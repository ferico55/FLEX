//
//  ShopHeaderView.m
//  Tokopedia
//
//  Created by Samuel Edwin on 12/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopHeaderView.h"
#import "DetailShopResult.h"
#import "MedalComponent.h"
#import "AFNetworkingImageDownloader.h"
#import "ImageStorage.h"
#import "CMPopTipView.h"

#import <ComponentKit/ComponentKit.h>
#import <NSAttributedString_DDHTML/NSAttributedString+DDHTML.h>

@interface ShopHeaderContext : NSObject

@property(nonatomic) id<CKNetworkImageDownloading> imageDownloader;
@property(nonatomic) ImageStorage *imageStorage;

@end

@implementation ShopHeaderContext

@end


@implementation ShopHeaderViewModel

@end

@interface ShopHeaderView() <CMPopTipViewDelegate>

@end

@implementation ShopHeaderView

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    
}

- (instancetype)initWithShop:(DetailShopResult *)shop {
    CKComponentFlexibleSizeRangeProvider *sizeProvider =
        [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    if (self = [super initWithComponentProvider:[self class] sizeRangeProvider:sizeProvider]) {
        ShopHeaderViewModel *viewModel = [ShopHeaderViewModel new];
        viewModel.shop = shop;
        viewModel.ownShop = NO;
        
        ShopHeaderContext *context = [ShopHeaderContext new];
        context.imageDownloader = [AFNetworkingImageDownloader new];
        
        ImageStorage *imageStorage = [ImageStorage new];
        [imageStorage initImageStorage];
        [imageStorage loadImageNamed:@"icon_medal14.png" description:@"IconMedal"];
        [imageStorage loadImageNamed:@"icon_medal_bronze14.png" description:@"IconMedalBronze"];
        [imageStorage loadImageNamed:@"icon_medal_silver14.png" description:@"IconMedalSilver"];
        [imageStorage loadImageNamed:@"icon_medal_gold14.png" description:@"IconMedalGold"];
        [imageStorage loadImageNamed:@"icon_medal_diamond_one14.png" description:@"IconMedalDiamond"];
        
        context.imageStorage = imageStorage;
        
        [self updateModel:viewModel mode:CKUpdateModeSynchronous];
        [self updateContext:context mode:CKUpdateModeSynchronous];
    }
    
    return self;
}

- (void)setViewModel:(ShopHeaderViewModel *)viewModel {
    _viewModel = viewModel;
    [self updateModel:viewModel mode:CKUpdateModeSynchronous];
}

- (void)didTapMessageButton {
    if (self.onTapMessageButton) {
        self.onTapMessageButton();
    }
}

- (void)didTapSettingsButton {
    if (self.onTapSettingsButton) {
        self.onTapSettingsButton();
    }
}

- (void)didTapAddProductButton {
    if (self.onTapAddProductButton) {
        self.onTapAddProductButton();
    }
}

- (void)didTapFavoriteButton {
    if (self.onTapFavoriteButton) {
        self.onTapFavoriteButton();
    }
}

- (void)didTapMedal:(CKComponent *)sender {
    CMPopTipView *_cmPopTipView;
    
    //Init pop up
    _cmPopTipView = [[CMPopTipView alloc] initWithMessage:self.viewModel.shop.stats.pointsText];
    _cmPopTipView.textFont = [UIFont boldSystemFontOfSize:13];
    _cmPopTipView.textColor = [UIColor whiteColor];
    _cmPopTipView.delegate = self;
    _cmPopTipView.backgroundColor = [UIColor blackColor];
    _cmPopTipView.animation = CMPopTipAnimationSlide;
    _cmPopTipView.dismissTapAnywhere = YES;
    
    [_cmPopTipView presentPointingAtView:sender.viewContext.view
                                  inView:self
                                animated:YES];

}

+ (UIImage *)badgeImageForShop:(DetailShopResult *)shop {
    if (shop.info.official) {
        return [UIImage imageNamed:@"badge_official"];
    }
    
    if (shop.info.hasGoldBadge) {
        return [UIImage imageNamed:@"Badges_gold_merchant"];
    }
    
    return nil;
}

+ (CKComponent *)mainDisplayComponent:(DetailShopResult *)shop context:(ShopHeaderContext *)context {
    CKComponent *background = [CKStackLayoutComponent
                               newWithView:{}
                               size:{}
                               style:{
                                   .direction = CKStackLayoutDirectionVertical,
                                   .alignItems = CKStackLayoutAlignItemsStretch
                               }
                               children:{
                                   {
                                       [CKNetworkImageComponent
                                        newWithURL:[NSURL URLWithString:shop.info.shop_is_gold || shop.info.official? shop.info.shop_cover: @""]
                                        imageDownloader:context.imageDownloader
                                        scenePath:nil
                                        size:{ .height = 95 }
                                        options:{}
                                        attributes:{
                                            {@selector(setBackgroundColor:), [UIColor colorWithRed:0.259 green:0.741 blue:0.255 alpha:1.00]},
                                            {@selector(setContentMode:), UIViewContentModeScaleAspectFill},
                                            {@selector(setClipsToBounds:), YES}
                                        }]
                                   },
                                   {
                                        [CKComponent
                                         newWithView:{}
                                         size:{.height = 45}]
                                   },
                                   {
                                       [CKInsetComponent
                                        newWithInsets:UIEdgeInsetsMake(15, 15, 15, 15)
                                        component:
                                        [CKStackLayoutComponent
                                         newWithView:{}
                                         size:{}
                                         style:{
                                             .direction = CKStackLayoutDirectionHorizontal,
                                             .alignItems = CKStackLayoutAlignItemsStretch
                                         }
                                         children:{
                                             {
                                                 [CKStackLayoutComponent
                                                  newWithView:{
                                                      [UIView class],
                                                      {{@selector(setBackgroundColor:), [UIColor whiteColor]}}
                                                  }
                                                  size:{}
                                                  style:{
                                                      .justifyContent = CKStackLayoutJustifyContentEnd,
                                                      .direction = CKStackLayoutDirectionVertical,
                                                      .alignItems = CKStackLayoutAlignItemsStretch,
                                                      .spacing = 10
                                                  }
                                                  children:{
                                                      {
                                                          [CKLabelComponent
                                                           newWithLabelAttributes:{
                                                               .string = shop.info.shop_name,
                                                               .font = [UIFont title1ThemeMedium]
                                                           }
                                                           viewAttributes:{}
                                                           size:{}]
                                                      },
                                                      {
                                                          shop.info.official?nil:
                                                          [MedalComponent
                                                           newMedalWithLevel:[shop.stats.shop_badge_level.level integerValue]                                                           
                                                           set:[shop.stats.shop_badge_level.set integerValue]
                                                           imageCache:context.imageStorage
                                                           selector:@selector(didTapMedal:)],
                                                          .alignSelf = CKStackLayoutAlignSelfStart
                                                      }
                                                  }],
                                                 .flexGrow = YES,
                                                 .flexShrink = YES
                                             },
                                             {
                                                 [CKImageComponent
                                                  newWithImage:[self badgeImageForShop:shop]
                                                  size:{25, 25}],
                                                 .alignSelf = CKStackLayoutAlignSelfCenter
                                             }
                                         }]],
                                       .flexGrow = YES
                                   }
                               }];
    
    return [CKOverlayLayoutComponent
            newWithComponent:background
            overlay:
            [CKStaticLayoutComponent
             newWithChildren:{
                 {
                     CGPointMake(15, 45),
                     [CKNetworkImageComponent
                      newWithURL:[NSURL URLWithString:shop.info.shop_avatar]
                      imageDownloader:context.imageDownloader
                      scenePath:nil
                      size:{}
                      options:{
                          .defaultImage = [UIImage imageNamed:@"icon_default_shop"]
                      }
                      attributes:{
                          {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 45},
                          {@selector(setContentMode:), UIViewContentModeScaleAspectFill},
                          {@selector(setClipsToBounds:), YES}
                      }],
                     CGSizeMake(90, 90)
                 }
             }]];
}

+ (CKComponent *)shopActivityComponent:(DetailShopResult *)shop {
    ShopActivity activity = shop.activity;
    
    if (activity == ShopActivityOpen) {
        return nil;
    }
    
    NSString *title = activity == ShopActivityOther? shop.info.shop_status_title.stringByStrippingHTML : [NSString stringWithFormat:@"Toko ini akan tutup sampai : %@", shop.closed_info.until];
    
    NSString *reason = shop.info.shop_status_message;
    
    return [CKInsetComponent
            newWithView: {
                [UIView class],
                {{@selector(setBackgroundColor:), [UIColor colorWithRed:1.000 green:0.961 blue:0.698 alpha:1.00]}}
            }
            insets:UIEdgeInsetsMake(10, 10, 10, 10)
            component:
            [CKStackLayoutComponent
             newWithView:{}
             size:{}
             style:{
                 .direction = CKStackLayoutDirectionVertical,
                 .spacing = 5
             }
             children:{
                 {
                     [CKLabelComponent
                      newWithLabelAttributes:{
                          .string = title,
                          .font = [UIFont smallThemeMedium]
                      }
                      viewAttributes:{
                          {@selector(setBackgroundColor:), [UIColor clearColor]}
                      }
                      size:{}]
                 },
                 {
                     [CKLabelComponent
                      newWithLabelAttributes:{
                          .string = [NSAttributedString attributedStringFromHTML:reason].string,
                          .font = [UIFont smallTheme]
                      }
                      viewAttributes:{
                          {@selector(setBackgroundColor:), [UIColor clearColor]}
                      }
                      size:{}]
                 }
             }]];
}

+ (CKComponent *)actionButtonWithTitle:(NSString *)title action:(SEL)action {
    return [CKButtonComponent
            newWithTitles:{
                {UIControlStateNormal, title}
            }
            titleColors:{
                {UIControlStateNormal, [UIColor colorWithWhite:0x6f/255.0 alpha:1]}
            }
            images:{}
            backgroundImages:{}
            titleFont:[UIFont largeTheme]
            selected:NO
            enabled:YES
            action:action
            size:{}
            attributes:{
                {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)),
                    (id)[UIColor grayColor].CGColor},
                {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 1},
                {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 4}
            }
            accessibilityConfiguration:{}];
}

