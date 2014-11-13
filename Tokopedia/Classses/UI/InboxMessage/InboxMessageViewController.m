//
//  InboxMessageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageViewController.h"
#import "InboxMessage.h"
#import "inbox.h"
#import "home.h"
#import "InboxMessageCell.h"
#import "TKPDTabInboxMessageNavigationController.h"


@interface InboxMessageViewController () <UITableViewDataSource, UITableViewDelegate, InboxMessageCellDelegate, TKPDTabInboxMessageNavigationControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *editarchiveview;
@property (weak, nonatomic) IBOutlet UIView *trashinboxview;

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *messages_selected;


@property (weak, nonatomic) IBOutlet UIButton *buttontrash;
@property (weak, nonatomic) IBOutlet UIButton *buttonarchive;


@end

@implementation InboxMessageViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
}



#pragma mark - Initialization

-(void) showCheckmark:(NSNotification*)notification {
    _userinfo = notification.userInfo;
    //show move to archive + trash
    if([_userinfo[@"show_check"] isEqualToString:@"0"] || [_userinfo[@"show_check"] isEqualToString:@"1"]) {
        _editarchiveview.hidden = NO;
        _trashinboxview.hidden = YES;
    //show move to trash forever + back to inbox
    } else if ([_userinfo[@"show_check"] isEqualToString:@"2"] || [_userinfo[@"show_check"] isEqualToString:@"3"]){
        _editarchiveview.hidden = YES;
        _trashinboxview.hidden = NO;
    } else {
        _editarchiveview.hidden = YES;
        _trashinboxview.hidden = YES;
    }
    
    [_table reloadData];
}

-(void) showRead:(NSNotification*)notification {
    if (_request.isExecuting) return;
    _userinfo = notification.userInfo;
    if([_userinfo[@"show_read"] isEqualToString:@"1"]) {
       _readstatus = @"all";
    } else {
        _readstatus = @"unread";
    }

    [self cancel];
    [self refreshView:nil];
    
    [_table reloadData];
}

-(void) reloadVc:(NSNotification*)notification {
//    _userinfo = notification.userInfo;
    if([[_data objectForKey:@"nav"] isEqualToString:notification.userInfo[@"vc"]]) {
        [self refreshView:nil];
        [_table reloadData];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _messages = [NSMutableArray new];
    _messages_selected = [NSMutableArray new];
    
    /** set first page become 1 **/
    _page = 1;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckmark:)
                                                 name:@"test"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRead:)
                                                 name:@"showRead"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadVc:)
                                                 name:@"reloadvc"
                                               object:nil];
    
    
    if (!_isrefreshview) {
        [self configureRestKit];
        
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
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
                                                 KTKPDMESSAGE_USERIMAGEKEY
                                                 ]];

    

    
    //relation
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
    if (!_isrefreshview) {
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
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
//        [_act stopAnimating];
//        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        //[_act stopAnimating];
//        _table.tableFooterView = nil;
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
        
//        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHISTORYPRODUCT_APIRESPONSEFILE];
//        NSError *error;
//        BOOL success = [result writeToFile:path atomically:YES];
//        if (!success) {
//            NSLog(@"writeToFile failed with error %@", error);
//        }
        
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

#pragma mark - Table View Data Source
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
            
//            if([list.message_read_status isEqualToString:@"1"]) {
//                ((InboxMessageCell*)cell).is_unread.hidden = NO;
//            } else {
//                ((InboxMessageCell*)cell).is_unread.hidden = YES;
//            }
//            
            if(_userinfo) {
                if(![_userinfo[@"show_check"] isEqualToString:@"-1"]) {
                    ((InboxMessageCell*)cell).multicheckbtn.hidden = NO;
                    ((InboxMessageCell*)cell).multicheckbtn.imageView.image = [UIImage imageNamed:@"icon_checkmark_1.png"];

                    
//                    [UIView animateWithDuration:0.5
//                                          delay:0
//                                        options: UIViewAnimationCurveEaseOut
//                                     animations:^{
//                                         CGRect frame = ((InboxMessageCell*)cell).movingview.frame;
//                                         frame.origin.x = 100;
//                                         
//                                         [((InboxMessageCell*)cell).movingview setFrame:frame];
//                                     }
//                                     completion:^(BOOL finished){
//                                     }];
                    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //if you want only one cell to be selected use a local NSIndexPath property instead of array. and use the code below
    //self.selectedIndexPath = indexPath;
    
    //the below code will allow multiple selection
    if ([_messages_selected containsObject:indexPath]) {
        [_messages_selected removeObject:indexPath];
    }
    else  {
        [_messages_selected addObject:indexPath];
    }
    
    
    [tableView reloadData];
    
}

#pragma mark - Refresh Data
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_messages removeAllObjects];
    
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    [_messages_selected removeAllObjects];
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Table View Delegate
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doArchiveMessage:(id)data{
    
}

- (void) doTrashMessage:(id)data {
    
}

- (void) deleteAnimation:(id)vc {
    NSIndexPath *item;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 1;
    
    for (item in _messages_selected) {
        [discardedItems addIndex:item.row];
        index++;
    }
    
    [_messages removeObjectsAtIndexes:discardedItems];
    
    NSString *joinedArr = [arr componentsJoinedByString:@"/and/"];
    
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:_messages_selected withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    
    [_messages_selected removeAllObjects];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:vc, @"vc", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadvc" object:nil userInfo:dict];
}

- (IBAction)tap:(id)sender {
    [_searchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
//            archive
            case 10: {
                [self deleteAnimation:@"inbox-message-archive"];
                
                break;
            }
//            trash
            case 11 : {
                [self deleteAnimation:@"inbox-message-trash"];
                break;
            }
                
                
            case 12 : {
                [self deleteAnimation:@"inbox-message"];
                break;
            }
                
            case 13 : {
                [self deleteAnimation:@""];
                break;
            }
            case 15 : {
                
                
            }
            default:
                break;
        }
        
    }
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
    [self refreshView:nil];
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
