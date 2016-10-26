//
//  InboxMessageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import <BlocksKit/BlocksKit.h>
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
#import "V4Response.h"

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

@end

@implementation InboxMessageViewController
{
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;

    /** url to the next page **/
    NSString *_urinext;

    UIRefreshControl *_refreshControl;
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    NSString *_messageNavigationFlag;

    TAGContainer *_gtmContainer;

    NoResultReusableView *_noResultView;
    UserAuthentificationManager *_userManager;

    TokopediaNetworkManager *_getInboxListNetworkManager;
    TokopediaNetworkManager *_messageActionNetworkManager;

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
    
    /** create new **/
    _messages = [NSMutableArray new];
    _messageNavigationFlag = [_data objectForKey:@"nav"];
    _userManager = [UserAuthentificationManager new];

    _getInboxListNetworkManager = [TokopediaNetworkManager new];
    _getInboxListNetworkManager.isUsingHmac = YES;
    
    _messageActionNetworkManager = [TokopediaNetworkManager new];
    _messageActionNetworkManager.isUsingHmac = YES;

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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableButtonRead" object:nil userInfo:nil];

    NSDictionary* param =@{
            kTKPDHOME_APIPAGEKEY:@(_page),
            KTKPDMESSAGE_FILTERKEY:_readstatus?_readstatus:@"",
            KTKPDMESSAGE_KEYWORDKEY:_keyword?_keyword:@"",
            KTKPDMESSAGE_NAVKEY:[_data objectForKey:@"nav"]?:@""
    };

    [_getInboxListNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                               path:@"/v1/message"
                                             method:RKRequestMethodGET
                                          parameter:param
                                            mapping:[V4Response mappingWithData:[InboxMessageResult mapping]]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              [self onReceiveMessages:successResult.dictionary[@""]];
                                          }
                                          onFailure:^(NSError *errorResult) {
                                              [self failedLoadingMessages];
                                          }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Inbox Message"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [_getInboxListNetworkManager requestCancel];
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
    [self messageaction:action indexPaths:[_table indexPathsForSelectedRows]?:@[]];
}

- (void)messageaction:(NSString*)action indexPaths:(NSArray<NSIndexPath*>*)indexPaths{
    NSIndexSet* discardedItems = [indexPaths bk_reduce:[NSMutableIndexSet new]
                                             withBlock:^NSMutableIndexSet *(NSMutableIndexSet * totalSet, NSIndexPath *indexPath) {
        [totalSet addIndex:indexPath.row];
        return totalSet;
    }];

    NSArray *messagesJson = [indexPaths bk_map:^NSString *(NSIndexPath *indexPath) {
        return _messages[indexPath.row].json_data_info;
    }];

    [_messages removeObjectsAtIndexes:discardedItems];
    [_table deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    [self postAction:action withMessageJson:messagesJson];
}

- (void)postAction:(NSString *)action withMessageJson:(NSMutableArray<NSString*> *)messagesJson {
    NSString *joinedArr = [messagesJson componentsJoinedByString:@"and"];
    NSDictionary* param = @{
            kTKPDHOME_APIACTIONKEY: action,
            KTKPDMESSAGE_DATAELEMENTKEY : joinedArr,
    };

    NSDictionary<NSString*, NSString*>* pathByAction = @{
            KTKPDMESSAGE_ACTIONARCHIVEMESSAGE: @"/v1/message/archive",
            KTKPDMESSAGE_ACTIONDELETEMESSAGE: @"/v1/message/delete",
            KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE: @"/v1/message/move_inbox",
            KTKPDMESSAGE_ACTIONDELETEFOREVERMESSAGE: @"/v1/message/delete/forever"
    };

    [_messageActionNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                                path:pathByAction[action]
                                              method:RKRequestMethodPOST
                                           parameter:param
                                             mapping:[InboxMessageAction mapping]
                                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                               [self requestactionsuccess:successResult withOperation:operation];

                                               [_table reloadData];
                                               _isrefreshview = NO;
                                               [_refreshControl endRefreshing];
                                           }
                                           onFailure:^(NSError *errorResult) {
                                               [self requestactionfailure:errorResult];

                                               _isrefreshview = NO;
                                               [_refreshControl endRefreshing];
                                           }];
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
        
        __weak typeof(self) weakSelf = self;
        //
        //    InboxMessageDetailViewController *vc = [InboxMessageDetailViewController new];
        //    vc.onMessagePosted = ^(NSString *replyMessage) {
        //        [weakSelf updateReplyMessage:replyMessage atIndexPath:indexPath];
        //    };
        //
        //    vc.data = [self dataForIndexPath:indexPath];
        MessageViewController *vc = [[MessageViewController alloc] init];
        vc.senderId = _userManager.getUserId;
        vc.senderDisplayName = @"Tonito";
        vc.messageTitle = list.message_title;
        vc.messageId = list.message_id;
        vc.onMessagePosted = ^(NSString* replyMessage) {
            [weakSelf updateReplyMessage:replyMessage atIndexPath:indexPath];
        };
        
        [AnalyticsManager trackEventName:@"clickMessage"
                                category:GA_EVENT_CATEGORY_INBOX_MESSAGE
                                  action:GA_EVENT_ACTION_VIEW
                                   label:[_data objectForKey:@"nav"]?:@""];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            navigationController.navigationBar.translucent = NO;
            
            [self.splitViewController replaceDetailViewController:navigationController];
        }
        else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

    
    
    
    
}

