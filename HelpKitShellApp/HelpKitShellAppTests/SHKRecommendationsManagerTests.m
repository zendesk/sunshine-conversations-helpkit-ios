//
//  SHKRecommendationsManagerTests.m
//  Smooch
//
//  Created by Michael Spensieri on 4/11/14.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKRecommendationsManager.h"
#import "SHKNavigationViewController.h"
#import "OCMock.h"
#import "SHKRecommendations.h"
#import "SHKImageLoader.h"

@interface SHKRecommendationsManager(Private)

@property SHKRecommendations* recommendations;

@end

@interface SHKRecommendationsManagerTests : XCTestCase

@end

@implementation SHKRecommendationsManagerTests

-(void)testInitWithImageLoader
{
    SHKImageLoader* imageLoader = [SHKImageLoader new];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoader navigationController:nil andRecommendations:nil];
    
    XCTAssertEqual(ram.imageLoader, imageLoader, "Should maintain the image loader");
}

-(void)testInitWithRecommendations
{
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:nil andRecommendations:recommendationsMock];
    
    XCTAssertEqual(recommendationsMock, ram.recommendations, "Should be the same");
    
    [recommendationsMock verify];
}

-(void)testNumberOfItemsEqualToNumberOfRecommendationsPlusBuffer
{
    int bufferCount = 3;
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:nil andRecommendations:recommendationsMock];
    
    [[[recommendationsMock expect] andReturn:nil] recommendationsList];
    XCTAssertEqual(0 + bufferCount, [ram numberOfItemsInSwipeView:nil], "Should be the same");
    
    [[[recommendationsMock expect] andReturn:@[ @"someURL" ]] recommendationsList];
    XCTAssertEqual(1 + bufferCount, [ram numberOfItemsInSwipeView:nil], "Should be the same");
    
    [[[recommendationsMock expect] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    XCTAssertEqual(2 + bufferCount, [ram numberOfItemsInSwipeView:nil], "Should be the same");
    
    [recommendationsMock verify];
}

-(void)testNewViewIsCreated
{
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:nil andRecommendations:nil];
    
    XCTAssertNotNil([ram swipeView:nil viewForItemAtIndex:0 reusingView:nil]);

    UIView* viewNotToReuse = [UIView new];
    XCTAssertNotEqual(viewNotToReuse, [ram swipeView:nil viewForItemAtIndex:0 reusingView:viewNotToReuse]);
}

// First two views, and the last view should not have images
-(void)testEmptyBlocksDoNotHaveImageViews
{
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:nil andRecommendations:recommendationsMock];
    
    UIView* returnedView = [ram swipeView:nil viewForItemAtIndex:0 reusingView:nil];
    
    XCTAssertEqual(0, returnedView.subviews.count, "First index should be blank");
    
    returnedView = [ram swipeView:nil viewForItemAtIndex:1 reusingView:nil];
    
    XCTAssertEqual(0, returnedView.subviews.count, "Second index should be blank");
    
    returnedView = [ram swipeView:nil viewForItemAtIndex:3 reusingView:nil];
    
    XCTAssertEqual(0, returnedView.subviews.count, "Third index should be blank");
    
    [recommendationsMock verify];
}

-(void)testDoesNotTakeScreenshotsIfNotEnabled
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];

    ram.shouldTakeScreenshots = NO;
    
    [[imageLoaderMock reject] loadImageForUrl:@"someURL" withCompletion:OCMOCK_ANY];
    [ram swipeView:nil viewForItemAtIndex:2 reusingView:nil];
    [imageLoaderMock verify];
    
    [[imageLoaderMock reject] loadImageForUrl:@"someOtherURL" withCompletion:OCMOCK_ANY];
    [ram swipeView:nil viewForItemAtIndex:3 reusingView:nil];
    [imageLoaderMock verify];
    
    [recommendationsMock verify];
}

-(void)testTakeScreenshotIfScreenshotsEnabled
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];
    ram.shouldTakeScreenshots = YES;
    
    [[imageLoaderMock expect] loadImageForUrl:@"someURL" withCompletion:OCMOCK_ANY];
    [ram swipeView:nil viewForItemAtIndex:2 reusingView:nil];
    [imageLoaderMock verify];
    
    [[imageLoaderMock expect] loadImageForUrl:@"someOtherURL" withCompletion:OCMOCK_ANY];
    [ram swipeView:nil viewForItemAtIndex:3 reusingView:nil];
    [imageLoaderMock verify];
    
    [recommendationsMock verify];
}

-(void)testFetchedImageIsUsed
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];
    ram.shouldTakeScreenshots = YES;
    
    UIImage* fetchedImage = [UIImage new];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(UIImage* image);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(fetchedImage);
    };
    [[[imageLoaderMock expect] andDo:doBlock] loadImageForUrl:@"someURL" withCompletion:OCMOCK_ANY];
    
    UIView* createdView = [ram swipeView:nil viewForItemAtIndex:2 reusingView:nil];
    UIImageView* imageView = createdView.subviews[0];

    [imageLoaderMock verify];
    
    XCTAssertEqual(fetchedImage, imageView.image, "Fetched image should be used");
    
    [recommendationsMock verify];
}

