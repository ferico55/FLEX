//
//  RequestNotifyLBLM.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestNotifyLBLM.h"

#import "TAGDataLayer.h"
#import "NotifyLBLM.h"

#import "Localytics.h"

@implementation RequestNotifyLBLM
{
    TAGContainer *_gtmContainer;
    UserAuthentificationManager *_userManager;
    
    TokopediaNetworkManager *_networkManager;
    
    NSString *_lplmBaseuUrl;
    NSString *_lplmPostUrl;
    NSString *_detailProductPostUrl;
    NSString *_detailProductFullUrl;
    
    NotifyData *_notifyData;
}

-(void)doRequestLBLM
{
    [self configureGTM];
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.isParameterNotEncrypted = YES;
    [_networkManager doRequest];
}

-(TokopediaNetworkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager.isParameterNotEncrypted = YES;
    }
    return _networkManager;
}

#pragma mark - Network Manager
-(NSDictionary *)getParameter:(int)tag
{
    return @{@"user_id":[_userManager getUserId]?:@"",
             @"shop_id":[_userManager getShopId]?:@""};
}

-(id)getObjectManager:(int)tag
{
    return [self objectManagerNotify];
}

-(RKObjectManager*)objectManagerNotify
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient:_lplmBaseuUrl?:@"http://clover-staging.tokopedia.com"];
    
//    RKRoute *route = [RKRoute routeWithClass:[NotifyLBLM class]
//                                 pathPattern:@""
//                                      method:RKRequestMethodGET];
    
//    RKRoute *route = [RKRoute routeWithName:@"route name" pathPattern:@"" method:RKRequestMethodGET];
//    [objectManager.router.routeSet addRoutes:@[route]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[NotifyLBLM mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(NSString *)getPath:(int)tag
{
    return _lplmPostUrl;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];

    NotifyLBLM *notify= stat;
    _notifyData = notify.data;
    
    return notify.status;
}

-(void)actionBeforeRequest:(int)tag
{
    
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    [self addLocalyticsProfile];
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
//    NSError *error = errorResult;
//    StickyAlertView *alert = [[StickyAlertView alloc]init];
//    NSArray *errors;
//    if(error.code == -1011) {
//        errors = @[@"Mohon maaf, terjadi kendala pada server"];
//    } else if (error.code==-1009 || error.code==-999) {
//        errors = @[@"Tidak ada koneksi internet"];
//    } else {
//        errors = @[error.localizedDescription];
//    }
//    
//    [alert initWithErrorMessages:errors delegate:_delegate];
//    [alert show];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{

}

-(RKRequestMethod)getRequestMethod:(int)tag
{
    return RKRequestMethodGET;
}

#pragma mark - GTM
- (void)configureGTM {
    _userManager = [UserAuthentificationManager new];

    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [_userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _lplmBaseuUrl = @"http://clover-staging.tokopedia.com";//[_gtmContainer stringForKey:@"lplm_base_url"];
    _lplmPostUrl = @"notify/v1";//[_gtmContainer stringForKey:@"lplm_post_url"];
}

#pragma mark - L
-(void)addLocalyticsProfile
{
    [Localytics setValue:_notifyData.attributes.notify_buyer forProfileAttribute:@"Notify Buyer" withScope:LLProfileScopeApplication];
    [Localytics setValue:_notifyData.attributes.notify_seller forProfileAttribute:@"Notify Seller" withScope:LLProfileScopeApplication];
}
@end
