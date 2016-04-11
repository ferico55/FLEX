//
//  ShopReputation.h
//  Tokopedia
//
//  Created by Tokopedia on 7/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopBadgeLevel.h"
#define CToolTip @"tooltip"
#define CReputationBadge @"reputation_badge"
#define CReputationScore @"reputation_score"
#define CScore @"score"
#define CMinBadgeScore @"min_badge_score"
#define CReputationBadgeObject @"reputation_badge_object"

@interface ShopReputation : NSObject <TKPObjectMapping>
@property (nonatomic, strong) NSString *tooltip;
@property (nonatomic, strong) NSString *reputation_score;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *min_badge_score;
@property (nonatomic, strong) ShopBadgeLevel *reputation_badge_object;
@property (nonatomic, strong) ShopBadgeLevel *reputation_badge;
@end
