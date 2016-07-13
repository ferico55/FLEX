//
//  ProfileEditResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataUser.h"

@interface ProfileEditResult : NSObject

@property (nonatomic, strong) DataUser *data_user;

+(RKObjectMapping*)mapping;
@end
