//
//  SHKSearchClientTests.m
//  Smooch
//
//  Created by Mike Spensieri on 2014-10-15.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKSearchClient.h"
#import "OCMock.h"
#import "SHKApiClient.h"
#import "SHKSearchEndpoint.h"
#import "SHKLegacyAjaxEndpoint.h"
#import "SHKZendeskSearchResultsFilter.h"

@interface SHKSearchClient(Private)

@property SHKApiClient* apiClient;
@property NSURLSessionTask* lastRequest;
@property SHKZendeskSearchResultsFilter* filter;

-(void)searchCompletedWithError:(NSError*)error completion:(void (^)(NSArray *, NSError *))completion;
-(void)searchCompletedWithResponseObject:(id)responseObject endpoint:(id<SHKSearchEndpoint>)endpoint completion:(void (^)(NSArray *, NSError *))completion;

@end

@interface SHKSearchClientTests : XCTestCase
@end

@implementation SHKSearchClientTests

-(void)testInitWithApiClient
{
    SHKApiClient* apiClient = [SHKApiClient new];
    SHKZendeskSearchResultsFilter* filter = [SHKZendeskSearchResultsFilter new];
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:apiClient filter:filter];
    
    XCTAssertNotNil(searchClient, "Should init successfully");
    XCTAssertEqual(apiClient, searchClient.apiClient, "Should keep api client");
    XCTAssertEqual(filter, searchClient.filter, "Should keep filter");
}

-(void)testSearchCancelsLastRequest
{
    id taskMock = [OCMockObject mockForClass:[NSURLSessionTask class]];
    [[taskMock expect] cancel];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    searchClient.lastRequest = taskMock;
    
    [searchClient search:nil withEndpoint:nil withCompletion:nil];
    
    [taskMock verify];
}

-(void)testSearchSetsUserAgentHeader
{
    id apiClientMock = [OCMockObject niceMockForClass:[SHKApiClient class]];
    [[apiClientMock expect] setValue:OCMOCK_ANY forHTTPHeaderField:@"User-Agent"];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:apiClientMock filter:nil];
    
    [searchClient search:nil withEndpoint:nil withCompletion:nil];
    
    [apiClientMock verify];
}

-(void)testSearchExpectJsonResponse
{
    id apiClientMock = [OCMockObject niceMockForClass:[SHKApiClient class]];
    [[[apiClientMock expect] ignoringNonObjectArgs] setExpectJSONResponse:NO];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:apiClientMock filter:nil];
    
    [searchClient search:nil withEndpoint:nil withCompletion:nil];
    
    [apiClientMock verify];
}

-(void)testSearchEncodesQuery
{
    NSString* query = @"A B";
    NSString* encodedQuery = @"A%20B";
    
    id endpointMock = [OCMockObject mockForProtocol:@protocol(SHKSearchEndpoint)];
    [[endpointMock expect] urlForQuery:encodedQuery];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    [searchClient search:query withEndpoint:endpointMock withCompletion:nil];
    
    [endpointMock verify];
}

-(void)testSearchStartSetsLastRequest
{
    id task = [OCMockObject niceMockForClass:[NSURLSessionTask class]];
    
    id apiClientMock = [OCMockObject niceMockForClass:[SHKApiClient class]];
    [[[apiClientMock expect] andReturn:task] GET:OCMOCK_ANY parameters:OCMOCK_ANY completion:OCMOCK_ANY];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:apiClientMock filter:nil];
    
    [searchClient search:nil withEndpoint:nil withCompletion:nil];
    
    XCTAssertEqual(searchClient.lastRequest, task, "Should set last request");
    
    [apiClientMock verify];
}

-(void)testSearchError400DoesNotTriggerError
{
    id taskMock = [OCMockObject niceMockForClass:[NSURLSessionDataTask class]];
    [[[taskMock expect] andReturn:[[NSHTTPURLResponse alloc] initWithURL:[NSURL new] statusCode:400 HTTPVersion:nil headerFields:nil]] response];
    
    id apiClientMock = [self newMockedClientCallingCompletionWithTask:taskMock error:[NSError new] responseObject:nil];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:apiClientMock filter:nil];
    
    [searchClient search:@" " withEndpoint:nil withCompletion:^(NSArray *results, NSError *error) {
        XCTAssertNil(error, "Should not trigger error");
        XCTAssertEqual(results.count, 0, "Should treat 400 error as no results found");
    }];
    
    [taskMock verify];
    [apiClientMock verify];
}

-(void)testSearchErrorCancelledDoesNotCallCompletion
{
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    __block BOOL called = NO;
    [searchClient searchCompletedWithError:error completion:^(NSArray *a, NSError *e) {
        called = YES;
    }];
    
    XCTAssertFalse(called, "Should not call completion");
}

