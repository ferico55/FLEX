//
//  InboxMessageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "InboxMessageViewController.h"
#import "InboxMessage.h"
#import "InboxMessageAction.h"
#import "inbox.h"
#import "string_home.h"
#import "string_inbox_message.h"
#import "string_home.h"
#import "InboxMessageCell.h"
#import "InboxMessageDetailViewController.h"
#import "ReputationDetail.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "UserAuthentificationManager.h"
#import "EncodeDecoderManager.h"
#import "SmileyAndMedal.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"
#import "TAGDataLayer.h"


@interface InboxMessageViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    SmileyDelegate,
    CMPopTipViewDelegate,
    InboxMessageDelegate,
    UISearchDisplayDelegate,
    MGSwipeTableCellDelegate,
    TKPDTabInboxMessageNavigationControllerDelegate,
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate
>

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *editarchiveview;
@property (weak, nonatomic) IBOutlet UIView *inboxtrashforeverview;
@property (weak, nonatomic) IBOutlet UIView *inboxtrashview;


@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *messages_selected;


@property (weak, nonatomic) IBOutlet UIButton *buttontrash;
@property (weak, nonatomic) IBOutlet UIButton *buttonarchive;


typedef enum TagRequest {
    messageListTag,
    messageActionTag
} TagRequest;


@end

