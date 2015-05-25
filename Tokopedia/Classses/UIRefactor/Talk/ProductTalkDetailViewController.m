//
//  ProductTalkDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkDetailViewController.h"
#import "TalkComment.h"
#import "detail.h"
#import "GeneralTalkCommentCell.h"
#import "ProductTalkCommentAction.h"
#import "TKPDSecureStorage.h"
#import "URLCacheController.h"
#import "HPGrowingTextView.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "GeneralAction.h"
#import "DetailProductViewController.h"
#import "LoginViewController.h"

//#import "ProfileBiodataViewController.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"
#import "TKPDTabProfileNavigationController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ReportViewController.h"
#import "NavigateViewController.h"
#import "UserAuthentificationManager.h"

#import "ProductTalkViewController.h"
#import "InboxTalkViewController.h"
#import "UserContainerViewController.h"

#import "stringrestkit.h"
#import "string_more.h"
#import "string_inbox_talk.h"

@interface ProductTalkDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,MGSwipeTableCellDelegate, HPGrowingTextViewDelegate, ReportViewControllerDelegate, LoginViewDelegate, GeneralTalkCommentCellDelegate>
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

    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    HPGrowingTextView *_growingtextview;
    
    NSTimeInterval _timeinterval;
    NSMutableDictionary *_auth;
    UserAuthentificationManager *_userManager;
    NavigateViewController *_navigateController;
    NSString *_reportAction;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *talkmessagelabel;
@property (weak, nonatomic) IBOutlet UILabel *talkcreatetimelabel;
@property (weak, nonatomic) IBOutlet UILabel *talkusernamelabel;
@property (weak, nonatomic) IBOutlet UILabel *talktotalcommentlabel;
@property (weak, nonatomic) IBOutlet UIImageView *talkuserimage;
@property (weak, nonatomic) IBOutlet UIImageView *talkProductImage;
@property (weak, nonatomic) IBOutlet UIView *talkInputView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *talkProductName;
@property (weak, nonatomic) IBOutlet UIView *userArea;
@property (weak, nonatomic) IBOutlet UIView *buttonsDividers;

@property (strong, nonatomic) IBOutlet UIView *header;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;
-(void)configureSendCommentRestkit;
- (void)configureDeleteCommentRestkit;

@end

