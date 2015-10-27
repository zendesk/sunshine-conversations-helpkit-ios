//
//  SHKHomeViewControllerTests.m
//  Smooch
//
//  Created by Joel Simpson on 2014-05-07.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHKRecommendationsViewController.h"
#import "SHKNavigationViewController.h"
#import "SHKTableCellVendingMachine.h"
#import "SHKHomeViewController.h"
#import "SHKSearchResultsView.h"
#import "SHKSearchController.h"
#import "SHKMessagesButtonView.h"
#import "SHKSearchBarView.h"
#import "SHKSearchResult.h"
#import "SHKStateMachine.h"
#import "SHKDimView.h"
#import "OCMock.h"

@interface SHKHomeViewController(Private)

-(void)endEditing;
-(void)reframeMessagesButton;
-(void)onCancel;
-(void)onClose;
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;

@property SHKDimView* dimView;
@property SHKSearchResultsView* searchResultsView;
@property SHKSearchController* searchController;
@property SHKTableCellVendingMachine* vendingMachine;
@property SHKRecommendationsViewController* recommendationsViewController;

@end

@interface SHKHomeViewControllerTests : XCTestCase

@end

@implementation SHKHomeViewControllerTests

-(void)testEndEditing
{
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[searchBarMock expect] resignFirstResponder];
    
    id recommendationsControllerMock = [OCMockObject mockForClass:[SHKRecommendationsViewController class]];
    [[recommendationsControllerMock expect] resetSwipeViewToStart];
    
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.searchBar = searchBarMock;
    vc.recommendationsViewController = recommendationsControllerMock;
    
    [vc endEditing];
    
    [searchBarMock verify];
    [recommendationsControllerMock verify];
}

-(void)testShowBadUrlError
{
    id searchControllerMock = [OCMockObject mockForClass:[SHKSearchController class]];
    [[searchControllerMock expect] setError:OCMOCK_ANY];
    
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] reloadData];
    
    id searchResultsViewMock = [OCMockObject mockForClass:[SHKSearchResultsView class]];
    [[[searchResultsViewMock expect] andReturn:tableViewMock] tableView];
    [[searchResultsViewMock expect] setHidden:YES];
    [[searchResultsViewMock expect] setHidden:NO];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchControllerMock];
    vc.searchResultsView = searchResultsViewMock;
    
    [vc showBadUrlError];
    
    [searchControllerMock verify];
    [tableViewMock verify];
    [searchResultsViewMock verify];
}

// -----------------------------------------------------------------------------------
// SEARCH BAR TESTS
// -----------------------------------------------------------------------------------

-(void)testTextChangedTriggersSearch
{
    NSString* searchQuery = @"I don't know what to search for";
    
    id searchControllerMock = [OCMockObject mockForClass:[SHKSearchController class]];
    [[searchControllerMock expect] search:searchQuery];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchControllerMock];
    
    [vc searchBar:[UISearchBar new] textDidChange:searchQuery];
    
    [searchControllerMock verify];
}

-(void)testSearchResultsChangedReloadsAndHidesTableViewIfNoQuery
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] reloadData];
    
    id searchResultsViewMock = [OCMockObject mockForClass:[SHKSearchResultsView class]];
    [[[searchResultsViewMock expect] andReturn:tableViewMock] tableView];
    [[searchResultsViewMock expect] setHidden:YES];
    
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[[searchBarMock expect] andReturn:@""] text];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:nil];
    vc.searchResultsView = searchResultsViewMock;
    vc.searchBar = searchBarMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKSearchControllerResultsDidChangeNotification object:nil];
    
    [tableViewMock verify];
    [searchResultsViewMock verify];
    [searchBarMock verify];
}

-(void)testSearchResultsChangedReloadsAndShowsTableViewIfQuery
{
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[tableViewMock expect] reloadData];
    
    id searchResultsViewMock = [OCMockObject mockForClass:[SHKSearchResultsView class]];
    [[[searchResultsViewMock expect] andReturn:tableViewMock] tableView];
    [[searchResultsViewMock expect] setHidden:NO];
    
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[[searchBarMock expect] andReturn:@"Some Query"] text];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:nil];
    vc.searchResultsView = searchResultsViewMock;
    vc.searchBar = searchBarMock;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKSearchControllerResultsDidChangeNotification object:nil];
    
    [tableViewMock verify];
    [searchResultsViewMock verify];
    [searchBarMock verify];
}

