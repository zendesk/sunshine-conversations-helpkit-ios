//
//  SHKRecommendationsViewControllerTests.m
//  Smooch
//
//  Created by Michael Spensieri on 4/23/14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKRecommendationsViewController.h"
#import "OCMock.h"
#import "SHKNavigationViewController.h"
#import "SHKRecommendations.h"
#import "SHKSwipeView.h"
#import "SHKRecommendationsManager.h"
#import "SHKTransition.h"

@interface SHKRecommendationsViewController(Private)

@property SHKSwipeView* swipeView;
@property BOOL needsUpdate;
@property UILabel* indexLabel;
@property UILabel* headerLabel;
@property SHKRecommendationsManager* recommendationsManager;

- (void)fadeInLabels;
- (void)fadeOutLabels;
-(CGPoint)getHeaderCenterPoint;

-(void)onRecommendationsUpdated;
-(void)onSmoochBecameActive:(NSNotification*)notification;
-(void)setNeedsSwipeViewUpdate;
-(void)refreshSwipeView;

@end

@interface SHKRecommendationsViewControllerTests : XCTestCase

@end

@implementation SHKRecommendationsViewControllerTests

-(void)testHeaderNotShownIfNoArticles
{
    // Expect nothing
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock expect] andReturnValue:@0] numberOfRecommendationsInSwipeView];
    
    [vc recommendationsManager:recommendationsManagerMock didChangeIndex:1];
    
    [mockTextLabel verify];
    [recommendationsManagerMock verify];
}

-(void)testHeaderFadesInIfNotShownWhenScrolling
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(0.0f)] alpha];
    [[mockTextLabel stub] setText:OCMOCK_ANY];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController expect] fadeInLabels];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@1] numberOfRecommendationsInSwipeView];
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didChangeIndex:1];
    
    [partiallyMockedViewController verify];
    [mockTextLabel verify];
    [recommendationsManagerMock verify];
}

-(void)testHeaderDoesNotFadeInIfShownWhenScrolling
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(1.0f)] alpha];
    [[mockTextLabel stub] setText:OCMOCK_ANY];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController reject] fadeInLabels];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@1] numberOfRecommendationsInSwipeView];
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didChangeIndex:1];
    
    [partiallyMockedViewController verify];
    [mockTextLabel verify];
    [recommendationsManagerMock verify];
}

-(void)testHeaderFadesOutWhenScrollingToBeginningAndHeaderIsShown
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(1.0f)] alpha];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController expect] fadeOutLabels];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@1] numberOfRecommendationsInSwipeView];
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didChangeIndex:0];
    
    [partiallyMockedViewController verify];
    [mockTextLabel verify];
    [recommendationsManagerMock verify];
}

-(void)testHeaderDoesNotFadeOutWhenScrollingToBeginningAndHeaderNotShown
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(0.0f)] alpha];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController reject] fadeOutLabels];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@1] numberOfRecommendationsInSwipeView];
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didChangeIndex:0];
    
    [partiallyMockedViewController verify];
    [mockTextLabel verify];
    [recommendationsManagerMock verify];
}

-(void)testLabelIncludesCurrentIndexAndMaxNumber
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(1.0f)] alpha];
    [[mockTextLabel stub] setText:@"111 / 222"];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id mockRecommendationsManager = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[mockRecommendationsManager stub] andReturnValue:OCMOCK_VALUE(222)] numberOfRecommendationsInSwipeView];
    [[[mockRecommendationsManager stub] andReturnValue:OCMOCK_VALUE(222)] numberOfRecommendationsInSwipeView];
    
    [vc recommendationsManager:mockRecommendationsManager didChangeIndex:111];
    
    [mockTextLabel verify];
    [mockRecommendationsManager verify];
}

