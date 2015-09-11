//
//  DeeplinkController.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DeeplinkController.h"
#import "NavigateViewController.h"
#import "WebViewInvoiceViewController.h"
#import "RequestUtils.h"

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
        NSString *urlString = [url absoluteString];
        NSDictionary *urlDict = [urlString URLQueryParametersWithOptions:URLQueryOptionDefault];
        [navigator navigateToSearchFromViewController:(UIViewController*)_delegate withData:urlDict];
    }
    else if([explodedPathUrl[1] isEqualToString:@"hot"]) {
        //hot
        [navigator navigateToHotlistResultFromViewController:(UIViewController*)_delegate withData:@{@"key":explodedPathUrl[2]}];
    }
    else if([explodedPathUrl[1] isEqualToString:@"catalog"]) {
        //catalog
        [navigator navigateToCatalogFromViewController:(UIViewController*)_delegate withCatalogID:explodedPathUrl[2] andCatalogKey:explodedPathUrl[3]];
    }
    else if(explodedPathUrl.count == 2) {
        //shop
        [navigator navigateToShopFromViewController:(UIViewController*)_delegate withShopName:explodedPathUrl[1]];
    } else if(explodedPathUrl.count == 3) {
        //product
        [navigator navigateToProductFromViewController:(UIViewController*)_delegate withData:@{@"product_key":explodedPathUrl[2], @"shop_domain" : explodedPathUrl[1]}];
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
