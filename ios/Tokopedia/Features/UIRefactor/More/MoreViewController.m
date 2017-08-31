//
//  MoreViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "SplitReputationViewController.h"
#import "MyReviewReputationViewController.h"
#import "SegmentedReviewReputationViewController.h"
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

#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"

#import "ShopFavoritedViewController.h"
#import "EtalaseViewController.h"

#import "InboxTicketSplitViewController.h"
#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabViewController.h"
#import "InboxTicketViewController.h"

#import "InboxTalkViewController.h"
#import "NotificationManager.h"

#import "TKPDTabInboxTalkNavigationController.h"
#import "DepositSummaryViewController.h"
#import "UserContainerViewController.h"
#import "ProductListMyShopViewController.h"
#import "InboxResolutionCenterTabViewController.h"
#import "InboxResolSplitViewController.h"
#import "NavigateViewController.h"

#import "NavigateViewController.h"
#import "LoyaltyPoint.h"

#import <MessageUI/MessageUI.h>

#import "UIActivityViewController+Extensions.h"
#import "MoreWrapperViewController.h"

#import "DepositRequest.h"

#import <JLPermissions/JLNotificationPermission.h>
#import <MoEngage_iOS_SDK/MoEngage.h>

#import "Tokopedia-Swift.h"
#import "CMPopTipView.h"
@import BlocksKit;

static NSString * const kPreferenceKeyTooltipSetting = @"Prefs.TooltipSetting";

@interface MoreViewController () <NotificationManagerDelegate, SplitReputationVcProtocol, EtalaseViewControllerDelegate, CMPopTipViewDelegate> {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    NSOperationQueue *_operationQueue;
    
    RKObjectManager *_objectmanager;
    BOOL _isNoDataDeposit, hasLoadViewWillAppear;
    NotificationManager *_notifManager;
    NSTimer *_requestTimer;
    
    UISplitViewController *splitViewController;
    NavigateViewController *_navigate;
    
    LoyaltyPointResult *_LPResult;
    TAGContainer *_gtmContainer;
    
    DepositRequest *_request;
    
    NSURL *_deeplinkUrl;
    
    BOOL _shouldDisplayPushNotificationCell;
    BOOL _shouldDisplayWalletCell;
    BOOL _shouldDisplayTopPointsCell;
    NSString* _walletUrl;
    BOOL _isWalletActive;
    CGRect _defaultTableFrame;
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
@property (strong, nonatomic) UIColor *progressBarTrack;
@property (strong, nonatomic) UIColor *progressBarColor;


@property (strong, nonatomic) CMPopTipView *popTipView;

@end

@implementation MoreViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadNotification)
                                                     name:@"reloadNotification"
                                                   object:nil];
        
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Universal Analytics
    [AnalyticsManager trackScreenName:@"More Navigation Page"];
    
    [self showProfileProgress];
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
        BOOL result = indexPath.row == 0 && indexPath.section == 2;
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
            self.popTipView = [[CMPopTipView alloc] initWithMessage:@"Pilih halaman setting dan pengaturan Touch ID untuk mengatur Touch ID anda"];
            self.popTipView.delegate = self;
            self.popTipView.backgroundColor = [UIColor darkGrayColor];
            self.popTipView.animation = CMPopTipAnimationPop;
            self.popTipView.dismissTapAnywhere = YES;
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            [self.popTipView presentPointingAtView:cell inView:self.view animated:YES];
        });
    }
}

#pragma mark - Method
- (void)requestWallet {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    __weak typeof(self) weakSelf = self;
    
    [WalletService getBalance:[userManager getUserId]
                    onSuccess:^(WalletStore * wallet) {
                        if (wallet.isExpired) {
                            [weakSelf requestWalletWithNewToken];
                        } else {
                            _walletNameLabel.text = wallet.data.text;
                            _walletBalanceLabel.text = wallet.data.balance;
                            _walletUrl = wallet.walletFullUrl;
                            
                            [weakSelf showActivationButton:wallet];
                        }
                        
                    }
                    onFailure:^(NSError * error) {
                        _isWalletActive = NO;
                        if(error.code == 9991) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_FORCE_LOGOUT" object:nil userInfo:nil];
                        }
                    }];
}

