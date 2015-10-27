//
//  SHKGetTopMostViewControllerTests.m
//  Smooch
//
//  Created by Michael Spensieri on 2/27/14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "SHKUtility.h"
#import "OCMock.h"

// Expose outlet to private utility method
UIViewController* SHKGetTopMostViewController(UIViewController* vc);

@interface SHKGetTopMostViewControllerTests : XCTestCase
@end

@implementation SHKGetTopMostViewControllerTests

-(void)testSingleViewController
{
    id rootControllerMock = [OCMockObject mockForClass:[UIViewController class]];
    [[[rootControllerMock expect] andReturn:nil] presentedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, rootControllerMock, "Single view controller should be the top VC");
    [rootControllerMock verify];
}

-(void)testViewControllerWithPresentedViewController
{
    id rootControllerMock = [OCMockObject mockForClass:[UIViewController class]];
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock stub] andReturn:expectedTopController] presentedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Presented VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testSingleNavigationController
{
    // Nav controller has no children
    id rootControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    
    [[[rootControllerMock expect] andReturn:nil] visibleViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, rootControllerMock, "Navigation VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testNavigationControllerWithChildController
{
    // Nav controller with a visible view controller
    id rootControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock expect] andReturn:expectedTopController] visibleViewController];
    [[[rootControllerMock expect] andReturn:expectedTopController] visibleViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Visible VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testNavigationControllerPresentsViewControllerTwice
{
    // Navigation controller's visible VC presents another VC
    id rootControllerMock = [OCMockObject mockForClass:[UINavigationController class]];
    id secondLevelController = [OCMockObject mockForClass:[UIViewController class]];
    
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock expect] andReturn:secondLevelController] visibleViewController];
    [[[rootControllerMock expect] andReturn:secondLevelController] visibleViewController];
    [[[secondLevelController expect] andReturn:expectedTopController] presentedViewController];
    [[[secondLevelController expect] andReturn:expectedTopController] presentedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Second level presented VC should be the top");
    
    [rootControllerMock verify];
    [secondLevelController verify];
}

-(void)testSingleTabBarController
{
    // Tab controller has no children
    id rootControllerMock = [OCMockObject mockForClass:[UITabBarController class]];
    
    [[[rootControllerMock expect] andReturn:nil] presentedViewController];
    [[[rootControllerMock expect] andReturn:nil] selectedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, rootControllerMock, "Tab VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testTabControllerWithSelectedController
{
    // Tab controller with selected controller
    id rootControllerMock = [OCMockObject mockForClass:[UITabBarController class]];
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock expect] andReturn:nil] presentedViewController];
    [[[rootControllerMock expect] andReturn:expectedTopController] selectedViewController];
    [[[rootControllerMock expect] andReturn:expectedTopController] selectedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Selected VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testTabControllerWithPresentedController
{
    // Tab controller with presented controller
    id rootControllerMock = [OCMockObject mockForClass:[UITabBarController class]];
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock expect] andReturn:expectedTopController] presentedViewController];
    [[[rootControllerMock expect] andReturn:expectedTopController] presentedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Presented VC should be the top");
    
    [rootControllerMock verify];
}

-(void)testTabControllerSelectedViewControllerPresentsViewController
{
    // Tab controller has a selected VC which presents a VC
    id rootControllerMock = [OCMockObject mockForClass:[UITabBarController class]];
    id selectedViewControllerMock = [OCMockObject mockForClass:[UIViewController class]];
    UIViewController* expectedTopController = [UIViewController new];
    
    [[[rootControllerMock expect] andReturn:nil] presentedViewController];
    [[[rootControllerMock expect] andReturn:selectedViewControllerMock] selectedViewController];
    [[[rootControllerMock expect] andReturn:selectedViewControllerMock] selectedViewController];
    
    [[[selectedViewControllerMock expect] andReturn:expectedTopController] presentedViewController];
    [[[selectedViewControllerMock expect] andReturn:expectedTopController] presentedViewController];
    
    UIViewController* foundController = SHKGetTopMostViewController(rootControllerMock);
    
    XCTAssertEqual(foundController, expectedTopController, "Presented VC should be the top");
    
    [rootControllerMock verify];
    [selectedViewControllerMock verify];
}

@end
