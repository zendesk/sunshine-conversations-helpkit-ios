//
//  SHKZendeskSearchResultsFilterTests.m
//  Smooch
//
//  Created by Mike Spensieri on 2014-10-15.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKZendeskSearchResultsFilter.h"
#import "SHKSearchResult.h"
#import "SHKSettings+Private.h"
#import "SHKApiClient.h"
#import "SHKMockApiClientBuilder.h"

@interface SHKZendeskSearchResultsFilter()

@property SHKSettings* sdkSettings;
@property SHKApiClient* apiClient;

@end

@interface SHKZendeskSearchResultsFilterTests : XCTestCase

@end

@implementation SHKZendeskSearchResultsFilterTests

-(void)testInit
{
    SHKSettings* settings = [SHKSettings new];
    SHKApiClient* apiClient = [SHKApiClient new];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:apiClient settings:settings];
    
    XCTAssertNotNil(filter, "Should initialize");
    XCTAssertNotNil(filter.categoryMap, "Should initialize category map");
    XCTAssertEqual(settings, filter.sdkSettings, "Should keep the settings");
    XCTAssertEqual(apiClient, filter.apiClient, "Should keep the client");
}

-(void)testFilteringDisabled
{
    SHKSettings* settings = [SHKSettings new];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:settings];
    
    XCTAssertFalse(filter.filteringEnabled, "Should not be enabled");
}

-(void)testFilteringEnabledWithSection
{
    SHKSettings* settings = [SHKSettings new];
    [settings excludeSearchResultsIf:0 categories:nil sections:@[@1]];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:settings];
    
    XCTAssertTrue(filter.filteringEnabled, "Should be enabled");
}

-(void)testFilteringEnabledWithCategories
{
    SHKSettings* settings = [SHKSettings new];
    [settings excludeSearchResultsIf:0 categories:@[@1] sections:nil];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:settings];
    
    XCTAssertTrue(filter.filteringEnabled, "Should be enabled");
}

-(void)testLoadCategoryMapNoCategories
{
    id clientMock = [OCMockObject mockForClass:[SHKApiClient class]];
    
    SHKSettings* settings = [SHKSettings new];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:clientMock settings:settings];
    
    [filter loadCategoryMapIfAny];
    
    //Expect nothing
    [clientMock verify];
}

-(void)testLoadCategoryMapUsesHttps
{
    id argContainingHttps = [OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj rangeOfString:@"https://"].location != NSNotFound;
    }];
    id clientMock = [OCMockObject mockForClass:[SHKApiClient class]];
    [[clientMock expect] GET:argContainingHttps parameters:OCMOCK_ANY completion:OCMOCK_ANY];
    
    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"http://www.google.ca"; // URL uses http://
    [settings excludeSearchResultsIf:0 categories:@[@1] sections:nil];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:clientMock settings:settings];
    
    [filter loadCategoryMapIfAny];
    
    [clientMock verify];
}

-(void)testFilterNil
{
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:nil];
    
    XCTAssertNil([filter filterResults:nil], "Nil results should return nil");
}

-(void)testOnlyValidArticlesAreKeptWithSHKArticleIsInSection
{
    SHKSearchResult* article1 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @1 }];
    SHKSearchResult* article2 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @2 }];
    SHKSearchResult* article3 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @3 }];
    SHKSearchResult* article4 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @4 }];
    SHKSearchResult* article5 = [[SHKSearchResult alloc] init];

    NSArray* responses = @[ article1, article2, article3, article4, article5 ];

    SHKSettings* settings = [SHKSettings new];
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:@[@1, @3]];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:settings];

    NSArray* filtered = [filter filterResults:responses];
    XCTAssertEqual([filtered count], 3, @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article2], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article4], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article5], @"applyFilteringOnResults should filter out the correct articles");
}

-(void)testOnlyValidArticlesAreKeptWithSHKArticleIsNotInSection
{
    SHKSearchResult* article1 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @1 }];
    SHKSearchResult* article2 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @2 }];
    SHKSearchResult* article3 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @3 }];
    SHKSearchResult* article4 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @4 }];
    SHKSearchResult* article5 = [[SHKSearchResult alloc] init];

    NSArray* responses = @[ article1, article2, article3, article4, article5 ];
    
    SHKSettings* settings = [SHKSettings new];
    [settings excludeSearchResultsIf:SHKSearchResultIsNotIn categories:nil sections:@[@1, @3]];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:nil settings:settings];
    
    NSArray* filtered = [filter filterResults:responses];
    
    XCTAssertEqual([filtered count], 3, @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article1], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article3], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article5], @"applyFilteringOnResults should filter out the correct articles");
}

-(void)testFilterByCategory
{
    NSDictionary* mockSectionsResponse =
    @{@"sections":
        @[
            @{@"id": @1, @"category_id":@2},
            @{@"id": @3, @"category_id":@4}
        ]
    };
    SHKSearchResult* article1 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @1 }];
    SHKSearchResult* article2 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @2 }];
    SHKSearchResult* article3 = [[SHKSearchResult alloc] init];
    NSArray* responses = @[ article1, article2, article3];

    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://fixmestick.zendesk.com";
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[@2] sections:nil];

    id clientMock = [SHKMockApiClientBuilder newMockedClientforMethod:@"GET" withError:nil andResponseObject:mockSectionsResponse];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:clientMock settings:settings];
    
    [filter loadCategoryMapIfAny];

    XCTAssertEqual([[filter categoryMap] count], 2);

    NSArray* filtered = [filter filterResults:responses];
    XCTAssertEqual([filtered count], 2, @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article2], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article3], @"applyFilteringOnResults should filter out the correct articles");

    [clientMock verify];
}

-(void)testApiError
{
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
    id clientMock = [SHKMockApiClientBuilder newMockedClientforMethod:@"GET" withError:error andResponseObject:nil];

    SHKSettings* settings = [SHKSettings new];
    settings.knowledgeBaseURL = @"https://fixmestick.zendesk.com";
    // Section id filtering should still work normally
    [settings excludeSearchResultsIf:SHKSearchResultIsIn categories:@[@42] sections:@[@1]];
    
    SHKZendeskSearchResultsFilter* filter = [[SHKZendeskSearchResultsFilter alloc] initWithApiClient:clientMock settings:settings];
    
    [filter loadCategoryMapIfAny];

    SHKSearchResult* article1 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @1 }];
    SHKSearchResult* article2 = [[SHKSearchResult alloc] initWithDictionary:@{ @"section_id" : @2 }];
    SHKSearchResult* article3 = [[SHKSearchResult alloc] init];
    NSArray* responses = @[ article1, article2, article3];
    NSArray* filtered = [filter filterResults:responses];

    // cateogryMap should be empty
    XCTAssertEqual([filter categoryMap], @{}, "categoryMap should be empty");
    XCTAssertEqual([filtered count], 2, @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article2], @"applyFilteringOnResults should filter out the correct articles");
    XCTAssert([filtered containsObject:article3], @"applyFilteringOnResults should filter out the correct articles");

    [clientMock verify];
}

@end