+ (CKComponent *)favoriteButtonWithViewModel:(ShopHeaderViewModel *)viewModel {
    if (viewModel.favoriteRequestInProgress) {
        // gotta wrap the activity indicator with another view because
        // there's a bug that the activity indicator will show out of nowhere after
        // going to the send message page and back again
        
        return [CKInsetComponent
                newWithView:{[UIView class]}
                insets:{}
                component:
                [CKComponent
                 newWithView:{
                     [UIActivityIndicatorView class],
                     {
                         {
                             {"shopheader::spin", ^(UIActivityIndicatorView *view, id unused) {
                                 view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                                 view.hidesWhenStopped = YES;
                                 [view startAnimating];
                             }},
                             nil
                         }
                     }
                 }
                 size:{}]];
    }
    
    return [self favoriteButtonIsFavorite:viewModel.shop.info.isFavorite];
}

+ (CKComponent *)favoriteButtonIsFavorite:(BOOL)isFavorite {
    NSString *title = isFavorite? @"Favorited": @"Favorit";
    UIColor *green = [UIColor colorWithRed:0.259 green:0.710 blue:0.286 alpha:1.00];
    UIImage *image = isFavorite?[UIImage imageNamed:@"icon_check_favorited"]:[UIImage imageNamed:@"icon_follow_plus"];
    
    return  [CKButtonComponent
             newWithTitles:{
                 {UIControlStateNormal, title}
             }
             titleColors:{
                 {UIControlStateNormal, isFavorite?[UIColor grayColor]:[UIColor whiteColor]}
             }
             images:{
                 {UIControlStateNormal, image}
             }
             backgroundImages:{}
             titleFont:[UIFont largeTheme]
             selected:NO
             enabled:YES
             action:@selector(didTapFavoriteButton)
             size:{}
             attributes:{
                 {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)),
                     isFavorite?(id)[UIColor grayColor].CGColor:(id)green.CGColor},
                 {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 1},
                 {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 4},
                 {@selector(setBackgroundColor:), isFavorite?[UIColor whiteColor]:green},
                 {@selector(setImageEdgeInsets:), UIEdgeInsetsMake(0, 0, 0, 8)}
             }
             accessibilityConfiguration:{}];
}

