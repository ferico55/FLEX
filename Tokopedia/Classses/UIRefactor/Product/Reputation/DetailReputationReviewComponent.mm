//
//  DetailReputationReviewComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReviewComponent.h"
#import "DetailReputationReviewHeaderComponent.h"
#import "RatingComponent.h"
#import "ReviewResponseComponent.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* messageLabel(NSString* message) {
    if (![message boolValue]) {
        return nil;
    }
    
    return [CKInsetComponent
            newWithInsets:{8,8,8,8}
            component:
            [CKLabelComponent
             newWithLabelAttributes:{
                 .string = message,
                 .font = [UIFont fontWithName:@"Gotham Book" size:14],
                 .maximumNumberOfLines = 0,
                 .lineSpacing = 0.6
             }
             viewAttributes:{}
             size:{}]];
}

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
                      [DetailReputationReviewHeaderComponent newWithReview:review]
                  },
                  {
                      messageLabel(review.review_message)
                  },
                  {
                      [CKComponent
                       newWithView:{
                           [UIView class],
                           {{@selector(setBackgroundColor:),[UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4]}}
                       }
                       size:{.height = 1, .width = CKRelativeDimension::Percent(.95)}],
                      .alignSelf = CKStackLayoutAlignSelfCenter
                  },
                  {
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
                                         [RatingComponent newWithRating:[review.product_rating_point intValue]]
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
                                         [RatingComponent newWithRating:[review.product_accuracy_point intValue]]
                                     }
                                 }],
                                .flexBasis = CKRelativeDimension::Percent(0.5)
                            }
                        }]]
                  },
                  {
                      [CKComponent
                       newWithView:{
                           [UIView class],
                           {{@selector(setBackgroundColor:),[UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4]}}
                       }
                       size:{.height = 1}]
                  },
                  {
                      [ReviewResponseComponent newWithReview:review]
                  }
//                      {
//                          [CKButtonComponent
//                           newWithTitles:{
//                               {UIControlStateNormal, @"Beri Ulasan"}
//                           }
//                           titleColors:{
//                               {UIControlStateNormal, buttonColor}
//                           }
//                           images:{}
//                           backgroundImages:{}
//                           titleFont:[UIFont fontWithName:@"Gotham Medium" size:14.0]
//                           selected:NO
//                           enabled:YES
//                           action:nil
//                           size:{.height = 30}
//                           attributes:{
//                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
//                               {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
//                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[buttonColor CGColor]},
//                               {@selector(setClipsToBounds:), YES},
//                               {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
//                           }
//                           accessibilityConfiguration:{}],
//                          .flexGrow = YES
//                      },
              }]
             ]];
}
@end
