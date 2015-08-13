//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "string_inbox_message.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "GeneralTalkCell.h"

#import "ReportViewController.h"
#import "Talk.h"
#import "GeneralAction.h"
#import "InboxTalk.h"

#import "inbox.h"
#import "SmileyAndMedal.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"
#import "ReputationDetail.h"

#import "URLCacheController.h"
#import "NoResultView.h"
#import "TAGDataLayer.h"


@interface InboxTalkViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    CMPopTipViewDelegate,
    TKPDTabInboxTalkNavigationControllerDelegate,
    GeneralTalkCellDelegate,
    SmileyDelegate,
    UIAlertViewDelegate,
    ReportViewControllerDelegate
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
    
    NSString *_inboxTalkBaseUrl;
    NSString *_inboxTalkPostUrl;
    NSString *_inboxTalkFullUrl;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    NSIndexPath *_selectedIndexPath;
    NoResultView *_noResultView;
    TAGContainer *_gtmContainer;
    CMPopTipView *popTipView;
    UserAuthentificationManager *_userManager;
    NSIndexPath *_selectedDetailIndexPath;
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
    _userManager = [UserAuthentificationManager new];
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
    // GTM
    [self configureGTM];
    
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
            [((GeneralTalkCell*)cell).userButton setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:13.0f]];
            ((GeneralTalkCell*)cell).userButton.userInteractionEnabled = YES;
            [((GeneralTalkCell*)cell).userButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(tap:)]];
        }
        
        if (_talkList.count > indexPath.row) {
            TalkList *list = _talkList[indexPath.row];
            
            ((GeneralTalkCell*)cell).btnReputation.tag = indexPath.row;
            ((GeneralTalkCell*)cell).indexpath = indexPath;
            ((GeneralTalkCell *)cell).data = list;
            ((GeneralTalkCell*)cell).userButton.text = list.talk_user_name;
            [((GeneralTalkCell*)cell).productButton setTitle:list.talk_product_name forState:UIControlStateNormal];
            ((GeneralTalkCell*)cell).timelabel.text = list.talk_create_time;
            [((GeneralTalkCell*)cell).commentbutton setTitle:[NSString stringWithFormat:@"%@ %@", list.talk_total_comment, COMMENT_TALK] forState:UIControlStateNormal];
            
            
            
            if(list.talk_user_reputation.no_reputation!=nil && [list.talk_user_reputation.no_reputation isEqualToString:@"1"]) {
                [((GeneralTalkCell*)cell).btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [((GeneralTalkCell*)cell).btnReputation setTitle:@"" forState:UIControlStateNormal];
            }
            else {
                [((GeneralTalkCell*)cell).btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [((GeneralTalkCell*)cell).btnReputation setTitle:[NSString stringWithFormat:@"%@%%", list.talk_user_reputation.positive_percentage==nil? @"0":list.talk_user_reputation.positive_percentage] forState:UIControlStateNormal];
            }
            
            //Set user label
//            if([list.talk_user_label isEqualToString:CPenjual]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPenjual];
//            }
//            else if([list.talk_user_label isEqualToString:CPembeli]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPembeli];
//            }
//            else if([list.talk_user_label isEqualToString:CAdministrator]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagAdministrator];
//            }
//            else if([list.talk_user_label isEqualToString:CPengguna]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPengguna];
//            }
//            else {
//                [((GeneralTalkCell*)cell).userButton setColor:-1];//-1 is set to empty string
//            }
//            
            [((GeneralTalkCell*)cell).userButton setLabelBackground:list.talk_user_label];

            
            if(list.talk_follow_status == 1 && ![list.talk_own isEqualToString:@"1"]) {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = NO;
                
                CGRect newFrame = ((GeneralTalkCell*)cell).commentbutton.frame;
                newFrame.origin.x = 0;
                ((GeneralTalkCell*)cell).commentbutton.frame = newFrame;
                ((GeneralTalkCell*)cell).buttonsDividers.hidden = NO;
                [((GeneralTalkCell *)cell) setTalkFollowStatus:YES];
            } else {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = YES;
                ((GeneralTalkCell*)cell).buttonsDividers.hidden = YES;
                [((GeneralTalkCell *)cell) setTalkFollowStatus:NO];
                

                
                CGRect newFrame = ((GeneralTalkCell*)cell).commentbutton.frame;
                newFrame.origin.x = (((GeneralTalkCell*)cell).frame.size.width-newFrame.size.width)/2;
                ((GeneralTalkCell*)cell).commentbutton.frame = newFrame;
                ((GeneralTalkCell*)cell).commentbutton.translatesAutoresizingMaskIntoConstraints = YES;

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
//    _objectmanager =  [RKObjectManager sharedClient];
//    _objectmanager =  ![_inboxTalkBaseUrl isEqualToString:kTkpdBaseURLString]?[RKObjectManager sharedClient:_inboxTalkBaseUrl]:[RKObjectManager sharedClient];
    if([_inboxTalkBaseUrl isEqualToString:kTkpdBaseURLString] || [_inboxTalkBaseUrl isEqualToString:@""]) {
        _objectmanager = [RKObjectManager sharedClient];
    } else {
        _objectmanager = [RKObjectManager sharedClient:_inboxTalkBaseUrl];
    }
    
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
                                                 TKPD_TALK_USER_LABEL,
                                                 TKPD_TALK_USER_LABEL_ID
                                                 ]];
    
    
    RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                 CNegative,
                                                                 CNoReputation,
                                                                 CNeutral,
                                                                 CPositif]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTalkUserReputation toKeyPath:CTalkUserReputation withMapping:reviewUserReputationMapping]];
    
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
                                                                                             pathPattern:[_inboxTalkPostUrl isEqualToString:@""] ? KTKPDMESSAGE_TALK : _inboxTalkPostUrl
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
                                                                      path:[_inboxTalkPostUrl isEqualToString:@""] ? KTKPDMESSAGE_TALK : _inboxTalkPostUrl
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
            
            
            if (_talkList.count >0)
            {
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _talkListPage<=1) {
                    NSInteger selectedIndex = _selectedDetailIndexPath.row?:0;
                    if(selectedIndex >= _talkList.count)return;
                    TalkList *list = _talkList[selectedIndex];
                    NSDictionary *data = @{
                                           TKPD_TALK_MESSAGE:list.talk_message?:@0,
                                           TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
                                           TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
                                           TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
                                           TKPD_TALK_ID:list.talk_id?:@0,
                                           TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%zd", list.talk_user_id],
                                           TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
                                           kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                                           TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
                                           TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image,
                                           kTKPDDETAIL_DATAINDEXKEY : @(selectedIndex)?:@0,
                                           TKPD_TALK_PRODUCT_NAME:list.talk_product_name,
                                           TKPD_TALK_PRODUCT_STATUS:list.talk_product_status
                                           };
                    [_detailViewController replaceDataSelected:data];
                }

                
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
                _table.tableFooterView = _noResultView.view;
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
                    _table.tableFooterView = _noResultView.view;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = _noResultView.view;
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
- (void)actionSmile:(id)sender {
    TalkList *list = _talkList[((UIView *) sender).tag];
    if(! (list.talk_user_reputation.no_reputation!=nil && [list.talk_user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.talk_user_reputation.neutral withRepSmile:list.talk_user_reputation.positive withRepSad:list.talk_user_reputation.negative withDelegate:self];
        
        //Init pop up
        popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor whiteColor];
        popTipView.animation = CMPopTipAnimationSlide;
        popTipView.dismissTapAnywhere = YES;
        popTipView.leftPopUp = YES;
        
        UIButton *button = (UIButton *)sender;
        [popTipView presentPointingAtView:button inView:self.view animated:YES];
    }
}

