//
//  ProductSingleViewCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductSingleViewCell.h"

#import "ProductCell.h"
#import "ProductModelView.h"
#import "CatalogModelView.h"
#import "Tokopedia-Swift.h"
#import "QueueImageDownloader.h"
#import <Lottie/Lottie.h>

@interface ProductSingleViewCell()
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UIView *viewDiscount;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlistExpander;
@property (strong, nonatomic) IBOutlet UIImageView *iconOvalWhite;
@property (strong, nonatomic) LOTAnimationView *setWishlistAnimationView;
@property (strong, nonatomic) LOTAnimationView *unsetWishlistAnimationView;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlist;

@end

@implementation ProductSingleViewCell{
    QueueImageDownloader* imageDownloader;
    TokopediaNetworkManager *tokopediaNetworkManagerWishList;
}

#pragma mark wishlist actions
- (void) setupWishlistButton {
    self.setWishlistAnimationView = [LOTAnimationView animationNamed:@"activateWishlist"];
    self.setWishlistAnimationView.loopAnimation = NO;
    self.setWishlistAnimationView.contentMode = UIViewContentModeScaleAspectFill;
    self.setWishlistAnimationView.backgroundColor = UIColor.clearColor;
    self.setWishlistAnimationView.animationProgress = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonWishlistTap:)];
    [self.setWishlistAnimationView addGestureRecognizer: tap];
    self.setWishlistAnimationView.frame = CGRectMake(self.contentView.frame.size.width - 36, 0, 36, 36);
    [self.contentView addSubview:self.setWishlistAnimationView];
    
    self.unsetWishlistAnimationView = [LOTAnimationView animationNamed:@"deactivateWishlist"];
    self.unsetWishlistAnimationView.loopAnimation = NO;
    self.unsetWishlistAnimationView.contentMode = UIViewContentModeScaleAspectFill;
    self.unsetWishlistAnimationView.backgroundColor = UIColor.clearColor;
    self.unsetWishlistAnimationView.animationProgress = 0;
    UITapGestureRecognizer *unsetTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonWishlistTap:)];
    [self.unsetWishlistAnimationView addGestureRecognizer: unsetTap];
    [self.contentView addSubview:self.unsetWishlistAnimationView];
    self.unsetWishlistAnimationView.frame = CGRectMake(self.contentView.frame.size.width - 36, 0, 36, 36);
    
    [self.buttonWishlist setHidden:YES];
}

