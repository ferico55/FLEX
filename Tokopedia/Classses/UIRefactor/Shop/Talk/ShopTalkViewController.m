//
//  ShopTalkViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Talk.h"
#import "string_product.h"
#import "detail.h"
#import "GeneralTalkCell.h"
#import "ShopTalkViewController.h"
#import "stringrestkit.h"
#import "URLCacheController.h"
#import "GeneralAction.h"

#import "TKPDSecureStorage.h"
#import "ShopHeaderViewController.h"
#import "UIImage+ImageEffects.h"

#import "TKPDTabShopViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "ShopInfoViewController.h"
#import "ProductTalkDetailViewController.h"

#import "string_inbox_talk.h"

@interface ShopTalkViewController () <UITableViewDataSource, UITableViewDelegate, ShopHeaderDelegate>
{
    NSMutableArray *_list;
    NSArray *_headerImages;
    NSInteger _requestCount;
    NSInteger _pageHeaderImages;
    NSTimer *_timer;
    BOOL _isNoData;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_uriNext;
    BOOL _isRefreshView;
    UIRefreshControl *_refreshControl;
    NSIndexPath *_deletingIndexpath;
    
    Talk *_talk;
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;

    NSDictionary *_auth;
    
    Shop *_shop;
    BOOL _shopIsGold;
    
    UIImageView *_navigationImageView;
    
    BOOL _navigationBarIsAnimating;
    BOOL _navigationBarShouldAnimate;
    
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    NSOperationQueue *_operationUnfollowQueue;
    NSInteger _requestUnfollowCount;
    
    __weak RKObjectManager *_objectDeletemanager;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    NSOperationQueue *_operationDeleteQueue;
    NSInteger _requestDeleteCount;

    ShopHeaderViewController *_headerController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIView *stickyTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickyTabVerticalSpace;
@property (weak, nonatomic) IBOutlet UIView *tabView;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout;

@end

@implementation ShopTalkViewController

#pragma mark - View Life Cycle

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationUnfollowQueue = [NSOperationQueue new];
    _operationDeleteQueue = [NSOperationQueue new];
    
    _cacheConnection = [URLCacheConnection new];
    _cacheController = [URLCacheController new];
    _page = 1;

