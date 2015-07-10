//
//  VTConfigTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/11/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTConfig.h"

@interface VTConfigTest : XCTestCase

@end

@implementation VTConfigTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [VTConfig setCLIENT_KEY:@"client_key"];
    [VTConfig setVT_IsProduction:false];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitVTConfig {
    XCTAssert([[VTConfig CLIENT_KEY] isEqualToString:@"client_key"] && [VTConfig VT_IsProduction] == false);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
