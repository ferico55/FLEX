//
//  ProductTableViewCell.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductCell.h"
#import "CatalogModelView.h"
#import "QueueImageDownloader.h"
#import "Tokopedia-Swift.h"
#import "UserAuthentificationManager.h"
#import "TokopediaNetworkManager.h"
#import "StarsRateView.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import <Lottie/Lottie.h>

@interface ProductCell()
@property (strong, nonatomic) IBOutlet StarsRateView *starsRateView;
@property (strong, nonatomic) IBOutlet UIView *ratingContainerView;
@property (strong, nonatomic) IBOutlet UILabel *totalReviewLabel;
@property (strong, nonatomic) LOTAnimationView *setWishlistAnimationView;
@property (strong, nonatomic) LOTAnimationView *unsetWishlistAnimationView;
@property (strong, nonatomic) IBOutlet UIView *soldOutView;
@property (strong, nonatomic) IBOutlet UIImageView *topAdsBadgeImageView;
@end

@implementation ProductCell{
    QueueImageDownloader* imageDownloader;
    TokopediaNetworkManager *tokopediaNetworkManagerWishList;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [_shopLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_badgesView.mas_leading);
    }];
}

- (void) setupWishlistButton {
    self.setWishlistAnimationView = [LOTAnimationView animationNamed:@"activateWishlist"];
    self.setWishlistAnimationView.loopAnimation = NO;
    self.setWishlistAnimationView.contentMode = UIViewContentModeScaleAspectFill;
    self.setWishlistAnimationView.backgroundColor = UIColor.clearColor;
    self.setWishlistAnimationView.animationProgress = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonWishlistTap:)];
    [self.setWishlistAnimationView addGestureRecognizer: tap];
    [self.contentView addSubview:self.setWishlistAnimationView];
    [self.setWishlistAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconOvalWhite.mas_left);
        make.top.equalTo(self.iconOvalWhite.mas_top);
        make.size.equalTo(self.iconOvalWhite);
    }];
    
    self.unsetWishlistAnimationView = [LOTAnimationView animationNamed:@"deactivateWishlist"];
    self.unsetWishlistAnimationView.loopAnimation = NO;
    self.unsetWishlistAnimationView.contentMode = UIViewContentModeScaleAspectFill;
    self.unsetWishlistAnimationView.backgroundColor = UIColor.clearColor;
    self.unsetWishlistAnimationView.animationProgress = 0;
    UITapGestureRecognizer *unsetTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonWishlistTap:)];
    [self.unsetWishlistAnimationView addGestureRecognizer: unsetTap];
    [self.contentView addSubview:self.unsetWishlistAnimationView];
    [self.unsetWishlistAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconOvalWhite.mas_left);
        make.top.equalTo(self.iconOvalWhite.mas_top);
        make.size.equalTo(self.iconOvalWhite);
    }];
    
    [self.buttonWishlist setHidden:YES];
}

- (void) removeWishlistButton {
    [self.setWishlistAnimationView setHidden:YES];
    [self.unsetWishlistAnimationView setHidden:YES];
    [self.buttonWishlistExpander setHidden:YES];
    [self.iconOvalWhite setHidden:YES];
    [self.buttonWishlist setHidden: YES];
    [self.setWishlistAnimationView removeFromSuperview];
    [self.buttonWishlist setHidden: YES];
}

- (void) setWishlistButtonState:(BOOL)isOnWishlist {
    if(isOnWishlist) {
        [self.buttonWishlist setSelected:YES];
        [self.buttonWishlistExpander setSelected:YES];
        [self.setWishlistAnimationView setHidden:YES];
        [self.unsetWishlistAnimationView setHidden:NO];
    } else {
        [self.buttonWishlist setSelected:NO];
        [self.buttonWishlistExpander setSelected:NO];
        [self.setWishlistAnimationView setHidden:NO];
        [self.unsetWishlistAnimationView setHidden:YES];
    }
    [self.buttonWishlistExpander setEnabled:YES];
}

- (void) resetWishlistButtonAnimation {
    self.setWishlistAnimationView.animationProgress = 0;
    self.unsetWishlistAnimationView.animationProgress = 0;
}

