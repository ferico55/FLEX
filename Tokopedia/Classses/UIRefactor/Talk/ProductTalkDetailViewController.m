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
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"

#import "NavigationHelper.h"
#import "ShopBadgeLevel.h"

@interface ProductTalkDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UISplitViewControllerDelegate,
    UITextViewDelegate,
    MGSwipeTableCellDelegate,
    ReportViewControllerDelegate,
    LoginViewDelegate,
    GeneralTalkCommentCellDelegate,
    SmileyDelegate,
    CMPopTipViewDelegate
>
{
    BOOL _isnodata;
    NSMutableArray *_list;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    NSString *_urinext;
    NSString *_urlPath;
    NSString *_urlAction;
    
    NSTimer *_timer;
    NSInteger _page;
    NSInteger _limit;
    NSMutableDictionary *_datainput;
    NSString *_savedComment;
    CMPopTipView *cmPopTitpView;
    NSMutableDictionary *dictCell;

    NSInteger _requestcount;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSInteger _requestactioncount;
    __weak RKObjectManager *_objectSendCommentManager;
    __weak RKManagedObjectRequestOperation *_requestSendComment;
    
    NSInteger _requestDeleteCommentCount;
    __weak RKObjectManager *_objectDeleteCommentManager;
    __weak RKManagedObjectRequestOperation *_requestDeleteComment;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationSendCommentQueue;
    NSOperationQueue *_operationDeleteCommentQueue;
    TalkComment *_talkcomment;

    IBOutlet RSKGrowingTextView *_growingtextview;
    
    NSTimeInterval _timeinterval;
    NSMutableDictionary *_auth;
    UserAuthentificationManager *_userManager;
    NavigateViewController *_navigateController;
    NSString *_reportAction;
    BOOL _marksOpenedTalksAsRead;

    TokopediaNetworkManager *_talkCommentNetworkManager;
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
        _isnodata = YES;
        _marksOpenedTalksAsRead = NO;
        self.title = kTKPDTITLE_TALK;
    }
    
    if(self){
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

- (void)addBottomInsetWhen14inch {
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
}

#pragma mark - View Life Cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_talkCommentNetworkManager requestCancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self adjustSendButtonAvailability];

    _talkCommentNetworkManager = [TokopediaNetworkManager new];
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationSendCommentQueue = [NSOperationQueue new];
    _operationDeleteCommentQueue = [NSOperationQueue new];
    
    _datainput = [NSMutableDictionary new];
    _userManager = [UserAuthentificationManager new];
    _navigateController = [NavigateViewController new];

    _page = 1;
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];

    if(_marksOpenedTalksAsRead) {
        _urlPath = kTKPDINBOX_TALK_APIPATH;
        _urlAction = kTKPDDETAIL_APIGETINBOXDETAIL;
        
    } else {
        _urlPath = kTKPDDETAILTALK_APIPATH;
        _urlAction = kTKPDDETAIL_APIGETCOMMENTBYTALKID;
    }
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

        // add gesture to product image
    UITapGestureRecognizer* productGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct)];
    [_talkProductImage addGestureRecognizer:productGesture];
    [_talkProductImage setUserInteractionEnabled: [NavigationHelper shouldDoDeepNavigation]];


    _talkuserimage.layer.cornerRadius = _talkuserimage.bounds.size.width/2.0f;
    _talkuserimage.layer.masksToBounds = YES;
    
    //islogin
    if([_userManager isLogin]) {
        //isbanned product
        if(![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_DELETED] &&
           ![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_BANNED]
           ) {
            [self initTalkInputView];
        }
        else
        {
            _talkInputView.hidden = YES;
        }
    }
    
    [self fetchTalkComments];

    [self setHeaderData:_data];
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
    return _isnodata?0:_list.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TalkCommentList *list = _list[indexPath.row];

    GeneralTalkCommentCell *cell = [dictCell objectForKey:list.comment_id==nil? @"-1":list.comment_id];
    if (cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"GeneralTalkCommentCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        
        if(dictCell == nil) {
            dictCell = [NSMutableDictionary new];
        }
        
        [dictCell setObject:cell forKey:list.comment_id==nil? @"-1":list.comment_id];
    }

    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0f;
    NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:list.comment_message attributes:attributes];
    
    UILabel *tempLbl = [[UILabel alloc] init];
    tempLbl.numberOfLines = 0;
    [tempLbl setAttributedText:attributedString];
    [tableView addSubview:tempLbl];
    
    CGSize tempSizeComment = [tempLbl sizeThatFits:CGSizeMake(tableView.bounds.size.width-25-((GeneralTalkCommentCell *)cell).commentlabel.frame.origin.x, 9999)];//left space
    return ((GeneralTalkCommentCell *)cell).commentlabel.frame.origin.y + 27 + tempSizeComment.height;//27 bottom space
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellid = kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER;

    GeneralTalkCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralTalkCommentCell newcell];
        cell.delegate = self;
        cell.del = self;
        [cell.user_name setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:14.0f]];
    }

    if (_list.count > indexPath.row) {
        TalkCommentList *list = _list[indexPath.row];

        UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5.0f;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style};
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:list.comment_message
                                                                               attributes:attributes];
        cell.commentlabel.attributedText = attributedString;

        NSString *name = ([list.comment_user_label isEqualToString:@"Penjual"]) ? list.comment_shop_name : list.comment_user_name;
        cell.user_name.text = name;
        cell.create_time.text = list.comment_create_time;

        cell.indexpath = indexPath;
        cell.btnReputation.tag = indexPath.row;

        if([list.comment_user_label isEqualToString:@"Penjual"]) {//Seller
            [SmileyAndMedal generateMedalWithLevel:list.comment_shop_reputation.reputation_badge_object.level withSet:list.comment_shop_reputation.reputation_badge_object.set withImage:cell.btnReputation isLarge:NO];
            [cell.btnReputation setTitle:@"" forState:UIControlStateNormal];
        } else {
            if (_auth) {
                if (list.comment_user_reputation == nil && list.comment_user_id != nil) {
                    NSString *userId = [_userManager getUserId];
                    BOOL usersComment = [list.comment_user_id isEqualToString:userId];
                    if (usersComment) {
                        UserAuthentificationManager *user = [UserAuthentificationManager new];
                        list.comment_user_reputation = user.reputation;
                    }
                }
            }

            if(list.comment_user_reputation==nil || (list.comment_user_reputation.no_reputation!=nil && [list.comment_user_reputation.no_reputation isEqualToString:@"1"])) {
                [cell.btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [cell.btnReputation setTitle:@"" forState:UIControlStateNormal];
            }
            else {
                [cell.btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
                [cell.btnReputation setTitle:[NSString stringWithFormat:@"%@%%", (list.comment_user_reputation==nil? @"0":list.comment_user_reputation.positive_percentage)] forState:UIControlStateNormal];
            }
        }

        [cell.user_name setLabelBackground:list.comment_user_label];

        if(list.is_not_delivered) {
            cell.commentfailimage.hidden = NO;
            cell.create_time.text = @"Gagal Kirim.";

            UITapGestureRecognizer *errorSendCommentGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapErrorComment)];
            [cell.commentfailimage addGestureRecognizer:errorSendCommentGesture];
            [cell.commentfailimage setUserInteractionEnabled:YES];
        } else {
            cell.commentfailimage.hidden = YES;
        }

        if(list.is_just_sent) {
            cell.create_time.text = @"Kirim...";
        } else {
            cell.create_time.text = list.comment_create_time;
        }

        NSURL *url;
        if ([list.comment_user_label isEqualToString:@"Penjual"]) {
            url = [NSURL URLWithString:list.comment_shop_image];
        } else {
            url = [NSURL URLWithString:list.comment_user_image];
        }

        UIImageView *user_image = cell.user_image;
        user_image.image = nil;

        [user_image setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default-boy.png"]];

        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];

        return cell;
    }
    
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