    _isNoData = YES;
    _isRefreshView = NO;

    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    if (_list.count>2) {
        _isNoData = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPTALK_APIRESPONSEFILEFORMAT,
                                                       [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
    _cacheController.filePath = _cachePath;
    _cacheController.URLCacheInterval = 86400.0;
	[_cacheController initCacheWithDocumentPath:path];

    _shopIsGold = [[_data objectForKey:kTKPDDETAIL_APISHOPISGOLD] boolValue];
    
    if (_shopIsGold) {
        _navigationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _navigationImageView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_navigationImageView];

        self.stickyTabVerticalSpace.constant = 64;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = YES;
    
    self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
    
    if (!_isRefreshView) {
        [self configureRestKit];
        if (_isNoData || (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0)) {
            [self loadData];
        }
    }

    if (_shopIsGold) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    } else {
        self.navigationController.navigationBar.translucent = NO;
    }

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 1;
    [self.navigationItem setBackBarButtonItem:barButtonItem];
    
    UIImage *infoImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kTKPDIMAGE_ICONINFO ofType:@"png"]];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithImage:infoImage
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    infoBarButton.tag = 2;
    self.navigationItem.rightBarButtonItem = infoBarButton;
    
    _navigationBarIsAnimating = false;
    _navigationBarShouldAnimate = false;
    
    [self updateTabAppearance:_contentOffset];
    [self updateNavigationBarAppearance:_contentOffset];
    
    _navigationBarShouldAnimate = true;

    if (_contentOffset.y > self.view.frame.size.height) _contentOffset.y = _header.frame.size.height - 109;
    else if (_tableView.contentInset.top == -64) _contentOffset.y = 64;
    
    self.tableView.contentOffset = _contentOffset;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height, 0);
    if (_shopIsGold) self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.tableView.delegate = self;
    
    self.hidesBottomBarWhenPushed = YES;
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self cancel];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:197.0/255.0 blue:34.0/255.0 alpha:1];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    self.tableView.delegate = nil;
//}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isNoData?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        
        NSString *cellid = kTKPDGENERALTALKCELL_IDENTIFIER;
        
        cell = (GeneralTalkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralTalkCell newcell];
            ((GeneralTalkCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            TalkList *list = _list[indexPath.row];
            
            //            ((GeneralTalkCell*)cell).deleteButton.hidden = NO;
            //            ((GeneralTalkCell*)cell).reportView.hidden = YES;
            ((GeneralTalkCell*)cell).indexpath = indexPath;
            ((GeneralTalkCell*)cell).data = list;
            [((GeneralTalkCell*)cell).userButton setTitle:list.talk_user_name forState:UIControlStateNormal];
            [((GeneralTalkCell*)cell).productButton setTitle:list.talk_product_name forState:UIControlStateNormal];
            ((GeneralTalkCell*)cell).timelabel.text = list.talk_create_time;
            [((GeneralTalkCell*)cell).commentbutton setTitle:[NSString stringWithFormat:@"%@ %@", list.talk_total_comment, COMMENT_TALK] forState:UIControlStateNormal];
            
            if([[_data objectForKey:@"nav"] isEqualToString:NAV_TALK_MYPRODUCT]) {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = YES;
            } else {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = NO;
            }
            
            if ([list.talk_message length] > 30) {
                NSRange stringRange = {0, MIN([list.talk_message length], 30)};
                stringRange = [list.talk_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralTalkCell*)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.talk_message substringWithRange:stringRange]];
            } else {
                ((GeneralTalkCell*)cell).commentlabel.text = list.talk_message;
            }
            
            if([list.talk_product_status isEqualToString:@"0"]) {
                ((GeneralTalkCell*)cell).commentbutton.enabled = NO;
            } else {
                ((GeneralTalkCell*)cell).commentbutton.enabled = YES;
            }
            
            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.talk_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *userImageView = ((GeneralTalkCell*)cell).thumb;
            userImageView.image = nil;
            [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [userImageView setImage:image];
                userImageView.layer.cornerRadius = userImageView.frame.size.width/2;
#pragma clang diagnostic pop
            } failure:nil];
            
            NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.talk_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *productImageView = ((GeneralTalkCell*)cell).productImageView;
            productImageView.image = nil;
            [productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [productImageView setImage:image];
                productImageView.layer.cornerRadius = productImageView.frame.size.width/2;
#pragma clang diagnostic pop
            } failure:nil];
            
        }
        
        return cell;
        
    } else {
        static NSString *cellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isNoData) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self loadData];
        } else {
            _tableView.tableFooterView = nil;
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 22, 0);
        }
	}
}

#pragma mark - View Action

