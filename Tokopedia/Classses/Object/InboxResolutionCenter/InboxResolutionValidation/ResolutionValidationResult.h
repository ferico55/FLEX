//
//  ResolutionValidationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TKPObjectMapping.h"

@interface ResolutionValidationResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *file_uploaded;

@end
