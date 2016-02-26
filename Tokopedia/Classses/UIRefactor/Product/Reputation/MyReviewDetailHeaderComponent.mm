//
//  MyReviewDetailHeaderComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailHeaderComponent.h"
#import "MyReviewDetailHeaderDelegate.h"
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
                action:@selector(didTapRevieweeReputation:)
                size:{}
                attributes:{}
                accessibilityConfiguration:{}];
    } else {
        return [MedalComponent newMedalWithLevel:[inbox.shop_badge_level.level intValue]
                                             set:[inbox.shop_badge_level.set intValue]];
    }
}


@implementation MyReviewDetailHeaderComponent {
    __weak id<MyReviewDetailHeaderDelegate> _delegate;
    DetailMyInboxReputation *_inbox;
}

- (void)didTapReviewee {
    NSString *userID = nil;
    if ([_inbox.role isEqualToString:@"2"]) {
        userID = [[_inbox.reviewee_uri componentsSeparatedByString:@"/"] lastObject];
    } else {
        userID = _inbox.shop_id;
    }
    [_delegate didTapRevieweeNameWithID:userID];
}

- (void)didTapRevieweeReputation:(id)sender {
    [_delegate didTapRevieweeReputation:sender role:_inbox.role];
}

- (void)didTapScore {
    
}

- (void)didTapMyScore {
    [_delegate didTapReviewerScore:_inbox];
}

+ (instancetype)newWithInbox:(DetailMyInboxReputation*)inbox context:(MyReviewDetailContext*)context {
    MyReviewDetailHeaderComponent *header = [super newWithComponent:[CKStackLayoutComponent
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
                                             newWithView:{
                                                 [UIView class],
                                                 {
                                                     {CKComponentTapGestureAttribute(@selector(didTapReviewee))}
                                                 }
                                             }
                                             insets:{8,8,8,8}
                                             component:{
                                                 [CKNetworkImageComponent
                                                  newWithURL:[NSURL URLWithString:inbox.reviewee_picture]
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
                                             newWithView:{
                                                 [UIView class],
                                                 {
                                                     {CKComponentTapGestureAttribute(@selector(didTapReviewee))}
                                                 }
                                             }
                                             size:{}
                                             style:{
                                                 .direction = CKStackLayoutDirectionHorizontal,
                                                 .spacing = 5
                                             }
                                             children:
                                             {
                                                 {
                                                     userLabel(inbox)
                                                 },
                                                 {
                                                     [CKInsetComponent
                                                      newWithInsets:{3,0,3,0}
                                                      component:{
                                                          [CKLabelComponent
                                                           newWithLabelAttributes:{
                                                               .string = inbox.reviewee_name,
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
                                            revieweeReputation(inbox)
                                        },
                                        {
                                            [MyReviewDetailHeaderSmileyComponent newWithInbox:inbox],
                                            .spacingAfter = 8
                                        }
                                    }]];
    
    header->_delegate = context.delegate;
    header->_inbox = inbox;
    
    return header;
}


@end
