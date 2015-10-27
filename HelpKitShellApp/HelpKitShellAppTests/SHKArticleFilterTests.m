//
//  SHKArticleFilterTests.m
//  Smooch
//
//  Created by Joel Simpson on 2014-04-24.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKSettings+Private.h"

@interface SHKArticleFilterTests : XCTestCase

@property SHKSettings* settings;

@end

@implementation SHKArticleFilterTests

- (void)setUp
{
    [super setUp];
    
    self.settings = [SHKSettings new];
}

- (void)testGoodSectionIdsAreSet
{
    [self.settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:@[@1, @2, @3]];
    
    XCTAssertTrue([self.settings.sectionsToFilter count] == 3, @"Numeric values should be accepted.");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@1], "Numeric values should be accepted.");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@2], "Numeric values should be accepted.");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@3], "Numeric values should be accepted.");
}

-(void)testStringsAreConvertedToNumbers
{
    [self.settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:@[ @"1", @"2" ]];
    
    XCTAssertEqual(self.settings.sectionsToFilter.count, 2, "Both should be accepted");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@1], "Strings should be converted to numbers");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@2], "Strings should be converted to numbers");
}

- (void)testInvalidSectionsIdsAreIgnored
{
    [self.settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:@[@1, [[UIView alloc] init], @3]];
    
    XCTAssertTrue([self.settings.sectionsToFilter count] == 2, "Invalid values should not be accepted bin articleSections.");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@1], "Numeric values should be accepted in articleSections.");
    XCTAssertTrue([self.settings.sectionsToFilter containsObject:@3], "Numeric values should be accepted in articleSections.");
}

- (void)testNilSectionIdsDoesNotSetMethod
{
    [self.settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:nil];
    
    XCTAssertNotNil(self.settings.sectionsToFilter, "Sections to filter should never be nil");
    XCTAssertFalse([self.settings.sectionsToFilter count], "articleSections should be empty if nil is passed");
}

- (void)testEmptySectionIdsDoesNotSetMethod
{
    [self.settings excludeSearchResultsIf:SHKSearchResultIsIn categories:nil sections:@[]];
    
    XCTAssertFalse([self.settings.sectionsToFilter count], "articleSections should be empty if an empty array is passed");
}

-(void)testInvalidFilterMode
{
    [self.settings excludeSearchResultsIf:-1 categories:nil sections:nil];
    
    XCTAssertNotEqual(self.settings.filterMode, -1, "Filter mode should not take an invalid value");
    XCTAssertNotNil(self.settings.sectionsToFilter, "Sections to filter should never be nil");
    XCTAssertFalse([self.settings.sectionsToFilter count], "Sections should be empty if nil is passed");
}


@end