- (void)GeneralTalkCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    
    _selectedDetailIndexPath
    = indexpath;
    
    NSInteger row = indexpath.row;
    TalkList *list = _talkList[row];
    
    NSDictionary *data = @{
                TKPD_TALK_MESSAGE:list.talk_message?:@0,
                TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
                TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
                TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
                TKPD_TALK_ID:list.talk_id?:@0,
                TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%zd", list.talk_user_id],
                TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id,
                TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
                TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image,
                kTKPDDETAIL_DATAINDEXKEY : @(row)?:@0,
                TKPD_TALK_PRODUCT_NAME:list.talk_product_name,
                TKPD_TALK_PRODUCT_STATUS:list.talk_product_status,
                TKPD_TALK_USER_LABEL:list.talk_user_label,
                TKPD_TALK_REPUTATION_PERCENTAGE:list.talk_user_reputation
                };
    
    NSDictionary *userinfo;
    userinfo = @{kTKPDDETAIL_DATAINDEXKEY:@(row)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadTalk" object:nil userInfo:userinfo];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (![data isEqualToDictionary:_detailViewController.data]) {
            [_detailViewController replaceDataSelected:data];
        }
    }
    else
    {
        ProductTalkDetailViewController *vc = [ProductTalkDetailViewController new];
        vc.data = data;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    DetailProductViewController *vc = [DetailProductViewController new];
//    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : @"11957147"};
    
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
                            @"shop_id":list.talk_shop_id
                            };
    
    _requestUnfollowCount ++;
    _requestUnfollow = [_objectUnfollowmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:TKPD_MESSAGE_TALK_ACTION parameters:[param encrypt]];
    
    [_requestUnfollow setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        GeneralAction *generalAction = [mappingResult.dictionary objectForKey:@""];
        if(generalAction.message_error!=nil && generalAction.message_error.count>0) {
            StickyAlertView *stickyAlert = [[StickyAlertView alloc] initWithErrorMessages:generalAction.message_error delegate:self];
            [stickyAlert show];
            
            [_table beginUpdates];
            [_table reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
            [_table endUpdates];
        }
        else {
            if([self.parentViewController isMemberOfClass:[TKPDTabInboxTalkNavigationController class]]) {
                TKPDTabInboxTalkNavigationController *inboxTalkNavigationController = (TKPDTabInboxTalkNavigationController *)self.parentViewController;
                
                if(inboxTalkNavigationController.viewControllers.count == 3) {
                    InboxTalkViewController *tempInboxTalkViewController = (inboxTalkNavigationController.selectedIndex==0)? [inboxTalkNavigationController.viewControllers lastObject]:[inboxTalkNavigationController.viewControllers firstObject];
                    [tempInboxTalkViewController removeData:((TalkList *) [_talkList objectAtIndex:indexpath.row]).talk_id];
                }
            }
            [_talkList removeObjectAtIndex:indexpath.row];
            [_table reloadData];
        }
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

#pragma mark - ReportViewController Delegate
#pragma mark - Report Delegate
- (NSDictionary *)getParameter {
    return @{
             @"action" : @"report_product_talk",
             @"talk_id" : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0)
             };
}


- (NSString *)getPath {
    return @"action/talk.pl";
}

#pragma mark - Method
- (void)reportTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ReportViewController *_reportController = [ReportViewController new];
    _reportController.delegate = self;
    
    TalkList *talkList = _talkList[indexpath.row];
    _reportController.strProductID = talkList.talk_product_id;
    _reportController.strCommentTalkID = talkList.talk_id;
    _reportController.strShopID = talkList.talk_shop_id;
    [self.navigationController pushViewController:_reportController animated:YES];
}

- (void)removeData:(NSString *)inboxID
{
    for(TalkList *tempTalkList in _talkList) {
        if([tempTalkList.talk_id isEqual:inboxID]) {
            [_talkList removeObject:tempTalkList];
            [_table reloadData];
            break;
        }
    }
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
    if(index >= _talkList.count) return;
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

- (void)configureGTM {
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [_userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _inboxTalkBaseUrl = [_gtmContainer stringForKey:GTMKeyInboxTalkBase];
    _inboxTalkPostUrl = [_gtmContainer stringForKey:GTMKeyInboxTalkPost];
}



#pragma mark - ToolTip Delegate
- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - Smiley Delegate
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}
@end