+ (CKComponent *)actionComponentWithViewModel:(ShopHeaderViewModel *)viewModel {
    BOOL isMyShop = viewModel.ownShop;
    
    return [CKInsetComponent
            newWithInsets:UIEdgeInsetsMake(0, 15, 10, 15)
            component:
            [CKStackLayoutComponent
             newWithView:{}
             size:{.height = 30}
             style:{
                 .direction = CKStackLayoutDirectionHorizontal,
                 .alignItems = CKStackLayoutAlignItemsStretch,
                 .spacing = 10
             }
             children:{
                 {
                     isMyShop?[self actionButtonWithTitle:@"Atur Toko" action:@selector(didTapSettingsButton)]: nil,
                     .flexBasis = CKRelativeDimension::Percent(0.5),
                     .flexShrink = YES
                 },
                 {
                     isMyShop?[self actionButtonWithTitle:@"Tambah Produk" action:@selector(didTapAddProductButton)]: nil,
                     .flexBasis = CKRelativeDimension::Percent(0.5),
                     .flexShrink = YES
                 },
                 {
                     !isMyShop?[self actionButtonWithTitle:@"Kirim Pesan" action:@selector(didTapMessageButton)]: nil,
                     .flexBasis = CKRelativeDimension::Percent(0.5),
                     .flexShrink = YES
                 },
                 {
                     !isMyShop?[self favoriteButtonWithViewModel:viewModel]: nil,
                     .flexBasis = CKRelativeDimension::Percent(0.5),
                     .flexShrink = YES
                 }
             }]];
}

+ (CKComponent *)componentForModel:(ShopHeaderViewModel *)viewModel context:(ShopHeaderContext *)context {
    DetailShopResult *shop = viewModel.shop;
    
    return [CKStackLayoutComponent
            newWithView:{}
            size:{}
            style:{
                .direction = CKStackLayoutDirectionVertical,
                .alignItems = CKStackLayoutAlignItemsStretch
            }
            children:{
                {
                    [self shopActivityComponent:shop]
                },
                {
                    [self mainDisplayComponent:shop context:context]
                },
                {
                    [self actionComponentWithViewModel:viewModel]
                }
            }];
}

@end
