//
//  MyReviewDetailHeaderSmileyComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailHeaderSmileyComponent.h"
#import "MyReviewDetailHeaderComponent.h"
#import "ImageStorage.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* revieweeEditedLabel(DetailMyInboxReputation *inbox) {
    if ([inbox.is_reviewee_score_edited isEqualToString:@"0"]) {
        return nil;
    }
    
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = @"(diubah)",
                .font = [UIFont fontWithName:@"Gotham Book" size:12.0],
                .color = [UIColor colorWithWhite:177.0/255 alpha:1.0]
            }
            viewAttributes:{}
            size:{}];
}

static CKComponent* reviewerEditedLabel(DetailMyInboxReputation *inbox) {
    if ([inbox.is_reviewer_score_edited isEqualToString:@"0"]) {
        return nil;
    }
    
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = @"(diubah)",
                .font = [UIFont fontWithName:@"Gotham Book" size:12.0],
                .color = [UIColor colorWithWhite:177.0/255 alpha:1.0]
            }
            viewAttributes:{}
            size:{}];
}

static CKComponent* score(DetailMyInboxReputation *inbox, MyReviewDetailContext *context) {
    ImageStorage *imageCache = context.imageCache;
    std::vector<CKStackLayoutComponentChild> smileys;
    NSInteger score;
    
    if ([inbox.reviewee_role isEqualToString:@"2"]) {
        score = [inbox.seller_score integerValue];
    } else {
        score = [inbox.buyer_score integerValue];
    }
    
    CKStackLayoutComponent *smileyLocked = [CKStackLayoutComponent
                                            newWithView:{
                                                [UIView class],
                                                {
                                                    {CKComponentTapGestureAttribute(@selector(didTapLockedSmiley))}
                                                }
                                            }
                                            size:{}
                                            style:{
                                                .direction = CKStackLayoutDirectionVertical,
                                                .alignItems = CKStackLayoutAlignItemsCenter,
                                                .spacing = 16
                                            }
                                            children:{
                                                {
                                                    [CKImageComponent
                                                     newWithImage:[imageCache cachedImageWithDescription:@"IconReviewLocked"]
                                                     size:{37,30}]
                                                },
                                                {
                                                    [CKLabelComponent
                                                     newWithLabelAttributes:{
                                                         .string = @"Terkunci",
                                                         .font = [UIFont fontWithName:@"Gotham Medium" size:12.0]
                                                     }
                                                     viewAttributes:{}
                                                     size:{}]
                                                }
                                            }];
    
    CKStackLayoutComponent *smileySadGrey = [CKStackLayoutComponent
                                             newWithView:{
                                                 [UIView class],
                                                 {
                                                     {CKComponentTapGestureAttribute(@selector(didTapNotSatisfiedSmiley))}
                                                 }
                                             }
                                             size:{.width = 65.5, .height = 57}
                                             style:{
                                                 .direction = CKStackLayoutDirectionVertical,
                                                 .alignItems = CKStackLayoutAlignItemsCenter,
                                                 .spacing = 16
                                             }
                                             children:{
                                                 {
                                                     [CKImageComponent
                                                      newWithImage:[imageCache cachedImageWithDescription:@"IconSadGrey"]
                                                      size:{30,30}]
                                                 },
                                                 {
                                                     [CKLabelComponent
                                                      newWithLabelAttributes:{
                                                          .string = @"Tidak Puas",
                                                          .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                                                      }
                                                      viewAttributes:{
                                                      {@selector(setBackgroundColor:), [UIColor clearColor]}
                                                      }
                                                      size:{}]
                                                 }
                                             }];
    
    CKStackLayoutComponent *smileySad = [CKStackLayoutComponent
                                         newWithView:{}
                                         size:{.width = 65.5, .height = 57}
                                         style:{
                                             .direction = CKStackLayoutDirectionVertical,
                                             .alignItems = CKStackLayoutAlignItemsCenter,
                                             .spacing = 16
                                         }
                                         children:{
                                             {
                                                 [CKImageComponent
                                                  newWithImage:[imageCache cachedImageWithDescription:@"IconSad"]
                                                  size:{30,30}]
                                             },
                                             {
                                                 [CKLabelComponent
                                                  newWithLabelAttributes:{
                                                      .string = @"Tidak Puas",
                                                      .font = [UIFont fontWithName:@"Gotham Medium" size:12.0]
                                                  }
                                                  viewAttributes:{}
                                                  size:{}]
                                             }
                                         }];
    
    CKStackLayoutComponent *smileyNeutralGrey = [CKStackLayoutComponent
                                                 newWithView:{
                                                     [UIView class],
                                                     {
                                                         {CKComponentTapGestureAttribute(@selector(didTapNeutralSmiley))}
                                                     }
                                                 }
                                                 size:{.width = 65.5, .height = 57}
                                                 style:{
                                                     .direction = CKStackLayoutDirectionVertical,
                                                     .alignItems = CKStackLayoutAlignItemsCenter,
                                                     .spacing = 16
                                                 }
                                                 children:{
                                                     {
                                                         [CKImageComponent
                                                          newWithImage:[imageCache cachedImageWithDescription:@"IconNeutralGrey"]
                                                          size:{30,30}]
                                                     },
                                                     {
                                                         [CKLabelComponent
                                                          newWithLabelAttributes:{
                                                              .string = @"Netral",
                                                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                                                          }
                                                          viewAttributes:{
                                                          {@selector(setBackgroundColor:), [UIColor clearColor]}
                                                          }
                                                          size:{}]
                                                     }
                                                 }];
    
    CKStackLayoutComponent *smileyNeutral = [CKStackLayoutComponent
                                             newWithView:{}
                                             size:{.width = 65.5, .height = 57}
                                             style:{
                                                 .direction = CKStackLayoutDirectionVertical,
                                                 .alignItems = CKStackLayoutAlignItemsCenter,
                                                 .spacing = 16
                                             }
                                             children:{
                                                 {
                                                     [CKImageComponent
                                                      newWithImage:[imageCache cachedImageWithDescription:@"IconNeutral"]
                                                      size:{30,30}]
                                                 },
                                                 {
                                                     [CKLabelComponent
                                                      newWithLabelAttributes:{
                                                          .string = @"Netral",
                                                          .font = [UIFont fontWithName:@"Gotham Medium" size:12.0]
                                                      }
                                                      viewAttributes:{}
                                                      size:{}]
                                                 }
                                             }];
    
    CKStackLayoutComponent *smileySmileGrey = [CKStackLayoutComponent
                                               newWithView:{
                                                   [UIView class],
                                                   {
                                                       {CKComponentTapGestureAttribute(@selector(didTapSatisfiedSmiley))}
                                                   }
                                               }
                                               size:{.width = 65.5, .height = 57}
                                               style:{
                                                   .direction = CKStackLayoutDirectionVertical,
                                                   .alignItems = CKStackLayoutAlignItemsCenter,
                                                   .spacing = 16
                                               }
                                               children:{
                                                   {
                                                       [CKImageComponent
                                                        newWithImage:[imageCache cachedImageWithDescription:@"IconSmileGrey"]
                                                        size:{30,30}]
                                                   },
                                                   {
                                                       [CKLabelComponent
                                                        newWithLabelAttributes:{
                                                            .string = @"Puas",
                                                            .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                                                        }
                                                        viewAttributes:{
                                                            {@selector(setBackgroundColor:), [UIColor clearColor]}
                                                        }
                                                        size:{}]
                                                   }
                                               }];
    
    CKStackLayoutComponent *smileySmile = [CKStackLayoutComponent
                                           newWithView:{}
                                           size:{}
                                           style:{
                                               .direction = CKStackLayoutDirectionVertical,
                                               .alignItems = CKStackLayoutAlignItemsCenter,
                                               .spacing = 16
                                           }
                                           children:{
                                               {
                                                   [CKImageComponent
                                                    newWithImage:[imageCache cachedImageWithDescription:@"IconSmile"]
                                                    size:{30,30}]
                                               },
                                               {
                                                   [CKLabelComponent
                                                    newWithLabelAttributes:{
                                                        .string = @"Puas",
                                                        .font = [UIFont fontWithName:@"Gotham Medium" size:12.0]
                                                    }
                                                    viewAttributes:{}
                                                    size:{}]
                                               }
                                           }];
    
    
    if ([inbox.reputation_progress isEqualToString:@"2"] && [inbox.my_score_image isEqualToString:@"smiley_none"]) {
        return smileyLocked;
    }
    
    UIColor *backgroundColor = [UIColor clearColor];
    
    switch (score) {
        case -1: {
            smileys.push_back({smileySad});
            smileys.push_back({smileyNeutralGrey});
            smileys.push_back({smileySmileGrey});
        }
            break;
        case 0: {
            smileys.push_back({smileySadGrey});
            smileys.push_back({smileyNeutralGrey});
            smileys.push_back({smileySmileGrey});
        }
            break;
        case 1: {
            smileys.push_back({smileySadGrey});
            smileys.push_back({smileyNeutral});
            smileys.push_back({smileySmileGrey});
        }
            break;
        case 2: {
            smileys.push_back({smileySmile});
        }
            break;
        default:
            break;
    }
    
    
    
    return [CKStackLayoutComponent
            newWithView:{
                [UIView class],
                {
                    {@selector(setBackgroundColor:), backgroundColor}
                }
            }
            size:{}
            style:{
                .direction = CKStackLayoutDirectionHorizontal,
                .justifyContent = CKStackLayoutJustifyContentCenter,
                .spacing = 16
            }
            children:smileys];
}