@implementation InboxMessageViewController
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    CMPopTipView *popTipView;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    NSMutableDictionary *_datainput;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSInteger _requestarchivecount;
    NSInteger _requesttrashcount;
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    NSString *_messageNavigationFlag;
    
    NSString *_inboxMessageBaseUrl;
    NSString *_inboxMessagePostUrl;
    NSString *_inboxMessageFullUrl;
    
    
    TAGContainer *_gtmContainer;
    
    BOOL _isrefreshnav;    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectmanagerarchive;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestarchive;
    __weak RKManagedObjectRequestOperation *_requesttrash;
    NSOperationQueue *_operationQueue;
    NoResultReusableView *_noResultView;
    UserAuthentificationManager *_userManager;
    EncodeDecoderManager *_encodeDecodeManager;
    TokopediaNetworkManager *_networkManager;
    LoadingView *_loadingView;
    
    NSIndexPath *_selectedIndexPath;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCheckmark:) name:@"editModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageWithFilter:) name:[NSString stringWithFormat:@"%@%@", @"showRead", _messageNavigationFlag] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVc:) name:@"reloadvc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageWithIndex:) name:@"updateMessageWithIndex" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markAsReadMessage:) name:@"markAsReadMessage" object:nil];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [_noResultView generateAllElements:nil
                                 title:@""
                                  desc:@""
                              btnTitle:nil];
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _messages = [NSMutableArray new];
    _messages_selected = [NSMutableArray new];
    _messageNavigationFlag = [_data objectForKey:@"nav"];
    _userManager = [UserAuthentificationManager new];
    _encodeDecodeManager = [EncodeDecoderManager new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = messageListTag;
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    /** set first page become 1 **/
    _page = 1;
    [self initNotification];
    [self initNoResultView];
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    
    if (_messages.count > 0) {
        _isnodata = NO;
    }
    
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabel setTitle:@"All" forState:UIControlStateNormal];
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    titleLabel.tag = 15;
    [titleLabel addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _table.tableHeaderView = _searchView;
    _table.allowsSelectionDuringEditing = YES;
    _table.allowsMultipleSelectionDuringEditing = YES;
    
    // GTM
    [self configureGTM];
    
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Inbox Message";
    [TPAnalytics trackScreenName:@"Inbox Message"];

    if (!_isrefreshview) {
        if (_isnodata && _page < 1) {
            [_networkManager doRequest];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [_networkManager requestCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction
- (IBAction)tap:(id)sender {
    [_searchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
            //archive
            case 10: {
                [self messageaction:KTKPDMESSAGE_ACTIONARCHIVEMESSAGE];
                _navthatwillrefresh = @"archive";
                break;
            }
                
            //trash
            case 11 : {
                [self messageaction:KTKPDMESSAGE_ACTIONDELETEMESSAGE];
                _navthatwillrefresh = @"trash";
                break;
            }
                
                
            //back to inbox message
            case 12 : {
                if([_messageNavigationFlag isEqualToString:@"inbox-message-archive"]) {
                    [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE];
                    _navthatwillrefresh = @"inbox-sent";
                } else {
                    [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE];
                    _navthatwillrefresh = @"inbox-archive-sent";
                }
                
                break;
            }
            
            //delete forever
            case 13 : {
                [self messageaction:KTKPDMESSAGE_ACTIONDELETEFOREVERMESSAGE];
                break;
            }
            case 14 : {
                
                break;
            }
            default:
                break;
        }
        
    }
}

- (void) messageaction:(id)action{
    NSIndexPath *item;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 1;
    
    for (item in _messages_selected) {
        
        NSInteger row = [item row];
        [discardedItems addIndex:row];
        InboxMessageList *list = _messages[row];
        [arr addObject:list.json_data_info];
        index++;
    }
    
    [_messages removeObjectsAtIndexes:discardedItems];
    
    NSString *joinedArr = [arr componentsJoinedByString:@"and"];
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:_messages_selected withRowAnimation:UITableViewRowAnimationFade];
    [_messages_selected removeAllObjects];
    if(_messages==nil || _messages.count==0) {
        _isnodata = YES;
//        _table.tableFooterView = [self getNoResult];
    }
    [_table endUpdates];
    

    
    [self configureactionrestkit];
    [self doactionmessage:joinedArr withAction:action];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _messages.count;
#else
    return _isnodata ? 0 : _messages.count;
#endif
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDINBOXMESSAGECELL_IDENTIFIER;
        
        cell = (InboxMessageCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [InboxMessageCell newcell];
            ((InboxMessageCell*)cell).delegate = self;
            ((InboxMessageCell*) cell).del = self;
        }

        if (_messages.count > indexPath.row ) {
            InboxMessageList *list = _messages[indexPath.row];
            
            ((InboxMessageCell*)cell).btnReputasi.tag = indexPath.row;
            ((InboxMessageCell*)cell).message_title.text = list.user_full_name;
            ((InboxMessageCell*)cell).message_create_time.text =list.message_create_time;
            ((InboxMessageCell*)cell).message_reply.text = list.message_reply;
            ((InboxMessageCell*)cell).indexpath = indexPath;
            
            if(list.user_reputation.no_reputation!=nil && [list.user_reputation.no_reputation isEqualToString:@"1"]) {
                [((InboxMessageCell*)cell).btnReputasi setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [((InboxMessageCell*)cell).btnReputasi setTitle:@"" forState:UIControlStateNormal];
            }
            else {
                [((InboxMessageCell*)cell).btnReputasi setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [((InboxMessageCell*)cell).btnReputasi setTitle:[NSString stringWithFormat:@"%@%%", list.user_reputation.positive_percentage] forState:UIControlStateNormal];
            }
            
            //Set user label
//            if([list.user_label isEqualToString:CPenjual]) {
//                [((InboxMessageCell*)cell).message_title setColor:CTagPenjual];
//            }
//            else if([list.user_label isEqualToString:CPembeli]) {
//                [((InboxMessageCell*)cell).message_title setColor:CTagPembeli];
//            }
//            else if([list.user_label isEqualToString:CAdministrator]) {
//                [((InboxMessageCell*)cell).message_title setColor:CTagAdministrator];
//            }
//            else if([list.user_label isEqualToString:CPengguna]) {
//                [((InboxMessageCell*)cell).message_title setColor:CTagPengguna];
//            }
//            else {
//                [((InboxMessageCell*)cell).message_title setColor:-1];//-1 is set to empty string
//            }
            [((InboxMessageCell*)cell).message_title setLabelBackground:list.user_label];
            
            if([[_data objectForKey:@"nav"] isEqualToString:NAV_MESSAGE]) {
                if([list.message_read_status isEqualToString:@"1"]) {
                    ((InboxMessageCell*)cell).is_unread.hidden = YES;
                } else {
                    ((InboxMessageCell*)cell).is_unread.hidden = NO;
                }
            }
            

            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *thumb = ((InboxMessageCell*)cell).userimageview;
            thumb = [UIImageView circleimageview:thumb];
            thumb.image = nil;
            [thumb setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
#pragma clang diagnostic pop
            } failure:nil];
        }
        
        return cell;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleNone;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_iseditmode || _table.isEditing) {
        if ([_messages_selected containsObject:indexPath]) {
            [_messages_selected removeObject:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_iseditmode || _table.isEditing) {
        if (![_messages_selected containsObject:indexPath]) {
            [_messages_selected addObject:indexPath];
        }
    } else {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSInteger index = indexPath.row;
        InboxMessageList *list = _messages[index];

        NSDictionary *data = @{KTKPDMESSAGE_IDKEY : list.message_id?:@"",
                               KTKPDMESSAGE_TITLEKEY : list.message_title?:@"",
                               KTKPDMESSAGE_NAVKEY : [_data objectForKey:@"nav"]?:@"",
                               MESSAGE_INDEX_PATH : indexPath?:[NSIndexPath indexPathForRow:0 inSection:0]
                               };

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            if (![data isEqualToDictionary:_detailViewController.data]) {
                [_detailViewController replaceDataSelected:data];
                [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                _selectedIndexPath = indexPath;
            }
        }
        else
        {
            InboxMessageDetailViewController *vc = [InboxMessageDetailViewController new];
            list.message_read_status = @"1";
            vc.data = data;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
            [_networkManager doRequest];
        } else {
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];;
            [_act stopAnimating];
        }
    }
}


#pragma mark - NSNotificationAction

-(void) showCheckmark:(NSNotification*)notification {
    _userinfo = notification.userInfo;
    
    NSInteger selected_vc = [_userinfo[@"show_check"] integerValue];
    _isrefreshview = YES;
    
    //show OPTION move to archive + trash
    if(selected_vc == 0 || selected_vc == 1) {
        _editarchiveview.hidden = NO;
        _inboxtrashforeverview.hidden = YES;
        _inboxtrashview.hidden = YES;
        _iseditmode = YES;

        [_table setEditing:YES animated:YES];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
        _table.contentInset = UIEdgeInsetsMake(0, 0, _editarchiveview.bounds.size.height, 0);

    //show OPTION move to trash forever + back to inbox
    } else if (selected_vc == 3){
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = NO;
        _inboxtrashview.hidden = YES;
        _iseditmode = YES;

        [_table setEditing:YES animated:YES];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
        _table.contentInset = UIEdgeInsetsMake(0, 0, _inboxtrashforeverview.bounds.size.height, 0);

    } else if (selected_vc == 2) {
        _inboxtrashview.hidden = NO;
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = YES;
        _iseditmode = YES;

        [_table setEditing:YES animated:YES];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
        _table.contentInset = UIEdgeInsetsMake(0, 0, _inboxtrashview.bounds.size.height, 0);

    } else {
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = YES;
        _inboxtrashview.hidden = YES;
        _iseditmode = NO;

        [_table reloadData];
        [self performSelector:@selector(disableEditing) withObject:nil afterDelay:0.05];
        [_messages_selected removeAllObjects];
    }
}

- (void)reloadData
{
    [_table reloadData];
}

- (void)disableEditing
{
    [_table setEditing:NO animated:YES];
}

-(void)showMessageWithFilter:(NSNotification*)notification {
    if (_request.isExecuting) return;
    _userinfo = notification.userInfo;
    
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
       _readstatus = @"all";
    } else {
        _readstatus = @"unread";
    }

    [_networkManager requestCancel];
    [_messages removeAllObjects];
    [_table reloadData];
    _table.tableFooterView = _footer;
    _page = 1;
    [_networkManager doRequest];
    
    [_table reloadData];
}

-(void) reloadVc:(NSNotification*)notification {

    if([[_data objectForKey:@"nav"] isEqualToString:notification.userInfo[@"vc"]] && !_isrefreshnav) {
        [_messages removeAllObjects];
        _page = 1;
        [_table reloadData];
        _table.tableFooterView = _footer;
        
        [_networkManager doRequest];
    }
}

-(void) updateMessageWithIndex:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSIndexPath *indexpath = [userinfo objectForKey:MESSAGE_INDEX_PATH];
    NSString *messageReply = [userinfo objectForKey:KTKPDMESSAGE_MESSAGEREPLYKEY];
    
    if(messageReply) {
        InboxMessageList *list = _messages[indexpath.row];
        
        list.message_reply = [NSString stringWithFormat:@"%@",messageReply];
        [_table reloadData];
    }

}

- (void)markAsReadMessage:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSIndexPath *indexpath = [userinfo objectForKey:@"index_path"];
    NSString *readStatus = [userinfo objectForKey:@"read_status"];
    
    if(readStatus) {
        if (_messages.count > indexpath.row) {
            InboxMessageList *list = _messages[indexpath.row];
            
            list.message_read_status = readStatus;
            [_table reloadData];
        }
    }
}


