//
//  SHKSearchEndpointFactoryTests.m
//  Smooch
//
//  Created by Mike Spensieri on 2014-10-15.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKSearchEndpointFactory.h"
#import "SHKHelpCenterAjaxEndpoint.h"
#import "SHKHelpCenterRestEndpoint.h"
#import "SHKLegacyAjaxEndpoint.h"
#import "SHKLegacyRestEndpoint.h"
#import "OCMock.h"

@interface SHKSearchEndpointFactory(Private)

@property NSString* knowledgeBaseURL;

@end

@interface SHKSearchEndpointFactoryTests : XCTestCase

@end

@implementation SHKSearchEndpointFactoryTests

-(void)testInit
{
    NSString* url = @"";
    
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:url];
    
    XCTAssertNotNil(factory, "Should initialize");
    XCTAssertEqual(url, factory.knowledgeBaseURL, "Should keep the url");
}

-(void)testAjax
{
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:nil];
    
    XCTAssertTrue([[factory objectForEndpoint:SHKZendeskApiAjaxEndpoint] isKindOfClass:[SHKHelpCenterAjaxEndpoint class]], "Should return the right class");
}

-(void)testLegacyAjax
{
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:nil];
    
    XCTAssertTrue([[factory objectForEndpoint:SHKZendeskApiAjaxLegacyEndpoint] isKindOfClass:[SHKLegacyAjaxEndpoint class]], "Should return the right class");
}

-(void)testHelpKitRest
{
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:nil];
    
    XCTAssertTrue([[factory objectForEndpoint:SHKZendeskApiHelpCenterEndpoint] isKindOfClass:[SHKHelpCenterRestEndpoint class]], "Should return the right class");
}

-(void)testLegacyRest
{
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:nil];
    
    XCTAssertTrue([[factory objectForEndpoint:SHKZendeskApiLegacyRestEndpoint] isKindOfClass:[SHKLegacyRestEndpoint class]], "Should return the right class");
}

-(void)testUndetermined
{
    SHKSearchEndpointFactory* factory = [[SHKSearchEndpointFactory alloc] initWithKnowledgeBaseURL:nil];
    
    XCTAssertNil([factory objectForEndpoint:SHKZendeskApiUndetermined], "Should return nil");
}

@end
