//
//  RequestNotifyLBLM.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestNotifyLBLM.h"
#import "NotifyLBLM.h"
#import "AlertLuckyView.h"

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
    [[self networkManager] doRequest];
    
//    [self performSelector:@selector(showLuckyBuyer) withObject:nil afterDelay:3.0f];
//    [self performSelector:@selector(showLuckyMerchant) withObject:nil afterDelay:4.0f];
}

-(TokopediaNetworkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager.isParameterNotEncrypted = YES;
        _networkManager.isUsingHmac = YES;
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
    RKObjectManager *objectManager = [RKObjectManager sharedClient:_lplmBaseuUrl];
    
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

-(int)didReceiveRequestMethod:(int)tag
{
    return RKRequestMethodGET;
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
    if ([_notifyData.attributes.notify_buyer isEqualToString:@"1"]) {
        [self performSelector:@selector(showLuckyBuyer) withObject:nil afterDelay:2.0f];
    }
    if ([_notifyData.attributes.notify_seller isEqualToString:@"1"]) {
        [self performSelector:@selector(showLuckyMerchant) withObject:nil afterDelay:3.0f];
    }
}

-(void)showLuckyMerchant
{
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = _notifyData.attributes.content_merchant_1?:[_gtmContainer stringForKey:@"string_notify_merchant_line_1"]?:@"Anda berhasil menjadi Lucky Merchant";
    NSString *line2 = _notifyData.attributes.content_merchant_2?:[_gtmContainer stringForKey:@"string_notify_merchant_line_2"]?:@"Kesempatan mendapatkan pesanan lebih banyak setiap harinya";
    NSString *line3 = _notifyData.attributes.content_merchant_3?:[_gtmContainer stringForKey:@"string_notify_merchant_line_3"]?:@"Berlaku hingga 30 hari kedepan";
    NSString *urlString = @"https://www.tokopedia.com/lucky-deal/";//_notifyData.attributes.link?:[_gtmContainer stringForKey:@"string_notify_buyer_link"]?:@"https://www.tokopedia.com/lucky-deal/";
    
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(12.0f/255.0f) green:(170.0f/255.0f) blue:85.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    [alertLucky show];
    
}

-(void)showLuckyBuyer
{
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = _notifyData.attributes.content_buyer_1?:[_gtmContainer stringForKey:@"string_notify_buyer_line_1"]?:@"Anda berhasil menjadi Lucky Buyer";
    NSString *line2 = _notifyData.attributes.content_buyer_2?:[_gtmContainer stringForKey:@"string_notify_buyer_line_2"]?:@"Dapatkan cashback dan diskon setiap belanja dari Lucky Merchant";
    NSString *line3 = _notifyData.attributes.content_buyer_3?:[_gtmContainer stringForKey:@"string_notify_buyer_line_3"]?:@"Berlaku hingga 30 hari kedepan";
    NSString *urlString =  @"https://www.tokopedia.com/lucky-deal/";//_notifyData.attributes.link?:[_gtmContainer stringForKey:@"string_notify_buyer_link"]?:@"https://www.tokopedia.com/lucky-deal/";
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(42.0f/255.0f) green:(180.0f/255.0f) blue:193.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    [alertLucky show];
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{

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

    [AnalyticsManager trackUserInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _lplmBaseuUrl = [_gtmContainer stringForKey:@"lplm_base_url"]?:@"https://clover.tokopedia.com";
    _lplmPostUrl = [_gtmContainer stringForKey:@"lplm_post_url"]?:@"notify/v1";
}

//#pragma mark - L
//-(void)addLocalyticsProfile
//{
//    [Localytics setValue:_notifyData.attributes.notify_buyer forProfileAttribute:@"Notify Buyer" withScope:LLProfileScopeApplication];
//    [Localytics setValue:_notifyData.attributes.notify_seller forProfileAttribute:@"Notify Seller" withScope:LLProfileScopeApplication];
//}
@end
