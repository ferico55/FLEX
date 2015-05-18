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
#import "ProductFeedViewController.h"
#import "GeneralProductCell.h"
#import "ProductFeed.h"
#import "DetailProductViewController.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultView.h"

@interface ProductFeedViewController() <UITableViewDataSource, UITableViewDelegate, GeneralProductCellDelegate, UIScrollViewDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *product;
@property (nonatomic)  BOOL *isDismissVc;
@property (nonatomic, assign) CGFloat lastContentOffset;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionCrazy,
    ScrollDirectionLeft,
    ScrollDirectionRight,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionHorizontal,
    ScrollDirectionVertical
} ScrollDirection;

typedef enum TagRequest {
    ProductFeedTag
} TagRequest;

@end


@implementation ProductFeedViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    BOOL hasInitData;
    NSString *strUserID;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    TokopediaNetworkManager *_networkManager;
    LoadingView *_loadingView;
    NoResultView *_noResult;
}

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
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = ProductFeedTag;
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, screenRect.size.width, 200)];
    
    /** create new **/
    _product = [NSMutableArray new];
    
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

    _table.contentInset = UIEdgeInsetsMake(5, 0, 53, 0);
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Home - Product Feed";
    
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [_networkManager doRequest];
        }
    }
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    
    //Check Difference userID
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
        _page = 1;
        _isnodata = YES;
        _product = [NSMutableArray new];
        _isrefreshview = NO;
        _urinext = nil;
        [_networkManager doRequest];
    }
    
    self.navigationItem.backBarButtonItem = backBarButtonItem;
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
            [self reset:cell];
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
                ProductFeedList *list = [_product objectAtIndex:indexsegment + i];
                ((UIView*)((GeneralProductCell*)cell).viewcell[i]).hidden = NO;
                (((GeneralProductCell*)cell).indexpath) = indexPath;
                
                ((UILabel*)((GeneralProductCell*)cell).labelprice[i]).text = list.product_price;
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:list.product_name];
                NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                [paragrahStyle setLineSpacing:5];
                [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [list.product_name length])];
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).attributedText = attributedString;
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).lineBreakMode = NSLineBreakByTruncatingTail;
                ((UILabel*)((GeneralProductCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
                
                if([list.shop_gold_status isEqualToString:@"1"]) {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = NO;
                } else {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = YES;
                }
                
                
                NSString *urlstring = list.product_image;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
                thumb.image = nil;
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    [thumb setImage:image];
                    [thumb setContentMode:UIViewContentModeScaleAspectFill];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
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
            [_networkManager doRequest];
        }
    }
}



#pragma mark - Cell Delegate
-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section+2*(indexPath.row);
    ProductFeedList *list = _product[index];

    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id, @"is_dismissed" : @YES};

    [self.delegate pushViewController:vc];
}



#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
//    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
//    [_table reloadData];
    /** request data **/
    [_networkManager doRequest];
}


-(void)reset:(UITableViewCell*)cell
{
    [((GeneralProductCell*)cell).thumb makeObjectsPerformSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [((GeneralProductCell*)cell).labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).viewcell makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ScrollDirection scrollDirection;
    if (self.lastContentOffset > scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionRight;
        NSLog(@"Scrolling direction: right");
    } else if (self.lastContentOffset < scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionLeft;
         NSLog(@"Scrolling direction: left");
    }
    self.lastContentOffset = scrollView.contentOffset.x;
    
    // do whatever you need to with scrollDirection here.
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:kTKPDHOMEPRODUCTFEEDACT, kTKPDHOME_APIACTIONKEY, @(_page),kTKPDHOME_APIPAGEKEY, @(kTKPDHOMEHOTLIST_LIMITPAGE), kTKPDHOME_APILIMITPAGEKEY, nil];
    
    return parameter;
}

- (NSString *)getPath:(int)tag {
    return kTKPDHOMEHOTLIST_APIPATH;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    ProductFeed *list = stat;
    
    return list.status;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductFeed class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductFeedResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ProductFeedList class]];
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
                                                                                             pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectmanager;
}

//- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
//{
//    
//}

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
    ProductFeed *feed = [result objectForKey:@""];
    
    if(_page == 1) {
        _product = [feed.result.list mutableCopy];
    } else {
        [_product addObjectsFromArray: feed.result.list];
    }
    
    if (_product.count >0) {
        _isnodata = NO;
        _urinext =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];
        
        if(_urinext!=nil && [_urinext isEqualToString:@"0"]) {
            [_act stopAnimating];
            _table.tableFooterView = nil;
        }
    } else {
        _isnodata = YES;
        _table.tableFooterView = _noResult;
    }

    
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [_table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else  {
        [_table reloadData];
    }

}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    _table.tableFooterView = _loadingView.view;
}

#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [_networkManager doRequest];
}

@end
