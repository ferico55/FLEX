//
//  ProdukFeedView.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "string_product.h"
#import "detail.h"
#import "GeneralProductCell.h"
#import "HistoryProductViewController.h"
#import "GeneralProductCell.h"
#import "HistoryProduct.h"
#import "DetailProductViewController.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultView.h"

@interface HistoryProductViewController() <UITableViewDataSource, UITableViewDelegate, GeneralProductCellDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *product;

@end


@implementation HistoryProductViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    NSMutableArray *_lastStoredArray;
    NSMutableArray *_refreshedArray;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    TokopediaNetworkManager *_networkManager;
    LoadingView *_loadingView;
    NoResultView *_noResult;
    NSString *strUserID;
    BOOL hasInitData;
}

#pragma mark - Factory Method

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _product = [NSMutableArray new];
    _lastStoredArray = [NSMutableArray new];
    _refreshedArray = [NSMutableArray new];
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, 53, 0);
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];

    NSLog(@"going here first");
    
    
    if (!_isrefreshview) {
//        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
//            [self loadData];
            hasInitData = YES;
            [_networkManager doRequest];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_networkManager requestCancel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    
    //Check login with different id
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];

    if(hasInitData)
    {
        hasInitData = !hasInitData;
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
    }
    else if(! [strUserID isEqualToString:[NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]]]) {
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
        _product = [NSMutableArray new];
        _lastStoredArray = [NSMutableArray new];
        _refreshedArray = [NSMutableArray new];
        _urinext = nil;
        _page = 1;
        _isnodata = YES;
        _isrefreshview = NO;
        [_networkManager doRequest];
    }
}



#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : count;
#else
    return _isnodata ? 0 : count;
#endif
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
        
        cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralProductCell newcell];
            ((GeneralProductCell*)cell).delegate = self;
        }
        
        
        if (_product.count > indexPath.row) {
            //reset cell
            [self reset:(GeneralProductCell*)cell];
            /** Flexible view count **/
            NSUInteger indexsegment = indexPath.row * 2;
            NSUInteger indexmax = indexsegment + 2;
            NSUInteger indexlimit = MIN(indexmax, _product.count);
            
            NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
            
            NSUInteger i;
            
            for (UIView *view in ((GeneralProductCell*)cell).viewcell ) {
                view.hidden = YES;
            }
            
            for (i = 0; (indexsegment + i) < indexlimit; i++) {
                HistoryProductList *list = [_product objectAtIndex:indexsegment + i];
                ((UIView*)((GeneralProductCell*)cell).viewcell[i]).hidden = NO;
                (((GeneralProductCell*)cell).indexpath) = indexPath;
                
                ((UILabel*)((GeneralProductCell*)cell).labelprice[i]).text = list.product_price;
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:list.product_name];
                NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                [paragrahStyle setLineSpacing:5];
                [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [list.product_name length])];
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).attributedText = attributedString ;
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).lineBreakMode = NSLineBreakByTruncatingTail;
                
                if([list.shop_gold_status isEqualToString:@"1"]) {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = NO;
                } else {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = YES;
                }
                
                
                //                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).text = list.catalog_name?:list.product_name;
                ((UILabel*)((GeneralProductCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
                
                NSString *urlstring = list.product_image;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
                thumb.image = nil;
                
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    [thumb setImage:image];
                    [thumb setContentMode:UIViewContentModeScaleAspectFill];
#pragma clang diagnostic pop
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                }];
            }
        }
    } else {
        static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
    }

    return cell;
  
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
//            [self configureRestKit];
//            [self loadData];
            [_networkManager doRequest];
        }
    }
}


#pragma mark - Request + Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

//-(void)loadData
//{
//    if (_request.isExecuting) return;
//    
//    // create a new one, this one is expired or we've never gotten it
//    if (!_isrefreshview) {
//        _table.tableFooterView = _footer;
//        [_act startAnimating];
//    }
//    
//    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEHISTORYPRODUCTACT};
//    
//    _requestcount ++;
//    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST
//                                                                      path:kTKPDHOMEHOTLIST_APIPATH
//                                                                parameters:[param encrypt]];
//    
//    
//    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        [self requestsuccess:mappingResult withOperation:operation];
//        [_act stopAnimating];
//        _table.tableFooterView = nil;
//        [_table reloadData];
//        _isrefreshview = NO;
//        [_refreshControl endRefreshing];
//        [_timer invalidate];
//        _timer = nil;
//        
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        /** failure **/
//        [self requestfailure:error];
//        //[_act stopAnimating];
//        _table.tableFooterView = nil;
//        _isrefreshview = NO;
//        [_refreshControl endRefreshing];
//        [_timer invalidate];
//        _timer = nil;
//    }];
//    
//    [_operationQueue addOperation:_request];
//    
//    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout:) userInfo:nil repeats:NO];
//    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//}
//
//-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
//    NSDictionary *result = ((RKMappingResult*)object).dictionary;
//    id info = [result objectForKey:@""];
//    HistoryProduct *historyproduct = info;
//    BOOL status = [historyproduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];

