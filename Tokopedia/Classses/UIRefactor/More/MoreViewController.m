//
//  MoreViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CreateShopViewController.h"
#import "MoreViewController.h"
#import "more.h"
#import "TKPDSecureStorage.h"
#import "stringrestkit.h"

#import "Deposit.h"
#import "DepositResult.h"
#import "string_deposit.h"
#import "string_more.h"


#import "SalesViewController.h"
#import "PurchaseViewController.h"

#import "ProfileBiodataViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"
#import "TKPDTabProfileNavigationController.h"

#import "TKPDTabShopViewController.h"
#import "ShopFavoritedViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "ShopTalkViewController.h"

#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabInboxReviewNavigationController.h"

#import "InboxTalkViewController.h"
#import "InboxReviewViewController.h"
#import "NotificationManager.h"

#import "TKPDTabInboxTalkNavigationController.h"
#import "DepositSummaryViewController.h"
#import "ShopContainerViewController.h"
#import "ReputationPageViewController.h"
#import "Helpshift.h"

@interface MoreViewController () <NotificationManagerDelegate> {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    NSOperationQueue *_operationQueue;

    __weak RKObjectManager *_depositObjectManager;
    __weak RKManagedObjectRequestOperation *_depositRequest;
    NSInteger _depositRequestCount;
    BOOL _isNoDataDeposit;
    NotificationManager *_notifManager;
}

@property (weak, nonatomic) IBOutlet UILabel *depositLabel;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopIsGoldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;

@property (weak, nonatomic) IBOutlet UIButton *createShopButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSaldo;

@property (weak, nonatomic) IBOutlet UITableViewCell *shopCell;

@end

@implementation MoreViewController

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
    
    _isNoDataDeposit  = YES;
    _depositRequestCount = 0;

    _operationQueue = [[NSOperationQueue alloc] init];
    
    _fullNameLabel.text = [_auth objectForKey:@"full_name"];
    
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
    }    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.title = @"More";
    [self initNotificationManager];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];

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
    
    
//    if (_isNoDataDeposit) {
        _depositLabel.hidden = YES;
        _loadingSaldo.hidden = NO;
        
        [self configureRestKit];
        [self loadDataDeposit];
