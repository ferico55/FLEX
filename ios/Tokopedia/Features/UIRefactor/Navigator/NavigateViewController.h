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
#import "ProductCell.h"

@class AddressViewModel;
@class TKPPlacePickerViewController;
@class LuckyDealWord;
@class SearchAWSProduct;
@class CategoryDataForCategoryResultVC;

@interface NavigateViewController : NSObject

+(void)navigateToMaintenanceViewController;
+ (void)navigateToAccountActivationSuccess;

+ (void)navigateToProductFromViewController:(UIViewController *)viewController
                              withProductID:(NSString *)productID
                                    andName:(NSString *)name
                                   andPrice:(NSString *)price
                                andImageURL:(NSString *)imageURL
                                andShopName:(NSString *)shopName;

-(void)navigateToInboxTalkFromViewController:(UIViewController *)viewController withTalkId:(NSString *)talkId;

-(void)navigateToProfileFromViewController:(UIViewController*)viewController withUserID:(NSString *)userID;
-(void)navigateToShopFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToShopFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID withEtalaseId:(NSString *)etalaseId;
-(void)navigateToShopFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID withEtalaseId:(NSString *)etalaseId search:(NSString *)keyword sort:(NSString *)by;
-(void)navigateToShopInfoFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToShopTalkFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToShopReviewFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToShopNoteFromViewController:(UIViewController*)viewController withShopID:(NSString *)shopID;
-(void)navigateToCartFromViewController:(UIViewController*)viewController;

-(void)navigateToSellerNewOrderFromViewController:(UIViewController*)viewController;
-(void)navigateToSellerShipmentFromViewController:(UIViewController*)viewController;
-(void)navigateToSellerShipmentStatusFromViewController:(UIViewController*)viewController;
-(void)navigateToSellerHistoryFromViewController:(UIViewController*)viewController;

-(void)navigateToBuyerPaymentFromViewController:(UIViewController*)viewController;
-(void)navigateToBuyerOrderFromViewController:(UIViewController*)viewController;
-(void)navigateToBuyerShippingConfFromViewController:(UIViewController*)viewController;
-(void)navigateToBuyerHistoryFromViewController:(UIViewController*)viewController;

-(void)navigateToHotListFromViewController:(UIViewController*)viewController;
-(void)navigateToShowImageFromViewController:(UIViewController *)viewController withImageDictionaries:(NSArray*)images imageDescriptions:(NSArray*)imageDesc indexImage:(NSInteger)index;
- (void)navigateToCatalogFromViewController:(UIViewController *)viewController withCatalogID:(NSString *)catalogID;

- (void)navigateToShopFromViewController:(UIViewController*)viewController withShopName:(NSString*)shopName;

- (void)navigateToHotlistResultFromViewController:(UIViewController*)viewController withData:(NSDictionary*)data;
- (void)navigateToPromoDetailFromViewController:(UIViewController*) viewController withName:(NSString*) promoName;

- (void)navigateToIntermediaryCategoryFromViewController:(UIViewController *)viewController withCategoryId:(NSString *) categoryId categoryName:(NSString *) categoryName isIntermediary:(BOOL) isIntermediary;
- (void)navigateToIntermediaryCategoryFromViewController:(UIViewController *)viewController withData:(CategoryDataForCategoryResultVC*)data withFilterParams:(NSDictionary *) filterParams;

- (void)navigateToSearchFromViewController:(UIViewController *)viewController withURL:(NSURL*)url;

-(void)popUpLuckyDeal:(LuckyDealWord*)words;
+(void)navigateToInvoiceFromViewController:(UIViewController *)viewController withInvoiceURL:(NSString *)invoiceURL;

+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type infoAddress:(AddressViewModel*)infoAddress fromViewController:(UIViewController *)viewController;
+(void)navigateToMap:(CLLocationCoordinate2D)location type:(NSInteger)type fromViewController:(UIViewController *)viewController;
+(void)navigateToShopFromViewController:(UIViewController *)viewController withShopID:(NSString *)shopID;
+ (void)navigateToContactUsFromViewController:(UIViewController *)viewController;
+ (void)navigateToSaldoTopupFromViewController:(UIViewController *)viewController;
- (void)navigateToAddProductFromViewController:(UIViewController*)viewController;

- (void)navigateToFeedDetailFromViewController:(UIViewController *) viewController withFeedCardID:(NSString *) cardID;
- (void)navigateToAddToCartFromViewController:(UIViewController *)viewController withProductID:(NSString *)productID;
- (void)navigateToOfficialBrandsFromViewController:(UIViewController*)viewController withFilterParams:(NSDictionary *) filterParams;
- (void)navigateToOfficialPromoFromViewController:(UIViewController*)viewController withSlug:(NSString*)slug;
+ (void)navigateToReferralWelcomeWithData:(NSDictionary*)data;
+ (void)navigateToReferralScreen;

#pragma mark - Inbox
- (void)navigateToInboxTalkFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController;
- (void)navigateToInboxReviewFromViewController:(UIViewController *)viewController withGetDataFromMasterDB:(BOOL)getDataFromMaster;
- (void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController;
-(void)navigateToInboxResolutionFromViewController:(UIViewController *)viewController atIndex:(int)index;
@end
