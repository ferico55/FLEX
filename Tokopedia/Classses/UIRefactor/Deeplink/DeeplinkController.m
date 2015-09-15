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
#import <GoogleAppIndexing/GoogleAppIndexing.h>

@implementation DeeplinkController

- (BOOL)shouldRedirectToWebView {
    NSURL *url = [GSDDeepLink handleDeepLink:[_delegate sanitizedURL]];

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
        NSString *firstDepartment = [explodedPathUrl count] >= 3 ? explodedPathUrl[2] : @"";
        NSString *secondDepartment = [explodedPathUrl count] >= 4 ? explodedPathUrl[3] : @"";
        NSString *thirdDepartment = [explodedPathUrl count] >= 5 ? explodedPathUrl[4] : @"";
        
        NSDictionary *departments = @{@"department_1" : firstDepartment, @"department_2" : secondDepartment, @"department_3" : thirdDepartment, @"st" : @"product"};
        [navigator navigateToSearchFromViewController:(UIViewController*)_delegate withData:departments];
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
    NSURL *url = [_delegate sanitizedURL];
    NSArray *explodedPathUrl = [[url path] componentsSeparatedByString:@"/"];
    
    WebViewController *webController = [[WebViewController alloc] init];
    webController.strTitle = explodedPathUrl[1];
    webController.strURL = [NSString stringWithFormat:@"https://%@%@", [url host], [url path]];
    webController.hidesBottomBarWhenPushed = YES;
    
    
    [((UIViewController*)_delegate).navigationController pushViewController:webController animated:YES];
    return;
}

- (void)doRedirect {
    if([self shouldRedirectToWebView]) {
        [self redirectToWebViewController];
    } else {
        [self redirectToAppsViewController:[_delegate sanitizedURL]];
    }
}


@end