-(void)testSwipeViewAnimatesWhenFirstImageFinishedLoading
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];
    ram.shouldTakeScreenshots = YES;
    
    UIImage* fetchedImage = [UIImage new];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(UIImage* image);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(fetchedImage);
    };
    [[[imageLoaderMock expect] andDo:doBlock] loadImageForUrl:@"someURL" withCompletion:OCMOCK_ANY];
    
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(0)] currentItemIndex];
    [[[swipeViewMock expect] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[swipeViewMock expect] setScrollEnabled:YES];
    
    [ram swipeView:swipeViewMock viewForItemAtIndex:2 reusingView:nil];
    
    [imageLoaderMock verify];
    [swipeViewMock verify];
    
    [recommendationsMock verify];
}

-(void)testSwipeDoesNotAnimateIfNotOnFirstIndex
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];
    ram.shouldTakeScreenshots = YES;
    
    UIImage* fetchedImage = [UIImage new];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(UIImage* image);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(fetchedImage);
    };
    [[[imageLoaderMock expect] andDo:doBlock] loadImageForUrl:@"someURL" withCompletion:OCMOCK_ANY];
    
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[[swipeViewMock reject] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[swipeViewMock expect] setScrollEnabled:YES];
    
    [ram swipeView:swipeViewMock viewForItemAtIndex:2 reusingView:nil];
    
    [imageLoaderMock verify];
    [swipeViewMock verify];
    [recommendationsMock verify];
}

-(void)testSwipeViewDoesNotAnimateForSubsequentImages
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:imageLoaderMock navigationController:nil andRecommendations:recommendationsMock];
    ram.shouldTakeScreenshots = YES;
    
    UIImage* fetchedImage = [UIImage new];
    
    void (^doBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^completionBlock)(UIImage* image);
        [invocation getArgument: &completionBlock atIndex: 3];
        completionBlock(fetchedImage);
    };
    [[[imageLoaderMock expect] andDo:doBlock] loadImageForUrl:@"someOtherURL" withCompletion:OCMOCK_ANY];
    
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    [[[swipeViewMock reject] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[swipeViewMock expect] setScrollEnabled:YES];
    
    [ram swipeView:swipeViewMock viewForItemAtIndex:3 reusingView:nil];
    
    [imageLoaderMock verify];
    [swipeViewMock verify];
    [recommendationsMock verify];
}

-(void)testTappingOuterCellsDoesNothing
{
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:navigationControllerMock andRecommendations:recommendationsMock];
    
    [ram swipeView:swipeViewMock didSelectItemAtIndex:0];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:4];
    
    // Expect nothing
    [swipeViewMock verify];
    [navigationControllerMock verify];
    [recommendationsMock verify];
}

-(void)testTappingSideCellScrollsIfScrollEnabled
{
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:navigationControllerMock andRecommendations:recommendationsMock];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[[swipeViewMock expect] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[[swipeViewMock expect] andReturnValue:@YES] isScrollEnabled];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:1];
    [swipeViewMock verify];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[[swipeViewMock expect] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[[swipeViewMock expect] andReturnValue:@YES] isScrollEnabled];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:3];
    [swipeViewMock verify];
    
    // Expect nothing
    [navigationControllerMock verify];
    [recommendationsMock verify];
}

-(void)testTappingSideCellDoesNotScrollsIfScrollDisabled
{
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:navigationControllerMock andRecommendations:recommendationsMock];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[[swipeViewMock reject] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[[swipeViewMock expect] andReturnValue:@NO] isScrollEnabled];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:1];
    [swipeViewMock verify];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[[swipeViewMock reject] ignoringNonObjectArgs] scrollToItemAtIndex:0 duration:0];
    [[[swipeViewMock expect] andReturnValue:@NO] isScrollEnabled];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:3];
    [swipeViewMock verify];
    
    // Expect nothing
    [navigationControllerMock verify];
    [recommendationsMock verify];
}

-(void)testTappingMiddleCellShowsRecommendation
{
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:navigationControllerMock andRecommendations:recommendationsMock];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(1)] currentItemIndex];
    [[navigationControllerMock expect] showArticle:@"someURL"];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:2];
    [navigationControllerMock verify];
    [swipeViewMock verify];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(2)] currentItemIndex];
    [[navigationControllerMock expect] showArticle:@"someOtherURL"];
    [ram swipeView:swipeViewMock didSelectItemAtIndex:3];
    [navigationControllerMock verify];
    [swipeViewMock verify];
    
    [recommendationsMock verify];
}

-(void)testTappingAppCellInMiddleClosesSmooch
{
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    id swipeViewMock = [OCMockObject mockForClass:[SHKSwipeView class]];
    
    id recommendationsMock = [OCMockObject mockForClass:[SHKRecommendations class]];
    [[[recommendationsMock stub] andReturn:@[ @"someURL", @"someOtherURL" ]] recommendationsList];
    
    SHKRecommendationsManager* ram = [[SHKRecommendationsManager alloc] initWithImageLoader:nil navigationController:navigationControllerMock andRecommendations:recommendationsMock];
    
    [[[swipeViewMock expect] andReturnValue:OCMOCK_VALUE(0)] currentItemIndex];
    
    // TODO : Verify state machine is called
    
    [ram swipeView:swipeViewMock didSelectItemAtIndex:1];
    
    [navigationControllerMock verify];
    [swipeViewMock verify];
    
    [recommendationsMock verify];
}

-(void)testClearImageCache
{
    id imageLoaderMock = [OCMockObject mockForClass:[SHKImageLoader class]];
    [[imageLoaderMock expect] clearImageCache];
    
    SHKRecommendationsManager* ram = [SHKRecommendationsManager new];
    ram.imageLoader = imageLoaderMock;
    
    [ram clearImageCache];
    
    [imageLoaderMock verify];
}

@end
