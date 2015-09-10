//
//  DeeplinkController.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DeeplinkController.h"
#import "NavigateViewController.h"

@implementation DeeplinkController

- (BOOL)shouldRedirectToWebView {
    NSURL *url = [_delegate sanitizedURL];
    //compare with GTM's array
    //GTM key : excluded_deeplink_url
    //replace below array later
    NSArray *excludedUrls = @[@"/careers", @"/brand-asset", @"/bantuan/pembayaran"];
    if([excludedUrls containsObject:[url path]]) {
        return YES;
    }
    
    if([[url host] isEqualToString:@"www.tokopedia.com"]) {
        return NO;
    }
    
    return YES;
}

- (void)redirectToAppsViewController:(NSURL*)url {
    NSArray *explodedPathUrl = [[url path] componentsSeparatedByString:@"/"];
    NavigateViewController *navigator = [NavigateViewController new];
    
    if([explodedPathUrl[1] isEqualToString:@"p"]) {
        //directory
        
    }
    else if ([explodedPathUrl[1] isEqualToString:@"search"]) {
        //search
        
    }
    else if([explodedPathUrl[1] isEqualToString:@"hot"]) {
        //hot
        
    }
    else if([explodedPathUrl[1] isEqualToString:@"catalog"]) {
        //catalog
        
    }
    else if(explodedPathUrl.count == 2) {
        //shop
        [navigator navigateToShopFromViewController:_delegate withShopName:explodedPathUrl[1]];
    } else if(explodedPathUrl.count == 3) {
        //product
        [navigator navigateToProductFromViewController:_delegate withData:@{@"product_key":explodedPathUrl[2], @"shop_domain" : explodedPathUrl[1]}];
    }
}

- (void)redirectToWebViewController {
    
}

- (void)doRedirect {
    if([self shouldRedirectToWebView]) {
        [self redirectToWebViewController];
    } else {
        [self redirectToAppsViewController:[_delegate sanitizedURL]];
    }
}

@end
