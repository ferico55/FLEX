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
#import "AlertPriceNotificationViewController.h"
#import "detail.h"
#import "CreateShopViewController.h"
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
#import "TKPDTabProfileNavigationController.h"

#import "ShopFavoritedViewController.h"


#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "TKPDTabViewController.h"
#import "InboxTicketViewController.h"

#import "InboxTalkViewController.h"
#import "InboxReviewViewController.h"
#import "NotificationManager.h"

#import "TKPDTabInboxTalkNavigationController.h"
#import "DepositSummaryViewController.h"
#import "ShopContainerViewController.h"
#import "UserContainerViewController.h"
#import "ReputationPageViewController.h"
#import "ProductListMyShopViewController.h"
#import "MyShopEtalaseViewController.h"
#import "InboxResolutionCenterTabViewController.h"
#import "InboxResolSplitViewController.h"
#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"

#import "NavigateViewController.h"
#import "LoyaltyPoint.h"

#import "TAGDataLayer.h"

#import <MessageUI/MessageUI.h>

#define CTagProfileInfo 12
#define CTagLP 13

@interface MoreViewController () <NotificationManagerDelegate, TokopediaNetworkManagerDelegate, SplitReputationVcProtocol> {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    NSOperationQueue *_operationQueue;
    
    RKObjectManager *_objectmanager;
    __weak RKObjectManager *_depositObjectManager;
    __weak RKManagedObjectRequestOperation *_depositRequest;
    NSInteger _depositRequestCount;
    BOOL _isNoDataDeposit, hasLoadViewWillAppear;
    NotificationManager *_notifManager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSTimer *_requestTimer;
    
    UISplitViewController *splitViewController;
    NavigateViewController *_navigate;
    
    TokopediaNetworkManager *_LPNetworkManager;
    LoyaltyPointResult *_LPResult;
    TAGContainer *_gtmContainer;
}

@property (weak, nonatomic) IBOutlet UILabel *depositLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopIsGoldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UIButton *createShopButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSaldo;
@property (weak, nonatomic) IBOutlet UITableViewCell *shopCell;
@property (weak, nonatomic) IBOutlet UILabel *LPointLabel;

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
                                                 selector:@selector(updateSaldoTokopedia:)
                                                     name:@"updateSaldoTokopedia" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateProfilePicture:)
                                                     name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShopPicture:)
                                                     name:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                                   object:nil];
         
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
    
    _LPNetworkManager = [TokopediaNetworkManager new];
    _LPNetworkManager.delegate = self;
    _LPNetworkManager.tagRequest = CTagLP;
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    _navigate = [NavigateViewController new];
    
    _isNoDataDeposit  = YES;
    _depositRequestCount = 0;
    
    _operationQueue = [[NSOperationQueue alloc] init];
    
    _fullNameLabel.text = [_auth objectForKey:@"full_name"];
    _versionLabel.text = [NSString stringWithFormat:@"Versi : %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    self.navigationController.title = @"More";
    [self initNotificationManager];
    
    // Remove default table inset
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    // Set round corner profile picture
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2;
    self.profilePictureImageView.layer.borderColor = [UIColor colorWithRed:(224/255) green:(224/255) blue:(224/255) alpha:(0.1)].CGColor;
    self.profilePictureImageView.layer.borderWidth = 1.0;
    
    // Set round corner profile picture
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width/2;
    self.shopImageView.layer.borderColor = [UIColor colorWithRed:(224/255) green:(224/255) blue:(224/255) alpha:(0.1)].CGColor;
    self.shopImageView.layer.borderWidth = 1.0;
    
    // Set create shop button corner
    self.createShopButton.layer.cornerRadius = 2;
    
    //Load Deposit
    _depositLabel.hidden = YES;
    _loadingSaldo.hidden = NO;
    
    [self updateSaldoTokopedia:nil];
    [self setShopImage];
    [self configureGTM];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self updateSaldoTokopedia:nil];
    
    //manual GA Track
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:kGAIScreenName value:@"More Navigation Page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    //    } else {
    //        _depositLabel.hidden = NO;
    //        _loadingSaldo.hidden = YES;
    //        [_loadingSaldo stopAnimating];
    //    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.tabBarController.title = @"More";
    [_LPNetworkManager requestCancel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagProfileInfo) {
        return @{
                 kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEINFOKEY,
                 kTKPDPROFILE_APIPROFILEUSERIDKEY : @([[_auth objectForKey:kTKPDPROFILE_APIUSERIDKEY]integerValue])
                 };
    }
    if (tag == CTagLP) {
        return @{@"action":@"get_lp"
                 };
    }
    return nil;
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagProfileInfo) {
        return kTKPDPROFILE_PEOPLEAPIPATH;
    }
    if (tag == CTagLP) {
        return @"lp.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagProfileInfo) {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileInfo class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileInfoResult class]];
        
        RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
        [shopinfoMapping addAttributeMappingsFromDictionary:@{
                                                              kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY
                                                              }];
        // Relationship Mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                      toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY
                                                                                    withMapping:shopinfoMapping]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                method:RKRequestMethodPOST
                                                                                           pathPattern:kTKPDPROFILE_PEOPLEAPIPATH
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptor];
        
        return _objectmanager;
    }
    if (tag == CTagLP) {
        return [self objectManagerLP];
    }
    
    return nil;
}

