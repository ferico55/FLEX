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
#import "string_more.h"
#import "HotlistResultViewController.h"
#import "CatalogViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "InboxTalkSplitViewController.h"
#import "InboxTalkViewController.h"
#import "TKPDTabInboxTalkNavigationController.h"

#import "InboxResolutionCenterTabViewController.h"
#import "InboxResolSplitViewController.h"
#import "TKPDTabViewController.h"

#import "ProductImages.h"

#import "AlertLuckyView.h"
#import "LuckyDealWord.h"
#import "RequestUtils.h"
#import "Tokopedia-Swift.h"

#import "GalleryViewController.h"
#import "TkpdHMAC.h"
#import "CategoryResultViewController.h"

#import "ProductTalkDetailViewController.h"
#import "TransactionCartViewController.h"
#import "SalesNewOrderViewController.h"
#import "ShipmentConfirmationViewController.h"
#import "ShipmentStatusViewController.h"
#import "SalesTransactionListViewController.h"
#import "TxOrderConfirmedViewController.h"
#import "TxOrderStatusViewController.h"
#import "PromoDetailViewController.h"
#import "TransactionATCViewController.h"
#import "OfficialStoreBrandsViewController.h"
#import "OfficialStorePromoViewController.h"
#import "NavigationHelper.h"
@import NativeNavigation;


@interface NavigateViewController()<GalleryViewControllerDelegate>

@end

@implementation NavigateViewController {
    UISplitViewController *splitViewController;
    NSArray *_images;
    NSUInteger _indexImage;
    NSArray *_imageDescriptions;
}
+(void)navigateToInvoiceFromViewController:(UIViewController *)viewController withInvoiceURL:(NSString *)invoiceURL {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    WebViewInvoiceViewController *VC = [WebViewInvoiceViewController new];
    NSDictionary *invoiceDictionary = [[NSDictionary dictionaryFromURLString:invoiceURL] autoParameters];
    
    NSString *invoicePDF = invoiceDictionary[@"pdf"]?:@"";
    NSString *invoiceID = invoiceDictionary[@"id"]?:@"";
    NSString* deviceID = invoiceDictionary[@"device_id"]?:@"";
    NSString* deviceTime = invoiceDictionary [@"device_time"]?:@"";
    NSString *userID = [auth getUserId];
    
    NSString* invoiceURLforWS = [NSString stringWithFormat:@"%@/v4/invoice.pl?device_id=%@&device_time=%@&id=%@&os_type=2&pdf=%@&recharge=0&tkpd=0&user_id=%@",
                                 [NSString v4Url],
                                 deviceID,
                                 deviceTime,
                                 invoiceID,
                                 invoicePDF,
                                 userID];
    
    VC.urlAddress = invoiceURLforWS?:@"";
    [viewController.navigationController pushViewController:VC animated:YES];}

+(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopViewController *container = [[ShopViewController alloc] init];
    container.data = @{MORE_SHOP_ID : shopID?:@""};
    [viewController.navigationController pushViewController:container animated:YES];
}


-(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopViewController *container = [[ShopViewController alloc] init];
    container.data = @{MORE_SHOP_ID : shopID?:@""};
    [viewController.navigationController pushViewController:container animated:YES];
}

-(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID withEtalaseId:(NSString *)etalaseId
{
    ShopViewController *container = [[ShopViewController alloc] init];
    container.data = @{MORE_SHOP_ID : shopID?:@""};
    EtalaseList *list = [EtalaseList new];
    list.etalase_id = etalaseId;
    container.initialEtalase = list;
    [viewController.navigationController pushViewController:container animated:YES];
}

-(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID withEtalaseId:(NSString *)etalaseId search:(NSString *)keyword sort:(NSString *)by
{
    ShopProductFilter *filter = [ShopProductFilter new];
    filter.query = keyword ?: @"";
    filter.orderBy = by ?: @"";
    filter.etalaseId = etalaseId ?: @"";
    ShopViewController *container = [[ShopViewController alloc] init];
    container.data = @{kTKPDDETAIL_APISHOPIDKEY : shopID ?: @""};
    container.productFilter = filter;
    
    [viewController.navigationController pushViewController:container animated:YES];
}

-(void)navigateToShopInfoFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopInfo *info = [ShopInfo new];
    info.shop_id = shopID;
    DetailShopResult *result = [DetailShopResult new];
    result.info = info;
    Shop *shop = [Shop new];
    shop.result = result;
    ShopInfoViewController *shopInfo = [ShopInfoViewController new];
    shopInfo.data = @{@"infoshop" : shop? : @""};
    [viewController.navigationController pushViewController:shopInfo animated:YES];
}

-(void)navigateToShopTalkFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopTalkPageViewController *talk = [ShopTalkPageViewController new];
    talk.data = @{@"shop_id" : shopID?:@""};
    talk.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:talk animated:YES];
}

