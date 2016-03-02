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

static CKComponent* button(DetailReputationReview *review, SEL buttonAction, NSString *role) {
    if ([role isEqualToString:@"1"]) {
        if (![review.review_is_allow_edit isEqualToString:@"1"]) {
            return nil;
        }
        
        return [CKButtonComponent
                newWithTitles:{}
                titleColors:{}
                images:{
                    {UIControlStateNormal, [UIImage imageNamed:@"icon_arrow_down.png"]}
                }
                backgroundImages:{}
                titleFont:nil
                selected:NO
                enabled:YES
                action:buttonAction
                size:{.height = 14, .width = 14}
                attributes:{}
                accessibilityConfiguration:{}];
    } else {
        if ([review.review_message isEqualToString:@"0"]) {
            return nil;
        }
        return [CKButtonComponent
                newWithTitles:{}
                titleColors:{}
                images:{
                    {UIControlStateNormal, [UIImage imageNamed:@"icon_arrow_down.png"]}
                }
                backgroundImages:{}
                titleFont:nil
                selected:NO
                enabled:YES
                action:buttonAction
                size:{.height = 14, .width = 14}
                attributes:{}
                accessibilityConfiguration:{}];
    }
}

@implementation DetailReputationReviewHeaderComponent

+ (instancetype)newWithReview:(DetailReputationReview*)review
                         role:(NSString*)role
           tapToProductAction:(SEL)action
              tapButtonAction:(SEL)buttonAction
              imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader {
    return [super newWithComponent:
            [CKStackLayoutComponent
             newWithView:{}
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
                          [UIView class],
                          {
                              {CKComponentTapGestureAttribute(action)}
                          }
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
                     button(review, buttonAction, role),
                     .alignSelf = CKStackLayoutAlignSelfStart
                 }
             }]];
}
@end
