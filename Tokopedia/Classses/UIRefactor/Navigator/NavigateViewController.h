//
//  NavigateViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "HistoryProduct.h"

@class AddressViewModel;
@class TKPPlacePickerViewController;
@class LuckyDealWord;
@class SearchAWSProduct;

@interface NavigateViewController : NSObject

-(void)navigateToProfileFromViewController:(UIViewController*)viewController withUserID:(NSString *)userID;
-(void)navigateToShopFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;

-(void)navigateToShowImageFromViewController:(UIViewController *)viewController withImageDictionaries:(NSArray*)images imageDescriptions:(NSArray*)imageDesc indexImage:(NSInteger)index;
- (void)navigateToProductFromViewController:(UIViewController *)viewController withName:(NSString*)name withPrice:(NSString*)price withId:(NSString*)productId withImageurl:(NSString*)url withShopName:(NSString*)shopName;
- (void)navigateToCatalogFromViewController:(UIViewController *)viewController withCatalogID:(NSString *)catalogID andCatalogKey:(NSString*)key;

- (void)navigateToShopFromViewController:(UIViewController*)viewController withShopName:(NSString*)shopName;
- (void)navigateToProductFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToHotlistResultFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToCategoryFromViewController:(UIViewController *)viewController withCategoryId:(NSString *) categoryId categoryName:(NSString *) categoryName;
- (void)navigateToSearchFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToSearchFromViewController:(UIViewController *)viewController withURL:(NSURL*)url;


- (void)navigateToProductFromViewController:(UIViewController *)viewController
                                  promoData:(NSDictionary *)data
                                productData:(NSDictionary *)productData;
- (void)navigateToProductFromViewController:(UIViewController *)viewController withProduct:(SearchAWSProduct *)product;

-(void)popUpLuckyDeal:(LuckyDealWord*)words;
+(void)navigateToInvoiceFromViewController:(UIViewController *)viewController withInvoiceURL:(NSString *)invoiceURL;

+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type infoAddress:(AddressViewModel*)infoAddress fromViewController:(UIViewController *)viewController;
+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type fromViewController:(UIViewController *)viewController;
+ (void)navigateToProductFromViewController:(UIViewController *)viewController withName:(NSString*)name withPrice:(NSString*)price withId:(NSString*)productId withImageurl:(NSString*)url withShopName:(NSString*)shopName;
+(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID;
+ (void)navigateToContactUsFromViewController:(UIViewController *)viewController;
+ (void)navigateToSaldoTopupFromViewController:(UIViewController *)viewController;
+ (void)navigateToProductFromViewController:(UIViewController *)viewController withProduct:(id)product;
+ (void)navigateToProductFromViewController:(UIViewController *)viewController withProduct:(id)objProduct withShopName:(NSString*)shopName;

#pragma mark - Inbox
- (void)navigateToInboxMessageFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxTalkFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController withGetDataFromMasterDB:(BOOL)getDataFromMaster;
- (void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController;
-(void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController atIndex:(int)index;
- (void)navigateToInboxPriceAlertFromViewController:(UIViewController*)viewController;
@end
