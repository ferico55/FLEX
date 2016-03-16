//
//  RequestRates.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestRates.h"
#import "TkpdHMAC.h"
#import "StickyAlertView+NetworkErrorHandler.h"

@implementation RequestRates

+(void)doRequestWithNames:(NSArray *)names origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight onSuccess:(void(^)(RateData* rateData))success onFailure:(void(^)(NSError* errorResult)) error{
    
    [TPAnalytics trackUserId];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    //TODO::BASE & POST URL
    NSString *baseuUrl = @"https://kero-staging.tokopedia.com";//[_gtmContainer stringForKey:@"base_url"]?:@"https://clover.tokopedia.com";
    NSString *pathUrl = @"rates/v1";//[_gtmContainer stringForKey:@"post_url"]?:@"notify/v1";
    
    NSString *name = [[names valueForKey:@"description"] componentsJoinedByString:@","];
    
    NSString *unixTime = [NSString stringWithFormat:@"%zd",[[NSDate date] timeIntervalSince1970]];
    
    TkpdHMAC *hmac = [TkpdHMAC new];
    NSString *token = [NSString stringWithFormat:@"Tokopedia+Kero:%@",[hmac generateTokenRatesPath:pathUrl withUnixTime:unixTime]];
    
    NSDictionary *param = @{
                            @"names"         :name?:@"",
                            @"origin"        :origin?:@"",
                            @"destination"   :destination?:@"",
                            @"weight"        :@"1kg",
                            @"ut"            :unixTime,
                            @"token"         :token
                           };
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingDefaultError = NO;
    
    [networkManager requestWithBaseUrl:baseuUrl path:pathUrl method:RKRequestMethodGET parameter:param mapping:[RateResponse mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *resultDict = successResult.dictionary;
        id stat = [resultDict objectForKey:@""];
        
        RateResponse *response= stat;
        success(response.data);
    } onFailure:^(NSError *errorResult) {
        [StickyAlertView showNetworkError:errorResult];
    }];
}

@end
