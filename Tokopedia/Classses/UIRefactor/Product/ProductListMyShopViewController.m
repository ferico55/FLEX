//
//  ProductListMyShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "sortfiltershare.h"
#import "ProductListMyShopViewController.h"
#import "ManageProduct.h"
#import "URLCacheController.h"
#import "MGSwipeButton.h"
#import "detail.h"
#import "EtalaseList.h"
#import "ProductListMyShopCell.h"
#import "ShopSettings.h"
#import "DetailProductViewController.h"
#import "ProductAddEditViewController.h"
#import "MyShopEtalaseFilterViewController.h"

#import "SortViewController.h"
#import "FilterViewController.h"

@interface ProductListMyShopViewController ()<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, MGSwipeTableCellDelegate, SortViewControllerDelegate, MyShopEtalaseFilterViewControllerDelegate>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _isnodata;
    
    NSOperationQueue *_operationQueue;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSMutableDictionary *_datainput;
    NSMutableDictionary *_dataFilter;
    
    NSMutableArray *_list;
    ManageProduct*_product;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    __weak RKObjectManager *_objectmanagerActionMoveToWarehouse;
    __weak RKManagedObjectRequestOperation *_requestActionMoveToWarehouse;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    NSDictionary *_auth;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;


@end

@implementation ProductListMyShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = TITLE_LIST_PRODUCT;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list= [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _dataFilter = [NSMutableDictionary new];
    
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _page = 1;
    _limit = kTKPDDETAILDEFAULT_LIMITPAGE;
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;

    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateView:) name:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    [self configureRestKit];
    [self request];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata && _page<=1) {
            [self request];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDSETTINGPRODUCTCELL_IDENTIFIER;
		
		cell = (ProductListMyShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ProductListMyShopCell newcell];
            ((ProductListMyShopCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ManageProductList *list = _list[indexPath.row];
            [((ProductListMyShopCell*)cell).labelname setText:list.product_name animated:YES];
            [((ProductListMyShopCell*)cell).labeletalase setText:list.product_etalase animated:YES];
            [((ProductListMyShopCell*)cell).labelprice setText:[NSString stringWithFormat:@"%@ %@",list.product_currency, list.product_normal_price] animated:YES];
            ((ProductListMyShopCell*)cell).indexpath = indexPath;
            
            UIActivityIndicatorView *act = ((ProductListMyShopCell*)cell).act;
            [act startAnimating];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image_300] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = ((ProductListMyShopCell*)cell).thumb;
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
                [act stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];
        }
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}


