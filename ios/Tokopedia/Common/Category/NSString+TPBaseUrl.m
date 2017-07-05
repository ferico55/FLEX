//
//  NSString+TPBaseUrl.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "NSString+TPBaseUrl.h"

@implementation NSString (TPBaseUrl)

typedef NS_ENUM(NSUInteger, TPUrl) {
    TPUrlProduction,
    TPUrlStaging,
    TPUrlAlpha,
    TPUrlDevelopment
};


+ (NSNumber*)urlIndex {
    NSNumber *TPUrlIndex = FBTweakValue(@"Network", @"Environment", @"Base Url", @(TPUrlProduction),
                                        (@{
                                           @(TPUrlProduction) : @"Production",
                                           @(TPUrlStaging) : @"Staging",
                                           @(TPUrlAlpha) : @"Alpha",
                                           @(TPUrlDevelopment) : @"Development",
                                           }));
    
    return TPUrlIndex;
}

+ (NSString*)tokopediaUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://www.tokopedia.com",
                           @(TPUrlStaging) : @"https://staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://www.ar-arief.ndvl"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}


+ (NSString*)basicUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"http://www.tokopedia.com/ws",
                           @(TPUrlStaging) : @"http://staging.tokopedia.com/ws",
                           @(TPUrlAlpha) : @"http://alpha.tokopedia.com/ws",
                           @(TPUrlDevelopment) : @"http://www.ar-arief.ndvl/ws"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}


+ (NSString*)aceUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://ace.tokopedia.com",
                           @(TPUrlStaging) : @"https://ace-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://ace-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://ace.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
    
    
}

+ (NSString*)v4Url {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://ws.tokopedia.com",
                           @(TPUrlStaging) : @"https://ws-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://ws-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"http://ws.ar-arief.ndvl"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)topAdsUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://ta.tokopedia.com",
                           @(TPUrlStaging) : @"https://ta-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://ta-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://ta.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}


+ (NSString*)keroUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://kero.tokopedia.com",
                           @(TPUrlStaging) : @"https://kero-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://kero-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://kero.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)accountsUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://accounts.tokopedia.com",
                           @(TPUrlStaging) : @"https://accounts-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://accounts-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"http://192.168.100.160:8009"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)hadesUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://hades.tokopedia.com",
                           @(TPUrlStaging) : @"https://hades-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://hades-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://hades.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)mojitoUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://mojito.tokopedia.com",
                           @(TPUrlStaging) : @"https://mojito-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://mojito-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://mojito.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}


+ (NSString*)pulsaApiUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://pulsa-api.tokopedia.com",
                           @(TPUrlStaging) : @"https://pulsa-api-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://pulsa-api-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://pulsa-api.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)pulsaUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://pulsa.tokopedia.com",
                           @(TPUrlStaging) : @"https://pulsa-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://pulsa-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://pulsa.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)jsUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://js.tokopedia.com",
                           @(TPUrlStaging) : @"https://js-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://js-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://js.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}



+ (NSString*)kunyitUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://inbox.tokopedia.com",
                           @(TPUrlStaging) : @"https://inbox-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://inbox-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://inbox.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)goldMerchantUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://goldmerchant.tokopedia.com",
                           @(TPUrlStaging) : @"https://goldmerchants-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://goldmerchant.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://goldmerchant.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)pointUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    //https://points.tokopedia.com/app/v4
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://points.tokopedia.com",
                           @(TPUrlStaging) : @"https://points-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"https://points-alpha.tokopedia.com",
                           @(TPUrlDevelopment) : @"https://points.tokopedia.com"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString *)wvloginUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary *urls = @{
                           @(TPUrlProduction) : @"https://js.tokopedia.com/wvlogin",
                           @(TPUrlStaging) : @"https://js-staging.tokopedia.com/wvlogin",
                           @(TPUrlAlpha) : @"https://ajax-alpha.tokopedia.com/wvlogin",
                           @(TPUrlDevelopment) : @"http://192.168.56.101:9000/js/wvlogin"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)walletUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://wallet.tokopedia.id",
                           @(TPUrlStaging) : @"https://wallet-staging.tokopedia.id",
                           @(TPUrlAlpha) : @"http://192.168.100.151:9096",
                           @(TPUrlDevelopment) : @"http://192.168.100.151:9096"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)mobileSiteUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://m.tokopedia.com",
                           @(TPUrlStaging) : @"https://m-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"http://192.168.100.151:9096",
                           @(TPUrlDevelopment) : @"http://192.168.100.151:9096"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)feedsMobileSiteUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://m.tokopedia.com",
                           @(TPUrlStaging) : @"https://3-feature-m-staging.tokopedia.com",
                           @(TPUrlAlpha) : @"http://192.168.100.151:9096",
                           @(TPUrlDevelopment) : @"http://192.168.100.151:9096"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

+ (NSString*)tokocashUrl {
    NSNumber *TPUrlIndex = [NSString urlIndex];
    
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"https://www.tokocash.com",
                           @(TPUrlStaging) : @"https://wallet-staging.tokopedia.id",
                           @(TPUrlAlpha) : @"http://192.168.100.151:9096",
                           @(TPUrlDevelopment) : @"http://192.168.100.151:9096"
                           };
    
    return [urls objectForKey:TPUrlIndex];
}

@end
