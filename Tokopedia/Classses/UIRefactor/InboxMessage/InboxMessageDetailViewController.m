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
#import "string_home.h"
#import "HPGrowingTextView.h"
#import "inbox.h"
#import "detail.h"
#import "NavigateViewController.h"

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
    if (self != nil) {
        _isrefreshview = NO;
        _isnodata = YES;
        
        _messages = [NSMutableArray new];
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
    
    self.title = [_data objectForKey:KTKPDMESSAGE_TITLEKEY];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    _operationQueue = [NSOperationQueue new];
    _page = 1;
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    _table.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    /** set table footer view (loading act) **/
    _table.tableHeaderView = _header;
    [_act startAnimating];
    
    if (_messages.count > 0) {
        _isnodata = NO;
    }
    
    _buttonsend.enabled = NO;
    
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
    _growingtextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 10, 240, 45)];
    _growingtextview.isScrollable = NO;
    _growingtextview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _growingtextview.layer.borderWidth = 0.5f;
    _growingtextview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _growingtextview.layer.cornerRadius = 5;
    _growingtextview.layer.masksToBounds = YES;

    _growingtextview.minNumberOfLines = 1;
    _growingtextview.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _growingtextview.returnKeyType = UIReturnKeyGo; //just as an example
    _growingtextview.delegate = self;
    _growingtextview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _growingtextview.backgroundColor = [UIColor whiteColor];
    _growingtextview.placeholder = @"Kirim pesanmu di sini..";
    _growingtextview.enablesReturnKeyAutomatically = YES;
    
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
    
//    InboxMessageDetailCell * cell = (InboxMessageDetailCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[InboxMessageDetailCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)configureCell:(id)aCell atIndexPath:(NSIndexPath*)indexPath {
    InboxMessageDetailCell *cell = (InboxMessageDetailCell*)aCell;
    if(_messages.count > indexPath.row) {
        InboxMessageDetailList *message = _messages[indexPath.row];
        
        UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        style.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: font,
                                     NSParagraphStyleAttributeName: style,
                                     };
        NSString *string = message.message_reply;
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        
        cell.messageLabel.attributedText = attributedText;
//        cell.messageLabel.text = message.message_reply;
        UITapGestureRecognizer *tapUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser:)];

        [cell.avatarImageView addGestureRecognizer:tapUser];
        [cell.avatarImageView setUserInteractionEnabled:YES];
        cell.avatarImageView.tag = [message.user_id integerValue];

        if([message.message_action isEqualToString:@"1"]) {
            if(message.is_just_sent) {
                cell.timeLabel.text = @"Kirim...";
            } else {
                cell.timeLabel.text = message.message_reply_time_fmt;
            }
            
            cell.sent = YES;
            cell.avatarImageView.image = nil;
        } else {
            cell.sent = NO;
            cell.avatarImageView.image = nil;
            cell.messageLabel.textColor = [UIColor blackColor];
            cell.timeLabel.text = message.message_reply_time_fmt;
            
            if([message.user_image isEqualToString:@"0"]) {
                cell.avatarImageView.image = [UIImage imageNamed:@"default-boy.png"];
            } else {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:message.user_image]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                [cell.avatarImageView setImageWithURLRequest:request
                                            placeholderImage:[UIImage imageNamed:@"default-boy.png"]
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [cell.avatarImageView setImage:image];
                } failure:nil];
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxMessageDetailList *messagedetaillist = _messages[indexPath.row];
    CGSize messageSize = [InboxMessageDetailCell messageSize:messagedetaillist.message_reply];
    
    return messageSize.height + 2*[InboxMessageDetailCell textMarginVertical] + 30.0f;
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
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGE_PATHURL parameters:[param encrypt]];
    
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
      
        [_table reloadData];
        _isrefreshview = NO;
        _buttonsend.enabled = YES;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
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
        InboxMessageDetailList *msg = _messages[_messages.count-1];
        if([inboxmessageaction.result.is_success isEqualToString:@"0"]) {
            msg.is_not_delivered = @"1";
        } else {
            msg.is_just_sent = NO;
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
            
            NSString *btw;
            if (between_name.count == 2) {
                btw = [NSString stringWithFormat:@"Antara : %@ dan %@", between_name[1], between_name[0]];
            } else {
                btw = [NSString stringWithFormat:@"Antara : %@", [between_name componentsJoinedByString:@", "]];
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 206, 44)];
            label.numberOfLines = 2;
            label.font = [UIFont systemFontOfSize: 11.0f];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            
            NSString *title = [NSString stringWithFormat:@"%@\n%@", [_data objectForKey:KTKPDMESSAGE_TITLEKEY], btw];
            
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
            [attributedText addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize: 16.0f]
                                   range:NSMakeRange(0, [[_data objectForKey:KTKPDMESSAGE_TITLEKEY] length])];
            
            label.attributedText = attributedText;
            
            self.navigationItem.titleView = label;
            
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
                NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
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
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:{
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
                NSString *message = [_growingtextview.text stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceCharacterSet]];
                if(message.length > 5 || ![message isEqualToString:@""]) {
                    NSInteger lastindexpathrow = [_messages count];
                    
                    InboxMessageDetailList *sendmessage = [InboxMessageDetailList new];
                    sendmessage.message_reply = _growingtextview.text;
                    
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:m"];
                    NSString *dateString = [dateFormat stringFromDate:today];
                    
                    sendmessage.message_reply_time_fmt = [dateString stringByAppendingString:@"WIB"];
                    sendmessage.message_action = @"1";
                    sendmessage.is_just_sent = YES;
                    
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
                } else {
                    
                    NSArray *array = [[NSArray alloc] initWithObjects:KTKPDMESSAGE_EMPTYFORM5, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
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
    _table.tableHeaderView = nil;
}

-(void) doSendMessage:(id)message_reply {
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONREPLYMESSAGE,
                            kTKPDHOME_APIMESSAGEREPLYKEY:message_reply,
                            KTKPDMESSAGE_IDKEY:[_data objectForKey:KTKPDMESSAGE_IDKEY],
                            
                            };
    
    _requestsendcount ++;
    _requestsend = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:KTKPDMESSAGEPRODUCTACTION_PATHURL parameters:[param encrypt]];
    
    NSDictionary *userinfo;
    userinfo = @{MESSAGE_INDEX_PATH : [_data objectForKey:MESSAGE_INDEX_PATH], KTKPDMESSAGE_MESSAGEREPLYKEY : _growingtextview.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageWithIndex" object:nil userInfo:userinfo];
    [_growingtextview resignFirstResponder];
    
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

#pragma mark - Growing TextView Delegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    NSString *message = [growingTextView.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
    if([message length] < 5 || [message isEqualToString:@""]) {
        _buttonsend.enabled = NO;
        
    } else {
        _buttonsend.enabled = YES;
    }
}

#pragma mark - Tap User
- (void)tapUser:(id)sender{
    NavigateViewController *navigateController = [NavigateViewController new];
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)tap.view.tag];
    [navigateController navigateToProfileFromViewController:self withUserID:userId];
}

@end
