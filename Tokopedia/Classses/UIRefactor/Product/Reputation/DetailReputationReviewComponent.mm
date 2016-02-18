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
             insets:{0, 8, 0, 8}
             component:
             [CKInsetComponent
              newWithView:{
                  [UIView class],
                  {
                      {@selector(setBackgroundColor:), [UIColor whiteColor]}
                  }
              }
              insets:{8, 8, 8, 8}
              component:{
                  [CKStackLayoutComponent
                   newWithView:{}
                   size:{}
                   style:{
                       .direction = CKStackLayoutDirectionVertical,
                       .alignItems = CKStackLayoutAlignItemsStretch,
                       .justifyContent = CKStackLayoutJustifyContentCenter
                   }
                   children:{
                       {
                           [CKStackLayoutComponent
                            newWithView:{}
                            size:{}
                            style:{
                                .direction = CKStackLayoutDirectionHorizontal
                            }
                            children:{
                                {
                                    //                                   [CKNetworkImageComponent
                                    //                                    newWithURL:[NSURL URLWithString:review.product_image]
                                    //                                    imageDownloader:imageDownloader
                                    //                                    scenePath:nil
                                    //                                    size:{44,44}
                                    //                                    options:{
                                    //                                        .defaultImage = [UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                    //                                    }
                                    //                                    attributes:{}]
                                },
                                {
                                    [CKComponent
                                     newWithView:{
                                         [UILabel class],
                                         {
                                             {@selector(setText:), review.product_name},
                                             {@selector(setFont:), [UIFont fontWithName:@"Gotham Medium" size:14.0]},
                                             {@selector(setLineBreakMode:), NSLineBreakByTruncatingMiddle}
                                         }}
                                     size:{.height = 21}],
                                    .flexGrow = YES
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
                            }]
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
              }]]];
}
@end