#pragma mark - Refresh Data
-(void)refreshView:(UIRefreshControl*)refresh
{
    [_networkManager requestCancel];
    /** clear object **/
    [_messages removeAllObjects];
    
    _page = 1;
    _keyword = @"";
    _searchbar.text = @"";
    _requestcount = 0;
    _isrefreshview = YES;
    _isrefreshnav = YES;
    [_messages_selected removeAllObjects];
    
    [_table reloadData];
    /** request data **/
    [_networkManager doRequest];
}


#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchbar = searchBar;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar resignFirstResponder];
    
    _keyword = _searchbar.text;
    _page = 1;
    [self undoactionmessage];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    _searchbar.text = nil;
    _keyword = _searchbar.text;
    _page = 1;
    
    [_messages removeAllObjects];

    [_networkManager doRequest];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


#pragma mark - Message Action

-(void) configureactionrestkit {
    _objectmanagerarchive =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxMessageAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxMessageActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:KTKPDMESSAGEPRODUCTACTION_PATHURL
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerarchive addResponseDescriptor:responseDescriptorStatus];
}

- (void) doactionmessage:(id)data withAction:(id)action{
    NSString *deleted_json_info = data;
    
    if (_requestarchive.isExecuting) return;
    
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:action,
                            KTKPDMESSAGE_DATAELEMENTKEY : deleted_json_info,
                            };
    
    _requestarchivecount ++;
    _requestarchive = [_objectmanagerarchive appropriateObjectRequestOperationWithObject:self
                                                                                  method:RKRequestMethodPOST
                                                                                    path:KTKPDMESSAGEPRODUCTACTION_PATHURL
                                                                              parameters:[param encrypt]];
    
    [_requestarchive setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestactionsuccess:mappingResult withOperation:operation];
        
        [_table reloadData];
        _isrefreshview = NO;
        _isrefreshnav = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
       
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestactionfailure:error];
        
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_requestarchive];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestactiontimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void) requestactionsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    InboxMessageAction *inboxmessageaction = info;
    BOOL status = [inboxmessageaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        //if success
        if([inboxmessageaction.result.is_success isEqualToString:@"1"]) {
            _isrefreshnav = NO;
            
            if([_navthatwillrefresh isEqualToString:@"inbox-archive-sent"]) {
                [self reloadInbox];
                [self reloadArchive];
                [self reloadSent];
            }
            else if([_navthatwillrefresh isEqualToString:@"inbox-sent"]) {
                [self reloadInbox];
                [self reloadSent];
            }
            else if([_navthatwillrefresh isEqualToString:@"archive"]) {
                [self reloadArchive];
            }
            else if([_navthatwillrefresh isEqualToString:@"trash"]) {
                [self reloadTrash];
            }
        } else {
            [self undoactionmessage];
        }
    }
}

