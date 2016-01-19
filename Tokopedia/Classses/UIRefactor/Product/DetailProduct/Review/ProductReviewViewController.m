//
//  ProductReviewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "string.h"
#import "string_alert.h"
#import "string_product.h"

#import "Review.h"
#import "StarsRateView.h"
#import "ProgressBarView.h"
#import "ProductReviewViewController.h"
#import "ProductReviewDetailViewController.h"
#import "GeneralProductReviewCell.h"
#import "DetailReviewViewController.h"

#import "TKPDAlertView.h"
#import "AlertListView.h"
#import "StickyAlert.h"
#import "string_inbox_message.h"
#import "NoResultView.h"

#import "URLCacheController.h"
#import "TKPDSecureStorage.h"

#pragma mark - Product Review View Controller
@interface ProductReviewViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate, GeneralProductReviewCellDelegate>
{
    NSMutableDictionary *_param;
    NSMutableArray *_list;
    NSMutableArray *_listresponse;
    NSInteger _requestcount;
    NSTimer *_timer;
    BOOL _isnodata;
    
    NSInteger _starcount;
    NSString *_reviewIsOwner;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    BOOL _isadvreviewquality;
    BOOL _isalltimes;
    
    Review *_review;
    ReviewResponse *_reviewresponse;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NoResultView *_noResultView;
}

@property (weak, nonatomic) IBOutlet UIView *detailstarsandtimesview;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet StarsRateView *averagerateview;

@property (weak, nonatomic) IBOutlet UILabel *labeltotalreview;

@property (weak, nonatomic) IBOutlet UILabel *labelstarcount;

@property (weak, nonatomic) IBOutlet UIButton *buttontime;
@property (weak, nonatomic) IBOutlet UILabel *labeltime;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *buttonadvreview;

@property (strong, nonatomic) IBOutletCollection(ProgressBarView) NSArray *progressviews;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelstars;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *ratingviews;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;
@end

