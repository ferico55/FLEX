//
//  PromoRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoRequest.h"
#import "TokopediaNetworkManager.h"
#import "string_promo.h"

typedef NS_ENUM(NSInteger, PromoRequestType) {
    PromoRequestTypeProductSearch,
    PromoRequestTypeProductHotlist,
    PromoRequestTypeProductFeed,
    PromoRequestTypeShopFeed,
};

typedef NS_ENUM(NSInteger, PromoNetworkManager) {
    PromoNetworkManagerGet,
    PromoNetworkManagerAction,
};

@interface PromoRequest () <TokopediaNetworkManagerDelegate> {
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager *_objectManager;
    
    TokopediaNetworkManager *_actionNetworkManager;
    __weak RKObjectManager *_actionObjectManager;
    
    PromoRequestType _requestType;
    
    NSString *_query;
    NSString *_departmentId;
    NSString *_key;
    
    NSString *_adKey;
    NSString *_adSemKey;
    NSString *_adR;
    NSInteger _source;
    
    TAGContainer *_gtmContainer;
    NSString *_promoBaseURL;
    NSString *_promoPostURL;
    NSString *_promoFullURL;
    NSString *_promoActionBaseURL;
    NSString *_promoActionPostURL;
    NSString *_promoActionFullURL;
    
    BOOL _cancelRequestProductFeed;
    BOOL _cancelRequestHotlist;
    BOOL _cancelRequestShopFeed;
    BOOL _cancelRequestSearch;
}

@end

@implementation PromoRequest

- (NSString *)getPath:(int)tag {
    NSString *path;
    if (tag == PromoNetworkManagerGet) {
        path = [_promoPostURL isEqualToString:@""] ? API_PATH_PROMO : _promoPostURL;
    } else if (tag == PromoNetworkManagerAction) {
        path = [_promoActionPostURL isEqualToString:@""] ? API_PATH_ACTION_PROMO : _promoActionPostURL;
    }
    return path;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameters = @{};
    if (tag == PromoNetworkManagerGet) {
        if (_requestType == PromoRequestTypeProductSearch) {
            parameters = @{
                           @"action"       : @"ad_product_search",
                           @"query"        : _query,
                           @"department_id": _departmentId,
                           @"page"         : [NSString stringWithFormat:@"%d", _page],
                           @"per_page"     : @"4",
                           };
        } else if (_requestType == PromoRequestTypeProductHotlist) {
            parameters = @{
                           @"action"       : @"ad_product_hotlist",
                           @"key"          : _key,
                           @"page"         : [NSString stringWithFormat:@"%d", _page],
                           @"per_page"     : @"4",
                           };
        } else if (_requestType == PromoRequestTypeProductFeed) {
            parameters = @{
                           @"action"   : @"ad_product_feed",
                           @"page"     : [NSString stringWithFormat:@"%d", _page],
                           @"per_page" : @"4",
                           };
        } else if (_requestType == PromoRequestTypeShopFeed) {
            parameters = @{
                           @"action"   : @"ad_shop_feed",
                           @"page"     : [NSString stringWithFormat:@"%d", _page],
                           @"per_page" : @"4",
                           };
        }
    } else if (tag == PromoNetworkManagerAction) {
        NSString *source;
        if (_source == PromoRequestSourceHotlist) {
            source = @"hotlist";
        } else if (_source == PromoRequestSourceCategory) {
            source = @"directory";
        } else if (_source == PromoRequestSourceSearch) {
            source = @"search";
        } else if (_source == PromoRequestSourceFavoriteProduct) {
            source = @"fav_product";
        } else if (_source == PromoRequestSourceFavoriteShop) {
            source = @"fav_shop";
        }
        parameters = @{
                       @"action"       : @"ad_impression_click",
                       @"ad_key"       : _adKey,
                       @"ad_sem_key"   : _adSemKey,
                       @"ad_r"         : _adR,
                       @"src"          : source
                       };
    }
    return parameters;
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager;
    if (tag == PromoNetworkManagerGet) {
        objectManager = [self configureObjectManager];
    } else if (tag == PromoNetworkManagerAction) {
        objectManager = [self configureActionNetworkManager];
    }
    return objectManager;
}

