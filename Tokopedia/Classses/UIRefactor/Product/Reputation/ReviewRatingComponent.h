//
//  ReviewRatingComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "DetailReputationReview.h"
#import "ImageStorage.h"

@interface ReviewRatingComponent : CKCompositeComponent

+ (instancetype)newWithReview:(DetailReputationReview*)review
                   imageCache:(ImageStorage*)imageCache;

@end
