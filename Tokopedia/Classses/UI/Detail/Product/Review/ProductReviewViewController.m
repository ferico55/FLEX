//
//  ProductReviewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"

#import "Review.h"
#import "StarsRateView.h"
#import "ProductReviewViewController.h"
#import "ProductReviewCell.h"

#pragma mark - Product Review View Controller
@interface ProductReviewViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_list;
    NSInteger _requestcount;
    NSTimer *_timer;
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    NSString *_urinext;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet StarsRateView *averagerateview;
@property (weak, nonatomic) IBOutlet UILabel *scalelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ProductReviewViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    
    _table.tableFooterView = _footer;
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
        
        NSString *cellid = kTKPDPRODUCTREVIEWCELLIDENTIFIER;
		
		cell = (ProductReviewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ProductReviewCell newcell];
			//((ProductReviewCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ReviewList *list = _list[indexPath.row];
            ((ProductReviewCell*)cell).namelabel.text = list.review_user_name;
            ((ProductReviewCell*)cell).timelabel.text = list.review_create_time;
            ((ProductReviewCell*)cell).commentlabel.text = list.review_message;
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
            ((ProductReviewCell*)cell).qualityrate.starscount = list.review_rate_quality;
            ((ProductReviewCell*)cell).speedrate.starscount = list.review_rate_speed;
            ((ProductReviewCell*)cell).servicerate.starscount = list.review_rate_service;
            ((ProductReviewCell*)cell).accuracyrate.starscount = list.review_rate_accuracy;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            UIImageView *thumb = ((ProductReviewCell*)cell).thumb;
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
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIEDNTIFIER;
        
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
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
                // see more action
                
                break;
                
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
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPDDETAIL_APISTATUSKEY,kTKPDDETAIL_APISERVERPROCESSTIMEKEY,kTKPDDETAIL_APIRESULTKEY]];
    
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
                                                 //kTKPDREVIEW_APIREVIEWRESPONSEKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
//    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
//    [responseMapping addAttributeMappingsFromDictionary:@{kTKPDREVIEW_APIRESPONSECREATETIMEKEY:kTKPDREVIEW_APIRESPONSECREATETIMEKEY,
//                                                          kTKPDREVIEW_APIRESPONSEMESSAGEKEY:kTKPDREVIEW_APIRESPONSEMESSAGEKEY
//                                                          }];
//    
//    RKObjectMapping *reviewproductownerMapping = [RKObjectMapping mappingForClass:[ReviewProductOwner class]];
//    [reviewproductownerMapping addAttributeMappingsFromDictionary:@{kTKPDREVIEW_APIUSERIDKEY:kTKPDREVIEW_APIUSERIDKEY,
//                                                                    kTKPDREVIEW_APIUSERIMAGEKEY:kTKPDREVIEW_APIUSERIMAGEKEY,
//                                                                    kTKPDREVIEW_APIUSERNAME:kTKPDREVIEW_APIUSERNAME
//                                                                    }];
//    
    //add relationship mapping
//    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIREVIEWRESPONSEKEY toKeyPath:kTKPDREVIEW_APIREVIEWRESPONSEKEY withMapping:responseMapping]];
//    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY toKeyPath:kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY withMapping:reviewproductownerMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorlist = [RKResponseDescriptor responseDescriptorWithMapping:listMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APILISTKEYPATH statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseDescriptorPaging = [RKResponseDescriptor responseDescriptorWithMapping:pagingMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:kTKPDDETAIL_APIPAGINGKEYPATH statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    [_objectmanager addResponseDescriptor:responseDescriptorlist];
    [_objectmanager addResponseDescriptor:responseDescriptorPaging];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptorlist.mapping forKey:(responseDescriptorlist.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorPaging.mapping forKey:(responseDescriptorPaging.keyPath ?: [NSNull null])];
}

- (void)loadData
{
    _requestcount++;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETPRODUCTREVIEWKEY,
                            kTKPDDETAIL_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APILIMITKEY :@(kTKPDDETAILREVIEW_LIMITPAGE)
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
    
    Review *review = stats;
    BOOL status = [review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        id page =[result objectForKey:kTKPDDETAIL_APIPAGINGKEYPATH];
        NSArray *list = [result objectForKey:kTKPDDETAIL_APILISTKEYPATH];
        [_list addObjectsFromArray:list];
        _headerview.hidden = NO;
        _isnodata = NO;
        
        Paging *paging = page;
        _urinext =  paging.uri_next;
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

-(void)setHeaderData:(NSDictionary*)data
{

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

@end
