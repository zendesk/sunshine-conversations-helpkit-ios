//
//  SHKOffsetManagerTests.m
//  Smooch
//
//  Created by Mike on 2014-05-21.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKOffsetManager.h"

@interface SHKOffsetManagerTests : XCTestCase

@property BOOL notificationReceived;
@property id notificationObject;

@end

@implementation SHKOffsetManagerTests

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
-(void)testShouldBounce
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    offsetManager.activeStateSnapPercentage = 1.0;
    offsetManager.offsetPercentage = 0.0;
    
    XCTAssertTrue([offsetManager shouldBounce], "Should bounce if offset is lower than snap percentage");
}

-(void)testShouldNotBounce
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    offsetManager.activeStateSnapPercentage = 0.0;
    offsetManager.offsetPercentage = 1.0;
    
    XCTAssertFalse([offsetManager shouldBounce], "Should not bounce if offset is higher than snap percentage");
}

-(void)testBouncePercentage
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    offsetManager.activeStateSnapPercentage = 1.0;
    
    XCTAssertTrue(offsetManager.bouncePercentage > offsetManager.activeStateSnapPercentage, "Bounce should be higher than snap percentage");
}

-(void)testAnimateToPercentageNotifies
{
    SHKOffsetManager* offsetManager = [SHKOffsetManager new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotif:) name:SHKOffsetManagerDidChangePercentageNotification object:nil];
    
    [offsetManager animateToPercentage:0 isDragging:NO withCompletion:nil];
    
    XCTAssertTrue(self.notificationReceived, "Should notify on addOffset");
    XCTAssertEqual(self.notificationObject, offsetManager, "Notification object should be the notifying transition");
}

-(void)onNotif:(NSNotification*)notification
{
    self.notificationReceived = YES;
    self.notificationObject = notification.object;
}

@end
