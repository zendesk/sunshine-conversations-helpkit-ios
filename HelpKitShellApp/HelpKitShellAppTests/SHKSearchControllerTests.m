//
//  SHKSearchControllerTests.m
//  Smooch
//
//  Created by Mike on 2014-05-07.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKSearchController.h"
#import "OCMock.h"
#import "SHKSearchResult.h"
#import "SHKSearchFallbackStrategy.h"
#import "SHKSearchClient.h"
#import "SHKMockApiClientBuilder.h"

@interface SHKSearchControllerTests : XCTestCase

@end

@implementation SHKSearchControllerTests

-(void)testSearchResetsError
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    controller.error = [NSError new];
    [controller search:nil];
    XCTAssertNil(controller.error, "Error should be reset after a search");
    
    controller.error = [NSError new];
    [controller search:@""];
    XCTAssertNil(controller.error, "Error should be reset after a search");
    
    controller.error = [NSError new];
    [controller search:@"Not Empty"];
    XCTAssertNil(controller.error, "Error should be reset after a search");
}

-(void)testSearchEmptyQuery
{
    id strategyMock = [OCMockObject mockForClass:[SHKSearchFallbackStrategy class]];
    id searchClientMock = [OCMockObject mockForClass:[SHKSearchClient class]];
    
    [[[strategyMock expect] andReturn:searchClientMock] searchClient];
    
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:strategyMock];
    controller.searchResults = @[];
    
    [[searchClientMock expect] cancelCurrentRequest];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:nil];
    
    [controller search:@""];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(controller.searchResults, "Search results should be nil for an empty query");
        
        [strategyMock verify];
        [searchClientMock verify];
    }];
}

-(void)testSearchFails
{
    NSError* searchError = [NSError new];
    NSString* searchQuery = @"Some Query";
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(NSArray *results, NSError *error);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(nil, searchError);
    };
    id strategyMock = [OCMockObject mockForClass:[SHKSearchFallbackStrategy class]];
    [[[strategyMock expect] andDo:doBlock] search:searchQuery withCompletion:OCMOCK_ANY];
    
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:strategyMock];
    controller.searchResults = @[];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:nil];
    
    [controller search:searchQuery];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(controller.searchResults, "Search results should be nil for a failed search");
        XCTAssertEqual(controller.error, searchError, "Controller should keep the error");
        
        [strategyMock verify];
    }];
}

-(void)testSearchSucceeds
{
    NSString* searchQuery = @"Some Other Query";
    NSArray* searchResults = @[ [SHKSearchResult new]  ];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(NSArray *results, NSError *error, NSString* query);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(searchResults, nil, nil);
    };
    id strategyMock = [OCMockObject mockForClass:[SHKSearchFallbackStrategy class]];
    [[[strategyMock expect] andDo:doBlock] search:searchQuery withCompletion:OCMOCK_ANY];
    
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:strategyMock];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:nil];
    
    [controller search:searchQuery];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNotNil(controller.searchResults, "Search results should not be nil for a successful search");
        XCTAssertEqual(controller.searchResults, searchResults, "Controller should keep the results");
        
        [strategyMock verify];
    }];
}

-(void)testSetSearchResultsFiresNotification
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    NSArray* results = @[ [SHKSearchResult new] ];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:nil];
    
    controller.searchResults = results;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertEqual(controller.searchResults, results, "Controller should keep the search results it was given");
    }];
}

-(void)testSearchResultAtIndexNoResults
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    controller.searchResults = @[ ];
    
    XCTAssertNil([controller searchResultAtIndex:0], "Should return nil if no results");
    XCTAssertNil([controller searchResultAtIndex:1], "Should return nil if no results");
}

-(void)testSearchResultAtIndexNilResults
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    controller.searchResults = nil;
    
    XCTAssertNil([controller searchResultAtIndex:0], "Should return nil if nil results");
    XCTAssertNil([controller searchResultAtIndex:1], "Should return nil if nil results");
}

-(void)testSearchResultAtIndexWithResults
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    SHKSearchResult* result1 = [SHKSearchResult new];
    SHKSearchResult* result2 = [SHKSearchResult new];
    controller.searchResults = @[ result1, result2 ];
    
    XCTAssertEqual(result1, [controller searchResultAtIndex:0], "Should return the correct results");
    XCTAssertEqual(result2, [controller searchResultAtIndex:1], "Should return the correct results");
}

-(void)testSearchStartNotifies
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    [self expectationForNotification:SHKSearchStartedNotification object:controller handler:nil];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

-(void)testSearchErrorNotifies
{
    id strategyMock = [self newMockedStrategyCallingCompletionWithError:[NSError new]];
    
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:strategyMock];
    
    [self expectationForNotification:SHKSearchCompleteNotification object:controller handler:nil];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [strategyMock verify];
    }];
}

-(void)testSearchSuccessNotifies
{
    id strategyMock = [self newMockedStrategyCallingCompletionWithError:nil];
    
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:strategyMock];
    
    [self expectationForNotification:SHKSearchCompleteNotification object:controller handler:nil];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [strategyMock verify];
    }];
}

-(void)testCancelNotifies
{
    SHKSearchController* controller = [[SHKSearchController alloc] initWithStrategy:nil];
    
    [self expectationForNotification:SHKSearchCancelledNotification object:controller handler:nil];
    
    [controller cancelCurrentRequest];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

-(id)newMockedStrategyCallingCompletionWithError:(NSError*)error
{
    id apiClientMock = [OCMockObject niceMockForClass:[SHKSearchFallbackStrategy class]];
    [[[apiClientMock expect] andDo:^(NSInvocation *invocation) {
        void (^completionBlock)(NSArray *results, NSError *error);
        
        [invocation getArgument:&completionBlock atIndex:3];
        
        completionBlock(nil, error);
    }] search:OCMOCK_ANY withCompletion:OCMOCK_ANY];
    
    return apiClientMock;
}

@end
