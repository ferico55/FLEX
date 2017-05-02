//
//  TKPObjectMapping.h
//  Tokopedia
//
//  Created by Harshad Dange on 15/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@protocol TKPObjectMapping <NSObject>

+ (RKObjectMapping *)mapping;

@optional
+ (NSDictionary *)attributeMappingDictionary;

@end
