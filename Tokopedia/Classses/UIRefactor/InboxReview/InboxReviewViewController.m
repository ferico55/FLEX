//
//  InboxReviewViewController.m
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "InboxReviewViewController.h"
#import "InboxReview.h"
#import "GeneralReviewCell.h"
#import "GeneralAction.h"
#import "ReviewFormViewController.h"

#import "stringrestkit.h"
#import "string_inbox_review.h"
#import "detail.h"
#import "TKPDSecureStorage.h"
#import "DetailReviewViewController.h"

#import "URLCacheController.h"
#import "URLCacheConnection.h"
#import "UserAuthentificationManager.h"
#import "ReportViewController.h"
#import "NoResultView.h"

@interface InboxReviewViewController () <UITableViewDataSource, UITableViewDelegate, GeneralReviewCellDelegate, ReportViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *reviewFooter;
@property (weak, nonatomic) IBOutlet UITableView *reviewTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *reviewLoadingAct;
@property (nonatomic, strong) NSDictionary *userinfo;

@property (nonatomic, strong) NSMutableArray *reviews;

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail;
- (void)requestTimeout;

- (void)configureSkipReviewRestkit;
- (void)requestSkipReviewSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestSkipReviewFail;
- (void)requestSkipReviewTimeout;

@end

@implementation InboxReviewViewController {
    BOOL _isNoData;
    BOOL _isRefreshing;
    
    NSInteger _requestCount;
    NSInteger _reviewPage;
    NSString *_uriNextPage;
    
    NSTimer *_requestTimer;
    NSMutableArray *_reviewList;
    NSOperationQueue *_operationQueue;
    UIRefreshControl *_refreshControl;
    NSDictionary *_auth;
    NSString *_readStatus;
    NSString *_talkNavigationFlag;
    
    BOOL _isLoadFromCache;
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectSkipReviewManager;
    __weak RKManagedObjectRequestOperation *_requestSkipReview;
    NSOperationQueue *_operationSkipReviewQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    UserAuthentificationManager *_userManager;
    ReportViewController *_reportController;
    NSString *_reportedReviewId;
    NoResultView *_noResult;
}

#pragma mark - Initialization
- (void)initCache {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:TKPD_INBOXREVIEW_CACHE];
    
    if(_userinfo[@"show_read"] == nil) {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-all",[_data objectForKey:@"nav"]]];
    } else {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",[_data objectForKey:@"nav"], _readStatus]];
    }
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAfterEditingReview:)
                                                 name:@"updateAfterEditingReview" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAfterWriteReview:)
                                                 name:@"updateAfterWriteReview" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTalkWithFilter:)
                                                 name:[NSString stringWithFormat:@"%@%@", @"showRead", _talkNavigationFlag]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalComment:)
                                                 name:@"updateTotalComment"
                                               object:nil];
}

- (void)initNavigationBar {
    UIBarButtonItem *barbuttonleft;
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _isRefreshing = NO;
        _isNoData = YES;
    }
    
    return self;
}

- (void)initRefreshControl {
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshTable:)forControlEvents:UIControlEventValueChanged];
    [_reviewTable addSubview:_refreshControl];
}


