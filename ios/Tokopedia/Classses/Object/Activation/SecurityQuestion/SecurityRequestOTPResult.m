//
//  SecurityRequestOTPResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityRequestOTPResult.h"

@implementation SecurityRequestOTPResult

+(RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"is_success"]];
    
    return mapping;
}
@end
