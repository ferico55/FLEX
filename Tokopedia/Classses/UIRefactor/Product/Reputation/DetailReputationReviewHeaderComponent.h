//
//  DetailReputationReviewHeaderComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"
#import <ComponentKit/ComponentKit.h>

@interface DetailReputationReviewHeaderComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review;
@end