#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _operationSkipReviewQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _userManager = [UserAuthentificationManager new];
    _reportController = [ReportViewController new];
    _reportController.delegate = self;
    
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    
    _reviews = [NSMutableArray new];
    _reviewPage = 1;
    
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    
    _reviewTable.delegate = self;
    _reviewTable.dataSource = self;
    _reviewTable.tableFooterView = _reviewFooter;
    
    if (_reviews.count > 0) {
        _isNoData = NO;
    }
    
    [self initNavigationBar];
    [self initRefreshControl];
    [self initNotificationCenter];
    [self initCache];
    [self configureRestkit];
    
    if(_reviewPage == 1) {
        _isLoadFromCache = YES;
        [self loadDataFromCache];
    }
    
    _isLoadFromCache = NO;
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_isRefreshing) {
        [self configureRestkit];
        
        if (_isNoData && _reviewPage < 1) {
            [self loadData];
        }
    }
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - DataSource Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        
        NSString *cellid = kTKPDGENERALREVIEWCELLIDENTIFIER;
        
        cell = (GeneralReviewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralReviewCell newcell];
            ((GeneralReviewCell*)cell).delegate = self;
        }
        
        if (_reviews.count > indexPath.row) {
            
            InboxReviewList *list = _reviews[indexPath.row];
            ((GeneralReviewCell*)cell).indexpath = indexPath;
            ((GeneralReviewCell*)cell).userNamelabel.text = list.review_user_name;
            ((GeneralReviewCell*)cell).timelabel.text = [list.review_create_time isEqualToString:@"0"] ? @"" : list.review_create_time;
            ((GeneralReviewCell*)cell).data = list;
            
//            ((GeneralReviewCell*)cell).contentReview.layer.borderColor = [UIColor lightGrayColor].CGColor;
//            ((GeneralReviewCell*)cell).contentReview.layer.borderWidth = 1.0f;
            
            if([list.review_response.response_message isEqualToString:@"0"]) {
                [((GeneralReviewCell*)cell).commentbutton setTitle:@"0 Comment" forState:UIControlStateNormal];
            } else {
                [((GeneralReviewCell*)cell).commentbutton setTitle:@"1 Comment" forState:UIControlStateNormal];
            }
            
            //edit button visibility
            if([list.review_is_allow_edit isEqualToString:@"1"] && ![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
                ((GeneralReviewCell*)cell).editReviewButton.hidden = NO;
            } else {
                ((GeneralReviewCell*)cell).editReviewButton.hidden = YES;
            }
            
            
            
            if ([list.review_is_skipable isEqualToString:@"1"]) {
                ((GeneralReviewCell*)cell).skipReviewButton.hidden = NO;
            } else {
                ((GeneralReviewCell*)cell).skipReviewButton.hidden = YES;
            }
            
            //report button visibility
            TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
            _auth = [secureStorage keychainDictionary];
            _auth = [_auth mutableCopy];
            NSString *userId = [[_auth objectForKey:@"user_id"] stringValue];
            if(userId && ![list.review_user_id isEqualToString:userId]) {
                ((GeneralReviewCell*)cell).reportReviewButton.hidden = NO;
            } else {
                ((GeneralReviewCell*)cell).reportReviewButton.hidden = YES;
            }
            
            ((GeneralReviewCell*)cell).productNamelabel.text = list.review_product_name;
    
            if ([list.review_message length] > 50) {
                NSRange stringRange = {0, MIN([list.review_message length], 50)};
                stringRange = [list.review_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralReviewCell *)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.review_message substringWithRange:stringRange]];
            } else {
                if([list.review_message isEqualToString:@"0"]) {
                    ((GeneralReviewCell *)cell).commentlabel.text = @"Belum ada review" ;
                    [((GeneralReviewCell *)cell).commentlabel setTextColor:[UIColor lightGrayColor]];
                } else {
                    ((GeneralReviewCell *)cell).commentlabel.text = list.review_message ;
                }

                
            }
            
            if([list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] || [list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
                if([list.review_message isEqualToString:@"0"]) {
                    ((GeneralReviewCell *)cell).commentlabel.text = @"Produk ini tidak dapat diulas" ;
                    ((GeneralReviewCell*)cell).delegate = nil;
                }
            } else {
                ((GeneralReviewCell*)cell).delegate = self;
            }
            
            if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
                ((GeneralReviewCell *)cell).inputReviewView.hidden = NO;
                ((GeneralReviewCell *)cell).commentView.hidden = YES;
                
            } else {
                ((GeneralReviewCell *)cell).inputReviewView.hidden = YES;
                ((GeneralReviewCell *)cell).commentView.hidden = NO;
                
                CGRect newFrame = ((GeneralReviewCell *)cell).frame;
                
            }
            
            
            
            ((GeneralReviewCell*)cell).qualityrate.starscount = [list.review_rate_quality integerValue];
            ((GeneralReviewCell*)cell).speedrate.starscount = [list.review_rate_speed integerValue];
            ((GeneralReviewCell*)cell).servicerate.starscount = [list.review_rate_service integerValue];
            ((GeneralReviewCell*)cell).accuracyrate.starscount = [list.review_rate_accuracy integerValue];
            
            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *userImageView = ((GeneralReviewCell *)cell).userImageView;
            userImageView.image = nil;
            [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [userImageView setImage:image];
                userImageView.layer.cornerRadius = userImageView.frame.size.width/2;
#pragma clang diagnostic pop
            } failure:nil];
            
            NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *productImageView = ((GeneralReviewCell*)cell).productImageView;
            productImageView.image = nil;
            [productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [productImageView setImage:image];
#pragma clang diagnostic pop
            } failure:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxReviewList *list = _reviews[indexPath.row];
    
    int cellHeight = 0;
    if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
        cellHeight =  250;
    } else {
        cellHeight =  325;
    }
   
    return 325;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isNoData ? 0 : _reviews.count;
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNextPage != NULL && ![_uriNextPage isEqualToString:@"0"] && _uriNextPage != 0) {
            [self configureRestkit];
            [self loadData];
        } else {
            _reviewTable.tableFooterView = nil;
            [_reviewLoadingAct stopAnimating];
        }
    }
}