-(void)navigateToShopReviewFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ReactViewController* reviewViewController = [[ReactViewController alloc] initWithModuleName:@"ShopReviewScreen" props:@{@"shopID": shopID}];
    reviewViewController.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:reviewViewController animated:YES];
}

-(void)navigateToShopNoteFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID
{
    ShopNotesPageViewController *notes = [ShopNotesPageViewController new];
    notes.data = @{@"shop_id" : shopID?:@""};
    notes.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:notes animated:YES];
}

-(void)navigateToCartFromViewController:(UIViewController*)viewController {
    UITabBarController *tabBarController = viewController.tabBarController;
    UINavigationController *navController=(UINavigationController*)[tabBarController.viewControllers objectAtIndex:3];
    [navController popToRootViewControllerAnimated:YES];
    
    UINavigationController *selfNav=(UINavigationController*)[tabBarController.viewControllers objectAtIndex:tabBarController.selectedIndex];
    [tabBarController setSelectedIndex:3];
    [selfNav popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:SHOULD_REFRESH_CART object:nil];
}

//seller
-(void)navigateToSellerNewOrderFromViewController:(UIViewController*)viewController {
    SalesNewOrderViewController *order = [SalesNewOrderViewController new];
    order.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:order animated:YES];
}

-(void)navigateToSellerShipmentFromViewController:(UIViewController*)viewController {
    ShipmentConfirmationViewController *shipment = [ShipmentConfirmationViewController new];
    shipment.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:shipment animated:YES];
}

-(void)navigateToSellerShipmentStatusFromViewController:(UIViewController*)viewController {
    ShipmentStatusViewController *shipment = [ShipmentStatusViewController new];
    shipment.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:shipment animated:YES];
}

-(void)navigateToSellerHistoryFromViewController:(UIViewController*)viewController {
    SalesTransactionListViewController *history = [SalesTransactionListViewController new];
    history.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:history animated:YES];
}

//buyer
-(void)navigateToBuyerPaymentFromViewController:(UIViewController*)viewController {
    TxOrderConfirmedViewController *payment = [TxOrderConfirmedViewController new];
    payment.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:payment animated:YES];
}