-(void)testCurrentIndexCannotExceedMaxNumber
{
    id mockTextLabel = [OCMockObject mockForClass:[UILabel class]];
    [[[mockTextLabel expect] andReturnValue:OCMOCK_VALUE(1.0f)] alpha];
    [[mockTextLabel stub] setText:@"222 / 222"];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.indexLabel = mockTextLabel;
    
    id mockRecommendationsManager = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[mockRecommendationsManager stub] andReturnValue:OCMOCK_VALUE(222)] numberOfRecommendationsInSwipeView];
    [[[mockRecommendationsManager stub] andReturnValue:OCMOCK_VALUE(222)] numberOfRecommendationsInSwipeView];
    
    [vc recommendationsManager:mockRecommendationsManager didChangeIndex:223];
    
    [mockTextLabel verify];
    [mockRecommendationsManager verify];
}

-(void)testRecommendationsChangedTriggersUpdate
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedVc expect] setNeedsSwipeViewUpdate];
    
    [partiallyMockedVc onRecommendationsUpdated];
    
    [partiallyMockedVc verify];
}

-(void)testWillRotateHidesSwipeViewAndSetsFlag
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id viewMock = [OCMockObject mockForClass:[UIView class]];
    [[viewMock expect] setAlpha:0];
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedViewController expect] andReturn:viewMock] view];
    
    [partiallyMockedViewController willRotateToInterfaceOrientation:0 duration:0];
    
    [viewMock verify];
    [partiallyMockedViewController verify];
}

-(void)testDidFinishRotatingTriggersUpdateAndResetsFlag
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id viewMock = [OCMockObject mockForClass:[UIView class]];
    [[viewMock expect] setAlpha:1.0];
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedViewController stub] andReturn:viewMock] view];
    [[[partiallyMockedViewController expect] andReturnValue:[NSValue valueWithCGPoint:CGPointZero]] getHeaderCenterPoint];
    [[partiallyMockedViewController expect] setNeedsSwipeViewUpdate];
    
    [partiallyMockedViewController didRotateFromInterfaceOrientation:0];
    
    [partiallyMockedViewController verify];
    [viewMock verify];
}

-(void)testSetNeedsSwipeViewUpdateSmoochShown
{
    id viewMock = [OCMockObject mockForClass:[UIView class]];
    [[[viewMock stub] andReturn:viewMock] window];
    [[[viewMock expect] andReturnValue:@NO] isHidden];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedVc expect] refreshSwipeView];
    [[[partiallyMockedVc stub] andReturn:viewMock] view];
    
    [partiallyMockedVc setNeedsSwipeViewUpdate];
    
    [viewMock verify];
    [partiallyMockedVc verify];
}

-(void)testSetNeedsSwipeViewUpdateSmoochHidden
{
    id viewMock = [OCMockObject mockForClass:[UIView class]];
    [[[viewMock stub] andReturn:viewMock] window];
    [[[viewMock expect] andReturnValue:@YES] isHidden];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = NO;
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVc stub] andReturn:viewMock] view];
    
    [partiallyMockedVc setNeedsSwipeViewUpdate];
    
    XCTAssertTrue(vc.needsUpdate, "Should flag that update is required");
    
    [viewMock verify];
    [partiallyMockedVc verify];
}

-(void)testSetNeedsSwipeViewUpdateNoWindow
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = NO;
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVc expect] andReturn:nil] view];
    
    [partiallyMockedVc setNeedsSwipeViewUpdate];
    
    XCTAssertTrue(vc.needsUpdate, "Should flag that update is required");
    
    [partiallyMockedVc verify];
}

-(void)testRefreshSwipeView
{
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[recommendationsManagerMock expect] clearImageCache];
    
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[swipeViewMock expect] reloadData];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = recommendationsManagerMock;
    
    [vc refreshSwipeView];
    
    [recommendationsManagerMock verify];
    [swipeViewMock verify];
}

