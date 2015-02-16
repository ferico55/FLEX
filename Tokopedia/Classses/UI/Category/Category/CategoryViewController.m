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
#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "NotificationManager.h"


@interface CategoryViewController () <CategoryViewCellDelegate, UITableViewDelegate>
{
    NSMutableArray *_category;
    NotificationManager *_notifManager;
}

@property (weak, nonatomic) IBOutlet UITableView *table;


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
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(goToViewController:) name:@"goToViewController" object:nil];
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
    [self initNotificationManager];
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
    [self tapWindowBar];
}



@end