-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 1:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 2:
            {
                if (_shop) {
                    ShopInfoViewController *vc = [[ShopInfoViewController alloc] init];
                    vc.data = @{kTKPDDETAIL_DATAINFOSHOPSKEY : _shop,
                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            default:
                break;
        }
    }

    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 1:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                TKPDTabShopViewController *shopProductViewController = [storyboard instantiateViewControllerWithIdentifier:@"TKPDTabShopViewController"];
                shopProductViewController.data = _data;
                shopProductViewController.contentOffset = self.tableView.contentOffset;
                shopProductViewController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopProductViewController]];
                break;
            }
            case 3:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopReviewViewController *shopReviewController = [storyboard instantiateViewControllerWithIdentifier:@"ShopReviewViewController"];
                shopReviewController.data = _data;
                shopReviewController.contentOffset = self.tableView.contentOffset;
                shopReviewController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopReviewController]];
                break;
            }
            case 4:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopNotesViewController *shopNotesController = [storyboard instantiateViewControllerWithIdentifier:@"ShopNotesViewController"];
                shopNotesController.data = _data;
                shopNotesController.contentOffset = self.tableView.contentOffset;
                shopNotesController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopNotesController]];
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
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];

    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];
    [listMapping addAttributeMappingsFromArray:@[TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_PRODUCT_NAME,
                                                 TKPD_TALK_PRODUCT_IMAGE,
                                                 TKPD_TALK_PRODUCT_ID,
                                                 TKPD_TALK_OWN,
                                                 TKPD_TALK_USER_ID,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_IMG,
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];

    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDDETAILSHOP_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPTALKKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            @"page" : @(_page),
                            @"per_page" : @(5)
                            };
    
    [_cacheController getFileModificationDate];
	_timeInterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
	if (_timeInterval > _cacheController.URLCacheInterval || _page > 1 || _isRefreshView) {

        if (!_isRefreshView) {
            self.tableView.tableFooterView = _footer;
            [_activityIndicator startAnimating];
        }
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOP_APIPATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_activityIndicator stopAnimating];
            self.tableView.hidden = NO;
            _isRefreshView = NO;
            [_refreshControl endRefreshing];
            [self requestSuccess:mappingResult withOperation:operation];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [_timer invalidate];
            _timer = nil;
            [_activityIndicator stopAnimating];
            self.tableView.hidden = NO;
            _isRefreshView = NO;
            [_refreshControl endRefreshing];
            [self requestFailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                  target:self
                                                selector:@selector(requestTimeout)
                                                userInfo:nil
                                                 repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cacheController.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestFailure:nil];
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talk = stats;
    BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1) {
            [_cacheConnection connection:operation.HTTPRequestOperation.request
                      didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cacheController connectionDidFinish:_cacheConnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachePath
                                                          atomically:YES];
        }
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval || _page > 1 || _isRefreshView) {
        [self requestProcess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _talk = stats;
            BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                [self requestProcess:mappingresult];
            }
        }
    }
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _talk = stats;
            
            BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                
                NSArray *list = _talk.result.list;
                
                [_list addObjectsFromArray:list];
                
                _uriNext =  _talk.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_uriNext];
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
                NSLog(@"next page shop talk : %zd",_page);
                
                _isNoData = NO;
                
                [self.tableView reloadData];
                if (_list.count == 0) _activityIndicator.hidden = YES;

            }
        }else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
                    //_table.tableFooterView = _footer;
                    //[_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_activityIndicator stopAnimating];
                    self.tableView.tableFooterView = nil;
                }
            }
            else
            {
                [_activityIndicator stopAnimating];
                self.tableView.tableFooterView = nil;
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateTabAppearance:scrollView.contentOffset];
    [self updateNavigationBarAppearance:scrollView.contentOffset];
    [_headerController didScroll:scrollView];
}

#pragma mark - Methods

- (void)updateTabAppearance:(CGPoint)contentOffset
{
    CGFloat limit;
    if (_shopIsGold) {
        limit = self.header.frame.size.height - 109;
    } else {
        limit = (self.header.frame.size.height - 44);
    }
    
    if (contentOffset.y >= limit) {
        _stickyTabView.hidden = NO;
    } else {
        _stickyTabView.hidden = YES;
    }
}

- (void)updateNavigationBarAppearance:(CGPoint)contentOffset;
{
    if (!_navigationBarIsAnimating && _shopIsGold) {
        _navigationBarIsAnimating = true;
        if (contentOffset.y > 136) {
            [self showNavigationBar];
        } else {
            [self hideNavigationBar];
        }
    }
}

- (void)showNavigationBar
{
    if (_navigationBarShouldAnimate) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            _navigationImageView.alpha = 1;
            self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
        } completion:^(BOOL finished) {
            _navigationBarIsAnimating = false;
        }];
    } else {
        _navigationImageView.alpha = 1;
        self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
        _navigationBarIsAnimating = false;
    }
}

- (void)hideNavigationBar
{
    if ( _navigationBarShouldAnimate) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            _navigationImageView.alpha = 0;
            self.title = @"";
        } completion:^(BOOL finished) {
            _navigationBarIsAnimating = false;
        }];
    } else {
        _navigationImageView.alpha = 0;
        self.title = @"";
        _navigationBarIsAnimating = false;
    }
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isRefreshView = YES;
    
    [self.tableView reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedHeader"]) {
        _headerController = segue.destinationViewController;
        _headerController.data = _data;
        _headerController.delegate = self;
        _headerController.shop = _shop;
    }
}

