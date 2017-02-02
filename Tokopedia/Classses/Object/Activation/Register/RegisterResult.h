//
//  RegisterResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterResult : NSObject

@property (nonatomic, strong) NSString *is_active;
@property (nonatomic, strong) NSString *u_id;
@property NSInteger action;

+ (RKObjectMapping *)mapping;
@end
