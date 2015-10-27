//
//  SHKSearchIntegrationTests.m
//  SmoochTests
//
//  Created by Michael Spensieri on 11/11/13.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKSearchController.h"
#import "SHKSettings.h"
#import "SHKSearchFallbackStrategy.h"
#import "SHKZendeskSearchResultsFilter.h"
#import "SHKApiClient.h"

@interface SHKSearchController(Private)

@property SHKSearchFallbackStrategy* strategy;

@end

@interface SHKSearchIntegrationTests : XCTestCase
@end

@implementation SHKSearchIntegrationTests

-(void)testAJAXEndpoint
{
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://fixmestick.zendesk.com";
    SHKSearchController* controller = [SHKSearchController searchControllerWithSettings:settings];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:^BOOL(NSNotification *notification) {
        XCTAssertNil(controller.error, "Should not have an error");
        XCTAssertGreaterThan(controller.searchResults.count, 0, "Should have results");
        
        return YES;
    }];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        SHKSearchFallbackStrategy* strategy = controller.strategy;
        
        XCTAssertEqual(strategy.apiEndpoint, SHKZendeskApiAjaxEndpoint, "Should have found ajax api");
    }];
}

-(void)testLegacyAJAXEndpoint
{
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://mortgagecoach.zendesk.com";
    SHKSearchController* controller = [SHKSearchController searchControllerWithSettings:settings];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:^BOOL(NSNotification *notification) {
        XCTAssertNil(controller.error, "Should not have an error");
        XCTAssertGreaterThan(controller.searchResults.count, 0, "Should have results");
        
        return YES;
    }];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        SHKSearchFallbackStrategy* strategy = controller.strategy;
        
        XCTAssertEqual(strategy.apiEndpoint, SHKZendeskApiAjaxLegacyEndpoint, "Should have found legacy ajax api");
    }];
}

-(void)testHelpKitEndpoint
{
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://support.zendesk.com";
    
    // Setting filtering should default to help center api
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[] sections:@[@1]];

    SHKSearchController* controller = [SHKSearchController searchControllerWithSettings:settings];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:^BOOL(NSNotification *notification) {
        XCTAssertNil(controller.error, "Should not have an error");
        XCTAssertGreaterThan(controller.searchResults.count, 0, "Should have results");
        
        return YES;
    }];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        SHKSearchFallbackStrategy* strategy = controller.strategy;
        
        XCTAssertEqual(strategy.apiEndpoint, SHKZendeskApiHelpCenterEndpoint, "Should have found help center api");
    }];
}

// HelpKit API returns 400 error when querying without text
// Verify that we handle this case correctly and report 0 results instead of error
-(void)testHelpKitEndpointWithSpace
{
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://support.zendesk.com";
    
    // Setting filtering should default to help center api
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[] sections:@[@1]];
    
    SHKSearchController* controller = [SHKSearchController searchControllerWithSettings:settings];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:^BOOL(NSNotification *notification) {
        XCTAssertNil(controller.error, "Should not have an error");
        XCTAssertEqual(controller.searchResults.count, 0, "Should not have results");
        
        return YES;
    }];
    
    [controller search:@" "];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        SHKSearchFallbackStrategy* strategy = controller.strategy;
        
        XCTAssertEqual(strategy.apiEndpoint, SHKZendeskApiHelpCenterEndpoint, "Should have found help center api");
    }];
}

-(void)testRESTEndpoint
{
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://mortgagecoach.zendesk.com";
    
    // Setting filtering should default to help center api, and it should fallback to rest
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[] sections:@[@1]];
    
    SHKSearchController* controller = [SHKSearchController searchControllerWithSettings:settings];
    
    [self expectationForNotification:SHKSearchControllerResultsDidChangeNotification object:controller handler:^BOOL(NSNotification *notification) {
        XCTAssertNil(controller.error, "Should not have an error");
        XCTAssertGreaterThan(controller.searchResults.count, 0, "Should have results");
        
        return YES;
    }];
    
    [controller search:@"a"];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        SHKSearchFallbackStrategy* strategy = controller.strategy;
        
        XCTAssertEqual(strategy.apiEndpoint, SHKZendeskApiLegacyRestEndpoint, "Should have found rest api");
    }];
}

-(void)testCategoriesEndpoint
{
    SHKSettings* settings = [SHKSettings new];
    
    // NOTE: http:// is used here on purpose - this is an https only api
    // we are verifying that http is changed to https
    settings.knowledgeBaseURL = @"http://support.zendesk.com";
    
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[@1] sections:nil];
    
    SHKApiClient* apiClient = [[SHKApiClient alloc] initWithBaseURL:settings.knowledgeBaseURL];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:apiClient settings:settings];
    
    [self keyValueObservingExpectationForObject:filter keyPath:@"categoryMap" handler:^BOOL(id observedObject, NSDictionary *change) {
        XCTAssertGreaterThan(filter.categoryMap.count, 0, "Should find some data");
        
        return YES;
    }];
    
    [filter loadCategoryMapIfAny];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
