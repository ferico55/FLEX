//
//  InboxMessageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "InboxMessageViewController.h"
#import "InboxMessage.h"
#import "InboxMessageAction.h"
#import "inbox.h"
#import "string_home.h"
#import "string_inbox_message.h"
#import "InboxMessageCell.h"
#import "InboxMessageDetailViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "SmileyAndMedal.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"
#import "NavigationHelper.h"
#import "Tokopedia-Swift.h"

@interface InboxMessageViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    SmileyDelegate,
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


@property (nonatomic, strong) NSMutableArray<InboxMessageList*> *messages;
@property (nonatomic, strong) NSDictionary *userinfo;

@property (weak, nonatomic) IBOutlet UIButton *buttontrash;
@property (weak, nonatomic) IBOutlet UIButton *buttonarchive;


typedef enum TagRequest {
    messageListTag,
    messageActionTag
} TagRequest;


@end

@implementation InboxMessageViewController
{
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;

    /** url to the next page **/
    NSString *_urinext;

    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSInteger _requestarchivecount;
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    NSString *_messageNavigationFlag;
    
    NSString *_inboxMessageBaseUrl;
    NSString *_inboxMessagePostUrl;

    TAGContainer *_gtmContainer;

    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectmanagerarchive;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestarchive;
    NSOperationQueue *_operationQueue;
    NoResultReusableView *_noResultView;
    UserAuthentificationManager *_userManager;

    TokopediaNetworkManager *_networkManager;
    LoadingView *_loadingView;
}


#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
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
    _messageNavigationFlag = [_data objectForKey:@"nav"];
    _userManager = [UserAuthentificationManager new];

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

    [self fetchInboxMessages];
}

- (void)fetchInboxMessages {
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Inbox Message";
    [TPAnalytics trackScreenName:@"Inbox Message"];
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

- (void) messageaction:(NSString*)action{
    [self messageaction:action indexPaths:[_table indexPathsForSelectedRows]];
}

- (void)messageaction:(NSString*)action indexPaths:(NSArray<NSIndexPath*>*)indexPaths{
    NSIndexPath *item;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 1;
    
    for (item in indexPaths) {
        
        NSInteger row = [item row];
        [discardedItems addIndex:row];
        InboxMessageList *list = _messages[row];
        [arr addObject:list.json_data_info];
        index++;
    }
    
    [_messages removeObjectsAtIndexes:discardedItems];
    
    NSString *joinedArr = [arr componentsJoinedByString:@"and"];
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    
    [self configureactionrestkit];
    [self doactionmessage:joinedArr withAction:action];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InboxMessageCell* cell = nil;
    NSString *cellid = kTKPDINBOXMESSAGECELL_IDENTIFIER;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [InboxMessageCell newcell];
        cell.delegate = self;
    }
    
    InboxMessageList *list = _messages[indexPath.row];

    if([[_data objectForKey:@"nav"] isEqualToString:NAV_MESSAGE]) {
        cell.displaysUnreadIndicator = YES;
    }
    
    cell.message = list;
    cell.popTipAnchor = self.view;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_iseditmode || _table.isEditing) {
    } else {
        [self showMessageDetailForIndexPath:indexPath];
    }
}

- (void)showMessageDetailForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        InboxMessageList *list = _messages[indexPath.row];
        list.message_read_status = @"1";
    }

    InboxMessageDetailViewController *vc = [InboxMessageDetailViewController new];
    vc.data = [self dataForIndexPath:indexPath];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        navigationController.navigationBar.translucent = NO;

        [self.splitViewController replaceDetailViewController:navigationController];
    }
    else
    {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSDictionary *)dataForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = nil;

    if (indexPath) {
        InboxMessageList *message = _messages[indexPath.row];
        data = @{
                KTKPDMESSAGE_IDKEY : message.message_id ?: @"",
                KTKPDMESSAGE_TITLEKEY : message.message_title ?: @"",
                KTKPDMESSAGE_NAVKEY : [_data objectForKey:@"nav"] ?: @"",
                MESSAGE_INDEX_PATH : indexPath
        };
    }
    return data;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        if (![_urinext isEqualToString:@"0"] && _urinext != nil) {
            [self fetchInboxMessages];
        } else {
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            [_act stopAnimating];
        }
    }
}


#pragma mark - NSNotificationAction

-(void) showCheckmark:(NSNotification*)notification {
    _userinfo = notification.userInfo;
    
    NSInteger selected_vc = [_userinfo[@"show_check"] integerValue];
    
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
    [self fetchInboxMessages];
    
    [_table reloadData];
}