-(void)navigateToBuyerOrderFromViewController:(UIViewController*)viewController {
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_status";
    controller.viewControllerTitle = @"Status Pemesanan";
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

-(void)navigateToBuyerShippingConfFromViewController:(UIViewController*)viewController {
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_deliver";
    controller.viewControllerTitle = @"Konfirmasi Penerimaan";
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

-(void)navigateToBuyerHistoryFromViewController:(UIViewController*)viewController {
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_list";
    controller.viewControllerTitle = @"Daftar Transaksi";
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

-(void)navigateToHotListFromViewController:(UIViewController*)viewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
}



-(void)navigateToProfileFromViewController:(UIViewController *)viewController withUserID:(NSString *)userID {
    [TPRoutes routeURL:[NSURL URLWithString:[NSString stringWithFormat:@"tokopedia://people/%@", userID]]];
}

-(void)navigateToShowImageFromViewController:(UIViewController *)viewController withImageDictionaries:(NSArray *)images imageDescriptions:(NSArray *)imageDesc indexImage:(NSInteger)index
{
    _images = images;
    _imageDescriptions = imageDesc;
    _indexImage = (NSUInteger)index;
    
    GalleryViewController *gallery = [[GalleryViewController alloc] initWithPhotoSource:self withStartingIndex:(int)index];
    gallery.canDownload = YES;
    [viewController.navigationController presentViewController:gallery animated:YES completion:nil];
}

+ (void)navigateToProductFromViewController:(UIViewController *)viewController
                              withProductID:(NSString *)productID
                                    andName:(NSString *)name
                                   andPrice:(NSString *)price
                                andImageURL:(NSString *)imageURL
                                andShopName:(NSString *)shopName {
    ProductDetailViewController *vc = [[ProductDetailViewController alloc] initWithProductID:productID?:@""
                                                                                        name:name?:@""
                                                                                       price:price?:@""
                                                                                    imageURL:imageURL?:@""
                                                                                    shopName:shopName?:@""
                                                                           isReplacementMode:NO];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [viewController.navigationController pushViewController:vc animated:YES];
}

-(void)navigateToInboxTalkFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxTalkSplitViewController *controller = [InboxTalkSplitViewController new];
        [viewController.navigationController pushViewController:controller animated:YES];
        
    } else {
        TKPDTabViewController *controller = [TKPDTabViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        controller.inboxType = InboxTypeTalk;
        
        InboxTalkViewController *allTalk = [InboxTalkViewController new];
        allTalk.inboxTalkType = InboxTalkTypeAll;
        allTalk.delegate = controller;
        
        InboxTalkViewController *myProductTalk = [InboxTalkViewController new];
        myProductTalk.inboxTalkType = InboxTalkTypeMyProduct;
        myProductTalk.delegate = controller;
        
        InboxTalkViewController *followingTalk = [InboxTalkViewController new];
        followingTalk.inboxTalkType = InboxTalkTypeFollowing;
        followingTalk.delegate = controller;
        
        controller.viewControllers = @[allTalk, myProductTalk, followingTalk];
        controller.tabTitles = @[@"Semua", @"Produk Saya", @"Ikuti"];
        controller.menuTitles = @[@"Semua Diskusi", @"Belum Dibaca"];
        
        [viewController.navigationController pushViewController:controller animated:YES];
    }
}

- (void)navigateToTopChatFromViewController:(UIViewController *)viewController {
    
}

//-(void)navigateToInboxTalkFromViewController:(UIViewController *)viewController withTalkId:(NSString *)talkId withShopId:(NSString *)shopId
//{
//    UserAuthentificationManager *userMng = [UserAuthentificationManager new];
//    TalkList *talk = [TalkList new];
//    ProductTalkDetailViewController *vc = [[ProductTalkDetailViewController alloc] init];
//    talk.talk_id = talkId;
//    talk.talk_shop_id = shopId;
//    talk.talk_user_id = [userMng.getUserId intValue];
//    vc.talk = talk;
//    
//    [viewController.navigationController pushViewController:vc animated:YES];
//}

-(void)navigateToInboxTalkFromViewController:(UIViewController *)viewController withTalkId:(NSString *)talkId
{
    UserAuthentificationManager *userMng = [UserAuthentificationManager new];
    TalkList *talk = [TalkList new];
    ProductTalkDetailViewController *vc = [[ProductTalkDetailViewController alloc] init];
    talk.talk_id = talkId;
    talk.talk_user_id = [userMng.getUserId intValue];
    vc.talk = talk;
    
    vc.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:vc animated:YES];
}

-(void)navigateToInboxReviewFromViewController:(UIViewController *)viewController
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary* userData = [auth getUserLoginData];
    
    UIViewController *reviewReactViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        ReactModule *masterModule = [[ReactModule alloc] initWithName:@"InboxReview" props:@{@"authInfo": userData}];
        ReactModule *detailModule = [[ReactModule alloc] initWithName:@"InvoiceDetailScreen" props:@{@"authInfo": userData}];
        reviewReactViewController = [[ReactSplitViewController alloc] initWithMasterModule:masterModule detailModule:detailModule];
    } else {
        reviewReactViewController = [[ReactViewController alloc] initWithModuleName:@"InboxReview" props:@{@"authInfo" : userData }];
    }
    
    reviewReactViewController.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:reviewReactViewController animated:YES];
    return;
}



- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController withGetDataFromMasterDB:(BOOL)getDataFromMaster
{
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary* userData = [auth getUserLoginData];
    
    UIViewController *reviewReactViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        ReactModule *masterModule = [[ReactModule alloc] initWithName:@"InboxReview" props:@{@"authInfo": userData}];
        ReactModule *detailModule = [[ReactModule alloc] initWithName:@"InvoiceDetailScreen" props:@{@"authInfo": userData}];
        reviewReactViewController = [[ReactSplitViewController alloc] initWithMasterModule:masterModule detailModule:detailModule];
    } else {
        reviewReactViewController = [[ReactViewController alloc] initWithModuleName:@"InboxReview" props:@{@"authInfo" : userData }];
    }
    
    reviewReactViewController.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:reviewReactViewController animated:YES];
    return;
}

-(void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxResolSplitViewController *controller = [InboxResolSplitViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        [viewController.navigationController pushViewController:controller animated:YES];
        
    } else {
        InboxResolutionCenterTabViewController *controller = [InboxResolutionCenterTabViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        [viewController.navigationController pushViewController:controller animated:YES];
    }
}

-(void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController atIndex:(int)index
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxResolSplitViewController *controller = [[InboxResolSplitViewController alloc] initWithSelectedIndex:index];
        controller.hidesBottomBarWhenPushed = YES;
        [viewController.navigationController pushViewController:controller animated:YES];
        
    } else {
        InboxResolutionCenterTabViewController *controller = [[InboxResolutionCenterTabViewController alloc] initWithSelectedIndex:index];
        controller.hidesBottomBarWhenPushed = YES;
        [viewController.navigationController pushViewController:controller animated:YES];
    }
}

- (void)navigateToShopFromViewController:(UIViewController*)viewController withShopName:(NSString*)shopName {
    ShopViewController *container = [[ShopViewController alloc] init];

    container.data = @{
                       @"shop_domain" : shopName
                       };
    [viewController.navigationController pushViewController:container animated:YES];
}

- (void)navigateToCatalogFromViewController:(UIViewController *)viewController withCatalogID:(NSString *)catalogID{
    CatalogViewController *catalogViewController = [CatalogViewController new];
    catalogViewController.catalogID = catalogID;
    catalogViewController.catalogImage = @"";
    catalogViewController.catalogPrice = @"";
    
    catalogViewController.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:catalogViewController animated:YES];
}

- (void)navigateToIntermediaryCategoryFromViewController:(UIViewController *)viewController withCategoryId:(NSString *) categoryId categoryName:(NSString *) categoryName isIntermediary:(BOOL) isIntermediary{
    CategoryResultViewController *categoryResultProductViewController = [CategoryResultViewController new];
    categoryResultProductViewController.hidesBottomBarWhenPushed = YES;
    categoryResultProductViewController.data = @{@"sc" : categoryId, @"department_name": categoryName, @"type" : @"search_product"};
    categoryResultProductViewController.isIntermediary = isIntermediary;
    
    SearchResultViewController *searchResultCatalogViewController = [SearchResultViewController new];
    searchResultCatalogViewController.hidesBottomBarWhenPushed = YES;
    searchResultCatalogViewController.isFromDirectory = YES;
    searchResultCatalogViewController.data = @{@"sc" : categoryId, @"department_name": categoryName, @"type" : @"search_catalog"};
    
    NSArray *subViewControllers = @[categoryResultProductViewController, searchResultCatalogViewController];
    
    TKPDTabNavigationController *tkpdTabNavigationController = [TKPDTabNavigationController new];
    categoryResultProductViewController.tkpdTabNavigationController = tkpdTabNavigationController;
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:@{@"type": @1, @"department_id" : categoryId}];
    tkpdTabNavigationController.data = data;
    tkpdTabNavigationController.navigationTitle = categoryName ?: @"";
    tkpdTabNavigationController.selectedIndex = 0;
    tkpdTabNavigationController.viewControllers = subViewControllers;
    tkpdTabNavigationController.hidesBottomBarWhenPushed = true;
    
    [viewController.navigationController pushViewController:tkpdTabNavigationController animated: YES];
}

