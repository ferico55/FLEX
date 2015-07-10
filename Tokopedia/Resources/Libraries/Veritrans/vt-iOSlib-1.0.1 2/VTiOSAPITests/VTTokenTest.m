//
//  VTTokenTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/12/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTConfig.h"
#import "VTDirect.h"

@interface VTTokenTest : XCTestCase

@end

@implementation VTTokenTest

- (void)setUp {
    [VTConfig setCLIENT_KEY:@"VT-client-3YUXFj6X0XBpeDgf"];
    [VTConfig setVT_IsProduction:false];
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetTokenSecure {
    VTDirect* vtDirect = [[VTDirect alloc] init];
    
    VTCardDetails* cardDetails = [[VTCardDetails alloc] init];
    cardDetails.card_number = @"4811111111111114";
    cardDetails.card_cvv = @"123";
    cardDetails.card_exp_month = 1;
    cardDetails.card_exp_year = 2020;
    cardDetails.gross_amount = @"10000";

    vtDirect.card_details = cardDetails;
    
    __block BOOL waitingForBlock = YES;
    
    [vtDirect getToken:^(VTToken *token, NSException *exception) {
        waitingForBlock = NO;
        XCTAssertNotNil(token);
        if(exception == nil){
            NSLog(@"Token id: %@",token.token_id);
            NSLog(@"Token redirect url: %@",token.redirect_url);
            XCTAssertNotNil(token);
        }else{
            NSLog(@"Reason: %@",exception.reason);
        }
    }];
    while (waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