@implementation ProductTalkDetailViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationSendCommentQueue = [NSOperationQueue new];
    _operationDeleteCommentQueue = [NSOperationQueue new];
    
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _datainput = [NSMutableDictionary new];
    _userManager = [UserAuthentificationManager new];
    _navigateController = [NavigateViewController new];
    
    _table.tableHeaderView = _header;
    _page = 1;
    _auth = [NSMutableDictionary new];
    [_sendButton setEnabled:NO];
    
    //validate previous class so it can use several URL path
    NSArray *vcs = self.navigationController.viewControllers;
    if([vcs[[vcs count] - 2] isKindOfClass:[TKPDTabInboxTalkNavigationController class]]) {
        
        _urlPath = kTKPDINBOX_TALK_APIPATH;
        _urlAction = kTKPDDETAIL_APIGETINBOXDETAIL;
        
    } else {
        _urlPath = kTKPDDETAILTALK_APIPATH;
        _urlAction = kTKPDDETAIL_APIGETCOMMENTBYTALKID;
    }
    
    if([_userManager isLogin]) {
        _reportButton.hidden = NO;
    } else {
        _reportButton.hidden = YES;
        _buttonsDividers.hidden = YES;
        
        CGRect newFrame = _talktotalcommentlabel.frame;
        newFrame.origin.x = 120;
        _talktotalcommentlabel.frame = newFrame;
    }
    
    
    
    //UIBarButtonItem *barbutton1;
    //NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    

        // add gesture to product image
    UITapGestureRecognizer* productGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct)];
    [_talkProductImage addGestureRecognizer:productGesture];
    [_talkProductImage setUserInteractionEnabled:YES];


    
    [self setHeaderData:_data];
    
    //islogin
    if([_userManager getUserId] && ![[_userManager getUserId] isEqualToString:@"0"]) {
        //isbanned product
        if(![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_DELETED] &&
           ![[_data objectForKey:@"talk_product_status"] isEqualToString:STATE_TALK_PRODUCT_BANNED]
           ) {
            [self initTalkInputView];
        }

    }

    
    NSDictionary *userinfo;
    userinfo = @{kTKPDDETAIL_DATAINDEXKEY:[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadTalk" object:nil userInfo:userinfo];
    
    UITapGestureRecognizer *tapUserGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
    [_userArea addGestureRecognizer:tapUserGes];
    [_userArea setUserInteractionEnabled:YES];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCTTALKDETAIL_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
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
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TalkCommentList *list = _list[indexPath.row];
    CGSize messageSize = [GeneralTalkCommentCell messageSize:list.comment_message];
    return messageSize.height + 2 * [GeneralTalkCommentCell textMarginVertical];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER;
        
        cell = (GeneralTalkCommentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralTalkCommentCell newcell];
            ((GeneralTalkCommentCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            TalkCommentList *list = _list[indexPath.row];
            
            UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
            NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 5.0f;
            NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style};
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:list.comment_message
                                                                                   attributes:attributes];
            ((GeneralTalkCommentCell *)cell).commentlabel.attributedText = attributedString;
            
            CGFloat commentLabelWidth = ((GeneralTalkCommentCell*)cell).commentlabel.frame.size.width;
            
            [((GeneralTalkCommentCell*)cell).commentlabel sizeToFit];
            
            CGRect commentLabelFrame = ((GeneralTalkCommentCell*)cell).commentlabel.frame;
            commentLabelFrame.size.width = commentLabelWidth;
            ((GeneralTalkCommentCell*)cell).commentlabel.frame = commentLabelFrame;
            
            ((GeneralTalkCommentCell*)cell).user_name.text = list.comment_user_name;
            ((GeneralTalkCommentCell*)cell).create_time.text = list.comment_create_time;
            
            ((GeneralTalkCommentCell*)cell).indexpath = indexPath;
            

            
            if(list.is_not_delivered) {
                ((GeneralTalkCommentCell*)cell).commentfailimage.hidden = NO;
                ((GeneralTalkCommentCell*)cell).create_time.text = @"Gagal Kirim.";
                
                UITapGestureRecognizer *errorSendCommentGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapErrorComment)];
                [((GeneralTalkCommentCell*)cell).commentfailimage addGestureRecognizer:errorSendCommentGesture];
                [((GeneralTalkCommentCell*)cell).commentfailimage setUserInteractionEnabled:YES];
            } else {
                ((GeneralTalkCommentCell*)cell).commentfailimage.hidden = YES;
            }
            
            if(list.is_just_sent) {
                ((GeneralTalkCommentCell*)cell).create_time.text = @"Kirim...";
            } else {
                ((GeneralTalkCommentCell*)cell).create_time.text = list.comment_create_time;
            }
        
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.comment_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *user_image = ((GeneralTalkCommentCell*)cell).user_image;
            user_image.image = nil;


            [user_image setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [user_image setImage:image];
            
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
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
        }
    }
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_growingtextview resignFirstResponder];
}



