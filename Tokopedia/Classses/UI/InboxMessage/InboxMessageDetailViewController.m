//
//  InboxMessageDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailViewController.h"
#import "InboxMessageDetailCell.h"
#import "InboxMessageDetail.h"
#import "InboxMessageAction.h"
#import "inbox.h"
#import "stringhome.h"
#import "HPGrowingTextView.h"
#import "inbox.h"

@interface InboxMessageDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, HPGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIView *messagingview;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonloadmore;
@property (weak, nonatomic) IBOutlet UIButton *buttonsend;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *titlebetween;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;


@end

@implementation InboxMessageDetailViewController {
    BOOL _isnodata;
    BOOL _isrefreshview;
    BOOL _ismorebuttonview;
    
    NSMutableArray *_messages;
    HPGrowingTextView *_growingtextview;
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSInteger _requestsendcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectmanageraction;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestsend;
    NSOperationQueue *_operationQueue;
}


#pragma mark - UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    
    _messages = [NSMutableArray new];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];		
    }
    

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //initiate back button
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    _operationQueue = [NSOperationQueue new];
    _page = 1;
    
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableHeaderView = _header;
    [_act startAnimating];
    
    if (_messages.count > 0) {
        _isnodata = NO;
    }
    
    _titlelabel.text = [_data objectForKey:KTKPDMESSAGE_TITLEKEY];
    _titlebetween.text = nil;
    
    [self setMessagingView];

    
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
    
}

- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMessagingView {
    _growingtextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 5, 265, 45)];
//    [_growingtextview becomeFirstResponder];
    _growingtextview.isScrollable = NO;
    _growingtextview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _growingtextview.minNumberOfLines = 1;
    _growingtextview.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _growingtextview.returnKeyType = UIReturnKeyGo; //just as an example
//    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    _growingtextview.delegate = self;
    _growingtextview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _growingtextview.backgroundColor = [UIColor whiteColor];
    _growingtextview.placeholder = @"Kirim pesanmu di sini..";
    
    [_messagingview addSubview:_growingtextview];
    _messagingview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _messages.count;
#else
    return _isnodata ? 0 : _messages.count;
#endif
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"messagingCell";
    
    InboxMessageDetailCell * cell = (InboxMessageDetailCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        cell = [[InboxMessageDetailCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)configureCell:(id)cell atIndexPath:(NSIndexPath*)indexPath {
    InboxMessageDetailCell* ccell = (InboxMessageDetailCell*)cell;
    
    if(_messages.count > indexPath.row) {
        InboxMessageDetailList *messagedetaillist = _messages[indexPath.row];
        
        ccell.messageLabel.text = messagedetaillist.message_reply;
        ccell.timeLabel.text = messagedetaillist.message_reply_time_fmt;
        
        if([messagedetaillist.message_action isEqualToString:@"1"]) {
            ccell.sent = YES;
//            ccell.avatarImageView.image = [UIImage imageNamed:@"pesrson1"];
        } else {
            ccell.sent = NO;
//            ccell.avatarImageView.image = [UIImage imageNamed:@"person1"];
        }
        
        if(messagedetaillist.is_not_delivered) {
            ccell.avatarImageView.image = [UIImage imageNamed:@"icon_report.png"];
        } else {
            ccell.avatarImageView.image = nil;
        }
    }

    
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_isnodata) {
//        cell.backgroundColor = [UIColor whiteColor];
//    }
//    
//    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
//    if (row == indexPath.row) {
//        NSLog(@"%@", NSStringFromSelector(_cmd));
//        
//        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
//            /** called if need to load next page **/
//            //NSLog(@"%@", NSStringFromSelector(_cmd));
//            [self configureRestKit];
//            [self loadData];
//        }
//    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxMessageDetailList *messagedetaillist = _messages[indexPath.row];
    CGSize messageSize = [InboxMessageDetailCell messageSize:messagedetaillist.message_reply];
    
    return messageSize.height + 2*[InboxMessageDetailCell textMarginVertical] + 20.0f;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_growingtextview resignFirstResponder];
}



#pragma mark - Request and Mapping
- (void) configureRestKit {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxMessageDetail class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APIURINEXTKEY:kTKPDHOME_APIURINEXTKEY}];

    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 KTKPDMESSAGE_ACTIONKEY,
                                                 KTKPDMESSAGE_CREATEBYKEY,
                                                 KTKPDMESSAGE_REPLYKEY,
                                                 KTKPDMESSAGE_REPLYIDKEY
                                                 KTKPDMESSAGE_BUTTONSPAMKEY,
                                                 KTKPDMESSAGE_REPLYTIMEKEY,
                                                 KTKPDMESSAGE_ISMODKEY,
                                                 KTKPDMESSAGE_USERIDKEY,
                                                 KTKPDMESSAGE_USERNAMEKEY,
                                                 KTKPDMESSAGE_USERIMAGEKEY
                                                 ]];
    
    RKObjectMapping *betweenMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailBetween class]];
    [betweenMapping addAttributeMappingsFromArray:@[
                                                     KTKPDMESSAGE_USERIDKEY,
                                                     KTKPDMESSAGE_USERNAMEKEY
                                                     ]];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *betweenRel = [RKRelationshipMapping relationshipMappingFromKeyPath:KTKPDMESSAGE_BETWEENCONVERSATIONKEY toKeyPath:KTKPDMESSAGE_BETWEENCONVERSATIONKEY withMapping:betweenMapping];
    [resultMapping addPropertyMapping:betweenRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:KTKPDMESSAGE_PATHURL
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];

}