//    if(status) {
//        [self requestproceed:object];
//        
//        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHISTORYPRODUCT_APIRESPONSEFILE];
//        NSError *error;
//        BOOL success = [result writeToFile:path atomically:YES];
//        if (!success) {
//            NSLog(@"writeToFile failed with error %@", error);
//        }
//
//    }
//}

//-(void) requestproceed:(id)object {
//    if (object) {
//        NSDictionary *result = ((RKMappingResult*)object).dictionary;
//        id stat = [result objectForKey:@""];
//        HistoryProduct *HistoryProduct = stat;
//        BOOL status = [HistoryProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];
//        
//        if (status) {
//            if(_isrefreshview) {
//                [_product removeAllObjects];
//            }
//            
//            [_product addObjectsFromArray:HistoryProduct.result.list];
//            
//            if (_product.count >0) {
//                _isnodata = NO;
//                _urinext =  HistoryProduct.result.paging.uri_next;
//                NSURL *url = [NSURL URLWithString:_urinext];
//                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
//                
//                NSMutableDictionary *queries = [NSMutableDictionary new];
//                [queries removeAllObjects];
//                for (NSString *keyValuePair in querry)
//                {
//                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//                    NSString *key = [pairComponents objectAtIndex:0];
//                    NSString *value = [pairComponents objectAtIndex:1];
//                    
//                    [queries setObject:value forKey:key];
//                }
//                
////                _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
//            }
//        }
//        else{
//            
//            [self cancel];
//            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
//            if ([(NSError*)object code] == NSURLErrorCancelled) {
//                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
//                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
//                    _table.tableFooterView = _footer;
//                    [_act startAnimating];
//                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
//                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
//                }
//                else
//                {
//                    [_act stopAnimating];
//                    _table.tableFooterView = nil;
//                }
//            }
//            else
//            {
//                [_act stopAnimating];
//                _table.tableFooterView = nil;
//            }
//            
//        }
//    }
//}
//
//-(void) requestfailure:(id)error {
//
//}
//
//- (void)requesttimeout
//{
//    
//}
//
//-(void) configureRestKit
//{
//    
//
//}
//
//-(void)requesttimeout:(NSTimer*)timer
//{
//    
//}

#pragma mark - Cell Delegate

-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section+2*(indexPath.row);
    HistoryProductList *list = _product[index];

    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id, @"is_dismissed" : @YES};
    
    [self.delegate pushViewController:vc];
}



#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
//    [self configureRestKit];
//    [self loadData];
    [_networkManager doRequest];
}


-(void)reset:(GeneralProductCell*)cell
{
    [cell.thumb makeObjectsPerformSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [cell.labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.viewcell makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
}


#pragma mark - Tokopedia Network Delegate
- (NSString *)getPath:(int)tag {
    return kTKPDHOMEHOTLIST_APIPATH;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEHISTORYPRODUCTACT};
    return param;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[HistoryProduct class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HistoryProductResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[HistoryProductList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY,
                                                 kTKPDDETAILCATALOG_APIPRODUCTIDKEY,
                                                 kTKPDDETAILCATALOG_APISHOPGOLDSTATUSKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                 API_PRODUCT_NAME_KEY
                                                 ]];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDHOMEHOTLIST_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectmanager;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    HistoryProduct *history = stat;
    
    return history.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    else{
        _table.tableFooterView = nil;
        [_act stopAnimating];
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    HistoryProduct *feed = [result objectForKey:@""];
    
    [_product addObjectsFromArray: feed.result.list];
    
    if (_product.count >0) {
        _isnodata = NO;
        _urinext =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];
        [_act stopAnimating];
    } else {
        _isnodata = YES;
        _table.tableFooterView = _noResult;
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    [_table reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [_refreshControl endRefreshing];
    _table.tableFooterView = _loadingView.view;
    _isrefreshview = NO;
}

#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_networkManager doRequest];
}


@end
