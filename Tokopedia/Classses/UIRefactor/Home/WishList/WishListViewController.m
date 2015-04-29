//
//  WishListViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "detail.h"
#import "DetailProductViewController.h"
#import "LoadingView.h"
#import "Paging.h"
#import "string_home.h"
#import "WishListViewController.h"
#import "WishListObject.h"
#import "WishListObjectList.h"
#import "WishListObjectResult.h"
@interface WishListViewController()<LoadingViewDelegate>

@end

@implementation WishListViewController
{
    NSMutableArray *product;
    int page, limit, requestCount;
    BOOL isNoData, isRefreshView, hasInitData;
    NSString *uriNext, *strUserID;
    __weak RKObjectManager *objectManager;
    __weak RKManagedObjectRequestOperation *request;
    NSOperationQueue *operationQueue;
    NSTimer *timer;
    
    LoadingView *loadingView;
    UIRefreshControl *refreshControl;
}
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isNoData = YES;
    operationQueue = [NSOperationQueue new];
    tokoPediaNetworkManager = [TokopediaNetworkManager new];
    tokoPediaNetworkManager.delegate = self;
    
    loadingView = [LoadingView new];
    
    /** create new **/
    product = [NSMutableArray new];
    
    /** set first page become 1 **/
    page = 1;
    
    /** set max data per page request **/
    limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set table view datasource and delegate **/
    tblWishList.delegate = self;
    tblWishList.dataSource = self;
    
    /** set table footer view (loading act) **/
    tblWishList.tableFooterView = footer;
    [activityIndicator startAnimating];
    tblWishList.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
    CGRect rectTable = tblWishList.frame;
    rectTable.size.height -= 105;
    tblWishList.contentInset = UIEdgeInsetsMake(0, 0, 53, 0);
    tblWishList.frame = rectTable;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    
    if (product.count > 0) {
        isNoData = NO;
    }
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tblWishList addSubview:refreshControl];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [tokoPediaNetworkManager requestCancel];
    tokoPediaNetworkManager.delegate = nil;
    tokoPediaNetworkManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (! isRefreshView) {
        [self configureRestKit];
        if (isNoData || (uriNext != NULL && ![uriNext isEqualToString:@"0"] && uriNext != 0)) {
            [self loadData];
        }
    }
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
 
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
        product = [NSMutableArray new];
        page = 1;
        isNoData = YES;
        isRefreshView = NO;
        uriNext = nil;
        [tokoPediaNetworkManager doRequest];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - UITableView Delegate & Data Source
- (void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section+2*(indexPath.row);
    WishListObjectList *list = product[index];
    
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id, @"is_dismissed" : @YES};
    
    [self.delegate pushViewController:vc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (product.count%2==0)?product.count/2:product.count/2+1;
    return isNoData ? 0 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (! isNoData)
    {
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
        
        cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [GeneralProductCell newcell];
            cell.contentView.userInteractionEnabled = YES;
            ((GeneralProductCell*)cell).delegate = self;
        }
        
        if (product.count > indexPath.row)
        {
            //reset cell
            [self reset:cell];
            /** Flexible view count **/
            NSUInteger indexsegment = indexPath.row * 2;
            NSUInteger indexmax = indexsegment + 2;
            NSUInteger indexlimit = MIN(indexmax, product.count);
            
            NSAssert(!(indexlimit > product.count), @"producs out of bounds");
            
            NSUInteger i;
            
            for (UIView *view in ((GeneralProductCell*)cell).viewcell ) {
                view.hidden = YES;
            }
            
            for (i = 0; (indexsegment + i) < indexlimit; i++) {
                WishListObjectList *list = [product objectAtIndex:indexsegment + i];
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
                
                if(list.shop_gold_status == 1) {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = NO;
                } else {
                    ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = YES;
                }
                
                NSString *urlstring = list.product_image;
                NSURLRequest *localRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
                thumb.image = nil;
                [thumb setImageWithURLRequest:localRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row)
    {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        if (uriNext != NULL && ![uriNext isEqualToString:@"0"] && uriNext != 0)
        {
            [self configureRestKit];
            [self loadData];
        }
    }
}

#pragma mark - TokopediaNetwork Delegate
- (NSDictionary*)getParameter:(int)tag
{
    return @{kTKPDHOME_APIACTIONKEY      :   kTKPDGET_WISH_LIST,
             kTKPDHOME_APIPAGEKEY        :       @(page),
             kTKPDHOME_APILIMITPAGEKEY   :   @(kTKPDHOMEHOTLIST_LIMITPAGE)};
}

- (NSString*)getPath:(int)tag
{
    return kTKPDHOMEHOTLIST_APIPATH;
}

- (id)getObjectManager:(int)tag
{
    // initialize RestKit
    objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[WishListObject class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[WishListObjectList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 KTKPDSHOP_GOLD_STATUS,
                                                 KTKPDSHOP_ID,
                                                 KTKPDPRODUCT_RATING_POINT,
                                                 KTKPDPRODUCT_DEPARTMENT_ID,
                                                 KTKPDPRODUCT_ETALASE,
                                                 KTKPDSHOP_FEATURED_SHOP,
                                                 KTKPDSHOP_URL,
                                                 KTKPDPRODUCT_STATUS,
                                                 KTKPDPRODUCT_ID,
                                                 KTKPDPRODUCT_IMAGE_FULL,
                                                 KTKPDPRODUCT_CURRENCY_ID,
                                                 KTKPDPRODUCT_RATING_DESC,
                                                 KTKPDPRODUCT_CURRENCY,
                                                 KTKPDPRODUCT_TALK_COUNT,
                                                 KTKPDPRODUCT_PRICE_NO_IDR,
                                                 KTKPDPRODUCT_IMAGE,
                                                 KTKPDPRODUCT_PRICE,
                                                 KTKPDPRODUCT_SOLD_COUNT,
                                                 KTKPDPRODUCT_RETURNABLE,
                                                 KTKPDSHOP_LOCATION,
                                                 KTKPDPRODUCT_NORMAL_PRICE,
                                                 KTKPDPRODUCT_IMAGE_300,
                                                 KTKPDSHOP_NAME,
                                                 KTKPDPRODUCT_REVIEW_COUNT,
                                                 KTKPDSHOP_IS_OWNER,
                                                 KTKPDPRODUCT_URL,
                                                 KTKPDPRODUCT_NAME
                                                 ]];
    
    //relation
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[WishListObjectResult class]];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    return ((WishListObject *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self requestsuccess:successResult withOperation:operation];
    [tblWishList reloadData];
    isRefreshView = NO;
    [refreshControl endRefreshing];

    if(tblWishList.contentSize.height <= tblWishList.bounds.size.height)
        [activityIndicator setHidden:YES];
    if(product.count == 0)
        [self.view addSubview:viewNoData];
    else
        [viewNoData removeFromSuperview];
}


- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    /** failure **/
}

- (void)actionBeforeRequest:(int)tag
{
    
}

- (void)actionRequestAsync:(int)tag
{

}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    loadingView.delegate = self;
    tblWishList.tableFooterView = loadingView.view;
    isRefreshView = NO;
    [refreshControl endRefreshing];
}