-(RKObjectManager*)objectManagerLP
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LoyaltyPoint mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"lp.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];

    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    if(tag == CTagProfileInfo) {
        ProfileInfo *profileInfo = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return profileInfo.status;
    }
    if (tag == CTagLP) {
        LoyaltyPoint *lp = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return lp.status;
    }
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagProfileInfo) {
        ProfileInfo *profileInfo = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if(profileInfo.result.shop_info!=nil && profileInfo.result.shop_info.shop_avatar!=nil && ![profileInfo.result.shop_info.shop_avatar isEqualToString:@""]) {
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            if(secureStorage != nil) {
                
                if(profileInfo.result.shop_info.shop_avatar != nil) {
                    [secureStorage setKeychainWithValue:profileInfo.result.shop_info.shop_avatar withKey:kTKPD_SHOP_AVATAR];
                }
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:profileInfo.result.shop_info.shop_avatar]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                [_shopImageView setImageWithURLRequest:request
                                      placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                                   //NSLOG(@"thumb: %@", thumb);
                                                   [_shopImageView setImage:image];
#pragma clang diagnostic pop
                                               } failure: nil];
            }
        }
    }
    
    if (tag == CTagLP) {
        LoyaltyPoint *lp = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        _LPResult = lp.result;
        _LPointLabel.text = lp.result.loyalty_point.amount;
        [[self tableView]reloadData];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
}

- (void)actionBeforeRequest:(int)tag
{
}


- (void)actionRequestAsync:(int)tag
{
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    
}


#pragma mark - Method
-(void)updateShopPicture:(NSNotification*)notif
{
    NSDictionary *userInfo = notif.userInfo;
    
    NSString *strAvatar = [userInfo objectForKey:@"file_th"]?:@"";
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:strAvatar withKey:@"shop_avatar"];
    _auth = [[secureStorage keychainDictionary] mutableCopy];
    
    [self setShopImage];
}

- (void)setShopImage {
    
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
                                           //NSLOG(@"thumb: %@", thumb);
                                           [_shopImageView setImage:image];
#pragma clang diagnostic pop
                                       } failure: nil];
        
        if ([[_auth objectForKey:@"shop_is_gold"] integerValue] == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Badges_gold_merchant"]];
            imageView.frame = CGRectMake(_shopIsGoldLabel.frame.origin.x,
                                         _shopIsGoldLabel.frame.origin.y,
                                         22, 22);
            [_shopCell addSubview:imageView];
            _shopIsGoldLabel.text = @"        Gold Merchant";
        } else {
            _shopIsGoldLabel.text = @"Regular Merchant";
        }
    }
}


- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tag == CTagProfileInfo) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = CTagProfileInfo;
            tokopediaNetworkManager.delegate = self;
        }
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}

- (void)updateImageURL {
    [[self getNetworkManager:CTagProfileInfo] doRequest];
}

