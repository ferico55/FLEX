//
//  NavigateViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigateViewController : NSObject

-(void)navigateToProfileFromViewController:(UIViewController*)viewController withUserID:(NSString *)userID;
-(void)navigateToShopFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToInvoiceFromViewController:(UIViewController*)viewController withInvoiceURL:(NSString *)invoiceURL;
-(void)navigateToShowImageFromViewController:(UIViewController *)viewController withImageDictionaries:(NSArray*)images imageDescriptions:(NSArray*)imageDesc indexImage:(NSInteger)index;

- (void)navigateToProductFromViewController:(UIViewController *)viewController withName:(NSString*)name withPrice:(NSString*)price withId:(NSString*)productId withImageurl:(NSString*)url withShopName:(NSString*)shopName;
- (void)navigateToCatalogFromViewController:(UIViewController *)viewController withCatalogID:(NSString *)catalogID andCatalogKey:(NSString*)key;

- (void)navigateToShopFromViewController:(UIViewController*)viewController withShopName:(NSString*)shopName;
- (void)navigateToProductFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToHotlistResultFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToSearchFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;

- (void)navigateToProductFromViewController:(UIViewController *)viewController
                                  promoData:(NSDictionary *)data
                                productData:(NSDictionary *)productData;

#pragma mark - Inbox
- (void)navigateToInboxMessageFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxTalkFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController withGetDataFromMasterDB:(BOOL)getDataFromMaster;
- (void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxPriceAlertFromViewController:(UIViewController*)viewController;

@end
