//
//  NavigateViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NavigateViewController.h"

#import "UserAuthentificationManager.h"

#import "WebViewInvoiceViewController.h"
#import "ShopContainerViewController.h"
#import "string_more.h"
#import "UserContainerViewController.h"
#import "ProfileContactViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "TKPDTabProfileNavigationController.h"
#import "DetailProductViewController.h"
#import "ProductGalleryViewController.h"

#import "ProductImages.h"

@implementation NavigateViewController
-(void)navigateToInvoiceFromViewController:(UIViewController *)viewController withInvoiceURL:(NSString *)invoiceURL
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    WebViewInvoiceViewController *VC = [WebViewInvoiceViewController new];
    NSDictionary *invoiceURLDictionary = [NSDictionary dictionaryFromURLString:invoiceURL];
    NSString *invoicePDF = [invoiceURLDictionary objectForKey:@"pdf"];
    NSString *invoiceID = [invoiceURLDictionary objectForKey:@"id"];
    NSString *userID = [auth getUserId];
    NSString *invoiceURLforWS = [NSString stringWithFormat:@"%@/invoice.pl?invoice_pdf=%@&id=%@&user_id=%@",kTkpdBaseURLString,invoicePDF,invoiceID,userID];
    VC.urlAddress = invoiceURLforWS?:@"";
    [viewController.navigationController pushViewController:VC animated:YES];
}

-(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    container.data = @{MORE_SHOP_ID : shopID};
    [viewController.navigationController pushViewController:container animated:YES];
}

-(void)navigateToProfileFromViewController:(UIViewController *)viewController withUserID:(NSString *)userID
{
    
    UserContainerViewController *container = [UserContainerViewController new];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    container.data = @{
                       @"user_id" : userID,
                       @"auth" : [auth getUserLoginData]
                       };
    
    [viewController.navigationController pushViewController:container animated:YES];
}

-(void)navigateToShowImageFromViewController:(UIViewController *)viewController withImageURLStrings:(NSArray*)imageURLStrings indexImage:(NSInteger)index
{
    
    NSMutableArray *productImages = [NSMutableArray new];

    for (NSString *image in imageURLStrings) {
        ProductImages* images = [ProductImages new];
        images.image_src = image;
        images.image_description = @"";
        [productImages addObject:images];
    }

    NSDictionary *data = @{
                           @"image_index" : @(index),
                           @"images" : productImages
                           };
    
    ProductGalleryViewController *vc = [ProductGalleryViewController new];
    vc.data = data;
    
    [viewController.navigationController presentViewController:vc animated:YES completion:nil];
}

-(void)navigateToProductFromViewController:(UIViewController *)viewController withProductID:(NSString *)productID {
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{@"product_id" : productID};
    vc.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToCatalogFromViewController:(UIViewController *)viewController withCatalogID:(NSString *)catalogID {
    
}

@end