#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxReview class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxReviewList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 REVIEW_PRODUCT_IMG,
                                                 REVIEW_USER_NAME,
                                                 REVIEW_RATE_ACCURACY,
                                                 REVIEW_MESSAGE,
                                                 REVIEW_PRODUCT_ID,
                                                 REVIEW_SHOP_ID,
                                                 REVIEW_PRODUCT_NAME,
                                                 REVIEW_CREATE_TIME,
                                                 REVIEW_ID,
                                                 REVIEW_RATE_QUALITY,
                                                 REVIEW_RATE_SPEED,
                                                 REVIEW_RATE_SERVICE,
                                                 REVIEW_IS_OWNER,
                                                 REVIEW_READ_STATUS,
                                                 REVIEW_USER_ID,
                                                 REVIEW_USER_IMAGE,
                                                 REVIEW_PRODUCT_STATUS,
                                                 REVIEW_IS_ALLOW_EDIT,
                                                 REVIEW_IS_SKIPABLE
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{NEXT_PAGE_URI_API:NEXT_PAGE_URI_API}];
    
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[InboxReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromDictionary:@{
                                                                REVIEW_RESPONSE_CREATE_TIME:REVIEW_RESPONSE_CREATE_TIME,
                                                                REVIEW_RESPONSE_MESSAGE:REVIEW_RESPONSE_MESSAGE
                                                                }];
    
    RKObjectMapping *reviewProductOwnerMapping = [RKObjectMapping mappingForClass:[InboxReviewProductOwner class]];
    [reviewProductOwnerMapping addAttributeMappingsFromDictionary:@{
                                                                    REVIEW_PRODUCT_OWNER_USER_ID:REVIEW_PRODUCT_OWNER_USER_ID,
                                                                    REVIEW_PRODUCT_OWNER_USER_IMAGE:REVIEW_PRODUCT_OWNER_USER_IMAGE,
                                                                    REVIEW_PRODUCT_OWNER_USER_NAME:REVIEW_PRODUCT_OWNER_USER_NAME
                                                                    }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxReviewResult class]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:RESULT_API
                                                                                  toKeyPath:RESULT_API
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:LIST_API
                                                                                  toKeyPath:LIST_API
                                                                                withMapping:listMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_RESPONSE
                                                                                toKeyPath:REVIEW_RESPONSE
                                                                              withMapping:reviewResponseMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_PRODUCT_OWNER
                                                                                toKeyPath:REVIEW_PRODUCT_OWNER
                                                                              withMapping:reviewProductOwnerMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:PAGING_API
                                                                                  toKeyPath:PAGING_API
                                                                                withMapping:pagingMapping]];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:INBOX_REVIEW_API_PATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
}

