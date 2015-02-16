//
//  UserAuthentification.h
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAuthentificationManager : NSObject {
    BOOL _isLogin;
    id userLoginData;
    NSString *_userId;
    NSString *_userShop;
}


- (id)getUserLoginData;
- (NSString*)getUserId;
- (NSString*)getShopId;
- (void)setUserLoginData:(id)loginData;
- (NSString*)addParameterAndConvertToString:(id)params;

@end    
