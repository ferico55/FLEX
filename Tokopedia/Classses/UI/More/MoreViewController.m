//
//  MoreViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

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

#import "TKPDTabShopNavigationController.h"
#import "ShopFavoritedViewController.h"
#import "ShopProductViewController.h"
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

@interface MoreViewController ()  {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    Notification *_notification;
    
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
@property (weak, nonatomic) IBOutlet UIImageView *shopIsGoldBadge;

@property (weak, nonatomic) IBOutlet UIButton *createShopButton;


@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    _isNoDataDeposit  = YES;
    _depositRequestCount = 0;

    _operationQueue = [[NSOperationQueue alloc] init];
    
    _fullNameLabel.text = [_auth objectForKey:@"full_name"];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(goToViewController:) name:@"goToViewController" object:nil];
    [nc addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotificationBar" object:nil];

    // Add logo in navigation bar
    self.title = kTKPDMORE_TITLE;
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];

    // Remove default table inset
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);

    // Set round corner profile picture
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2;

    // Set round corner profile picture
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width/2;

    // Set create shop button corner
    self.createShopButton.layer.cornerRadius = 2;
    
    _depositLabel.text = @"";

        [self configureRestKit];
    
    if (_isNoDataDeposit) {
        [self loadDataDeposit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
            return 6;
            break;
            
        case 5:
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
    }
    return @"";
}

#pragma mark - Table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    else if (indexPath.section == 2 && indexPath.row == 0) {
        NSMutableArray *viewControllers = [NSMutableArray new];
        
        NSDictionary *data = @{MORE_SHOP_ID:[_auth objectForKey:@"shop_id"],
                               MORE_AUTH:_auth};
        
        ShopProductViewController *productController = [ShopProductViewController new];
        productController.data = data;
        [viewControllers addObject:productController];
        
        ShopTalkViewController *talkController = [ShopTalkViewController new];
        talkController.data = data;
        [viewControllers addObject:talkController];
        
        ShopReviewViewController *reviewController = [ShopReviewViewController new];
        reviewController.data = data;
        [viewControllers addObject:reviewController];
        
        ShopNotesViewController *noteController = [ShopNotesViewController new];
        noteController.data = data;
        [viewControllers addObject:noteController];
        
        TKPDTabShopNavigationController *shopNavigationController = [TKPDTabShopNavigationController new];
        shopNavigationController.data = data;
        [shopNavigationController setViewControllers:viewControllers animated:YES];
        [shopNavigationController setSelectedIndex:0];
        
        [self.navigationController pushViewController:shopNavigationController animated:YES];
    }
    
    else if (indexPath.section == 4) {
        if(indexPath.row == 3) {
            InboxMessageViewController *vc = [InboxMessageViewController new];
            vc.data=@{@"nav":@"inbox-message"};
            
            InboxMessageViewController *vc1 = [InboxMessageViewController new];
            vc1.data=@{@"nav":@"inbox-message-sent"};
            
            InboxMessageViewController *vc2 = [InboxMessageViewController new];
            vc2.data=@{@"nav":@"inbox-message-archive"};
            
            InboxMessageViewController *vc3 = [InboxMessageViewController new];
            vc3.data=@{@"nav":@"inbox-message-trash"};
            NSArray *vcs = @[vc,vc1, vc2, vc3];
            
            TKPDTabInboxMessageNavigationController *nc = [TKPDTabInboxMessageNavigationController new];
            [nc setSelectedIndex:2];
            [nc setViewControllers:vcs];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
            [nav.navigationBar setTranslucent:NO];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        } else if(indexPath.row == 4) {
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
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
            [nav.navigationBar setTranslucent:NO];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        } else if (indexPath.row == 5) {
            InboxReviewViewController *vc = [InboxReviewViewController new];
            vc.data=@{@"nav":@"inbox-review"};
            
            InboxTalkViewController *vc1 = [InboxReviewViewController new];
            vc1.data=@{@"nav":@"inbox-review-my-product"};
            
            InboxTalkViewController *vc2 = [InboxReviewViewController new];
            vc2.data=@{@"nav":@"inbox-review-my-review"};
            
            NSArray *vcs = @[vc,vc1, vc2];
            
            TKPDTabInboxReviewNavigationController *nc = [TKPDTabInboxReviewNavigationController new];
            [nc setSelectedIndex:2];
            [nc setViewControllers:vcs];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:nc];
            [nav.navigationBar setTranslucent:NO];
            [self.navigationController presentViewController:nav animated:YES completion:nil];

        }
        
    }
    
    else if (indexPath.section == 5) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];
        [nc postNotificationName:@"clearCacheNotificationBar" object:nil];
    }
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
                                                                                                  method:RKRequestMethodGET
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

    _depositRequest = [_depositObjectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodGET
                                                                      path:API_DEPOSIT_PATH
                                                                parameters:@{API_DEPOSIT_ACTION : API_DEPOSIT_GET_DETAIL}];
    
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
    }
}

- (void)requestfailure:(NSError *)error
{
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Sales"]) {
        SalesViewController *salesController = segue.destinationViewController;
        salesController.notification = _notification;
    }
    else if ([segue.identifier isEqualToString:@"Purchase"]) {
        PurchaseViewController *purchaseController = segue.destinationViewController;
        purchaseController.notification = _notification;
    }
}

#pragma mark - Notification Manager
- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

- (void)goToViewController:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    [self tapWindowBar];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end
