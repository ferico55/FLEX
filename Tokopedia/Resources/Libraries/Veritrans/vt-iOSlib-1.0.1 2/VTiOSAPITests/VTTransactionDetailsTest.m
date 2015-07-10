//
//  VTTransactionDetailsTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/11/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTTransactionDetails.h"

@interface VTTransactionDetailsTest : XCTestCase

@end

@implementation VTTransactionDetailsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit{
    // This is an example of a functional test case.
    VTTransactionDetails* transaction = [VTTransactionDetails transactionWithOrderAndGross:@"9009" withGrossAmount:2000];
    NSLog(@"Order id: %@, gross: %ld",transaction.order_id,transaction.gross_amount);
    XCTAssert([transaction.order_id isEqualToString:@"9009"] && transaction.gross_amount == 2000);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