-(void)setHeaderData:(NSDictionary*)data
{
    if(!data) {
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
            [_sendButton setEnabled:NO];
        } else {
            [_talkInputView setHidden:YES];
        }
    }

    CGFloat previouseLabelHeight = _talkmessagelabel.frame.size.height;
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;

    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:[data objectForKey:TKPD_TALK_MESSAGE]?:@""
                                                                                    attributes:attributes];
    _talkmessagelabel.attributedText = productNameAttributedText;
    _talkmessagelabel.textAlignment = NSTextAlignmentLeft;
    _talkmessagelabel.numberOfLines = 0;
    [_talkmessagelabel sizeToFit];

    CGFloat currentLabelHeight = _talkmessagelabel.frame.size.height;
    CGFloat paddingBottom = -20;
    // add 10 for padding bottom
    if (currentLabelHeight < 70) paddingBottom = 10;
    CGFloat differenceLabelHeight = currentLabelHeight - previouseLabelHeight + paddingBottom;
    CGRect headerFrame = _header.frame;
    headerFrame.size.height += differenceLabelHeight;
    self.header.frame = headerFrame;
    self.table.tableHeaderView = self.header;

    _talkcreatetimelabel.text = [data objectForKey:TKPD_TALK_CREATE_TIME];
    
    [_userButton setLabelBackground:[data objectForKey:TKPD_TALK_USER_LABEL]];
    [_userButton setText:[data objectForKey:TKPD_TALK_USER_NAME]];
    [_userButton setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:14.0f]];

    UITapGestureRecognizer *tapUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
    [_userButton addGestureRecognizer:tapUser];
    [_userButton setUserInteractionEnabled:YES];

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
    
    NSURLRequest* requestUserImage = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[data objectForKey:TKPD_TALK_USER_IMG]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [_talkuserimage setImageWithURLRequest:requestUserImage placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [_talkuserimage setImage:image];
        _talkuserimage = [UIImageView circleimageview:_talkuserimage];
        
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[data objectForKey:TKPD_TALK_PRODUCT_IMAGE]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [_talkProductImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [_talkProductImage setImage:image];
        
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    _productNameLabel.text = [_data objectForKey:TKPD_TALK_PRODUCT_NAME];
    _productNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct)];
    [_productNameLabel addGestureRecognizer:tap];
}