-(void) reloadVc:(NSNotification*)notification {

    if([[_data objectForKey:@"nav"] isEqualToString:notification.userInfo[@"vc"]] && !_refreshControl.isRefreshing) {
        [_messages removeAllObjects];
        _page = 1;
        [_table reloadData];
        _table.tableFooterView = _footer;
        
        [self fetchInboxMessages];
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
            [_table reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
            [_table selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
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

    [_table reloadData];
    /** request data **/
    [self fetchInboxMessages];
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
    _keyword = @"";
    _page = 1;
    
    [_messages removeAllObjects];
    [_table reloadData];

    [self fetchInboxMessages];
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

    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:[InboxMessageAction mapping]
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:KTKPDMESSAGEPRODUCTACTION_PATHURL
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerarchive addResponseDescriptor:responseDescriptorStatus];
}

- (void) doactionmessage:(NSString*)data withAction:(NSString*)action{

    if (_requestarchive.isExecuting) return;
    
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:action,
                            KTKPDMESSAGE_DATAELEMENTKEY : data,
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
    NSDictionary *dict = @{@"vc" : _data[@"nav"]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
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

-(void) refreshDetailIfCellIsSelected:(UITableViewCell*) cell {
    if (![NavigationHelper shouldDoDeepNavigation] && [_table cellForRowAtIndexPath:[_table indexPathForSelectedRow]] == cell) {
        [self showMessageDetailForIndexPath:nil];
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
        NSIndexPath *indexPath = [_table indexPathForCell:cell];
        InboxMessageList *list = _messages[indexPath.row];

        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self refreshDetailIfCellIsSelected:cell];
            [self messageaction:KTKPDMESSAGE_ACTIONDELETEMESSAGE indexPaths:@[indexPath]];
            _navthatwillrefresh = @"trash";
            return YES;
        }];
        MGSwipeButton * archive = [MGSwipeButton buttonWithTitle:@"Arsipkan" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self refreshDetailIfCellIsSelected:cell];
            [self messageaction:KTKPDMESSAGE_ACTIONARCHIVEMESSAGE indexPaths:@[indexPath]];
            _navthatwillrefresh = @"archive";
            return YES;
        }];
        
        MGSwipeButton * backtoinbox = [MGSwipeButton buttonWithTitle:@"Inbox" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self refreshDetailIfCellIsSelected:cell];
            if([_messageNavigationFlag isEqualToString:@"inbox-message-archive"]) {
                [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE indexPaths:@[indexPath]];
                _navthatwillrefresh = @"inbox-sent";
            } else {
                [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE indexPaths:@[indexPath]];
                _navthatwillrefresh = @"inbox-archive-sent";
            }
            return YES;
        }];
        
        MGSwipeButton * deleteforever = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self refreshDetailIfCellIsSelected:cell];
            [self messageaction:KTKPDMESSAGE_ACTIONDELETEFOREVERMESSAGE indexPaths:@[indexPath]];
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
        if([_inboxMessageBaseUrl isEqualToString:kTkpdBaseURLString] || [_inboxMessageBaseUrl isEqualToString:@""]) {
            _objectmanager = [RKObjectManager sharedClient];
        } else {
            _objectmanager = [RKObjectManager sharedClient:_inboxMessageBaseUrl];
        }
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:[InboxMessage mapping]
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

- (NSArray<NSIndexPath*>*) indexPathsForInserting:(NSArray*)appendedArray to:(NSArray*)sourceArray {
    NSMutableArray<NSIndexPath*>* indexPaths = [NSMutableArray new];
    
    for (NSInteger counter = 0; counter < appendedArray.count; counter++) {
        NSInteger row = counter + sourceArray.count;
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return indexPaths;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    if(tag == messageListTag) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        InboxMessage *message = result[@""];

        _urinext =  message.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_urinext] integerValue];

        [self addMessages:message.result.list];

        if (_messages.count >0) {
            [_noResultView removeFromSuperview];
        } else {
            //_table.tableFooterView = _noResultView;
            NSString *text;
            NSString *currentCategory = _data[@"nav"];
            
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                if (_messages.count > 0) {
                    NSIndexPath *indexpath = [_table indexPathForSelectedRow]?:[NSIndexPath indexPathForRow:0 inSection:0];

                    [self showMessageDetailForIndexPath:indexpath];
                    [_table selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else {
                    [self showMessageDetailForIndexPath:nil];
                }
            }
        });
    }
}

- (void)addMessages:(NSArray<InboxMessageList*> *)messages {
    NSArray<NSIndexPath*>* indexPaths = [self indexPathsForInserting:messages to:_messages];
    [_messages addObjectsFromArray:messages];
    [_table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

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
    [self fetchInboxMessages];
}


- (void)configureGTM {
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:@{@"user_id" : [_userManager getUserId]}];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _inboxMessageBaseUrl = [_gtmContainer stringForKey:GTMKeyInboxMessageBase];
    _inboxMessagePostUrl = [_gtmContainer stringForKey:GTMKeyInboxMessagePost];
}

@end
