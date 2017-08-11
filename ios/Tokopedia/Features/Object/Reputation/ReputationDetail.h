//
//  DepositInfo.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReputationDetail : NSObject
@property (nonatomic, strong) NSString *positive_percentage;
@property (nonatomic, strong) NSString *negative;
@property (nonatomic, strong) NSString *positive;
@property (nonatomic, strong) NSString *neutral;
@property (nonatomic, strong) NSString *no_reputation;

+ (RKObjectMapping*) mapping;

@end
