//
//  AlertPriceNotificationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AlertPriceNotificationViewController.h"
#import "Breadcrumb.h"
#import "category.h"
#import "DepartmentTableViewController.h"
#import "DetailPriceAlert.h"
#import "DetailPriceAlertViewController.h"
#import "GeneralAction.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"
#import "PriceAlertCell.h"
#import "Paging.h"
#import "PriceAlert.h"
#import "PriceAlertResult.h"
#import "RKObjectManager.h"
#import "string_product.h"
#import "string_price_alert.h"
#import "TokopediaNetworkManager.h"
#import "DetailPriceAlertViewController.h"

#define CPriceAlertCell @"PriceAlertCell"
#define CDetailPriceAlertTableViewCell @"DetailPriceAlertTableViewCell"

#define CCellIdentifier @"cell"
#define CTagGetPriceAlert 10
#define CTagDeletePriceAlert 11

@interface AlertPriceNotificationViewController ()<TokopediaNetworkManagerDelegate, DepartmentListDelegate, LoadingViewDelegate, UIAlertViewDelegate, NoResultDelegate>{
    IBOutlet UITableView *_table;
}
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation AlertPriceNotificationViewController {
    NSIndexPath *tempUnreadIndexPath;
    LoadingView *loadingView;
    UIRefreshControl *refreshControl;
    NoResultReusableView *_noResultView;
    
    TokopediaNetworkManager *tokopediaNetworkManager;
    RKObjectManager *rkObjectManager;
    NSMutableArray *arrList, *arrDepartment;
    PriceAlert *priceAlert;
    DetailPriceAlert *tempPriceAlert;
    
    NSObject *objTagConfirmDelete;
    int nSelectedDepartment, lastSelectedDepartment;
    int page, latestPage;
    BOOL isFirst;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Segera ikuti perkembangan harga produk yang Anda sukai!"
                                  desc:@"Ini adalah daftar notifikasi harga untuk produk yang Anda ikuti"
                              btnTitle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedPriceNotif:) name:@"didAddedPriceNotif" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovedPriceNotif:) name:@"didRemovedPriceNotif" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CStringNotificationHarga;
    page = 1;
    isFirst = YES;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdatePriceAlert:) name:@"TkpdUpdatePriceAlert" object:nil];
    
    [self initNoResultView];
    
    _table.tableFooterView = [self getActivityIndicator];
    [[self getNetworkManager:CTagGetPriceAlert] doRequest];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CstringFilter style:UIBarButtonItemStylePlain target:self action:@selector(actionShowKategory:)];
}

- (void)notificationUpdatePriceAlert:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *price = [userInfo objectForKey:@"price"];
    
    [self updatePriceAlert:price];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(tempUnreadIndexPath != nil) {
        ((DetailPriceAlert *) [arrList objectAtIndex:tempUnreadIndexPath.row]).pricealert_total_unread = @"0";
    }
    
    [_table reloadData];
    tempPriceAlert = nil;
    tempUnreadIndexPath = nil;
}

