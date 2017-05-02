//
//  UploadImageHelperResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface UploadImageHelperResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *file_uploaded;
@property (nonatomic, strong) NSString *is_success;

@end
