//
//  SHKNavigationViewControllerTests.m
//  Smooch
//
//  Created by Mike on 2014-05-20.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKNavigationViewController.h"
#import "SHKOffsetManager.h"
#import "SHKTransition.h"
#import "SHKStateMachine.h"
#import "SHKMessagesButtonView.h"
#import "SHKTutorialView.h"
#import "OCMock.h"
#import "SHKHomeViewController.h"
#import "SmoochHelpKit+Private.h"

@interface SHKNavigationViewController(Private)

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController andStateMachine:(SHKStateMachine*)stateMachine;

- (void)skipGestureHint;
-(void)updateStatusBar;
-(void)onOffsetChanged:(NSNotification*)notification;
-(void)smoochDidBecomeActive;
-(void)handleTransition:(SHKTransition*)transition visibleViewController:(UIViewController*)visibleViewController;

@property UIViewController* visibleViewController;
@property UINavigationBar* navigationBar;
@property SHKTutorialView* tutorialView;
@property BOOL gestureHintSkipped;

@end

@interface SHKNavigationViewControllerTests : XCTestCase

@end

@implementation SHKNavigationViewControllerTests

-(void)testOffsetChangedReframesMessagesButton
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id messagesButtonMock = [OCMockObject mockForClass:[SHKMessagesButtonView class]];
    [[messagesButtonMock expect] reframeAnimated:NO];
    
    vc.messagesButton = messagesButtonMock;
    
    [vc onOffsetChanged:nil];
    
    [messagesButtonMock verify];
}

-(void)testOffsetChangedReframesNavigationBar
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    
    id navBarMock = [OCMockObject niceMockForClass:[UINavigationBar class]];
    [[[navBarMock expect] ignoringNonObjectArgs] setFrame:CGRectZero];
    
    [[[partiallyMockedVc stub] andReturn:navBarMock] navigationBar];
    
    [partiallyMockedVc onOffsetChanged:nil];
    
    [navBarMock verify];
}

-(void)testOffsetChangedFadesTutorialViewIfShown
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id tutorialViewMock = [OCMockObject mockForClass:[SHKTutorialView class]];
    [[[tutorialViewMock expect] andReturnValue:@NO] isHidden];
    [[[tutorialViewMock expect] ignoringNonObjectArgs] setAlpha:0];
    
    vc.tutorialView = tutorialViewMock;
    
    [vc onOffsetChanged:nil];
    
    [tutorialViewMock verify];
}

-(void)testOffsetChangedDoesNotFadeTutorialViewIfHidden
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id tutorialViewMock = [OCMockObject mockForClass:[SHKTutorialView class]];
    [[[tutorialViewMock expect] andReturnValue:@YES] isHidden];
    [[[tutorialViewMock reject] ignoringNonObjectArgs] setAlpha:0];
    
    vc.tutorialView = tutorialViewMock;
    
    [vc onOffsetChanged:nil];
    
    [tutorialViewMock verify];
}

-(void)testOffsetChangedUpdatesStatusBar
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedController expect] updateStatusBar];
    
    [partiallyMockedController onOffsetChanged:nil];
    
    [partiallyMockedController verify];
}

-(void)testTransitionToActiveHidesTutorialView
{
    id tutorialViewMock = [OCMockObject niceMockForClass:[SHKTutorialView class]];
    [[[tutorialViewMock stub] andReturnValue:@YES] isHidden];
    [[tutorialViewMock expect] setHidden:YES];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.tutorialView = tutorialViewMock;
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVC expect] andReturnValue:@NO] conversationOnly];
    
    [partiallyMockedVC smoochDidBecomeActive];
    
    [tutorialViewMock verify];
    [partiallyMockedVC verify];
}

-(void)testTransitionFromActiveFadesOutVisibleVC
{
    id viewMock = [OCMockObject mockForClass:[UIView class]];
    [[viewMock expect] setAlpha:0];

    id visibleViewControllerMock = [OCMockObject mockForClass:[UIViewController class]];
    [[[visibleViewControllerMock expect] andReturn:viewMock] view];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:SmoochStateActive offsetManager:nil];
    
    [vc handleTransition:transition visibleViewController:visibleViewControllerMock];
    
    [viewMock verify];
    [visibleViewControllerMock verify];
}

-(void)testTransitionFromInactiveDoesNotFadeOutVisibleVC
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:SmoochStateInactive offsetManager:nil];
    
    id visibleViewControllerMock = [OCMockObject mockForClass:[UIViewController class]];
    [vc handleTransition:transition visibleViewController:visibleViewControllerMock];
    
    [visibleViewControllerMock verify];
}

