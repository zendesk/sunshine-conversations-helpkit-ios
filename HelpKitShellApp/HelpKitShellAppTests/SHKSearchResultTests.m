//
//  SHKSearchResultTests.m
//  Smooch
//
//  Created by Michael Spensieri on 5/1/14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKSearchResult.h"

@interface SHKSearchResultTests : XCTestCase

@end

@implementation SHKSearchResultTests

-(void)testInitWithTitleAndUrl
{
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithTitle:@"Title" url:@"Url"];
    
    XCTAssertTrue([result.title isEqualToString:@"Title"], "Should use the given title");
    XCTAssertTrue([result.htmlURL isEqualToString:@"Url"], "Should use the given url");
}

-(void)testInitWithDictionaryNameField
{
    NSDictionary* jsonResult = @{ @"name" : @"Title" };
    
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithDictionary:jsonResult];
    
    XCTAssertTrue([result.title isEqualToString:@"Title"], "Should use the name field if it exists");
}

-(void)testInitWithDictionaryTitleField
{
    NSDictionary* jsonResult = @{ @"title" : @"Title" };
    
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithDictionary:jsonResult];
    
    XCTAssertTrue([result.title isEqualToString:@"Title"], "Should use the title field if it exists");
}

-(void)testInitWithDictionaryHTMLUrl
{
    NSDictionary* jsonResult = @{ @"html_url" : @"Url" };
    
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithDictionary:jsonResult];
    
    XCTAssertTrue([result.htmlURL isEqualToString:@"Url"], "Should use the html_url field if it exists");
}

-(void)testInitWithDictionaryConvertsUrlToHTMLUrl
{
    NSString* jsonURL = @"https://prezi.zendesk.com/api/v2/topics/22140113.json";
    NSString* expectedHTMLUrl = @"https://prezi.zendesk.com/entries/22140113";
    
    NSDictionary* jsonResult = @{ @"url" : jsonURL };
    
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithDictionary:jsonResult];
    
    XCTAssertTrue([result.htmlURL isEqualToString:expectedHTMLUrl], "Should have converted json url to an html url");
}

-(void)testInitWithDictionarySectionId
{
    NSDictionary* jsonResult = @{ @"section_id" : @200 };
    
    SHKSearchResult* result = [[SHKSearchResult alloc] initWithDictionary:jsonResult];
    
    XCTAssertEqual([result.sectionId integerValue], 200, "Should have converted json url to an html url");
}

@end
