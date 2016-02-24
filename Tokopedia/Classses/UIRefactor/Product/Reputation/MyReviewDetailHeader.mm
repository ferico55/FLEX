//
//  MyReviewDetailHeader.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailHeader.h"
#import "MyReviewDetailHeaderSmileyComponent.h"
#import "MedalComponent.h"
#import "ShopBadgeLevel.h"
#import "AFNetworkingImageDownloader.h"
#import <ComponentKit/ComponentKit.h>

@implementation MyReviewDetailHeader

- (instancetype)initWithInboxDetail:(DetailMyInboxReputation *)inbox {
    CKComponentFlexibleSizeRangeProvider* provider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    
    
    if (self = [super initWithComponentProvider:[MyReviewDetailHeader class] sizeRangeProvider:provider]) {
        
//        MyReviewDetailContext* context = [MyReviewDetailContext new];
//        context.imageDownloader = [AFNetworkingImageDownloader new];
        
        [self updateModel:inbox mode:CKUpdateModeSynchronous];
//        [self updateContext:context mode:CKUpdateModeSynchronous];
    }
    
    return self;
}

+ (CKComponent*)componentForModel:(DetailMyInboxReputation*)model context:(MyReviewDetailContext*)context {
    return [CKStackLayoutComponent
            newWithView:{
                [UIView class],
                {
                    {@selector(setBackgroundColor:), [UIColor whiteColor]}
                }
            }
            size:{}
            style:{
                .direction = CKStackLayoutDirectionVertical,
                .alignItems = CKStackLayoutAlignItemsCenter,
                .spacing = 5
            }
            children:{
                {   // Avatar
                    [CKInsetComponent
                     newWithView:{}
                     insets:{8,8,8,8}
                     component:{
                         [CKImageComponent
                          newWithImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                          size:{50,50}]
                     }]
                },
                {   // Label nama
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
                                       .string = [model.reviewee_role isEqualToString:@"1"]?@"Pembeli":@"Penjual",
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
                                       .string = model.reviewee_name,
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
                    [MedalComponent newMedalWithLevel:[model.shop_badge_level.level intValue]
                                                  set:[model.shop_badge_level.set intValue]]
                },
                {
                    [MyReviewDetailHeaderSmileyComponent newWithInbox:model],
                    .spacingAfter = 8
                }
            }];
}

@end
