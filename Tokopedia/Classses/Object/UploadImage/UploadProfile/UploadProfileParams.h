//
//  UploadProfileParams.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import <Foundation/Foundation.h>

@interface UploadProfileParams : NSObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *server_id;

@end