- (void)requestWalletWithNewToken {
    __weak typeof(self) weakSelf = self;
    
    [[AuthenticationService sharedService]
     getNewTokenOnSuccess:^(OAuthToken *token) {
         [weakSelf requestWallet];
     }
     onFailure:^{
         [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_FORCE_LOGOUT" object:nil userInfo:nil];
     }];
}

- (void)showActivationButton:(WalletStore*)wallet {
    [_walletActivationButton setHidden:!wallet.shouldShowActivation];
    _isWalletActive = wallet.shouldShowActivation;
    [_walletActivationButton setTitle:wallet.data.action.text forState:UIControlStateNormal];
    [_walletActivationButton bk_whenTapped:^{
        [TPRoutes routeURL:[NSURL URLWithString:  wallet.data.action.applinks]];
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
                                                 //NSLOG(@"thumb: %@", thumb);
                                                 [_profilePictureImageView setImage:image];
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

#pragma mark - Table view data source

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 2 && indexPath.row == 0) {
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
            
        case 1: return _shouldDisplayTopPointsCell?1:0;
        case 2:
            return 3;
            break;
            
        case 3:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 4;
            else return 0;
            break;
            
        case 4:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 0;
            else return 1;
            break;
            
        case 5:
            return 5;
            break;
            
        case 6:
            return 3;
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
                [AnalyticsManager trackClickNavigateFromMore:@"Saldo"];
            }
        } else if (indexPath.row == 1) {
            if (!_isWalletActive) {
                UserAuthentificationManager* userManager = [UserAuthentificationManager new];
                WKWebViewController *controller = [[WKWebViewController alloc] initWithUrlString: [userManager webViewUrlFromUrl:_walletUrl] shouldAuthorizeRequest:YES];
                controller.title = _walletNameLabel.text;
                __weak typeof(WKWebViewController) *wcontroller = controller;
                controller.didTapBack = ^{
                    [wcontroller.navigationController popViewControllerAnimated:YES];
                };
                
                [_wrapperViewController.navigationController pushViewController:controller animated:YES];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        UserAuthentificationManager* userManager = [UserAuthentificationManager new];
        WebViewController *webViewController = [WebViewController new];
        
        webViewController.isLPWebView = YES;
        webViewController.shouldAuthorizeRequest = YES;
        webViewController.strURL = [userManager webViewUrlFromUrl: _LPResult.uri];
        webViewController.strTitle = @"TopPoints";
        [AnalyticsManager trackScreenName:@"Top Points Page"];
        [AnalyticsManager trackClickNavigateFromMore:@"TopPoints"];
        [wrapperController.navigationController pushViewController:webViewController animated:YES];
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        NavigateViewController *navigateController = [NavigateViewController new];
        [AnalyticsManager trackClickNavigateFromMore:@"Profile"];
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        [navigateController navigateToProfileFromViewController:wrapperController withUserID:auth.getUserId];
    }
    
    else if (indexPath.section == 2 && indexPath.row == 1) {
        [AnalyticsManager trackClickNavigateFromMore:@"Buy"];
        
        PurchaseViewController *purchaseController = [PurchaseViewController new];
        purchaseController.notification = _notifManager.notification;
        purchaseController.hidesBottomBarWhenPushed = YES;
        [wrapperController.navigationController pushViewController:purchaseController animated:YES];
        
    }
    else if(indexPath.section == 2 && indexPath.row == 2) {
        [AnalyticsManager trackClickNavigateFromMore:@"Wishlist"];
        [wrapperController.tabBarController setSelectedIndex:2];
    }
    
    else if (indexPath.section == 3) {
        if(indexPath.row == 0) {
            UserAuthentificationManager *authenticationManager = [UserAuthentificationManager new];
            
            [AnalyticsManager trackClickNavigateFromMore:@"Shop"];
            ShopViewController *container = [[ShopViewController alloc] init];
            container.data = @{MORE_SHOP_ID : authenticationManager.getShopId,
                               MORE_AUTH : _auth,
                               MORE_SHOP_NAME : authenticationManager.getShopName
                               };
            [wrapperController.navigationController pushViewController:container animated:YES];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Sales"];
            SalesViewController *salesController = [SalesViewController new];
            salesController.notification = _notifManager.notification;
            salesController.hidesBottomBarWhenPushed = YES;
            [wrapperController.navigationController pushViewController:salesController animated:YES];
        } else if (indexPath.row == 2) {
            [AnalyticsManager trackClickNavigateFromMore:@"Product List"];
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:_auth?:@{}};
            vc.hidesBottomBarWhenPushed = YES;
            [wrapperController.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 3) {
            [AnalyticsManager trackClickNavigateFromMore:@"Etalase"];
            EtalaseViewController *vc = [EtalaseViewController new];
            vc.delegate = self;
            vc.isEditable = YES;
            vc.showOtherEtalase = NO;
            [vc setEnableAddEtalase:YES];
            vc.hidesBottomBarWhenPushed = YES;
            
            NSString* shopId = [_auth objectForKey:MORE_SHOP_ID]?:@{};
            [vc setShopId:shopId];
            [wrapperController.navigationController pushViewController:vc animated:YES];
            
        }
        
    }
    
    else if (indexPath.section == 5) {
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Message"];
            [_navigate navigateToInboxMessageFromViewController:wrapperController];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Product Discussion"];
            [_navigate navigateToInboxTalkFromViewController:wrapperController];
        } else if (indexPath.row == 2) {
            [AnalyticsManager trackClickNavigateFromMore:@"Review"];
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                splitViewController = [UISplitViewController new];
                
                SplitReputationViewController *splitReputationViewController = [SplitReputationViewController new];
                splitReputationViewController.splitViewController = splitViewController;
                splitReputationViewController.del = self;
                [wrapperController.navigationController pushViewController:splitReputationViewController animated:YES];
            }
            else  {
                SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
                segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
                segmentedReputationViewController.userHasShop = ([_auth objectForKey:@"shop_id"] && [[_auth objectForKey:@"shop_id"] integerValue] > 0);
                [wrapperController.navigationController pushViewController:segmentedReputationViewController animated:YES];
            }
        } else if (indexPath.row == 3) {
            [AnalyticsManager trackClickNavigateFromMore:@"Help"];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                InboxTicketSplitViewController *controller = [InboxTicketSplitViewController new];
                
                [wrapperController.navigationController pushViewController:controller animated:YES];
            } else {
                TKPDTabViewController *controller = [TKPDTabViewController new];
                controller.hidesBottomBarWhenPushed = YES;
                controller.inboxType = InboxTypeTicket;
                
                InboxTicketViewController *allInbox = [InboxTicketViewController new];
                allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
                allInbox.delegate = controller;
                allInbox.onTapContactUsButton = ^{
                    [NavigateViewController navigateToContactUsFromViewController:_wrapperViewController];
                };
                
                InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
                unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
                unreadInbox.delegate = controller;
                unreadInbox.onTapContactUsButton = ^{
                    [NavigateViewController navigateToContactUsFromViewController:_wrapperViewController];
                };
                
                InboxTicketViewController *closedInbox = [InboxTicketViewController new];
                closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
                closedInbox.delegate = controller;
                closedInbox.onTapContactUsButton = ^{
                    [NavigateViewController navigateToContactUsFromViewController:_wrapperViewController];
                };
                
                controller.viewControllers = @[allInbox, unreadInbox, closedInbox];
                controller.tabTitles = @[@"Semua", @"Dalam Proses", @"Ditutup"];
                controller.menuTitles = @[@"Semua Layanan Pengguna", @"Belum Dibaca"];
                
                [wrapperController.navigationController pushViewController:controller animated:YES];
            }
        } else if (indexPath.row == 4) {
            [AnalyticsManager trackClickNavigateFromMore:@"Resolution Center"];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                InboxResolSplitViewController *controller = [InboxResolSplitViewController new];
                controller.hidesBottomBarWhenPushed = YES;
                [wrapperController.navigationController pushViewController:controller animated:YES];
                
            } else {
                InboxResolutionCenterTabViewController *controller = [InboxResolutionCenterTabViewController new];
                controller.hidesBottomBarWhenPushed = YES;
                [wrapperController.navigationController pushViewController:controller animated:YES];
            }
        }
    }
    
    else if (indexPath.section == 6) {
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Contact Us"];
            [NavigateViewController navigateToContactUsFromViewController:wrapperController];
        } else if(indexPath.row == 1) {
            [AnalyticsManager trackClickNavigateFromMore:@"Privacy"];
            [AnalyticsManager trackScreenName:@"Privacy Policy"];
            
            WebViewController *webViewController = [WebViewController new];
            webViewController.strURL = kTKPDMORE_PRIVACY_URL;
            webViewController.strTitle = kTKPDMORE_PRIVACY_TITLE;
            [wrapperController.navigationController pushViewController:webViewController animated:YES];
        } else if(indexPath.row == 2) {
            [AnalyticsManager trackClickNavigateFromMore:@"Share Application"];
            [AnalyticsManager trackScreenName:@"Share App"];
            
            NSString *title = @"Download Aplikasi Tokopedia Sekarang Juga! \nNikmati kemudahan jual beli online di tanganmu.";
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/id/app/tokopedia/id1001394201"];
            UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                              url:url
                                                                                           anchor:[tableView cellForRowAtIndexPath:indexPath]];
            
            [wrapperController presentViewController:controller animated:YES completion:nil];
        }
    }
    
    else if (indexPath.section == 7) {
        [AnalyticsManager trackClickNavigateFromMore:@"Push Notification"];
        [self activatePushNotification];
    }
    
    else if (indexPath.section == 8) {
        if(indexPath.row == 0) {
            [AnalyticsManager trackClickNavigateFromMore:@"Sign Out"];
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

#pragma mark - Notification Manager

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:_wrapperViewController];
    _notifManager.delegate = _wrapperViewController;
    _wrapperViewController.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

//
//- (void)tapNotificationBar {
//    [_notifManager tapNotificationBar];
//}
//
//- (void)tapWindowBar {
//    [_notifManager tapWindowBar];
//}

- (void)navigateToContactUs:(NSNotification*)notification{
    [NavigateViewController navigateToContactUsFromViewController:_wrapperViewController];
}

#pragma mark - Notification delegate
- (void)reloadNotification
{
    [self initNotificationManager];
}
//
//- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
//{
//    [notificationManager tapWindowBar];
//    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
//}
//
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
        
        [self requestTopPoint];
    } onFailure:^(NSError *errorResult) {
        
        
    }];
}