- (void)setViewModel:(ProductModelView *)viewModel {
    _viewModel = viewModel;
    
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }
    
    self.productName.font = [UIFont smallThemeMedium];
    self.productName.text = viewModel.productName?:@"";
    
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    if(!viewModel.shopLocation || [viewModel.shopLocation isEqualToString:@"0"]) {
        [self.shopLocation setHidden:YES];
    }
    [self.shopLocation setText:viewModel.shopLocation];
    
    if(!viewModel.productShop || [viewModel.productShop isEqualToString:@"0"]) {
        [self.productShop setHidden:YES];
    }
    
    self.preorderPosition.constant = !viewModel.isWholesale ? -42 : 3;
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.productThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    
    [self setBadges:viewModel.badges];
    [self setLabels:viewModel.labels];
    
    if ([self isHasReview:viewModel.productRate]) {
        _ratingContainerView.hidden = NO;
        [_starsRateView setStarscount: [viewModel.productRate integerValue]];
        _totalReviewLabel.text = [NSString stringWithFormat: @"(%@)", viewModel.totalReview];
    } else {
        _ratingContainerView.hidden = YES;
    }
    
    [self.buttonWishlistExpander setHidden:NO];
    [self.iconOvalWhite setHidden:NO];
    [self resetWishlistButtonAnimation];
    [self setWishlistButtonState:viewModel.isOnWishlist];
    
    UIFont *font = [UIFont largeTheme];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [viewModel.productPrice sizeWithAttributes:attributes];
    self.productPriceLabelWidthConstraint.constant = size.width + 8;
    
    if(viewModel.original_price && ![viewModel.original_price isEqualToString:@""]) {
        NSMutableAttributedString* originalPrice = [[NSMutableAttributedString alloc]initWithString:viewModel.original_price];
        [originalPrice addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [originalPrice length])];
        [originalPrice addAttribute:NSStrikethroughColorAttributeName value:[UIColor.blackColor colorWithAlphaComponent:0.6] range:NSMakeRange(0, [originalPrice length])];
        self.originalPriceLabel.attributedText = originalPrice;
        self.discountLabel.text = [NSString stringWithFormat:@"%ld%%OFF", (long)viewModel.percentage_amount];
        [self.originalPriceLabel setHidden:NO];
        [self.discountView setHidden:NO];
        self.productPriceLabelTopConstraint.constant = 12;
        
        [self layoutIfNeeded];
    }
    else {
        [self.originalPriceLabel setHidden:YES];
        [self.discountView setHidden:YES];
        self.productPriceLabelTopConstraint.constant = 0;
    }
    self.soldOutView.hidden = !viewModel.isSoldOut;
}

- (void) updateLayout {
    if(![self.discountLabel.text isEqualToString:@""]) {
        UIFont *font = [UIFont largeThemeSemibold];
        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
        CGSize size = [self.productPrice.text sizeWithAttributes:attributes];
        [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.productName.mas_bottom);
            make.height.equalTo(@(14));
            [self.productPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.originalPriceLabel.mas_bottom);
                make.width.equalTo(@(size.width + 8));
            }];
        }];
    }
}

- (IBAction)buttonWishlistTap:(id)sender {
    if(![self.buttonWishlistExpander isEnabled]) {
        return;
    }
    if([self.setWishlistAnimationView isAnimationPlaying] || [self.unsetWishlistAnimationView isAnimationPlaying]) {
        return;
    }
    
    BOOL isLoggedIn = [UserAuthentificationManager new].isLogin;
    if (!isLoggedIn) {
        [AuthenticationService.shared ensureLoggedInFromViewController:self.parentViewController onSuccess:nil];
    } else {
        if(self.setWishlistAnimationView == nil) {
            [self setupWishlistButton];
            [self setWishlistButtonState:self.viewModel.isOnWishlist];
        }
        else {
            [self resetWishlistButtonAnimation];
        }
        [self.buttonWishlistExpander setEnabled:NO];
        if([self.setWishlistAnimationView isHidden]) {
            [self.unsetWishlistAnimationView playWithCompletion:^(BOOL animationFinished) {
                [self setWishlistButtonState:NO];
            }];
            [self setUnWishList];
        }
        else {
            [self.setWishlistAnimationView playWithCompletion:^(BOOL animationFinished) {
                [self setWishlistButtonState:YES];
            }];
            [self setWishList];
        }
    }
}

