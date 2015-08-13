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
#import "SegmentedReviewReputationViewController.h"
#import "UserContainerViewController.h"
#import "ProfileContactViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "TKPDTabProfileNavigationController.h"
#import "DetailProductViewController.h"
#import "ProductGalleryViewController.h"

#import "InboxRootViewController.h"
#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"

#import "InboxTalkSplitViewController.h"
#import "InboxTalkViewController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "SplitReputationViewController.h"

#import "InboxReviewSplitViewController.h"
#import "InboxReviewViewController.h"
#import "TKPDTabInboxReviewNavigationController.h"

#import "InboxResolutionCenterTabViewController.h"
#import "InboxResolSplitViewController.h"

#import "ProductImages.h"
@interface NavigateViewController()<SplitReputationVcProtocol>

@end

@implementation NavigateViewController {
    UISplitViewController *splitViewController;
}
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
                       @"auth" : [auth getUserLoginData]?:@""
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
    vc.data = @{@"product_id" : productID?:@""};
    vc.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToProductFromViewController:(UIViewController *)viewController withLoadedData:(NSDictionary*)loadedData {
    DetailProductViewController *productController = [DetailProductViewController new];
    productController.loadedData = loadedData;
    productController.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:productController animated:YES];
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

- (void)navigateToProductFromViewController:(UIViewController *)viewController withName:(NSString *)name withPrice:(NSString *)price withId:(NSString *)productId withImageurl:(NSString *)url withShopName:(NSString*)shopName {
    NSDictionary *loadedData = @{@"product_id" : productId?:@"", @"product_name" : name?:@"", @"product_image" : url?:@"", @"product_price" :price?:@"", @"shop_name" : shopName?:@""};
    
    DetailProductViewController *productController = [DetailProductViewController new];
    productController.loadedData = loadedData;
    productController.data = @{@"product_id" : productId};
    productController.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:productController animated:YES];
}

-(void)navigateToInboxTalkFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxTalkSplitViewController *controller = [InboxTalkSplitViewController new];
        [viewController.navigationController pushViewController:controller animated:YES];
        
    } else {
        InboxTalkViewController *vc = [InboxTalkViewController new];
        vc.data=@{@"nav":@"inbox-talk"};
        
        InboxTalkViewController *vc1 = [InboxTalkViewController new];
        vc1.data=@{@"nav":@"inbox-talk-my-product"};
        
        InboxTalkViewController *vc2 = [InboxTalkViewController new];
        vc2.data=@{@"nav":@"inbox-talk-following"};
        
        NSArray *vcs = @[vc,vc1, vc2];
        
        TKPDTabInboxTalkNavigationController *controller = [TKPDTabInboxTalkNavigationController new];
        [controller setSelectedIndex:2];
        [controller setViewControllers:vcs];
        controller.hidesBottomBarWhenPushed = YES;
        
        [viewController.navigationController pushViewController:controller animated:YES];
    }
}

-(void)navigateToInboxReviewFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        InboxReviewSplitViewController *controller = [InboxReviewSplitViewController new];
//        [viewController.navigationController pushViewController:controller animated:YES];
        
        splitViewController = [UISplitViewController new];
        
        SplitReputationViewController *splitReputationViewController = [SplitReputationViewController new];
        splitReputationViewController.splitViewController = splitViewController;
        splitReputationViewController.del = self;
        [viewController.navigationController pushViewController:splitReputationViewController animated:YES];
        
    } else {
        SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
        segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
        segmentedReputationViewController.selectedIndex = CTagReviewSaya;
        [viewController.navigationController pushViewController:segmentedReputationViewController animated:YES];
        
        
//        InboxReviewViewController *vc = [InboxReviewViewController new];
//        vc.data=@{@"nav":@"inbox-review"};
//        
//        InboxReviewViewController *vc1 = [InboxReviewViewController new];
//        vc1.data=@{@"nav":@"inbox-review-my-product"};
//        
//        InboxReviewViewController *vc2 = [InboxReviewViewController new];
//        vc2.data=@{@"nav":@"inbox-review-following"};
//        
//        NSArray *vcs = @[vc,vc1, vc2];
//        
//        TKPDTabInboxReviewNavigationController *controller = [TKPDTabInboxReviewNavigationController new];
//        [controller setSelectedIndex:2];
//        [controller setViewControllers:vcs];
//        controller.hidesBottomBarWhenPushed = YES;
//        
//        [viewController.navigationController pushViewController:controller animated:YES];
    }
}

-(void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxResolSplitViewController *controller = [InboxResolSplitViewController new];
        [viewController.navigationController pushViewController:controller animated:YES];
        
    } else {
        InboxResolutionCenterTabViewController *controller = [InboxResolutionCenterTabViewController new];
        [viewController.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - SplitViewReputation Delegate
- (void)deallocVC {
    splitViewController = nil;
}
@end