- (void)reloadInbox {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"inbox-message", @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}

- (void)reloadSent {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"inbox-message-sent", @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}

- (void)reloadArchive {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"inbox-message-archive", @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}

- (void)reloadTrash {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"inbox-message-trash", @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}

-(void) requestactionfailure:(id)error {
    [self undoactionmessage];
}
-(void) requestactiontimeout {
    [self undoactionmessage];
}

-(void) undoactionmessage {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[_data objectForKey:@"nav"], @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
    
    [_messages_selected removeAllObjects];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}



#pragma mark - InboxMessageCell Delegate
-(void)InboxMessageCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    
    if(_iseditmode) {
        if ([_messages_selected containsObject:indexpath]) {
            [_messages_selected removeObject:indexpath];
        }
        else  {
            [_messages_selected addObject:indexpath];
        }
        
        [_table reloadData];
    } else {
        NSInteger index = indexpath.row;
        InboxMessageList *list = _messages[index];
        InboxMessageDetailViewController *vc = [InboxMessageDetailViewController new];
        list.message_read_status = @"1";
        vc.data = @{KTKPDMESSAGE_IDKEY : list.message_id,
                    KTKPDMESSAGE_TITLEKEY : list.message_title,
                    KTKPDMESSAGE_NAVKEY : [_data objectForKey:@"nav"],
                    MESSAGE_INDEX_PATH : indexpath
                    };
        [_table reloadData];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - Swipe Delegate
-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    if(_iseditmode) {
        return NO;
    } else {
        return YES;
    }
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
        NSIndexPath *indexPath = ((InboxMessageCell*) cell).indexpath;
        InboxMessageList *list = _messages[indexPath.row];
        
        if ([_messages_selected containsObject:indexPath]) {
            [_messages_selected removeObject:indexPath];
        }
        else  {
            [_messages_selected addObject:indexPath];
        }
        
        [_datainput setObject:list.message_id forKey:@"message_id"];

        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self messageaction:KTKPDMESSAGE_ACTIONDELETEMESSAGE];
            _navthatwillrefresh = @"trash";
            return YES;
        }];
        MGSwipeButton * archive = [MGSwipeButton buttonWithTitle:@"Arsipkan" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self messageaction:KTKPDMESSAGE_ACTIONARCHIVEMESSAGE];
            _navthatwillrefresh = @"archive";

            return YES;
        }];
        
        MGSwipeButton * backtoinbox = [MGSwipeButton buttonWithTitle:@"Inbox" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            if([_messageNavigationFlag isEqualToString:@"inbox-message-archive"]) {
                [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE];
                _navthatwillrefresh = @"inbox-sent";
            } else {
                [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE];
                _navthatwillrefresh = @"inbox-archive-sent";
            }
            
            return YES;
        }];
        
        MGSwipeButton * deleteforever = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self messageaction:KTKPDMESSAGE_ACTIONDELETEFOREVERMESSAGE];
            
            return YES;
        }];

        if([_messageNavigationFlag isEqualToString:@"inbox-message"] || [_messageNavigationFlag isEqualToString:@"inbox-message-sent"]) {
            return @[trash, archive];
        }
        
        if([_messageNavigationFlag isEqualToString:@"inbox-message-archive"]) {
            return @[trash, backtoinbox];
        }
        
        if([_messageNavigationFlag isEqualToString:@"inbox-message-trash"]) {
            return @[backtoinbox, deleteforever];
        }
    }
    return nil;
}