- (RKObjectManager *)configureObjectManager {
    if([_promoBaseURL isEqualToString:kTkpdBaseURLString] || [_promoBaseURL isEqualToString:@""]) {
        _objectManager = [RKObjectManager sharedClient];
    } else {
        _objectManager = [RKObjectManager sharedClient:_promoBaseURL];
    }
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PromoResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY, kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoResult class]];
    
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[PromoProduct class]];
    [productMapping addAttributeMappingsFromArray:@[
                                                    API_AD_SEM_KEY,
                                                    API_SHOP_GOLD_STATUS_KEY,
                                                    API_SHOP_ID_KEY,
                                                    API_SHOP_URL_KEY,
                                                    API_PRODUCT_IMAGE_200_KEY,
                                                    API_PRODUCT_IMAGE_100_KEY,
                                                    API_PRODUCT_ID_KEY,
                                                    API_SHOP_URL_TOPADS_KEY,
                                                    API_AD_KEY,
                                                    API_SHOP_RATE_SPEED_DESC_KEY,
                                                    API_PRODUCT_TALK_COUNT_KEY,
                                                    API_SHOP_RATE_SERVICE_DESC_KEY,
                                                    API_PRODUCT_PRICE_KEY,
                                                    API_SHOP_LOCATION_KEY,
                                                    API_PRODUCT_WHOLESALE_KEY,
                                                    API_SHOP_RATE_SPEED_KEY,
                                                    API_PRODUCT_URL_TOPADS_KEY,
                                                    API_PRODUCT_REVIEW_COUNT_KEY,
                                                    API_SHOP_NAME_KEY,
                                                    API_AD_R_KEY,
                                                    API_AD_STICKER_IMAGE_KEY,
                                                    API_SHOP_RATE_ACCURACY_DESC_KEY,
                                                    API_SHOP_IS_OWNER_KEY,
                                                    API_PRODUCT_URL_KEY,
                                                    API_PRODUCT_NAME_KEY,
                                                    API_PRODUCT_SHOP_LUCKY_KEY,
                                                    ]];
    
    RKObjectMapping *shopMapping = [RKObjectMapping mappingForClass:[PromoShop class]];
    [shopMapping addAttributeMappingsFromArray:@[
                                                 API_SHOP_URI_AD_KEY,
                                                 API_SHOP_IMAGE_KEY,
                                                 API_AD_SEM_KEY,
                                                 API_SHOP_LOCATION_KEY,
                                                 API_SHOP_ID_KEY,
                                                 API_SHOP_NAME_KEY,
                                                 API_SHOP_URI_KEY,
                                                 API_AD_R_KEY,
                                                 API_AD_KEY,
                                                 API_PRODUCT_IMAGES_KEY
                                                 ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    if (_requestType == PromoRequestTypeProductSearch ||
        _requestType == PromoRequestTypeProductHotlist ||
        _requestType == PromoRequestTypeProductFeed) {
        RKRelationshipMapping *productRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                             toKeyPath:kTKPD_APILISTKEY
                                                                                           withMapping:productMapping];
        [resultMapping addPropertyMapping:productRelation];
    } else if (_requestType == PromoRequestTypeShopFeed) {
        RKRelationshipMapping *shopRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                          toKeyPath:kTKPD_APILISTKEY
                                                                                        withMapping:shopMapping];
        [resultMapping addPropertyMapping:shopRelation];
    }
    
    NSString *pathPattern = [_promoPostURL isEqualToString:@""] ? API_PATH_PROMO : _promoPostURL;
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:pathPattern
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (RKObjectManager *)configureActionNetworkManager {
    
    if([_promoActionBaseURL isEqualToString:kTkpdBaseURLString] || [_promoActionBaseURL isEqualToString:@""]) {
        _actionObjectManager = [RKObjectManager sharedClient];
    } else {
        _actionObjectManager = [RKObjectManager sharedClient:_promoActionBaseURL];
    }
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PromoResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY, kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    NSString *pathPattern = [_promoActionPostURL isEqualToString:@""] ? API_PATH_ACTION_PROMO : _promoActionPostURL;
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:pathPattern
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_actionObjectManager addResponseDescriptor:responseDescriptor];
    
    return _actionObjectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)result withTag:(int)tag {
    PromoResponse *response = [[result dictionary] objectForKey:@""];
    return response.status;
}