#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}


#pragma mark - General Talk Delegate
- (void)GeneralTalkCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ProductTalkDetailViewController *vc = [ProductTalkDetailViewController new];
    NSInteger row = indexpath.row;
    TalkList *list = _list[row];
    vc.data = @{
                TKPD_TALK_MESSAGE:list.talk_message?:0,
                TKPD_TALK_USER_IMG:list.talk_user_image?:0,
                TKPD_TALK_CREATE_TIME:list.talk_create_time?:0,
                TKPD_TALK_USER_NAME:list.talk_user_name?:0,
                TKPD_TALK_ID:list.talk_id?:0,
                TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:0,
                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                TKPD_TALK_SHOP_ID:list.talk_shop_id?:0,
                TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image,
                kTKPDDETAIL_DATAINDEXKEY : @(row)?:0
                };
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Unfollow Talk
- (void)unfollowTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withButton:(UIButton *)buttonUnfollow {
    [self configureUnfollowRestkit];
    [self followAnimateZoomOut:buttonUnfollow];
    
    TalkList *list = _list[indexpath.row];
    if (_requestUnfollow.isExecuting) return;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_ACTIONKEY : TKPD_FOLLOW_TALK_ACTION,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                            TKPD_TALK_ID:list.talk_id?:0,
                            };
    
    _requestUnfollowCount ++;
    _requestUnfollow = [_objectUnfollowmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/talk.pl" parameters:[param encrypt]];
    
    [_requestUnfollow setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
    
    [_operationUnfollowQueue addOperation:_requestUnfollow];
    
}

- (void)followAnimateZoomOut:(UIButton*)buttonUnfollow {
    double delayInSeconds = 2.0;
    if([[buttonUnfollow currentTitle] isEqualToString:TKPD_TALK_FOLLOW]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1.3,1.3);
        [buttonUnfollow setTitle:TKPD_TALK_UNFOLLOW forState:UIControlStateNormal];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1,1);
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1.3,1.3);
        [buttonUnfollow setTitle:TKPD_TALK_FOLLOW forState:UIControlStateNormal];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1,1);
        [UIView commitAnimations];
    }
    
    buttonUnfollow.enabled = NO;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        buttonUnfollow.enabled = YES;
    });
}

-(void) configureUnfollowRestkit {
    _objectUnfollowmanager =  [RKObjectManager sharedClient];
    
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/talk.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectUnfollowmanager addResponseDescriptor:responseDescriptorStatus];
}

#pragma mark - Delete Talk 
- (void)deleteTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    _deletingIndexpath = indexpath;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:PROMPT_DELETE_TALK
                          message:PROMPT_DELETE_TALK_MESSAGE
                          delegate:self
                          cancelButtonTitle:BUTTON_CANCEL
                          otherButtonTitles:nil];
    
    [alert addButtonWithTitle:BUTTON_OK];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //delete talk
    if(buttonIndex == 1) {
        TalkList *list = _list[_deletingIndexpath.row];
        [_list removeObjectAtIndex:_deletingIndexpath.row];
        [_tableView reloadData];
        [self configureDeleteRestkit];
        
        if (_requestDelete.isExecuting) return;
        
        NSDictionary* param = @{
                                kTKPDDETAIL_ACTIONKEY : TKPD_DELETE_TALK_ACTION,
                                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                                TKPD_TALK_ID:list.talk_id?:0,
                                kTKPDDETAILSHOP_APISHOPID : list.talk_shop_id
                                };
        
        _requestDeleteCount ++;
        _requestDelete = [_objectDeletemanager appropriateObjectRequestOperationWithObject:self
                                                                                    method:RKRequestMethodPOST
                                                                                      path:@"action/talk.pl"
                                                                                parameters:[param encrypt]];
        
        [_requestDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
        
        [_operationDeleteQueue addOperation:_requestDelete];
        
    }
}

- (void)configureDeleteRestkit {
    _objectDeletemanager =  [RKObjectManager sharedClient];
    
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/talk.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectDeletemanager addResponseDescriptor:responseDescriptorStatus];
}

- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    return self;
}



@end
