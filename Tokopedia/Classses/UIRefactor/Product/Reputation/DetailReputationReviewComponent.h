//
//  DetailReputationReviewComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CKCompositeComponent.h"
#import "DetailReputationReview.h"
#import <ComponentKit/ComponentKit.h>

@interface DetailReputationReviewComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review;
@end
