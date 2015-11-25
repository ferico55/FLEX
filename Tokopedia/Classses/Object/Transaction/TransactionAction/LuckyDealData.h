//
//  LuckyDealData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyDealAttributes.h"

@interface LuckyDealData : NSObject <TKPObjectMapping>

@property NSInteger ld_id;
@property NSInteger type;
@property (strong, nonatomic) LuckyDealAttributes *attributes;

@end