- (void)setWishList
{
    [AnalyticsManager trackEventName:@"clickWishlist"
                            category:GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE
                              action:GA_EVENT_ACTION_CLICK
                               label:@"Add to Wishlist"];
    
    NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:self.productPrice.text];
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventAddToWishlist withValues:@{
                                                                                   AFEventParamPrice : price?:@"",
                                                                                   AFEventParamContentType : @"Product",
                                                                                   AFEventParamContentId : self.viewModel.productId,
                                                                                   AFEventParamCurrency : @"IDR",
                                                                                   AFEventParamQuantity : @(1)
                                                                                   }];
    
    if ([_parentViewController isKindOfClass:[SearchResultViewController class]]) {
        NSString *now = [NSDate getNowWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        [AnalyticsManager trackEventName:@"productView" category:@"search result" action:@"click - wishlist" label:[NSString stringWithFormat:@"add - %@ - %@", _searchTerm, now]];
    }
    
    __weak typeof(self) weakSelf = self;
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    tokopediaNetworkManagerWishList.isUsingDefaultError = NO;
    tokopediaNetworkManagerWishList.isUsingHmac = YES;

    [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl]
                                                   path:@"/wishlist/v1.2"
                                                 method:RKRequestMethodPOST
                                                 header: @{@"X-User-ID" : [_userManager getUserId]}
                                              parameter: @{@"user_id" : [_userManager getUserId],
                                                           @"product_id" : _viewModel.productId}
                                                mapping:[GeneralAction mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
            [weakSelf didSuccessAddWishlistWithSuccessResult: successResult withOperation:operation];
                                              } onFailure:^(NSError *errorResult) {
                                                  [weakSelf didFailedAddWishListWithErrorResult:errorResult];
                                              }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddedProductToWishList" object:self.viewModel.productId];
}

-(void) didSuccessRemoveWishlistWithSuccessResult: (RKMappingResult *) successResult withOperation: (RKObjectRequestOperation *) operation{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda berhasil menghapus wishlist"] delegate:self.parentViewController];
    [alert show];
    [self.delegate changeWishlistForProductId:self.viewModel.productId withStatus:NO];
}

-(void) didSuccessAddWishlistWithSuccessResult: (RKMappingResult *) successResult withOperation: (RKObjectRequestOperation *) operation {
    [self.delegate changeWishlistForProductId: _viewModel.productId withStatus:YES];
}

-(void) didFailedAddWishListWithErrorResult: (NSError *) error {
    [self resetWishlistButtonAnimation];
    [self setWishlistButtonState:NO];
    
    NSString *errorMessage = [error localizedRecoverySuggestion];
    NSArray *messageToShow = @[@"Kendala koneksi internet."];
    if (errorMessage) {
        NSData *data = [errorMessage dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        messageToShow = json[@"message_error"];
    }
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messageToShow delegate:self.parentViewController];
    [alert show];
    [self.delegate changeWishlistForProductId:self.viewModel.productId withStatus:NO];
}

-(void) didFailedRemoveWishListWithErrorResult: (NSError *) error {
    [self resetWishlistButtonAnimation];
    [self setWishlistButtonState:YES];
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Gagal menghapus produk dari wishlist"] delegate:self.parentViewController];
    [alert show];
    [self.delegate changeWishlistForProductId:self.viewModel.productId withStatus:YES];
}

