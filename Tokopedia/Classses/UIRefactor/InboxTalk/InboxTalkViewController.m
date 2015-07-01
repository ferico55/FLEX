//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "GeneralTalkCell.h"

#import "Talk.h"
#import "GeneralAction.h"
#import "InboxTalk.h"

#import "inbox.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"

#import "URLCacheController.h"
#import "NoResultView.h"
#import "DetailProductViewController.h"

@interface InboxTalkViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TKPDTabInboxTalkNavigationControllerDelegate,
    GeneralTalkCellDelegate,
    UIAlertViewDelegate
>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *talkList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation InboxTalkViewController
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _talkListPage;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    
    NSString *_urinext;
    NSString *_talkNavigationFlag;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;

    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;

    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;

    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    NSIndexPath *_selectedIndexPath;
    NoResultView *_noResultView;
    
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


- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalComment:)
                                                 name:@"UpdateTotalComment" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUnreadTalk:)
                                                 name:@"updateUnreadTalk" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTalkWithFilter:)
                                                 name:[NSString stringWithFormat:@"%@%@", @"showRead", _talkNavigationFlag]
                                               object:nil];
}

- (void)initCache {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:TKPD_INBOXTALK_CACHE];
    
    if(_userinfo[@"show_read"] == nil) {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_all",[_data objectForKey:@"nav"]]];
    } else {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",[_data objectForKey:@"nav"], _readstatus]];
    }
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _talkListPage = 1;
    
    [self initNotification];
    _operationQueue = [NSOperationQueue new];
    _operationUnfollowQueue = [NSOperationQueue new];
    _operationDeleteQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _talkList = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = _footer;
    
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_talkList.count > 0) {
        _isnodata = NO;
    }
    

    [self initCache];
    [self configureRestKit];
    
    //TODO::
    //gimana kalo di balikin sama server data kosong
    //gimana kalo di balikin error sama server
    if(_talkListPage == 1) {
        _isLoadFromCache = YES;
        [self loadDataFromCache];
    }

    _isLoadFromCache = NO;
    [self loadData];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Inbox Talk";
    if (!_isrefreshview) {
        [self configureRestKit];
        
        if (_isnodata && _talkListPage < 1) {
            [self loadData];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self configureRestKit];
            [self loadData];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}

#pragma mark - TableView Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isnodata ? 0 : _talkList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALTALKCELL_IDENTIFIER;
        
        cell = (GeneralTalkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralTalkCell newcell];
            ((GeneralTalkCell*)cell).delegate = self;
        }
        
        if (_talkList.count > indexPath.row) {
            TalkList *list = _talkList[indexPath.row];
            
            ((GeneralTalkCell*)cell).indexpath = indexPath;
            ((GeneralTalkCell *)cell).data = list;
            [((GeneralTalkCell*)cell).userButton setTitle:list.talk_user_name forState:UIControlStateNormal];
            [((GeneralTalkCell*)cell).productButton setTitle:list.talk_product_name forState:UIControlStateNormal];
            ((GeneralTalkCell*)cell).timelabel.text = list.talk_create_time;
            [((GeneralTalkCell*)cell).commentbutton setTitle:[NSString stringWithFormat:@"%@ %@", list.talk_total_comment, COMMENT_TALK] forState:UIControlStateNormal];
            
            if(list.talk_follow_status == 1 && ![list.talk_own isEqualToString:@"1"]) {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = NO;
                
                CGRect newFrame = ((GeneralTalkCell*)cell).commentbutton.frame;
                newFrame.origin.x = 0;
                ((GeneralTalkCell*)cell).commentbutton.frame = newFrame;
                ((GeneralTalkCell*)cell).buttonsDividers.hidden = NO;
            } else {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = YES;
                ((GeneralTalkCell*)cell).unfollowButton.hidden = YES;
                
                CGRect newFrame = ((GeneralTalkCell*)cell).commentbutton.frame;
                newFrame.origin.x = 75;
                ((GeneralTalkCell*)cell).commentbutton.frame = newFrame;
                ((GeneralTalkCell*)cell).buttonsDividers.hidden = YES;
            }
            
            if([list.talk_read_status isEqualToString:@"1"]) {
                ((GeneralTalkCell*)cell).subContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                ((GeneralTalkCell*)cell).subContentView.layer.borderWidth = 1.0;
                ((GeneralTalkCell*)cell).unreadIcon.hidden = NO;
            } else {
                ((GeneralTalkCell*)cell).subContentView.layer.borderWidth = 0;
                ((GeneralTalkCell*)cell).unreadIcon.hidden = YES;
            }
            
            if ([list.talk_message length] > 30) {
                NSRange stringRange = {0, MIN([list.talk_message length], 30)};
                stringRange = [list.talk_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralTalkCell*)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.talk_message substringWithRange:stringRange]];
            } else {
                ((GeneralTalkCell*)cell).commentlabel.text = list.talk_message;
            }