@implementation ProductReviewViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isadvreviewquality = YES;
        _isnodata = YES;
        self.title = kTKPDTITLE_REVIEW;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _ratingviews = [NSArray sortViewsWithTagInArray:_ratingviews];
    _labelstars = [NSArray sortViewsWithTagInArray:_labelstars];
    _progressviews = [NSArray sortViewsWithTagInArray:_progressviews];
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    
    _list = [NSMutableArray new];
    _param = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _table.tableHeaderView = _headerview;
    _headerview.hidden = YES;
    
    _page = 1;

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalReviewComment:)
                                                 name:@"updateTotalReviewComment" object:nil];
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCTREVIEW_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // UA
    [TPAnalytics trackScreenName:@"Product - Review List"];

    // GA
    self.screenName = @"Product - Review List";
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
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
        
        static NSString *ProductReviewCellIdentifier = @"GeneralReviewCellIdentifier";
		
		cell = (GeneralProductReviewCell *)[tableView dequeueReusableCellWithIdentifier:ProductReviewCellIdentifier];
		if (cell == nil) {
			cell = [GeneralProductReviewCell newcell];
			((GeneralProductReviewCell *)cell).delegate = self;
            [((GeneralProductReviewCell*)cell).namelabel setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:13.0f]];
		}

        if (_list.count > indexPath.row) {
            ReviewList *list = _list[indexPath.row];

            ((GeneralProductReviewCell *)cell).data = list;
            ((GeneralProductReviewCell *)cell).namelabel.text = list.review_user_name;
            ((GeneralProductReviewCell *)cell).timelabel.text = list.review_create_time;
            
            //Set user label
//            if([list.review_user_label isEqualToString:CPenjual]) {
//                [((GeneralProductReviewCell*)cell).namelabel setColor:CTagPenjual];
//            }
//            else if([list.review_user_label isEqualToString:CPembeli]) {
//                [((GeneralProductReviewCell*)cell).namelabel setColor:CTagPembeli];
//            }
//            else if([list.review_user_label isEqualToString:CAdministrator]) {
//                [((GeneralProductReviewCell*)cell).namelabel setColor:CTagAdministrator];
//            }
//            else if([list.review_user_label isEqualToString:CPengguna]) {
//                [((GeneralProductReviewCell*)cell).namelabel setColor:CTagPengguna];
//            }
//            else {
//                [((GeneralProductReviewCell*)cell).namelabel setColor:-1];//-1 is set to empty string
//            }
//            
            [((GeneralProductReviewCell*)cell).namelabel setLabelBackground:list.review_user_label];
            
            if([list.review_response.response_message isEqualToString:@"0"]) {
                [((GeneralProductReviewCell*)cell).commentbutton setTitle:@"0 Comment" forState:UIControlStateNormal];
            } else {
                [((GeneralProductReviewCell*)cell).commentbutton setTitle:@"1 Comment" forState:UIControlStateNormal];
            }
            
            if ([list.review_message length] > 50) {
                NSRange stringRange = {0, MIN([list.review_message length], 50)};
                stringRange = [list.review_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralProductReviewCell *)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.review_message substringWithRange:stringRange]];
            } else {
                ((GeneralProductReviewCell *)cell).commentlabel.text = list.review_message?:@"";
            }
            
            ((GeneralProductReviewCell *)cell).indexpath = indexPath;
            
            
            ReviewResponse *review_response = list.review_response;
            [((GeneralProductReviewCell *)cell).commentbutton setTitle:([review_response.response_message isEqualToString:@"0"] ? @"0 Komentar" : @"1 Komentar") forState:UIControlStateNormal];
            
            ((GeneralProductReviewCell *)cell).qualityrate.starscount = [list.review_rate_product integerValue];
            ((GeneralProductReviewCell *)cell).speedrate.starscount = [list.review_rate_speed integerValue];
            ((GeneralProductReviewCell *)cell).servicerate.starscount = [list.review_rate_service integerValue];
            ((GeneralProductReviewCell *)cell).accuracyrate.starscount = [list.review_rate_accuracy integerValue];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *thumb = ((GeneralProductReviewCell *)cell).thumb;
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default-boy.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
#pragma clang diagnostic pop

            } failure:nil];
        }
        
		return cell;
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
//    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                // see more action
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                 
//                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
             case 11:
            {
                // Action Advance Review Quality / Accuracy
                AlertListView *v = [AlertListView newview];
                v.delegate = self;
                v.tag = 10;
                v.data = @{kTKPDALERTVIEW_DATALISTKEY:kTKPDREVIEW_ALERTRATINGLISTARRAY};
                [v show];
                break;
            }
            case 12:
            {
                // Action Period
                AlertListView *v = [AlertListView newview];
                v.tag = 11;
                v.delegate = self;
                v.data = @{kTKPDALERTVIEW_DATALISTKEY:kTKPDREVIEW_ALERTPERIODSARRAY};
                [v show];
            }
            default:
                break;
        }
//    }
}

- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                _starcount = gesture.view.tag-10;
                _detailstarsandtimesview.hidden = NO;
                if (_isadvreviewquality)
                {
                    [_param setObject:@(0) forKey:kTKPDREVIEW_APIRATEACCURACYKEY];
                    [_param setObject:@(gesture.view.tag-10) forKey:kTKPDTEVIEW_APIRATEQUALITYKEY];
                }else{
                    [_param setObject:@(0) forKey:kTKPDTEVIEW_APIRATEQUALITYKEY];
                    [_param setObject:@(gesture.view.tag-10) forKey:kTKPDREVIEW_APIRATEACCURACYKEY];
                }
                [self refreshView:nil];
                [self setHeaderData];
                break;
            }
                
            default:
                break;
        }
    }
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
    
    //TODO:: Relationship
    RKObjectMapping *advreviewMapping = [RKObjectMapping mappingForClass:[AdvanceReview class]];
    [advreviewMapping addAttributeMappingsFromDictionary:@{
                                                           kTKPDREVIEW_APINETRALQUALITYKEY:kTKPDREVIEW_APINETRALQUALITYKEY,
                                                           kTKPDREVIEW_APINEGATIVEACCURACYKEY:kTKPDREVIEW_APINEGATIVEACCURACYKEY,
                                                           kTKPDREVIEW_APIRATINGACCURACYKEY:kTKPDREVIEW_APIRATINGACCURACYKEY,
                                                           kTKPDREVIEW_APINEGATIVEQUALITYKEY:kTKPDREVIEW_APINEGATIVEQUALITYKEY,
                                                           kTKPDREVIEW_APIPOSITIVEQUALITYKEY:kTKPDREVIEW_APIPOSITIVEQUALITYKEY,
                                                           kTKPDREVIEW_APINETRALACCURACYKEY:kTKPDREVIEW_APINETRALACCURACYKEY,
                                                           kTKPDREVIEW_APIPOSITIVEACCURACYKEY:kTKPDREVIEW_APIPOSITIVEACCURACYKEY,
                                                           kTKPDREVIEW_APITOTALREVIEWKEY:kTKPDREVIEW_APITOTALREVIEWKEY,
                                                           kTKPDREVIEW_APIRATINGQUALITYKEY:kTKPDREVIEW_APIRATINGQUALITYKEY,

                                                           }];
    
    RKObjectMapping *ratinglistMapping = [RKObjectMapping mappingForClass:[RatingList class]];
    [ratinglistMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIRATINGSTARPOINTKEY,
                                                       kTKPDREVIEW_APIRATINGACCURACYKEY,
                                                       kTKPDREVIEW_APIRATINGQUALITYKEY
                                                       ]];
    
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ReviewList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIREVIEWSHOPIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWCREATETIMEKEY,
                                                 kTKPDREVIEW_APIREVIEWIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERNAMEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEQUALITY,
                                                 kTKPDREVIEW_APIREVIEWRATESPEEDKEY,
                                                 CReviewReputationID,
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
//                                                 kTKPDREVIEW_APIREVIEWRESPONSEKEY
                                                 kTKPDREVIEW_APIREVIEWPRODUCTRATEKEY,
                                                 KTKPDREVIEW_APIREVIEWUSERLABELIDKEY,
                                                 KTKPDREVIEW_APIREVIEWUSERLABELKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [responseMapping addAttributeMappingsFromDictionary:@{kTKPDREVIEW_APIRESPONSECREATETIMEKEY:kTKPDREVIEW_APIRESPONSECREATETIMEKEY,
                                                          kTKPDREVIEW_APIRESPONSEMESSAGEKEY:kTKPDREVIEW_APIRESPONSEMESSAGEKEY
                                                          }];

    RKObjectMapping *reviewproductownerMapping = [RKObjectMapping mappingForClass:[ReviewProductOwner class]];
    [reviewproductownerMapping addAttributeMappingsFromDictionary:@{kTKPDREVIEW_APIUSERIDKEY:kTKPDREVIEW_APIUSERIDKEY,
                                                                    kTKPDREVIEW_APIUSERIMAGEKEY:kTKPDREVIEW_APIUSERIMAGEKEY,
                                                                    kTKPDREVIEW_APIUSERNAME:kTKPDREVIEW_APIUSERNAME
                                                                    }];
