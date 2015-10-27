//
//  SHKRecommendationsTests.m
//  Smooch
//
//  Created by Joel Simpson on 2014-04-15.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKRecommendations.h"

@interface SHKRecommendations()

@property NSArray* defaultRecommendations;
@property NSString* topRecommendation;

@end

@interface SHKRecommendationsTests : XCTestCase

@property SHKRecommendations* recommendations;
@property BOOL notificationReceived;

@end

@implementation SHKRecommendationsTests

- (void)setUp
{
    [super setUp];
    self.notificationReceived = NO;
    self.recommendations = [[SHKRecommendations alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendationsUpdated) name:SHKRecommendationsUpdatedNotification object:nil];
}

-(void)tearDown
{
    [super tearDown];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)testTopRecommendationIsNilWhenNeverSet
{
    XCTAssertNil(self.recommendations.topRecommendation, @"Top recommendation should be nil if it's never been set");
}

-(void)testDefaultRecommendationsIsEmptyWhenNeverSet
{
    XCTAssertNotNil(self.recommendations.defaultRecommendations, "Should not be nil");
    XCTAssertEqual(self.recommendations.defaultRecommendations.count, 0, "Default recommendations should be empty if never set");
}

-(void)testTopRecommendationIsSet{
    [self.recommendations setTopRecommendation:@"https://smooch.zendesk.com/hc/en-us/articles/200637380-When-is-an-Android-version-coming-"];
    XCTAssert([self.recommendations.topRecommendation isEqualToString:@"https://smooch.zendesk.com/hc/en-us/articles/200637380-When-is-an-Android-version-coming-"],@"Top recommendation should be set if passed a valid article page.");
}

-(void)testTopRecommendationIsNotSetWithBadURL{
    [self.recommendations setTopRecommendation:@"htt://smooch.zendesk.com/hc/en-us/articles/200637380-When-is-an-Android-version-coming-"];
    XCTAssertNil(self.recommendations.topRecommendation ,@"Top recommendations should be nil if passed a an invalid article page.");
}

-(void)testTopRecommendationCanBeReset
{
    [self.recommendations setTopRecommendation:@"https://smooch.zendesk.com/hc/en-us/articles/200637380-When-is-an-Android-version-coming-"];
    [self.recommendations setTopRecommendation:@"https://smooch.zendesk.com/hc/en-us/articles/200504405-How-can-I-submit-a-bug-"];
    XCTAssert([self.recommendations.topRecommendation isEqualToString:@"https://smooch.zendesk.com/hc/en-us/articles/200504405-How-can-I-submit-a-bug-"], @"Top recommendations should be overwritten if a new one is set with a valid article page");
}

-(void)testTopRecommendationCanBeNil
{
    [self.recommendations setTopRecommendation:nil];
    
    XCTAssertNil(self.recommendations.topRecommendation, "Should be correctly set to nil");
}

-(void)testDefaultRecommendationsCanBeResetWithGoodURLs
{
    [self.recommendations setDefaultRecommendations: @[@"https://smooch.zendesk.com/hc/en-us/articles/200637380-When-is-an-Android-version-coming-",
                                                     @"https://smooch.zendesk.com/hc/en-us/articles/200504405-How-can-I-submit-a-bug-"]];
    [self.recommendations setDefaultRecommendations: @[@"https://smooch.zendesk.com/hc/en-us/articles/200584104-May-I-submit-a-feature-request-",
                                                     @"https://smooch.zendesk.com/hc/en-us/articles/200793930-Error-in-search-UI-Smooch-showInViewController-provided-Zendesk-URL-must-contain-http-or-https-and-be-valid-as-per-NSURL-",
                                                     @"https://smooch.zendesk.com/hc/en-us/articles/200512685-Trouble-installing-Cocoapods"]];
    
    XCTAssert([self.recommendations.defaultRecommendations count] == 3, @"When valid URLs are set as the default recommendationss, the array should contain 3 recommendationss");
    XCTAssert([self.recommendations.defaultRecommendations containsObject:@"https://smooch.zendesk.com/hc/en-us/articles/200584104-May-I-submit-a-feature-request-"], @"Default recommendationss should contain new recommendations if being overwritten.");
    XCTAssert([self.recommendations.defaultRecommendations containsObject:@"https://smooch.zendesk.com/hc/en-us/articles/200793930-Error-in-search-UI-Smooch-showInViewController-provided-Zendesk-URL-must-contain-http-or-https-and-be-valid-as-per-NSURL-"], @"Default recommendationss should contain new recommendations if being overwritten.");
    XCTAssert([self.recommendations.defaultRecommendations containsObject:@"https://smooch.zendesk.com/hc/en-us/articles/200512685-Trouble-installing-Cocoapods"], @"Default recommendationss should contain new recommendations if being overwritten.");
}

