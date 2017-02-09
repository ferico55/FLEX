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

@class CategoryDetail;

@interface UserAuthentificationManager : NSObject {
    id userLoginData;
    NSString *_userId;
    NSString *_userShop;
}

@property (nonatomic) BOOL isLogin;
@property (readonly) ShopType shopType;
@property (nonatomic, getter=isOfficialStore, readonly) BOOL officialStore;

- (id)getUserLoginData;
- (NSString*)getUserId;
- (NSString*)getShopId;
- (NSString*)getShopName;
- (NSString*)getShopHasTerm;
- (CategoryDetail *)getLastProductAddCategory;
- (NSString*)getMyDeviceToken;
- (BOOL)isMyShopWithShopId:(NSString*)shopId;
- (BOOL)isMyUser:(NSString*)userId;
- (NSString *)addParameterAndConvertToString:(id)params;
- (NSDictionary *)autoAddParameter:(id)params ;

- (void)setUserImage:(NSString *)userImage;

- (ReputationDetail *)reputation;
- (BOOL)isUserPhoneVerified;

+ (void)ensureDeviceIdExistence;
- (BOOL)userHasShop;
- (NSString *)webViewUrlFromUrl:(NSString *)url;

@end