- (void)updateKeyChain
{
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    if([_auth objectForKey:@"shop_id"]) {
        _shopNameLabel.text = [_auth objectForKey:@"shop_name"];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_auth objectForKey:@"shop_avatar"]]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        [_shopImageView setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                           //NSLOG(@"thumb: %@", thumb);
                                           [_shopImageView setImage:image];
#pragma clang diagnostic pop
                                       } failure: nil];
        
        if ([[_auth objectForKey:@"shop_is_gold"] integerValue] == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Badges_gold_merchant"]];
            imageView.frame = CGRectMake(_shopIsGoldLabel.frame.origin.x,
                                         _shopIsGoldLabel.frame.origin.y,
                                         22, 22);
            [_shopCell addSubview:imageView];
            _shopIsGoldLabel.text = @"        Gold Merchant";
        } else {
            _shopIsGoldLabel.text = @"Regular Merchant";
            CGRect shopIsGoldLabelFrame = _shopIsGoldLabel.frame;
            shopIsGoldLabelFrame.origin.x = 83;
            _shopIsGoldLabel.frame = shopIsGoldLabelFrame;
            _shopIsGoldLabel.text = @"";
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            if ([_LPResult.loyalty_point.has_lp integerValue] == 1) {
                return 2;
            }
            else return 1;
            break;
        }
        case 1:
            return 3;
            break;
            
        case 2:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 4;
            else return 0;
            break;
            
        case 3:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                return 0;
            else return 1;
            break;
            
        case 4:
            return 6;
            break;
            
        case 5:
            return 4;
            break;
            
        case 6:
            return 1;
            break;
            
        case 7 :
            return 1;
            break;
            
        default:
            break;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"PROFIL SAYA";
    } else if (section == 2) {
        if ([_auth objectForKey:@"shop_id"] &&
            [[_auth objectForKey:@"shop_id"] integerValue] > 0)
            return @"TOKO SAYA";
        else return @"";
    } else if (section == 3) {
        if ([_auth objectForKey:@"shop_id"] &&
            [[_auth objectForKey:@"shop_id"] integerValue] > 0)
            return @"";
        else return @"TOKO SAYA";
    } else if(section == 4) {
        return @"Kotak Masuk";
    }
    return @"";
}


#pragma mark - Table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        if(![_depositLabel.text isEqualToString:@"-"]) {
            DepositSummaryViewController *depositController = [DepositSummaryViewController new];
            depositController.data = @{@"total_saldo":_depositLabel.text};
            [self.navigationController pushViewController:depositController animated:YES];
        }
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSString  *currentDeviceId = [_auth objectForKey:@"device_token"];
        NSString *userID = [_auth objectForKey:kTKPDPROFILE_APIUSERIDKEY];
        NSString *url_ = _LPResult.uri;
        NSURL *url = [NSURL URLWithString:url_];
        WebViewController *webViewController = [WebViewController new];
        NSString *webViewStrUrl =[NSString stringWithFormat:@"http://%@/js/wvlogin?uid=%@&token=%@&url=%@?%@",  [url host],userID,currentDeviceId,[url path],[url query]]; //[url scheme], [url host]
