//
//  MoreViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "detail.h"
#import "MoreViewController.h"
#import "more.h"
#import "TKPDSecureStorage.h"
#import "stringrestkit.h"
#import "profile.h"
#import "Deposit.h"
#import "DepositResult.h"
#import "string_deposit.h"
#import "string_more.h"
#import "WebViewController.h"

#import "HomeTabViewController.h"
#import "SalesViewController.h"
#import "PurchaseViewController.h"

#import "ShopFavoritedViewController.h"
#import "EtalaseViewController.h"

#import "InboxTicketSplitViewController.h"
#import "TKPDTabViewController.h"
#import "InboxTicketViewController.h"

#import "InboxTalkViewController.h"

#import "TKPDTabInboxTalkNavigationController.h"
#import "DepositSummaryViewController.h"
#import "ProductListMyShopViewController.h"
#import "InboxResolutionCenterTabViewController.h"
#import "InboxResolSplitViewController.h"
#import "NavigateViewController.h"

#import "NavigateViewController.h"

#import <MessageUI/MessageUI.h>

#import "UIActivityViewController+Extensions.h"
#import "MoreWrapperViewController.h"

#import "DepositRequest.h"

#import <JLPermissions/JLNotificationPermission.h>
#import <MoEngage_iOS_SDK/MoEngage.h>

#import "Tokopedia-Swift.h"
#import "CMPopTipView.h"
@import BlocksKit;
@import NativeNavigation;

static NSString * const kPreferenceKeyTooltipSetting = @"Prefs.TooltipSetting";

@interface MoreViewController () <EtalaseViewControllerDelegate, CMPopTipViewDelegate, PointsAlertViewDelegate> {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    NSOperationQueue *_operationQueue;
    
    RKObjectManager *_objectmanager;
    BOOL _isNoDataDeposit, hasLoadViewWillAppear;
    NSTimer *_requestTimer;
    
    UISplitViewController *splitViewController;
    NavigateViewController *_navigate;
    
    TAGContainer *_gtmContainer;
    
    DepositRequest *_request;
    
    NSURL *_deeplinkUrl;
    
    BOOL _shouldDisplayPushNotificationCell;
    BOOL _shouldDisplayWalletCell;

    NSString* _walletApplink;

    BOOL _isWalletActive;
    CGRect _defaultTableFrame;
    BOOL _shouldShowAppShare;
    
    BOOL _hachikoEnabled;
    NSString *tokopointsMainpageUrl;
    
    NSInteger _profileCompleted;
}

@property (weak, nonatomic) IBOutlet UILabel *depositLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *completeProfileLabel;
@property (weak, nonatomic) IBOutlet UIButton *completeProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *verifiedAccountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedAccountIcon;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopIsGoldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UIButton *createShopButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSaldo;
@property (weak, nonatomic) IBOutlet UITableViewCell *shopCell;
@property (weak, nonatomic) IBOutlet UILabel *LPointLabel;

@property (weak, nonatomic) IBOutlet UILabel* walletBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel* walletNameLabel;
@property (weak, nonatomic) IBOutlet UIButton* walletActivationButton;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *appShareCell;
@property (strong, nonatomic) UIColor *progressBarTrack;
@property (strong, nonatomic) UIColor *progressBarColor;


@property (strong, nonatomic) CMPopTipView *popTipView;

@property (weak, nonatomic) IBOutlet UIView *viewTokopoints;
@property (weak, nonatomic) IBOutlet UIImageView *imgPointsTierView;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet UIButton *btnRedeemPoints;
@property (weak, nonatomic) IBOutlet UILabel *referralLabel;

@end

