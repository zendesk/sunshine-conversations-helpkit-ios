//
//  SHKTransitionTests.m
//  Smooch
//
//  Created by Mike on 2014-05-14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKTransition.h"
#import "SHKOffsetManager.h"
#import "OCMock.h"

@interface SHKTransition(Private)

-(SmoochState)outputState;

@end

@interface SHKTransitionTests : XCTestCase

@end

@implementation SHKTransitionTests

-(void)testInitWithSourceState
{
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:SmoochStateActive offsetManager:nil];
    
    XCTAssertEqual(transition.sourceState, SmoochStateActive, "Should keep the state that is given");
    
    transition = [[SHKTransition alloc] initWithSourceState:SmoochStateInactive offsetManager:nil];
    
    XCTAssertEqual(transition.sourceState, SmoochStateInactive, "Should keep the state that is given");
}

-(void)testOutputState
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManager];
    for(CGFloat i = 0; i <= 0.5; i = i + 0.01){
        
        offsetManager.offsetPercentage = i;
        
        XCTAssertEqual([transition outputState], SmoochStateInactive, "Should be inactive for percentages lower than 50");
    }
    
    for(CGFloat i = 0.51; i <= 1.0; i = i + 0.01){
        offsetManager.offsetPercentage = i;
        
        XCTAssertEqual([transition outputState], SmoochStateActive, "Should be active for percentages higher than 50");
    }
}

-(void)testAddOffset
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    offsetManager.offsetPercentage = 0.5;
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManager];
    
    [transition addOffset:10];
    
    XCTAssertEqualWithAccuracy(0.6f, offsetManager.offsetPercentage, 0.01, "AddOffset should modify the completion percentage if positive");
    
    [transition addOffset:-10];
    
    XCTAssertEqual(0.5f, offsetManager.offsetPercentage, "AddOffset should modify the completion percentage if negative");
}

-(void)testAddOffsetLimitsVelocity
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    offsetManager.offsetPercentage = 0.5;
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManager];
    
    [transition addOffset:20];
    
    XCTAssertEqualWithAccuracy(0.62f, offsetManager.offsetPercentage, 0.01, "AddOffset should limit the positive offset");
    
    [transition addOffset:-20];
    
    XCTAssertEqual(0.5f, offsetManager.offsetPercentage, "AddOffset should limit the negative offset");
}

-(void)testTransitionToInactiveSetsOffsetAndCallsCompletion
{
    id offsetManagerMock = [OCMockObject mockForClass:[SHKOffsetManager class]];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(void);
        [invocation getArgument: &completionBlock atIndex:4];
        completionBlock();
    };
    [[[offsetManagerMock expect] andDo:doBlock] animateToPercentage:SHKOffsetManagerInactivePercentage isDragging:NO withCompletion:OCMOCK_ANY];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManagerMock];
    
    __block SmoochState stateReturned = -1;
    [transition transitionTo:SmoochStateInactive withCompletion:^(SmoochState outputState) {
        stateReturned = outputState;
    }];
    
    XCTAssertEqual(SmoochStateInactive, stateReturned, "Should call completion block with the correct output state");
    
    [offsetManagerMock verify];
}

-(void)testTransitionToActiveWithBounce
{
    id offsetManagerMock = [OCMockObject mockForClass:[SHKOffsetManager class]];
    [[[offsetManagerMock expect] andReturnValue:@YES] shouldBounce];
    [[[offsetManagerMock stub] andReturnValue:OCMOCK_VALUE(0.0f)] bouncePercentage];
    [[[offsetManagerMock stub] andReturnValue:OCMOCK_VALUE(1.0f)] activeStateSnapPercentage];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(void);
        [invocation getArgument: &completionBlock atIndex:4];
        completionBlock();
    };
    [[[offsetManagerMock expect] andDo:doBlock] animateToPercentage:0.0f isDragging:NO withCompletion:OCMOCK_ANY];
    [[[offsetManagerMock expect] andDo:doBlock] animateToPercentage:1.0f isDragging:NO withCompletion:OCMOCK_ANY];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManagerMock];
    
    __block SmoochState stateReturned = -1;
    [transition transitionTo:SmoochStateActive withCompletion:^(SmoochState outputState) {
        stateReturned = outputState;
    }];
    
    XCTAssertEqual(SmoochStateActive, stateReturned, "Should call completion block with the correct output state");
    
    [offsetManagerMock verify];
}

-(void)testTransitionToActiveNoBounce
{
    id offsetManagerMock = [OCMockObject mockForClass:[SHKOffsetManager class]];
    [[[offsetManagerMock expect] andReturnValue:@NO] shouldBounce];
    [[[offsetManagerMock stub] andReturnValue:OCMOCK_VALUE(1.0f)] activeStateSnapPercentage];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(void);
        [invocation getArgument: &completionBlock atIndex:4];
        completionBlock();
    };
    [[[offsetManagerMock expect] andDo:doBlock] animateToPercentage:1.0f isDragging:NO withCompletion:OCMOCK_ANY];
    
    SHKTransition* transition = [[SHKTransition alloc] initWithSourceState:0 offsetManager:offsetManagerMock];
    
    __block SmoochState stateReturned = -1;
    [transition transitionTo:SmoochStateActive withCompletion:^(SmoochState outputState) {
        stateReturned = outputState;
    }];
    
    XCTAssertEqual(SmoochStateActive, stateReturned, "Should call completion block with the correct output state");
    
    [offsetManagerMock verify];
}

@end