#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_searchbar resignFirstResponder];
    
    ManageProductList *list = _list[indexPath.row];
    DetailProductViewController *detailProductVC = [DetailProductViewController new];
    detailProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: @(list.product_id),
                             kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                             DATA_PRODUCT_DETAIL_KEY : list,
                            };
    [self.navigationController pushViewController:detailProductVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

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
            [self configureRestKit];
            [self request];
        }
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_searchbar resignFirstResponder];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_searchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([sender tag] == 11) {
            ProductAddEditViewController *vc = [ProductAddEditViewController new];
            vc.data = @{
                        kTKPD_AUTHKEY                   : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                        DATA_TYPE_ADD_EDIT_PRODUCT_KEY  : @(TYPE_ADD_EDIT_PRODUCT_ADD),
                        };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_FILTER_TYPE_SORT:
            {
                NSIndexPath *indexpath = [_dataFilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SortViewController *vc = [SortViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEHOTLISTVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case BUTTON_FILTER_TYPE_ETALASE:
            {
                NSIndexPath *indexpath = [_dataFilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                MyShopEtalaseFilterViewController *vc = [MyShopEtalaseFilterViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case BUTTON_FILTER_TYPE_SHARE:
            {
                NSString *activityItem = [NSString stringWithFormat:@"Jual %@ | Tokopedia %@", [_data objectForKey:@"title"], [_data objectForKey:@"url"]];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                 applicationActivities:nil];
                activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:activityController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }

        

    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ManageProduct class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ManageProductResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY:kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY,
                                                        kTKPDDETAILPRODUCT_APITOTALDATAKEY:kTKPDDETAILPRODUCT_APITOTALDATAKEY,
                                                        kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY:kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY,
                                                        kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY:kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY,
                                                        kTKPDDETAILPRODUCT_APIETALASENAMEKEY:kTKPDDETAILPRODUCT_APIETALASENAMEKEY,
                                                        kTKPDDETAILPRODUCT_APIMENUIDKEY:kTKPDDETAILPRODUCT_APIMENUIDKEY
                                                        }];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];

    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ManageProductList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIPRODUCTCOUNTREVIEWKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTCOUNTTALKKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTRATINGPOINTKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTETALASEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTSHOPIDKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                 kTKPDDETAILPRODUCT_APICOUNTSOLDKEY,
                                                 API_PRODUCT_PRICE_CURRENCY_ID_KEY,
                                                 kTKPDDETAILPRODUCT_APICURRENCYKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                 kTKPDDETAILPRODUCT_APINORMALPRICEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGE300KEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTDEPARTMENTKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTURKKEY,
                                                 API_PRODUCT_NAME_KEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSInteger shopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSInteger orderByID = [[_dataFilter objectForKey:kTKPDFILTER_APIORDERBYKEY]integerValue];
    NSInteger etalaseID = [[_dataFilter objectForKey:API_PRODUCT_ETALASE_ID_KEY]integerValue];
    NSString *keyword = [_dataFilter objectForKey:API_KEYWORD_KEY]?:@"";
    NSInteger userID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : ACTION_GET_PRODUCT_LIST,
                            kTKPDDETAIL_APISHOPIDKEY : @(shopID),
                            kTKPDDETAIL_APILIMITKEY : @(_limit),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APISORTKEY : @(orderByID),
                            kTKPDSHOP_APIETALASEIDKEY:@(etalaseID),
                            API_KEYWORD_KEY:keyword,
                            };
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        NSTimer *timer;
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            [_refreshControl endRefreshing];
            [_act stopAnimating];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [timer invalidate];
            [_refreshControl endRefreshing];
            [_act stopAnimating];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
    }
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _product = stats;
    BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && _product.result) {
    if ((_page<=1 && _product.result.list.count >0) || _isrefreshview) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
    }
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _product = stats;
            BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _product = stats;
            BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _product.result.list;
                if (_isrefreshview) {
                    [_list removeAllObjects];
                    _isrefreshview = NO;
                }
                
                [_list addObjectsFromArray:list];
                _isnodata = NO;
                
                [_table reloadData];
                
                _urinext =  _product.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_urinext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];

            }
        }
        else{
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark Request Action Delete
-(void)cancelActionDelete
{
    [_requestActionDelete cancel];
    _requestActionDelete = nil;
    [_objectmanagerActionDelete.operationQueue cancelAllOperations];
    _objectmanagerActionDelete = nil;
}

-(void)configureRestKitActionDelete
{
    _objectmanagerActionDelete = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIDELETEPRODUCTKEY,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [userinfo objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:@(0),
                            };
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDDETAILACTIONPRODUCT_APIPATH
                                                                                        parameters:[param encrypt]];
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
        [_act stopAnimating];
        _isrefreshview = NO;
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionDelete:error];
        _isrefreshview = NO;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionDelete];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                            target:self
                                          selector:@selector(requestTimeoutActionDelete)
                                          userInfo:nil repeats:NO]
    ;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionDelete:object];
    }
}

-(void)requestFailureActionDelete:(id)object
{
    [self requestProcessActionDelete:object];
}

-(void)requestProcessActionDelete:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    [self cancelDeleteRow];
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:@[@"Anda telah berhasil menghapus produk"];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            //[self cancelActionDelete];
            [self cancelDeleteRow];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionDelete
{
    [self cancelActionDelete];
}

#pragma mark Request Action MoveToWarehouse
-(void)cancelActionMoveToWarehouse
{
    [_requestActionMoveToWarehouse cancel];
    _requestActionMoveToWarehouse = nil;
    [_objectmanagerActionMoveToWarehouse.operationQueue cancelAllOperations];
    _objectmanagerActionMoveToWarehouse = nil;
}