@implementation MoreViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSaldoTokopedia)
                                                     name:@"updateSaldoTokopedia"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateProfilePicture:)
                                                     name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShopPicture:)
                                                     name:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShopPicture:)
                                                     name:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShopInformation)
                                                     name:@"shopCreated"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(navigateToContactUs:)
                                                     name:@"navigateToContactUs" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapProfileCompletion)
                                                     name:@"openProfileCompletion" object:nil];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add logo in navigation bar
    self.title = kTKPDMORE_TITLE;
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    _navigate = [NavigateViewController new];
    
    _isNoDataDeposit  = YES;
    
    _isWalletActive = YES;
    
    _operationQueue = [[NSOperationQueue alloc] init];
    
    _fullNameLabel.text = [_auth objectForKey:@"full_name"];
    _versionLabel.text = [NSString stringWithFormat:@"Versi : %@", [UIApplication getAppVersionString]];
    
    // Remove default table inset
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    // Set round corner profile picture
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/20;
    self.profilePictureImageView.layer.borderColor = [UIColor colorWithRed:(224/255) green:(224/255) blue:(224/255) alpha:(0.1)].CGColor;
    self.profilePictureImageView.layer.borderWidth = 1.0;
    
    // Set round corner profile picture
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width/20;
    self.shopImageView.layer.borderColor = [UIColor colorWithRed:(224/255) green:(224/255) blue:(224/255) alpha:(0.1)].CGColor;
    self.shopImageView.layer.borderWidth = 1.0;
    
    // Set create shop button corner
    self.createShopButton.layer.cornerRadius = 2;
    
    //Load Deposit
    _depositLabel.hidden = YES;
    _loadingSaldo.hidden = NO;
    
    _request = [DepositRequest new];
    
    _profileCompleted = 0;
    
    [self updateShopInformation];
    [self configureGTM];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    [self togglePushNotificationCellVisibility];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidResume)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    _progressBar.layer.masksToBounds = true;
    _progressBar.layer.cornerRadius = 5;
    [self showProfileProgress];
    _shouldShowAppShare = NO;
    [self showHideAppShareCell];
    
    [_btnRedeemPoints setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0.01, 0)];
    
    [self updateReferralLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _hachikoEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"hachiko_enabled"];
    if (_hachikoEnabled) {
        _viewTokopoints.hidden = false;
    }
    else {
        _viewTokopoints.hidden = true;
    }
    
    // Universal Analytics
    [AnalyticsManager trackScreenName:@"More Navigation Page"];
    [self showProfileProgress];
    [self requestTokopoints];
    [self showHideAppShareCell];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.popTipView && self.popTipView != nil) {
        [self.popTipView dismissAnimated:NO];
        self.popTipView = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.tabBarController.title = @"More";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.popTipView = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:kPreferenceKeyTooltipSetting];
    [prefs synchronize];
}

- (void)showTooltipView {
    if(self.popTipView !=nil && ![self.popTipView isHidden])
        return;
    BOOL isTargetVisible = [self.tableView.indexPathsForVisibleRows bk_any:^(NSIndexPath *indexPath) {
        BOOL result = indexPath.row == 0 && indexPath.section == 1;
        return result;
    }];
    
    if(!isTargetVisible)
        return;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:kPreferenceKeyTooltipSetting] &&
        [[TouchIDHelper sharedInstance] isTouchIDAvailable] &&
        [[TouchIDHelper sharedInstance] numberOfConnectedAccounts] > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.popTipView != nil) {
                [self.popTipView dismissAnimated:NO];
            }
            self.popTipView = [[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"Pilih halaman setting dan pengaturan %@ untuk mengatur %@ Anda", [NSString authenticationType], [NSString authenticationType]]];
            self.popTipView.delegate = self;
            self.popTipView.backgroundColor = [UIColor darkGrayColor];
            self.popTipView.animation = CMPopTipAnimationPop;
            self.popTipView.dismissTapAnywhere = YES;
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [self.popTipView presentPointingAtView:cell inView:self.view animated:YES];
        });
    }
}