-(void)testSearchResultsChangedReframesMessagesButton
{
    id messagesButtonMock = [OCMockObject mockForClass:[SHKMessagesButtonView class]];
    [[messagesButtonMock expect] reframeAnimated:YES];
    
    id navigationControllerMock = [OCMockObject mockForClass:[SHKNavigationViewController class]];
    [[[navigationControllerMock expect] andReturn:messagesButtonMock] messagesButton];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:nil];
    
    id partiallyMockedVc = [OCMockObject partialMockForObject:vc];
    [[[partiallyMockedVc expect] andReturn:navigationControllerMock] navigationController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKSearchControllerResultsDidChangeNotification object:nil];
    
    [messagesButtonMock verify];
    [navigationControllerMock verify];
    [partiallyMockedVc verify];
}

-(void)testDimWhenFocusingSearchBar
{
    id dimViewMock = [OCMockObject mockForClass:[SHKDimView class]];
    [[dimViewMock expect] dim];
    
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.dimView = dimViewMock;
    
    [vc searchBarShouldBeginEditing:nil];
    
    [dimViewMock verify];
}

-(void)testUndimWhenUnfocusSearchBar
{
    id dimViewMock = [OCMockObject mockForClass:[SHKDimView class]];
    [[dimViewMock expect] undim];
    
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.dimView = dimViewMock;
    
    [vc searchBarTextDidEndEditing:[UISearchBar new]];
    
    [dimViewMock verify];
}

- (void)testSearchBarBecomesFirstResponderIfNoRecommendations
{
    id managerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(0)] numberOfRecommendationsInSwipeView];
    
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[[searchBarMock stub] andReturn:@""] text];
    [[searchBarMock expect] becomeFirstResponder];
    
    id managerViewControllerMock = [OCMockObject mockForClass:[SHKRecommendationsViewController class]];
    [[[managerViewControllerMock expect] andReturn:managerMock] recommendationsManager];
    
    SHKHomeViewController* homeViewController = [[SHKHomeViewController alloc] initWithSearchController:nil];
    homeViewController.searchBar = searchBarMock;
    homeViewController.recommendationsViewController = managerViewControllerMock;
    [homeViewController viewDidAppear:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    [managerMock verify];
    [searchBarMock verify];
    [managerViewControllerMock verify];
}

- (void)testSearchBarDoesNotBecomeFirstResponderIfRecommendations
{
    id managerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[managerMock expect] andReturnValue:OCMOCK_VALUE(1)] numberOfRecommendationsInSwipeView];
    
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[searchBarMock reject] becomeFirstResponder];
    
    id managerViewControllerMock = [OCMockObject mockForClass:[SHKRecommendationsViewController class]];
    [[[managerViewControllerMock expect] andReturn:managerMock] recommendationsManager];
    
    SHKHomeViewController* homeViewController = [[SHKHomeViewController alloc] initWithSearchController:nil];
    homeViewController.searchBar = searchBarMock;
    homeViewController.recommendationsViewController = managerViewControllerMock;
    [homeViewController viewDidAppear:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    
    [managerMock verify];
    [searchBarMock verify];
    [managerViewControllerMock verify];
}


