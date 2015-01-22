//
//  ShopNotesViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "alert.h"

#import "Notes.h"
#import "StarsRateView.h"
#import "ProgressBarView.h"
#import "ShopNotesCell.h"

#import "TKPDAlertView.h"
#import "AlertListView.h"
#import "ShopNotesViewController.h"
#import "ShopNotesDetailViewController.h"
#import "SettingNoteDetailViewController.h"

#import "URLCacheController.h"
#import "SettingNoteDetailViewController.h"
#import "ShopHeaderViewController.h"

#import "UIImage+ImageEffects.h"

#import "TKPDTabShopViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopInfoViewController.h"

#pragma mark - Shop Notes View Controller

@interface ShopNotesViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate, ShopNotesCellDelegate, ShopHeaderDelegate>
{
    NSMutableDictionary *_param;
    NSMutableArray *_list;
    NSInteger _requestCount;
    NSTimer *_timer;
    BOOL _isNoData;
    
    BOOL _isRefreshView;
    UIRefreshControl *_refreshControl;
    
    Notes *_notes;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    
    UIImageView *_navigationImageView;

    BOOL _shopIsGold;
    BOOL _navigationBarIsAnimating;
    BOOL _navigationBarShouldAnimate;

    ShopHeaderViewController *_headerController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIView *tabView;
@property (strong, nonatomic) IBOutlet UIView *stickyTabView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickyTabVerticalSpace;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout;

@end

@implementation ShopNotesViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isNoData = YES;
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cacheController = [URLCacheController new];
    _cacheConnection = [URLCacheConnection new];
    
    if (_list.count>2) {
        _isNoData = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT, [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
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
    
    _navigationBarIsAnimating = false;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
    
    if (!_isRefreshView) {
        [self configureRestKit];
        if (_isNoData) {
            [self request];
        }
    }
    
    if (_shopIsGold) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        
        if (_contentOffset.y > 136) {
            _navigationImageView.alpha = 1;
            self.title = [_data objectForKey:kTKPDDETAIL_APISHOPNAMEKEY];
        } else {
            _navigationImageView.alpha = 0;
            self.title = @"";
        }
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
    
    if (_contentOffset.y > self.view.frame.size.height) _contentOffset.y = _headerView.frame.size.height - 109;
    else if (_tableView.contentInset.top == -64) _contentOffset.y = 64;

    self.tableView.contentOffset = _contentOffset;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height, 0);
    if (_shopIsGold) self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);

    self.tableView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:197.0/255.0 blue:34.0/255.0 alpha:1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tableView.delegate = nil;
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isNoData?1:_list.count;
#else
    return _isNoData?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        
        NSString *cellid = kTKPDSHOPNOTESCELL_IDENTIFIER;
		
		cell = (ShopNotesCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ShopNotesCell newcell];
			((ShopNotesCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            NotesList *list = _list[indexPath.row];
            ((ShopNotesCell*)cell).label.text = list.note_title;
            ((ShopNotesCell*)cell).indexpath = indexPath;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isNoData) {
		cell.backgroundColor = [UIColor whiteColor];
	}

    if (indexPath.row == (_list.count-1)) {
        CGFloat insetBottom = self.view.frame.size.height - (tableView.sectionHeaderHeight +
                                                             (tableView.rowHeight * _list.count) +
                                                             _tabView.frame.size.height + 64);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, insetBottom, 0);
        _tableView.tableFooterView = nil;
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateTabAppearance:scrollView.contentOffset];
    [self updateNavigationBarAppearance:scrollView.contentOffset];
    [_headerController didScroll:scrollView];
}

#pragma mark - Memory Management

- (void)dealloc
{
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Notes class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NotesResult class]];

    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[NotesList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDNOTES_APINOTEIDKEY,
                                                 kTKPDNOTES_APINOTESTATUSKEY,
                                                 kTKPDNOTES_APINOTETITLEKEY
                                                       ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDDETAILSHOP_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
//    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPNOTESKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0)};
    
    [_cacheController getFileModificationDate];
    
	_timeInterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
	
    if (_timeInterval > _cacheController.URLCacheInterval) {

        _tableView.tableFooterView = _footerView;
        
        [_activityIndicator startAnimating];
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOP_APIPATH
                                                                    parameters:[param encrypt]];

        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

            [_timer invalidate];
            _timer = nil;
            
            [_activityIndicator stopAnimating];
            
            _isRefreshView = NO;
            
            [_refreshControl endRefreshing];
            
            [self requestSuccess:mappingResult withOperation:operation];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [_timer invalidate];
            _timer = nil;
            [_activityIndicator stopAnimating];
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
    _notes = stats;
    BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_cacheConnection connection:operation.HTTPRequestOperation.request
                  didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cacheController connectionDidFinish:_cacheConnection];
        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];

        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval) {
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
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _notes = stats;
            BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
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
            
            _notes = stats;
            BOOL status = [_notes.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _notes.result.list;
                [_list addObjectsFromArray:list];
                _isNoData = NO;
                
                [_tableView reloadData];

                _tableView.tableFooterView = nil;
                [_activityIndicator stopAnimating];
                if (_list.count == 0) _activityIndicator.hidden = YES;
            }

        } else {
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestCount);
                    _tableView.tableFooterView = _footerView;
                    [_activityIndicator startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_activityIndicator stopAnimating];
                    _tableView.tableFooterView = nil;
                }
            }
            else
            {
                [_activityIndicator stopAnimating];
                _tableView.tableFooterView = nil;
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

#pragma mark - Methods

- (void)updateTabAppearance:(CGPoint)contentOffset
{
    CGFloat limit;
    if (_shopIsGold) {
        limit = self.headerView.frame.size.height - 131;
    } else {
        limit = (self.headerView.frame.size.height - 66);
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
    _isRefreshView = YES;
    
    [_tableView reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
}

#pragma mark - Cell Delegate

-(void)ShopNotesCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexPath
{
    NotesList *list = _list[indexPath.row];
    SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY),
                kTKPDNOTES_APINOTEIDKEY:list.note_id,
                kTKPDNOTES_APINOTETITLEKEY:list.note_title
                };
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - Actions

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
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
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
            case 2:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                ShopTalkViewController *shopTalkController = [storyboard instantiateViewControllerWithIdentifier:@"ShopTalkViewController"];
                shopTalkController.data = _data;
                shopTalkController.contentOffset = self.tableView.contentOffset;
                shopTalkController.shop = _shop;
                [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], shopTalkController]];
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
            default:
                break;
        }
    }
}

@end