static CKComponent *myScore(DetailMyInboxReputation *inbox, MyReviewDetailContext *context) {
    ImageStorage *imageCache = context.imageCache;
    NSDictionary<NSString*, UIImage*>* myScoreImageNameByType = @{
                                                                   @"smiley_neutral":[imageCache cachedImageWithDescription:@"IconNeutral"],
                                                                   @"smiley_bad":[imageCache cachedImageWithDescription:@"IconSad"],
                                                                   @"smiley_good":[imageCache cachedImageWithDescription:@"IconSmile"],
                                                                   @"smiley_none":[inbox.reputation_progress isEqualToString:@"2"]?[imageCache cachedImageWithDescription:@"IconReviewLocked"]:[imageCache cachedImageWithDescription:@"IconQuestionMark"],
                                                                   @"grey_question_mark":[imageCache cachedImageWithDescription:@"IconQuestionMark"],
                                                                   @"blue_question_mark":[imageCache cachedImageWithDescription:@"IconChecklist"]
                                                                   };
    
    return [CKStackLayoutComponent
            newWithView:{
                [UIView class],
                {
                    {CKComponentTapGestureAttribute(@selector(getMyScore))},
                    {@selector(setBackgroundColor:), [UIColor whiteColor]}
                }
            }
            size:{}
            style:{
                .direction = CKStackLayoutDirectionVertical,
                .alignItems = CKStackLayoutAlignItemsStretch,
                .spacing = 8
            }
            children:{
                {
                    [CKComponent
                     newWithView:{
                         [UIView class],
                         {{@selector(setBackgroundColor:),[UIColor colorWithRed:0.784
                                                                          green:0.78
                                                                           blue:0.8
                                                                          alpha:0.4]}}
                     }
                     size:{
                         .height = 1}]
                },
                {
                    [CKStackLayoutComponent
                     newWithView:{}
                     size:{}
                     style:{
                         .direction = CKStackLayoutDirectionHorizontal,
                         .alignItems = CKStackLayoutAlignItemsCenter,
                         .spacing = 5
                     }
                     children:{
                         {
                             [CKLabelComponent
                              newWithLabelAttributes:{
                                  .string = @"Nilai Untuk Anda:",
                                  .font = [UIFont fontWithName:@"Gotham Book" size:14.0]
                              }
                              viewAttributes:{}
                              size:{}]
                         },
                         {
                             [CKImageComponent
                              newWithImage:[myScoreImageNameByType objectForKey:inbox.my_score_image]
                              size:{([inbox.reputation_progress isEqualToString:@"2"] && [inbox.my_score_image isEqualToString:@"smiley_none"])?24.7:20,20}]
                         },
                         {
                             revieweeEditedLabel(inbox)
                         }
                         
                     }],
                    .alignSelf = CKStackLayoutAlignSelfCenter,
                    .spacingAfter = 8
                }
            }]
    ;
}