//            if([list.talk_product_status isEqualToString:@"0"]) {
//                ((GeneralTalkCell*)cell).commentbutton.enabled = NO;
//            } else {
//                ((GeneralTalkCell*)cell).commentbutton.enabled = YES;
//            }
            
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

#pragma mark - Request + Mapping
- (void)configureRestKit
{
    _objectmanager =  [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];

    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_PRODUCT_NAME,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_IMG,
                                                 TKPD_TALK_PRODUCT_STATUS,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_READ_STATUS,
                                                 TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_PRODUCT_ID,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_PRODUCT_IMAGE,
                                                 TKPD_TALK_OWN,
                                                 TKPD_TALK_USER_ID,
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDINBOX_TALK_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
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
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            _isrefreshview = YES;
            _isNeedToInsertCache = NO;
            [self requestsuccess:mappingresult withOperation:nil];
        }
    }
}

- (void)loadData {
    if (_request.isExecuting) return;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDTALK_ACTIONGET,
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE),
                            kTKPDHOME_APIPAGEKEY:@(_talkListPage),
                            KTKPDMESSAGE_FILTERKEY:_readstatus?_readstatus:@"",
                            KTKPDMESSAGE_KEYWORDKEY:_keyword?_keyword:@"",
                            KTKPDMESSAGE_NAVKEY:[_data objectForKey:@"nav"]
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:KTKPDMESSAGE_TALK
                                                                parameters:[param encrypt]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableButtonRead" object:nil userInfo:nil];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableButtonRead" object:nil userInfo:nil];
        _isNeedToInsertCache = YES;
        
        [self requestsuccess:mappingResult withOperation:operation];
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        InboxTalk *inboxtalk = stat;
        BOOL status = [inboxtalk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(_isrefreshview) {
                [_talkList removeAllObjects];
            }
            
            [_talkList addObjectsFromArray: inboxtalk.result.list];

            if(_talkListPage == PAGE_TO_CACHE && _isNeedToInsertCache) {
                [_cacheconnection connection:operation.HTTPRequestOperation.request
                          didReceiveResponse:operation.HTTPRequestOperation.response];
                [_cachecontroller connectionDidFinish:_cacheconnection];
                
                [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
            }
            
            
            if (_talkList.count >0) {
                _isnodata = NO;
                _urinext =  inboxtalk.result.paging.uri_next;
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

                if(!_isLoadFromCache) {
                    _talkListPage = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
                }
                
            } else {
                _isnodata = YES;
                _table.tableFooterView = _noResultView;
            }
        }
        else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = _noResultView;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = _noResultView;
            }
        }
    }
}

- (void)cancel {
    
}

- (void)requestfailure:(id)error {
    
}

- (void)requesttimeout {
    
}

#pragma mark - General Talk Delegate
- (void)GeneralTalkCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ProductTalkDetailViewController *vc = [ProductTalkDetailViewController new];
    NSInteger row = indexpath.row;
    TalkList *list = _talkList[row];
    
    vc.data = @{
                TKPD_TALK_MESSAGE:list.talk_message?:@0,
                TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
                TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
                TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
                TKPD_TALK_ID:list.talk_id?:@0,
                TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%d", list.talk_user_id],
                TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
                TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image,
                kTKPDDETAIL_DATAINDEXKEY : @(row)?:@0,
                TKPD_TALK_PRODUCT_NAME:list.talk_product_name,
                TKPD_TALK_PRODUCT_STATUS:list.talk_product_status
                };
    
