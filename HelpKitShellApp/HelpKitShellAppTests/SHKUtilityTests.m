//
//  SHKUtilityTests.m
//  Smooch
//
//  Created by Mike Spensieri on 2015-10-11.
//  Copyright © 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKUtility.h"

@interface SHKUtilityTests : XCTestCase

@end

@implementation SHKUtilityTests

- (void)testIsValidZendeskUrl
{
    XCTAssertFalse(SHKIsValidZendeskUrl(@"just a string"),@"ZendeskUrl should contain http:// or https://");
    XCTAssertFalse(SHKIsValidZendeskUrl(@"brushes.zendesk.com"),@"ZendeskUrl should contain http:// or https://");
    XCTAssertTrue(SHKIsValidZendeskUrl(@"https://brushes.zendesk.com"),@"ZendeskUrl should contain http:// or https://");
    XCTAssertTrue(SHKIsValidZendeskUrl(@"http://brushes.zendesk.com"),@"ZendeskUrl should contain http:// or https://");
    XCTAssertTrue(SHKIsValidZendeskUrl([@"http://brushes.zendesk.com" mutableCopy]),@"ZendeskUrl should contain http:// or https://");
    
    XCTAssertFalse(SHKIsValidZendeskUrl((id)[UIView new]),@"ZendeskUrl should contain http:// or https://");
}

-(void)testAddIsMobileQueryParameter
{
    NSString* urlWithoutQueryParameter = @"http://some.url.to.append";
    
    XCTAssertTrue([SHKAddIsMobileQueryParameter(urlWithoutQueryParameter) isEqualToString:@"http://some.url.to.append?is_mobile=true"], "Should add query parameter if there is none");
    
    NSString* urlWithQueryParameter = @"http://some.url.to.append?has_query_parameter=true";
    
    XCTAssertTrue([SHKAddIsMobileQueryParameter(urlWithQueryParameter) isEqualToString:@"http://some.url.to.append?has_query_parameter=true&is_mobile=true"], "Should append to existing query parameter");
}

@end