//
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *responseRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIREVIEWRESPONSEKEY toKeyPath:kTKPDREVIEW_APIREVIEWRESPONSEKEY withMapping:responseMapping];
    [listMapping addPropertyMapping:responseRel];
    
    RKRelationshipMapping *productOwner = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY toKeyPath:kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY withMapping:reviewproductownerMapping];
    [listMapping addPropertyMapping:productOwner];
    
    RKRelationshipMapping *advreviewRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIADVREVIEWKEY toKeyPath:kTKPDREVIEW_APIADVREVIEWKEY withMapping:advreviewMapping];
    [resultMapping addPropertyMapping:advreviewRel];
    
    RKRelationshipMapping *ratinglistRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIRATINGLISTKEY toKeyPath:kTKPDREVIEW_APIRATINGLISTKEY withMapping:ratinglistMapping];
    [advreviewMapping addPropertyMapping:ratinglistRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
        
    _requestcount++;
    
    NSInteger monthrange = [[_param objectForKey:kTKPDREVIEW_APIMONTHRANGEKEY]integerValue];
    NSInteger rateaccuracy = [[_param objectForKey:kTKPDREVIEW_APIRATEACCURACYKEY]integerValue];
    NSInteger ratequality = [[_param objectForKey:kTKPDTEVIEW_APIRATEQUALITYKEY]integerValue];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETPRODUCTREVIEWKEY,
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APILIMITKEY :@(kTKPDDETAILREVIEW_LIMITPAGE),
                            kTKPDREVIEW_APIMONTHRANGEKEY : @(monthrange),
                            kTKPDREVIEW_APIRATEACCURACYKEY : @(rateaccuracy),
                            kTKPDTEVIEW_APIRATEQUALITYKEY : @(ratequality)
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILPRODUCT_APIPATH parameters:[param encrypt]];
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	//if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1) {
        
        //if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
        //}
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestfailure:error];
        }];

        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

    //}else{
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //    NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
    //    NSLog(@"cache and updated in last 24 hours.");
    //    [self requestfailure:nil];
    //}
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _review = stats;
    BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page == 1) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data to plist
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
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _review.result.list;
                _reviewIsOwner = _review.result.is_owner;
                
                [_list addObjectsFromArray:list];
                
                _headerview.hidden = NO;
                _isnodata = NO;
                
                [self setHeaderData];
                if([_list count] > 0) {
                    _urinext =  _review.result.paging.uri_next;
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
                    _table.tableFooterView = nil;
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
                _table.tableFooterView = nil;
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

#pragma mark - Methods

-(void)setHeaderData
{
    _labelstarcount.text = (_starcount>1)?[NSString stringWithFormat:@"%zd ratings",_starcount]:[NSString stringWithFormat:@"%zd rating",_starcount];
    
    NSArray *list =kTKPDREVIEW_ALERTPERIODSARRAY;
    _labeltime.text = (_isalltimes)?[NSString stringWithFormat:@"%@",list[0]]:[NSString stringWithFormat:@"in the past %@",list[1]];
    
    float ratingpoint = (_isadvreviewquality)?_review.result.advance_review.rating_quality_point:_review.result.advance_review.rating_accuracy_point;

    _labeltotalreview.text = [NSString stringWithFormat:@"%f out of %zd",ratingpoint,_review.result.advance_review.total_review];
}

#pragma mark - Delegate
- (void)GeneralProductReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    NSInteger row = indexpath.row;
    DetailReviewViewController *vc = [DetailReviewViewController new];
    ReviewList *reviewlist = _list[row];
    reviewlist.review_product_name = [_data objectForKey:API_PRODUCT_NAME_KEY];
    reviewlist.review_product_id = [_data objectForKey:API_PRODUCT_ID_KEY];
    reviewlist.review_product_image = [_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY];

    vc.data = reviewlist;
    vc.index = [NSString stringWithFormat:@"%ld",(long)row];
    vc.is_owner = _reviewIsOwner;
    vc.indexPath = indexpath;
    
    [self.navigationController pushViewController:vc animated:YES];
    
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

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
        {
            // Alert Quality / Accuracy
            NSArray *list =kTKPDREVIEW_ALERTRATINGLISTARRAY;
            [_buttonadvreview setTitle:list[buttonIndex] forState:UIControlStateNormal];
            _isadvreviewquality = (buttonIndex == 0)?YES:NO;
            [self setHeaderData];

            break;
        }
        case 11:
        {
            // Alert All Times / 6 Months
            NSArray *list =kTKPDREVIEW_ALERTPERIODSARRAY;
            [_buttontime setTitle:list[buttonIndex] forState:UIControlStateNormal];
            _isalltimes = (buttonIndex == 0)?YES:NO;
            [self setHeaderData];
            _detailstarsandtimesview.hidden = NO;
            NSArray *listvalue = kTKPDREVIEW_ALERTPERIODSVALUEARRAY;
            [_param setObject:listvalue[buttonIndex] forKey:kTKPDREVIEW_APIMONTHRANGEKEY];
            [self refreshView:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Notification Center Action
- (void)updateTotalReviewComment:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"index"]integerValue];
    NSIndexPath *indexPath = [userinfo objectForKey:@"indexPath"];
    
    ReviewList *list = _list[index];
    
    list.review_response.response_message = [userinfo objectForKey:@"review_comment"];
    list.review_response.response_create_time = [userinfo objectForKey:@"review_comment_time"];
//    [_table reloadData];
    [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