- (void)actionAfterRequest:(RKMappingResult *)result withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    PromoResponse *response = [[result dictionary] objectForKey:@""];
    if (tag == PromoNetworkManagerGet) {
        if ([self.delegate respondsToSelector:@selector(didReceivePromo:)]) {
            if (response.result.list.count > 0) {
                if (_requestType != PromoRequestTypeShopFeed) {
                    [TPAnalytics trackPromoImpression:response.result.list];
                }
                [self.delegate didReceivePromo:response.result.list];
            } else {
                [self.delegate didReceivePromo:nil];
            }
        }
    } else if (tag == PromoNetworkManagerAction) {
        if ([self.delegate respondsToSelector:@selector(didFinishedAddImpression)]) {
            [self.delegate didFinishedAddImpression];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    [self.delegate didReceivePromo:nil];
}

- (void)requestPromo {
    [self configureGTM];
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = PromoNetworkManagerGet;
    _networkManager.maxTries = 1;
    _networkManager.timeInterval = 3;
    [_networkManager doRequest];
}

- (void)requestForProductQuery:(NSString *)query department:(NSString *)department {
    _query = query;
    _departmentId = department;
    _requestType = PromoRequestTypeProductSearch;
    if (!_cancelRequestSearch) [self requestPromo];
}

- (void)requestForProductHotlist:(NSString *)key {
    _key = key;
    _requestType = PromoRequestTypeProductHotlist;
    if (!_cancelRequestHotlist) [self requestPromo];
}

- (void)requestForProductFeed {
    _requestType = PromoRequestTypeProductFeed;
    if (!_cancelRequestProductFeed) [self requestPromo];
}

- (void)requestForShopFeed {
    _requestType = PromoRequestTypeShopFeed;
    if (!_cancelRequestShopFeed) [self requestPromo];
}

- (void)requestActionPromo {
    [self configureGTM];
    _actionNetworkManager = [TokopediaNetworkManager new];
    _actionNetworkManager.delegate = self;
    _actionNetworkManager.tagRequest = PromoNetworkManagerAction;
    [_actionNetworkManager doRequest];
}

- (void)addImpressionKey:(NSString *)key
                  semKey:(NSString *)semKey
             referralKey:(NSString *)referralKey
                  source:(PromoRequestSourceType)source {
    _adKey = key;
    _adSemKey = semKey;
    _adR = referralKey;
    _source = source;
    [self requestActionPromo];
}

#pragma mark - GTM

- (void)configureGTM {    
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;

//#ifdef DEBUG
//    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
//    
//    _promoBaseURL = [secureStorage.keychainDictionary valueForKey:@"AppBaseUrl"];
//    _promoPostURL = @"promo.pl";
//    _promoFullURL = @"";
//    
//    NSString *promoActionBaseURL = [NSString stringWithFormat:@"%@/action/",
//                                    [secureStorage.keychainDictionary valueForKey:@"AppBaseUrl"]];
//    _promoActionBaseURL = promoActionBaseURL;
//    _promoActionPostURL = @"promo.pl";
//    _promoActionFullURL = @"";
//    
//    _cancelRequestHotlist = NO;
//    _cancelRequestProductFeed = NO;
//    _cancelRequestSearch = NO;
//    _cancelRequestShopFeed = NO;
//#else
    _promoBaseURL = [_gtmContainer stringForKey:GTMKeyPromoBase];
    _promoPostURL = [_gtmContainer stringForKey:GTMKeyPromoPost];
    _promoFullURL = [_gtmContainer stringForKey:GTMKeyPromoFull];
    
    _promoActionBaseURL = [_gtmContainer stringForKey:GTMKeyPromoBaseAction];
    _promoActionPostURL = [_gtmContainer stringForKey:GTMKeyPromoPostAction];
    _promoActionFullURL = [_gtmContainer stringForKey:GTMKeyPromoFullAction];
    
    _cancelRequestHotlist = [[_gtmContainer stringForKey:GTMKeyCancelPromoHotlist] boolValue];
    _cancelRequestProductFeed = [[_gtmContainer stringForKey:GTMKeyCancelPromoProductFeed] boolValue];
    _cancelRequestSearch = [[_gtmContainer stringForKey:GTMKeyCancelPromoSearch] boolValue];
    _cancelRequestShopFeed = [[_gtmContainer stringForKey:GTMKeyCancelPromoShopFeed] boolValue];
//#endif
}

@end