- (void) initTalkInputView {
    _growingtextview.layer.borderWidth = 0.5f;
    _growingtextview.layer.borderColor = [UIColor lightGrayColor].CGColor;

    _talkInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - Request and Mapping
-(void) cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;

    [_talkCommentNetworkManager requestCancel];
}

-(void) configureRestKit{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [TalkComment mapping];

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:_urlPath keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void) loadData {
    NSDictionary* param = @{
            kTKPDDETAIL_APIACTIONKEY : _urlAction?:@"",
            TKPD_TALK_ID : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),
            kTKPDDETAIL_APIPAGEKEY : @(_page)
    };

    [_talkCommentNetworkManager requestWithBaseUrl:kTkpdBaseURLString
                                              path:_urlPath
                                            method:RKRequestMethodPOST
                                         parameter:param
                                           mapping:[TalkComment mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             [_act stopAnimating];
                                             _table.hidden = NO;
                                             _isrefreshview = NO;
                                             [_refreshControl endRefreshing];
                                             [self requestsuccess:successResult withOperation:operation];
                                         }
                                         onFailure:^(NSError *errorResult) {
                                             [_act stopAnimating];
                                             _table.hidden = NO;
                                             _isrefreshview = NO;
                                             [_refreshControl endRefreshing];
                                             [self requestfailure:errorResult];
                                         }];
}

-(void) requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talkcomment = stats;
    BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocess:object];
    }
}

-(void) requestfailure:(id)object {
    [self requestprocess:object];
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _talkcomment = stats;
            BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _talkcomment.result.list;
                [_list addObjectsFromArray:list];
                
                _urinext =  _talkcomment.result.paging.uri_next;
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
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                NSLog(@"next page : %zd",_page);
                
                
                _isnodata = NO;
                [_table reloadData];
            }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                [_act stopAnimating];
                _table.tableFooterView = nil;
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout {
    [self cancel];
}

#pragma mark - View Action

