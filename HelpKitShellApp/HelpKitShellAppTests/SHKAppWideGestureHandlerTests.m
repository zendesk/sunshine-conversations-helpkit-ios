//
//  SHKAppWideGestureHandlerTests.m
//  Smooch
//
//  Created by Mike on 2014-05-13.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKAppWideGestureHandler.h"
#import "OCMock.h"
#import "SHKTwoFingerSwipeGestureRecognizer.h"
#import "SHKStateMachine.h"
#import "SHKTransition.h"

@interface SHKAppWideGestureHandler(Private)

-(void)handleGesture:(SHKTwoFingerSwipeGestureRecognizer*)swipeGesture;

@property SHKTwoFingerSwipeGestureRecognizer* panGesture;
@property UIWindow* currentWindow;
@property SHKStateMachine* stateMachine;
@property NSMutableSet* otherRecognizers;

@end

@interface SHKAppWideGestureHandlerTests : XCTestCase < SHKAppWideGestureHandlerDelegate >

@end

@implementation SHKAppWideGestureHandlerTests

-(void)testInitWithStateMachine
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachine];
    
    XCTAssertEqual(stateMachine, handler.stateMachine, "Should use the given state machine");
}

-(void)testAddAppWideGestureAddsToNewWindow
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    id windowMock = [OCMockObject niceMockForClass:[UIWindow class]];
    [[windowMock expect] addGestureRecognizer:OCMOCK_ANY];
    
    [handler addAppWideGestureTo:windowMock];
    
    [windowMock verify];
}

-(void)testAddGestureRecognizersRemovesFromOldWindow
{
    id oldWindowMock = [OCMockObject mockForClass:[UIWindow class]];
    [[oldWindowMock expect] removeGestureRecognizer:OCMOCK_ANY];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    handler.currentWindow = oldWindowMock;
    
    [handler addAppWideGestureTo:nil];
    
    [oldWindowMock verify];
}

-(void)testDelegateCanIgnoreGesture
{
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[gestureRecognizerMock reject] state];
    
    // Expect nothing
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachineMock];
    handler.delegate = self;
    
    [handler handleGesture:gestureRecognizerMock];
    
    // Delegate refuses gesture, nothing should happen
    [gestureRecognizerMock verify];
    [stateMachineMock verify];
}

-(BOOL)appWideGestureHandlerShouldBeginGesture:(SHKAppWideGestureHandler *)gestureHandler
{
    return NO;
}

// -----------------------------------------------------------------------------------
// GESTURE BEGAN TESTS
// -----------------------------------------------------------------------------------

-(void)testGestureBeginsFiresNotification
{
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] setCurrentState:SmoochStateTransitioning];
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateBegan)] state];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachineMock];
    
    [handler handleGesture:gestureRecognizerMock];
    
    [stateMachineMock verify];
    [gestureRecognizerMock verify];
}

-(void)testGestureBeginsCancelsOtherRecognizers
{
    NSMutableArray* otherRecognizers = [NSMutableArray new];
    for(int i = 0; i < 5; i++){
        id gestureRecognizerMock = [OCMockObject mockForClass:[UIGestureRecognizer class]];
        [[gestureRecognizerMock expect] setEnabled:NO];
        
        [otherRecognizers addObject:gestureRecognizerMock];
    }
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateBegan)] state];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    handler.otherRecognizers = [NSMutableSet setWithArray:otherRecognizers];
    
    [handler handleGesture:gestureRecognizerMock];
    
    for(id mock in otherRecognizers){
        [mock verify];
    }
    [gestureRecognizerMock verify];
}

// -----------------------------------------------------------------------------------
// GESTURE CHANGED TESTS
// -----------------------------------------------------------------------------------

-(void)testGestureChangedUpdatesTransitionAndResetsOffset
{
    CGFloat offsetToMove = 10;
    
    id transitionMock = [OCMockObject mockForClass:[SHKTransition class]];
    [[transitionMock expect] addOffset:offsetToMove];
    
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.transition = transitionMock;
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateChanged)] state];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(offsetToMove)] verticalOffset];
    [[[gestureRecognizerMock expect] andReturn:nil] view];
    [[gestureRecognizerMock expect] setTranslation:CGPointZero inView:nil];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachine];
    
    [handler handleGesture:gestureRecognizerMock];
    
    [transitionMock verify];
    [gestureRecognizerMock verify];
}

// -----------------------------------------------------------------------------------
// GESTURE ENDED TESTS
// -----------------------------------------------------------------------------------

-(void)testGestureEndedReenablesOtherRecognizers
{
    NSMutableArray* otherRecognizers = [NSMutableArray new];
    for(int i = 0; i < 5; i++){
        id gestureRecognizerMock = [OCMockObject mockForClass:[UIGestureRecognizer class]];
        [[gestureRecognizerMock expect] setEnabled:YES];
        
        [otherRecognizers addObject:gestureRecognizerMock];
    }
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateEnded)] state];
    [[[gestureRecognizerMock stub] andReturnValue:OCMOCK_VALUE(0.0f)] verticalVelocity];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    handler.otherRecognizers = [NSMutableSet setWithArray:otherRecognizers];
    
    [handler handleGesture:gestureRecognizerMock];
    
    XCTAssertEqual(0, handler.otherRecognizers.count, "Should clear the recognizers after enabling them");
    
    for(id mock in otherRecognizers){
        [mock verify];
    }
    [gestureRecognizerMock verify];
}

