//
//  ProductTalkViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Talk.h"
#import "string_product.h"
#import "detail.h"
#import "GeneralAction.h"
#import "GeneralTalkCell.h"
#import "ProductTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "ProductTalkFormViewController.h"
#import "TKPDSecureStorage.h"
#import "stringrestkit.h"
#import "URLCacheController.h"
#import "GeneralAction.h"
#import "UserAuthentificationManager.h"
#import "ReportViewController.h"
#import "TokopediaNetworkManager.h"
#import "NoResultView.h"
#import "string_inbox_talk.h"
#import "string_inbox_message.h"
#import "stringrestkit.h"
#import "inbox.h"

#define CTagDeleteAlert 12
#define CTagDeleteMessage 13

#pragma mark - Product Talk View Controller
@interface ProductTalkViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, GeneralTalkCellDelegate,ReportViewControllerDelegate, UIAlertViewDelegate, TokopediaNetworkManagerDelegate>
{
    NSMutableArray *_list;
    NSArray *_headerimages;
    NSInteger _requestcount;
    NSInteger _requestUnfollowCount;
    NSInteger _pageheaderimages;
    NSTimer *_timer;
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    NSIndexPath *selectedIndexPath;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    Talk *_talk;
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NSString *product_id;
    UserAuthentificationManager *_userManager;
    ReportViewController *_reportController;
    NoResultView *_noResultView;
    