- (void)navigateToIntermediaryCategoryFromViewController:(UIViewController *)viewController withData:(CategoryDataForCategoryResultVC*)data withFilterParams:(NSDictionary *) filterParams{
    CategoryResultViewController *vc = [CategoryResultViewController new];
    vc.isIntermediary = YES;
    NSMutableDictionary *dataDictionaryWithFilterParams = [[self addDataTypeFromData: [data mapToDictionary]] mutableCopy];
    [dataDictionaryWithFilterParams addEntriesFromDictionary:filterParams];
    vc.data = [dataDictionaryWithFilterParams copy];
    vc.title = [self getTitleFromData: dataDictionaryWithFilterParams];
    vc.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToSearchFromViewController:(UIViewController *)viewController withURL:(NSURL*)url {
    NSString *urlString = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *data = [[urlString URLQueryParametersWithOptions:URLQueryOptionDefault] mutableCopy];
    
    if (data[@"q"] != nil &&
        [NavigationHelper isKeywordRedirectToOfficialStore: data[@"q"]] ) {
        [TPRoutes routeURL:[[NSURL alloc] initWithString:@"tokopedia://official-store/mobile"]];
    } else {
        [data setObject:data[@"q"]?:@"" forKey:@"search"];
        
        SearchResultViewController *searchProductController = [[SearchResultViewController alloc] init];
        [data setObject:@"search_product" forKey:@"type"];
        searchProductController.data = [data copy];
        
        SearchResultViewController *searchCatalogController = [[SearchResultViewController alloc] init];
        [data setObject:@"search_catalog" forKey:@"type"];
        searchCatalogController.data = [data copy];
        
        SearchResultShopViewController *searchShopController = [[SearchResultShopViewController alloc] init];
        [data setObject:@"search_shop" forKey:@"type"];
        searchShopController.data = [data copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *viewControllers = @[searchProductController, searchCatalogController, searchShopController];
            
            TKPDTabNavigationController *tabController = [[TKPDTabNavigationController alloc] init];
            [tabController setNavigationTitle:[data objectForKey:@"q"]];
            [tabController setViewControllers:viewControllers];
            
            if ([[data objectForKey:@"st"] isEqualToString:@"catalog"]) {
                
                [tabController setSelectedIndex:1];
                [tabController setSelectedViewController:searchProductController animated:YES];
                
                NSDictionary *userInfo = @{@"count": @(3), @"selectedIndex": @(1)};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setsegmentcontrol" object:nil userInfo:userInfo];
                
            } else if ([[data objectForKey:@"st"] isEqualToString:@"shop"]) {
                
                [tabController setSelectedIndex:2];
                [tabController setSelectedViewController:searchShopController animated:YES];
                
                NSDictionary *userInfo = @{@"count": @(3),  @"selectedIndex": @(2)};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setsegmentcontrol" object:nil userInfo:userInfo];
            }
            
            tabController.hidesBottomBarWhenPushed = YES;
            [viewController.navigationController pushViewController:tabController animated:YES];
        });
    }

}

