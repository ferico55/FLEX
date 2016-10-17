//
//  ProductTalkDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define CHeightUserLabel 21

#import "ShopReputation.h"
#import "CMPopTipView.h"
#import "ProductTalkDetailViewController.h"
#import "TalkComment.h"
#import "detail.h"
#import "GeneralTalkCommentCell.h"
#import "ProductTalkCommentAction.h"
#import "MGSwipeButton.h"
#import "GeneralAction.h"
#import "LoginViewController.h"

#import "ReportViewController.h"
#import "NavigateViewController.h"
#import "SmileyAndMedal.h"
#import "TalkList.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "WebViewController.h"

@import UITableView_FDTemplateLayoutCell;
#import "Tokopedia-Swift.h"

@interface ProductTalkDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UITextViewDelegate,
    MGSwipeTableCellDelegate,
    LoginViewDelegate,
    GeneralTalkCommentCellDelegate,
    SmileyDelegate,
    CMPopTipViewDelegate
>
{
    NSMutableArray *_list;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    NSString *_urinext;
    NSString *_urlPath;
    NSString *_urlAction;

    NSInteger _page;
    NSMutableDictionary *_datainput;
    NSString *_savedComment;
    CMPopTipView *cmPopTitpView;
    NSMutableDictionary *dictCell;

    IBOutlet RSKGrowingTextView *_growingtextview;

    NSMutableDictionary *_auth;
    UserAuthentificationManager *_userManager;
    NavigateViewController *_navigateController;
    NSString *_reportAction;
    BOOL _marksOpenedTalksAsRead;

    TokopediaNetworkManager *_talkCommentNetworkManager;
    TokopediaNetworkManager *_sendCommentNetworkManager;
    TokopediaNetworkManager *_deleteCommentNetworkManager;
    TokopediaNetworkManager *_reportNetworkManager;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *talkmessagelabel;
@property (weak, nonatomic) IBOutlet UILabel *talkcreatetimelabel;
@property (weak, nonatomic) IBOutlet ViewLabelUser *userButton;
@property (weak, nonatomic) IBOutlet UIImageView *talkuserimage;
@property (weak, nonatomic) IBOutlet UIImageView *talkProductImage;
@property (weak, nonatomic) IBOutlet UIView *talkInputView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *talkCommentButtonLarge;

@property (strong, nonatomic) NSDictionary *data;

@end

@implementation ProductTalkDetailViewController

#pragma mark - Initializations
-(id) initByMarkingOpenedTalkAsRead:(BOOL) marksOpenedTalkAsRead {
    self = [super init];
    _marksOpenedTalksAsRead = marksOpenedTalkAsRead;
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    

    
    if (self) {
        _marksOpenedTalksAsRead = NO;
        _enableDeepNavigation = YES;
        self.title = kTKPDTITLE_TALK;
    }
    
    if(self){
        _data = [NSMutableDictionary new];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];
    }

    return self;
}