#pragma mark - Methods
-(void)setHeaderData:(NSDictionary*)data
{
//    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 3.0;
//    style.alignment = NSTextAlignmentLeft;
//    
//    NSDictionary *attributes = @{
//                                 NSForegroundColorAttributeName: [UIColor blackColor],
//                                 NSFontAttributeName: font,
//                                 NSParagraphStyleAttributeName: style,
//                                 };
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[data objectForKey:TKPD_TALK_MESSAGE] attributes:attributes];
//    
//    _talkmessagelabel.attributedText = attributedText;
//    _talkmessagelabel.numberOfLines = 5;
//    [_talkmessagelabel sizeToFit];
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;

    
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:[data objectForKey:TKPD_TALK_MESSAGE]
                                                                                    attributes:attributes];
    _talkmessagelabel.attributedText = productNameAttributedText;
    _talkmessagelabel.textAlignment = NSTextAlignmentLeft;
    _talkmessagelabel.numberOfLines = 4;
    
    CGRect newFrame = CGRectMake(94, 106, 210, 110);
    _talkmessagelabel.frame = newFrame;
    [_talkmessagelabel sizeToFit];
    
    CGRect myFrame = _talkmessagelabel.frame;
    myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, 210, myFrame.size.height);
    _talkmessagelabel.frame = myFrame;
    
    _talkcreatetimelabel.text = [data objectForKey:TKPD_TALK_CREATE_TIME];
    _talkusernamelabel.text = [data objectForKey:TKPD_TALK_USER_NAME];
    _talktotalcommentlabel.text = [NSString stringWithFormat:@"%@ Komentar",[data objectForKey:TKPD_TALK_TOTAL_COMMENT]];
    
    
    if(![[data objectForKey:TKPD_TALK_USER_ID] isEqualToString:[_userManager getUserId]] && ![_userManager isMyShopWithShopId:[_data objectForKey:@"talk_shop_id"]]) {
        _reportButton.hidden = NO;
        
        CGRect newFrame = _talktotalcommentlabel.frame;
        newFrame.origin.x = 54;
        _talktotalcommentlabel.frame = newFrame;
        _buttonsDividers.hidden = NO;
    } else {
        _reportButton.hidden = YES;
        
        CGRect newFrame = _talktotalcommentlabel.frame;
        newFrame.origin.x = 120;
        _talktotalcommentlabel.frame = newFrame;
        _buttonsDividers.hidden = YES;
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

    [_talkProductName setTitle:[data objectForKey:TKPD_TALK_PRODUCT_NAME] forState:UIControlStateNormal];
}

- (void) initTalkInputView {
    _growingtextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 10, 240, 45)];
    //    [_growingtextview becomeFirstResponder];
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
    //    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    _growingtextview.delegate = self;
    _growingtextview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _growingtextview.backgroundColor = [UIColor whiteColor];
    _growingtextview.placeholder = @"Kirim pesanmu di sini..";

    
    [_talkInputView addSubview:_growingtextview];
    _talkInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}


#pragma mark - Life Cycle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([_userManager isLogin]) {
        [_talkInputView setHidden:NO];
        [_sendButton setEnabled:NO];
    } else {
        [_talkInputView setHidden:YES];
    }
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
}


#pragma mark - Request and Mapping
-(void) cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

-(void) configureRestKit{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TalkComment class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkCommentResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkCommentList class]];

    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_MESSAGE,
                                                 TKPD_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_ISMOD,
                                                 TKPD_TALK_COMMENT_ISSELLER,
                                                 TKPD_TALK_COMMENT_CREATETIME,
                                                 TKPD_TALK_COMMENT_USERIMG,
                                                 TKPD_TALK_COMMENT_USERNAME,
                                                 TKPD_TALK_COMMENT_USERID
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:_urlPath keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void) loadData {
    if(_request.isExecuting) return;
    
    _requestcount++;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : _urlAction,
                            TKPD_TALK_ID : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:TKPD_TALK_SHOP_ID],
                            kTKPDDETAIL_APIPAGEKEY : @(_page)
                            };
//    [_cachecontroller getFileModificationDate];
//	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
//	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:_urlPath parameters:[param encrypt]];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            [_sendButton setEnabled:YES];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    }else{
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
//        NSLog(@"cache and updated in last 24 hours.");
//        [self requestfailure:nil];
//    }
}

-(void) requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talkcomment = stats;
    BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1 && !_isrefreshview) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        [self requestprocess:object];
    }
}