- (void)navigateToHotlistResultFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data {
    HotlistResultViewController *controller = [HotlistResultViewController new];
    controller.data = data;
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToPromoDetailFromViewController:(UIViewController*) viewController withName:(NSString*) promoName {
    PromoDetailViewController *controller = [PromoDetailViewController new];
    controller.promoName = promoName;
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToAddProductFromViewController:(UIViewController*)viewController {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    ReactViewController *controller = [[ReactViewController alloc] initWithModuleName:@"AddProductScreen"
                                                                                props:@{
                                                                                        @"authInfo": [userManager getUserLoginData]
                                                                                        }];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    [viewController presentViewController:navigation animated:YES completion:nil];
}
+ (void)navigateToReferralWelcomeWithData:(NSDictionary*)data {
    NSString *code = data[@"code"];
    NSString *owner = data[@"owner"];
    NSString *ownCode = [ReferralManager new].referralCode;
    if (code == nil || owner == nil || [code compare:ownCode] == NSOrderedSame) {
        [self navigateToReferralScreen];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Referral" bundle:nil];
    ReferralWelcomeController* welcomeController = [storyboard instantiateViewControllerWithIdentifier:@"ReferralWelcomeController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeController];
    welcomeController.promoCode = code;
    welcomeController.ownerName = owner;
    welcomeController.dismisHandler = ^{
        [(AppDelegate *)[UIApplication sharedApplication].delegate setupInitialViewController];
    };
    [UIApplication sharedApplication].keyWindow.rootViewController = navController;
}

+ (void)navigateToReferralScreen {
    UIViewController *viewController = [UIApplication topViewController];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Referral" bundle:nil];
    CodeShareTableViewController* referralController = [storyboard instantiateInitialViewController];
    [viewController.navigationController pushViewController: referralController animated:YES];
}
#pragma mark - SplitViewReputation Delegate
- (void)deallocVC {
    splitViewController = nil;
}

#pragma mark - Photo Gallery Delegate
- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery
{
    if(_images == nil)
        return 0;
    
    return (int)_images.count;
}



- (NSString*)photoGallery:(GalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    if (_imageDescriptions.count==0) {
        return @"";
    }
    
    if(((int) index) < 0)
        return _imageDescriptions[0];
    else if(((int)index) > _imageDescriptions.count-1)
        return _imageDescriptions[_imageDescriptions.count - 1];
    
    return _imageDescriptions[index];
}

- (UIImage *)photoGallery:(NSUInteger)index {
    if(((int) index) < 0)
        return ((UIImageView*)_images[0]).image;
    else if(((int)index) > _images.count-1)
        return ((UIImageView*)_images[_images.count-1]).image;
    return ((UIImageView*)_images[index]).image;
}

- (NSString*)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}

-(void)popUpLuckyDeal:(LuckyDealWord*)words
{
    if ([words.notify_buyer integerValue] == 1) {
        [self showLuckyBuyer:words];
    }
    else
        [self showLuckyMerchant:words];
}

-(void)showLuckyMerchant:(LuckyDealWord*)words
{
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = words.content_merchant_1?:@"";
    NSString *line2 = words.content_merchant_2?:@"";
    NSString *line3 = words.content_merchant_3?:@"";
    NSString *urlString = words.link?:@"";
    
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(12.0f/255.0f) green:(170.0f/255.0f) blue:85.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    if ([urlString isEqualToString:@""]) {
        alertLucky.infoLabel.hidden = YES;
        alertLucky.klikDisiniButton.hidden = YES;
    }

    [alertLucky show];
    
}

-(void)showLuckyBuyer:(LuckyDealWord*)words
{
    
    AlertLuckyView *alertLucky = [AlertLuckyView new];
    NSString *line1 = words.content_buyer_1?:@"";
    NSString *line2 = words.content_buyer_2?:@"";
    NSString *line3 = words.content_buyer_3?:@"";
    NSString *urlString = words.link?:@"";
    
    alertLucky.upperView.backgroundColor = [UIColor colorWithRed:(42.0f/255.0f) green:(180.0f/255.0f) blue:193.0f/255.0f alpha:1];
    alertLucky.upperColor = alertLucky.upperView.backgroundColor;
    [alertLucky.FirstLineLabel setCustomAttributedText:line1];
    [alertLucky.secondLineLabel setCustomAttributedText:line2];
    [alertLucky.Line3Label setCustomAttributedText:line3];
    alertLucky.urlString = urlString;
    
    if ([urlString isEqualToString:@""]) {
        alertLucky.infoLabel.hidden = YES;
        alertLucky.klikDisiniButton.hidden = YES;
    }
    
    [alertLucky show];
}

+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type fromViewController:(UIViewController *)viewController
{
    TKPPlacePickerViewController *placePicker = [TKPPlacePickerViewController new];
    placePicker.firstCoordinate = location;
    placePicker.type = type;
    placePicker.delegate = viewController;
    placePicker.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:placePicker animated:YES];
}

+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type infoAddress:(AddressViewModel*)infoAddress fromViewController:(UIViewController *)viewController
{
    TKPPlacePickerViewController *placePicker = [TKPPlacePickerViewController new];
    placePicker.firstCoordinate = location;
    placePicker.type = type;
    placePicker.delegate = viewController;
    placePicker.hidesBottomBarWhenPushed = YES;
    placePicker.infoAddress = infoAddress;
//    PlacePickerViewController *placePicker = [PlacePickerViewController new];
//    placePicker.firstCoordinate = location;
//    placePicker.type = type;
//    placePicker.delegate = viewController;
    [viewController.navigationController pushViewController:placePicker animated:YES];
}

+ (NSString *)contactUsURL {
    NSString *appVersion = [UIApplication getAppVersionStringWithoutDot];
    return [NSString stringWithFormat:@"%@/contact-us?flag_app=1&utm_source=ios&app_version=%@", [NSString tokopediaUrl], appVersion];
}

+ (void)navigateToContactUsFromViewController:(UIViewController *)viewController {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    
    NSString *contactUsURL = [self contactUsURL];
    WKWebViewController *controller = [[WKWebViewController alloc] initWithUrlString:[auth webViewUrlFromUrl:contactUsURL] shouldAuthorizeRequest:YES];
    __weak typeof(WKWebViewController) *wcontroller = controller;
    
    controller.didReceiveNavigationAction = ^(WKNavigationAction* action){
        NSURL* url = action.request.URL;
        if ([url.absoluteString isEqualToString:[NSString stringWithFormat:@"%@#/", contactUsURL]]) {
            [wcontroller.navigationController popViewControllerAnimated:YES];
        }
    };
    
    controller.title = @"Tokopedia Contact";
    [viewController.navigationController pushViewController:controller animated:YES];
}

+ (void)navigateToSaldoTopupFromViewController:(UIViewController *)viewController {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *pulsaURL = @"https://pulsa.tokopedia.com/saldo/?utm_source=ios";
    
    WKWebViewController *controller = [[WKWebViewController alloc] initWithUrlString:[auth webViewUrlFromUrl:pulsaURL] shouldAuthorizeRequest:YES];
    __weak typeof(WKWebViewController) *wcontroller = controller;
    
    controller.didReceiveNavigationAction = ^(WKNavigationAction* action){
        NSURL* url = action.request.URL;
        if (action.navigationType == WKNavigationTypeBackForward && [url.host isEqualToString:@"pay.tokopedia.com"]) {
            [wcontroller.navigationController popViewControllerAnimated:YES];
        }
    };
    controller.title = @"Top Up Saldo";
    
    [viewController.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToFeedDetailFromViewController:(UIViewController *)viewController withFeedCardID:(NSString *)cardID {
    FeedDetailViewController *vc = [[FeedDetailViewController alloc] initWithActivityID:cardID];
    vc.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToAddToCartFromViewController:(UIViewController *)viewController withProductID:(NSString *)productID {
    TransactionATCViewController *vc = [TransactionATCViewController new];
    vc.productID = productID;
    vc.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:vc animated:YES];
}

- (void)navigateToOfficialBrandsFromViewController:(UIViewController*)viewController {
    OfficialStoreBrandsViewController* controller = [OfficialStoreBrandsViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    [viewController.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToOfficialPromoFromViewController:(UIViewController*)viewController withSlug:(NSString*)slug {
    OfficialStorePromoViewController* controller = [OfficialStorePromoViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    controller.promoSlug = slug;
    [viewController.navigationController pushViewController:controller animated:YES];
}

#pragma - Common Method 

-(NSString *) getTitleFromData: (NSDictionary *) data {
    NSString *title = @"";
    if ([data objectForKey:@"q"]) {
        title = [[data objectForKey:@"q"] capitalizedString];
    } else if ([data objectForKey:@"department_1"]) {
        title = [[data objectForKey:@"department_1"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        title = [title capitalizedString];
    }
    
    return title;
}

// only for non shop view controller
-(NSDictionary *) addDataTypeFromData: (NSDictionary *)data {
    NSMutableDictionary *datas = [NSMutableDictionary new];
    [datas addEntriesFromDictionary:data];
    [datas setObject:[NSString stringWithFormat:@"search_%@",[data objectForKey:@"st"]]?:@"" forKey:@"type"];
    
    return [datas copy];
}

+ (void)navigateToMaintenanceViewController {
    MaintenanceViewController *viewController = [MaintenanceViewController new];
    viewController.hidesBottomBarWhenPushed = YES;
    UIViewController * topViewController = [UIApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    [topViewController.navigationController pushViewController:viewController animated:YES];
}

+ (void)navigateToAccountActivationSuccess {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    NSString *name = [userManager getUserFullName];
    
    AccountActivationSuccessViewController *vc = [[AccountActivationSuccessViewController alloc] initWithName:name];
    
    UIViewController * topViewController = [UIApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    [topViewController.navigationController presentViewController:vc animated:YES completion:nil];
}

@end
