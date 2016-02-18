//
//  DetailReputationReviewHeaderComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReviewHeaderComponent.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* timestampLabel(NSString* createTime) {
    if (![createTime boolValue]) {
        return nil;
    }
    
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = createTime,
                .font = [UIFont fontWithName:@"Gotham Book" size:12],
                .lineBreakMode = NSLineBreakByTruncatingMiddle,
                .maximumNumberOfLines = 1,
                .color = [UIColor colorWithWhite:179.0/255 alpha:1]
            }
            viewAttributes:{}
            size:{}];
}

@implementation DetailReputationReviewHeaderComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review {
    return [super newWithComponent:
            [CKInsetComponent
             newWithInsets:{8,8,8,8}
             component:
             [CKStackLayoutComponent
              newWithView:{}
              size:{}
              style:{
                  .direction = CKStackLayoutDirectionHorizontal,
                  .spacing = 8
              }
              children:{
                  {
                      [CKImageComponent
                       newWithImage:[UIImage imageNamed:@"icon_toped_loading_grey.png"]
                       size:{50,50}]
                  },
                  {
                      [CKStackLayoutComponent
                       newWithView:{
                           
                       }
                       size:{}
                       style:{
                           .direction = CKStackLayoutDirectionVertical,
                           .justifyContent = CKStackLayoutJustifyContentCenter,
                           .spacing = 5
                       }
                       children:
                       {
                           {
                               [CKLabelComponent
                                newWithLabelAttributes:{
                                    .string = review.product_name,
                                    .font = [UIFont fontWithName:@"Gotham Medium" size:14],
                                    .lineBreakMode = NSLineBreakByTruncatingMiddle,
                                    .maximumNumberOfLines = 1
                                }
                                viewAttributes:{}
                                size:{}],
                           },
                           {
                               timestampLabel(review.review_response.response_create_time)
                           }
                       }],
                      .flexGrow = YES,
                      .flexShrink = YES,
                      .alignSelf = CKStackLayoutAlignSelfStretch
                  },
                  {
                      [CKButtonComponent
                       newWithTitles:{}
                       titleColors:{}
                       images:{
                           {UIControlStateNormal, [UIImage imageNamed:@"icon_cancel.png"]}
                       }
                       backgroundImages:{}
                       titleFont:nil
                       selected:NO
                       enabled:YES
                       action:nil
                       size:{.height = 30}
                       attributes:{
                           
                       }
                       accessibilityConfiguration:{}]
                  }
              }]]];
}
@end
