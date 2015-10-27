//
//  SHKSearchFallbackStrategyTests.m
//  Smooch
//
//  Created by Mike Spensieri on 2014-10-15.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKSearchFallbackStrategy.h"
#import "SHKSearchClient.h"
#import "OCMock.h"

@interface SHKSearchFallbackStrategy(Private)

@property SHKSearchEndpointFactory* factory;

-(void)onSearchError:(NSError*)error query:(NSString*)query completion:(void (^)(NSArray *results, NSError *error))completion;

@end

@interface SHKSearchFallbackStrategyTests : XCTestCase

@end

@implementation SHKSearchFallbackStrategyTests

-(void)testInit
{
    SHKSearchClient* client = [SHKSearchClient new];
    SHKSearchEndpointFactory* factory = [SHKSearchEndpointFactory new];
    
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:client factory:factory];
    
    XCTAssertNotNil(strategy, "Should initialize");
    XCTAssertEqual(client, strategy.searchClient, "Should keep the client");
    XCTAssertEqual(factory, strategy.factory, "Should keep the factory");
    XCTAssertEqual(SHKZendeskApiUndetermined, strategy.apiEndpoint, "Should have undetermined endpoint");
}

-(void)testSearchSetsFirstEndpoint
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    
    [strategy search:nil withCompletion:nil];
    
    XCTAssertEqual(SHKZendeskApiAjaxEndpoint, strategy.apiEndpoint, "Should use ajax as first endpoint");
}

-(void)testSearchSetsFirstRestEndpointWithFiltering
{
    id clientMock = [OCMockObject niceMockForClass:[SHKSearchClient class]];
    [[[clientMock expect] andReturnValue:@YES] filteringEnabled];
    
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:clientMock factory:nil];
    
    [strategy search:nil withCompletion:nil];
    
    XCTAssertEqual(SHKZendeskApiHelpCenterEndpoint, strategy.apiEndpoint, "Should use help center as first endpoint if filtering is enabled");
    
    [clientMock verify];
}

-(void)testSearchGetsEndpointFromFactory
{
    id factoryMock = [OCMockObject niceMockForClass:[SHKSearchEndpointFactory class]];
    [[[factoryMock expect] ignoringNonObjectArgs] objectForEndpoint:0];
    
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:factoryMock];
    
    [strategy search:nil withCompletion:nil];
    
    [factoryMock verify];
}

-(void)testSearchPerformsSearch
{
    id clientMock = [OCMockObject niceMockForClass:[SHKSearchClient class]];
    [[clientMock expect] search:OCMOCK_ANY withEndpoint:OCMOCK_ANY withCompletion:OCMOCK_ANY];
    
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:clientMock factory:nil];
    
    [strategy search:nil withCompletion:nil];
    
    [clientMock verify];
}

-(void)testSearchSuccessfulCallsCompletion
{
    id clientMock = [OCMockObject niceMockForClass:[SHKSearchClient class]];
    [[[clientMock expect] andDo:^(NSInvocation *invocation) {
        void (^completionBlock)(NSArray *results, NSError *error);
        
        [invocation getArgument:&completionBlock atIndex:4];
        
        completionBlock(nil, nil);
    }] search:OCMOCK_ANY withEndpoint:OCMOCK_ANY withCompletion:OCMOCK_ANY];
    
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:clientMock factory:nil];
    
    __block BOOL called = NO;
    [strategy search:nil withCompletion:^(NSArray *results, NSError *error) {
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
    [clientMock verify];
}

-(void)testSearchErrorNoInternetDoesNotFallback
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
    
    __block BOOL called = NO;
    [strategy onSearchError:error query:nil completion:^(NSArray *results, NSError *error) {
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
    
    XCTAssertEqual(SHKZendeskApiUndetermined, strategy.apiEndpoint, "Should not fallback if no internet");
}

-(void)testSearchErrorConnectionLostDoesNotFallback
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNetworkConnectionLost userInfo:nil];
    
    __block BOOL called = NO;
    [strategy onSearchError:error query:nil completion:^(NSArray *results, NSError *error) {
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
    
    XCTAssertEqual(SHKZendeskApiUndetermined, strategy.apiEndpoint, "Should not fallback if connection lost");
}

-(void)testSearchErrorFallbackSearchesAgain
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    
    id partiallyMockedStrategy = [OCMockObject partialMockForObject:strategy];
    [[partiallyMockedStrategy expect] search:OCMOCK_ANY withCompletion:OCMOCK_ANY];
    [[[partiallyMockedStrategy expect] ignoringNonObjectArgs] setApiEndpoint:0];
    
    [partiallyMockedStrategy onSearchError:nil query:nil completion:nil];
    
    [partiallyMockedStrategy verify];
}

-(void)testSearchErrorDoNotFallbackPastRest
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    strategy.apiEndpoint = SHKZendeskApiLegacyRestEndpoint;
    
    id partiallyMockedStrategy = [OCMockObject partialMockForObject:strategy];
    [[partiallyMockedStrategy reject] search:OCMOCK_ANY withCompletion:OCMOCK_ANY];
    [[[partiallyMockedStrategy reject] ignoringNonObjectArgs] setApiEndpoint:0];
    
    [partiallyMockedStrategy onSearchError:nil query:nil completion:nil];
    
    [partiallyMockedStrategy verify];
}

-(void)testSearchErrorCompletionCalledWhenNoMoreFallbacks
{
    SHKSearchFallbackStrategy* strategy = [[SHKSearchFallbackStrategy alloc] initWithSearchClient:nil factory:nil];
    strategy.apiEndpoint = SHKZendeskApiLegacyRestEndpoint;
    
    NSError* error = [NSError new];
    
    __block BOOL called = NO;
    [strategy onSearchError:error query:nil completion:^(NSArray *results, NSError *e) {
        XCTAssertEqual(error, e, "Should propagate the error");
        XCTAssertNil(results, "Should not have results");
        called = YES;
    }];
    
    XCTAssertTrue(called, "Should call completion");
}

@end