- (void)loadData {
    if (_request.isExecuting) return;
    [self beginToRequest];
    
    //TODO::change this param later
    NSDictionary* param = @{
                            ACTION_API_KEY:GET_INBOX_REVIEW,
                            NAV_API_KEY : [_data objectForKey:@"nav"],
                            LIMIT_API_KEY:INBOX_REVIEW_LIMIT_VALUE,
                            PAGE_API_KEY:@(_reviewPage),
                            FILTER_API_KEY:_readStatus?_readStatus:@"",
                            KEYWORD_API_KEY:@""
                            };
    
    _requestCount++;
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:INBOX_REVIEW_API_PATH
                                                                parameters:[param encrypt]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableButtonRead" object:nil userInfo:nil];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableButtonRead" object:nil userInfo:nil];
        _isNeedToInsertCache = YES;
        [self requestSuccess:mappingResult withOperation:operation];
        _isRefreshing = NO;
        [self stopRequestTimer];
        [self finishRequest];
        [_reviewTable reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        
        [self stopRequestTimer];
    }];
    
    [_operationQueue addOperation:_request];
    [self initRequestTimer];
}

- (void)loadDataFromCache {
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    
    NSError* error;
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    
    if(data.length) {
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            _isRefreshing = YES;
            _isNeedToInsertCache = NO;
            [self requestSuccess:mappingresult withOperation:nil];
        }
    }
}


- (void)stopRequestTimer {
    [_requestTimer invalidate];
    _requestTimer = nil;
}

- (void)initRequestTimer {
    _requestTimer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_TIMER_MAX target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];
}

- (void)beginToRequest {
    _reviewTable.tableFooterView = _reviewFooter;
    [_reviewLoadingAct startAnimating];
}

- (void)finishRequest {
//    _reviewTable.tableFooterView = nil;
    [_reviewLoadingAct stopAnimating];
    [_refreshControl endRefreshing];
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    InboxReview *reviewObject = [result objectForKey:@""];
    BOOL status = [reviewObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        if(_isRefreshing) {
            [_reviews removeAllObjects];
        }
        
        [_reviews addObjectsFromArray:reviewObject.result.list];
        
        if(_reviewPage == PAGE_TO_CACHE && _isNeedToInsertCache) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request
                      didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        
        if(_reviews.count > 0) {
            _isNoData = NO;
            _uriNextPage =  reviewObject.result.paging.uri_next;
            NSURL *url = [NSURL URLWithString:_uriNextPage];
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
            
            if(!_isLoadFromCache) {
                _reviewPage = [[queries objectForKey:@"page"] integerValue];
            }


        } else {
            _isNoData = YES;
            _reviewTable.tableFooterView = _noResult;
        }
    }
}

- (void)requestFail {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}

#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
                
            default:
                break;
        }
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10: {
                
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Refresh View
- (void)refreshTable:(UIRefreshControl*)refresh {
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    //    [_talks removeAllObjects];
    _reviewPage = 1;
    _isRefreshing = YES;
    
    [_reviewTable reloadData];
    /** request data **/
    [self configureRestkit];
    [self loadData];
}

#pragma mark - Memory Manage
- (void)dealloc {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Review Cell Delegate
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}

-(void)GeneralReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    DetailReviewViewController *vc = [DetailReviewViewController new];
    NSInteger row = indexpath.row;
    
    InboxReviewList *list = _reviews[row];
    
    vc.data = list;
    vc.is_owner = list.review_is_owner;
    vc.index = [NSString stringWithFormat:@"%ld",(long)row];
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

    
}

- (void)skipReview:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    [self configureSkipReviewRestkit];
    InboxReviewList *list = _reviews[indexpath.row];
    [_reviews removeObjectAtIndex:indexpath.row];
    [_reviewTable reloadData];
    
    [self doSkipReview:list.review_product_id];
}