-(void)testDefaultRecommendationsOnlyAcceptsValidURLs
{
    [self.recommendations setDefaultRecommendations: @[@"https://smooch.zendesk.com/hc/en-us/articles/200584104-May-I-submit-a-feature-request-",
                                                     @"hps://smooch.zendesk.com/hc/en-us/articles/200793930-Error-in-search-UI-Smooch-showInViewController-provided-Zendesk-URL-must-contain-http-or-https-and-be-valid-as-per-NSURL-",
                                                     @"https://smooch.zendesk.com/hc/en-us/articles/200512685-Trouble-installing-Cocoapods"]];
    
    XCTAssert([self.recommendations.defaultRecommendations count] == 2, @"Default recommendationss should not accept an invalid url.");
}

-(void)testNilDefaultRecommendationsIsSetToEmptyArray
{
    [self.recommendations setDefaultRecommendations:nil];
    
    XCTAssertNotNil(self.recommendations.defaultRecommendations, "Should not be nil");
    XCTAssertEqual(self.recommendations.defaultRecommendations.count, 0, "Should be empty");
}

-(void)testNonStringRecommendationsAreRemoved
{
    [self.recommendations setDefaultRecommendations:@[ @"http://www.apple.com", [UIView new] ]];
    
    XCTAssertNotNil(self.recommendations.defaultRecommendations, "Should not be nil");
    XCTAssertEqual(self.recommendations.defaultRecommendations.count, 1, "Should remove the uiview");
    XCTAssertTrue([self.recommendations.defaultRecommendations[0] isEqualToString:@"http://www.apple.com"]);
}

-(void)testTopRecommendationIsAtFrontOfListIfExists
{
    [self.recommendations setTopRecommendation:@"https://www.apple.ca"];
    
    XCTAssertEqual(self.recommendations.recommendationsList.count, 1);
    XCTAssertTrue([self.recommendations.recommendationsList[0] isEqualToString:@"https://www.apple.ca"]);
    
    [self.recommendations setDefaultRecommendations: @[@"https://www.google.ca"]];
    
    XCTAssertEqual(self.recommendations.recommendationsList.count, 2);
    XCTAssertTrue([self.recommendations.recommendationsList[0] isEqualToString:@"https://www.apple.ca"]);
}

-(void)testNoTopRecommendationDoesNotThrowException
{
    [self.recommendations setTopRecommendation:nil];
    
    XCTAssertNoThrow(self.recommendations.recommendationsList, "Should not throw exception if top recommendations is nil");
}

-(void)testNotifyWhenUpdatingTopRecommendation
{
    [self.recommendations setTopRecommendation:nil];
    
    XCTAssertTrue(self.notificationReceived, "Should have received notification");
}

-(void)testNotifyWhenUpdatingDefaultRecommendations
{
    [self.recommendations setDefaultRecommendations:nil];
    
    XCTAssertTrue(self.notificationReceived, "Should have received notification");
}

-(void)recommendationsUpdated
{
    self.notificationReceived = YES;
}


@end