//        NSString *webViewStrUrl =[NSString stringWithFormat:@"%@://%@/js/wvlogin?uid=%@&token=%@&url=%@?%@", @"http", @"m.tokopedia.com",userID,currentDeviceId,@"/lp.pl",@"flag_app=1"]; //[url scheme], [url host]
        webViewController.isLPWebView = YES;
        webViewController.strURL = webViewStrUrl;
        webViewController.strTitle = @"TopPoints";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        NavigateViewController *navigateController = [NavigateViewController new];
        [navigateController navigateToProfileFromViewController:self withUserID:[_auth objectForKey:MORE_USER_ID]];
    }
    
    else if (indexPath.section == 1 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PurchaseViewController *purchaseController = [storyboard instantiateViewControllerWithIdentifier:@"PurchaseViewController"];
        purchaseController.notification = _notifManager.notification;
        [self.navigationController pushViewController:purchaseController animated:YES];
    }
    else if(indexPath.section==1 && indexPath.row==2) {
        UINavigationController *tempNavController = (UINavigationController *) [self.tabBarController.viewControllers firstObject];
        [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:2];
        [self.tabBarController setSelectedIndex:0];
        [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToWishList];
    }
    
    else if (indexPath.section == 2) {
        if(indexPath.row == 0) {
            ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
            container.data = @{MORE_SHOP_ID : [_auth objectForKey:MORE_SHOP_ID],
                               MORE_AUTH : _auth,
                               MORE_SHOP_NAME : [_auth objectForKey:MORE_SHOP_NAME]
                               };
            [self.navigationController pushViewController:container animated:YES];
        } else if(indexPath.row == 1) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SalesViewController *salesController = [storyboard instantiateViewControllerWithIdentifier:@"SalesViewController"];
            salesController.notification = _notifManager.notification;
            salesController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:salesController animated:YES];
        } else if (indexPath.row == 2) {
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:_auth?:@{}};
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 3) {
            MyShopEtalaseViewController *vc = [MyShopEtalaseViewController new];
            vc.data = @{MORE_SHOP_ID : [_auth objectForKey:MORE_SHOP_ID]?:@{},
                        kTKPD_AUTHKEY:_auth?:@{}};
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    
    else if (indexPath.section == 4) {
        if(indexPath.row == 0) {
            [_navigate navigateToInboxMessageFromViewController:self];
        } else if(indexPath.row == 1) {
            [_navigate navigateToInboxTalkFromViewController:self];
        } else if (indexPath.row == 2) {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                splitViewController = [UISplitViewController new];
                
                SplitReputationViewController *splitReputationViewController = [SplitReputationViewController new];
                splitReputationViewController.splitViewController = splitViewController;
                splitReputationViewController.del = self;
                [self.navigationController pushViewController:splitReputationViewController animated:YES];
            }
            else  {
                SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
                segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:segmentedReputationViewController animated:YES];
            }
            
            /*
            InboxReviewViewController *vc = [InboxReviewViewController new];
            vc.data=@{@"nav":@"inbox-review"};
            
            InboxReviewViewController *vc1 = [InboxReviewViewController new];
            vc1.data=@{@"nav":@"inbox-review-my-product"};
            
            InboxReviewViewController *vc2 = [InboxReviewViewController new];
            vc2.data=@{@"nav":@"inbox-review-my-review"};
            
            NSArray *vcs = @[vc,vc1, vc2];
            
            TKPDTabInboxReviewNavigationController *nc = [TKPDTabInboxReviewNavigationController new];
            [nc setSelectedIndex:2];
            [nc setViewControllers:vcs];
            nc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nc animated:YES];
            */
        } else if (indexPath.row == 3) {
            
            [_navigate navigateToInboxPriceAlertFromViewController:self];
            
        } else if (indexPath.row == 4) {
            TKPDTabViewController *controller = [TKPDTabViewController new];
            controller.hidesBottomBarWhenPushed = YES;
            
            InboxTicketViewController *allInbox = [InboxTicketViewController new];
            allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
            allInbox.delegate = controller;
            
            InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
            unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
            unreadInbox.delegate = controller;
            
            InboxTicketViewController *closedInbox = [InboxTicketViewController new];
            closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
            closedInbox.delegate = controller;
            
            controller.viewControllers = @[allInbox, unreadInbox, closedInbox];
            controller.tabTitles = @[@"Semua", @"Dalam Proses", @"Ditutup"];
            controller.menuTitles = @[@"Semua Layanan Pengguna", @"Belum Dibaca"];
            
            [self.navigationController pushViewController:controller animated:YES];
        } else if (indexPath.row == 5) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                InboxResolSplitViewController *controller = [InboxResolSplitViewController new];
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller animated:YES];
                
            } else {
                InboxResolutionCenterTabViewController *controller = [InboxResolutionCenterTabViewController new];
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }
    
    else if (indexPath.section == 5) {
        if(indexPath.row == 0) {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker setAllowIDFACollection:YES];
            [tracker set:kGAIScreenName value:@"Contact Us"];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            //            [Helpshift setName:[_auth objectForKey:@"full_name"] andEmail:nil];
            //            [[Helpshift sharedInstance]showFAQs:self withOptions:nil];
            //            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            
            if([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
                emailController.mailComposeDelegate = self;
                
                
                NSString *messageBody = [NSString stringWithFormat:@"Device : %@ <br/> OS Version : %@ <br/> Email Tokopedia : %@ <br/> App Version : %@ <br/><br/> Komplain : ", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [_auth objectForKey:kTKPD_USEREMAIL],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
                
                [emailController setSubject:@"Feedback"];
                [emailController setMessageBody:messageBody isHTML:YES];
                [emailController setToRecipients:@[@"ios.feedback@tokopedia.com"]];
                [emailController.navigationBar setTintColor:[UIColor whiteColor]];
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                [self presentViewController:emailController animated:YES completion:nil];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kamu harus memiliki email (dan login terlebih dahulu) apabila ingin mengirimkan feedback :)"]
                                                                               delegate:self];
                [alert show];
            }
            
        } else if(indexPath.row == 1) {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker setAllowIDFACollection:YES];
            [tracker set:kGAIScreenName value:@"FAQ Center"];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            WebViewController *webViewController = [WebViewController new];
            webViewController.strURL = kTKPDMORE_HELP_URL;
            webViewController.strTitle = kTKPDMORE_HELP_TITLE;
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if(indexPath.row == 2) {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker setAllowIDFACollection:YES];
            [tracker set:kGAIScreenName value:@"Privacy Policy"];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            WebViewController *webViewController = [WebViewController new];
            webViewController.strURL = kTKPDMORE_PRIVACY_URL;
            webViewController.strTitle = kTKPDMORE_PRIVACY_TITLE;
            [self.navigationController pushViewController:webViewController animated:YES];
        } else if(indexPath.row == 3) {
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker setAllowIDFACollection:YES];
            [tracker set:kGAIScreenName value:@"Share App"];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            NSString *title = @"Download Aplikasi Tokopedia Sekarang Juga! \nNikmati kemudahan jual beli online di tanganmu.";
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/id/app/tokopedia/id1001394201"];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                             applicationActivities:nil];
            activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
            [self presentViewController:activityController animated:YES completion:nil];
        }
    }
    
    else if (indexPath.section == 6) {
        if(indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION
                                                                object:nil
                                                              userInfo:@{}];
        }
        
    }
    
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Reskit