- (void)reportReview:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    InboxReviewList *review = _reviews[[indexpath row]];
    _reportedReviewId = review.review_id;
    _reportController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_reportController animated:YES];
}

#pragma mark - Report Delegate
- (NSString *)getPath {
    return @"action/review.pl";
}

- (NSDictionary *)getParameter {
    return @{@"action" : @"report_comment_review", @"review_id" : _reportedReviewId};
}

#pragma mark - Action Skip Review
- (void)configureSkipReviewRestkit {
    _objectSkipReviewManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:ADD_REVIEW_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectSkipReviewManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doSkipReview:(id)productID {
    if (_requestSkipReview.isExecuting) return;
    
    //TODO::change this param later
    NSDictionary* param = @{
                            ACTION_API_KEY:SKIP_REVIEW,
                            @"product_id" : productID
                            };
    
    _requestSkipReview = [_objectSkipReviewManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:ADD_REVIEW_PATH
                                                                parameters:[param encrypt]];
    
    [_requestSkipReview setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSkipReviewSuccess:mappingResult withOperation:operation];
        [self stopRequestTimer];
        [self finishRequest];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        
        [self stopRequestTimer];
    }];
    
    [_operationSkipReviewQueue addOperation:_requestSkipReview];
    [self initRequestTimer];
}

- (void)requestSkipReviewSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    
}

- (void)requestSkipReviewFail {
    
}

- (void)requestSkipReviewTimeout {
    
}

#pragma mark - Notification Center
- (void)updateAfterEditingReview:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];

    InboxReviewList *list = _reviews[index];
    NSDictionary *editedParam = [userinfo objectForKey:@"data"];
    
    list.review_message = [editedParam objectForKey:@"review_message"];
    list.review_rate_quality = [editedParam objectForKey:@"rate_product"];
    list.review_rate_accuracy = [editedParam objectForKey:@"rate_accuracy"];
    list.review_rate_service = [editedParam objectForKey:@"rate_service"];
    list.review_rate_speed = [editedParam objectForKey:@"rate_speed"];
    list.review_is_allow_edit = 0;
    
    [_reviewTable reloadData];
}

- (void)updateAfterWriteReview:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    
    InboxReviewList *list = _reviews[index];
    NSDictionary *editedParam = [userinfo objectForKey:@"data"];
    
    list.review_message = [editedParam objectForKey:@"review_message"];
    list.review_rate_quality = [editedParam objectForKey:@"rate_product"];
    list.review_rate_accuracy = [editedParam objectForKey:@"rate_accuracy"];
    list.review_rate_service = [editedParam objectForKey:@"rate_service"];
    list.review_rate_speed = [editedParam objectForKey:@"rate_speed"];
    list.review_create_time = @"Just Now";
    list.review_id = @"1";
//    list.review_user_id = [_userManager getUserId];
    
    [_reviewTable reloadData];
}

-(void) showTalkWithFilter:(NSNotification*)notification {
    if (_request.isExecuting) return;
    _userinfo = notification.userInfo;
    
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
        _readStatus = @"all";
    } else {
        _readStatus = @"unread";
    }
    
    [self cancel];
    _reviewPage = 1;
    
    
    /**init view*/
    [self configureRestkit];
    [self initCache];
    
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    if(_reviewPage == 1 && data.length) {
        _isLoadFromCache = YES;
        [self loadDataFromCache];
        [_reviewTable reloadData];
    } else {
        [_reviews removeAllObjects];
        [_reviewTable reloadData];
        _reviewTable.tableFooterView = _reviewFooter;
    }
    
    _isLoadFromCache = NO;
    [self loadData];
}

- (void)updateTotalComment:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"index"]integerValue];
    
    InboxReviewList *list = _reviews[index];
    
    list.review_response.response_message = [userinfo objectForKey:@"review_comment"];
    list.review_response.response_create_time = [userinfo objectForKey:@"review_comment_time"];
    [_reviewTable reloadData];

}

- (void)cancel {
    
}

@end