-(void)testFireReachedSecondToLastRecommendationNotification
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController stub] viewDidLoad];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@4] numberOfRecommendationsInSwipeView];
    
    NSString *notificationName = SHKRecommendationsViewControllerReachedSecondToLastRecommendation;
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    [[observerMock expect] notificationWithName:notificationName object:nil];
    
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didChangeIndex:3];
    
    [recommendationsManagerMock verify];
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

-(void)testFireReachedEndOfRecommandation
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id partiallyMockedViewController = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedViewController stub] viewDidLoad];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock stub] andReturnValue:@4] numberOfRecommendationsInSwipeView];
    
    NSString *notificationName = SHKRecommendationsViewControllerReachedEndOfRecommandation;
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    [[observerMock expect] notificationWithName:notificationName object:nil];
    
    
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didScrollToOffset:4];
    // scroll pass
    [partiallyMockedViewController recommendationsManager:recommendationsManagerMock didScrollToOffset:4.5];
    
    [recommendationsManagerMock verify];
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

#pragma mark - View Did Appear

-(void)testViewDidAppearReloadsSwipeViewIfNecessaryAndScreenshotsEnabled
{
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock stub] andReturnValue:@0] currentItemIndex];
    [[swipeViewMock expect] reloadData];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock expect] andReturnValue:@YES] shouldTakeScreenshots];
    [[recommendationsManagerMock expect] clearImageCache];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = YES;
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = recommendationsManagerMock;
    
    [vc viewDidAppear:NO];
    
    XCTAssertFalse(vc.needsUpdate, "Should reset the needs update flag");
    
    [swipeViewMock verify];
    [recommendationsManagerMock verify];
}

-(void)testViewDidAppearDoesNotReloadSwipeViewIfNecessaryButScreenshotsNotEnabled
{
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock stub] andReturnValue:@0] currentItemIndex];
    [[swipeViewMock reject] reloadData];
    
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[recommendationsManagerMock expect] andReturnValue:@NO] shouldTakeScreenshots];
    [[recommendationsManagerMock reject] clearImageCache];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = YES;
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = recommendationsManagerMock;
    
    [vc viewDidAppear:NO];
    
    XCTAssertTrue(vc.needsUpdate, "Should not update - screenshots are not enabled");
    
    [swipeViewMock verify];
    [recommendationsManagerMock verify];
}

-(void)testViewDidAppearDoesNotReloadSwipeViewIfNotNecessary
{
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock stub] andReturnValue:@0] currentItemIndex];
    id recommendationsManagerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = NO;
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = recommendationsManagerMock;
    
    [vc viewDidAppear:NO];
    
    XCTAssertFalse(vc.needsUpdate, "Should not update if it's not necessary");
    
    // Expect nothing
    [swipeViewMock verify];
    [recommendationsManagerMock verify];
}

#pragma mark - Smooch Became Inactive

-(void)testSmoochBecameInactiveResetsSwipeView
{
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[swipeViewMock expect] scrollToItemAtIndex:0 duration:0];
    
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    [vc viewDidAppear:YES];
    vc.swipeView = swipeViewMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterInactiveStateNotification object:nil];
    
    [swipeViewMock verify];
}

#pragma mark - Smooch Became Active

-(void)testSmoochBecameActiveRefreshSwipeViewIfNecessary
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = YES;
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedVc expect] refreshSwipeView];
    
    [partiallyMockedVc onSmoochBecameActive:nil];
    
    XCTAssertFalse(vc.needsUpdate, "Should not need update - it just updated");
    
    [partiallyMockedVc verify];
}

-(void)testSmoochBecameActiveDoesNotRefreshSwipeViewIfNotNecessary
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    vc.needsUpdate = NO;
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[partiallyMockedVc reject] refreshSwipeView];
    
    [partiallyMockedVc onSmoochBecameActive:nil];
    
    XCTAssertFalse(vc.needsUpdate, "Should not need an update");
    
    [partiallyMockedVc verify];
}