- (void)configureRestKit
{
    // initialize RestKit
    _depositObjectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Deposit class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DepositResult class]];
    [resultMapping addAttributeMappingsFromArray:@[TKPD_DEPOSIT_TOTAL,]];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:API_DEPOSIT_PATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_depositObjectManager addResponseDescriptor:responseDescriptorStatus];
}
#pragma mark - Deposit Reskit methods

- (void)loadDataDeposit
{
    if (_depositRequest.isExecuting) return;
    
    _depositRequestCount++;
    
    NSDictionary *param = @{API_DEPOSIT_ACTION : API_DEPOSIT_GET_DETAIL};
    
    _depositRequest = [_depositObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                  method:RKRequestMethodPOST
                                                                                    path:API_DEPOSIT_PATH
                                                                              parameters:[param encrypt]];
    
    [_requestTimer invalidate];
    _requestTimer = nil;
    [_depositRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestfailure:error];
    }];
    
    [_operationQueue addOperation:_depositRequest];
    _requestTimer = [NSTimer scheduledTimerWithTimeInterval:16.0 target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];
}

- (void)requestTimeout {
    [self requestCancel];
    if(_depositRequestCount < kTKPDREQUESTCOUNTMAX) {
        [self updateSaldoTokopedia:nil];
    }
}

- (void)requestCancel {
    [_depositRequest cancel];
    _depositRequest = nil;
    
    [_depositObjectManager.operationQueue cancelAllOperations];
    _depositObjectManager = nil;
    
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    if (result) {
        Deposit *deposit = [result objectForKey:@""];
        _depositLabel.text = deposit.result.deposit_total;
        _depositLabel.hidden = NO;
        _loadingSaldo.hidden = YES;
        [_loadingSaldo stopAnimating];
        _isNoDataDeposit = NO;

        [_LPNetworkManager doRequest];
    }
}

- (void)requestfailure:(NSError *)error
{
    
}

#pragma mark - Notification Manager

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

#pragma mark - Notification delegate
- (void)reloadNotification
{
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [self requestCancel];
    [_LPNetworkManager requestCancel];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Action
- (IBAction)actionCreateShop:(id)sender
{
    CreateShopViewController *createShopViewController = [CreateShopViewController new];
    createShopViewController.moreViewController = self;
    [self pushViewController:createShopViewController];
}

- (void)updateSaldoTokopedia:(NSNotification*)notification {
    [self configureRestKit];
    [self loadDataDeposit];
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
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;

}

#pragma mark - Email delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - SplitVC Delegate
- (void)deallocVC {
    splitViewController = nil;
}
@end