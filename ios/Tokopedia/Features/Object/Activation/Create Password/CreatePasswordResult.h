//
//  CreatePasswordResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreatePasswordResult : NSObject

@property (strong, nonatomic, nonnull) NSString *is_success;

+ (RKObjectMapping *_Nonnull)mapping;

@end