- (void)testSearchBarFirstResponderReentry
{
    id managerMock = [OCMockObject mockForClass:[SHKRecommendationsManager class]];
    [[[managerMock stub] andReturnValue:OCMOCK_VALUE(0)] numberOfRecommendationsInSwipeView];
    
    id managerViewControllerMock = [OCMockObject mockForClass:[SHKRecommendationsViewController class]];
    [[[managerViewControllerMock stub] andReturn:managerMock] recommendationsManager];

    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[[searchBarMock stub] andReturn:@""] text];
    [[searchBarMock expect] becomeFirstResponder];
    
    SHKHomeViewController* homeViewController = [[SHKHomeViewController alloc] initWithSearchController:nil];
    homeViewController.searchBar = searchBarMock;
    homeViewController.recommendationsViewController = managerViewControllerMock;
    [homeViewController viewDidAppear:YES];

    // Simulate two gesture bounces
    // If the user triggers the gesture again after SHK has opened, the search bar should still have only be focused only once
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    [searchBarMock verify];
   
    // Simluate exiting SHK
    [[searchBarMock expect] resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterInactiveStateNotification object:nil];
    [searchBarMock verify];
   
    // Repeat the gesture bounce and verify that the search bar gets auto-focused once again
    [[searchBarMock expect] becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHKStateMachineDidEnterActiveStateNotification object:nil];
    [searchBarMock verify];
}

// -----------------------------------------------------------------------------------
// TABLE VIEW TESTS
// -----------------------------------------------------------------------------------

-(void)testHeightForRowWithError
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.error = [NSError new];
    
    id vendingMachineMock = [OCMockObject mockForClass:[SHKTableCellVendingMachine class]];
    [[[[vendingMachineMock expect] ignoringNonObjectArgs] andReturnValue:OCMOCK_VALUE(20.0f)] heightForError:searchController.error constrainedToWidth:0];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    vc.vendingMachine = vendingMachineMock;
    
    XCTAssertEqual(20, [vc tableView:[UITableView new] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], "Should return the height given by the vending machine");
    
    [vendingMachineMock verify];
}

-(void)testHeightForRowNoError
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.searchResults = @[ [SHKSearchResult new] ];
    
    id vendingMachineMock = [OCMockObject mockForClass:[SHKTableCellVendingMachine class]];
    [[[[vendingMachineMock expect] ignoringNonObjectArgs] andReturnValue:OCMOCK_VALUE(20.0f)] heightForSearchResult:searchController.searchResults[0] constrainedToWidth:0];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    vc.vendingMachine = vendingMachineMock;
    
    XCTAssertEqual(20, [vc tableView:[UITableView new] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], "Should return the height given by the vending machine");
    
    [vendingMachineMock verify];
}

-(void)testHeightForRowUsesWidthOfResultsView
{
    CGRect frame = CGRectMake(0, 1, 2, 3);
    
    id resultsViewMock = [OCMockObject mockForClass:[SHKSearchResultsView class]];
    [[[resultsViewMock expect] andReturnValue:[NSValue valueWithCGRect:frame]] frame];
    
    id vendingMachineMock = [OCMockObject mockForClass:[SHKTableCellVendingMachine class]];
    [[[vendingMachineMock expect] andReturnValue:OCMOCK_VALUE(0.0f)] heightForSearchResult:OCMOCK_ANY constrainedToWidth:frame.size.width];
    
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.searchResultsView = resultsViewMock;
    vc.vendingMachine = vendingMachineMock;
    
    [vc tableView:[UITableView new] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [resultsViewMock verify];
    [vendingMachineMock verify];
}

-(void)testCellForRowWithError
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.error = [NSError new];
    UITableViewCell* returnedCell = [UITableViewCell new];
    
    id vendingMachineMock = [OCMockObject mockForClass:[SHKTableCellVendingMachine class]];
    [[[[vendingMachineMock expect] ignoringNonObjectArgs] andReturn:returnedCell] cellForError:searchController.error dequeueFrom:OCMOCK_ANY];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    vc.vendingMachine = vendingMachineMock;
    
    XCTAssertEqual(returnedCell, [vc tableView:[UITableView new] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], "Should return the cell given by the vending machine");
    
    [vendingMachineMock verify];
}

-(void)testCellForRowNoError
{
    UITableViewCell* returnedCell = [UITableViewCell new];
    
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.searchResults = @[ [SHKSearchResult new] ];
    
    id vendingMachineMock = [OCMockObject mockForClass:[SHKTableCellVendingMachine class]];
    [[[[vendingMachineMock expect] ignoringNonObjectArgs] andReturn:returnedCell] cellForSearchResult:OCMOCK_ANY dequeueFrom:OCMOCK_ANY];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    vc.vendingMachine = vendingMachineMock;
    
    XCTAssertEqual(returnedCell, [vc tableView:[UITableView new] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], "Should return the cell given by the vending machine");
    
    [vendingMachineMock verify];
}