- (void)dealloc {
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - UITableView Delegate And DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(arrList == nil)
        return 0;
    
    return arrList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 134;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tempPriceAlert = [arrList objectAtIndex:indexPath.row];
    if(! [tempPriceAlert.pricealert_total_unread isEqualToString:@"0"]) {
        tempUnreadIndexPath = indexPath;
    }
    else if(! (tempPriceAlert.pricealert_is_active!=nil && [tempPriceAlert.pricealert_is_active isEqualToString:@"1"])) {
        return;
    }
    
    
    PriceAlertCell *cell = (PriceAlertCell *)[tableView cellForRowAtIndexPath:indexPath];
    tempPriceAlert.pricealert_product_name = [NSString convertHTML:tempPriceAlert.pricealert_product_name];
    
    DetailPriceAlertViewController *detailPriceAlertViewController = [DetailPriceAlertViewController new];
    detailPriceAlertViewController.detailPriceAlert = tempPriceAlert;
    detailPriceAlertViewController.imageHeader = cell.getProductImage.image;
    detailPriceAlertViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailPriceAlertViewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(arrList.count-1==indexPath.row && page>1 && (tokopediaNetworkManager.getObjectRequest.isExecuting || rkObjectManager!=nil)) {
        _table.tableFooterView = [self getLoadView:CTagGetPriceAlert].view;
    }
    else if(arrList.count-1==indexPath.row && page>1 && !tokopediaNetworkManager.getObjectRequest.isExecuting) {
        _table.tableFooterView = [self getActivityIndicator];
        [[self getNetworkManager:CTagGetPriceAlert] doRequest];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PriceAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:CPriceAlertCell owner:nil options:0];
        cell = [arrPriceAlert objectAtIndex:0];
        cell.viewController = self;
        cell.getBtnProductName.titleLabel.font = [UIFont fontWithName:@"Gotham Book" size:13.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    DetailPriceAlert *detailPriceAlert = [arrList objectAtIndex:indexPath.row];
    //Set Image Product
    if(detailPriceAlert.pricealert_product_image != nil) {
        [cell.getProductImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:detailPriceAlert.pricealert_product_image]]  placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_toped_loading_grey-01" ofType:@".png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.getProductImage.image = image;
        } failure:nil];
    }
    
    
    if(detailPriceAlert.pricealert_is_active!=nil && [detailPriceAlert.pricealert_is_active isEqualToString:@"1"]) {
        cell.userInteractionEnabled = YES;
        [cell setProductName:[NSString convertHTML:detailPriceAlert.pricealert_product_name]];
    }
    else {
        [cell setProductName:@"Produk telah dihapus"];
    }
    
    cell.getViewUnread.hidden = ([detailPriceAlert.pricealert_total_unread isEqualToString:@"0"]);
    [cell setTagBtnClose:(int)indexPath.row];
    [cell setLblDateProduct:detailPriceAlert.pricealert_time];
    [cell setPriceNotification:[self getPrice:detailPriceAlert.pricealert_price]];
    [cell setLowPrice:detailPriceAlert.pricealert_price_min];
    
    
    
    return cell;
}

#pragma mark - UIAction View
- (void)actionShowKategory:(id)sender {
    if(arrList!=nil && arrDepartment!=nil && arrDepartment.count>0) {
        DepartmentTableViewController *departmentViewController = [DepartmentTableViewController new];
        departmentViewController.del = self;
        departmentViewController.navigationItem.title = CStringCategory;
        departmentViewController.arrList = arrDepartment;
        departmentViewController.selectedIndex = nSelectedDepartment;
        //        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:departmentViewController];
        //        navController.navigationBar.translucent = NO;
        //        [self presentViewController:navController animated:YES completion:nil];
        [self.navigationController pushViewController:departmentViewController animated:YES];
    }
}

- (void)actionCloseCell:(id)sender {
    if(tokopediaNetworkManager.getObjectRequest.isExecuting || rkObjectManager!=nil) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringWaitLoading] delegate:self];
        [stickyAlertView show];
    }
    else {
        objTagConfirmDelete = [NSObject new];
        
        UIAlertView *confirmDelete = [[UIAlertView alloc] initWithTitle:nil message:CStringConfirmDeleteCatalog delegate:self cancelButtonTitle:CStringTidak otherButtonTitles:CStringYa, nil];
        confirmDelete.delegate = self;
        confirmDelete.tag = (int)((UIButton *) sender).tag;;
        [confirmDelete show];
    }
}


#pragma mark - Method
- (void)refreshView:(id)sender {
    [refreshControl endRefreshing];
    if(tokopediaNetworkManager.getObjectRequest.isExecuting || rkObjectManager!=nil) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringWaitLoading] delegate:self];
        [stickyAlertView show];
    }
    else {
        latestPage = page;
        page = 1;
        
        _table.allowsSelection = NO;
        [[self getNetworkManager:CTagGetPriceAlert] doRequest];
    }
}

- (NSString *)getPrice:(NSString *)strTempPrice {
    return ([strTempPrice isEqualToString:@"Rp 0"])? CStringAllPrice:strTempPrice;
}

