//
//  DepositInfoResult.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepositResult : NSObject

@property (nonatomic, strong, nonnull) NSString *deposit_total;

+ (RKObjectMapping *_Nonnull)mapping;

@end