#pragma mark - Method
- (void)requestWallet {
    __weak typeof(self) weakSelf = self;
    [TokoCashUseCase requestBalanceWithCompletionHandler:^(WalletStore * wallet) {
        _walletNameLabel.text = wallet.data.text;
        _walletBalanceLabel.text = wallet.data.balance;
        _walletApplink = wallet.data.applinks;
        
        [weakSelf showActivationButton:wallet];
    } andErrorHandler:^(NSError * error) {
        _isWalletActive = YES;
        if (error.code == 3) {
            WalletAction *action = [[WalletAction alloc] initWithText:@"Aktivasi" redirectUrl:@"" applinks:@"" visibility:@"0"];
            WalletData *data = [[WalletData alloc] initWithAction:action balance:@"" rawBalance:0 totalBalance:@"" rawTotalBalance:0 holdBalance:@"" rawHoldBalance:0 rawThreshold:0 text:@"TokoCash" redirectUrl:@"" link:0 hasPendingCashback:NO applinks:@"tokopedia://wallet/activation" abTags:[[NSArray alloc] init]];
            WalletStore *wallet = [[WalletStore alloc] initWithCode:@"" message:@"" error:@"" data:data];
          
            _walletNameLabel.text = wallet.data.text;
            _walletBalanceLabel.text = wallet.data.balance;
            _walletApplink = wallet.data.applinks;
            
            [weakSelf showActivationButton:wallet];
            
        }else if(error.code == 9991) {
            
            [LogEntriesHelper logForceLogoutWithLastURL:[NSString stringWithFormat:@"%@%@", NSString.tokocashUrl, @"/api/v1/wallet/balance"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_FORCE_LOGOUT" object:nil userInfo:nil];
        }
    }];
}

- (void)showActivationButton:(WalletStore*)wallet {
    [_walletActivationButton setHidden:!wallet.shouldShowActivation];
    _isWalletActive = wallet.shouldShowActivation;
    [_walletActivationButton setTitle:wallet.data.action.text forState:UIControlStateNormal];
    [_walletActivationButton bk_whenTapped:^{
        [TPRoutes routeURL:[NSURL URLWithString:_walletApplink]];
    }];
}

- (void)appDidResume {
    [self togglePushNotificationCellVisibility];
}

- (BOOL)isBadgeNotificationTurnedOn {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
        return application.currentUserNotificationSettings.types & UIUserNotificationTypeBadge;
    } else {
        return application.enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
    }
}

- (void)togglePushNotificationCellVisibility {
    BOOL isPushNotificationAuthorized = [JLNotificationPermission sharedInstance].authorizationStatus != JLPermissionDenied;
    
    _shouldDisplayPushNotificationCell = !isPushNotificationAuthorized || ![self isBadgeNotificationTurnedOn];
    
    [self.tableView reloadData];
}

-(void)updateShopPicture:(NSNotification*)notif
{
    NSDictionary *userInfo = notif.userInfo;
    
    NSString *strAvatar = [userInfo objectForKey:@"file_th"]?:@"";
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:strAvatar withKey:@"shop_avatar"];
    _auth = [[secureStorage keychainDictionary] mutableCopy];
    
    [self updateShopInformation];
}

- (void)updateShopInformation {
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    UserAuthentificationManager *authManager = [UserAuthentificationManager new];
    NSURL *profilePictureURL = [NSURL URLWithString:[authManager.getUserLoginData objectForKey:@"user_image"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:profilePictureURL];
    [_profilePictureImageView setImageWithURLRequest:request
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                                 [_profilePictureImageView setImageWithURL: profilePictureURL placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]];
#pragma clang diagnostic pop
                                             } failure: nil];
    
    if([_auth objectForKey:@"shop_id"]) {
        if([_auth objectForKey:@"shop_name"]) {
            _shopNameLabel.text = [[NSString stringWithFormat:@"%@", [_auth objectForKey:@"shop_name"]] mutableCopy];
        }
        
        NSString *strAvatar = [[_auth objectForKey:@"shop_avatar"] isMemberOfClass:[NSString class]]? [_auth objectForKey:@"shop_avatar"] : [NSString stringWithFormat:@"%@", [_auth objectForKey:@"shop_avatar"]];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strAvatar]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        [_shopImageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                           [_shopImageView setImage:image];
#pragma clang diagnostic pop
                                       } failure: nil];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_shopIsGoldLabel.frame.origin.x,
                                                                               _shopIsGoldLabel.frame.origin.y,
                                                                               22, 22)];
        
        [_shopCell addSubview:imageView];
        
        NSDictionary<NSString *, NSDictionary *> *display = @{
                                                              @(ShopTypeRegular): @{
                                                                      @"label": @"Regular Merchant",
                                                                      @"image": [UIImage new]
                                                                      },
                                                              @(ShopTypeGold): @{
                                                                      @"label": @"        Gold Merchant",
                                                                      @"image": [UIImage imageNamed:@"Badges_gold_merchant"]
                                                                      },
                                                              @(ShopTypeOfficial): @{
                                                                      @"label": @"        Official Merchant",
                                                                      @"image": [UIImage imageNamed:@"badge_official_small"]
                                                                      }
                                                              };
        
        ShopType shopType = authManager.shopType;
        _shopIsGoldLabel.text = (NSString *)display[@(shopType)][@"label"];
        imageView.image = (UIImage *)display[@(shopType)][@"image"];
    }
    [self.tableView reloadData];
}