#pragma mark - View Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_talkCommentNetworkManager requestCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self adjustSendButtonAvailability];
    [_table registerNib:[UINib nibWithNibName:@"GeneralTalkCommentCell" bundle:nil] forCellReuseIdentifier:kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER];


    _talkCommentNetworkManager = [TokopediaNetworkManager new];
    _talkCommentNetworkManager.isUsingHmac = YES;

    _sendCommentNetworkManager = [TokopediaNetworkManager new];
    _sendCommentNetworkManager.isUsingHmac = YES;

    _deleteCommentNetworkManager = [TokopediaNetworkManager new];
    _deleteCommentNetworkManager.isUsingHmac = YES;

    _reportNetworkManager = [TokopediaNetworkManager new];
    _reportNetworkManager.isUsingHmac = YES;

    _list = [NSMutableArray new];

    _datainput = [NSMutableDictionary new];
    _userManager = [UserAuthentificationManager new];
    _navigateController = [NavigateViewController new];

    _page = 1;
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    if(_marksOpenedTalksAsRead) {
        _urlPath = @"/v2/talk/inbox/detail";
        _urlAction = kTKPDDETAIL_APIGETINBOXDETAIL;
        
    } else {
        _urlPath = @"/v2/talk/comment";
        _urlAction = kTKPDDETAIL_APIGETCOMMENTBYTALKID;
    }
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    [_talkProductImage setUserInteractionEnabled: _enableDeepNavigation];


    _talkuserimage.layer.cornerRadius = _talkuserimage.bounds.size.width/2.0f;
    _talkuserimage.layer.masksToBounds = YES;
    
    //islogin
    if([_userManager isLogin]) {
        //isbanned product
        if(![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_DELETED] &&
           ![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_BANNED]
           ) {
        }
        else
        {
            _talkInputView.hidden = YES;
        }
    }

    _table.tableFooterView = _footer;

    _data = [self generateData];
    if([self shouldFetchDataAtBeginning]){
        [self fetchTalkComments];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Product Talk Detail Page"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self setHeaderData:_data];

    //called to prevent error on iOS 7, haven't found explanation why
    //if called on iOS 8 or above, this will mess up the layout
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.view layoutIfNeeded];
    }
}

- (NSDictionary *)generateData {
    if (!_talk || !_indexPath) return nil;

    return @{
            TKPD_TALK_MESSAGE:_talk.talk_message?:@0,
            TKPD_TALK_USER_IMG:_talk.talk_user_image?:@0,
            TKPD_TALK_CREATE_TIME:_talk.talk_create_time?:@0,
            TKPD_TALK_USER_NAME:_talk.talk_user_name?:@0,
            TKPD_TALK_ID:_talk.talk_id?:@0,
            TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%zd", _talk.talk_user_id]?:@0,
            TKPD_TALK_TOTAL_COMMENT : _talk.talk_total_comment?:@0,
            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : _talk.talk_product_id?:@0,
            TKPD_TALK_SHOP_ID:_talk.talk_shop_id?:@0,
            TKPD_TALK_PRODUCT_IMAGE:_talk.talk_product_image?:@"",
            TKPD_TALK_PRODUCT_NAME:_talk.talk_product_name?:@0,
            TKPD_TALK_PRODUCT_STATUS:_talk.talk_product_status?:@0,
            TKPD_TALK_USER_LABEL:_talk.talk_user_label?:@0,
            TKPD_TALK_REPUTATION_PERCENTAGE:_talk.talk_user_reputation?:@0,
            kTKPDDETAIL_DATAINDEXKEY : @(_indexPath.row)?:@0
    };
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER
                                    cacheByIndexPath:indexPath
                                       configuration:^(GeneralTalkCommentCell * cell) {
                                            cell.comment = _list[indexPath.row];
                                       }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GeneralTalkCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER];
    __weak __typeof(self) weakSelf = self;
    if (cell == nil) {
        cell = [GeneralTalkCommentCell newcell];
    }
    
    cell.delegate = self;
    cell.del = self;
    cell.onTapTalkWithUrl = ^(NSURL* url){
        WebViewController *controller = [[WebViewController alloc] init];
        controller.strURL = url.absoluteString;
        controller.strTitle = @"Mengarahkan...";
        controller.onTapLinkWithUrl = ^(NSURL* url) {
            if([url.absoluteString isEqualToString:@"https://www.tokopedia.com/"]) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        };
        
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };

    TalkCommentList *list = _list[indexPath.row];

    cell.comment = list;

    cell.btnReputation.tag = indexPath.row;

    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self fetchTalkComments];
        }
    }
    
    return cell;
}

#pragma mark - Methods

- (BOOL)shouldFetchDataAtBeginning{
    return (_talk != nil);
}

- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)resizeHeaderHeightToFitContent {
    [_header layoutIfNeeded];
    _talkmessagelabel.preferredMaxLayoutWidth = _talkmessagelabel.frame.size.width;
    
    CGFloat height = [_header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect headerFrame = _header.frame;
    headerFrame.size.height = height;
    _header.frame = headerFrame;
}

-(void)setHeaderData:(NSDictionary*)data
{
    if(!data || !data.count) {
        [_talkInputView setHidden:YES];
        [_header setHidden:YES];
        return;
    } else {
        [_header setHidden:NO];
        if([_userManager isLogin]) {
            if(![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_DELETED] &&
               ![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_BANNED]
               ) {
                [_talkInputView setHidden:NO];
            }
            [self adjustSendButtonAvailability];
        } else {
            [_talkInputView setHidden:YES];
        }
    }

    self.table.tableHeaderView = self.header;
    _talkmessagelabel.text = data[TKPD_TALK_MESSAGE];
    
    [self resizeHeaderHeightToFitContent];

    _talkcreatetimelabel.text = [data objectForKey:TKPD_TALK_CREATE_TIME];
    
    [_userButton setLabelBackground:[data objectForKey:TKPD_TALK_USER_LABEL]];
    [_userButton setText:[data objectForKey:TKPD_TALK_USER_NAME]];
    [_userButton setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont smallThemeMedium]];

    [_userButton setUserInteractionEnabled:_enableDeepNavigation];

    [_talkCommentButtonLarge setTitle:[NSString stringWithFormat:@"%@ Komentar",[data objectForKey:TKPD_TALK_TOTAL_COMMENT]] forState:UIControlStateNormal];
    
    if([data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]) {
        if(((ReputationDetail *)[data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).no_reputation!=nil && [((ReputationDetail *)[data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).no_reputation isEqualToString:@"1"]) {
            [btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
            [btnReputation setTitle:@"" forState:UIControlStateNormal];
        }
        else {
            [btnReputation setTitle:[NSString stringWithFormat:@"%@%%", ((ReputationDetail *)[data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).positive_percentage] forState:UIControlStateNormal];
        }
    }

    NSURL *userImageUrl = [NSURL URLWithString:[data objectForKey:TKPD_TALK_USER_IMG]];
    [_talkuserimage setImageWithURL:userImageUrl placeholderImage:[UIImage imageNamed:@"default-boy.png"]];
    _talkuserimage.userInteractionEnabled = _enableDeepNavigation;

    NSURL *productImageUrl = [NSURL URLWithString:[data objectForKey:TKPD_TALK_PRODUCT_IMAGE]];
    [_talkProductImage setImageWithURL:productImageUrl placeholderImage:[UIImage imageNamed:@"default-boy.png"]];

    _productNameLabel.text = [_data objectForKey:TKPD_TALK_PRODUCT_NAME];
    _productNameLabel.userInteractionEnabled = _enableDeepNavigation;
}

#pragma mark - Request and Mapping
- (void)cancel {
    [_talkCommentNetworkManager requestCancel];
}

- (void)onReceiveComment:(TalkComment *)comment {
    _urinext = comment.result.paging.uri_next;
    NSDictionary *queries = [self queryFromUri:_urinext];

    _page = [queries[kTKPDDETAIL_APIPAGEKEY] integerValue];

    NSArray *list = comment.result.list;
    [_list addObjectsFromArray:list];
    [_table reloadData];
}

- (NSDictionary *)queryFromUri:(NSString *)uri {
    NSURL *url = [NSURL URLWithString:uri];
    NSArray *keyValueQueries = [[url query] componentsSeparatedByString: @"&"];

    NSMutableDictionary *queries = [NSMutableDictionary new];
    [queries removeAllObjects];
    for (NSString *keyValuePair in keyValueQueries)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = pairComponents[0];
        NSString *value = pairComponents[1];

        queries[key] = value;
    }
    return queries;
}

-(void)requesttimeout {
    [self cancel];
}

#pragma mark - View Action

- (IBAction)tapProduct {
    if (!_enableDeepNavigation) {
        return;
    }
    
    if([[_data objectForKey:@"talk_product_status"] isEqualToString:@"1"]) {
        [_navigateController navigateToProductFromViewController:self withName:[_data objectForKey:TKPD_TALK_PRODUCT_NAME] withPrice:nil withId:[_data objectForKey:TKPD_TALK_PRODUCT_ID]?:[_data objectForKey:@"product_id"] withImageurl:[_data objectForKey:TKPD_TALK_PRODUCT_IMAGE] withShopName:nil];
    }
}

- (void)tapErrorComment {
    [self sendComment];
}

- (void)sendComment {
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIADDCOMMENTTALK,
                            TKPD_TALK_ID:[_data objectForKey:TKPD_TALK_ID],
                            kTKPDTALKCOMMENT_APITEXT: _growingtextview.text,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]
                            };

    [_sendCommentNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                              path:@"/v2/talk/comment/create"
                                            method:RKRequestMethodPOST
                                         parameter:param
                                           mapping:[ProductTalkCommentAction mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             [self onCommentSent:successResult commentAction:successResult.dictionary[@""]];
                                             [_table reloadData];
                                             [_refreshControl endRefreshing];
                                             [_act stopAnimating];
                                         }
                                         onFailure:^(NSError *errorResult) {
                                             _table.tableFooterView = nil;
                                             _isrefreshview = NO;
                                             [_refreshControl endRefreshing];
                                             [_act stopAnimating];
                                             [self putSendCommentBack];
                                         }];
}

- (IBAction)tapUser {
    NSString *userId = [_data objectForKey:@"user_id"];
    if(!userId) {
        userId = [_data objectForKey:@"talk_user_id"];
    }
    [_navigateController navigateToProfileFromViewController:self withUserID:userId];
}

- (IBAction)btnSendTapped {
    [AnalyticsManager trackEventName:@"clickProductDiscussion"
                            category:GA_EVENT_CATEGORY_INBOX_TALK
                              action:GA_EVENT_ACTION_SEND
                               label:_inboxTalkType];
    [self submitTalk];
}

- (void)submitTalk {
    NSInteger lastindexpathrow = [_list count];
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    if(_auth) {

        TalkCommentList *comment = [TalkCommentList new];
        comment.comment_user_id = [_userManager getUserId];
        comment.comment_user_name = [_auth objectForKey:@"full_name"];
        comment.comment_user_image = [_auth objectForKey:@"user_image"];
        comment.comment_message = _growingtextview.text;

        if ([_auth objectForKey:@"shop_id"]) {
            NSString* userShopId = [_userManager getShopId];

            if ([[_data objectForKey:@"talk_shop_id"] isEqualToString:userShopId]) {
                comment.comment_shop_name = [_auth objectForKey:@"shop_name"];
                comment.comment_shop_image = [_auth objectForKey:@"shop_avatar"];
                comment.comment_is_owner = @"1";
            }
            comment.comment_is_seller = @"1";
            comment.comment_user_label = @"Penjual";
        }

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMMM yyyy, HH:mm"];
        NSString *dateString = [dateFormat stringFromDate:today];

        comment.comment_create_time = dateString;
        comment.is_just_sent = YES;
        comment.comment_user_label = [_userManager isMyShopWithShopId:[_data objectForKey:TKPD_TALK_SHOP_ID]] ? @"Penjual" : @"Pengguna";
        comment.comment_user_reputation = _userManager.reputation;
        if(![_act isAnimating]) {
            [_list addObject:comment];
            [_table reloadData];

            [_act startAnimating];

            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastindexpathrow inSection:0];
            [_table scrollToRowAtIndexPath:indexpath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];

            //connect action to web service
            _savedComment = _growingtextview.text;
            [self sendComment];

            _growingtextview.text = nil;
            [self adjustSendButtonAvailability];
            [_growingtextview resignFirstResponder];
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sedang memuat komentar.."]
                                                                           delegate:self];
            [alert show];
        }

    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];


        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];

        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - Action Send Comment Talk