- (void)setUnWishList
{
    if ([_parentViewController isKindOfClass:[SearchResultViewController class]]) {
        NSString *now = [NSDate getNowWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        [AnalyticsManager trackEventName:@"productView" category:@"search result" action:@"click - wishlist" label:[NSString stringWithFormat:@"remove - %@ - %@", _searchTerm, now]];
    }
    
    __weak __typeof(self) weakSelf = self;
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    tokopediaNetworkManagerWishList.isUsingHmac = YES;
    [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl]
                                                   path:@"/wishlist/v1.2"
                                                 method:RKRequestMethodDELETE
                                                 header: @{@"X-User-ID" : [_userManager getUserId]}
                                              parameter: @{@"user_id" : [_userManager getUserId],
                                                           @"product_id" : _viewModel.productId}
                                                mapping:[GeneralAction mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        [weakSelf didSuccessRemoveWishlistWithSuccessResult: successResult withOperation:operation];
                                            } onFailure:^(NSError *errorResult) {
        [weakSelf didFailedRemoveWishListWithErrorResult:errorResult];
    }];
}

- (void)setLabels:(NSArray<ProductLabel*>*) labels {
    for(UIView* subview in _labelsView.arrangedSubviews) {
        [_labelsView removeArrangedSubview:subview];
    }
    
    _labelsView.alignment = OAStackViewAlignmentFill;
    _labelsView.spacing = 2;
    _labelsView.axis = UILayoutConstraintAxisHorizontal;
    _labelsView.distribution = OAStackViewDistributionEqualSpacing;
    
    for(ProductLabel* productLabel in labels) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [NSString stringWithFormat:@"%@ ", productLabel.title];
        label.backgroundColor  = [UIColor fromHexString:productLabel.color];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.borderColor =  [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor tpGray].CGColor : [UIColor fromHexString:productLabel.color].CGColor;
        label.textColor = [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor] : [UIColor whiteColor];
        label.font = [UIFont superMicroTheme];
        
        [label sizeToFit];
        
        [_labelsView addArrangedSubview:label];
    }
}

- (void)setBadges:(NSArray<ProductBadge*>*)badges {
    
    for(UIView* subview in _badgesView.arrangedSubviews) {
        [_badgesView removeArrangedSubview:subview];
    }
    
    _badgesView.spacing = 2;
    _badgesView.axis = UILayoutConstraintAxisHorizontal;
    _badgesView.distribution = OAStackViewDistributionFillEqually;
    _badgesView.alignment = OAStackViewAlignmentCenter;
    
    NSMutableArray *urls = [NSMutableArray new];
    for(ProductBadge* badge in badges){
        [urls addObject:badge.image_url];
    }
    
    [imageDownloader downloadImagesWithUrls:urls onComplete:^(NSArray<UIImage *> *images) {
        for(UIImage *image in images){
            if(image.size.width > 1){
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                imageView.image = image;
                
                [_badgesView addArrangedSubview:imageView];
                
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(_badgesView.mas_height);
                    make.height.equalTo(_badgesView.mas_height);
                }];
            }
        }
    }];
}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];
    
    self.productPrice.text = @"Mulai dari";
    self.productPrice.font = [UIFont microTheme];
    self.productPrice.textColor = [UIColor tpDisabledBlackText];
    
    self.catalogPriceLabel.hidden = NO;
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.catalogPriceLabel.font = [UIFont largeThemeSemibold];
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada produk" : [NSString stringWithFormat:@"%@ Produk", viewModel.catalogSeller]];
    self.productShop.font = [UIFont microTheme];
    self.productShop.textColor = [UIColor tpPrimaryBlackText];
    
    self.goldShopBadge.hidden = YES;
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeCenter];
    
    self.locationImage.hidden = YES;
    self.shopLocation.text = nil;
    _ratingContainerView.hidden = YES;
    
    [self.buttonWishlistExpander setHidden:YES];
    [self.setWishlistAnimationView setHidden: YES];
    [self.unsetWishlistAnimationView setHidden: YES];
    [self.iconOvalWhite setHidden:YES];
    [self removeWishlistButton];
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}

- (BOOL) isHasReview: (NSString*) productRate {
    if ([productRate integerValue] == 0 || productRate == nil) {
        return NO;
    }
    
    return YES;
}

- (void) setAsTopAds  {
    _topAdsBadgeImageView.hidden = NO;
}

@end
