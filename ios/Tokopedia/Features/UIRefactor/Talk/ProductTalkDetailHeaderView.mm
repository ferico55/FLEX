//
//  ProductTalkDetailHeaderView.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKNetworkImageDownloading.h>

#import "ProductTalkDetailHeaderView.h"
#import "AFNetworkingImageDownloader.h"
#import "CMPopTipView.h"
#import "SmileyAndMedal.h"

@interface ProductTalkDetailHeaderContext : NSObject

@property (nonatomic) id<CKNetworkImageDownloading> imageDownloader;

@end

@implementation ProductTalkDetailHeaderContext

@end

@implementation ProductTalkDetailHeaderView {
    TalkList *_talk;
}

- (instancetype)initWithTalk:(TalkList *)talk {
    CKComponentFlexibleSizeRangeProvider *sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider
                                                               providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    self = [super initWithComponentProvider:[self class]
                          sizeRangeProvider:sizeRangeProvider];
    
    _talk = talk;
    
    ProductTalkDetailHeaderContext *context = [ProductTalkDetailHeaderContext new];
    context.imageDownloader = [AFNetworkingImageDownloader new];
    
    [self updateContext:context mode:CKUpdateModeSynchronous];
    [self updateModel:talk mode:CKUpdateModeSynchronous];
    
    return self;
}

- (void)didTapProduct {
    if (self.onTapProduct) {
        self.onTapProduct(_talk);
    }
}

- (void)didTapUser {
    if (self.onTapUser) {
        self.onTapUser(_talk);
    }
}

- (void)didTapReputation:(CKComponent *)sender {
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
    
    SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
    [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:_talk.talk_user_reputation.neutral withRepSmile:_talk.talk_user_reputation.positive withRepSad:_talk.talk_user_reputation.negative withDelegate:nil];
    
    CMPopTipView *cmPopTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
    cmPopTipView.backgroundColor = [UIColor whiteColor];
    cmPopTipView.animation = CMPopTipAnimationSlide;
    cmPopTipView.dismissTapAnywhere = YES;
    cmPopTipView.leftPopUp = YES;
    
    [cmPopTipView presentPointingAtView:sender.viewContext.view inView:self animated:YES];
}

+ (CKComponent *)productComponentWithTalk:(TalkList *)talk context:(ProductTalkDetailHeaderContext *)context {
    return [CKStackLayoutComponent
            newWithView:{}
            size:{}
            style:{
                .direction = CKStackLayoutDirectionHorizontal,
                .spacing = 10
            }
            children:{
                {
                    [CKNetworkImageComponent
                     newWithURL:[NSURL URLWithString:talk.talk_product_image]
                     imageDownloader:context.imageDownloader
                     scenePath:nil
                     size:{ .width = 70, .height = 70 }
                     options:{}
                     attributes:{
                         {CKComponentTapGestureAttribute(@selector(didTapProduct))},
                         {@selector(setUserInteractionEnabled:), YES}
                     }]
                },
                {
                    [CKStackLayoutComponent
                     newWithView:{}
                     size:{}
                     style:{
                         .direction = CKStackLayoutDirectionVertical,
                         .spacing = 4
                     }
                     children:{
                         {
                             [CKLabelComponent
                              newWithLabelAttributes:{
                                  .string = talk.talk_product_name,
                                  .font = [UIFont smallThemeMedium]
                              }
                              viewAttributes:{
                                  {CKComponentTapGestureAttribute(@selector(didTapProduct))},
                                  {@selector(setUserInteractionEnabled:), YES}
                              }
                              size:{}]
                         },
                         {
                             [CKLabelComponent
                              newWithLabelAttributes:{
                                  .string = [[talk.talk_message stringByStrippingHTML] kv_decodeHTMLCharacterEntities],
                                  .font = [UIFont largeTheme],
                                  .lineSpacing = 5
                              }
                              viewAttributes:{}
                              size:{}]
                         }
                     }],
                    .flexShrink = YES
                }
            }];
}