#pragma mark - Tokopedia Network Manager 
- (NSDictionary *)getParameter:(int)tag {
    if(tag == messageListTag) {
        NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONGETMESSAGE,
                                kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE),
                                kTKPDHOME_APIPAGEKEY:@(_page),
                                KTKPDMESSAGE_FILTERKEY:_readstatus?_readstatus:@"",
                                KTKPDMESSAGE_KEYWORDKEY:_keyword?_keyword:@"",
                                KTKPDMESSAGE_NAVKEY:[_data objectForKey:@"nav"]?:@""
                                };
        return param;
    }
    
    return nil;
}

- (NSString *)getPath:(int)tag {
    if(tag == messageListTag) {
        return [_inboxMessagePostUrl isEqualToString:@""] ? KTKPDMESSAGE_PATHURL : _inboxMessagePostUrl;
    }
    
    return nil;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == messageListTag) {
        NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
        id stat = [resultDict objectForKey:@""];
        InboxMessage *list = stat;
        
        return list.status;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == messageListTag) {
//        _objectmanager =  [RKObjectManager sharedClient];
//        _objectmanager =  ![_inboxMessageBaseUrl isEqualToString:kTkpdBaseURLString]?[RKObjectManager sharedClient:_inboxMessageBaseUrl]:[RKObjectManager sharedClient];
        if([_inboxMessageBaseUrl isEqualToString:kTkpdBaseURLString] || [_inboxMessageBaseUrl isEqualToString:@""]) {
            _objectmanager = [RKObjectManager sharedClient];
        } else {
            _objectmanager = [RKObjectManager sharedClient:_inboxMessageBaseUrl];
        }
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxMessage class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxMessageResult class]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxMessageList class]];
        [listMapping addAttributeMappingsFromArray:@[
                                                     KTKPDMESSAGE_IDKEY,
                                                     KTKPDMESSAGE_USERFULLNAMEKEY,
                                                     KTKPDMESSAGE_CREATETIMEKEY,
                                                     KTKPDMESSAGE_READSTATUSKEY,
                                                     KTKPDMESSAGE_TITLEKEY,
                                                     KTKPDMESSAGE_USERIDKEY,
                                                     KTKPDMESSAGE_MESSAGEREPLYKEY,
                                                     KTKPDMESSAGE_INBOXIDKEY,
                                                     KTKPDMESSAGE_USERIMAGEKEY,
                                                     KTKPDMESSAGE_JSONDATAKEY,
                                                     KTKPDMESSAGE_USER_LABEL,
                                                     KTKPDMESSAGE_USER_LABEL_ID
                                                     ]];
        
        
        RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                     CNoReputation,
                                                                     CNegative,
                                                                     CNeutral,
                                                                     CPositif]];
        RKRelationshipMapping *userReputationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CUserReputation toKeyPath:CUserReputation withMapping:reviewUserReputationMapping];
        [listMapping addPropertyMapping:userReputationRel];
        
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pageRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
        [resultMapping addPropertyMapping:listRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[_inboxMessagePostUrl isEqualToString:@""] ? KTKPDMESSAGE_PATHURL : _inboxMessagePostUrl
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        return _objectmanager;
    }
    
    return nil;
}