@implementation MyReviewDetailHeaderSmileyComponent {
    __weak id<MyReviewDetailHeaderSmileyDelegate> _delegate;
    DetailMyInboxReputation *_inbox;
}

- (void)getMyScore {
    [_delegate didTapReviewerScore:_inbox];
}

- (void)didTapLockedSmiley {
    [_delegate didTapLockedSmiley];
}

- (void)didTapNotSatisfiedSmiley {
    [_delegate didTapNotSatisfiedSmiley:_inbox];
}

- (void)didTapSatisfiedSmiley {
    [_delegate didTapSatisfiedSmiley:_inbox];
}

- (void)didTapNeutralSmiley {
    [_delegate didTapNeutralSmiley:_inbox];
}

+ (instancetype)newWithInbox:(DetailMyInboxReputation *)inbox context:(MyReviewDetailContext *)context {
    UIColor *backgroundColor = [UIColor clearColor];
    
    NSInteger revieweeScore;
    
    if ([inbox.reviewee_role isEqualToString:@"2"]) {
        revieweeScore = [inbox.seller_score integerValue];
    } else {
        revieweeScore = [inbox.buyer_score integerValue];
    }
    
    MyReviewDetailHeaderSmileyComponent *smiley = [super newWithComponent:
            [CKStackLayoutComponent
             newWithView:{
                 [UIView class],
                 {
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 1.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4] CGColor]},
                     {@selector(setClipsToBounds:), YES},
                     {@selector(setBackgroundColor:), backgroundColor}
                 }
             }
             size:{
                 .width = CKRelativeDimension::Percent(0.9)
             }
             style:{
                 .direction = CKStackLayoutDirectionVertical,
                 .alignItems = CKStackLayoutAlignItemsStretch,
                 .spacing = 8
             }
             children:{
                 {
                     [CKStackLayoutComponent
                      newWithView:{}
                      size:{}
                      style:{
                          .direction = CKStackLayoutDirectionHorizontal,
                          .alignItems = CKStackLayoutAlignItemsCenter,
                          .spacing = 5
                      }
                      children:{
                          {
                              [CKLabelComponent
                               newWithLabelAttributes:{
                                   .string = [inbox.reviewee_role isEqualToString:@"2"]?@"Beri Nilai Penjual:":@"Beri Nilai Pembeli:",
                                   .font = [UIFont fontWithName:@"Gotham Medium" size:14.0]
                               }
                               viewAttributes:{
                                   {@selector(setBackgroundColor:), backgroundColor}
                               }
                               size:{}]
                          },
                          {
                              reviewerEditedLabel(inbox)
                          }
                      }],
                     .alignSelf = CKStackLayoutAlignSelfCenter,
                     .spacingBefore = 8
                 },
                 {
                     score(inbox, context),
                     .alignSelf = CKStackLayoutAlignSelfStretch
                 },
                 {
                     myScore(inbox, context),
                     .alignSelf = CKStackLayoutAlignSelfStretch
                 }
             }]];
    
    smiley->_delegate = context.smileyDelegate;
    smiley->_inbox = inbox;
    
    return smiley;
}

@end