- (void)onCommentSent:(RKMappingResult *)object commentAction:(ProductTalkCommentAction *)commentAction {
    if([commentAction.result.is_success isEqualToString:@"0"]) {
        [self putSendCommentBack];

        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:commentAction.message_error
                                                                       delegate:self];
        [alert show];
    } else {
        NSString *totalcomment = [NSString stringWithFormat:@"%zd %@",_list.count, @"Komentar"];
        [_talkCommentButtonLarge setTitle:totalcomment forState:UIControlStateNormal];

        TalkCommentList *comment = _list[_list.count-1];
        comment.is_just_sent = NO;
        comment.comment_id = commentAction.result.comment_id;
        comment.comment_user_id = [_userManager getUserId];

        if([dictCell objectForKey:@"-1"]) {
            [dictCell removeObjectForKey:@"-1"];
        }

        NSDictionary *userInfo = @{
            TKPD_TALK_TOTAL_COMMENT  : @(_list.count)?:0,
            kTKPDDETAIL_DATAINDEXKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXKEY],
            TKPD_TALK_ID : [_data objectForKey:TKPD_TALK_ID]
        };

        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTotalComment"
                                                            object:nil
                                                          userInfo:userInfo];

    }
}

- (void)putSendCommentBack {
    _growingtextview.text = _savedComment;
    [self adjustSendButtonAvailability];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_list.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_list removeLastObject];
    [_table endUpdates];
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
    
    [_talkInputView becomeFirstResponder];
    // commit animations
    [UIView commitAnimations];
    
    if(_list.count > 0) {
        [_table scrollRectToVisible:CGRectMake(0, _table.contentSize.height-keyboardBounds.size.height, _table.bounds.size.width, _table.bounds.size.height) animated:YES];
    }
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - Swipe Delegate
-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{

    if([_userManager isLogin]) {
        return YES;
    }
    
    return NO;

}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    __weak __typeof(self) weakSelf = self;
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = [_table indexPathForCell:cell];
        TalkCommentList *list = _list[indexPath.row];
        if(list.comment_user_id == nil || list.comment_id == nil)
            return nil;
        
        [_datainput setObject:list.comment_id forKey:@"comment_id"];
        [_datainput setObject:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY] forKey:@"product_id"];
        
        if([[_userManager getUserId] isEqualToString:list.comment_user_id]){
            MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                [weakSelf deleteCommentTalkAtIndexPath:indexPath];
                return YES;
            }];
            
            return @[trash];
        }else{
            MGSwipeButton * report = [MGSwipeButton buttonWithTitle:@"Laporkan" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                _reportAction = @"report_comment_talk";
                ReportViewController *reportController = [ReportViewController new];
                
                reportController.onFinishWritingReport = ^(NSString *message) {
                    [weakSelf reportCommentWithMessage:message];
                };
                
                [weakSelf.navigationController pushViewController:reportController animated:YES];
                return YES;
            }];
            return @[report];

        }
        
    }
    
    return nil;
    
}