-(void)testSmoochBecameActiveEnablesScrollIfRecommendations
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    [vc viewDidAppear:YES];
    vc.needsUpdate = NO;
    
    id managerMock = [OCMockObject niceMockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(1)] numberOfRecommendationsInSwipeView];
    
    id swipeViewMock = [OCMockObject niceMockForClass:[SHKSwipeView class]];
    [[swipeViewMock expect] setScrollEnabled:YES];
    
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = managerMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    [swipeViewMock verify];
    [managerMock verify];
}

-(void)testSmoochBecameActiveDoesNotEnableScrollIfNoRecommendations
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    [vc viewDidAppear:YES];
    vc.needsUpdate = NO;
    
    id managerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(0)] numberOfRecommendationsInSwipeView];
    [[managerMock expect] setShouldTakeScreenshots:YES];
    
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[swipeViewMock reject] setScrollEnabled:YES];
    
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = managerMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    [swipeViewMock verify];
    [managerMock verify];
}

-(void)testSmoochBecameActiveScrollsToFirstItem
{
    [self verifySwipeViewScrollsToFirstItemFromState:SmoochStateActive];
}

-(void)testSmoochBecameActiveScrollsToFirstItemFromGestureHint
{
    [self verifySwipeViewScrollsToFirstItemFromState:SmoochStateSemiActive];
}

-(void)verifySwipeViewScrollsToFirstItemFromState:(SmoochState)state
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    [vc viewDidAppear:YES];
    vc.needsUpdate = NO;
    
    id managerMock = [OCMockObject niceMockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(1)] numberOfRecommendationsInSwipeView];
    
    id swipeViewMock = [OCMockObject niceMockForClass:[SHKSwipeView class]];
    [[[swipeViewMock expect] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    
    vc.swipeView = swipeViewMock;
    vc.recommendationsManager = managerMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    [swipeViewMock verify];
    [managerMock verify];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:state offsetManager:nil];
    
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.transition = transition;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:stateMachine];
    
    [swipeViewMock verify];
    [managerMock verify];
}

-(void)testSmoochBecameActiveFadesInLabelsIfNotOnFirstIndex
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];
    
    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [partiallyMockedVC viewDidAppear:YES];
    [partiallyMockedVC setNeedsUpdate:NO];
    
    id managerMock = [OCMockObject niceMockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(1)] numberOfRecommendationsInSwipeView];
    
    id swipeViewMock = [OCMockObject niceMockForClass:[SHKSwipeView class]];
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    
    [partiallyMockedVC setSwipeView:swipeViewMock];
    [partiallyMockedVC setRecommendationsManager:managerMock];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:SmoochStateActive offsetManager:nil];
    
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.transition = transition;
    
    [[partiallyMockedVC expect] fadeInLabels];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:stateMachine];
    
    [swipeViewMock verify];
    [managerMock verify];
    [partiallyMockedVC verify];
}

-(void)testSmoochBecameActiveDoesNotFadeInLabelsIfOnFirstIndex
{
    SHKRecommendationsViewController* vc = [SHKRecommendationsViewController new];

    id partiallyMockedVC = [OCMockObject partialMockForObject:vc];
    [partiallyMockedVC viewDidAppear:YES];
    [partiallyMockedVC setNeedsUpdate:NO];
    
    id managerMock = [OCMockObject niceMockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(1)] numberOfRecommendationsInSwipeView];
    
    id swipeViewMock = [OCMockObject niceMockForClass:[SHKSwipeView class]];
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(0)] currentItemIndex];
    
    [partiallyMockedVC setSwipeView:swipeViewMock];
    [partiallyMockedVC setRecommendationsManager:managerMock];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:SmoochStateActive offsetManager:nil];
    
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.transition = transition;
    
    [[partiallyMockedVC reject] fadeInLabels];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:stateMachine];
    
    [swipeViewMock verify];
    [managerMock verify];
    [partiallyMockedVC verify];
}

@end