#pragma mark - Method
- (void)reset:(UITableViewCell*)cell
{
    [((GeneralProductCell*)cell).thumb makeObjectsPerformSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    [((GeneralProductCell*)cell).labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).viewcell makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
}

- (void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [product removeAllObjects];
    page = 1;
    requestCount = 0;
    isRefreshView = YES;
    
    [tblWishList reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

- (void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    WishListObject *wishListObject = [result objectForKey:@""];
    BOOL status = [wishListObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestproceed:wishListObject withObject:object];
        
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEPRODUCTFEED_APIRESPONSEFILE];
        NSError *error;
        BOOL success = [result writeToFile:path atomically:YES];
        if (!success) {
            NSLog(@"writeToFile failed with error %@", error);
        }
        
        
        //Hidden activity indicator
        [activityIndicator setHidden:[wishListObject.result.paging.uri_next isEqualToString:@"0"]];
    }
}

- (void)cancel
{
    [request cancel];
    request = nil;
    [objectManager.operationQueue cancelAllOperations];
    objectManager = nil;
}


- (void)requestproceed:(WishListObject *)wishListObject withObject:(id)object
{
    if (object)
    {
        BOOL status = [wishListObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status)
        {
            [product addObjectsFromArray:wishListObject.result.list];
            
            if (product.count > 0) {
                isNoData = NO;
                uriNext =  wishListObject.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:uriNext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                NSMutableDictionary *queries = [NSMutableDictionary new];
                
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] intValue];
            }
        }
        else
        {
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled)
            {
                if (requestCount < kTKPDREQUESTCOUNTMAX)
                {
                    NSLog(@" ==== REQUESTCOUNT %zd =====", requestCount);
                    tblWishList.tableFooterView = footer;
                }
                else
                    tblWishList.tableFooterView = nil;
            }
            else
                tblWishList.tableFooterView = nil;
        }
    }
}


-(void)loadData
{
//    if(request.isExecuting)
//        return;
    
    // create a new one, this one is expired or we've never gotten it
    if(! isRefreshView) {
        tblWishList.tableFooterView = footer;
        //        [_act startAnimating];
    }
    
    [tokoPediaNetworkManager doRequest];
}

- (void)requestTimeout:(NSTimer*)timer
{
    
}

- (void) requestfailure:(id)error {
    
}

- (void)configureRestKit
{
    
}



#pragma mark - Loading View Delegate
- (void)pressRetryButton
{
    tblWishList.tableFooterView = footer;
    [activityIndicator startAnimating];
    [tokoPediaNetworkManager doRequest];
}
@end
