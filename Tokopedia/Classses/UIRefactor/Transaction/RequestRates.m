//
//  RequestRates.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestRates.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "ShipmentAvailable.h"

@implementation RequestRates

+(void)fetchRateWithName:(NSString *)name origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight token:(NSString*)token ut:(NSString*)ut shipmentAvailable:(NSArray*)shipmentAvailable isShowOKE:(NSString*)isShowOKE onSuccess:(void(^)(RateData* rateData))success onFailure:(void(^)(NSError* errorResult)) error{
    
    [TPAnalytics trackUserId];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    //TODO::BASE & POST URL
    NSString *baseuUrl = @"https://kero.tokopedia.com";//[_gtmContainer stringForKey:@"base_url"]?:@"https://clover.tokopedia.com";
    NSString *pathUrl = @"/rates/v1";//[_gtmContainer stringForKey:@"post_url"]?:@"notify/v1";
    
    NSDictionary *param = @{
                            @"names"         :name?:@"",
                            @"origin"        :origin?:@"",
                            @"destination"   :destination?:@"",
                            @"weight"        :weight,
                            @"ut"            :ut,
                            @"token"         :token
                           };
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingDefaultError = NO;
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:baseuUrl
                                  path:pathUrl
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[RateResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *resultDict = successResult.dictionary;
                                 id stat = [resultDict objectForKey:@""];
                                 
                                 RateResponse *response= stat;
                                 NSArray *shipments = [ShipmentAvailable compareShipmentsWS:shipmentAvailable withShipmentsKero:response.data.attributes];
                                 shipments = [ShipmentAvailable shipments:shipments showOKE:isShowOKE];
                                 response.data.attributes = shipments;
                                 success(response.data);
                                 
                             } onFailure:^(NSError *errorResult) {
                                 [StickyAlertView showNetworkError:errorResult];
                                 error(errorResult);
                             }];
}

@end