-(void) requestfailure:(id)object {
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _talkcomment = stats;
            BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
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
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
    if([[_data objectForKey:@"talk_product_status"] isEqualToString:@"1"]) {
        DetailProductViewController *vc = [DetailProductViewController new];
        vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:@"product_id"]};
        [self.navigationController pushViewController:vc animated:YES];
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
            case 10: {
                if([_growingtextview.text length] < 5) {
                    return;
                }
                NSInteger lastindexpathrow = [_list count];
                TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                NSDictionary* auth = [secureStorage keychainDictionary];
                _auth = [auth mutableCopy];

                
                if(_auth)
                {
                    TalkCommentList *commentlist = [TalkCommentList new];
                    commentlist.comment_message =_growingtextview.text;
                    commentlist.comment_user_name = [_auth objectForKey:@"full_name"];
                    commentlist.comment_user_image = [_auth objectForKey:@"user_image"];
                    
                    
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:m"];
                    NSString *dateString = [dateFormat stringFromDate:today];
                    
                    commentlist.comment_create_time = dateString;
                    commentlist.is_just_sent = YES;
                    
                    [_list insertObject:commentlist atIndex:lastindexpathrow];
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
                    
                    //connect action to web service
                    _savedComment = _growingtextview.text;
                    [self configureSendCommentRestkit];
                    [self addProductCommentTalk];
                    
                    _growingtextview.text = nil;
                    [_growingtextview resignFirstResponder];
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
                
                break;
            }
                
            case 11 : {
                [self tapProduct];
                break;
            }
                
            case 12 : {
//                NSMutableArray *viewControllers = [NSMutableArray new];
//                
//                ProfileBiodataViewController *biodataController = [ProfileBiodataViewController new];
//                [viewControllers addObject:biodataController];
//                
//                ProfileFavoriteShopViewController *favoriteController = [ProfileFavoriteShopViewController new];
//                favoriteController.data = @{MORE_USER_ID:[_auth objectForKey:MORE_USER_ID],
//                                            MORE_SHOP_ID:[_auth objectForKey:MORE_SHOP_ID],
//                                            MORE_AUTH:_auth?:[NSNull null]};
//                [viewControllers addObject:favoriteController];
//                
//                ProfileContactViewController *contactController = [ProfileContactViewController new];
//                [viewControllers addObject:contactController];
//                
//                TKPDTabProfileNavigationController *profileController = [TKPDTabProfileNavigationController new];
//                profileController.data = @{MORE_USER_ID:[_auth objectForKey:MORE_USER_ID],
//                                           MORE_AUTH:_auth?:[NSNull null]};
//                [profileController setViewControllers:viewControllers animated:YES];
//                [profileController setSelectedIndex:0];
//                
//                [self.navigationController pushViewController:profileController animated:YES];
                
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
            TalkCommentList *commentlist = _list[_list.count-1];
            commentlist.is_not_delivered = @"1";
            commentlist.comment_user_id= [[_auth objectForKey:kTKPD_USERIDKEY] stringValue];
            _growingtextview.text = _savedComment;
            
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:commentaction.message_error
                                                                           delegate:self];
            [alert show];
        } else {
            NSString *totalcomment = [NSString stringWithFormat:@"%zd %@",_list.count, @"Komentar"];
            _talktotalcommentlabel.text = totalcomment;
            
            TalkCommentList *commentlist = _list[_list.count-1];
            commentlist.is_just_sent = NO;
            commentlist.comment_id = commentaction.result.comment_id;
            commentlist.comment_user_id= [[_auth objectForKey:kTKPD_USERIDKEY] stringValue];
            
            NSDictionary *userinfo;
            userinfo = @{TKPD_TALK_TOTAL_COMMENT:@(_list.count)?:0, kTKPDDETAIL_DATAINDEXKEY:[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTotalComment" object:nil userInfo:userinfo];
            
        }
    }
}

- (void)requestactionfailure:(id)error {
    
}

#pragma mark - UITextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _talkInputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _talkInputView.frame = r;
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
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    self.view.backgroundColor = [UIColor clearColor];
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

#pragma mark - Action Delete Comment Talk
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
    
    _talktotalcommentlabel.text = [NSString stringWithFormat:@"%lu Komentar", (unsigned long)[_list count]];
    
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
                    
                    NSDictionary *userinfo = @{TKPD_TALK_TOTAL_COMMENT:@(_list.count)?:0, kTKPDDETAIL_DATAINDEXKEY:[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTotalComment" object:nil userInfo:userinfo];
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
    _talktotalcommentlabel.text = [NSString stringWithFormat:@"%lu Komentar",(unsigned long)[_list count]];
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
             @"comment_id" : [_datainput objectForKey:@"comment_id"]?:@(0),
             @"product_id" : [_data objectForKey:@"product_id"]
             };
}

- (NSString *)getPath {
    return @"action/talk.pl";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController {

}

#pragma mark - GrowingTextView Delegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView  {
    if([growingTextView.text length] < 5) {
        _sendButton.enabled = NO;
    } else {
        _sendButton.enabled = YES;
    }
}

#pragma mark - Notification Delegate
- (void)userDidLogin:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];
}

- (void)userDidLogout:(NSNotification*)notification {
    _userManager = [UserAuthentificationManager new];    
}
@end
