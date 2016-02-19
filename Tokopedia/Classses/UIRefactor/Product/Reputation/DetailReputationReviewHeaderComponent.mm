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

static CKComponent* skipButton (DetailReputationReview* review) {
    if ([review.review_is_skipable isEqualToString:@"1"]) {
        return [CKButtonComponent
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
                accessibilityConfiguration:{}];
    }
    
    return nil;
}

@implementation DetailReputationReviewHeaderComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review tapAction:(SEL)action imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader {
    return [super newWithComponent:
            [CKInsetComponent
             newWithInsets:{8,8,8,8}
             component:
             [CKStackLayoutComponent
              newWithView:{
                  [UIView class],
                  {
                      {CKComponentTapGestureAttribute(action)}
                  }
              }
              size:{}
              style:{
                  .direction = CKStackLayoutDirectionHorizontal,
                  .spacing = 8
              }
              children:{
                  {
                      [CKNetworkImageComponent
                       newWithURL:[NSURL URLWithString:review.product_image]
                       imageDownloader:imageDownloader
                       scenePath:nil
                       size:{50,50}
                       options:{
                           .defaultImage = [UIImage imageNamed:@"icon_toped_loading_grey.png"]
                       }
                       attributes:{}]
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
                      skipButton(review)
                  }
              }]]];
}
@end
