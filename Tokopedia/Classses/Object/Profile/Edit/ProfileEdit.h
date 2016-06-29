//
//  ProfileEdit.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProfileEditResult.h"

@interface ProfileEdit : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ProfileEditResult *result;

+ (NSDictionary *)attributeMappingDictionary;
+ (RKObjectMapping *)mapping;

@end