- (void)updatePriceAlert:(NSString *)strPrice {
    ((DetailPriceAlert *) [arrList objectAtIndex:[arrList indexOfObject:tempPriceAlert]]).pricealert_price = strPrice;
    [_table beginUpdates];
    [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[arrList indexOfObject:tempPriceAlert] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_table endUpdates];
}

- (void)deletingPriceAlert:(BOOL)isDeleting {
    if(isDeleting) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.frame = CGRectMake(0, 0, 30, 30);
        [activityIndicatorView startAnimating];
        
        self.navigationItem.rightBarButtonItem.customView = activityIndicatorView;
    }
    else {
        self.navigationItem.rightBarButtonItem.customView = nil;
    }
}

- (LoadingView *)getLoadView:(int)tag {
    if(loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    loadingView.tag = tag;
    
    return loadingView;
}

- (UIActivityIndicatorView *)getActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0, 10, 40, 40);
    [activityIndicator startAnimating];

    return activityIndicator;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}

- (void)tapBackButton {
    [_splitVC.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetPriceAlert) {
        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:CGetPriceAlert, CAction, [NSNumber numberWithInt:page], CPage, nil];
        if(nSelectedDepartment > 0) {
            [dictParam setObject:((Breadcrumb *)[arrDepartment objectAtIndex:nSelectedDepartment]).department_id forKey:CDepartmentID];
        }
        
        return dictParam;
    }
    else if(tag == CTagDeletePriceAlert) {
        return @{CAction:([tempPriceAlert.pricealert_type isEqualToString:@"1"]? CDeletePriceAlert:CDeleteCatalogPriceAlert), CPriceAlertID:tempPriceAlert.pricealert_id};
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagGetPriceAlert) {
        return CInboxPriceAlert;
    }
    else if(tag == CTagDeletePriceAlert) {
        return [NSString stringWithFormat:@"%@/%@", CAction, CPriceAlertPL];
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetPriceAlert) {
        rkObjectManager = [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PriceAlert class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                            }];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PriceAlertResult class]];
        RKObjectMapping *departmentMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
        [departmentMapping addAttributeMappingsFromArray:@[CDepartmentID, CDepartmentName]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext, CUriPrevious:CUriPrevious}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[DetailPriceAlert class]];
        [listMapping addAttributeMappingsFromArray:@[CPriceAlertTotalProduct,
                                                     CPriceAlertPriceMin,
                                                     CPriceAlertIsActive,
                                                     CPriceAlertProductName,
                                                     CPriceAlertProductStatus,
                                                     CPriceAlertTotalUnread,
                                                     CPriceAlertType,
                                                     CPriceAlertPrice,
                                                     CPriceAlertProductImage,
                                                     CPriceAlertID,
                                                     CPriceAlertProductID,
                                                     CPriceAlertTime
                                                     ]];
        
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *departmenetRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CDepartment toKeyPath:CDepartment withMapping:departmentMapping];
        [resultMapping addPropertyMapping:departmenetRel];
        
        RKRelationshipMapping *pagingRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pagingRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:listMapping];
        [resultMapping addPropertyMapping:listRel];
        
        
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:CTagGetPriceAlert] keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [rkObjectManager addResponseDescriptor:responseDescriptorStatus];
        
        return rkObjectManager;
    }
    else if(tag == CTagDeletePriceAlert) {
        rkObjectManager = [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [rkObjectManager addResponseDescriptor:responseDescriptorStatus];
        
        return rkObjectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == CTagGetPriceAlert) {
        PriceAlert *tempPAlert = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return tempPAlert.status;
    }
    else if(tag == CTagDeletePriceAlert) {
        GeneralAction *generalAction = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return generalAction.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    if(tag == CTagGetPriceAlert) {
        _table.allowsSelection = YES;
        _table.tableFooterView = nil;
        priceAlert = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if(priceAlert.result.list != nil) {
            if(page == 1) {
                arrList = [[NSMutableArray alloc] initWithArray:priceAlert.result.list];
            }
            else {
                [arrList addObjectsFromArray:priceAlert.result.list];
            }
            priceAlert.result.list = nil;
            
            if(priceAlert.result.department != nil) {
                if(arrDepartment == nil) {
                    arrDepartment = [[NSMutableArray alloc] initWithArray:priceAlert.result.department];
                    Breadcrumb *breadCrumb = [Breadcrumb new];
                    breadCrumb.department_id = @"-1";
                    breadCrumb.department_name = CStringAllCategory;
                    [arrDepartment insertObject:breadCrumb atIndex:0];
                    priceAlert.result.department = nil;
                }
                
                if(! [priceAlert.result.paging.uri_next isEqualToString:@"0"]) {
                    NSURL *url = [NSURL URLWithString:priceAlert.result.paging.uri_next];
                    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                    NSMutableDictionary *queries = [NSMutableDictionary new];
                    for (NSString *keyValuePair in querry)
                    {
                        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                        NSString *key = [pairComponents objectAtIndex:0];
                        NSString *value = [pairComponents objectAtIndex:1];
                        
                        [queries setObject:value forKey:key];
                    }
                    
                    page = [[queries objectForKey:@"page"] intValue];
                }
                else {
                    page = 1;
                }
            }
        }
        
        
        if(arrList==nil || arrList.count==0) {
            [_table addSubview:_noResultView];
        }else{
            [_noResultView removeFromSuperview];
        }
        
        
        if(_table.delegate == nil) {
            _table.delegate = self;
            _table.dataSource = self;
        }

        [_table reloadData];
    }
    else if(tag == CTagDeletePriceAlert) {
        GeneralAction *generalAction = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if([generalAction.result.is_success isEqualToString:@"1"]) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessRemovePriceAlert] delegate:self];
            [stickyAlertView show];
            
            [arrList removeObject:tempPriceAlert];
            NSMutableIndexSet *section = [[NSMutableIndexSet alloc] init];
            [section addIndex:0];
            [_table reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
            tempPriceAlert = nil;
            
            if(arrList.count > 0){
                [_noResultView removeFromSuperview];
            }else{
                [_table addSubview:_noResultView];
            }
        }
        else {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedDeletePriceAlert] delegate:self];
            [stickyAlertView show];
        }
        
        [self deletingPriceAlert:NO];
    }
    
    rkObjectManager = nil;
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if(tag == CTagGetPriceAlert) {
        
    }
}

