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

static CKComponent *userLabel(DetailMyInboxReputation *inbox) {
    
    NSString *role = nil;
    UIColor *color = nil;
    
    if ([inbox.reviewee_role isEqualToString:@"1"]) {
        color = [UIColor colorWithRed:42/255.0f green:180/255.0f blue:194/255.0f alpha:1.0f];
        role = @"Pembeli";
    } else {
        color = [UIColor colorWithRed:185/255.0f green:74/255.0f blue:72/255.0f alpha:1.0f];
        role = @"Penjual";
    }
    
    return [CKInsetComponent
            newWithView:{
                [UIView class],
                {
                    {@selector(setBackgroundColor:), color},
                    {@selector(setCornerRadius:), 2.0},
                    {@selector(setClipsToBounds:), YES}
                }
            }
            insets:{5,4,5,4}
            component:{
                [CKLabelComponent
                 newWithLabelAttributes:{
                     .string = role,
                     .font = [UIFont fontWithName:@"Gotham Medium" size:11.0],
                     .color = [UIColor whiteColor],
                     .alignment = NSTextAlignmentCenter
                     
                 }
                 viewAttributes:{
                     {@selector(setBackgroundColor:), color}
                 }
                 size:{}]
            }];
}

static CKComponent *revieweeReputation(DetailMyInboxReputation *inbox) {
    
    NSString *percentage = @"0";
    
    if (inbox.user_reputation != nil) {
        percentage = inbox.user_reputation.positive_percentage;
    }
    
    if ([inbox.reviewee_role isEqualToString:@"1"]) {
        return [CKButtonComponent
                newWithTitles:{
                    {UIControlStateNormal, [NSString stringWithFormat:@"%@%%", percentage]}
                }
                titleColors:{
                    {UIControlStateNormal, [UIColor colorWithWhite:117.0/255 alpha:1.0]}
                }
                images:{
                    {UIControlStateNormal, [UIImage imageNamed:@"icon_smile_small.png"]}
                }
                backgroundImages:{}
                titleFont:{
                    [UIFont fontWithName:@"Gotham Book" size:11.0]
                }
                selected:NO
                enabled:YES
                action:nil
                size:{}
                attributes:{}
                accessibilityConfiguration:{}];
    } else {
        return [MedalComponent newMedalWithLevel:[inbox.shop_badge_level.level intValue]
                                             set:[inbox.shop_badge_level.set intValue]];
    }
}

@implementation MyReviewDetailContext

@end

@implementation MyReviewDetailHeader

- (instancetype)initWithInboxDetail:(DetailMyInboxReputation *)inbox {
    CKComponentFlexibleSizeRangeProvider* provider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    
    
    if (self = [super initWithComponentProvider:[MyReviewDetailHeader class] sizeRangeProvider:provider]) {
        
        MyReviewDetailContext* context = [MyReviewDetailContext new];
        context.imageDownloader = [AFNetworkingImageDownloader new];
        
        [self updateModel:inbox mode:CKUpdateModeSynchronous];
        [self updateContext:context mode:CKUpdateModeSynchronous];
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
                         [CKNetworkImageComponent
                          newWithURL:[NSURL URLWithString:model.reviewee_picture]
                          imageDownloader:context.imageDownloader
                          scenePath:nil
                          size:{50,50}
                          options:{
                              .defaultImage = [UIImage imageNamed:@"icon_profile_picture.jpeg"]
                          }
                          attributes:{
                              {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 25.0},
                              {@selector(setClipsToBounds:), YES}
                          }]
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
                             userLabel(model)
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
                                       .color = [UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]
                                   }
                                   viewAttributes:{}
                                   size:{}]
                              }]
                             
                         }
                     }]
                },
                {
                    revieweeReputation(model)
                },
                {
                    [MyReviewDetailHeaderSmileyComponent newWithInbox:model],
                    .spacingAfter = 8
                }
            }];
}

@end