- (void) loadData {
    if (_request.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (!_isrefreshview) {
        _table.tableHeaderView = _header;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONGETDETAIL,
                            kTKPDHOME_APIPAGEKEY : @(_page),
                            kTKPDHOME_APILIMITPAGEKEY : KTKPDMESSAGE_LIMITVALUE,
                            KTKPDMESSAGE_IDKEY:[_data objectForKey:KTKPDMESSAGE_IDKEY],
                            KTKPDMESSAGE_NAVKEY : [_data objectForKey:KTKPDMESSAGE_NAVKEY],
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGE_PATHURL parameters:param];
    
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
      
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
//        [self requestfailure:error];

        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

    
}

- (void)requestsendmessage:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    InboxMessageAction *inboxmessageaction = info;
    BOOL status = [inboxmessageaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        //if success
        if([inboxmessageaction.result.is_success isEqualToString:@"0"]) {
            InboxMessageDetailList *msg = _messages[_messages.count-1];
            msg.is_not_delivered = @"1";
        }
    }
    
}

- (void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    InboxMessageDetail *messagelist = info;
    
    BOOL status = [messagelist.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        
        
        if(_page > 1) {
            NSMutableArray *_loadedmessages;
            _loadedmessages = [NSMutableArray new];
            
            NSArray* reversedArray = [[messagelist.result.list reverseObjectEnumerator] allObjects];
            [_loadedmessages addObjectsFromArray: reversedArray];
            [_loadedmessages addObjectsFromArray:_messages];
            [_messages removeAllObjects];
            [_messages addObjectsFromArray:_loadedmessages];
        } else {
            NSArray* reversedArray = [[messagelist.result.list reverseObjectEnumerator] allObjects];
            [_messages addObjectsFromArray: reversedArray];
            
            NSArray *between = messagelist.result.conversation_between;
            NSMutableArray *between_name;
            between_name = [NSMutableArray new];
            
            for(int i=0;i<between.count;i++) {
                InboxMessageDetailBetween *m_between = between[i];
                [between_name addObject:m_between.user_name];
            }
            NSString *joinedString = [between_name componentsJoinedByString:@","];
            NSString *btw = [NSString stringWithFormat:@"%@ : %@", @"Between", joinedString];
            
            _titlebetween.text = btw;
            
            [_table setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        }
        
        if (_messages.count >0) {
            _isnodata = NO;
            _urinext =  messagelist.result.paging.uri_next;

            if([_urinext isEqualToString:@"0"]) {
                [self hidebuttonmore:YES];
            } else {
                [self showbuttonmore];
            }
            
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
    } else {
        [self cancel];
        NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
        if ([(NSError*)object code] == NSURLErrorCancelled) {
            if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                _table.tableHeaderView = _footer;
                [_act startAnimating];
                [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            }
            else
            {
                [_act stopAnimating];
                _table.tableHeaderView = nil;
            }
        }
        else
        {
            [_act stopAnimating];
            _table.tableHeaderView = nil;
        }
    }
}



- (void)requesttimeout {
    
}

- (void) cancel {
    
}

#pragma mark - IBAction
- (IBAction)tap :(id)sender {
//    [_growingtextview resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:{
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
        
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        
        switch (btn.tag) {
            case 10: {
                [self hidebuttonmore:NO];
                [self configureRestKit];
                [self loadData];
                break;
            }
                
            case 11: {
                if(_growingtextview.text.length > 0) {
                    NSInteger lastindexpathrow = [_messages count];
                    
//                    NSMutableArray =  addObjectsFromArray
                    InboxMessageDetailList *sendmessage = [InboxMessageDetailList new];
                    sendmessage.message_reply = _growingtextview.text;
                    
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:m"];
                    NSString *dateString = [dateFormat stringFromDate:today];
                    
                    sendmessage.message_reply_time_fmt = [dateString stringByAppendingString:@"WIB"];
                    sendmessage.message_action = @"1";
                    
                    [_messages insertObject:sendmessage atIndex:lastindexpathrow];
                    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                                 [NSIndexPath indexPathForRow:lastindexpathrow inSection:0],nil
                                                 ];
                    
                    [_table beginUpdates];
                    [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                    [_table endUpdates];
                    
                    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastindexpathrow inSection:0];
                    [_table scrollToRowAtIndexPath:indexpath
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
                    
                    [self configureActionRestkit];
                    [self doSendMessage:_growingtextview.text];
                    
                    _growingtextview.text = nil;
                }
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - UITextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _messagingview.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    
    _messagingview.frame = r;
}


-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height - 65);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    // set views with new info
    self.view.frame = containerFrame;
    
    [_messagingview becomeFirstResponder];
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    self.view.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height + 65;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.view.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - action
-(void) configureActionRestkit {
    _objectmanageraction =  [RKObjectManager sharedClient];
    
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
    
    [_objectmanageraction addResponseDescriptor:responseDescriptorStatus];
}

- (void) showbuttonmore {
    [_act stopAnimating];
    _buttonloadmore.hidden = NO;
}

- (void) hidebuttonmore:(bool)alsohideact
{
    if(alsohideact) {
        [_act stopAnimating];
    } else {
        [_act startAnimating];
    }
    _buttonloadmore.hidden = YES;
}

-(void) doSendMessage:(id)message_reply {
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONREPLYMESSAGE,
                            kTKPDHOME_APIMESSAGEREPLYKEY:message_reply,
                            KTKPDMESSAGE_IDKEY:[_data objectForKey:KTKPDMESSAGE_IDKEY],
                            
                            };
    
    _requestsendcount ++;
    _requestsend = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGEPRODUCTACTION_PATHURL parameters:param];
    
    NSDictionary *userinfo;
    userinfo = @{MESSAGE_INDEX_PATH : [_data objectForKey:MESSAGE_INDEX_PATH], KTKPDMESSAGE_MESSAGEREPLYKEY : _growingtextview.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageWithIndex" object:nil userInfo:userinfo];
    
    [_requestsend setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsendmessage:mappingResult withOperation:operation];
        
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
//                [self requestfailure:error];
        
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];

    [_operationQueue addOperation:_requestsend];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestsendtimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestsendtimeout {
    
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
