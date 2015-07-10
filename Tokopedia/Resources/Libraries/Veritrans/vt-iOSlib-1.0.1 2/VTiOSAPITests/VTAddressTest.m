//
//  VTAddressTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/11/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VTAddress.h"

@interface VTAddressTest : XCTestCase

@end

@implementation VTAddressTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddress {
    // This is an example of a functional test case.
    VTAddress* address = [[VTAddress alloc] init];
    address.first_name = @"anis";    
    XCTAssert([address.first_name isEqualToString:@"anis"], @"Pass");
}


@end
