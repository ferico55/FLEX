//
//  ReviewRatingComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewRatingComponent.h"
#import "RatingComponent.h"

@implementation ReviewRatingComponent

+ (instancetype)newWithReview:(DetailReputationReview*)review imageCache:(ImageStorage *)imageCache {
    if ([review.review_message isEqualToString:@"0"] || review.review_message == nil) {
        return nil;
    }
    
    return [super newWithComponent:
            [CKInsetComponent
             newWithInsets:{0,8,0,8}
             component:
             [CKStackLayoutComponent
              newWithView:{}
              size:{.height = 38}
              style:{
                  .direction = CKStackLayoutDirectionHorizontal,
                  .alignItems = CKStackLayoutAlignItemsStretch
              }
              children:
              {
                  {
                      [CKStackLayoutComponent
                       newWithView:{}
                       size:{}
                       style:{
                           .direction = CKStackLayoutDirectionHorizontal,
                           .alignItems = CKStackLayoutAlignItemsCenter,
                           .spacing = 5
                       }
                       children:
                       {
                           {
                               [CKLabelComponent
                                newWithLabelAttributes:{
                                    .string = @"Kualitas",
                                    .font = [UIFont fontWithName:@"Gotham Book" size:12]
                                }
                                viewAttributes:{}
                                size:{}]
                           },
                           {
                               [RatingComponent newWithRating:[review.product_rating_point intValue] imageCache:imageCache]
                           }
                       }],
                      .flexBasis = CKRelativeDimension::Percent(0.5)
                  },
                  {
                      [CKStackLayoutComponent
                       newWithView:{}
                       size:{}
                       style:{
                           .direction = CKStackLayoutDirectionHorizontal,
                           .alignItems = CKStackLayoutAlignItemsCenter,
                           .justifyContent = CKStackLayoutJustifyContentEnd,
                           .spacing = 5
                       }
                       children:
                       {
                           {
                               [CKLabelComponent
                                newWithLabelAttributes:{
                                    .string = @"Akurasi",
                                    .font = [UIFont fontWithName:@"Gotham Book" size:12]
                                }
                                viewAttributes:{}
                                size:{}]
                           },
                           {
                               [RatingComponent newWithRating:[review.product_accuracy_point intValue] imageCache:imageCache]
                           }
                       }],
                      .flexBasis = CKRelativeDimension::Percent(0.5)
                  }
              }]]];
}

@end
