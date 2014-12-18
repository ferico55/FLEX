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
#import "stringhome.h"
#import "string_inbox_message.h"
#import "stringhome.h"
#import "InboxMessageCell.h"
#import "InboxMessageDetailViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"


@interface InboxMessageViewController () <UITableViewDataSource, UITableViewDelegate, InboxMessageCellDelegate, TKPDTabInboxMessageNavigationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

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


@end

@implementation InboxMessageViewController
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    
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
    
    BOOL _isrefreshnav;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectmanagerarchive;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestarchive;
    __weak RKManagedObjectRequestOperation *_requesttrash;
    NSOperationQueue *_operationQueue;
    
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
                                             selector:@selector(showCheckmark:)
                                                 name:@"editModeOn"
                                               object:nil];
    
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMessageWithFilter:)
                                                 name:[NSString stringWithFormat:@"%@%@", @"showRead", _messageNavigationFlag]
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVc:)
                                                 name:@"reloadvc"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessageWithIndex:)
                                                 name:@"updateMessageWithIndex"
                                               object:nil];
    
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _messages = [NSMutableArray new];
    _messages_selected = [NSMutableArray new];
    _messageNavigationFlag = [_data objectForKey:@"nav"];
    
    /** set first page become 1 **/
    _page = 1;
    [self initNotification];
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 155;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 240;
        _table.contentInset = inset;
    }
    
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    
    //    [self setHeaderData:_goldshop];
    //    [_act startAnimating];
    
    if (_messages.count > 0) {
        _isnodata = NO;
    }
    
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabel setTitle:@"All" forState:UIControlStateNormal];
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    titleLabel.tag = 15;
    [titleLabel addTarget:self action:@selector(tapbutton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    NSLog(@"going here first");
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
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
                _navthatwillrefresh = @"inbox-message-archive";
                break;
            }
                
            //trash
            case 11 : {
                [self messageaction:KTKPDMESSAGE_ACTIONDELETEMESSAGE];
                _navthatwillrefresh = @"inbox-message-trash";
                break;
            }
                
                
            //back to inbox message
            case 12 : {
                [self messageaction:KTKPDMESSAGE_ACTIONMOVETOINBOXMESSAGE];
                _navthatwillrefresh = @"inbox-message";
                break;
            }
            
            //delete forever
            case 13 : {
                [self messageaction:KTKPDMESSAGE_ACTIONDELETEFOREVERMESSAGE];
//                _navthatwillrefresh = @"inbox-message-forever";
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
    [_table endUpdates];
    
    [self configureactionrestkit];
    [self doactionmessage:joinedArr withAction:action];
    [_messages_selected removeAllObjects];

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
        }
        
        
        if (_messages.count > indexPath.row ) {
            InboxMessageList *list = _messages[indexPath.row];
            
            ((InboxMessageCell*)cell).message_title.text = list.message_title;
            ((InboxMessageCell*)cell).message_create_time.text =list.message_create_time;
            ((InboxMessageCell*)cell).message_reply.text = list.message_reply;
            ((InboxMessageCell*)cell).multicheckbtn.tag = indexPath.row;
            ((InboxMessageCell*)cell).indexpath = indexPath;
            
            
            if([[_data objectForKey:@"nav"] isEqualToString:NAV_MESSAGE]) {
                if([list.message_read_status isEqualToString:@"1"]) {
                    ((InboxMessageCell*)cell).is_unread.hidden = YES;
                } else {
                    ((InboxMessageCell*)cell).is_unread.hidden = NO;
                }
            }
            
            
            if(_userinfo) {
                if(_userinfo[@"show_check"] && ![_userinfo[@"show_check"] isEqualToString:@"-1"]) {
                    ((InboxMessageCell*)cell).multicheckbtn.hidden = NO;
                    ((InboxMessageCell*)cell).multicheckbtn.imageView.image = [UIImage imageNamed:@"icon_checkmark_1.png"];
                    
                } else {
                    ((InboxMessageCell*)cell).multicheckbtn.hidden = YES;
                    [_messages_selected removeAllObjects];
                }
            }
            
            
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            UIImageView *thumb = ((InboxMessageCell*)cell).userimageview;
            thumb = [UIImageView circleimageview:thumb];
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
        }
        
        if ([_messages_selected containsObject:indexPath]) {
            //            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            ((InboxMessageCell*)cell).multicheckbtn.imageView.image = [UIImage imageNamed:@"icon_checkmark.png"];
        }
        else {
            //            cell.accessoryType = UITableViewCellAccessoryNone;
            ((InboxMessageCell*)cell).multicheckbtn.imageView.image = [UIImage imageNamed:@"icon_checkmark_1.png"];
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

#pragma mark - UITableViewDelegate

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
            
            [self loadData];
        } else {
            _table.tableFooterView = nil;
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
    //show OPTION move to trash forever + back to inbox
    } else if (selected_vc == 3){
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = NO;
        _inboxtrashview.hidden = YES;
        _iseditmode = YES;
    
    } else if (selected_vc == 2) {
        _inboxtrashview.hidden = NO;
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = YES;
        _iseditmode = YES;
    } else {
        _editarchiveview.hidden = YES;
        _inboxtrashforeverview.hidden = YES;
        _inboxtrashview.hidden = YES;
        _iseditmode = NO;
    }
    
    [_table reloadData];
}

