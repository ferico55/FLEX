//
//  VTCardDetailsTest.m
//  VTiOSAPI
//
//  Created by Muhammad Anis on 12/11/14.
//  Copyright (c) 2014 Veritrans Indonesia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTConfig.h"
#import "VTCardDetails.h"

@interface VTCardDetailsTest : XCTestCase

@end

@implementation VTCardDetailsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    VTConfig.CLIENT_KEY = @"VT-client-3YUXFj6X0XBpeDgf";
    VTConfig.VT_IsProduction = false;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testGenerateBankParam {
    VTCardDetails* cardDetails = [[VTCardDetails alloc]init];
    NSLog(@"Bank Param %@",[cardDetails getBankParam]);
    XCTAssert([[cardDetails getBankParam] isEqualToString:@""]);
    //set card bank
    cardDetails.bank = @"bni";
    XCTAssert([[cardDetails getBankParam] isEqualToString:@"&bank=bni"]);
    
}

- (void)testGeneratejsonSecure {
    VTCardDetails* cardDetails = [[VTCardDetails alloc] init];
    cardDetails.card_number = @"4811111111111114";
    cardDetails.card_cvv = @"123";
    cardDetails.card_exp_month = 1;
    cardDetails.card_exp_year = 2020;
    cardDetails.gross_amount = @"10000";
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[VTConfig getTokenUrl],[cardDetails getParamUrl]];
    
    NSString* testUrl = [NSString stringWithFormat:@"%@%@",[VTConfig getTokenUrl],[NSString stringWithFormat:@"?card_number=4811111111111114&card_exp_month=1&card_exp_year=2020&card_cvv=123&client_key=%@&secure=false&gross_amount=10000",[VTConfig CLIENT_KEY]]];
    NSLog(@"url: %@",url);
    NSLog(@"testUrl: %@",testUrl);
    XCTAssert([url isEqualToString:testUrl]);
    
    //test url with bank
    cardDetails.bank = @"bni";
    NSString* urlWithBank = [NSString stringWithFormat:@"%@%@",[VTConfig getTokenUrl],[cardDetails getParamUrl]];
    NSString* testUrlWithBank = [NSString stringWithFormat:@"%@%@",[VTConfig getTokenUrl],[NSString stringWithFormat:@"?card_number=4811111111111114&card_exp_month=1&card_exp_year=2020&card_cvv=123&client_key=%@&secure=false&bank=bni&gross_amount=10000",[VTConfig CLIENT_KEY]]];
    NSLog(@"URL With Bank: %@",[cardDetails getBankParam]);
    XCTAssert([urlWithBank isEqualToString:testUrlWithBank]);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
