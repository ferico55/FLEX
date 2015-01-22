//
//  CategoryViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "category.h"
#import "search.h"
#import "DBManager.h"
#import "CategoryViewController.h"
#import "CategoryViewCell.h"
#import "CategoryResultViewController.h"
#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "Notification.h"
#import "NotificationViewController.h"
#import "NotificationBarButton.h"
#import "NotificationRequest.h"

@interface CategoryViewController () <CategoryViewCellDelegate, UITableViewDelegate, NotificationDelegate>
{
    NSMutableArray *_category;
    Notification *_notification;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) UIWindow *notificationWindow;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationViewController *notificationController;

@end

@implementation CategoryViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CategoryViewController" bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    /** Initialization variable **/
    _category = [NSMutableArray new];
    
    /** Set title and icon for category **/
    NSArray *titles = kTKPDCATEGORY_TITLEARRAY;
    NSArray *dataids = kTKPDCATEGORY_IDARRAY;
    
    for (int i = 0; i<22; i++) {
        NSString * imagename = [NSString stringWithFormat:@"icon_%zd",i];
        [_category addObject:@{kTKPDCATEGORY_DATATITLEKEY : titles[i], kTKPDCATEGORY_DATADIDKEY : dataids[i],kTKPDCATEGORY_DATAICONKEY:imagename}];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.table respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.table setSeparatorInset:UIEdgeInsetsZero];
    }
 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([self.table respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.table setLayoutMargins:UIEdgeInsetsZero];
    }
#endif
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //TODO: change to more flexible counting
    return (_category.count+2)/3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDCATEGORYVIEWCELL_IDENTIFIER;
    
    cell = (CategoryViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [CategoryViewCell newcell];
        ((CategoryViewCell*)cell).delegate = self;
    }

    [((CategoryViewCell*)cell) reset];
    
    /** Flexible view count **/ //TODO::sederhanakan
    NSInteger countdata;
    if (_category.count > indexPath.row) {
        if (_category.count % 3 == 0 || indexPath.row != ([_category count] - 1) / 3) {
            countdata = 3;
        }
        else {
            countdata = [_category count] % 3;
        }
        
        NSArray *tempArray = [_category objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(indexPath.row* 3, countdata)]];
        ((CategoryViewCell*)cell).data = @{kTKPDCATEGORY_DATAINDEXPATHKEY: indexPath, kTKPDCATEGORY_DATACOLUMNSKEY: tempArray};
    }
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    return footerView;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
#endif
}

#pragma mark - Delegate Cell
-(void)CategoryViewCellDelegateCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    NSInteger index = indexpath.section+3*(indexpath.row);
    
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
               kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
    
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"",
                kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : [_category[index] objectForKey:kTKPDSEARCH_APITITLEKEY?:@""],
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};

    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *c = [TKPDTabNavigationController new];
    [c setData:@{kTKPDCATEGORY_DATATYPEKEY: @(kTKPDCATEGORY_DATATYPECATEGORYKEY), kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"", }];
    [c setSelectedIndex:0];
    [c setViewControllers:viewcontrollers];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [nav.navigationBar setTranslucent:NO];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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

@end