#pragma mark - Action Smiley
- (IBAction)actionSmiley:(id)sender {
    if([_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]) {
        if(! (((ReputationDetail *)[_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).no_reputation!=nil && [((ReputationDetail *)[_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).no_reputation isEqualToString:@"1"])) {
            int paddingRightLeftContent = 10;
            UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
            SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
            [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:((ReputationDetail *)[_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).neutral withRepSmile:((ReputationDetail *)[_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).positive withRepSad:((ReputationDetail *)[_data objectForKey:TKPD_TALK_REPUTATION_PERCENTAGE]).negative withDelegate:self];
            
            //Init pop up
            cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
            cmPopTitpView.delegate = self;
            cmPopTitpView.backgroundColor = [UIColor whiteColor];
            cmPopTitpView.animation = CMPopTipAnimationSlide;
            cmPopTitpView.dismissTapAnywhere = YES;
            cmPopTitpView.leftPopUp = YES;
            
            UIButton *button = (UIButton *)sender;
            [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];

        }
    }
}

#pragma mark - Action Delete Comment Talk
- (void)actionSmile:(id)sender {
    TalkCommentList *list = _list[((UIView *) sender).tag];
    
    if(list.comment_is_seller!=nil && [list.comment_is_seller isEqualToString:@"1"]) {
        NSString *strText = [NSString stringWithFormat:@"%@ %@", list.comment_shop_reputation.reputation_score==nil? @"0":list.comment_shop_reputation.reputation_score, CStringPoin];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
    }
    else {
        if(list.comment_user_reputation.no_reputation!=nil && [list.comment_user_reputation.no_reputation isEqualToString:@"0"]) {
            int paddingRightLeftContent = 10;
            UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
            
            SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
            [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.comment_user_reputation.neutral withRepSmile:list.comment_user_reputation.positive withRepSad:list.comment_user_reputation.negative withDelegate:self];
            
            //Init pop up
            cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
            cmPopTitpView.delegate = self;
            cmPopTitpView.backgroundColor = [UIColor whiteColor];
            cmPopTitpView.animation = CMPopTipAnimationSlide;
            cmPopTitpView.dismissTapAnywhere = YES;
            cmPopTitpView.leftPopUp = YES;
            
            UIButton *button = (UIButton *)sender;
            [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
        }
    }
}

- (void)deleteCommentTalkAtIndexPath:(NSIndexPath*)indexpath {
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationRight];
    [_table endUpdates];
    [self doDeleteCommentTalk:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

- (void)doDeleteCommentTalk:(id)object {
    NSDictionary *param = @{
            @"action" : @"delete_comment_talk",
            @"product_id" : [_datainput objectForKey:@"product_id"],
            @"comment_id" : [_datainput objectForKey:@"comment_id"],
            @"shop_id" : [_data objectForKey:@"talk_shop_id"],
            @"talk_id" : [_data objectForKey:@"talk_id"]
    };

    [_deleteCommentNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                                path:@"/v2/talk/comment/delete"
                                              method:RKRequestMethodPOST
                                           parameter:param
                                             mapping:[GeneralAction mapping]
                                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                               [self onCommentDeleted:successResult];

                                               [_table reloadData];
                                               [_refreshControl endRefreshing];
                                               [_act stopAnimating];
                                           }
                                           onFailure:^(NSError *errorResult) {
                                               [_act stopAnimating];
                                               _table.hidden = NO;
                                               _isrefreshview = NO;
                                               [_refreshControl endRefreshing];
                                               [_act stopAnimating];

                                               [self deleteCommentFailed];
                                           }];
}

- (void)deleteCommentFailed {
    [self cancelDeleteRow];
}

- (void)onCommentDeleted:(RKMappingResult *)object {
    NSDictionary *result = object.dictionary;
    GeneralAction *generalaction = [result objectForKey:@""];

    if(generalaction.message_error)
    {
        [self cancelDeleteRow];
        NSArray *array = generalaction.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
        [alert show];
    }
    
    if ([generalaction.data.is_success isEqualToString:@"1"]) {
        NSArray *array =  [[NSArray alloc] initWithObjects:CStringBerhasilMenghapusKomentarDiskusi, nil];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
        [stickyAlertView show];

        NSString *title = [NSString stringWithFormat:@"%d Komentar", (int) _list.count?:0];
        [_talkCommentButtonLarge setTitle:title
                                 forState:UIControlStateNormal];

        NSDictionary *userinfo = @{
                TKPD_TALK_TOTAL_COMMENT : @(_list.count)?:0,
                kTKPDDETAIL_DATAINDEXKEY:[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY],
                TKPD_TALK_ID : [_data objectForKey:TKPD_TALK_ID]
        };

        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTotalComment"
                                                            object:nil
                                                          userInfo:userinfo];
    }
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_talkCommentButtonLarge setTitle:[NSString stringWithFormat:@"%lu Komentar",(unsigned long)[_list count]] forState:UIControlStateNormal];
    [_table reloadData];
}


#pragma mark - Report Delegate

- (void)reportCommentWithMessage:(NSString *)textMessage {

    NSDictionary *parameter = @{
            @"action" : _reportAction,
            @"talk_id" : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
            @"talk_comment_id" : [_datainput objectForKey:@"comment_id"]?:@(0),
            @"product_id" : [_data objectForKey:@"product_id"],
            @"text_message": textMessage
    };

    [_reportNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                         path:@"/v2/talk/comment/report"
                                       method:RKRequestMethodPOST
                                    parameter:parameter
                                      mapping:[GeneralAction mapping]
                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                        [self.navigationController popToViewController:self animated:YES];

                                        // need to do dispatch because this view controller's window is nil until the report view controller
                                        // is popped from navigation stack
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            GeneralAction *action = successResult.dictionary[@""];
                                            if (action.data.is_success.boolValue) {
                                                StickyAlertView *alertView = [[StickyAlertView alloc] initWithSuccessMessages:@[SUCCESS_REPORT_TALK]
                                                                                                                     delegate:self];

                                                [alertView show];
                                            } else {
                                                StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                                                                                   delegate:self];

                                                [alertView show];
                                            }
                                        });

                                    }
                                    onFailure:^(NSError *errorResult) {

                                    }];
}