- (void)tapProduct {
    if (![NavigationHelper shouldDoDeepNavigation]) {
        return;
    }
    
    if([[_data objectForKey:@"talk_product_status"] isEqualToString:@"1"]) {
        [_navigateController navigateToProductFromViewController:self withName:[_data objectForKey:TKPD_TALK_PRODUCT_NAME] withPrice:nil withId:[_data objectForKey:TKPD_TALK_PRODUCT_ID]?:[_data objectForKey:@"product_id"] withImageurl:[_data objectForKey:TKPD_TALK_PRODUCT_IMAGE] withShopName:nil];
    }
}

- (void)tapErrorComment {
    [self configureSendCommentRestkit];
    [self addProductCommentTalk];
}

- (void)tapUser {
    NSString *userId = [_data objectForKey:@"user_id"];
    if(!userId) {
        userId = [_data objectForKey:@"talk_user_id"];
    }
    [_navigateController navigateToProfileFromViewController:self withUserID:userId];
}

- (IBAction)btnSendTapped {
    [self submitTalk];
}


-(IBAction)tap:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
                
            
                
            default:
            break;
        }
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 11 : {
                [self tapProduct];
                break;
            }
                
            case 12 : {
                [self tapUser];
                break;
            }
                
            case 13 : {
                _reportAction = @"report_product_talk";
                ReportViewController *reportController = [ReportViewController new];
                reportController.delegate = self;
                [self.navigationController pushViewController:reportController animated:YES];
                break;
            }

            default:
                break;
        }
    }
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
            //TODO: the UserAuthenticationManager actually returns shop id as NSNumber*,
            //so we need to get the string value of it. need to fix data type problem
            NSString* userShopId = [((NSNumber*)[_userManager getShopId]) stringValue];

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

        if(![_act isAnimating]) {
            [_list insertObject:comment atIndex:lastindexpathrow];
            [_table reloadData];

            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastindexpathrow inSection:0];
            [_table scrollToRowAtIndexPath:indexpath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];

            //connect action to web service
            _savedComment = _growingtextview.text;
            [self configureSendCommentRestkit];
            [self addProductCommentTalk];

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
- (void)configureSendCommentRestkit {
    // initialize RestKit
    _objectSendCommentManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success", CFieldCommentID:CFieldCommentID}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDACTIONTALK_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectSendCommentManager addResponseDescriptor:responseDescriptorStatus];
}

-(void)addProductCommentTalk{
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIADDCOMMENTTALK,
                            TKPD_TALK_ID:[_data objectForKey:TKPD_TALK_ID],
                            kTKPDTALKCOMMENT_APITEXT:_growingtextview.text,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]
                            };
    
    _requestactioncount ++;
    _requestSendComment = [_objectSendCommentManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDACTIONTALK_APIPATH parameters:[param encrypt]];
    
    
    [_requestSendComment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestactionsuccess:mappingResult withOperation:operation];
        [_table reloadData];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    }];
    
    [_operationSendCommentQueue addOperation:_requestSendComment];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}

- (void)requestactionsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    ProductTalkCommentAction *commentaction = info;
    BOOL status = [commentaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        //if success
        if([commentaction.result.is_success isEqualToString:@"0"]) {
            _growingtextview.text = _savedComment;
            
            TalkCommentList *commentlist = _list[_list.count-1];
            [_list removeObject:commentlist];
            [_table beginUpdates];
            [_table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_list.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [_table endUpdates];
            
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:commentaction.message_error
                                                                           delegate:self];
            [alert show];
        } else {
            NSString *totalcomment = [NSString stringWithFormat:@"%zd %@",_list.count, @"Komentar"];
            [_talkCommentButtonLarge setTitle:totalcomment forState:UIControlStateNormal];
            
            TalkCommentList *comment = _list[_list.count-1];
            comment.is_just_sent = NO;
            comment.comment_id = commentaction.result.comment_id;
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
}

- (void)requestactionfailure:(id)error {
    
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
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexPath = ((GeneralTalkCommentCell*) cell).indexpath;
        TalkCommentList *list = _list[indexPath.row];
        if(list.comment_user_id == nil || list.comment_id == nil)
            return nil;
        
        [_datainput setObject:list.comment_id forKey:@"comment_id"];
        [_datainput setObject:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY] forKey:@"product_id"];
        
        if(![[_userManager getUserId] isEqualToString:list.comment_user_id] && ![_userManager isMyShopWithShopId:[_data objectForKey:@"talk_shop_id"]]) {
            MGSwipeButton * report = [MGSwipeButton buttonWithTitle:@"Laporkan" backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                _reportAction = @"report_comment_talk";
                ReportViewController *reportController = [ReportViewController new];
                reportController.delegate = self;
                [self.navigationController pushViewController:reportController animated:YES];
                return YES;
            }];
            return @[report];
        } else {
            MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                [self deleteCommentTalkAtIndexPath:indexPath];
                return YES;
            }];
            
            return @[trash];
        }
        
    }
    
    return nil;
    
}

