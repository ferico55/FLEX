//
//  DetailReputationReviewComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReviewComponent.h"
#import <ComponentKit/ComponentKit.h>

@implementation DetailReputationReviewComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review {
    UIColor* buttonColor = [UIColor colorWithRed:18.0/255
                                           green:199.0/255
                                            blue:0
                                           alpha:1];
    
    return [super newWithComponent:
            [CKInsetComponent
             newWithView:{}
             insets:{8, 8, 8, 8}
             component:
                 [CKStackLayoutComponent
                  newWithView:{
                      [UIView class],
                      {
                          {@selector(setBackgroundColor:), [UIColor whiteColor]}
                      }
                  }
                  size:{}
                  style:{
                      .direction = CKStackLayoutDirectionVertical,
                      .alignItems = CKStackLayoutAlignItemsStretch,
                      .justifyContent = CKStackLayoutJustifyContentCenter
                  }
                  children:{
                      {
                          //header
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
                                     newWithImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
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
                                         .spacing = 3
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
                                             [CKLabelComponent
                                              newWithLabelAttributes:{
                                                  .string = review.review_response.response_create_time,
                                                  .font = [UIFont fontWithName:@"Gotham Book" size:12],
                                                  .lineBreakMode = NSLineBreakByTruncatingMiddle,
                                                  .maximumNumberOfLines = 1,
                                                  .color = [UIColor colorWithWhite:179.0/255 alpha:1]
                                              }
                                              viewAttributes:{}
                                              size:{}]
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
                            }]]
                      },
                      {
                          [CKButtonComponent
                           newWithTitles:{
                               {UIControlStateNormal, @"Beri Ulasan"}
                           }
                           titleColors:{
                               {UIControlStateNormal, buttonColor}
                           }
                           images:{}
                           backgroundImages:{}
                           titleFont:[UIFont fontWithName:@"Gotham Medium" size:14.0]
                           selected:NO
                           enabled:YES
                           action:nil
                           size:{.height = 30}
                           attributes:{
                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                               {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[buttonColor CGColor]},
                               {@selector(setClipsToBounds:), YES},
                               {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
                           }
                           accessibilityConfiguration:{}],
                          .flexGrow = YES
                      },
                  }]
             ]];
}
@end
