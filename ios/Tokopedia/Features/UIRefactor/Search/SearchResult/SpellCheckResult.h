//
//  SpellCheckResult.h
//  Tokopedia
//
//  Created by Tokopedia on 10/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpellCheckResult : NSObject

@property (strong, nonatomic) NSString *suggest;
@property (strong, nonatomic) NSString *total_data;

+ (RKObjectMapping*)mapping;

@end