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
#import "ReviewFormViewController.h"

#import "stringrestkit.h"
#import "string_inbox_review.h"
#import "detail.h"
#import "TKPDSecureStorage.h"

@interface InboxReviewViewController () <UITableViewDataSource, UITableViewDelegate, GeneralReviewCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *reviewFooter;
@property (weak, nonatomic) IBOutlet UITableView *reviewTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *reviewLoadingAct;

@property (nonatomic, strong) NSMutableArray *reviews;

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail;
- (void)requestTimeout;

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
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
}

#pragma mark - Initialization
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
    
    [self initNavigationBar];
    _operationQueue = [NSOperationQueue new];
    _reviews = [NSMutableArray new];
    _reviewPage = 1;
    
    _reviewTable.delegate = self;
    _reviewTable.dataSource = self;
    _reviewTable.tableFooterView = _reviewFooter;
    
    if (_reviews.count > 0) {
        _isNoData = NO;
    }
    
    [self initRefreshControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureRestkit];
    [self loadData];
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
            
            ((GeneralReviewCell *)cell).productNamelabel.text = list.review_product_name;
            if ([list.review_message length] > 30) {
                NSRange stringRange = {0, MIN([list.review_message length], 30)};
                stringRange = [list.review_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralReviewCell *)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.review_message substringWithRange:stringRange]];
            } else {
                ((GeneralReviewCell *)cell).commentlabel.text = [list.review_message isEqualToString:@"0"] ? @"" : list.review_message;
            }
            
            if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
                ((GeneralReviewCell *)cell).ratingView.hidden = YES;
                ((GeneralReviewCell *)cell).inputReviewView.hidden = NO;
            } else {
                ((GeneralReviewCell *)cell).ratingView.hidden = NO;
                ((GeneralReviewCell *)cell).inputReviewView.hidden = YES;
            }
            
            ((GeneralReviewCell*)cell).qualityrate.starscount = [list.review_rate_quality integerValue];
            ((GeneralReviewCell*)cell).speedrate.starscount = [list.review_rate_speed integerValue];
            ((GeneralReviewCell*)cell).servicerate.starscount = [list.review_rate_service integerValue];
            ((GeneralReviewCell*)cell).accuracyrate.starscount = [list.review_rate_accuracy integerValue];
            
            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *userImageView = ((GeneralReviewCell *)cell).userImageView;
            userImageView.image = nil;
            [userImageView setImageWithURLRequest:userImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [userImageView setImage:image];
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
    UITableViewCell* cell = nil;

        
    NSString *cellid = kTKPDGENERALREVIEWCELLIDENTIFIER;
    
    cell = (GeneralReviewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralReviewCell newcell];
    }
        
    if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
        return 250;
    } else {
        return 325;
    }
   
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
                                                 REVIEW_PRODUCT_STATUS,
                                                 REVIEW_IS_ALLOW_EDIT
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
                            NAV_API_KEY : @"inbox-review",
                            LIMIT_API_KEY:INBOX_REVIEW_LIMIT_VALUE,
                            PAGE_API_KEY:@(_reviewPage),
                            FILTER_API_KEY:@"all",
                            KEYWORD_API_KEY:@""
                            };
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:INBOX_REVIEW_API_PATH
                                                                parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [self stopRequestTimer];
        [self finishRequest];
        [_reviewTable reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        
        [self stopRequestTimer];
    }];
    
    [_operationQueue addOperation:_request];
    [self initRequestTimer];
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
    _reviewTable.tableFooterView = nil;
    [_reviewLoadingAct stopAnimating];
    [_refreshControl endRefreshing];
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    InboxReview *reviewObject = [result objectForKey:@""];
    BOOL status = [reviewObject.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [_reviews addObjectsFromArray:reviewObject.result.list];
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
            
            _reviewPage = [[queries objectForKey:@"page"] integerValue];

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
    ReviewFormViewController *vc = [ReviewFormViewController new];
    NSInteger row = indexpath.row;
    vc.data = _reviews[row];
    vc.isViewForm = YES;
    [self.navigationController pushViewController:vc animated:YES];


}



@end