    TokopediaNetworkManager *tokopediaNetworkManagerDeleteMessage;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIView *header;

@property (weak, nonatomic) IBOutlet UILabel *productnamelabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imagescrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (weak, nonatomic) IBOutlet UILabel *productSoldLabel;
@property (weak, nonatomic) IBOutlet UILabel *productViewLabel;


-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

-(IBAction)tap:(id)sender;

@end

@implementation ProductTalkViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_TALK;
    }
    
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationUnfollowQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _userManager = [UserAuthentificationManager new];
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    
    _table.tableHeaderView = _header;
    
    //UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //right button

    NSString *shopID = [NSString stringWithFormat:@"%@", [_userManager getShopId]];
    NSString *userID = [NSString stringWithFormat:@"%@", [_userManager getUserId]];
    if(![userID isEqualToString:@"0"] && ![shopID isEqual:[_data objectForKey:TKPD_TALK_SHOP_ID]]) {

        UIBarButtonItem *rightbar;
        UIImage *imgadd = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_shop_addproduct" ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [imgadd imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            rightbar = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        }
        else
            rightbar = [[UIBarButtonItem alloc] initWithImage:imgadd style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        [rightbar setTag:11];
        self.navigationItem.rightBarButtonItem = rightbar;
    }
    
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    [self setHeaderData:_data];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    /** init notification*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalComment:)
                                                 name:@"UpdateTotalComment" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTalk:)
                                                 name:@"UpdateTalk" object:nil];
    
    
    //cache
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
//    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCTTALK_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
//    _cachecontroller.filePath = _cachepath;
//    _cachecontroller.URLCacheInterval = 86400.0;
//	[_cachecontroller initCacheWithDocumentPath:path];
    
    product_id = [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Product - Talk List";
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata) {
            [self loadData];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALTALKCELL_IDENTIFIER;
		
		cell = (GeneralTalkCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralTalkCell newcell];
			((GeneralTalkCell*)cell).delegate = self;
            [((GeneralTalkCell*)cell).userButton setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:13.0f]];
            ((GeneralTalkCell*)cell).userButton.userInteractionEnabled = YES;
            [((GeneralTalkCell*)cell).userButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(tap:)]];
		}
        
        if (_list.count > indexPath.row) {
            TalkList *list = _list[indexPath.row];
            ((GeneralTalkCell*)cell).userButton.text = list.talk_user_name;
            ((GeneralTalkCell*)cell).timelabel.text = list.talk_create_time;
            ((GeneralTalkCell*)cell).commentlabel.text = list.talk_message;
            ((GeneralTalkCell*)cell).data = list;
            
            //Set user label
//            if([list.talk_user_label isEqualToString:CPenjual]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPenjual];
//            }
//            else if([list.talk_user_label isEqualToString:CPembeli]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPembeli];
//            }
//            else if([list.talk_user_label isEqualToString:CAdministrator]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagAdministrator];
//            }
//            else if([list.talk_user_label isEqualToString:CPengguna]) {
//                [((GeneralTalkCell*)cell).userButton setColor:CTagPengguna];
//            }
//            else {
//                [((GeneralTalkCell*)cell).userButton setColor:-1];//-1 is set to empty string
//            }
            [((GeneralTalkCell*)cell).userButton setLabelBackground:list.talk_user_label];
            
            NSString *followStatus;
            if(!list.talk_follow_status) {
                followStatus = TKPD_TALK_FOLLOW;
            } else {
                followStatus = TKPD_TALK_UNFOLLOW;
            }
            [((GeneralTalkCell*)cell).unfollowButton setTitle:followStatus forState:UIControlStateNormal];
            
            if(![list.talk_own isEqualToString:@"1"] && [_userManager isLogin]) {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = NO;
            } else {
                ((GeneralTalkCell*)cell).unfollowButton.hidden = YES;
                ((GeneralTalkCell*)cell).buttonsDividers.hidden = YES;
                
                CGRect newFrame = ((GeneralTalkCell*)cell).commentbutton.frame;
                newFrame.origin.x = cell.frame.size.width/2;
                ((GeneralTalkCell*)cell).commentbutton.frame = newFrame;
            }
            

            if([_userManager isLogin]) {
                ((GeneralTalkCell*)cell).moreActionButton.hidden = NO;
            } else {
                ((GeneralTalkCell*)cell).moreActionButton.hidden = YES;
            }
            ((GeneralTalkCell*)cell).productViewIsHidden = YES;
            ((GeneralTalkCell*)cell).messageLabel.hidden = NO;
            ((GeneralTalkCell*)cell).messageLabel.text = list.talk_message;
            ((GeneralTalkCell*)cell).indexpath = indexPath;
            
//            if(list.disable_comment) {
//                ((GeneralTalkCell*)cell).commentbutton.enabled = NO;
//            } else {
//                ((GeneralTalkCell*)cell).commentbutton.enabled = YES;
//            }
            
            NSString *commentstring = [list.talk_total_comment?:0 stringByAppendingFormat:
                                 @" Komentar"];
            [((GeneralTalkCell*)cell).commentbutton setTitle:commentstring forState:UIControlStateNormal];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.talk_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            UIImageView *thumb = ((GeneralTalkCell*)cell).thumb;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                NSLog(@"thumb: %@", thumb);
                [thumb setImage:image];
                
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

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                // back to previous vie controller
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11 : {
                //add new talk
                ProductTalkFormViewController *vc = [ProductTalkFormViewController new];
                vc.data = @{
                            kTKPDDETAIL_APIPRODUCTIDKEY:[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY]?:@(0),
                            kTKPDDETAILPRODUCT_APIIMAGESRCKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]?:@(0),
                            TKPD_TALK_SHOP_ID:[_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),
                            
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                // see more action
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                //[self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                // back action image scroll view
                if (_pageheaderimages>0) {
                    _pageheaderimages --;
                    [_imagescrollview setContentOffset:CGPointMake(_imagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];
                    
                }
                break;
            }
            case 12:
            {
                // next action image scroll view
                if (_pageheaderimages<_headerimages.count-1) {
                    _pageheaderimages ++;
                    [_imagescrollview setContentOffset:CGPointMake(_imagescrollview.frame.size.width*_pageheaderimages, 0.0f) animated:YES];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)followAnimateZoomOut:(UIButton*)buttonUnfollow {
    double delayInSeconds = 2.0;
    if([[buttonUnfollow currentTitle] isEqualToString:TKPD_TALK_FOLLOW]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1.3,1.3);
        [buttonUnfollow setTitle:TKPD_TALK_UNFOLLOW forState:UIControlStateNormal];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1,1);
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1.3,1.3);
        [buttonUnfollow setTitle:TKPD_TALK_FOLLOW forState:UIControlStateNormal];
        buttonUnfollow.transform = CGAffineTransformMakeScale(1,1);
        [UIView commitAnimations];
    }
    
    buttonUnfollow.enabled = NO;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        buttonUnfollow.enabled = YES;
    });
}

-(void) configureUnfollowRestkit {
    _objectUnfollowmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:TKPD_MESSAGE_TALK_ACTION keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectUnfollowmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)unfollowTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withButton:(UIButton *)buttonUnfollow {
    [self configureUnfollowRestkit];
    [self followAnimateZoomOut:buttonUnfollow];
    
    TalkList *list = _list[indexpath.row];
    if (_requestUnfollow.isExecuting) return;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_ACTIONKEY : TKPD_FOLLOW_TALK_ACTION,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : product_id,
                            TKPD_TALK_ID:list.talk_id?:@0,
                            };
    
    _requestUnfollowCount ++;
    _requestUnfollow = [_objectUnfollowmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:TKPD_MESSAGE_TALK_ACTION parameters:[param encrypt]];
    
    [_requestUnfollow setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
    
    [_operationUnfollowQueue addOperation:_requestUnfollow];
    
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManagerDeleteMessage requestCancel];
    tokopediaNetworkManagerDeleteMessage.delegate = nil;
    tokopediaNetworkManagerDeleteMessage = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Talk class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_TOTAL_COMMENT,
                                                 TKPD_TALK_USER_IMG,
                                                 TKPD_TALK_USER_NAME,
                                                 TKPD_TALK_ID,
                                                 TKPD_TALK_CREATE_TIME,
                                                 TKPD_TALK_MESSAGE,
                                                 TKPD_TALK_FOLLOW_STATUS,
                                                 TKPD_TALK_SHOP_ID,
                                                 TKPD_TALK_USER_ID,
                                                 TKPD_TALK_PRODUCT_STATUS,
                                                 TKPD_TALK_USER_LABEL_ID,
                                                 TKPD_TALK_USER_LABEL
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETPRODUCTTALKKEY,
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page)?:@1,
                            kTKPDDETAIL_APILIMITKEY : @kTKPDDETAILDEFAULT_LIMITPAGE
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
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
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
    }
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talk = stats;
    BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
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

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
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
            _talk = stats;
            BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _talk = stats;
            BOOL status = [_talk.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _talk.result.list;
                [_list addObjectsFromArray:list];
                
                if([_list count] > 0) {
                    _urinext =  _talk.result.paging.uri_next;
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
                } else {
                    _table.tableFooterView = _noResultView;
                    _isnodata = YES;
                }
                
                
                
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
                    _table.tableFooterView = _noResultView;
                    NSError *error = object;
                    NSString *errorDescription = error.localizedDescription;
                    
                    if(error.code == -1011) {
                        errorDescription = CStringFailedInServer;
                    } else if (error.code==-1009 || error.code==-999) {
                        errorDescription = CStringNoConnection;
                    }
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [errorAlert show];
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = _noResultView;
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                
                if(error.code == -1011) {
                    errorDescription = CStringFailedInServer;
                } else if (error.code==-1009 || error.code==-999) {
                    errorDescription = CStringNoConnection;
                }
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}


#pragma mark - Delegate
- (void)GeneralTalkCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ProductTalkDetailViewController *vc = [ProductTalkDetailViewController new];
    NSInteger row = indexpath.row;
    TalkList *list = _list[row];
    vc.data = @{
                TKPD_TALK_MESSAGE:list.talk_message?:@0,
                TKPD_TALK_USER_IMG:list.talk_user_image?:@0,
                TKPD_TALK_CREATE_TIME:list.talk_create_time?:@0,
                TKPD_TALK_USER_NAME:list.talk_user_name?:@0,
                TKPD_TALK_ID:list.talk_id?:@0,
                TKPD_TALK_USER_ID:[NSString stringWithFormat:@"%d", list.talk_user_id],
                TKPD_TALK_TOTAL_COMMENT : list.talk_total_comment?:@0,
                kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : product_id,
                TKPD_TALK_SHOP_ID:list.talk_shop_id?:@0,
                TKPD_TALK_PRODUCT_STATUS:[_data objectForKey:@"talk_product_status"],
                TKPD_TALK_PRODUCT_IMAGE:[_data objectForKey:@"talk_product_image"],
                TKPD_TALK_PRODUCT_NAME:[_data objectForKey:@"product_name"],
                //utk notification, apabila total comment bertambah, maka list ke INDEX akan berubah pula
                kTKPDDETAIL_DATAINDEXKEY : @(row)?:@0,
                TKPD_TALK_USER_LABEL:list.talk_user_label
                };
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _imagescrollview.frame.size.width;
    _pageheaderimages = floor((_imagescrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pagecontrol.currentPage = _pageheaderimages;
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagDeleteMessage) {
        if(tokopediaNetworkManagerDeleteMessage == nil) {
            tokopediaNetworkManagerDeleteMessage = [TokopediaNetworkManager new];
            tokopediaNetworkManagerDeleteMessage.delegate = self;
            tokopediaNetworkManagerDeleteMessage.tagRequest = tag;
        }
        
        return tokopediaNetworkManagerDeleteMessage;
    }
    
    return nil;
}

-(void)setHeaderData:(NSDictionary*)data
{
    _productnamelabel.text = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    _productnamelabel.numberOfLines = 1;
    
    _pricelabel.text = [data objectForKey:API_PRODUCT_PRICE_KEY];
    _headerimages = [data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY];
    for (int i = 0; i<_headerimages.count; i++) {
        CGFloat y = i * 320;
        UIImageView *thumb = [[UIImageView alloc]initWithFrame:CGRectMake(y, 0, _imagescrollview.frame.size.width, _imagescrollview.frame.size.height)];
        thumb.image = ((UIImageView*)_headerimages[i]).image;
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        [_imagescrollview addSubview:thumb];
    }
    
    _productSoldLabel.text = [NSString stringWithFormat:@"%@ Sold", [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY]];
    ;
    _productViewLabel.text = [NSString stringWithFormat:@"%@ View", [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY]];
    
    _imagescrollview.contentSize = CGSizeMake(_headerimages.count*320,0);
    _imagescrollview.pagingEnabled = YES;
    
    _pagecontrol.hidden = _headerimages.count <= 1?YES:NO;
    _pagecontrol.numberOfPages = _headerimages.count;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Handler
-(void) updateTotalComment:(NSNotification*)notification{
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    
    TalkList *list = _list[index];
    list.talk_total_comment = [NSString stringWithFormat:@"%@",[userinfo objectForKey:TKPD_TALK_TOTAL_COMMENT]];
    [_table reloadData];
}

- (void) updateTalk:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
   
    
    if([userinfo objectForKey:@"talk_id"]) {
        NSInteger row = 0;
        if(_list.count == 0) {
            [self insertList:userinfo];

            TalkList *list = _list[row];
            list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
            list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
            list.disable_comment = NO;
            list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
        }
        else {
            TalkList *list = _list[row];
            if(list.talk_id!=nil && ![list.talk_id isEqualToString:@""]) {
                [self insertList:userinfo];
                
                list = _list[row];
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
            }
            else {
                list.talk_id = [userinfo objectForKey:TKPD_TALK_ID];
                list.talk_shop_id = [userinfo objectForKey:TKPD_TALK_SHOP_ID];
                list.disable_comment = NO;
                list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
            }
        }
    } else {
        [self insertList:userinfo];
    }
    
    
    [_table reloadData];
    
}

- (void)insertList:(NSDictionary *)userinfo {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
    
    
    TalkList *list = [TalkList new];
    list.talk_user_name = [auth objectForKey:kTKPD_FULLNAMEKEY];
    list.talk_total_comment = kTKPD_NULLCOMMENTKEY;
    list.talk_user_image = [auth objectForKey:kTKPD_USERIMAGEKEY];
    list.talk_user_id = [[auth objectForKey:kTKPD_USERIDKEY] intValue];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy, HH:mm"];
    
    list.talk_create_time = [dateFormat stringFromDate:today];
    list.talk_message = [userinfo objectForKey:TKPD_TALK_MESSAGE];
    
    list.disable_comment = YES;
    [_list insertObject:list atIndex:0];
    _isnodata = NO;
    _table.tableFooterView = nil;
}

#pragma mark - General Cell Comment Delegate
- (void)reportTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    _reportController = [ReportViewController new];
    _reportController.delegate = self;
    
    [self.navigationController pushViewController:_reportController animated:YES];
}

- (void)deleteTalk:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    selectedIndexPath = indexpath;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:PROMPT_DELETE_TALK
                          message:PROMPT_DELETE_TALK_MESSAGE
                          delegate:self
                          cancelButtonTitle:BUTTON_CANCEL
                          otherButtonTitles:nil];
    
    alert.tag = CTagDeleteAlert;
    [alert addButtonWithTitle:BUTTON_OK];
    [alert show];
}

#pragma mark - Report Delegate
- (NSDictionary *)getParameter {
    return @{
             @"action" : @"report_product_talk",
             @"talk_id" : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0)
             };
}


- (NSString *)getPath {
    return @"action/talk.pl";
}


#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == CTagDeleteAlert) {
        if(buttonIndex == 1) {
            [[self getNetworkManager:CTagDeleteMessage] doRequest];
        }
        else {
            selectedIndexPath = nil;
        }
    }
}




#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagDeleteMessage) {
        NSInteger row = selectedIndexPath.row;
        TalkList *list = _list[row];
        return @{
                 kTKPDDETAIL_ACTIONKEY : TKPD_DELETE_TALK_ACTION,
                 kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : product_id,
                 TKPD_TALK_ID:list.talk_id?:@0,
                 kTKPDDETAILSHOP_APISHOPID : list.talk_shop_id
                 };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagDeleteMessage) {
        return TKPD_MESSAGE_TALK_ACTION;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagDeleteMessage) {
        _objectDeletemanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:TKPD_MESSAGE_TALK_ACTION
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectDeletemanager addResponseDescriptor:responseDescriptorStatus];
        return _objectDeletemanager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((GeneralAction *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    if(tag == CTagDeleteMessage) {
        [_list removeObjectAtIndex:selectedIndexPath.row];
        [_table reloadData];
        selectedIndexPath = nil;
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{

}

- (void)actionBeforeRequest:(int)tag {

}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagDeleteMessage) {
        selectedIndexPath = nil;
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedDeleteMessage] delegate:self];
        [stickyAlertView show];
    }
}
@end
