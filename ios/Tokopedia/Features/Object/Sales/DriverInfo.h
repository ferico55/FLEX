//
//  DriverInfo.h
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 8/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverInfo : NSObject

@property (strong, nonatomic, nonnull) NSString *license_number;
@property (strong, nonatomic, nonnull) NSString *driver_name;
@property (strong, nonatomic, nonnull) NSString *driver_phone;
@property (strong, nonatomic, nonnull) NSString *driver_photo;

+(RKObjectMapping*_Nonnull)mapping;

@end
