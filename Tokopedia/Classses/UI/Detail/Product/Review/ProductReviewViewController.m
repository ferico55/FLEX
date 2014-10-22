//
//  ProductReviewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "alert.h"

#import "Review.h"
#import "StarsRateView.h"
#import "ProgressBarView.h"
#import "ProductReviewViewController.h"
#import "ProductReviewDetailViewController.h"
#import "GeneralReviewCell.h"

#import "TKPDAlertView.h"
#import "AlertListView.h"
#import "StickyAlert.h"

#pragma mark - Product Review View Controller
@interface ProductReviewViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate, GeneralReviewCellDelegate>
{
    NSMutableDictionary *_param;
    NSMutableArray *_list;
    NSMutableArray *_listresponse;
    NSInteger _requestcount;
    NSTimer *_timer;
    BOOL _isnodata;
    
    NSInteger _starcount;
    
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
    
    _list = [NSMutableArray new];
    _param = [NSMutableDictionary new];
    
    _table.tableFooterView = _footer;
    _table.tableHeaderView = _headerview;
    _headerview.hidden = YES;
    
    _page = 1;
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
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
        
        NSString *cellid = kTKPDGENERALREVIEWCELLIDENTIFIER;
		
		cell = (GeneralReviewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralReviewCell newcell];
			((GeneralReviewCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ReviewList *list = _list[indexPath.row];

            
            ((GeneralReviewCell*)cell).namelabel.text = list.review_user_name;
            ((GeneralReviewCell*)cell).timelabel.text = list.review_create_time;
            ((GeneralReviewCell*)cell).commentlabel.text = list.review_message;
            ((GeneralReviewCell*)cell).indexpath = indexPath;
            
            
            ReviewResponse *review_response = list.review_response;
            [((GeneralReviewCell*)cell).commentbutton setTitle:([review_response.response_message isEqualToString:@"0"] ? @"0 Comment" : @"1 Comment") forState:UIControlStateNormal];
            
            
            //TODO:: create see more button
            //UIFont * font = ((ProductReviewCell*)cell).commentlabel.font ;
            //CGSize stringSize = [((ProductReviewCell*)cell).commentlabel.text sizeWithFont:font];
            //CGFloat widthlabel = stringSize.width;
            //CGFloat heightlabel = stringSize.height;
            //UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            //[button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
            //[button setTitle:@"See More" forState:UIControlStateNormal];
            //[button setFrame:CGRectMake(widthlabel,heightlabel, ((ProductReviewCell*)cell).commentlabel.frame.size.width, ((ProductReviewCell*)cell).commentlabel.frame.size.height)];
            //button.tag = 10;
            ((GeneralReviewCell*)cell).qualityrate.starscount = list.review_rate_quality;
            ((GeneralReviewCell*)cell).speedrate.starscount = list.review_rate_speed;
            ((GeneralReviewCell*)cell).servicerate.starscount = list.review_rate_service;
            ((GeneralReviewCell*)cell).accuracyrate.starscount = list.review_rate_accuracy;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            UIImageView *thumb = ((GeneralReviewCell*)cell).thumb;
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
//    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                // see more action
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                id stickyalert = [StickyAlert new];
//                StickyAlert *stickyalert = [[StickyAlert alloc]init];
                [stickyalert initView:self.view];
                [stickyalert alertError:[NSArray arrayWithObjects:@"Error 1", @"Error 2", @"Error3",@"Error3",@"Error3",@"Error3",@"Error3", nil]];
                
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
                                                           kTKPDREVIEW_APIRATINGQUALITYKEY:kTKPDREVIEW_APIRATINGQUALITYKEY
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
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
//                                                 kTKPDREVIEW_APIREVIEWRESPONSEKEY
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
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APILISTKEY toKeyPath:kTKPDDETAIL_APILISTKEY withMapping:listMapping];
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
    _requestcount++;
    
    //if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    //}
    
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
    
    [_objectmanager getObjectsAtPath:kTKPDDETAILPRODUCT_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestsuccess:mappingResult];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self requestfailure:error];
    }];

    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _review = stats;
    BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        NSArray *list = _review.result.list;
        [_list addObjectsFromArray:list];
        _headerview.hidden = NO;
        _isnodata = NO;
        
        [self setHeaderData];
                
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
        NSLog(@"next page : %d",_page);

        [_table reloadData];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
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

#pragma mark - Methods

-(void)setHeaderData
{
    _labelstarcount.text = (_starcount>1)?[NSString stringWithFormat:@"%d ratings",_starcount]:[NSString stringWithFormat:@"%d rating",_starcount];
    
    NSArray *list =kTKPDREVIEW_ALERTPERIODSARRAY;
    _labeltime.text = (_isalltimes)?[NSString stringWithFormat:@"%@",list[0]]:[NSString stringWithFormat:@"in the past %@",list[1]];
    
    float ratingpoint = (_isadvreviewquality)?_review.result.advance_review.rating_quality_point:_review.result.advance_review.rating_accuracy_point;

    _labeltotalreview.text = [NSString stringWithFormat:@"%f out of %d",ratingpoint,_review.result.advance_review.total_review];
    
    NSArray *ratinglist = _review.result.advance_review.rating_list;
    
    for (RatingList *list in ratinglist) {
        NSInteger starpoint = list.rating_star_point;
        ((ProgressBarView*)_progressviews[starpoint-1]).floatcount =(_isadvreviewquality)?list.rating_quality_point:list.rating_accuracy_point;
    }
}

#pragma mark - Delegate
- (void)GeneralReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    ProductReviewDetailViewController *vc = [ProductReviewDetailViewController new];
    
    ReviewList *list = _list[indexpath.row];

    vc.data = @{
                kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY]?:@(""),
                kTKPDDETAILPRODUCT_APIIMAGESRCKEY:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]?:@(""),
                //ini untuk review
                kTKPDREVIEW_APIREVIEWMESSAGEKEY:list.review_message,
                kTKPDREVIEW_APIREVIEWCREATETIMEKEY:list.review_create_time,
                kTKPDREVIEW_APIREVIEWUSERNAMEKEY:list.review_user_name,
                kTKPDREVIEW_APIREVIEWUSERIMAGEKEY:list.review_user_image,
                kTKPDREVIEW_APIREVIEWUSERIDKEY:list.review_user_id,
                kTKPDREVIEW_APIREVIEWRESPONSEKEY:list.review_response,
                kTKPDREVIEW_APIREVIEWRATEACCURACYKEY:@(list.review_rate_accuracy),
                kTKPDREVIEW_APIREVIEWRATEQUALITY:@(list.review_rate_quality),
                kTKPDREVIEW_APIREVIEWRATESERVICEKEY:@(list.review_rate_service),
                kTKPDREVIEW_APIREVIEWRATESPEEDKEY:@(list.review_rate_speed),
                kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY:list.review_product_owner
                };
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

@end
