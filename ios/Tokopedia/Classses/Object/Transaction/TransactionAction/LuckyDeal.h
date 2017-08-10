//
//  LuckyDeal.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyDealData.h"
#import "LuckyDealAttributes.h"

@interface LuckyDeal : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *url;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) LuckyDealData *data;

@end