-(void)requestTopPoint{
    [TopPointRequest fetchTopPoint:^(LoyaltyPointResult * data) {
        
        _LPResult = data;
        _LPointLabel.text = data.loyalty_point.amount;
        _shouldDisplayTopPointsCell = data.active;
        [[self tableView]reloadData];
        
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
    [UserRequest getUserCompletionOnSuccess:^(ProfileCompletionInfo *profileInfo) {
        double profileCompleted = profileInfo.completion/100.0;
        //progress color
        self.progressBarTrack = [UIColor colorWithRed:200.0/225.0 green:200.0/225.0 blue:200.0/225.0 alpha:1];
        self.progressBarColor = [UIColor colorWithRed:175.0/225.0 green:213.0/225.0 blue:100.0/225.0 alpha:1]; //default: 0.5
        self.progressLabel.text = @"50%";
        _verifiedAccountLabel.textColor = [UIColor clearColor];
        _verifiedAccountIcon.hidden = true;
        if (profileCompleted>=0.6 && profileCompleted<0.7) {
            self.progressBarColor = [UIColor colorWithRed:127.0/225.0 green:190.0/225.0 blue:51.0/225.0 alpha:1];
            self.progressLabel.text = @"60%";
        } else if (profileCompleted>=0.7 && profileCompleted<0.8) {
            self.progressBarColor = [UIColor colorWithRed:78.0/225.0 green:188.0/225.0 blue:74.0/225.0 alpha:1];
            self.progressLabel.text = @"70%";
        } else if (profileCompleted>=0.8 && profileCompleted<0.9) {
            self.progressBarColor = [UIColor colorWithRed:39.0/225.0 green:160.0/225.0 blue:46.0/225.0 alpha:1];
            self.progressLabel.text = @"80%";
        } else if (profileCompleted>=0.9 && profileCompleted<1.0) {
            self.progressBarColor = [UIColor colorWithRed:8.0/225.0 green:132.0/225.0 blue:31.0/225.0 alpha:1];
            self.progressLabel.text = @"90%";
        } else if (profileCompleted >= 1.0) {
            self.progressBarColor = [UIColor colorWithRed:0.0/225.0 green:112.0/225.0 blue:20.0/225.0 alpha:1];
            self.progressLabel.text = @"100%";
            _completeProfileButton.hidden = true;
            _verifiedAccountLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.54];
            _verifiedAccountIcon.hidden = false;
        }
        [self.progressBar setProgress:profileCompleted animated:true];
        [self.progressBar setTrackTintColor:self.progressBarTrack];
        [self.progressBar setProgressTintColor:self.progressBarColor];
    }];
}
@end