- (void) removeWishlistButton {
    [self.setWishlistAnimationView setHidden:YES];
    [self.unsetWishlistAnimationView setHidden:YES];
    [self.buttonWishlistExpander setHidden:YES];
    [self.iconOvalWhite setHidden:YES];
    [self.buttonWishlist setHidden:YES];
    [self.setWishlistAnimationView removeFromSuperview];
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

- (IBAction)buttonWishlistTap:(id)sender {
    if(![self.buttonWishlistExpander isEnabled]) {
        return;
    }
    if([self.setWishlistAnimationView isAnimationPlaying] || [self.unsetWishlistAnimationView isAnimationPlaying]) {
        return;
    }
    
    BOOL isLoggedIn = [UserAuthentificationManager new].isLogin;
    [AuthenticationService.shared ensureLoggedInFromViewController:self.parentViewController onSuccess:^{
        if(!isLoggedIn) return;
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
    }];
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
    __weak typeof(self) weakSelf = self;
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    tokopediaNetworkManagerWishList.isUsingDefaultError = NO;
    tokopediaNetworkManagerWishList.isUsingHmac = YES;
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    
    [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl]
                                                   path:[self wishlistUrlPathWithProductId:self.viewModel.productId userId: [_userManager getUserId]]
                                                 method:RKRequestMethodPOST
                                                 header: @{@"X-User-ID" : [_userManager getUserId]}
                                              parameter: nil
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
    [self.delegate changeWishlistForProductId:self.viewModel.productId withStatus:YES];
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

- (NSString *) wishlistUrlPathWithProductId: (NSString *)productId userId: (NSString*) userId {
    return [NSString stringWithFormat:@"/users/%@/wishlist/%@/v1.1", userId, productId];
}

- (void)setUnWishList
{
    __weak __typeof(self) weakSelf = self;
    tokopediaNetworkManagerWishList = [TokopediaNetworkManager new];
    tokopediaNetworkManagerWishList.isUsingHmac = YES;
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    [tokopediaNetworkManagerWishList requestWithBaseUrl:[NSString mojitoUrl]
                                                   path:[self wishlistUrlPathWithProductId:self.viewModel.productId userId: [_userManager getUserId]]
                                                 method:RKRequestMethodDELETE
                                                 header: @{@"X-User-ID" : [_userManager getUserId]}
                                              parameter: nil
                                                mapping:[GeneralAction mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                  [weakSelf didSuccessRemoveWishlistWithSuccessResult: successResult withOperation:operation];
                                              } onFailure:^(NSError *errorResult) {
                                                  [weakSelf didFailedRemoveWishListWithErrorResult:errorResult];
                                              }];
}

#pragma mark other method
- (void)setViewModel:(ProductModelView *)viewModel {
    _viewModel = viewModel;
    if(imageDownloader == nil){
        imageDownloader = [QueueImageDownloader new];
    }
    
    if(!viewModel.productShop || [viewModel.productShop isEqualToString:@"0"]) {
        [self.productShop setHidden:YES];
        [self.shopLocation setHidden:YES];
    }
    else {
        [self.productShop setHidden: NO];
        [self.shopLocation setHidden:NO];
    }
    
    [self.productName setText:viewModel.productName];
    [self.productPrice setText:viewModel.productPrice];
    [self.productShop setText:viewModel.productShop];
    
    self.shopLocation.text = viewModel.shopLocation;
    self.grosirPosition.constant = viewModel.isProductPreorder ? 10 : -64;

    [self.productInfoLabel setText:[NSString stringWithFormat:@"%@ Diskusi - %@ Ulasan", viewModel.productTalk, viewModel.productReview]];
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.singleGridImageUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [self setBadges:viewModel.badges];
    [self setLabels:viewModel.labels];
    
    if(viewModel.original_price && ![viewModel.original_price isEqualToString:@""]) {
        NSMutableAttributedString* originalPrice = [[NSMutableAttributedString alloc]initWithString:viewModel.original_price];
        [originalPrice addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [originalPrice length])];
        [originalPrice addAttribute:NSStrikethroughColorAttributeName value:[UIColor.blackColor colorWithAlphaComponent:0.6] range:NSMakeRange(0, [originalPrice length])];
        
        self.catalogPriceLabel.hidden = NO;
        self.viewDiscount.hidden = NO;
        
        self.productPrice.attributedText = originalPrice;
        self.productPrice.textColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        
        self.productPrice.font = [UIFont superMicroTheme];
        self.discountLabel.text = [NSString stringWithFormat:@"%d%%OFF", viewModel.percentage_amount];
        self.catalogPriceLabel.text = viewModel.productPrice;
        self.shopLocation.hidden = YES;
        
        [self updateLayout];
    }
    else {
        self.productPrice.font = [UIFont largeThemeSemibold];
        self.productPrice.textColor = UIColor.redColor; //#FC5830
        self.catalogPriceLabel.hidden = YES;
        self.viewDiscount.hidden = YES;
    }
    
    [self.buttonWishlistExpander setHidden:NO];
    [self.iconOvalWhite setHidden:NO];
    [self resetWishlistButtonAnimation];
    [self setWishlistButtonState:viewModel.isOnWishlist];
}

- (void) updateLayout {
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [self.productPrice.text sizeWithAttributes:attributes];
    [self.catalogPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size.width + 8));
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
        label.text = [NSString stringWithFormat:@" %@  ", productLabel.title];
        label.backgroundColor  = [UIColor fromHexString:productLabel.color];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1.0;
        label.layer.borderColor =  [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor].CGColor : [UIColor fromHexString:productLabel.color].CGColor;
        label.textColor = [productLabel.color isEqualToString:@"#ffffff"] ? [UIColor lightGrayColor] : [UIColor whiteColor];
        label.font = [UIFont microTheme];
        
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
    
    [_shopLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_badgesView.mas_leading);
    }];

}

- (void)setCatalogViewModel:(CatalogModelView *)viewModel {
    [self.productName setText:viewModel.catalogName];
    
    self.productPrice.text = @"Mulai dari";
    self.productPriceWidthConstraint.constant = -50;
    self.productPrice.font = [UIFont microTheme];
    self.productPrice.textColor = [UIColor tpDisabledBlackText];
    
    self.catalogPriceLabel.text = viewModel.catalogPrice;
    self.catalogPriceLabel.font = [UIFont largeThemeSemibold];
    self.catalogPriceLabel.hidden = NO;
    
    [self.productShop setText:[viewModel.catalogSeller isEqualToString:@"0"] ? @"Tidak ada produk" : [NSString stringWithFormat:@"%@ Produk", viewModel.catalogSeller]];
    self.productShop.font = [UIFont microTheme];
    self.productShop.textColor = [UIColor tpPrimaryBlackText];
    
    [self.productImage setImageWithURL:[NSURL URLWithString:viewModel.catalogThumbUrl] placeholderImage:[UIImage imageNamed:@"grey-bg.png.png"]];
    [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
    
    self.locationIcon.hidden = YES;
    self.shopLocation.text = nil;
    self.productInfoLabel.hidden = YES;
    [self removeWishlistButton];
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [imageDownloader cancelAllOperations];
}
@end