- (void)showHideAppShareCell {
    [ReferralRemoteConfig.shared shouldShowAppShareOnCompletion:^(BOOL show) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _shouldShowAppShare = show;
            [self.appShareCell setHidden:!show];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row == 0) {
        [self showTooltipView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.3")) {
                return 2;
            } else {
                if (_isWalletActive) {
                    return 2;
                } else {
                    return 1;
                }
            }
        }
        case 1: return 3;
        case 2:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 6;
            else return 0;
            break;
            
        case 3:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 0;
            else return 1;
            break;
            
        case 4:
            return [[[UserAuthentificationManager alloc] init] userHasShop] ? 5 : 4;
            break;
            
        case 5:
            return [[[UserAuthentificationManager alloc] init] userHasShop] ? 2 : 1;
            break;
            
        case 6:
            return 4;
            break;
            
        case 7:
            return _shouldDisplayPushNotificationCell?1:0;
            break;
            
        case 8 :
            return 1;
            break;
            
        default:
            break;
    }
    return 1;
}

#pragma mark - Table delegate
/*
 why we need to wrap more vc ?
 objective : to simply reduce the width of the table
 problem : morevc is a tableviewcontroller, that is why it has no self.view, and we need to shrink the view, not the tableview
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
        switch (indexPath.row) {
            case 0: {
                return 200;
            }
            default:
                return 52;
        }
        case 2:
        switch (indexPath.row) {
                case 0: return 120;
            default:
                return 52;
        }
        case 3:
            switch (indexPath.row) {
                case 0: return 127;
                default:
                    return 52;
            }
        case 4:
            switch (indexPath.row) {
                case 0: return 90;
                default:
                    return 52;
            }
        case 5:
            switch (indexPath.row) {
                case 0: return 90;
                default:
                    return 52;
            }
        case 6:
            switch (indexPath.row) {
                case 0:
                    if (_shouldShowAppShare) {
                        return 52;
                    } else {
                        return 0;
                    }
                default:
                    return 52;
            }
        default:
            return 52;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _wrapperViewController.hidesBottomBarWhenPushed = YES;
    UIViewController* wrapperController = _wrapperViewController;
    
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            if(![_depositLabel.text isEqualToString:@"-"]) {
                DepositSummaryViewController *depositController = [DepositSummaryViewController new];
                depositController.data = @{@"total_saldo":_depositLabel.text};
                [wrapperController.navigationController pushViewController:depositController animated:YES];
                [AnalyticsManager trackClickNavigateFromMore:@"Saldo" parent:@"Header Saldo"];
            }
        } else if (indexPath.row == 1) {
            if (!_isWalletActive) {
                [TPRoutes routeURL:[NSURL URLWithString:_walletApplink]];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            [AnalyticsManager trackClickNavigateFromMore:@"TokoCash" parent:@"Header TokoCash"];

        }
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                [AnalyticsManager trackClickNavigateFromMore:@"Profile" parent:MORE_SECTION_1];
                
                UserAuthentificationManager *auth = [UserAuthentificationManager new];
                NSString *userID = [auth getUserId];
                
                [TPRoutes routeURL:[NSURL URLWithString:[NSString stringWithFormat:@"tokopedia://people/%@", userID]]];
            }
                break;
            case 1: {
                [AnalyticsManager trackClickNavigateFromMore:@"Pembelian" parent:MORE_SECTION_1];
                PurchaseViewController *purchaseController = [PurchaseViewController new];
                purchaseController.hidesBottomBarWhenPushed = YES;
                [wrapperController.navigationController pushViewController:purchaseController animated:YES];
            }
                break;
            case 2:
                [AnalyticsManager trackClickNavigateFromMore:@"Wishlist" parent:MORE_SECTION_1];
                [wrapperController.tabBarController setSelectedIndex:2];
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
        UserAuthentificationManager *authenticationManager = [UserAuthentificationManager new];
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Shop" parent:MORE_SECTION_2];
            ShopViewController *container = [[ShopViewController alloc] init];
            container.data = @{MORE_SHOP_ID : authenticationManager.getShopId,
                               MORE_AUTH : _auth,
                               MORE_SHOP_NAME : authenticationManager.getShopName
                               };
            [wrapperController.navigationController pushViewController:container animated:YES];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Penjualan" parent:MORE_SECTION_2];
            SalesViewController *salesController = [SalesViewController new];
            salesController.hidesBottomBarWhenPushed = YES;
            [wrapperController.navigationController pushViewController:salesController animated:YES];
        } else if (indexPath.row == 2) {
            UIViewController *addProductViewController = [[ReactViewController alloc] initWithModuleName:@"AddProductScreen" props: @{@"authInfo": [authenticationManager getUserLoginData]}];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:addProductViewController];
            navigation.navigationBar.translucent = NO;
            [self.navigationController presentViewController: navigation animated:YES completion:nil];
        } else if (indexPath.row == 3) {
            [AnalyticsManager trackClickNavigateFromMore:@"Daftar Produk" parent:MORE_SECTION_2];
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:_auth?:@{}};
            vc.hidesBottomBarWhenPushed = YES;
            [wrapperController.navigationController pushViewController:vc animated:YES];
        } else if(indexPath.row == 4) {
            [AnalyticsManager trackClickNavigateFromMore:@"Etalase" parent:MORE_SECTION_2];
            
            UIViewController *addProductViewController = [[ReactViewController alloc] initWithModuleName:@"ManageShowcaseScreen"
                                                                                                   props: @{
                                                                                                            @"authInfo": [authenticationManager getUserLoginData],
                                                                                                            @"action": @"manage"
                                                                                                            }];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addProductViewController animated:YES];
            return;
        } else if(indexPath.row == 5) {
            [AnalyticsManager trackClickNavigateFromMore:@"TopAds" parent:MORE_SECTION_2];
            [TPRoutes routeURL:[NSURL URLWithString: @"tokopedia://topads/dashboard"]];
        }
    }
    else if (indexPath.section == 4) {
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"TopChat" parent: MORE_SECTION_4];
            [TPRoutes routeURL:[NSURL URLWithString: @"tokopedia://topchat"]];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Diskusi" parent:MORE_SECTION_4];
            [_navigate navigateToInboxTalkFromViewController:wrapperController];
        } else if (indexPath.row == 2) {
            [AnalyticsManager trackClickNavigateFromMore:@"Ulasan" parent:MORE_SECTION_4];
            [TPRoutes routeURL:[NSURL URLWithString: @"tokopedia://review"]];
            _wrapperViewController.hidesBottomBarWhenPushed = NO;
            return;
        } else if (indexPath.row == 3) {
            [AnalyticsManager trackClickNavigateFromMore:@"Layanan Pengguna" parent:MORE_SECTION_4];
            
            UserAuthentificationManager* userManager = [UserAuthentificationManager new];
            
            WKWebViewController *wkWebViewController = [[WKWebViewController new] initWithUrlString:[userManager webViewUrlFromUrl:@"https://m.tokopedia.com/help/ticket-list/mobile"] title:@"Help"];
            
            [wrapperController.navigationController pushViewController:wkWebViewController animated:YES];
        } else if (indexPath.row == 4) {
            [AnalyticsManager trackSellerInfoMenuClick];
            SellerInfoInboxViewController *controller = [SellerInfoInboxViewController new];
            controller.hidesBottomBarWhenPushed = YES;
            [wrapperController.navigationController pushViewController:controller animated:YES];
        }
    }
    else if (indexPath.section == 5) {
        ComplaintUserType userType = ComplaintUserTypeCustomer;
        if (indexPath.row == 1) {
            userType = ComplaintUserTypeSeller;
        }
        ComplaintsViewController *vc = [[ComplaintsViewController alloc] initWithUserType: userType];
        vc.hidesBottomBarWhenPushed = true;
        [wrapperController.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Share ke Teman" parent:MORE_SECTION_OTHERS];
            [self shareToFriend];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Hubungi Kami" parent:MORE_SECTION_OTHERS];
            [NavigateViewController navigateToContactUsFromViewController:wrapperController];
        } else if(indexPath.row == 2) {
            [AnalyticsManager trackClickNavigateFromMore:@"Kebijakan & Privasi" parent:MORE_SECTION_OTHERS];
            [AnalyticsManager trackScreenName:@"Privacy Policy"];
            
            WebViewController *webViewController = [WebViewController new];
            webViewController.strURL = kTKPDMORE_PRIVACY_URL;
            webViewController.strTitle = kTKPDMORE_PRIVACY_TITLE;
            [wrapperController.navigationController pushViewController:webViewController animated:YES];
        } else if(indexPath.row == 3) {
            [AnalyticsManager trackClickNavigateFromMore:@"Bagikan Aplikasi" parent:MORE_SECTION_OTHERS];
            [AnalyticsManager trackScreenName:@"Share App"];
            [ReferralRemoteConfig.shared getAppShareDescriptionOnCompletion:^(NSString * _Nonnull description) {
                AppSharing *appSharing = [AppSharing new];
                appSharing.buoDescription = description;
                [[ReferralManager new] shareWithObject:appSharing from: wrapperController anchor:[tableView cellForRowAtIndexPath:indexPath]];
            }];
        }
    }
    else if (indexPath.section == 7) {
        [AnalyticsManager trackClickNavigateFromMore:@"Push Notifikasi" parent:MORE_SECTION_OTHERS];
        [self activatePushNotification];
    }
    else if (indexPath.section == 8) {
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Keluar" parent:MORE_SECTION_OTHERS];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION
                                                                object:nil
                                                              userInfo:@{}];
        }
        
    }
    
    _wrapperViewController.hidesBottomBarWhenPushed = NO;
}

- (void)activatePushNotification {
    [[MoEngage sharedInstance] registerForRemoteNotificationWithCategories:nil andCategoriesForPreviousVersions:nil andWithUserNotificationCenterDelegate:self];
    JLNotificationPermission *permission = [JLNotificationPermission sharedInstance];
    
    JLAuthorizationStatus permissionStatus = permission.authorizationStatus;
    
    if (permissionStatus == JLPermissionNotDetermined) {
        permission.extraAlertEnabled = false;
        [permission authorize: ^(NSString *deviceId, NSError *error) {
            [AnalyticsManager trackPushNotificationAccepted:deviceId != nil];
            [self togglePushNotificationCellVisibility];
        }];
    } else {
        ActivatePushInstructionViewController *viewController = [ActivatePushInstructionViewController new];
        
        viewController.viewControllerDidClosed = ^{
            [AnalyticsManager trackOpenPushNotificationSetting];
            [[JLNotificationPermission sharedInstance] displayAppSystemSettings];
        };
        [_wrapperViewController presentViewController:viewController animated:YES completion:nil];
    }
}

#pragma mark - Referral
- (void)shareToFriend {
    [ReferralRemoteConfig.shared showReferralCodeOnCompletion:^(BOOL show) {
        [self showReferralScreen:show];
    }];
}

- (void)showReferralScreen:(BOOL) show {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Referral" bundle:nil];
    UIViewController *viewController = nil;
    if ([_walletActivationButton isHidden] || !show) {
        viewController = [storyboard instantiateInitialViewController];
        viewController.hidesBottomBarWhenPushed = YES;
    } else {
        if ([UserAuthentificationManager new].isUserPhoneVerified) {
            TokoCashActivationViewController *tokoCashActivationVC = [TokoCashActivationViewController new];
            tokoCashActivationVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:tokoCashActivationVC animated:YES];
        } else {
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"VerifyPhoneTableViewController"];
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)updateReferralLabel {
    [ReferralRemoteConfig.shared showReferralCodeOnCompletion:^(BOOL show) {
        if (show) {
            self.referralLabel.text = @"Dapatkan TokoCash";
        } else {
            self.referralLabel.text = @"Share ke Teman";
        }
    }];
}

- (void)navigateToContactUs:(NSNotification*)notification{
    [NavigateViewController navigateToContactUsFromViewController:_wrapperViewController];
}

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [_wrapperViewController.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Action
- (IBAction)actionCreateShop:(id)sender
{
    OpenShopViewController *controller = [[OpenShopViewController alloc] initWithNibName:@"OpenShopViewController" bundle:nil];
    [self pushViewController:controller];
}

- (void)updateSaldoTokopedia {
    [self requestWallet];
    [_request requestGetDepositOnSuccess:^(DepositResult *result) {
        _depositLabel.text = result.deposit_total;
        _depositLabel.hidden = NO;
        _loadingSaldo.hidden = YES;
        [_loadingSaldo stopAnimating];
        _isNoDataDeposit = NO;
    } onFailure:^(NSError *errorResult) {
        
        
    }];
}

- (void)updateProfilePicture:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *strAvatar = [userInfo objectForKey:@"file_th"]?:@"";
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:strAvatar withKey:@"user_image"];
    _auth = [[secureStorage keychainDictionary] mutableCopy];
    
    UIImage *profilePicture = [notification.userInfo objectForKey:@"profile_img"];
    _profilePictureImageView.image = profilePicture;
}

- (IBAction)tapInfoTopPoints:(id)sender {
    NSString *urlString = [_gtmContainer stringForKey:@"string_notify_buyer_link"]?:@"http://blog.tokopedia.com";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - GTM
- (void)configureGTM {
    [AnalyticsManager trackUserInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
}

#pragma mark - Email delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.wrapperViewController.navigationController dismissViewControllerAnimated:YES completion:^() {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        //undesired changes from tableview frame when setStatusBarHidden
        //need to reframe tableView
        self.tableView.frame = _defaultTableFrame;
    }];
}


#pragma mark - SplitVC Delegate
- (void)deallocVC {
    splitViewController = nil;
}


#pragma mark - profile completion
- (IBAction)tapProfileCompletion {
    ProfileCompletionProgressViewController *progressController = [ProfileCompletionProgressViewController new];
    progressController.hidesBottomBarWhenPushed = YES;
    [AnalyticsManager trackEventName:@"profileCompletion" category: @"Profile" action: GA_EVENT_ACTION_CLICK label: @"Verify"];
    [self pushViewController:progressController];
}

-(void)showProfileProgress {
    self.progressBar.hidden = false;
    self.completeProfileButton.hidden = true;
    self.progressLabel.hidden = false;
    self.completeProfileLabel.hidden = false;
    
    _verifiedAccountIcon.hidden = true;
    _verifiedAccountLabel.hidden = true;
    _verifiedAccountLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.54];
    
    [UserRequest getUserCompletionOnSuccess:^(ProfileCompletionInfo *profileInfo) {
        _profileCompleted = profileInfo.completion;
        //progress color
        self.progressBarTrack = [UIColor colorWithRed:200.0/225.0 green:200.0/225.0 blue:200.0/225.0 alpha:1];
        self.progressBarColor = [UIColor colorWithRed:175.0/225.0 green:213.0/225.0 blue:100.0/225.0 alpha:1]; //default: 0.5
        self.progressLabel.text = @"50%";
        if (_profileCompleted == 60) {
            self.progressBarColor = [UIColor colorWithRed:127.0/225.0 green:190.0/225.0 blue:51.0/225.0 alpha:1];
            self.progressLabel.text = @"60%";
        } else if (_profileCompleted == 70) {
            self.progressBarColor = [UIColor colorWithRed:78.0/225.0 green:188.0/225.0 blue:74.0/225.0 alpha:1];
            self.progressLabel.text = @"70%";
        } else if (_profileCompleted == 80) {
            self.progressBarColor = [UIColor colorWithRed:39.0/225.0 green:160.0/225.0 blue:46.0/225.0 alpha:1];
            self.progressLabel.text = @"80%";
        } else if (_profileCompleted == 90) {
            self.progressBarColor = [UIColor colorWithRed:8.0/225.0 green:132.0/225.0 blue:31.0/225.0 alpha:1];
            self.progressLabel.text = @"90%";
        } else if (_profileCompleted == 100) {
            self.progressBarColor = [UIColor colorWithRed:0.0/225.0 green:112.0/225.0 blue:20.0/225.0 alpha:1];
            self.progressLabel.text = @"100%";
            _verifiedAccountLabel.hidden = false;
            _verifiedAccountIcon.hidden = false;
        }
        double progress = _profileCompleted/100.0;
        [self.progressBar setProgress:progress animated:true];
        [self.progressBar setTrackTintColor:self.progressBarTrack];
        [self.progressBar setProgressTintColor:self.progressBarColor];
        
        if (_profileCompleted < 100) {
            self.completeProfileButton.hidden = false;
        }
        
        [self.tableView reloadData];
        
    } onFailure:^() {
        [self.tableView reloadData];
    }];
}

- (IBAction)btnRedeemPointsDidTapped:(id)sender {
    [AnalyticsManager trackEventName:GA_EVENT_NAME_TOKOPOINTS category:@"tokopoints - user profile page" action:@"click tokopoints" label:@"tokopoints"];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    WebViewController *webView = [WebViewController new];
    webView.strURL = [auth webViewUrlFromUrl:tokopointsMainpageUrl];
    webView.strTitle = @"TokoPoints";
    webView.shouldAuthorizeRequest = true;
    webView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webView animated:YES];
    webView.hidesBottomBarWhenPushed = NO;
}

- (void)requestTokopoints {
    [TokopointsService getDrawerDataOnSuccess:^(DrawerData * drawerData) {
        if ([drawerData.offFlag isEqualToString:@"0"]) {
            // hachiko enabled
            _hachikoEnabled = true;
            _viewTokopoints.hidden = false;
            [self showProfileProgress];
            
            _lblPoints.text = drawerData.userTier.rewardPointsString;
            [_imgPointsTierView setBackgroundColor:[UIColor tpGray]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:drawerData.userTier.tierImageUrl]];
            [_imgPointsTierView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_imgPointsTierView setImage:image];
                [_imgPointsTierView setBackgroundColor:nil];
            } failure:nil];
            
            if ([drawerData.hasNotification isEqualToString:@"1"]) {
                [AnalyticsManager trackEventName:GA_EVENT_NAME_TOKOPOINTS category:@"tokopoints - pop up" action:@"impression on any pop up" label:@"pop up"];
                
                PointsAlertViewButton *button = [PointsAlertViewButton buttonWithType:UIButtonTypeSystem];
                [button initializeWithTitle:drawerData.popUpNotification.buttonText titleColor:[UIColor tpGreen] image:nil alignment:NSTextAlignmentCenter callback:^{
                    [AnalyticsManager trackEventName:GA_EVENT_NAME_TOKOPOINTS category:@"tokopoints - pop up" action:@"click any pop up button" label:@"pop up button"];
                    
                    UserAuthentificationManager *auth = [UserAuthentificationManager new];
                    WebViewController *webView = [WebViewController new];
                    webView.strURL = [auth webViewUrlFromUrl:drawerData.popUpNotification.buttonUrl];
                    webView.shouldAuthorizeRequest = true;
                    webView.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webView animated:YES];
                    webView.hidesBottomBarWhenPushed = NO;
                }];
                
                PointsAlertView *alertView = [[PointsAlertView alloc] initWithTitle:drawerData.popUpNotification.title image:nil imageUrl:drawerData.popUpNotification.imageUrl message:drawerData.popUpNotification.text buttons:@[button]];
                alertView.delegate = self;
                [alertView showSelfWithAnimated:true];
            }
            
            tokopointsMainpageUrl = drawerData.mainpageUrl;
        }
        else {
            // hachiko disabled
            _hachikoEnabled = false;
            _viewTokopoints.hidden = true;
            [self showProfileProgress];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:_hachikoEnabled forKey:@"hachiko_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tableView reloadData];
    } onFailure:^(NSError * error) {
        NSLog(@"%@", error.localizedDescription);
        
        // hachiko disabled
        _hachikoEnabled = false;
        _viewTokopoints.hidden = true;
        [self showProfileProgress];
        
        [[NSUserDefaults standardUserDefaults] setBool:_hachikoEnabled forKey:@"hachiko_enabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tableView reloadData];
    }];
}

- (void)didDismissed:(PointsAlertView *)pointsAlertView {
    [AnalyticsManager trackEventName:GA_EVENT_NAME_TOKOPOINTS category:@"Tokopoint - Notification" action:@"click close button" label:@"close"];
}

@end
