//
//  GiveReviewResponseViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyInboxReputation.h"
#import "DetailReputationReview.h"
#import "ImageStorage.h"

@interface GiveReviewResponseViewController : UIViewController

@property (nonatomic, weak) DetailMyInboxReputation *inbox;
@property (nonatomic, weak) DetailReputationReview *review;
@property (nonatomic, weak) ImageStorage *imageCache;

@end