- (void)GeneralTalkCommentCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    
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
    [self configureDeleteCommentRestkit];
    [self doDeleteCommentTalk:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}


- (void)configureDeleteCommentRestkit {
    _objectDeleteCommentManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"}];

    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDACTIONTALK_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectDeleteCommentManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doDeleteCommentTalk:(id)object {
    if(_requestDeleteComment.isExecuting) return;
    
    _requestDeleteCommentCount++;

    NSDictionary *param = @{
                            @"action" : @"delete_comment_talk",
                            @"product_id" : [_datainput objectForKey:@"product_id"],
                            @"comment_id" : [_datainput objectForKey:@"comment_id"],
                            @"shop_id" : [_data objectForKey:@"talk_shop_id"],
                            @"talk_id" : [_data objectForKey:@"talk_id"]
                            };
    
    _requestDeleteComment = [_objectDeleteCommentManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDACTIONTALK_APIPATH parameters:[param encrypt]];
    
    [_talkCommentButtonLarge setTitle:[NSString stringWithFormat:@"%lu Komentar", (unsigned long)[_list count]] forState:UIControlStateNormal];
    
    [_requestDeleteComment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessDeleteComment:mappingResult withOperation:operation];
        
        [_table reloadData];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
 
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        
        [self requestFailureDeleteComment:error];
    }];
    
    [_operationDeleteCommentQueue addOperation:_requestDeleteComment];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutDeleteComment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestSuccessDeleteComment:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    GeneralAction *generalaction = stat;
    BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionDelete:object];
    }
}

- (void)requestProcessActionDelete:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            GeneralAction *generalaction = stat;
            BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(generalaction.message_error)
                {
                    [self cancelDeleteRow];
                    NSArray *array = generalaction.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                if ([generalaction.result.is_success isEqualToString:@"1"]) {
                    NSArray *array =  [[NSArray alloc] initWithObjects:CStringBerhasilMenghapusKomentarDiskusi, nil];
                    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                    [stickyAlertView show];
                    
                    NSString *title = [NSString stringWithFormat:@"%d Komentar", (int)_list.count?:0];
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
        }
        else{
            [self cancelActionDelete];
            [self cancelDeleteRow];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_talkCommentButtonLarge setTitle:[NSString stringWithFormat:@"%lu Komentar",(unsigned long)[_list count]] forState:UIControlStateNormal];
    [_table reloadData];
}



- (void)cancelActionDelete {
    [_requestDeleteComment cancel];
    _requestDeleteComment = nil;
    [_objectDeleteCommentManager.operationQueue cancelAllOperations];
    _objectDeleteCommentManager = nil;
}

- (void)requestFailureDeleteComment:(id)object {
    [self requestProcessActionDelete:object];
}

- (void)requestTimeoutDeleteComment {
    [self cancelActionDelete];
}

#pragma mark - Report Delegate
- (NSDictionary *)getParameter {
    return @{
             @"action" : _reportAction,
             @"talk_id" : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
             @"talk_comment_id" : [_datainput objectForKey:@"comment_id"]?:@(0),
             @"product_id" : [_data objectForKey:@"product_id"],
             };
}

- (NSString *)getPath {
    return @"action/talk.pl";
}

- (UIViewController *)didReceiveViewController {
    return self;
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
    [self configureRestKit];
    [self loadData];
}


- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self adjustSendButtonAvailability];
}

- (void)adjustSendButtonAvailability {
    NSString *text = [_growingtextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    _sendButton.enabled = text.length > 5;
}

@end
