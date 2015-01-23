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

#import "TKPDTabShopViewController.h"
#import "ShopFavoritedViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "ShopTalkViewController.h"

#import "NotificationBarButton.h"

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

@property (strong, nonatomic) UIView *notificationView;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationViewController *notificationController;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    
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
 
    // Remove default table inset
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);

    // Set round corner profile picture
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2;

    // Set round corner profile picture
    self.shopImageView.layer.cornerRadius = self.shopImageView.frame.size.width/2;

    // Set create shop button corner
    self.createShopButton.layer.cornerRadius = 2;
    
    _depositLabel.text = @"";

    _notificationView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _notificationView.clipsToBounds = YES;
    
    UIView *notificationTapToCloseArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowDidTap)];
    [notificationTapToCloseArea addGestureRecognizer:tapRecognizer];
    [_notificationView addSubview:notificationTapToCloseArea];
    
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
    [_notificationView addSubview:_notificationArrowImageView];
    
    NotificationRequest *notificationRequest = [NotificationRequest new];
    notificationRequest.delegate = self;
    [notificationRequest loadNotification];

    [self configureRestKit];
    
    if (_isNoDataDeposit) {
        [self loadDataDeposit];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notification methods

- (void)barButtonDidTap
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    _notificationController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    _notificationController.notification = _notification;
    
    [[[self tabBarController] view] addSubview:_notificationView];
    
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    windowFrame.size.height = 0;
    _notificationView.frame = windowFrame;
    
    CGRect tableFrame = [[UIScreen mainScreen] bounds];
    tableFrame.origin.y = 64;
    self.notificationController.tableView.frame = tableFrame;
    tableFrame.size.height = self.view.frame.size.height-64;
    
    [_notificationView addSubview:_notificationController.tableView];
    
    _notificationArrowImageView.alpha = 1;
    
    [UIView animateWithDuration:0.7 animations:^{
        _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }];
    
    [UIView animateWithDuration:0.55 animations:^{
        _notificationView.frame = [[UIScreen mainScreen] bounds];
        self.notificationController.tableView.frame = tableFrame;
    }];
}

- (void)windowDidTap
{
    CGRect windowFrame = _notificationView.frame;
    windowFrame.size.height = 0;

    [UIView animateWithDuration:0.15 animations:^{
        _notificationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _notificationArrowImageView.alpha = 0;
    }];

    [UIView animateWithDuration:0.2 animations:^{
        _notificationView.frame = windowFrame;
    } completion:^(BOOL finished) {
        [_notificationView removeFromSuperview];
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
            return 3;
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
    self.hidesBottomBarWhenPushed = YES;
    
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
        purchaseController.notification = _notification;
        [self.navigationController pushViewController:purchaseController animated:YES];
    }
    
    else if (indexPath.section == 2 && indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TKPDTabShopViewController *shopViewController = [storyboard instantiateViewControllerWithIdentifier:@"TKPDTabShopViewController"];
        shopViewController.data = @{MORE_SHOP_ID : [_auth objectForKey:MORE_SHOP_ID],
                                    MORE_AUTH : _auth,
                                    MORE_SHOP_NAME : [_auth objectForKey:MORE_SHOP_NAME]
                                    };
        [self.navigationController pushViewController:shopViewController animated:YES];
    }
    
    else if (indexPath.section == 2 && indexPath.row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SalesViewController *salesController = [storyboard instantiateViewControllerWithIdentifier:@"SalesViewController"];
        salesController.notification = _notification;
        [self.navigationController pushViewController:salesController animated:YES];
    }
    
    else if (indexPath.section == 5) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];        
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

    NSDictionary *param = @{API_DEPOSIT_ACTION : API_DEPOSIT_GET_DETAIL};
    
    _depositRequest = [_depositObjectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodGET
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
    }
}

- (void)requestfailure:(NSError *)error
{
    
}


//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"Sales"]) {
//        SalesViewController *salesController = segue.destinationViewController;
//        salesController.notification = _notification;
//    }
//    else if ([segue.identifier isEqualToString:@"Purchase"]) {
//        PurchaseViewController *purchaseController = segue.destinationViewController;
//        purchaseController.notification = _notification;
//    }
//}

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
