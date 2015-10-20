//
//  DeeplinkController.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DeeplinkController.h"
#import "NavigateViewController.h"
#import "WebViewController.h"
#import "RequestUtils.h"
#import "TAGDataLayer.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "TKPDTabNavigationController.h"
#import <GoogleAppIndexing/GoogleAppIndexing.h>
#import "MyWishlistViewController.h"
#import "CreateShopViewController.h"
#import "ProductAddEditViewController.h"
#import "TransactionCartRootViewController.h"

#import "string_product.h"

@implementation DeeplinkController

- (BOOL)shouldRedirectToWebView {
    _sanitizedURL = [GSDDeepLink handleDeepLink:[_delegate sanitizedURL]];
    NSURL *url = _sanitizedURL;

    //compare with GTM's array
    //GTM key : excluded_deeplink_url
    //replace below array later

    UserAuthentificationManager *userManager = [[UserAuthentificationManager alloc] init];
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    
    
    NSString *excludedUrlsString = [_gtmContainer stringForKey:@"excluded-url"];
    NSArray *excludedUrls = [excludedUrlsString componentsSeparatedByString:@","];
    if([excludedUrls containsObject:[url path]]) {
        return YES;
    }
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"/tokopedia.com/" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange textRange = NSMakeRange(0, [url host].length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:[url host] options:NSMatchingReportProgress range:textRange];
    
    if (matchRange.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (void)redirectToAppsViewController {
    NSURL *url = _sanitizedURL;
    
    NSArray *explodedPathUrl = [[url path] componentsSeparatedByString:@"/"];
    NavigateViewController *navigator = [NavigateViewController new];
    
    if([explodedPathUrl[1] isEqualToString:@"p"]) {
        //directory
        NSString *firstDepartment = [explodedPathUrl count] >= 3 ? explodedPathUrl[2] : @"";
        NSString *secondDepartment = [explodedPathUrl count] >= 4 ? explodedPathUrl[3] : @"";
        NSString *thirdDepartment = [explodedPathUrl count] >= 5 ? explodedPathUrl[4] : @"";
        
        NSDictionary *departments = @{@"department_1" : firstDepartment, @"department_2" : secondDepartment, @"department_3" : thirdDepartment, @"st" : @"product"};
        [navigator navigateToSearchFromViewController:(UIViewController*)_delegate withData:departments];
    }
    else if ([explodedPathUrl[1] isEqualToString:@"search"]) {
        //search
        NSString *urlString = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *urlDict = [urlString URLQueryParametersWithOptions:URLQueryOptionDefault];
        NSDictionary *data = urlDict;
        
        SearchResultViewController *vc = [SearchResultViewController new];
        vc.data = @{
                    @"search" : [data objectForKey:@"q"]?:@"",
                    @"type" : @"search_product",
                    @"location" : [data objectForKey:@"floc"]?:@"",
                    @"price_min" : [data objectForKey:@"pmin"]?:@"",
                    @"price_max" : [data objectForKey:@"pmax"]?:@"",
                    @"order_by" :[data objectForKey:@"ob"]?:@"",
                    @"shop_type" : [data objectForKey:@"fshop"]?:@"",
                    @"department_1" : [data objectForKey:@"department_1"]?:@"",
                    @"department_2" : [data objectForKey:@"department_2"]?:@"",
                    @"department_3" : [data objectForKey:@"department_3"]?:@"",
                    };
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc1.data = @{
                     @"search" : [data objectForKey:@"q"]?:@"",
                     @"type" : @"search_catalog",
                     @"location" : [data objectForKey:@"floc"]?:@"",
                     @"price_min" : [data objectForKey:@"pmin"]?:@"",
                     @"price_max" : [data objectForKey:@"pmax"]?:@"",
                     @"order_by" :[data objectForKey:@"ob"]?:@"",
                     @"shop_type" : [data objectForKey:@"fshop"]?:@"",
                     @"department_1" : [data objectForKey:@"department_1"]?:@"",
                     @"department_2" : [data objectForKey:@"department_2"]?:@"",
                     @"department_3" : [data objectForKey:@"department_3"]?:@"",
                     };
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.data = @{
                     @"search" : [data objectForKey:@"q"]?:@"",
                     @"type" : @"search_shop",
                     @"location" : [data objectForKey:@"floc"]?:@"",
                     @"price_min" : [data objectForKey:@"pmin"]?:@"",
                     @"price_max" : [data objectForKey:@"pmax"]?:@"",
                     @"order_by" :[data objectForKey:@"ob"]?:@"",
                     @"shop_type" : [data objectForKey:@"fshop"]?:@"",
                     @"department_1" : [data objectForKey:@"department_1"]?:@"",
                     @"department_2" : [data objectForKey:@"department_2"]?:@"",
                     @"department_3" : [data objectForKey:@"department_3"]?:@"",
                     };
        NSArray *viewcontrollers = @[vc,vc1,vc2];
        
        TKPDTabNavigationController *vcs = [[TKPDTabNavigationController alloc] init];
        
        [vcs setSelectedIndex:0];
        [vcs setViewControllers:viewcontrollers];
        [vcs setNavigationTitle:[data objectForKey:@"q"]];
        
        vcs.hidesBottomBarWhenPushed = YES;
        [((UIViewController*)_delegate).navigationController pushViewController:vcs animated:YES];
    }
    else if([explodedPathUrl[1] isEqualToString:@"hot"]) {
        //hot
        [navigator navigateToHotlistResultFromViewController:(UIViewController*)_delegate withData:@{@"key":explodedPathUrl[2]}];
    }
    else if([explodedPathUrl[1] isEqualToString:@"catalog"]) {
        //catalog
        [navigator navigateToCatalogFromViewController:(UIViewController*)_delegate withCatalogID:explodedPathUrl[2] andCatalogKey:explodedPathUrl[3]];
    }
    else if ([[url absoluteString] rangeOfString:@"tx.pl"].location != NSNotFound) {
        //cart
        TransactionCartRootViewController *controller = [TransactionCartRootViewController new];
        [((UIViewController*)_delegate).navigationController pushViewController:controller animated:YES];
    }
    else if ([[url absoluteString] rangeOfString:@"tab=wishlist"].location != NSNotFound) {
        //wishlist
        MyWishlistViewController *controller = [MyWishlistViewController new];
        [((UIViewController*)_delegate).navigationController pushViewController:controller animated:YES];
    }
    else if ([[url absoluteString] rangeOfString:@"create-shop"].location != NSNotFound) {
        //create shops
        CreateShopViewController *controller = [CreateShopViewController new];
        [((UIViewController*)_delegate).navigationController pushViewController:controller animated:YES];
    }
    else if ([[url absoluteString] rangeOfString:@"product-add.pl"].location != NSNotFound) {
        //add product
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary *dataAuth = [secureStorage keychainDictionary];
        
        ProductAddEditViewController *controller = [ProductAddEditViewController new];
        controller.data = @{
            kTKPD_AUTHKEY                   : dataAuth?:@{},
            DATA_TYPE_ADD_EDIT_PRODUCT_KEY  : @(TYPE_ADD_EDIT_PRODUCT_ADD),
        };
        
        [((UIViewController*)_delegate).navigationController pushViewController:controller animated:YES];
    }
    else if(explodedPathUrl.count == 2) {
        //shop
        [navigator navigateToShopFromViewController:(UIViewController*)_delegate withShopName:explodedPathUrl[1]];
    }
    else if(explodedPathUrl.count == 3) {
        //product
        [navigator navigateToProductFromViewController:(UIViewController*)_delegate withData:@{@"product_key":explodedPathUrl[2], @"shop_domain" : explodedPathUrl[1]}];
    }
}


- (void)redirectToWebViewController {
    NSURL *url = _sanitizedURL;
    NSArray *explodedPathUrl = [[url path] componentsSeparatedByString:@"/"];
    
    WebViewController *webController = [[WebViewController alloc] init];
    webController.strTitle = explodedPathUrl[1];
    webController.strURL = [NSString stringWithFormat:@"https://%@%@", [url host], [url path]];
    webController.hidesBottomBarWhenPushed = YES;
    
    
    [((UIViewController*)_delegate).navigationController pushViewController:webController animated:YES];
    return;
}

- (void)doRedirect {
    _sanitizedURL = [GSDDeepLink handleDeepLink:[_delegate sanitizedURL]];
    NSURL *url = _sanitizedURL;
    if ([[url host] rangeOfString:@"testMode"].location != NSNotFound ||
        [[url host] rangeOfString:@"localytics"].location != NSNotFound) {
        return;
    }
    if([self shouldRedirectToWebView]) {
        [self redirectToWebViewController];
    } else {
        [self redirectToAppsViewController];
    }
}

@end