//    } else {
//        _depositLabel.hidden = NO;
//        _loadingSaldo.hidden = YES;
//        [_loadingSaldo stopAnimating];
//    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.tabBarController.title = @"More";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        
        case 1:
            return 2;
            break;
            
        case 2:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                    return 2;
            else return 0;
            break;
            
        case 3:
            if ([_auth objectForKey:@"shop_id"] &&
                [[_auth objectForKey:@"shop_id"] integerValue] > 0)
                    return 0;
            else return 1;
            break;
            
        case 4:
            return 3;
            break;
            
        case 5:
            return 3;
            break;
            
        case 6:
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
    
    if(indexPath.section == 0) {
        if(!_depositRequest.isExecuting) {
            DepositSummaryViewController *depositController = [DepositSummaryViewController new];
            depositController.data = @{@"total_saldo":_depositLabel.text};
            [self.navigationController pushViewController:depositController animated:YES];
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        NSMutableArray *viewControllers = [NSMutableArray new];
        
        ProfileBiodataViewController *biodataController = [ProfileBiodataViewController new];
        [viewControllers addObject:biodataController];
        
        ProfileFavoriteShopViewController *favoriteController = [ProfileFavoriteShopViewController new];
        favoriteController.data = @{MORE_USER_ID:[_auth objectForKey:MORE_USER_ID],
                                    MORE_SHOP_ID:[_auth objectForKey:MORE_SHOP_ID],
                                    MORE_AUTH:_auth?:[NSNull null]};
        [viewControllers addObject:favoriteController];
        
        ProfileContactViewController *contactController = [ProfileContactViewController new];
        [viewControllers addObject:contactController];
        
        TKPDTabProfileNavigationController *profileController = [TKPDTabProfileNavigationController new];
        profileController.data = @{MORE_USER_ID:[_auth objectForKey:MORE_USER_ID],
                                   MORE_AUTH:_auth?:[NSNull null]};
        [profileController setViewControllers:viewControllers animated:YES];
        [profileController setSelectedIndex:0];
        
        [self.navigationController pushViewController:profileController animated:YES];
    }
    
    else if (indexPath.section == 1 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PurchaseViewController *purchaseController = [storyboard instantiateViewControllerWithIdentifier:@"PurchaseViewController"];
        purchaseController.notification = _notifManager.notification;
        [self.navigationController pushViewController:purchaseController animated:YES];
    }
    
    else if (indexPath.section == 2 && indexPath.row == 0) {
        ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
        container.data = @{MORE_SHOP_ID : [_auth objectForKey:MORE_SHOP_ID],
                                                               MORE_AUTH : _auth,
                                                               MORE_SHOP_NAME : [_auth objectForKey:MORE_SHOP_NAME]
                                                               };
        [self.navigationController pushViewController:container animated:YES];
    }
    
    else if (indexPath.section == 2 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SalesViewController *salesController = [storyboard instantiateViewControllerWithIdentifier:@"SalesViewController"];
        salesController.notification = _notifManager.notification;
        [self.navigationController pushViewController:salesController animated:YES];
    }
    
    else if (indexPath.section == 4) {
        if(indexPath.row == 0) {
            InboxMessageViewController *vc = [InboxMessageViewController new];
            vc.data=@{@"nav":@"inbox-message"};
            
            InboxMessageViewController *vc1 = [InboxMessageViewController new];
            vc1.data=@{@"nav":@"inbox-message-sent"};
            
            InboxMessageViewController *vc2 = [InboxMessageViewController new];
            vc2.data=@{@"nav":@"inbox-message-archive"};
            
            InboxMessageViewController *vc3 = [InboxMessageViewController new];
            vc3.data=@{@"nav":@"inbox-message-trash"};
            NSArray *vcs = @[vc,vc1, vc2, vc3];
            
            TKPDTabInboxMessageNavigationController *inboxController = [TKPDTabInboxMessageNavigationController new];
            [inboxController setSelectedIndex:2];
            [inboxController setViewControllers:vcs];
            [self.navigationController pushViewController:inboxController animated:YES];
        } else if(indexPath.row == 1) {
            InboxTalkViewController *vc = [InboxTalkViewController new];
            vc.data=@{@"nav":@"inbox-talk"};
            
            InboxTalkViewController *vc1 = [InboxTalkViewController new];
            vc1.data=@{@"nav":@"inbox-talk-my-product"};
            
            InboxTalkViewController *vc2 = [InboxTalkViewController new];
            vc2.data=@{@"nav":@"inbox-talk-following"};
            
            NSArray *vcs = @[vc,vc1, vc2];
            
            TKPDTabInboxTalkNavigationController *nc = [TKPDTabInboxTalkNavigationController new];
            [nc setSelectedIndex:2];
            [nc setViewControllers:vcs];
            [self.navigationController pushViewController:nc animated:YES];
        } else if (indexPath.row == 2) {
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
            
        }
        
    }
    
    else if (indexPath.section == 5) {
        if(indexPath.row == 0) {
            [Helpshift setName:[_auth objectForKey:@"full_name"] andEmail:nil];
            
            [[Helpshift sharedInstance]showFAQs:self withOptions:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        } else if(indexPath.row == 1) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 568)];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kTKPDMORE_HELP_URL]]];
            UIViewController *controller = [UIViewController new];
            controller.title = kTKPDMORE_HELP_TITLE;
            [controller.view addSubview:webView];
            [self.navigationController pushViewController:controller animated:YES];
        } else if(indexPath.row == 2) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kTKPDMORE_PRIVACY_URL]]];
            UIViewController *controller = [UIViewController new];
            controller.title = kTKPDMORE_PRIVACY_TITLE;
            [controller.view addSubview:webView];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    else if (indexPath.section == 6) {
        [Helpshift logout];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];
        [nc postNotificationName:@"clearCacheNotificationBar" object:nil];
        
        TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
        [storage resetKeychain];
    }

    self.hidesBottomBarWhenPushed = NO;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    [_depositRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestfailure:error];
    }];

    [_operationQueue addOperation:_depositRequest];
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
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Action
- (IBAction)actionCreateShop:(id)sender
{
    CreateShopViewController *createShopViewController = [CreateShopViewController new];
    [self pushViewController:createShopViewController];
}
@end
