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
#import "ReviewImageAttachment.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* skipButton (DetailReputationReview* review) {
    if ([review.review_is_skipable isEqualToString:@"1"]) {
        return [CKButtonComponent
                newWithTitles:{
                    {UIControlStateNormal, @"Lewati"}
                }
                titleColors:{
                    {UIControlStateNormal, [UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]}
                }
                images:{}
                backgroundImages:{}
                titleFont:[UIFont microTheme]
                selected:NO
                enabled:YES
                action:@selector(didTapToSkipReview:)
                size:{.height = 25}
                attributes:{}
                accessibilityConfiguration:{}];
    }
    
    return nil;
}


static CKComponent* messageLabel(DetailReputationReview* review, NSString* role) {
    NSString* message = nil;
    if (!([review.review_message isEqualToString:@"0"] || review.review_message == nil)) {
        message = review.review_message;
    } else if ([role isEqualToString:@"2"]) {
        message = [review.review_is_skipped isEqualToString:@"1"]?@"Pembeli telah melewati ulasan":@"Pembeli belum memberi ulasan";
    } else if ([review.review_is_skipped isEqualToString:@"1"] && [role isEqualToString:@"1"]) {
        message = @"Anda telah melewati ulasan ini";
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
                     .font = [UIFont largeTheme],
                     .maximumNumberOfLines = 0,
                     .lineSpacing = 5.0
                 }
                 viewAttributes:{}
                 size:{}]];
    }
}

static CKComponent* giveReviewButton(DetailReputationReview* review, NSString* role) {
    if (([review.review_message isEqualToString:@"0"] || review.review_message == nil) && [role isEqualToString:@"1"] && [review.review_is_skipped isEqualToString:@"0"]) {
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
                 titleFont:[UIFont largeThemeMedium]
                 selected:NO
                 enabled:YES
                 action:@selector(didTapToGiveReview:)
                 size:{.height = 30}
                 attributes:{
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:60/255.0 green:179/255.0 blue:57/255.0 alpha:1.0] CGColor]},
                     {@selector(setClipsToBounds:), YES},
                     {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
                 }
                 accessibilityConfiguration:{}]];
    }
    
    return nil;
}

static CKComponent *giveResponseButton(DetailReputationReview *review, NSString *role, BOOL isDetail) {
    if (isDetail) {
        return nil;
    }
    
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
                 titleFont:[UIFont largeThemeMedium]
                 selected:NO
                 enabled:YES
                 action:@selector(didTapToGiveResponse:)
                 size:{.height = 30}
                 attributes:{
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:60/255.0 green:179/255.0 blue:57/255.0 alpha:1.0] CGColor]},
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

static CKComponent *attachedImages(DetailReputationReview *review, DetailReputationReviewContext *context) {
    if (review.review_image_attachment.count == 0) {
        return nil;
    }
    
    std::vector<CKStackLayoutComponentChild> images;
    
    for (int ii = 0; ii < review.review_image_attachment.count; ii++) {
        ReviewImageAttachment *image = review.review_image_attachment[ii];
        images.push_back({
            [CKInsetComponent
             newWithView:{
                 [UIView class],
                 {
                     {CKComponentTapGestureAttribute(@selector(didTapAttachedImages:))},
                     {@selector(setTag:), ii}
                 }
             }
             insets:{0,0,0,0}
             component:[CKNetworkImageComponent
                        newWithURL:[NSURL URLWithString:image.uri_thumbnail]
                        imageDownloader:context.imageDownloader
                        scenePath:nil
                        size:{50,50}
                        options:{}
                        attributes:{}]]
            
        });
    }
    
    return [CKInsetComponent
            newWithInsets:{8,8,8,8}
            component:
            [CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionHorizontal,
                 .spacing = 8
             }
             children:images]];
}

@implementation DetailReputationReviewContext
@end

@implementation DetailReputationReviewComponent {
    __weak id<DetailReputationReviewComponentDelegate> _delegate;
    DetailReputationReview *_review;
    NSString *_role;
}

- (void)didTapHeader:(id)sender {
    [_delegate didTapProductWithReview:_review];
}

- (void)didTapToGiveReview:(id)sender {
    [_delegate didTapToGiveReview:_review];
}

- (void)didTapToGiveResponse:(id)sender {
    [_delegate didTapToGiveResponse:_review];
}

- (void)didTapToSkipReview:(id)sender {
    [_delegate didTapToSkipReview:_review];
}

- (void)didTapButton:(id)sender {
    if ([_role isEqualToString:@"2"]) {
        [_delegate didTapToReportReview:_review atView:((CKButtonComponent*)sender).viewContext.view];
    } else {
        [_delegate didTapToEditReview:_review atView:((CKButtonComponent*)sender).viewContext.view];
    }
}

- (void)didTapToDeleteResponse:(id)sender {
    [_delegate didTapToDeleteResponse:_review atView:((CKButtonComponent*)sender).viewContext.view];
}

- (void)didTapAttachedImages:(id)sender {
    [_delegate didTapAttachedImages:_review withIndex:((CKInsetComponent*)sender).viewContext.view.tag];
}

- (void)didTapRevieweeReputation:(id)sender {
    [_delegate didTapRevieweeReputation:sender onReview:_review atView:((CKStackLayoutComponent*)sender).viewContext.view];
}

+ (instancetype)newWithReview:(DetailReputationReview*)review role:(NSString*)role isDetail:(BOOL)isDetail context:(DetailReputationReviewContext*)context {
    
    DetailReputationReviewComponent* component =
    [super newWithComponent:
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
                         [DetailReputationReviewHeaderComponent newWithReview:review
                                                                         role:(NSString*)role
                                                           tapToProductAction:@selector(didTapHeader:)
                                                              tapButtonAction:@selector(didTapButton:)
                                                              imageDownloader:context.imageDownloader
                                                                   imageCache:context.imageCache
                                                                     isDetail:isDetail],
                         .flexGrow = YES,
                         .flexShrink = YES,
                         .alignSelf = CKStackLayoutAlignSelfStretch
                     },
                     {
                         skipButton(review)
                     }
                 }]]
           },
           {
               messageLabel(review, role)
           },
           {
               attachedImages(review, context)
           },
           {
               giveReviewButton(review, role)
           },
           {
               horizontalBorder(review),
               .alignSelf = CKStackLayoutAlignSelfCenter
           },
           {
               [ReviewRatingComponent newWithReview:review imageCache:context.imageCache]
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
               [ReviewResponseComponent newWithReview:review
                                      imageDownloader:context.imageDownloader
                                           imageCache:context.imageCache
                                                 role:role
                                               action:@selector(didTapToDeleteResponse:)
                                      tapToReputation:@selector(didTapRevieweeReputation:)]
           },
           {
               giveResponseButton(review, role, isDetail)
           }
       }]
      ]];
    
    component->_delegate = context.delegate;
    component->_review = review;
    component->_role = role;
    
    return component;
}
@end