- (void)updateReplyMessage:(NSString *)message atIndexPath:(NSIndexPath *)indexPath {
    InboxMessageList *list = _messages[indexPath.row];

    list.message_reply = message;
    [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    NSInteger lastRow = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (lastRow == indexPath.row) {
        if ([self hasMoreMessages]) {
            [self fetchInboxMessages];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}

- (BOOL)hasMoreMessages {
    return ![_urinext isEqualToString:@"0"] && _urinext != nil;
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
    _userinfo = notification.userInfo;
    
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
       _readstatus = @"all";
    } else {
        _readstatus = @"unread";
    }

    [_getInboxListNetworkManager requestCancel];
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
    [_getInboxListNetworkManager requestCancel];
    /** clear object **/
    [_messages removeAllObjects];
    
    _page = 1;
    _keyword = @"";
    _searchbar.text = @"";
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

-(void) undoactionmessage {
    NSDictionary *dict = @{@"vc" : _data[@"nav"]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_getInboxListNetworkManager requestCancel];
    _getInboxListNetworkManager.delegate = nil;
    _getInboxListNetworkManager = nil;
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

- (NSArray<NSIndexPath*>*) indexPathsForInserting:(NSArray*)appendedArray to:(NSArray*)sourceArray {
    NSMutableArray<NSIndexPath*>* indexPaths = [NSMutableArray new];
    
    for (NSInteger counter = 0; counter < appendedArray.count; counter++) {
        NSInteger row = counter + sourceArray.count;
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return indexPaths;
}

- (void)onReceiveMessages:(V4Response<InboxMessageResult*> *)message {
    _urinext =  message.data.paging.uri_next;
    _page = [[_getInboxListNetworkManager splitUriToPage:_urinext] integerValue];

    [self addMessages:message.data.list];

    if (_messages.count >0) {
        [_noResultView removeFromSuperview];
    } else {
        NSString *currentCategory = _data[@"nav"];

        [_noResultView setNoResultTitle:[self noMessageInfoFromCategory:currentCategory]];
        _table.tableHeaderView = _searchView;
        _table.tableFooterView = _noResultView;
    }

    [_refreshControl endRefreshing];

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

- (NSString *)noMessageInfoFromCategory:(NSString *)currentCategory {
    NSString *text;
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
    return text;
}

- (void)addMessages:(NSArray<InboxMessageList*> *)messages {
    NSArray<NSIndexPath*>* indexPaths = [self indexPathsForInserting:messages to:_messages];
    [_messages addObjectsFromArray:messages];
    [_table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)failedLoadingMessages {
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    _table.tableFooterView = _loadingView;
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
}

@end
