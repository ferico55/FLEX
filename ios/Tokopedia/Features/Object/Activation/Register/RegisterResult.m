//
//  RegisterResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "Register.h"
#import "RegisterResult.h"

@implementation RegisterResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[RegisterResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDREGISTER_APIISACTIVEKEY:kTKPDREGISTER_APIISACTIVEKEY,
                                                        kTKPDREGISTER_APIUIKEY:kTKPDREGISTER_APIUIKEY,
                                                        @"action":@"action"
                                                        }];
    return resultMapping;
}
@end
