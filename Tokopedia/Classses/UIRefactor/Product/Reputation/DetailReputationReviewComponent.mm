//
//  DetailReputationReviewComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReviewComponent.h"
#import "DetailReputationReviewHeaderComponent.h"
#import "ReviewRatingComponent.h"
#import "ReviewResponseComponent.h"
#import "AFNetworkingImageDownloader.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* messageLabel(DetailReputationReview* review, NSString* role) {
    NSString* message = nil;
    if (!([review.review_message isEqualToString:@"0"] || review.review_message == nil)) {
        message = review.review_message;
    } else if ([role isEqualToString:@"2"]) {
        message = [review.review_is_skipped isEqualToString:@"1"]?@"Pembeli memutuskan untuk tidak mengisi ulasan":@"Pembeli belum memberi ulasan";
    }
    
    if (message == nil) {
        return nil;
    } else {
        return [CKInsetComponent
                newWithInsets:{8,8,8,8}
                component:
                [CKLabelComponent
                 newWithLabelAttributes:{
                     .string = message,
                     .font = [UIFont fontWithName:@"Gotham Book" size:14],
                     .maximumNumberOfLines = 0,
                     .lineSpacing = 1.0
                 }
                 viewAttributes:{}
                 size:{}]];
    }
}

static CKComponent* giveReviewButton(DetailReputationReview* review, NSString* role) {
    if (([review.review_message isEqualToString:@"0"] || review.review_message == nil) && [role isEqualToString:@"1"]) {
        return [CKInsetComponent
                newWithInsets:{8,8,8,8}
                component:
                [CKButtonComponent
                 newWithTitles:{
                     {UIControlStateNormal, @"Beri Ulasan"}
                 }
                 titleColors:{
                     {UIControlStateNormal, [UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]}
                 }
                 images:{}
                 backgroundImages:{}
                 titleFont:[UIFont fontWithName:@"Gotham Book" size:14.0]
                 selected:NO
                 enabled:YES
                 action:@selector(didTapToGiveReview:)
                 size:{.height = 30}
                 attributes:{
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0] CGColor]},
                     {@selector(setClipsToBounds:), YES},
                     {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
                 }
                 accessibilityConfiguration:{}]];
    }
    
    return nil;
}

static CKComponent *giveResponseButton(DetailReputationReview *review, NSString *role) {
    if (![review.review_message isEqualToString:@"0"] && (review.review_response.response_message == nil || [review.review_response.response_message isEqualToString:@"0"]) && [role isEqualToString:@"2"]) {
        return [CKInsetComponent
                newWithInsets:{8,8,8,8}
                component:
                [CKButtonComponent
                 newWithTitles:{
                     {UIControlStateNormal, @"Balas Ulasan"}
                 }
                 titleColors:{
                     {UIControlStateNormal, [UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]}
                 }
                 images:{}
                 backgroundImages:{}
                 titleFont:[UIFont fontWithName:@"Gotham Book" size:14.0]
                 selected:NO
                 enabled:YES
                 action:nil
                 size:{.height = 30}
                 attributes:{
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0] CGColor]},
                     {@selector(setClipsToBounds:), YES},
                     {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
                 }
                 accessibilityConfiguration:{}]];
    }
    
    return nil;
}

static CKComponent *horizontalBorder (DetailReputationReview *review) {
    if ([review.review_message isEqualToString:@"0"] || review.review_message == nil) {
        return nil;
    }
    
    return [CKComponent
            newWithView:{
                [UIView class],
                {{@selector(setBackgroundColor:),[UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4]}}
            }
            size:{.height = 1, .width = CKRelativeDimension::Percent(.95)}];
}

@implementation DetailReputationReviewContext
@end

@implementation DetailReputationReviewComponent {
    __weak id<DetailReputationReviewComponentDelegate> _delegate;
    DetailReputationReview *_review;
}

- (void)didTapHeader:(id)sender {
    [_delegate didTapHeaderWithReview:_review];
}

- (void)didTapToGiveReview:(id)sender {
    [_delegate didTapToGiveReview:_review];
}

+ (instancetype)newWithReview:(DetailReputationReview*)review role:(NSString*)role context:(DetailReputationReviewContext*)context{
    DetailReputationReviewComponent* component = [super newWithComponent:
                                                  [CKInsetComponent
                                                   newWithView:{}
                                                   insets:{8, 8, 0, 8}
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
                                                            [DetailReputationReviewHeaderComponent newWithReview:review
                                                                                                       tapAction:@selector(didTapHeader:)
                                                                                                 imageDownloader:context.imageDownloader]
                                                        },
                                                        {
                                                            messageLabel(review, role)
                                                        },
                                                        {
                                                            giveReviewButton(review, role)
                                                        },
                                                        {
                                                            horizontalBorder(review),
                                                            .alignSelf = CKStackLayoutAlignSelfCenter
                                                        },
                                                        {
                                                            [ReviewRatingComponent newWithReview:review]
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
                                                            [ReviewResponseComponent newWithReview:review imageDownloader:context.imageDownloader]
                                                        },
                                                        {
                                                            giveResponseButton(review, role)
                                                        }
                                                    }]
                                                   ]];
    
    component->_delegate = context.delegate;
    component->_review = review;
    
    return component;
}
@end
