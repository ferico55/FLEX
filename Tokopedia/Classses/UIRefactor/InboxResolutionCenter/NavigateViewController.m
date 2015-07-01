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

#import "InboxRootViewController.h"
#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"

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
    container.data = @{
                       @"user_id" : userID
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

-(void)navigateToProductFromViewController:(UIViewController *)viewController withProductID:(NSString *)productID
{
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{@"product_id" : productID?:@""};
    vc.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:vc animated:YES];
}

-(void)navigateToInboxMessageFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxRootViewController *inboxController = [InboxRootViewController new];
        [viewController.navigationController pushViewController:inboxController animated:YES];
        
    } else {
        InboxMessageViewController *vc = [InboxMessageViewController new];
        vc.data=@{@"nav":@"inbox-message"};
        
        InboxMessageViewController *vc1 = [InboxMessageViewController new];
        vc1.data=@{@"nav":@"inbox-message-sent"};
        
        InboxMessageViewController *vc2 = [InboxMessageViewController new];
        vc2.data=@{@"nav":@"inbox-message-archive"};
        
        InboxMessageViewController *vc3 = [InboxMessageViewController new];
        vc3.data=@{@"nav":@"inbox-message-trash"};
        NSArray *vcs = @[vc,vc1, vc2, vc3];
        
        TKPDTabInboxMessageNavigationController *inboxController = [TKPDTabInboxMessageNavigationController new];
        [inboxController setSelectedIndex:2];
        [inboxController setViewControllers:vcs];
        
        [viewController.navigationController pushViewController:inboxController animated:YES];
    }

}

@end
