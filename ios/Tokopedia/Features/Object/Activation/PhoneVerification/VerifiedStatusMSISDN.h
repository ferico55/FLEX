//
//  VerifiedStatusMSISDN.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VerifiedStatusMSISDN : NSObject
@property(strong, nonatomic, nonnull) NSString* show_dialog;
@property(strong, nonatomic, nonnull) NSString* user_phone;
@property(strong, nonatomic, nonnull) NSString* is_verified;

+ (RKObjectMapping *_Nonnull)mapping;

@end
