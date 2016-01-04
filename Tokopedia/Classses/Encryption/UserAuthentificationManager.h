//
//  UserAuthentification.h
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Breadcrumb.h"
#import "ReputationDetail.h"

@interface UserAuthentificationManager : NSObject {
    id userLoginData;
    NSString *_userId;
    NSString *_userShop;
}

@property (nonatomic) BOOL isLogin;

- (id)getUserLoginData;
- (NSString*)getUserId;
- (NSString*)getShopId;
- (NSString*)getShopName;
- (NSString*)getShopHasTerm;
- (Breadcrumb*)getLastProductAddCategory;
- (NSString*)getMyDeviceToken;
- (NSString*)getMyDeviceIdToken;
- (BOOL)isMyShopWithShopId:(NSString*)shopId;
- (BOOL)isMyUser:(NSString*)userId;
- (NSString *)addParameterAndConvertToString:(id)params;
- (NSDictionary *)autoAddParameter:(id)params ;

- (void)setUserImage:(NSString *)userImage;

- (ReputationDetail *)reputation;

@end
