//
//  _KODETests.m
//  4KODETests
//
//  Created by Ruslan on 7/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CollageComposer.h"

@interface CollageComposerTests : XCTestCase

@end

@implementation CollageComposerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThat20ProperlyHandle {
    NSMutableArray *array = [NSMutableArray new];
    for (int i =0; i < 20; i++) {
        [array addObject:@"2"];
    }
    CGSize actual = [CollageComposer getSizeForCollage:array];
    NSAssert(actual.width == 4, @"Result should be 4");
    NSAssert(actual.height == 5, @"Result should be 5");
}

- (void)testThat1ProperlyHandle {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:@"2"];
    CGSize actual = [CollageComposer getSizeForCollage:array];
    NSAssert(actual.width == 1, @"width should be 1");
    NSAssert(actual.height == 1, @"height should be 0");
}

- (void)testThat2ProperlyHandle {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:@"2"];
    [array addObject:@"2"];
    CGSize actual = [CollageComposer getSizeForCollage:array];
    NSAssert(actual.width == 2, @"width should be 1");
    NSAssert(actual.height == 1, @"height should be 1");
}


- (void)testThat1ProperlyDividedOnSimpleValues {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:@"2"];
    NSArray *actual = [CollageComposer getSimpleValuesForImagesCount:array];
    NSAssert(actual.count == 1, @"Actual count should be 1");
    NSAssert(((NSNumber*)actual.firstObject).integerValue == 1, @"Result should be 1");
}

- (void)testThat73ProperlyDividedOnSimpleValues {
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < 73; i++) {
        [array addObject:@"2"];
    }
    NSArray *actual = [CollageComposer getSimpleValuesForImagesCount:array];
    NSAssert(actual.count == 5, @"Actual count should be 5");
    NSAssert(((NSNumber*)actual.firstObject).integerValue == 2, @"Result should be 2");
    NSAssert(((NSNumber*)actual[1]).integerValue == 2, @"Result should be 2");
    NSAssert(((NSNumber*)actual[2]).integerValue == 2, @"Result should be 2");
    NSAssert(((NSNumber*)actual[3]).integerValue == 3, @"Result should be 3");
    NSAssert(((NSNumber*)actual[4]).integerValue == 3, @"Result should be 3");
}


@end
