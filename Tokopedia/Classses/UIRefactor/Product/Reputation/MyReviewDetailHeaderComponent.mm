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
#import "ImageStorage.h"
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

static CKComponent *revieweeReputation(DetailMyInboxReputation *inbox, MyReviewDetailContext *context) {
    ImageStorage *imageCache = context.imageCache;
    
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
                    {UIControlStateNormal, [imageCache cachedImageWithDescription:@"IconSmileSmall"]}
                }
                backgroundImages:{}
                titleFont:{
                    [UIFont fontWithName:@"Gotham Book" size:11.0]
                }
                selected:NO
                enabled:YES
                action:@selector(didTapBuyerReputation:)
                size:{}
                attributes:{}
                accessibilityConfiguration:{}];
    } else {
        return [MedalComponent newMedalWithLevel:[inbox.shop_badge_level.level intValue]
                                             set:[inbox.shop_badge_level.set intValue]
                                      imageCache:imageCache
                                        selector:@selector(didTapSellerReputation:)];
    }
}

static CKComponent *remainingTimeLeft(DetailMyInboxReputation *inbox, MyReviewDetailContext *context) {
    ImageStorage *imageCache = context.imageCache;
    
    NSString *timeLeft = [NSString stringWithFormat:@"Batas waktu ubah nilai %d hari lagi", [inbox.reputation_days_left intValue]];
    
    if([inbox.reputation_days_left intValue] > 0 && [inbox.reputation_days_left intValue] < 4) {
        return [CKStackLayoutComponent
                newWithView:{}
                size:{}
                style:{
                    .direction = CKStackLayoutDirectionHorizontal,
                    .alignItems = CKStackLayoutAlignItemsCenter,
                    .spacing = 5
                }
                children:{
                    {
                        [CKImageComponent
                         newWithImage:[imageCache cachedImageWithDescription:@"IconCountdown"]
                         size:{14,14}]
                    },
                    {
                        [CKLabelComponent
                         newWithLabelAttributes:{
                             .string = timeLeft,
                             .font = [UIFont fontWithName:@"Gotham Book" size:14.0]
                         }
                         viewAttributes:{
                             {@selector(setBackgroundColor:), [UIColor clearColor]}
                         }
                         size:{}],
                        
                    }
                }];
    } else {
        return nil;
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

- (void)didTapBuyerReputation:(id)sender {
    [_delegate didTapRevieweeReputation:sender role:_inbox.reviewee_role atView:((CKButtonComponent*)sender).viewContext.view];
}

- (void)didTapSellerReputation:(id)sender {
    [_delegate didTapRevieweeReputation:sender role:_inbox.reviewee_role atView:((CKStackLayoutComponent*)sender).viewContext.view];
}

+ (instancetype)newWithInbox:(DetailMyInboxReputation*)inbox context:(MyReviewDetailContext*)context {
    ImageStorage *imageCache = context.imageCache;
    
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
                                                                                       .defaultImage = [imageCache cachedImageWithDescription:@"IconProfilePicture"]
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
                                                                             revieweeReputation(inbox, context)
                                                                         },
                                                                         {
                                                                             [MyReviewDetailHeaderSmileyComponent newWithInbox:inbox context:context],
                                                                             .spacingAfter = 8
                                                                         },
                                                                         {
                                                                             remainingTimeLeft(inbox, context),
                                                                             .spacingAfter = 8
                                                                         }
                                                                     }]];
    
    header->_delegate = context.delegate;
    header->_inbox = inbox;
    
    return header;
}


@end