//    DetailProductViewController *vc = [DetailProductViewController new];
//    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : @"11957147"};
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - action
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
                                                                                             pathPattern:TKPD_MESSAGE_TALK_ACTION keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectUnfollowmanager addResponseDescriptor:responseDescriptorStatus];
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
                                                                                             pathPattern:TKPD_MESSAGE_TALK_ACTION
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectDeletemanager addResponseDescriptor:responseDescriptorStatus];
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

- (void)unfollowTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withButton:(UIButton *)buttonUnfollow {
    [self configureUnfollowRestkit];
    [self followAnimateZoomOut:buttonUnfollow];
    
    TalkList *list = _talkList[indexpath.row];
    if (_requestUnfollow.isExecuting) return;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_ACTIONKEY : TKPD_FOLLOW_TALK_ACTION,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                            TKPD_TALK_ID:list.talk_id?:@0,
                            };
    
    _requestUnfollowCount ++;
    _requestUnfollow = [_objectUnfollowmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:TKPD_MESSAGE_TALK_ACTION parameters:[param encrypt]];
    
    [_requestUnfollow setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_talkList removeObjectAtIndex:indexpath.row];
        [_table reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self followAnimateZoomOut:buttonUnfollow];
    }];
    
    [_operationUnfollowQueue addOperation:_requestUnfollow];

}

- (void)deleteTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    _selectedIndexPath = indexpath;
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
        NSInteger row = [_selectedIndexPath row];
        TalkList *list = _talkList[row];
        [_talkList removeObjectAtIndex:row];
        [_table reloadData];
        [self configureDeleteRestkit];
        
        if (_requestDelete.isExecuting) return;
        
        NSDictionary* param = @{
                                kTKPDDETAIL_ACTIONKEY : TKPD_DELETE_TALK_ACTION,
                                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                                TKPD_TALK_ID:list.talk_id?:@0,
                                kTKPDDETAILSHOP_APISHOPID : list.talk_shop_id
                                };
        
        _requestDeleteCount ++;
        _requestDelete = [_objectDeletemanager appropriateObjectRequestOperationWithObject:self
                                                                                    method:RKRequestMethodPOST
                                                                                      path:TKPD_MESSAGE_TALK_ACTION
                                                                                parameters:[param encrypt]];
        
        [_requestDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
        
        [_operationDeleteQueue addOperation:_requestDelete];

    }
}

- (void)failToDelete:(id)talk {
    
}


- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    return self;
}

#pragma mark - Refresh View 
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
//    [_talks removeAllObjects];
    _talkListPage = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Handler
-(void) updateTotalComment:(NSNotification*)notification{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    
    TalkList *list = _talkList[index];
    list.talk_total_comment = [NSString stringWithFormat:@"%@",[userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT]];
    [_table reloadData];
}

- (void)updateUnreadTalk : (NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    
    TalkList *list = _talkList[index];
    list.talk_read_status = @"2";
    [_table reloadData];
}



-(void) showTalkWithFilter:(NSNotification*)notification {
    if (_request.isExecuting) return;
    _userinfo = notification.userInfo;
    
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
        _readstatus = @"all";
    } else {
        _readstatus = @"unread";
    }
    
    [self cancel];
    _talkListPage = 1;
    
    
    /**init view*/
    [self configureRestKit];
    [self initCache];
    
    NSData *data = [NSData dataWithContentsOfFile:_cachepath];
    if(_talkListPage == 1 && data.length) {
        _isLoadFromCache = YES;
        [self loadDataFromCache];
        [_table reloadData];
    } else {
        [_talkList removeAllObjects];
        [_table reloadData];
         _table.tableFooterView = _footer;
    }
    
    _isLoadFromCache = NO;
    [self loadData];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