-(void)testHideKeyboardWhenScrolling
{
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[[searchBarMock stub] andReturn:@""] text];
    [[searchBarMock expect] resignFirstResponder];
    
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.searchBar = searchBarMock;
    
    [vc scrollViewWillBeginDragging:[UITableView new]];
    
    [searchBarMock verify];
}

-(void)testNumberOfRowsInSectionWithError
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.error = [NSError new];
    searchController.searchResults = @[];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    
    XCTAssertEqual(1, [vc tableView:[UITableView new] numberOfRowsInSection:0], "Should return 1 cell if there is an error");
}

-(void)testNumberOfRowsInSectionWithResults
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.searchResults = @[ [SHKSearchResult new], [SHKSearchResult new] ];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    
    XCTAssertEqual(searchController.searchResults.count, [vc tableView:[UITableView new] numberOfRowsInSection:0], "Should return the number of search results");
}

-(void)testNumberOfRowsInSectionNoResults
{
    SHKSearchController* searchController = [[SHKSearchController alloc] init];
    searchController.searchResults = @[];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchController];
    
    XCTAssertEqual(1, [vc tableView:[UITableView new] numberOfRowsInSection:0], "Should return 1 cell if there are no results");
}

-(void)testTappingCancelHidesKeyBoard
{
    id searchBarMock = [OCMockObject mockForClass:[SHKSearchBarView class]];
    [[searchBarMock expect] resignFirstResponder];
    [[[searchBarMock stub] andReturnValue:@NO] isFirstResponder];

    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.searchBar = searchBarMock;
    
    [vc onCancel];

    [searchBarMock verify];
}

-(void)testTappingCancelHidesSearchResultsView
{
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.navigationItem.leftBarButtonItem = nil;
    vc.searchResultsView = [SHKSearchResultsView new];
    vc.searchResultsView.hidden = NO;
    [vc onCancel];
    
    XCTAssertTrue(vc.searchResultsView.hidden == YES, @"Tapping Cancel should hide the searchResultsView");
}

-(void)testSearchBarFocusAssignsRightBarButton
{
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.navigationItem.rightBarButtonItem = nil;
    [vc searchBarTextDidBeginEditing:[UISearchBar new]];
    
    XCTAssertNotNil(vc.navigationItem.rightBarButtonItem, @"Focussing the search bar should assign the rightBarButton navigationItem");
}

-(void)testSearchBarFocusRemovesLeftBarButton
{
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TestButton" style:UIBarButtonItemStylePlain target:nil action:nil];
    [vc searchBarTextDidBeginEditing:[UISearchBar new]];
    
    XCTAssertFalse(vc.navigationItem.leftBarButtonItem, @"Focussing the search bar should remove the leftBarButton navigationItem");
}

-(void)testCancelButtonCancelsRequest
{
    id searchControllerMock = [OCMockObject mockForClass:[SHKSearchController class]];
    [[searchControllerMock expect] cancelCurrentRequest];
    
    SHKHomeViewController* vc = [[SHKHomeViewController alloc] initWithSearchController:searchControllerMock];
    
    [vc onCancel];
    
    [searchControllerMock verify];
}

-(void)testCancelTogglesNavigationItems
{
    SHKHomeViewController* vc = [SHKHomeViewController new];
    vc.navigationItem.rightBarButtonItem = [UIBarButtonItem new];
    vc.navigationItem.leftBarButtonItem = nil;
    vc.searchResultsView = [SHKSearchResultsView new];
    
    [vc onCancel];
    
    XCTAssertNotNil(vc.navigationItem.leftBarButtonItem, @"Cancel should show the close button");
    XCTAssertNil(vc.navigationItem.rightBarButtonItem, @"Cancel should hide the cancel button");
}

@end
