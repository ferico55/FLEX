//
//  ATCShopOrigin.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATCShopOrigin : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *is_gojek;
@property (nonatomic, strong, nonnull) NSString *longitude;
@property (nonatomic, strong, nonnull) NSString *origin_id;
@property (nonatomic, strong, nonnull) NSString *device;
@property (nonatomic, strong, nonnull) NSString *origin_postal;
@property (nonatomic, strong, nonnull) NSString *ut;
@property (nonatomic, strong, nonnull) NSString *is_ninja;
@property (nonatomic, strong, nonnull) NSString *from;
@property (nonatomic, strong, nonnull) NSString *latitude;
@property (nonatomic, strong, nonnull) NSString *show_oke;
@property (nonatomic, strong, nonnull) NSString *token;
@property (nonatomic, strong, nonnull) NSString *avail_shipping_code;
@property (nonatomic, strong, nonnull) NSString *name;

@end
