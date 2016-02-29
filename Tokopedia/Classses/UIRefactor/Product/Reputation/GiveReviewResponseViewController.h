//
//  GiveReviewResponseViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyInboxReputation.h"
#import "DetailReputationReview.h"

@interface GiveReviewResponseViewController : UIViewController

@property (nonatomic, weak) DetailMyInboxReputation *inbox;
@property (nonatomic, weak) DetailReputationReview *review;

@end
