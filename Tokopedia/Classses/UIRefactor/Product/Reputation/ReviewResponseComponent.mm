//
//  ReviewResponseComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewResponseComponent.h"
#import "MedalComponent.h"
#import "ShopBadgeLevel.h"

static CKComponent *deleteButton (NSString *role, SEL action) {
    if ([role isEqualToString:@"2"]) {
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
                action:action
                size:{.height = 14, .width = 14}
                attributes:{}
                accessibilityConfiguration:{}];
    }
    
    return nil;
}

@implementation ReviewResponseComponent

+ (instancetype)newWithReview:(DetailReputationReview *)review
              imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                         role:(NSString *)role
                       action:(SEL)action {
    if ([review.review_response.response_message isEqualToString:@"0"] || review.review_response.response_message == nil) {
        return nil;
    }
    
    return [super newWithComponent:
            [CKInsetComponent
             newWithInsets:{8,8,8,8}
             component:{
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
                           newWithURL:[NSURL URLWithString:review.product_owner.shop_img]
                           imageDownloader:imageDownloader
                           scenePath:nil
                           size:{50,50}
                           options:{
                               .defaultImage = [UIImage imageNamed:@"icon_profile_picture.jpeg"]
                           }
                           attributes:{
                               {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 25.0},
                               {@selector(setClipsToBounds:), YES}
                           }]
                      },
                      {
                          [CKStackLayoutComponent
                           newWithView:{}
                           size:{}
                           style:{
                               .direction = CKStackLayoutDirectionVertical,
                               .spacing = 8
                           }
                           children:
                           {
                               {
                                   [CKStackLayoutComponent
                                    newWithView:{}
                                    size:{}
                                    style:{
                                        .direction = CKStackLayoutDirectionHorizontal,
                                        .spacing = 5
                                    }
                                    children:
                                    {
                                        {
                                            [CKInsetComponent
                                             newWithView:{
                                                 [UIView class],
                                                 {
                                                     {@selector(setBackgroundColor:), [UIColor colorWithRed:185/255.0f green:74/255.0f blue:72/255.0f alpha:1.0f]},
                                                     {@selector(setCornerRadius:), 2.0},
                                                     {@selector(setClipsToBounds:), YES}
                                                 }
                                             }
                                             insets:{5,4,5,4}
                                             component:{
                                                 [CKLabelComponent
                                                  newWithLabelAttributes:{
                                                      .string = @"Penjual",
                                                      .font = [UIFont fontWithName:@"Gotham Medium" size:11.0],
                                                      .color = [UIColor whiteColor],
                                                      .alignment = NSTextAlignmentCenter
                                                      
                                                  }
                                                  viewAttributes:{
                                                      {@selector(setBackgroundColor:), [UIColor colorWithRed:185/255.0f green:74/255.0f blue:72/255.0f alpha:1.0f]}
                                                  }
                                                  size:{}]
                                             }]
                                        },
                                        {
                                            [CKInsetComponent
                                             newWithInsets:{3,0,3,0}
                                             component:{
                                                 [CKLabelComponent
                                                  newWithLabelAttributes:{
                                                      .string = review.product_owner.shop_name,
                                                      .font = [UIFont fontWithName:@"Gotham Medium" size:14.0],
                                                      .maximumNumberOfLines = 1,
                                                      .color = [UIColor colorWithRed:18.0/255 green:199.0/255 blue:0 alpha:1]
                                                  }
                                                  viewAttributes:{}
                                                  size:{}]
                                             }]
                                            
                                        }
                                    }]
                               },
                               {
                                   [MedalComponent newMedalWithLevel:[review.shop_badge_level.level intValue] set:[review.shop_badge_level.set intValue]]
                               },
                               {
                                   [CKLabelComponent
                                    newWithLabelAttributes:{
                                        .string = review.review_response.response_message,
                                        .font = [UIFont fontWithName:@"Gotham Book" size:14.0],
                                        .maximumNumberOfLines = 0
                                    }
                                    viewAttributes:{}
                                    size:{}],
                                   
                               },
                               {
                                   [CKLabelComponent
                                    newWithLabelAttributes:{
                                        .string = review.review_response.response_create_time,
                                        .font = [UIFont fontWithName:@"Gotham Book" size:12.0],
                                        .color = [UIColor colorWithWhite:158.0/255 alpha:1]
                                    }
                                    viewAttributes:{}
                                    size:{}]
                               }
                           }],
                          .flexShrink = YES,
                          .flexGrow = YES
                      },
                      {
                          deleteButton(role, action)
                      }
                  }]}]];
}

@end
