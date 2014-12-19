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

#import "Notification.h"
#import "NotificationRequest.h"
#import "NotificationViewController.h"

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

#import "InboxTalkViewController.h"

#import "NotificationBarButton.h"
#import "TKPDTabInboxTalkNavigationController.h"

@interface MoreViewController () <NotificationDelegate> {
    NSDictionary *_auth;
    
    Deposit *_deposit;
    Notification *_notification;
    
    NSOperationQueue *_operationQueue;

    __weak RKObjectManager *_depositObjectManager;
    __weak RKManagedObjectRequestOperation *_depositRequest;
    NSInteger _depositRequestCount;
    BOOL _isNoDataDeposit;
}

@property (weak, nonatomic) IBOutlet UILabel *depositLabel;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopIsGoldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shopIsGoldBadge;

@property (weak, nonatomic) IBOutlet UIButton *createShopButton;

@property (strong, nonatomic) UIWindow *notificationWindow;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationViewController *notificationController;

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
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_auth objectForKey:@"user_image"]]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    [_profilePictureImageView setImageWithURLRequest:request
                                    placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [_profilePictureImageView setImage:image];
#pragma clang diagnostic pop
    } failure: nil];

    _shopNameLabel.text = [_auth objectForKey:@"shop_name"];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_auth objectForKey:@"shop_avatar"]]
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
        _shopIsGoldLabel.text = @"Gold Merchant";
    } else {
        _shopIsGoldBadge.hidden = YES;
        CGRect shopIsGoldLabelFrame = _shopIsGoldLabel.frame;
        shopIsGoldLabelFrame.origin.x = 83;
        _shopIsGoldLabel.frame = shopIsGoldLabelFrame;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

    _notificationWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _notificationWindow.clipsToBounds = YES;

    // Notification button
    _notificationButton = [[NotificationBarButton alloc] init];
    UIButton *button = (UIButton *)_notificationButton.customView;
    [button addTarget:self action:@selector(barButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = _notificationButton;
    
    _notificationArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_triangle_grey"]];
    _notificationArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    _notificationArrowImageView.clipsToBounds = YES;
    _notificationArrowImageView.frame = CGRectMake(_notificationButton.customView.frame.origin.x+12, 60, 10, 5);
    _notificationArrowImageView.alpha = 0;
    [_notificationWindow addSubview:_notificationArrowImageView];
    
    NotificationRequest *notificationRequest = [NotificationRequest new];
    notificationRequest.delegate = self;
    [notificationRequest loadNotification];

    [self configureRestKit];
    
    if (_isNoDataDeposit) {
        [self loadDataDeposit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notification methods

- (void)barButtonDidTap
{
    [_notificationWindow makeKeyAndVisible];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowDidTap)];
    [_notificationWindow addGestureRecognizer:tapRecognizer];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    _notificationController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    _notificationController.notification = _notification;
    
    [_notificationController.tableView beginUpdates];
    CGRect notificationTableFrame = _notificationController.tableView.frame;
    notificationTableFrame.origin.y = 64;
    notificationTableFrame.size.height = 300;
    _notificationController.tableView.frame = notificationTableFrame;
    [_notificationController.tableView endUpdates];
    
    _notificationController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 355, 0);
    
    CGRect windowFrame = _notificationWindow.frame;
    windowFrame.size.height = 0;
    _notificationWindow.frame = windowFrame;

    windowFrame.size.height = self.view.frame.size.height-64;
    
    [_notificationWindow addSubview:_notificationController.view];

    _notificationArrowImageView.alpha = 1;

    [UIView animateWithDuration:0.7 animations:^{
        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }];
    
    [UIView animateWithDuration:0.55 animations:^{
        _notificationWindow.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+112);
    }];
    
}

- (void)windowDidTap
{
    CGRect windowFrame = _notificationWindow.frame;
    windowFrame.size.height = 0;

    [UIView animateWithDuration:0.15 animations:^{
        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _notificationArrowImageView.alpha = 0;
    }];

    [UIView animateWithDuration:0.2 animations:^{
        _notificationWindow.frame = windowFrame;
    } completion:^(BOOL finished) {
        _notificationWindow.hidden = YES;
    }];

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
        }
        
    }
    
    else if (indexPath.section == 5) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];        
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

#pragma mark - Notification delegate

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    
    if ([_notification.result.total_notif integerValue] == 0) {
        
        _notificationButton.badgeLabel.hidden = YES;
        
    } else {
        
        _notificationButton.enabled = YES;
        
        _notificationButton.badgeLabel.hidden = NO;
        _notificationButton.badgeLabel.text = _notification.result.total_notif;
        
        NSInteger totalNotif = [_notification.result.total_notif integerValue];
        
        CGRect badgeLabelFrame = _notificationButton.badgeLabel.frame;
        
        if (totalNotif >= 10 && totalNotif < 100) {
            
            badgeLabelFrame.origin.x -= 6;
            badgeLabelFrame.size.width += 11;
            
        } else if (totalNotif >= 100 && totalNotif < 1000) {
            
            badgeLabelFrame.origin.x -= 7;
            badgeLabelFrame.size.width += 14;
            
        } else if (totalNotif >= 1000 && totalNotif < 10000) {
            
            badgeLabelFrame.origin.x -= 11;
            badgeLabelFrame.size.width += 22;
            
        } else if (totalNotif >= 10000 && totalNotif < 100000) {
            
            badgeLabelFrame.origin.x -= 17;
            badgeLabelFrame.size.width += 30;
            
        }
        
        _notificationButton.badgeLabel.frame = badgeLabelFrame;
        
    }
}

@end