- (void)actionBeforeRequest:(int)tag {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableButtonRead" object:nil userInfo:nil];
    if(tag == messageListTag) {
        if (_navthatwillrefresh || !_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }

    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    if(tag == messageListTag) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        InboxMessage *message = [result objectForKey:@""];
        
        [_messages addObjectsFromArray: message.result.list];
        
        if (_messages.count >0) {
            _isnodata = NO;
            _urinext =  message.result.paging.uri_next;
            _page = [[_networkManager splitUriToPage:_urinext] integerValue];
            [_noResultView removeFromSuperview];
        } else {
            _isnodata = YES;
            //_table.tableFooterView = _noResultView;
            NSString *text;
            NSString *currentCategory = [_data objectForKey:@"nav"];
            
            if(_keyword != nil && ![_keyword isEqualToString:@""]){
                text = [NSString stringWithFormat:@"Pesan dengan keyword \"%@\" tidak ditemukan.", _keyword];
            }else if([currentCategory isEqualToString:@"inbox-message"]){
                text = @"Belum ada pesan";
            }else if([currentCategory isEqualToString:@"inbox-message-sent"]){
                text = @"Belum ada pesan terkirim";
            }else if([currentCategory isEqualToString:@"inbox-message-archive"]){
                text = @"Belum ada pesan diarsipkan";
            }else if([currentCategory isEqualToString:@"inbox-message-trash"]){
                text = @"Belum ada pesan dihapus";
            }
            [_noResultView setNoResultTitle:text];
            _table.tableHeaderView = _searchView;
            _table.tableFooterView = _noResultView;
        }
        
        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableButtonRead" object:nil userInfo:nil];
        [_table reloadData];
        
        if(_iseditmode) {
            for (NSIndexPath *indexpath in _messages_selected) {
                [_table selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
            
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            if (_messages.count > 0) {
                NSIndexPath *indexpath = _selectedIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
                InboxMessageList *list = _messages[indexpath.row];
                
                NSDictionary *data = @{KTKPDMESSAGE_IDKEY : list.message_id?:@"",
                                       KTKPDMESSAGE_TITLEKEY : list.message_title?:@"",
                                       KTKPDMESSAGE_NAVKEY : [_data objectForKey:@"nav"]?:@"",
                                       MESSAGE_INDEX_PATH : indexpath
                                       };
                if (![data isEqualToDictionary:_detailViewController.data]) {
                    [_detailViewController replaceDataSelected:data];
                }
                [_table selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                [_detailViewController replaceDataSelected:nil];
            }
        }
    }
}

//- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
//    if(tag == messageListTag) {
//        
//    }
//}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == messageListTag) {
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        _table.tableFooterView = _loadingView.view;

    }
}

#pragma mark - Retry Delegate
- (void)pressRetryButton {
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [_networkManager doRequest];
}


- (void)configureGTM {
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [_userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _inboxMessageBaseUrl = [_gtmContainer stringForKey:GTMKeyInboxMessageBase];
    _inboxMessagePostUrl = [_gtmContainer stringForKey:GTMKeyInboxMessagePost];
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


#pragma mark - InboxMessage Delegate
- (void)actionSmile:(id)sender {
    InboxMessageList *list = _messages[((UIView *) sender).tag];

    if(! (list.user_reputation.no_reputation!=nil && [list.user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.user_reputation.neutral withRepSmile:list.user_reputation.positive withRepSad:list.user_reputation.negative withDelegate:self];
        
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
@end