-(void)configureRestKitActionMoveToWarehouse
{
    _objectmanagerActionMoveToWarehouse = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionMoveToWarehouse addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionMoveToWarehouse:(id)object
{
    if (_requestActionMoveToWarehouse.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:ACTION_MOVE_TO_WAREHOUSE,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [userinfo objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:0,
                            };
    _requestActionMoveToWarehouse = [_objectmanagerActionMoveToWarehouse appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILACTIONPRODUCT_APIPATH parameters:[param encrypt]]; //kTKPDPROFILE_PROFILESETTINGAPIPATH
    
    [_requestActionMoveToWarehouse setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionMoveToWarehouse:mappingResult withOperation:operation];
        [_act stopAnimating];
        _isrefreshview = NO;
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureActionMoveToWarehouse:error];
        _isrefreshview = NO;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionMoveToWarehouse];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionMoveToWarehouse) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionMoveToWarehouse:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionMoveToWarehouse:object];
    }
}

-(void)requestFailureActionMoveToWarehouse:(id)object
{
    [self requestProcessActionMoveToWarehouse:object];
}

-(void)requestProcessActionMoveToWarehouse:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    [self refreshView:nil];
                }
            }
        }
        else{
            [self cancelActionMoveToWarehouse];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionMoveToWarehouse
{
    [self cancelActionMoveToWarehouse];
}


#pragma mark - Methods

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    _requestcount = 0;
    _page = 1;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    _isrefreshview = YES;
    [self configureRestKit];
    [self request];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [_dataFilter setObject:searchBar.text forKey:API_KEYWORD_KEY];
    [self refreshView:nil];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


#pragma mark - Notification
- (void)didEditNote:(NSNotification*)notification
{
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_dataFilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Etalase Delegate
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    EtalaseList *etalase = [userInfo objectForKey:DATA_ETALASE_KEY];
    
    [_dataFilter setObject:etalase.etalase_id?:@"" forKey:API_PRODUCT_ETALASE_ID_KEY];
    [_dataFilter setObject:etalase.etalase_name forKey:API_PRODUCT_ETALASE_NAME_KEY];
    
    NSIndexPath *indexpath = [userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataFilter setObject:indexpath forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
    [self refreshView:nil];
}

#pragma mark - Notification
-(void)updateView:(NSNotification*)notification
{
    [self refreshView:nil];

}

#pragma mark - Swipe Delegate

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    [_searchbar resignFirstResponder];
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = ((ProductListMyShopCell*) cell).indexpath;
        ManageProductList *list = _list[indexPath.row];
        [_datainput setObject:@(list.product_id) forKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY];
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:BUTTON_DELETE_TITLE backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexPath];
            return YES;
        }];
        MGSwipeButton * etalase = [MGSwipeButton buttonWithTitle:BUTTON_EDIT_PRODUCT backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            ManageProductList *list = _list[indexPath.row];
            ProductAddEditViewController *editProductVC = [ProductAddEditViewController new];
            editProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: @(list.product_id),
                                   kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                   DATA_PRODUCT_DETAIL_KEY : list,
                                   DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_EDIT),
                                   DATA_IS_GOLD_MERCHANT :@(0) //TODO:: Change Value
                                    };
            [self.navigationController pushViewController:editProductVC animated:YES];
            return YES;
        }];
        MGSwipeButton * duplicate = [MGSwipeButton buttonWithTitle:BUTTON_DUPLICATE_PRODUCT backgroundColor:[UIColor colorWithRed:199.0/255 green:199.0/255.0 blue:199.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            ManageProductList *list = _list[indexPath.row];
            ProductAddEditViewController *editProductVC = [ProductAddEditViewController new];
            editProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: @(list.product_id),
                                   kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                   DATA_PRODUCT_DETAIL_KEY : list,
                                   DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_COPY),
                                   DATA_IS_GOLD_MERCHANT :@(0) //TODO:: Change Value
                                   };
            [self.navigationController pushViewController:editProductVC animated:YES];
            return YES;
        }];
        return @[trash, duplicate, etalase];
    }
    
    return nil;
    
}
@end
