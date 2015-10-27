//
//  SHKStateMachineTests.m
//  Smooch
//
//  Created by Mike on 2014-05-14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKStateMachine.h"
#import "SHKTransition.h"
#import "OCMock.h"

@interface SHKStateMachineTests : XCTestCase < SHKStateMachineDelegate >

@property BOOL notificationReceived;
@property SHKStateMachine* notificationObject;

@end

@implementation SHKStateMachineTests

-(void)setUp
{
    [super setUp];
    self.notificationReceived = NO;
    self.notificationObject = nil;
}

-(void)tearDown
{
    [super tearDown];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)testChangeState
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    stateMachine.currentState = SmoochStateInactive;
    XCTAssertEqual(SmoochStateInactive, stateMachine.currentState, "Should update to the given state");
    
    stateMachine.currentState = SmoochStateTransitioning;
    XCTAssertEqual(SmoochStateTransitioning, stateMachine.currentState, "Should update to the given state");
    
    stateMachine.currentState = SmoochStateActive;
    XCTAssertEqual(SmoochStateActive, stateMachine.currentState, "Should update to the given state");
}

-(void)testChangeToSameState
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.currentState = SmoochStateInactive;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterInactiveStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateInactive;
    XCTAssertFalse(self.notificationReceived, "Should not notify if the state did not change");
    
    stateMachine.currentState = SmoochStateTransitioning;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterTransitioningStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateTransitioning;
    XCTAssertFalse(self.notificationReceived, "Should not notify if the state did not change");
    
    stateMachine.currentState = SmoochStateActive;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateActive;
    XCTAssertFalse(self.notificationReceived, "Should not notify if the state did not change");
}

-(void)testChangeToInactiveNotifies
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.currentState = SmoochStateTransitioning;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterInactiveStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateInactive;
    
    XCTAssertTrue(self.notificationReceived, "State machine should notify when entering inactive state");
    XCTAssertEqual(self.notificationObject, stateMachine, "Notification object should be the notifying machine");
}

-(void)testChangeToTransitioningNotifies
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterTransitioningStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateTransitioning;
    
    XCTAssertTrue(self.notificationReceived, "State machine should notify when entering transitioning state");
    XCTAssertNotEqual(self.notificationObject, stateMachine, "Notification object should not be the notifying machine");
    XCTAssertTrue([self.notificationObject isKindOfClass:[SHKTransition class]], "Notification object should be the new transition");
}

-(void)testChangeToTransitioningSetsSourceState
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    stateMachine.currentState = SmoochStateActive;
    
    stateMachine.currentState = SmoochStateTransitioning;
    XCTAssertNotNil(stateMachine.transition, "Should have a transition object");
    XCTAssertEqual(SmoochStateActive, stateMachine.transition.sourceState, "Should init transition object with previous state");
    
    // --------------------------------------------
    
    stateMachine = [SHKStateMachine new];
    
    stateMachine.currentState = SmoochStateInactive;
    
    stateMachine.currentState = SmoochStateTransitioning;
    XCTAssertNotNil(stateMachine.transition, "Should have a transition object");
    XCTAssertEqual(SmoochStateInactive, stateMachine.transition.sourceState, "Should init transition object with previous state");
}

-(void)testChangeToActiveNotifies
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateActive;
    
    XCTAssertTrue(self.notificationReceived, "State machine should notify when entering active state");
    XCTAssertEqual(self.notificationObject, stateMachine, "Notification object should be the notifying machine");
}

-(void)testChangeToSemiActiveNotifies
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKStateMachineDidEnterSemiActiveStateNotification object:nil];
    
    stateMachine.currentState = SmoochStateSemiActive;
    
    XCTAssertTrue(self.notificationReceived, "State machine should notify when entering semi active state");
    XCTAssertEqual(self.notificationObject, stateMachine, "Notification object should be the notifying machine");
}

-(void)testTransitionToInactiveWithExistingTransition
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.currentState = SmoochStateTransitioning;
    
    [self transitionMachine:stateMachine toState:SmoochStateInactive andVerifyWithNotificationName:SHKStateMachineDidEnterInactiveStateNotification];
}

-(void)testTransitionToActiveWithExistingTransition
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.currentState = SmoochStateTransitioning;
    
    [self transitionMachine:stateMachine toState:SmoochStateActive andVerifyWithNotificationName:SHKStateMachineDidEnterActiveStateNotification];
}

-(void)transitionMachine:(SHKStateMachine*)stateMachine toState:(SmoochState)state andVerifyWithNotificationName:(NSString*)notificationName
{
    id transitionMock = [OCMockObject mockForClass:[SHKTransition class]];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(SmoochState outputState);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(state);
    };
    [[[transitionMock expect] andDo:doBlock] transitionTo:state withCompletion:OCMOCK_ANY];
    
    stateMachine.transition = transitionMock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:notificationName object:nil];
    
    [stateMachine transitionToState:state];
    
    XCTAssertTrue(self.notificationReceived, "State machine should notify of completed transition");
    XCTAssertEqual(self.notificationObject, stateMachine, "Notification object should be the notifying machine");
    
    [transitionMock verify];
}

-(void)testCompleteActiveTransition
{
    id transitionMock = [OCMockObject mockForClass:[SHKTransition class]];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(SmoochState outputState);
        [invocation getArgument: &completionBlock atIndex:2];
        completionBlock(SmoochStateActive);
    };
    [[[transitionMock expect] andDo:doBlock] autoTransitionWithCompletion:OCMOCK_ANY];
    
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.transition = transitionMock;
    
    [stateMachine completeActiveTransition];
    
    XCTAssertEqual(SmoochStateActive, stateMachine.currentState, "Should set state to the one given by the transition");
    
    [transitionMock verify];
}

-(void)testDelegate
{
    SHKStateMachine* stateMachine = [SHKStateMachine new];
    stateMachine.currentState = SmoochStateInactive;
    
    stateMachine.delegate = self;
    
    stateMachine.currentState = SmoochStateTransitioning;
    XCTAssertEqual(stateMachine.currentState, SmoochStateInactive, "Should not change state if the delegate refuses");
    
    stateMachine.currentState = SmoochStateSemiActive;
    XCTAssertEqual(stateMachine.currentState, SmoochStateInactive, "Should not change state if the delegate refuses");
    
    stateMachine.currentState = SmoochStateActive;
    XCTAssertEqual(stateMachine.currentState, SmoochStateInactive, "Should not change state if the delegate refuses");
}

-(BOOL)stateMachine:(SHKStateMachine *)stateMachine shouldChangeToState:(SmoochState)state
{
    return NO;
}

-(void)onNotif:(NSNotification*)notification
{
    self.notificationReceived = YES;
    self.notificationObject = notification.object;
}

@end
