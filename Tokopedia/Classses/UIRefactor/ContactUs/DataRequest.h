//
//  DataRequest.h
//  Tokopedia
//
//  Created by Tokopedia on 9/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenerateHost.h"

@interface DataRequest : NSObject

@property (nonatomic, strong) RKResponseDescriptor *responseDescriptor;
@property (nonatomic, strong) NSDictionary *parameters;

+ (void)requestWithParameters:(NSDictionary *)parameters
                  pathPattern:(NSString *)pathPattern
                         host:(GeneratedHost *)host
           responseDescriptor:(RKResponseDescriptor *)responseDescriptor
                   completion:(void (^)(id))completionBlock;

@end