-(void)testSearchErrorCallsCompletion
{
    NSError* error = [NSError new];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    __block BOOL called = NO;
    [searchClient searchCompletedWithError:error completion:^(NSArray *a, NSError *e) {
        XCTAssertEqual(error, e, "Should call completion with error");
        XCTAssertNil(a, "Should call completion without results");
        
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
}

-(void)testSearchSuccessDeserializesJSON
{
    id endpointMock = [OCMockObject mockForProtocol:@protocol(SHKSearchEndpoint)];
    [[endpointMock expect] deserializeResultsJSON:OCMOCK_ANY];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    [searchClient searchCompletedWithResponseObject:nil endpoint:endpointMock completion:nil];
    
    [endpointMock verify];
}

-(void)testSearchSuccessDeserializesData
{
    // Workaround for OCMock. mockForProtocol does not allow to override respondsToSelector, so we have to use SHKLegacyAjaxEndpoint
    id endpointMock = [OCMockObject mockForClass:[SHKLegacyAjaxEndpoint class]];
    [[endpointMock expect] deserializeResultsData:OCMOCK_ANY];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    [searchClient searchCompletedWithResponseObject:nil endpoint:endpointMock completion:nil];
    
    [endpointMock verify];
}

-(void)testSearchSuccessUsesFilter
{
    id filterMock = [OCMockObject mockForClass:[SHKZendeskSearchResultsFilter class]];
    [[[filterMock expect] andReturnValue:@YES] filteringEnabled];
    [[filterMock expect] filterResults:OCMOCK_ANY];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:filterMock];
    
    [searchClient searchCompletedWithResponseObject:nil endpoint:nil completion:nil];
    
    [filterMock verify];
}

-(void)testSearchSuccessCallsCompletion
{
    NSArray* results = @[];
    
    id endpointMock = [OCMockObject mockForProtocol:@protocol(SHKSearchEndpoint)];
    [[[endpointMock expect] andReturn:results] deserializeResultsJSON:OCMOCK_ANY];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    __block BOOL called = NO;
    [searchClient searchCompletedWithResponseObject:nil endpoint:endpointMock completion:^(NSArray * array, NSError * error) {
        XCTAssertEqual(array, results, "Should return the deserialized results");
        XCTAssertNil(error, "Should not give an error");
        
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
}

-(void)testDeserializeErrorCallsCompletionWithError
{
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    
    __block BOOL called = NO;
    [searchClient searchCompletedWithResponseObject:nil endpoint:nil completion:^(NSArray * array, NSError * error) {
        XCTAssertNil(array, "Results should be nil");
        XCTAssertNotNil(error, "Should return a deserialization error");
        
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
}

-(void)testCancelCancels
{
    id taskMock = [OCMockObject mockForClass:[NSURLSessionTask class]];
    [[taskMock expect] cancel];
    
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    searchClient.lastRequest = taskMock;
    
    [searchClient cancelCurrentRequest];
    
    [taskMock verify];
}

-(void)testCancelSetsLastRequestToNil
{
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:nil];
    searchClient.lastRequest = [OCMockObject niceMockForClass:[NSURLSessionTask class]];
    
    [searchClient cancelCurrentRequest];
    
    XCTAssertNil(searchClient.lastRequest, "Should set the request to nil");
}

-(void)testFilteringEnabled
{
    id filterMock = [OCMockObject mockForClass:[SHKZendeskSearchResultsFilter class]];
    SHKSearchClient* searchClient = [[SHKSearchClient alloc] initWithApiClient:nil filter:filterMock];
    
    [[[filterMock expect] andReturnValue:@NO] filteringEnabled];
    
    XCTAssertFalse([searchClient filteringEnabled], "Should return filter's value");
    
    [filterMock verify];
    
    [[[filterMock expect] andReturnValue:@YES] filteringEnabled];
    
    XCTAssertTrue([searchClient filteringEnabled], "Should return filter's value");
    
    [filterMock verify];
}

-(id)newMockedClientCallingCompletionWithTask:(NSURLSessionDataTask*)task error:(NSError*)error responseObject:(id)responseObject
{
    id apiClientMock = [OCMockObject niceMockForClass:[SHKApiClient class]];
    [[[apiClientMock expect] andDo:^(NSInvocation *invocation) {
        void (^completionBlock)(NSURLSessionDataTask *task, NSError *error, id responseObject);
        
        [invocation getArgument:&completionBlock atIndex:4];
        
        completionBlock(task, error, responseObject);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY completion:OCMOCK_ANY];
    
    return apiClientMock;
}

@end
