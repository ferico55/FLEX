//
//  RequestRates.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestRates.h"

@implementation RequestRates {
    TAGContainer *_gtmContainer;
    UserAuthentificationManager *_userManager;
    
    TokopediaNetworkManager *_networkManager;
    
    NSString *_baseuUrl;
    NSString *_postUrl;
    
    NSDictionary *_param;
    
    RateData *_data;

}

-(void)doRequestWithNames:(NSArray *)names origin:(NSString*)origin destination:(NSString *)destination weight:(NSString*)weight {
    [self configureGTM];
    
    NSString *name = [[names valueForKey:@"description"] componentsJoinedByString:@","];
    
    _param = @{@"names"         :name?:@"",
               @"origin"        : origin?:@"",
               @"destination"   :@"",
               @"weight"        :@""
               };
    
    [[self networkManager] doRequest];
}

-(TokopediaNetworkManager *)networkManager {
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager.isParameterNotEncrypted = YES;
        _networkManager.isUsingHmac = YES;
    }
    return _networkManager;
}

#pragma mark - Network Manager
-(NSDictionary *)getParameter:(int)tag {
    return _param;
}

-(id)getObjectManager:(int)tag {
    return [self objectManagerNotify];
}

-(RKObjectManager*)objectManagerNotify {
    RKObjectManager *objectManager = [RKObjectManager sharedClient:_baseuUrl];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RateResponse mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(int)didReceiveRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

-(NSString *)getPath:(int)tag {
    return _postUrl;
}

-(NSString *)getRequestStatus:(RKMappingResult*)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];

    RateResponse *response= stat;
    _data = response.data;
    
    if (response.errors.count==0) {
        return @"OK";
    } else return ((ResponseError*)response.errors[0]).title;
}

-(void)actionBeforeRequest:(int)tag {
    
}

-(void)actionAfterRequest:(RKMappingResult*)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *resultDict = successResult.dictionary;
    id stat = [resultDict objectForKey:@""];
    
    RateResponse *response= stat;
    
    if ([_delegate respondsToSelector:@selector(successRequestRates:)]) {
        [_delegate successRequestRates:response.data];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag {

}

-(int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

#pragma mark - GTM
- (void)configureGTM {
    _userManager = [UserAuthentificationManager new];

    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    //TODO::BASE & POST URL
    _baseuUrl = @"http://private-8f030-kero.apiary-mock.com";//[_gtmContainer stringForKey:@"base_url"]?:@"https://clover.tokopedia.com";
    _postUrl = @"rates/v1";//[_gtmContainer stringForKey:@"post_url"]?:@"notify/v1";
}

@end
