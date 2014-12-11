//
//  ShopReviewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "detail.h"
#import "alert.h"

#import "Review.h"
#import "StarsRateView.h"
#import "ProgressBarView.h"
#import "GeneralReviewCell.h"

#import "TKPDAlertView.h"
#import "AlertListView.h"
#import "ShopReviewViewController.h"

#import "URLCacheController.h"

#pragma mark - Shop Review View Controller
@interface ShopReviewViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate>
{
    NSMutableDictionary *_param;
    NSMutableArray *_list;
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
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UIView *detailstarsandtimesview;
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
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;
@end

@implementation ShopReviewViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isadvreviewquality = YES;
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _ratingviews = [NSArray sortViewsWithTagInArray:_ratingviews];
    _labelstars = [NSArray sortViewsWithTagInArray:_labelstars];
    _progressviews = [NSArray sortViewsWithTagInArray:_progressviews];
    
    _list = [NSMutableArray new];
    _param = [NSMutableDictionary new];
    
    _table.tableHeaderView = _headerview;
    _headerview.hidden = YES;
    
    _page = 1;
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
//    //cache
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
//    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPREVIEW_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
//    _cachecontroller.filePath = _cachepath;
//    _cachecontroller.URLCacheInterval = 86400.0;
//	[_cachecontroller initCacheWithDocumentPath:path];
    
    UIEdgeInsets inset = _table.contentInset;
    inset.bottom += 50;
    _table.contentInset = inset;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self request];
        }
    }
    self.table.contentOffset = CGPointMake(0, 0);
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
		}
        
        if (_list.count > indexPath.row) {
            
            ReviewList *list = _list[indexPath.row];
            
            ((GeneralReviewCell*)cell).userNamelabel.text = list.review_user_name;
            ((GeneralReviewCell*)cell).timelabel.text = list.review_create_time;

            ((GeneralReviewCell*)cell).productNamelabel.text = list.review_product_name;
            
            ((GeneralReviewCell *)cell).productNamelabel.text = list.review_product_name;
            if ([list.review_message length] > 30) {
                NSRange stringRange = {0, MIN([list.review_message length], 30)};
                stringRange = [list.review_message rangeOfComposedCharacterSequencesForRange:stringRange];
                ((GeneralReviewCell *)cell).commentlabel.text = [NSString stringWithFormat:@"%@...", [list.review_message substringWithRange:stringRange]];
            } else {
                ((GeneralReviewCell *)cell).commentlabel.text = list.review_message;
            }
            
            ((GeneralReviewCell*)cell).qualityrate.starscount = list.review_rate_quality;
            ((GeneralReviewCell*)cell).speedrate.starscount = list.review_rate_speed;
            ((GeneralReviewCell*)cell).servicerate.starscount = list.review_rate_service;
            ((GeneralReviewCell*)cell).accuracyrate.starscount = list.review_rate_accuracy;
            
            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *userImageView = ((GeneralReviewCell *)cell).userImageView;
            userImageView.image = nil;
            [userImageView setImageWithURLRequest:userImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [userImageView setImage:image];
#pragma clang diagnostic pop
            } failure:nil];
            
            NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *productImageView = ((GeneralReviewCell*)cell).productImageView;
            productImageView.image = nil;
            [productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [productImageView setImage:image];
#pragma clang diagnostic pop
            } failure:nil];
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
            [self request];
        }
	}
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableParentScroll" object:nil];
        _table.scrollEnabled = NO;
    } else {
        _table.scrollEnabled = YES;
    }
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
                // see more action
                
                break;
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
    }
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
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEQUALITY,
                                                 kTKPDREVIEW_APIREVIEWRATESPEEDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIPRODUCTNAMEKEY,
                                                 kTKPDREVIEW_APIPRODUCTIDKEY,
                                                 kTKPDREVIEW_APIPRODUCTIMAGEKEY,
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPREVIEWKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APILIMITKEY :@(kTKPDDETAILREVIEW_LIMITPAGE),
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOP_APIPATH parameters:param];
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
    _review = stats;
    BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
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
            else{
                [self cancel];
                NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
                if ([(NSError*)object code] == NSURLErrorCancelled) {
                    if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                        NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                        _table.tableFooterView = _footer;
                        [_act startAnimating];
                        [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                        [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
}

-(void)requesttimeout
{
    [self cancel];
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
    [self request];
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