-(void) showMessageWithFilter:(NSNotification*)notification {
    if (_request.isExecuting) return;
    _userinfo = notification.userInfo;
    
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
       _readstatus = @"all";
    } else {
        _readstatus = @"unread";
    }

    [self cancel];
    [_messages removeAllObjects];
    [_table reloadData];
    _table.tableFooterView = _footer;
    _page = 1;
    [self configureRestKit];
    [self loadData];
    
    [_table reloadData];
}

-(void) reloadVc:(NSNotification*)notification {

    if([[_data objectForKey:@"nav"] isEqualToString:notification.userInfo[@"vc"]] && !_isrefreshnav) {
        [_messages removeAllObjects];
        [_table reloadData];
        _table.tableFooterView = _footer;
        [self configureRestKit];
        [self loadData]; 
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

#pragma mark - Request and Mapping

- (void)configureRestKit {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
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
                                                 KTKPDMESSAGE_JSONDATAKEY
                                                 ]];

    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:KTKPDMESSAGE_PATHURL keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}


- (void)loadData {
    if (_request.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (_navthatwillrefresh || !_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONGETMESSAGE,
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE),
                            kTKPDHOME_APIPAGEKEY:@(_page),
                            KTKPDMESSAGE_FILTERKEY:_readstatus?_readstatus:@"",
                            KTKPDMESSAGE_KEYWORDKEY:_keyword?_keyword:@"",
                            KTKPDMESSAGE_NAVKEY:[_data objectForKey:@"nav"]
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGE_PATHURL parameters:param];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"disableButtonRead" object:nil userInfo:nil];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableButtonRead" object:nil userInfo:nil];
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

-(void)requesttimeout {
    
}

-(void) requestsuccess:(id)object withOperation:(NSOperationQueue*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    InboxMessage *inboxmessage = info;
    BOOL status = [inboxmessage.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestproceed:object];
    }
}

-(void) requestproceed:(id)object {
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        InboxMessage *inboxmessage = stat;
        BOOL status = [inboxmessage.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            [_messages addObjectsFromArray: inboxmessage.result.list];
            
            if (_messages.count >0) {
                _isnodata = NO;
                _urinext =  inboxmessage.result.paging.uri_next;
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
                
                _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
            } else {
                _isnodata = YES;
                _table.tableFooterView = nil;
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
                    _table.tableFooterView = nil;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
            
        }
    }
}

-(void)cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}


-(void) requestfailure:(id)error {
    
}




#pragma mark - Refresh Data
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
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
    [self configureRestKit];
    [self loadData];
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
    [self undoactionmessage];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    _searchbar.text = nil;
    _keyword = _searchbar.text;
    _page = 1;
    
    [_messages removeAllObjects];

    [self configureRestKit];
    [self loadData];
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:KTKPDMESSAGEPRODUCTACTION_PATHURL keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerarchive addResponseDescriptor:responseDescriptorStatus];
}

- (void) doactionmessage:(id)data withAction:(id)action{
    NSString *deleted_json_info = data;
    
    if (_requestarchive.isExecuting) return;
    
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:action,
                            KTKPDMESSAGE_DATAELEMENTKEY : deleted_json_info,
                            };
    
    _requestarchivecount ++;
    _requestarchive = [_objectmanagerarchive appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGEPRODUCTACTION_PATHURL parameters:param];
    
    
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
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_navthatwillrefresh, @"vc", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
        } else {
            [self undoactionmessage];
        }
    }
    
    
    
    
}

-(void) requestactionfailure:(id)error {
    [self undoactionmessage];
    [self cancel];
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
        vc.data = @{KTKPDMESSAGE_IDKEY : list.message_id,
                    KTKPDMESSAGE_TITLEKEY : list.message_title,
                    KTKPDMESSAGE_NAVKEY : [_data objectForKey:@"nav"],
                    MESSAGE_INDEX_PATH : indexpath
                    };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