-(void)testGestureCancelledReenablesOtherRecognizers
{
    NSMutableArray* otherRecognizers = [NSMutableArray new];
    for(int i = 0; i < 5; i++){
        id gestureRecognizerMock = [OCMockObject mockForClass:[UIGestureRecognizer class]];
        [[gestureRecognizerMock expect] setEnabled:YES];
        
        [otherRecognizers addObject:gestureRecognizerMock];
    }
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateCancelled)] state];
    [[[gestureRecognizerMock stub] andReturnValue:OCMOCK_VALUE(0.0f)] verticalVelocity];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    handler.otherRecognizers = [NSMutableSet setWithArray:otherRecognizers];
    
    [handler handleGesture:gestureRecognizerMock];
    
    XCTAssertEqual(0, handler.otherRecognizers.count, "Should clear the recognizers after enabling them");
    
    for(id mock in otherRecognizers){
        [mock verify];
    }
    [gestureRecognizerMock verify];
}

-(void)testGestureEndedWithSwipeUp
{
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] transitionToState:SmoochStateInactive];
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateEnded)] state];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(-1500.0f)] verticalVelocity];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachineMock];
    
    [handler handleGesture:gestureRecognizerMock];
    
    [stateMachineMock verify];
    [gestureRecognizerMock verify];
}

-(void)testGestureEndedWithSwipeDown
{
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] transitionToState:SmoochStateActive];
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateEnded)] state];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(1500.0f)] verticalVelocity];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachineMock];
    
    [handler handleGesture:gestureRecognizerMock];
    
    [stateMachineMock verify];
    [gestureRecognizerMock verify];
}

-(void)testGestureEndedNormally
{
    id stateMachineMock = [OCMockObject mockForClass:[SHKStateMachine class]];
    [[stateMachineMock expect] completeActiveTransition];
    
    id gestureRecognizerMock = [OCMockObject mockForClass:[SHKTwoFingerSwipeGestureRecognizer class]];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(UIGestureRecognizerStateEnded)] state];
    [[[gestureRecognizerMock expect] andReturnValue:OCMOCK_VALUE(0.0f)] verticalVelocity];
    
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:stateMachineMock];
    
    [handler handleGesture:gestureRecognizerMock];
    
    [stateMachineMock verify];
    [gestureRecognizerMock verify];
}

// -----------------------------------------------------------------------------------
// SHOULD RECOGNIZE SIMULTANEOUSLY TESTS
// -----------------------------------------------------------------------------------

-(void)testShouldRecognizeSimultaneouslyAddsPansToSet
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    UIPanGestureRecognizer* otherRecognizer = [UIPanGestureRecognizer new];
    
    [handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:otherRecognizer];
    
    XCTAssertTrue([handler.otherRecognizers containsObject:otherRecognizer], "Should add recognizer to the list");
}

-(void)testShouldRecognizeSimultaneouslyDoesNotAddOtherTypesToSet
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    for(Class gestureRecognizerSubclass in @[ [UITapGestureRecognizer class], [UIPinchGestureRecognizer class], [UISwipeGestureRecognizer class], [UIRotationGestureRecognizer class], [UILongPressGestureRecognizer class] ]){
        
        UIGestureRecognizer* otherRecognizer = [gestureRecognizerSubclass new];
        
        [handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:otherRecognizer];
        
        XCTAssertFalse([handler.otherRecognizers containsObject:otherRecognizer], "Should not add non-pan recognizer to the list");
    }
}

-(void)testShouldRecognizeSimultaneouslyDoesNotAddOwnGestureToSet
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    handler.panGesture = [SHKTwoFingerSwipeGestureRecognizer new];
    
    [handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:handler.panGesture];
    
    XCTAssertFalse([handler.otherRecognizers containsObject:handler.panGesture], "Two finger swipe should not be added to the list");
}

-(void)testShouldRecognizeSimultaneouslyWithPinch
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    UIPinchGestureRecognizer* pinch = [UIPinchGestureRecognizer new];
    
    XCTAssertFalse([handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:pinch], "Should not recognize siultaneously with pinch");
}

-(void)testShouldRecognizeSimultaneouslyWithRotation
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    UIRotationGestureRecognizer* rotation = [UIRotationGestureRecognizer new];
    
    XCTAssertFalse([handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:rotation], "Should not recognize siultaneously with rotate");
}

-(void)testShouldRecognizeSimultaneouslyWithOther
{
    SHKAppWideGestureHandler* handler = [[SHKAppWideGestureHandler alloc] initWithStateMachine:nil];
    
    for(Class gestureRecognizerSubclass in @[ [UITapGestureRecognizer class], [UIPanGestureRecognizer class], [UISwipeGestureRecognizer class], [UILongPressGestureRecognizer class] ]){
        
        UIGestureRecognizer* otherRecognizer = [gestureRecognizerSubclass new];
        
        XCTAssertTrue([handler gestureRecognizer:[UIPanGestureRecognizer new] shouldRecognizeSimultaneouslyWithGestureRecognizer:otherRecognizer], "Should recognize siultaneously with everything but pinch and rotate");
        
    }
}

@end
