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
#import "string_inbox_message.h"
#import "string_home.h"
#import "inbox.h"
#import "detail.h"
#import "NavigateViewController.h"
#import "TagManagerHandler.h"
#import "NavigationHelper.h"
#import "Tokopedia-Swift.h"

@interface InboxMessageDetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIView *messagingview;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonloadmore;
@property (weak, nonatomic) IBOutlet UIButton *buttonsend;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet RSKGrowingTextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *participantsLabel;


@end

@implementation InboxMessageDetailViewController {
    BOOL _isnodata;
    BOOL _isrefreshview;

    NSMutableArray *_messages;
    
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    NSInteger _requestsendcount;
    NSTimer *_timer;
    
    NSString *_messageBaseUrl;
    NSString *_messagePostUrl;
    NSString *_messageActionBaseUrl;
    NSString *_messageActionPostUrl;

    TokopediaNetworkManager *_fetchConversationNetworkManager;

    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectmanageraction;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestsend;
    NSOperationQueue *_operationQueue;
    TAGContainer *_gtmContainer;
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

    _fetchConversationNetworkManager = [TokopediaNetworkManager new];

    _textView.delegate = self;
    
    if (_data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"markAsReadMessage" object:nil userInfo:@{@"index_path" : [_data objectForKey:@"index_path"], @"read_status" : @"1"}];
        
        [_act startAnimating];
    } else {
        _messagingview.hidden = YES;
        [_refreshControl endRefreshing];
        [_act stopAnimating];
    }

    _operationQueue = [NSOperationQueue new];
    _page = 1;
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    _table.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    /** set table footer view (loading act) **/
    _table.tableHeaderView = _header;
    
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    TagManagerHandler *gtmHandler = [TagManagerHandler new];
    [gtmHandler pushDataLayer:@{@"user_id" : [_userManager getUserId]}];
    
    _messageBaseUrl = [[self gtmContainer] stringForKey:GTMKeyInboxMessageBase];
    _messagePostUrl = [[self gtmContainer] stringForKey:GTMKeyInboxMessagePost];
    _messageActionBaseUrl = [[self gtmContainer] stringForKey:GTMKeyActionInboxMessageBase];
    _messageActionPostUrl = [[self gtmContainer] stringForKey:GTMKeyActionInboxMessagePost];
    
    if (_messages.count > 0) {
        _isnodata = NO;
    }
    
    _buttonsend.enabled = NO;
    
    [self setMessagingView];
//    self.navigationController.navigationBar.backItem.backBarButtonItem.title = @"";
//    self.navigationController.navigationItem.backBarButtonItem = nil;
    self.navigationItem.titleView = _titleView;

    if (_data) {
        [self fetchInboxMessageConversations];
    }
}

-(TAGContainer *)gtmContainer {
    if (!_gtmContainer) {
        _gtmContainer = [TagManagerHandler getContainer];
    }
    return _gtmContainer;
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
}

- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [_request cancel];
    [_operationQueue cancelAllOperations];
    [_timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMessagingView {
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;

    _messagingview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data? _messages.count:0;
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

- (NSString *)stringReplaceAhrefWithUrl:(NSString *)string
{
    NSString *leadingTrailingWhiteSpacesPattern = @"<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:leadingTrailingWhiteSpacesPattern options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSRange stringRange = NSMakeRange(0, string.length);
    NSString *trimmedString = [regex stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:stringRange withTemplate:@"$1"];
    
    return trimmedString;
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
        string = [self stringReplaceAhrefWithUrl:string];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        
        cell.messageLabel.attributedText = attributedText;
//        cell.messageLabel.text = message.message_reply;
        UITapGestureRecognizer *tapUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser:)];

        [cell.avatarImageView addGestureRecognizer:tapUser];
        [cell.avatarImageView setUserInteractionEnabled:[NavigationHelper shouldDoDeepNavigation]];
        cell.avatarImageView.tag = [message.user_id integerValue];
        cell.viewLabelUser.text = message.user_name;
        
        //Set user label
//        if([message.user_label isEqualToString:CPenjual]) {
//            [cell.viewLabelUser setColor:CTagPenjual];
//        }
//        else if([message.user_label isEqualToString:CPembeli]) {
//            [cell.viewLabelUser setColor:CTagPembeli];
//        }
//        else if([message.user_label isEqualToString:CAdministrator]) {
//            [cell.viewLabelUser setColor:CTagAdministrator];
//        }
//        else if([message.user_label isEqualToString:CPengguna]) {
//            [cell.viewLabelUser setColor:CTagPengguna];
//        }
        [cell.viewLabelUser setLabelBackground:message.user_label];

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
    if(! [messagedetaillist.message_action isEqualToString:@"1"]) {
        messageSize.height += CHeightUserLabel;
    }
    
    return messageSize.height + 2*[InboxMessageDetailCell textMarginVertical] + 30.0f;
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

- (void)requestsuccess:(RKMappingResult *)object {
    NSDictionary *result = object.dictionary;
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
            [_messages removeAllObjects];
            NSArray* reversedArray = [[messagelist.result.list reverseObjectEnumerator] allObjects];
            [_messages addObjectsFromArray: reversedArray];
            
            NSArray *between = messagelist.result.conversation_between?:@[];
            NSMutableArray *between_name;
            between_name = [NSMutableArray new];
            
            for(int i=0;i<between.count;i++) {
                InboxMessageDetailBetween *m_between = between[i];
                [between_name addObject:m_between.user_name?:@""];
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

            _titleLabel.text = [_data objectForKey:KTKPDMESSAGE_TITLEKEY];
            _participantsLabel.text = btw;

            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
            [attributedText addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize: 16.0f]
                                   range:NSMakeRange(0, [[_data objectForKey:KTKPDMESSAGE_TITLEKEY] length])];

            
            label.attributedText = attributedText;

            [_table setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        }
        
        if (_messages.count >0) {
            _isnodata = NO;
            _urinext =  messagelist.result.paging.uri_next;

            if([_urinext isEqualToString:@"0"] || !_urinext) {
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

                [self performSelector:@selector(fetchInboxMessageConversations)
                           withObject:nil
                           afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
                [self fetchInboxMessageConversations];
                break;
            }
                
            case 11: {
                NSString *message = [_textView.text stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceCharacterSet]];
                if(message.length > 5) {
                    NSInteger lastindexpathrow = [_messages count];
                    
                    InboxMessageDetailList *sendmessage = [InboxMessageDetailList new];
                    sendmessage.message_reply = _textView.text;
                    
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
                    [self doSendMessage:_textView.text];
                    
                    _textView.text = nil;
                    [self adjustButtonSendAvailability];
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

- (void)fetchInboxMessageConversations {
    if (!_isrefreshview) {
        _table.tableHeaderView = _header;
        [_act startAnimating];
    }

    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:KTKPDMESSAGE_ACTIONGETDETAIL,
            kTKPDHOME_APIPAGEKEY : @(_page),
            kTKPDHOME_APILIMITPAGEKEY : KTKPDMESSAGE_LIMITVALUE,
            KTKPDMESSAGE_IDKEY:[_data objectForKey:KTKPDMESSAGE_IDKEY]?:@"",
            KTKPDMESSAGE_NAVKEY : [_data objectForKey:KTKPDMESSAGE_NAVKEY]?:@"",
    };

    [_fetchConversationNetworkManager requestWithBaseUrl:[NSString basicUrl]
                                                    path:KTKPDMESSAGE_PATHURL
                                                  method:RKRequestMethodPOST
                                               parameter:param
                                                 mapping:[InboxMessageDetail mapping]
                                               onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                   [self requestsuccess:successResult];

                                                   [_table reloadData];
                                                   _isrefreshview = NO;
                                                   [_refreshControl endRefreshing];
                                               }
                                               onFailure:^(NSError *errorResult) {
                                                   _table.tableFooterView = nil;
                                                   _isrefreshview = NO;
                                                   [_refreshControl endRefreshing];
                                               }];
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = note.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _messageViewBottomConstraint.constant = keyboardBounds.size.height;
    [self.view layoutIfNeeded];

    [_messagingview becomeFirstResponder];
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = note.userInfo[UIKeyboardAnimationCurveUserInfoKey];

    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];


    _messageViewBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];

    [_messagingview becomeFirstResponder];
    [UIView commitAnimations];
}

#pragma mark - action
-(void) configureActionRestkit {
    if([_messageActionBaseUrl isEqualToString:kTkpdBaseURLString] || [_messageActionBaseUrl isEqualToString:@""]) {
        _objectmanageraction = [RKObjectManager sharedClient];
    } else {
        _objectmanageraction = [RKObjectManager sharedClient:_messageBaseUrl];
    }
    
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
                                                                                             pathPattern:[_messageActionPostUrl isEqualToString:@""] ? KTKPDMESSAGEPRODUCTACTION_PATHURL : _messageActionPostUrl
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanageraction addResponseDescriptor:responseDescriptorStatus];
}

- (void) showbuttonmore {
    [_act stopAnimating];
    
    _table.tableHeaderView = _header;
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
    _requestsend = [_objectmanageraction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[_messageActionPostUrl isEqualToString:@""] ? KTKPDMESSAGEPRODUCTACTION_PATHURL : _messageActionPostUrl parameters:[param encrypt]];

    if (_onMessagePosted) {
        _onMessagePosted(_textView.text);
    }

    [_textView resignFirstResponder];
    
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

#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    [self adjustButtonSendAvailability];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_table scrollToBottomAnimated:YES];
}

- (void)adjustButtonSendAvailability {
    NSString *message = [_textView.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    _buttonsend.enabled = message.length > 5;
}

#pragma mark - Tap User
- (void)tapUser:(id)sender{
    NavigateViewController *navigateController = [NavigateViewController new];
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSString *userId = [NSString stringWithFormat:@"%ld", (long)tap.view.tag];
    [navigateController navigateToProfileFromViewController:self withUserID:userId];
}

@end
