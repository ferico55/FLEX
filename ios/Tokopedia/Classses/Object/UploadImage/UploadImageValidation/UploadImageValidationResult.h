//
//  UploadImageValidationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface UploadImageValidationResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *post_key;
@property (nonatomic, strong, nonnull) NSString *is_success;

@end
