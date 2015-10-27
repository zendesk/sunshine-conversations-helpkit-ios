//
//  SHKTableCellVendingMachineTests.m
//  Smooch
//
//  Created by Mike on 2014-05-07.
//  Copyright (c) 2015 Smooch Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SHKTableCellVendingMachine.h"
#import "OCMock.h"
#import "SHKSearchResult.h"

@interface SHKTableCellVendingMachineTests : XCTestCase

@end

@implementation SHKTableCellVendingMachineTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testResultCellsAreRecycled
{
    UITableViewCell* cell = [UITableViewCell new];
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[[tableViewMock expect] andReturn:cell] dequeueReusableCellWithIdentifier:OCMOCK_ANY];
    
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertEqual(cell, [vendingMachine cellForSearchResult:nil dequeueFrom:tableViewMock], "Cell should be dequeued from the tableView");
    
    [tableViewMock verify];
}

-(void)testResultCellsAreCreatedIfNoneToRecycle
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertNotNil([vendingMachine cellForSearchResult:nil dequeueFrom:nil], "Cell should be created if none can be dequeued");
}

-(void)testResultCellsCanBeTapped
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertTrue([vendingMachine cellForSearchResult:[SHKSearchResult new] dequeueFrom:nil].userInteractionEnabled, "UserInteractionEnabled should be true");
}

-(void)testNoResultsCellCannotBeTapped
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertFalse([vendingMachine cellForSearchResult:nil dequeueFrom:nil].userInteractionEnabled, "UserInteractionEnabled should be false");
}

-(void)testResultCellUsesTitle
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    SHKSearchResult* searchResult = [[SHKSearchResult alloc] initWithTitle:@"Some title" url:nil];
    UITableViewCell* createdCell = [vendingMachine cellForSearchResult:searchResult dequeueFrom:nil];
    
    XCTAssertTrue([createdCell.textLabel.text isEqualToString:searchResult.title], "Cell should take the title from the search result");
}

-(void)testErrorCellsAreRecycled
{
    UITableViewCell* cell = [UITableViewCell new];
    
    id tableViewMock = [OCMockObject mockForClass:[UITableView class]];
    [[[tableViewMock expect] andReturn:cell] dequeueReusableCellWithIdentifier:OCMOCK_ANY];
    
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertEqual(cell, [vendingMachine cellForError:nil dequeueFrom:tableViewMock], "Cell should be dequeued from the tableView");
    
    [tableViewMock verify];
}

-(void)testErrorCellsAreCreatedIfNoneToRecycle
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertNotNil([vendingMachine cellForError:nil dequeueFrom:nil], "Cell should be created if none can be dequeued");
}

-(void)testErrorCellsCannotBeTapped
{
    SHKTableCellVendingMachine* vendingMachine = [SHKTableCellVendingMachine new];
    
    XCTAssertFalse([vendingMachine cellForError:nil dequeueFrom:nil].userInteractionEnabled, "UserInteractionEnabled should be false");
}

@end