+ (CKComponent *)componentForModel:(TalkList *)talk context:(ProductTalkDetailHeaderContext *)context {
    if (!talk) return nil;
    
    return [CKInsetComponent
            newWithView:{
                [UIView class],
                {{@selector(setBackgroundColor:), [UIColor whiteColor]}}
            }
            insets:UIEdgeInsetsMake(15, 15, 15, 15)
            component:
            [CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionVertical,
                 .alignItems = CKStackLayoutAlignItemsStretch
             }
             children:{
                 {
                     [CKStackLayoutComponent
                      newWithView:{}
                      size:{}
                      style:{
                          .direction = CKStackLayoutDirectionHorizontal,
                          .spacing = 10
                      }
                      children:{
                          {
                              [CKNetworkImageComponent
                               newWithURL: [NSURL URLWithString:talk.talk_user_image]
                               imageDownloader:context.imageDownloader
                               scenePath:{}
                               size:{ .width = 50, .height = 50 }
                               options:{}
                               attributes:{
                                   {
                                       {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 25},
                                       {@selector(setClipsToBounds:), YES},
                                       {CKComponentTapGestureAttribute(@selector(didTapUser))},
                                       {@selector(setUserInteractionEnabled:), YES}
                                   }
                               }]
                          },
                          {
                              [CKStackLayoutComponent
                               newWithView:{}
                               size:{}
                               style:{
                                   .direction = CKStackLayoutDirectionVertical,
                                   .spacing = 3
                               }
                               children:{
                                   {
                                       [CKStackLayoutComponent
                                        newWithView:{
                                            [UIView class],
                                            {
                                                {CKComponentTapGestureAttribute(@selector(didTapUser))},
                                                {@selector(setUserInteractionEnabled:), YES}
                                            }
                                        }
                                        size:{}
                                        style:{
                                            .direction = CKStackLayoutDirectionHorizontal,
                                            .alignItems = CKStackLayoutAlignItemsCenter,
                                            .spacing = 4
                                        }
                                        children:{
                                            {
                                                [CKInsetComponent
                                                 newWithView:{
                                                     [UIView class],
                                                     {
                                                         {@selector(setBackgroundColor:), [UIColor colorWithRed:0.275 green:0.533 blue:0.278 alpha:1.00]},
                                                         {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 2}
                                                     }
                                                 }
                                                 insets:UIEdgeInsetsMake(4, 4, 4, 4)
                                                 component:
                                                 [CKLabelComponent
                                                  newWithLabelAttributes:{
                                                      .string = @"Pengguna",
                                                      .font = [UIFont microTheme],
                                                      .color = [UIColor whiteColor]
                                                  }
                                                  viewAttributes:{
                                                      {@selector(setBackgroundColor:), [UIColor clearColor]}
                                                  }
                                                  size:{}]]
                                            },
                                            {
                                                [CKLabelComponent
                                                 newWithLabelAttributes:{
                                                     .string = talk.talk_user_name,
                                                     .color = [UIColor colorWithRed:0.039 green:0.494 blue:0.027 alpha:1.00],
                                                     .font = [UIFont smallTheme]
                                                 }
                                                 viewAttributes:{}
                                                 size:{}]
                                            }
                                        }]
                                   },
                                   {
                                       [CKButtonComponent
                                        newWithTitles:{
                                            {UIControlStateNormal, [NSString stringWithFormat:@"%@%%", talk.talk_user_reputation.positive_percentage]}
                                        }
                                        titleColors:{
                                            {UIControlStateNormal, [UIColor colorWithRed:0.620 green:0.620 blue:0.620 alpha:1.00]}
                                        }
                                        images:{
                                            {UIControlStateNormal, [UIImage imageNamed:@"icon_smile_small.png"]}
                                        }
                                        backgroundImages:{}
                                        titleFont:[UIFont smallTheme]
                                        selected:NO
                                        enabled:YES
                                        action:nil
                                        size:{ .width = 80 }
                                        attributes:{
                                            {@selector(setTitleEdgeInsets:), UIEdgeInsetsMake(0, 10, 0, 0)},
                                            {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentLeft},
                                            {CKComponentActionAttribute(@selector(didTapReputation:))}
                                        }
                                        accessibilityConfiguration:{}],
                                   },
                                   {
                                       [CKLabelComponent
                                        newWithLabelAttributes:{
                                            .string = talk.talk_create_time,
                                            .color = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.00],
                                            .font = [UIFont microTheme]
                                        }
                                        viewAttributes:{}
                                        size:{}]
                                   }
                               }]
                          }
                      }]
                 },
                 {
                     [CKComponent
                      newWithView:{
                          [UIView class],
                          {{@selector(setBackgroundColor:), [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00]}}
                      }
                      size:{ .height = 1 }],
                     .spacingBefore = 3,
                     .spacingAfter = 15
                 },
                 {
                     [self productComponentWithTalk:talk context:context]
                 }
             }]];
}

@end
