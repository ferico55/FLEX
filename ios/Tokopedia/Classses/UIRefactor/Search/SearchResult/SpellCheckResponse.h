//
//  SpellCheckResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 10/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellCheckResult.h"

@interface SpellCheckResponse : NSObject

@property (nonatomic, strong) NSArray *config;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) SpellCheckResult *data;

+(RKObjectMapping*)mapping;

@end
