//
//  UploadImageParams.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UploadImage.h"
#import <Foundation/Foundation.h>

@interface UploadImageParams : NSObject

@property (nonatomic, strong, nonnull) NSString *action;
@property (nonatomic, strong, nonnull) NSNumber *user_id;
@property (nonatomic, strong, nonnull) NSNumber *server_id;

@end
