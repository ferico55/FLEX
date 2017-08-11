//
//  ProfileEditFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileEditFormResult : NSObject

@property (strong, nonatomic) NSString *is_success;

+(RKObjectMapping*)mapping;

@end
