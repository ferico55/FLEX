//
//  MyReviewDetailHeaderSmileyComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailHeaderSmileyComponent.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* editedLabel(DetailMyInboxReputation *inbox) {
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = @"(diubah)",
                .font = [UIFont fontWithName:@"Gotham Book" size:12.0],
                .color = [UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4]
            }
            viewAttributes:{}
            size:{}];
}

static CKComponent* score(DetailMyInboxReputation *inbox) {
    std::vector<CKStackLayoutComponentChild> smileys;
    NSInteger score;
    
    if ([inbox.reviewee_role isEqualToString:@"2"]) {
        score = [inbox.seller_score integerValue];
    } else {
        score = [inbox.buyer_score integerValue];
    }
    
    if ([inbox.reputation_progress isEqualToString:@"2"] && [inbox.my_score_image isEqualToString:@"smiley_none"]) {
        return [CKStackLayoutComponent
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
                         newWithImage:[UIImage imageNamed:@"icon_review_locked.png"]
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
    }
    
    switch (score) {
        case -1: {
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_sad.png"] size:{30,30}]
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
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_neutral_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Netral",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_smile_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Puas",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
        }
            break;
        case 0: {
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_sad_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Tidak Puas",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_neutral_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Netral",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_smile_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Puas",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
        }
            
            break;
        case 1: {
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_sad_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Tidak Puas",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_netral.png"] size:{30,30}]
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
                 }]
            });
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_smile_grey.png"] size:{30,30}]
                     },
                     {
                         [CKLabelComponent
                          newWithLabelAttributes:{
                              .string = @"Puas",
                              .font = [UIFont fontWithName:@"Gotham Book" size:12.0]
                          }
                          viewAttributes:{}
                          size:{}]
                     }
                 }]
            });
        }
            
            break;
        case 2: {
            smileys.push_back({
                [CKStackLayoutComponent
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
                          newWithImage:[UIImage imageNamed:@"icon_smile.png"] size:{30,30}]
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
                 }]
            });
        }
            
            break;
        default:
            break;
    }
    
    return [CKStackLayoutComponent
            newWithView:{}
            size:{}
            style:{
                .direction = CKStackLayoutDirectionHorizontal,
                .justifyContent = CKStackLayoutJustifyContentCenter,
                .spacing = 16
            }
            children:smileys];
}

static CKComponent *remainingTimeLeft(DetailMyInboxReputation *inbox) {
    
    NSString *timeLeft = [NSString stringWithFormat:@"Batas waktu ubah nilai %d hari lagi", [inbox.reputation_days_left intValue]];
    
    if([inbox.reputation_days_left intValue] > 0 && [inbox.reputation_days_left intValue] < 4) {
        return [CKStackLayoutComponent
                newWithView:{
                    [UIView class],
                    {
                        {
                            {@selector(setBackgroundColor:),[UIColor colorWithRed:255.0/255
                                                                         green:209.0/255
                                                                          blue:209.0/255
                                                                         alpha:1]}
                        }
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
                         size:{.height = 1}]
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
                                 [CKImageComponent
                                  newWithImage:[UIImage imageNamed:@"icon_countdown.png"]
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
                         }],
                        .alignSelf = CKStackLayoutAlignSelfCenter,
                        .spacingAfter = 8
                    }
                }];
    } else {
        return nil;
    }
}

static CKComponent *myScore(DetailMyInboxReputation *inbox) {
    NSDictionary<NSString*, NSString*>* myScoreImageNameByType = @{
                                                                   @"smiley_neutral":@"icon_netral.png",
                                                                   @"smiley_bad":@"icon_sad.png",
                                                                   @"smiley_good":@"icon_smile.png",
                                                                   @"smiley_none":[inbox.reputation_progress isEqualToString:@"2"]?@"icon_review_locked.png":@"icon_question_mark30.png",
                                                                   @"grey_question_mark":@"icon_question_mark30.png",
                                                                   @"blue_question_mark":@"icon_checklist_grey.png"
                                                                   };
    
    return [CKStackLayoutComponent
            newWithView:{}
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
                              newWithImage:[UIImage imageNamed:[myScoreImageNameByType objectForKey:inbox.my_score_image]]
                              size:{([inbox.reputation_progress isEqualToString:@"2"] && [inbox.my_score_image isEqualToString:@"smiley_none"])?24.7:20,20}]
                         },
                         {
                             editedLabel(inbox)
                         }
                         
                     }],
                    .alignSelf = CKStackLayoutAlignSelfCenter,
                    .spacingAfter = 8
                }
            }]
    ;
}

@implementation MyReviewDetailHeaderSmileyComponent

+ (instancetype)newWithInbox:(DetailMyInboxReputation *)inbox {
    return [super newWithComponent:
            [CKStackLayoutComponent
             newWithView:{
                 [UIView class],
                 {
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 1.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                     {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:0.784 green:0.78 blue:0.8 alpha:0.4] CGColor]},
                     {@selector(setClipsToBounds:), YES}
                     
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
                               viewAttributes:{}
                               size:{}]
                          },
                          {
                              editedLabel(inbox)
                          }
                      }],
                     .alignSelf = CKStackLayoutAlignSelfCenter,
                     .spacingBefore = 8
                 },
                 {
                     score(inbox),
                     .alignSelf = CKStackLayoutAlignSelfStretch
                 },
                 {
                     remainingTimeLeft(inbox),
                     .alignSelf = CKStackLayoutAlignSelfStretch,
                     .spacingAfter = -8
                 },
                 {
                     myScore(inbox),
                     .alignSelf = CKStackLayoutAlignSelfStretch
                 }
             }]];
}

@end