- (void)actionBeforeRequest:(int)tag {
    if(tag == CTagGetPriceAlert) {
        
    }
    
}

- (void)actionRequestAsync:(int)tag {
    if(tag == CTagGetPriceAlert) {
        
    }
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagGetPriceAlert) {
        if(_table.allowsSelection) {
            _table.tableFooterView = [self getLoadView:CTagGetPriceAlert].view;
        }
        else {
            _table.allowsSelection = YES;
            page = latestPage;
        }
    }
    else if(tag == CTagDeletePriceAlert) {
        tempPriceAlert = nil;
        [self deletingPriceAlert:NO];
    }
    
    nSelectedDepartment = lastSelectedDepartment;
    rkObjectManager = nil;
}

#pragma mark - DepartmentList Delegate
- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFinishSelectedAtRow:(int)row{
    if(row != nSelectedDepartment) {
        lastSelectedDepartment = nSelectedDepartment;
        nSelectedDepartment = row;
        page = 1;
        [[self getNetworkManager:CTagGetPriceAlert] doRequest];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    if(tokopediaNetworkManager.getObjectRequest.isExecuting || rkObjectManager!=nil) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringWaitLoading] delegate:self];
        [stickyAlertView show];
    }
    else {
        _table.tableFooterView = [self getActivityIndicator];
        [[self getNetworkManager:CTagGetPriceAlert] doRequest];
    }
}

#pragma mark  -UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(objTagConfirmDelete) {
        if(buttonIndex == 1) {
            [self deletingPriceAlert:YES];
            tempPriceAlert = [arrList objectAtIndex:alertView.tag];
            [[self getNetworkManager:CTagDeletePriceAlert] doRequest];
        }
        
        objTagConfirmDelete = nil;
    }
}

#pragma mark - Notification Method
- (void)didAddedPriceNotif:(NSNotification*)notification {
    self.view = _contentView;
}

- (void)didRemovedPriceNotif:(NSNotification*)notification {
    
}

@end