-(void)testShowGestureHintShowsTutorialView
{
    id tutorialViewMock = [OCMockObject mockForClass:[SHKTutorialView class]];
    [[tutorialViewMock expect] setHidden:NO];
    [[tutorialViewMock expect] startAnimation];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.tutorialView = tutorialViewMock;
    
    [vc showGestureHint];
    
    [tutorialViewMock verify];
}

-(void)testShowGestureHintResetsSkippedFlag
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.gestureHintSkipped = YES;
    
    [vc showGestureHint];
    
    XCTAssertFalse(vc.gestureHintSkipped, "Should reset tutorial skipped flag");
}

-(void)testShowGestureHintSetsOffsetAndState
{
    id offsetManagerMock = [OCMockObject mockForClass:[SHKOffsetManager class]];
    [[offsetManagerMock expect] animateToPercentage:SHKOffsetManagerSemiActivePercentage isDragging:NO withCompletion:nil];
    
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] setCurrentState:SmoochStateSemiActive];
    [[[stateMachineMock expect] andReturn:offsetManagerMock] offsetManager];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new] andStateMachine:stateMachineMock];
    
    [vc showGestureHint];
    
    [offsetManagerMock verify];
    [stateMachineMock verify];
}

-(void)testSkipGestureHintSetsFlag
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.gestureHintSkipped = NO;
    
    [vc skipGestureHint];
    
    XCTAssertTrue(vc.gestureHintSkipped, "Should flag that the hint was skipped");
}

-(void)testSkipGestureHintTransitionsToActive
{
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] transitionToState:SmoochStateActive];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new] andStateMachine:stateMachineMock];
    
    [vc skipGestureHint];
    
    [stateMachineMock verify];
}

-(void)testShouldBeginGesture
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    XCTAssertTrue([vc appWideGestureHandlerShouldBeginGesture:nil], "Should begin gesture if no presented view controller");
}

-(void)testShouldChangeToStateIfGestureHintIsHidden
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.tutorialView = [SHKTutorialView new];
    vc.tutorialView.hidden = YES;
    
    XCTAssertTrue([vc stateMachine:nil shouldChangeToState:SmoochStateActive], "Should be able to change states");
     XCTAssertTrue([vc stateMachine:nil shouldChangeToState:SmoochStateInactive], "Should be able to change states");
     XCTAssertTrue([vc stateMachine:nil shouldChangeToState:SmoochStateSemiActive], "Should be able to change states");
     XCTAssertTrue([vc stateMachine:nil shouldChangeToState:SmoochStateTransitioning], "Should be able to change states");
}

-(void)testShouldNotChangeToInactiveStateIfGestureHintIsShown
{
    id offsetManagerMock = [OCMockObject mockForClass:[SHKOffsetManager class]];
    [[offsetManagerMock expect] animateToPercentage:SHKOffsetManagerSemiActivePercentage isDragging:NO withCompletion:nil];
    
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[[stateMachineMock expect] andReturn:offsetManagerMock] offsetManager];
    
    id tutorialViewMock = [OCMockObject mockForClass:[SHKTutorialView class]];
    [[[tutorialViewMock expect] andReturnValue:@NO] isHidden];
    [[tutorialViewMock expect] startAnimation];
    
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    vc.tutorialView = tutorialViewMock;
    
    XCTAssertFalse([vc stateMachine:stateMachineMock shouldChangeToState:SmoochStateInactive], "Should disallow changing to inactive state if gesture hint is shown");
    
    [offsetManagerMock verify];
    [stateMachineMock verify];
    [tutorialViewMock verify];
}

-(void)testConversationOnlySearchPlusRecommendations
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVC stub] andReturn:@[ [SHKHomeViewController new] ]] viewControllers];
    [SmoochHelpKit setTopRecommendation:@"http://www.apple.com"];
    
    XCTAssertFalse([vc conversationOnly], "Search + Recommendations is not conversation only");
}

-(void)testConversationOnlyJustRecommendations
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVC stub] andReturn:@[]] viewControllers];
    [SmoochHelpKit setTopRecommendation:@"http://www.apple.com"];
    
    XCTAssertFalse([vc conversationOnly], "Recommendations is not conversation only");
}

-(void)testConversationOnlyJustSearch
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVC stub] andReturn:@[ [SHKHomeViewController new] ]] viewControllers];
    [SmoochHelpKit setTopRecommendation:nil];
    [SmoochHelpKit setDefaultRecommendations:nil];
    
    XCTAssertFalse([vc conversationOnly], "Search is not conversation only");
}

-(void)testConversationOnlyNothing
{
    SHKNavigationViewController* vc = [[SHKNavigationViewController alloc] initWithRootViewController:[UIViewController new]];
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVC stub] andReturn:@[]] viewControllers];
    [SmoochHelpKit setTopRecommendation:nil];
    [SmoochHelpKit setDefaultRecommendations:nil];
    
    XCTAssertTrue([vc conversationOnly], "No search + no recommendation = conversation only");
}

@end
