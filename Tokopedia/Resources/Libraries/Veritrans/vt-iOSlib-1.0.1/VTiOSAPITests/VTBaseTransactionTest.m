//
//  VTBaseTransactionTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/11/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTBaseTransaction.h"

@interface VTBaseTransactionTest : XCTestCase

@end

@implementation VTBaseTransactionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    // This is an example of a functional test case.
    VTBaseTransaction* base = [[VTBaseTransaction alloc] init];
    XCTAssert(base.item_details != nil);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