#pragma mark - LoginView Delegate

- (void)redirectViewController:(id)viewController {

}
#pragma mark - Notification Delegate

- (void)userDidLogin:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
}

- (void)userDidLogout:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
}
#pragma mark - CMPopTipView Delegate


- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}
#pragma mark - Smiley Delegate

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}

-(void)replaceDataSelected:(NSDictionary *)data
{
    _data = data;

    if (data) {
        _page = 1;
        [_list removeAllObjects];
        [_table reloadData];

        [self fetchTalkComments];
        [self setHeaderData:data];
    }
}

- (void)fetchTalkComments {
    [_act startAnimating];

    NSDictionary* param = @{
            kTKPDDETAIL_APIACTIONKEY : _urlAction ?:@"",
            TKPD_TALK_ID : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),
            kTKPDDETAIL_APIPAGEKEY : @(_page)
    };

    [_talkCommentNetworkManager requestWithBaseUrl:[NSString kunyitUrl]
                                              path:_urlPath
                                            method:RKRequestMethodGET
                                         parameter:param
                                           mapping:[TalkComment mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             [_act stopAnimating];
                                             _table.hidden = NO;
                                             _isrefreshview = NO;
                                             [_refreshControl endRefreshing];
                                             [self onReceiveComment:successResult.dictionary[@""]];
                                         }
                                         onFailure:^(NSError *errorResult) {
                                             [_act stopAnimating];
                                             _table.hidden = NO;
                                             _isrefreshview = NO;
                                             [_refreshControl endRefreshing];
                                         }];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self adjustSendButtonAvailability];
}

- (void)adjustSendButtonAvailability {
    NSString *text = [_growingtextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    _sendButton.enabled = text.length >= 5;
}

- (void)setTalk:(TalkList *)list {
    _talk = list;

    NSDictionary *data = @{
            TKPD_TALK_MESSAGE:list.talk_message?:@0,
            TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
            TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
            TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
            TKPD_TALK_ID:list.talk_id?:@0,
            TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%zd", list.talk_user_id]?:@0,
            TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : list.talk_product_id?:@0,
            TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
            TKPD_TALK_PRODUCT_IMAGE:list.talk_product_image?:@"",
            TKPD_TALK_PRODUCT_NAME:list.talk_product_name?:@0,
            TKPD_TALK_PRODUCT_STATUS:list.talk_product_status?:@0,
            TKPD_TALK_USER_LABEL:list.talk_user_label?:@0,
            TKPD_TALK_REPUTATION_PERCENTAGE:list.talk_user_reputation?:@0,
    };
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

@end
