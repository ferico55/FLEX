//
//  ReputationMyProductViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationMyProductViewController.h"
#import "ReputationCell.h"
#import "ReputationShopHeader.h"
#import "ReputationDetailFormViewController.h"
#import "ReputationDetailViewController.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "Reputation.h"

#import "reputation_string.h"

@interface ReputationMyProductViewController () <UITableViewDataSource, UITableViewDelegate,
    ReputationCellDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *footer;

@end

@implementation ReputationMyProductViewController {
    BOOL _isNoData;
    NSString *_uriNext;
    NSInteger _nextPage;
    NSInteger _limit;
    
    ReputationShopHeader *_shopReputation;
    TokopediaNetworkManager *_networkManager;
    LoadingView *_loadingView;
    
    RKObjectManager *_listObjectManager;
    UIRefreshControl *_refreshControl;
    
    BOOL _isRefreshingView;
    UIActivityIndicatorView *_indicator;
    
    NSMutableArray *_reputationArray;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isRefreshingView = NO;
        _isNoData = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kTKPDREPUTATION_TITLE;
    
    _table.delegate = self;
    _table.dataSource = self;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _nextPage = 1;
    _reputationArray = [NSMutableArray new];
    
    [_networkManager doRequest];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableData Source
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    _shopReputation = [ReputationShopHeader new];
    
    return _shopReputation.footer;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _shopReputation = [ReputationShopHeader new];

    return _shopReputation;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 108.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isNoData ? 0 : _reputationArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    if(!_isNoData) {
        NSString *cellid = kTKPDREPUTATION_CELL_ID;
        
        cell = (ReputationCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ReputationCell newcell];
            ((ReputationCell *)cell).delegate = self;
        }
        
        ((ReputationCell *)cell).indexpath = indexPath;
        ((ReputationCell *)cell).productLabel.text = @"Cumi Kamu";

    } else {
        static NSString *CellIdentifier = @"cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = @"no data";
        cell.detailTextLabel.text = @"no desc";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReputationDetailViewController *reputationDetail = [ReputationDetailViewController new];
    [self.navigationController pushViewController:reputationDetail animated:YES];
}

#pragma mark - ReputationCell Delegate
- (void)ReputationCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    
}

#pragma mark - Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    return @{
             kTKPDREPUTATION_ACTION_KEY : kTKPDREPUTATION_ACTION_GETLIST,
             };
}

- (NSString *)getPath:(int)tag {
    return kTKPDREPUTATION_REQUEST_PATH;
}

- (id)getObjectManager:(int)tag {
    _listObjectManager = [RKObjectManager sharedClient];


    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Reputation class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReputationResult class]];
    
    RKObjectMapping *reputationListMapping = [RKObjectMapping mappingForClass:[ReputationList class]];
    [reputationListMapping addAttributeMappingsFromArray:@[
                                                    kTKPDREPUTATION_INBOX_ID,
                                                    kTKPDREPUTATION_ID,
                                                    kTKPDREPUTATION_ORDER_ID,
                                                    kTKPDREPUTATION_ROLE,
                                                    kTKPDREPUTATION_SELLER_SCORE,
                                                    kTKPDREPUTATION_BUYER_SCORE,
                                                    kTKPDREPUTATION_REVIEWEE_NAME,
                                                    kTKPDREPUTATION_REVIEWEE_URI,
                                                    kTKPDREPUTATION_REVIEWEE_PICTURE,
                                                    kTKPDREPUTATION_REVIEWEE_SCORE,
                                                    kTKPDREPUTATION_REVIEWEE_SCORE_STATUS,
                                                    kTKPDREPUTATION_REVIEWEE_ROLE,
                                                    kTKPDREPUTATION_CREATE_TIME,
                                                    kTKPDREPUTATION_CREATE_TIME_AGO,
                                                    kTKPDREPUTATION_INVOICE_REF_NUM,
                                                    kTKPDREPUTATION_INVOICE_URI,
                                                    kTKPDREPUTATION_SHOW_REVIEWEE_SCORE,
                                                    kTKPDREPUTATION_READ_STATUS
                                                    ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIPAGINGKEY:kTKPD_APIPAGINGKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:reputationListMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDREPUTATION_REQUEST_PATH keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_listObjectManager addResponseDescriptor:responseDescriptor];
    
    return _listObjectManager;
}


- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    Reputation *reputation = stat;
    
    return reputation.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (!_isRefreshingView) {
        _table.tableFooterView = _footer;
        [_indicator startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_indicator stopAnimating];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    Reputation *reputation = [result objectForKey:@""];
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    [_reputationArray addObjectsFromArray: reputation.result.list];
    
    if (_reputationArray.count > 0) {
        _isNoData = NO;
        _uriNext =  reputation.result.paging.uri_next;
        _nextPage = [[_networkManager splitUriToPage:_uriNext] integerValue];
    }
    
    [_table reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [_refreshControl endRefreshing];
    _table.tableFooterView = _loadingView.view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
