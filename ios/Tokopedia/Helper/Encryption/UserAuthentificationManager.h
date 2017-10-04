//
//  UserAuthentification.h
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReputationDetail.h"
#import "ShopType.h"

@class ListOption;

@interface UserAuthentificationManager : NSObject {
    id userLoginData;
    NSString *_userId;
    NSString *_userShop;
}

@property (nonatomic) BOOL isLogin;
@property (readonly) ShopType shopType;
@property (nonatomic, getter=isOfficialStore, readonly) BOOL officialStore;

- (null_unspecified NSDictionary *)getUserLoginData;
- (null_unspecified NSString*)getUserId;
- (null_unspecified NSString*)getUserEmail;
- (nullable NSString*)getUserFullName;
- (nullable NSString*)getUserShortName;
- (nullable NSString*)getUserPhoneNumber;
- (null_unspecified NSString*)getShopId;
- (null_unspecified NSString*)getShopName;
- (null_unspecified NSString*)getShopHasTerm;
- (null_unspecified ListOption *)getLastProductAddCategory;
- (nonnull NSString*)getMyDeviceToken;
- (BOOL)isMyShopWithShopId:(nonnull NSString*)shopId;
- (BOOL)isMyUser:(nonnull NSString*)userId;
- (nonnull NSString *)addParameterAndConvertToString:(nonnull id)params;
- (nonnull NSDictionary *)autoAddParameter:(nonnull id)params ;

- (void)setUserImage:(nonnull NSString *)userImage;

- (null_unspecified ReputationDetail *)reputation;
- (BOOL)isUserPhoneVerified;

+ (void)ensureDeviceIdExistence;
+ (void)trackAppLocation;
- (BOOL)userHasShop;
- (nonnull NSString*)userLatitude;
- (nonnull NSString*)userLongitude;
- (BOOL)userIsGoldMerchant;
- (nonnull NSString *)webViewUrlFromUrl:(nonnull NSString *)url;

- (nullable NSString*)getDOB;
- (nullable NSString*)getCity;
- (nullable NSString*)getProvince;
- (nullable NSString*)getRegistrationDate;
- (nullable NSNumber*)getTotalItemSold;
- (nullable NSString*)getShopLocation;
- (nullable NSString*)getDateShopCreated;
- (nullable NSDate*) convertStringToDateWithLocaleID:(nonnull NSString*) str;
- (BOOL)userIsSeller;
- (nullable NSString *)getGender;
- (BOOL)userIsTokocashActive;
- (nullable NSString *)getTokocashAmount;
- (nullable NSString *)getSaldoAmount;
- (nullable NSString *)getTopAdsAmount;
- (BOOL)userIsTopAdsUser;
- (BOOL)userHasPurchasedMarketplace;
- (BOOL)userHasPurchasedDigital;
- (BOOL)userHasPurchasedTicket;
- (nullable NSString *)getLastTransactionDate;
- (nonnull NSNumber *)getTotalActiveProduct;
- (nonnull NSNumber *)getShopScore;
@end
