//
//  HotlistResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HotlistDetail.h"
#import "SearchResult.h"
#import "List.h"

#import "home.h"
#import "search.h"
#import "sortfiltershare.h"
#import "detail.h"
#import "category.h"

#import "FilterViewController.h"
#import "SortViewController.h"

#import "GeneralProductCell.h"
#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "TKPDTabNavigationController.h"
#import "CategoryMenuViewController.h"
#import "DetailProductViewController.h"

#import "URLCacheController.h"

@interface HotlistResultViewController () <UITableViewDataSource,UITableViewDelegate, GeneralProductCellDelegate>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    NSMutableArray *_product;
    NSMutableDictionary *_paging;
    NSMutableArray *_buttons;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    
    UIBarButtonItem *_barbuttoncategory;
    
    NSInteger _requestcount;
    NSTimer *_timer;
    
    HotlistDetail *_hotlistdetail;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;

    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIScrollView *hashtagsscrollview;
@property (strong, nonatomic) IBOutlet UIView *descriptionview;
@property (weak, nonatomic) IBOutlet UILabel *descriptionlabel;
@property (weak, nonatomic) IBOutlet UIView *filterview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureleft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureright;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation HotlistResultViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _requestcount = 0;
        _isrefreshview = NO;
    }
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // set title navigation
    NSString * title = [_data objectForKey:kTKPDHOME_DATATITLEKEY];
    self.navigationItem.title = title;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _product = [NSMutableArray new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];
    _cachecontroller = [URLCacheController new];
    _cacheconnection = [URLCacheConnection new];
    _operationQueue = [NSOperationQueue new];
    
    // set max data per page request
    _limit = kTKPDHOMEHOTLISTRESULT_LIMITPAGE;
    
    _page = 1;
    
    /** set inset table for different size**/
    //if (is4inch) {
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 150;
    //    _table.contentInset = inset;
    //}
    //else{
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 240;
    //    _table.contentInset = inset;
    //}
    
    _table.tableHeaderView = _header;
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
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
    
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONMORECATEGORY ofType:@"png"]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        //_barbuttoncategory = [[UIBarButtonItem alloc] initWithTitle:@"Category" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    }
    else
        _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[_barbuttoncategory setTag:11];
    _barbuttoncategory.enabled = NO;
    self.navigationItem.rightBarButtonItem = _barbuttoncategory;
    
    // adjust refresh control
    //_refreshControl = [[UIRefreshControl alloc] init];
    //_refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //[_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    //[_table addSubview:_refreshControl];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(setDepartmentID:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    
    UIImageView *imageview = [_data objectForKey:kTKPHOME_DATAHEADERIMAGEKEY];
    if (imageview) {
        _imageview.image = imageview.image;
        _header.hidden = NO;
        _pagecontrol.hidden = YES;
        _swipegestureleft.enabled = NO;
        _swipegestureright.enabled = NO;
    }
    
    [_descriptionview setFrame:CGRectMake(350, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
    [_pagecontrol bringSubviewToFront:_descriptionview];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDHOMEHOTLISTRESULT_CACHEFILEPATH];
    NSString *querry =[_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDHOMEHOTLISTRESULT_APIRESPONSEFILEFORMAT,[_detailfilter objectForKey:kTKPDHOME_DATAQUERYKEY]?:querry]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
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

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
		
		cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralProductCell newcell];
			((GeneralProductCell*)cell).delegate = self;
		}
        
       [self reset:(GeneralProductCell*)cell];
		
        if (_product.count > indexPath.row) {
            /** Flexible view count **/
            NSUInteger indexsegment = indexPath.row * 2;
            NSUInteger indexmax = indexsegment + 2;
            NSUInteger indexlimit = MIN(indexmax, _product.count);
            
            NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
            
            NSUInteger i;
            
            for (i = 0; (indexsegment + i) < indexlimit; i++) {
                List *list = [_product objectAtIndex:indexsegment + i];
                ((UIView*)((GeneralProductCell*)cell).viewcell[i]).hidden = NO;
                (((GeneralProductCell*)cell).indexpath) = indexPath;
                
                ((UILabel*)((GeneralProductCell*)cell).labelprice[i]).text = list.catalog_price?:list.product_price;
                ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).text = list.catalog_name?:list.product_name;
                ((UILabel*)((GeneralProductCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
                
                NSString *urlstring = list.catalog_image?:list.product_image;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                
                UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
                thumb.image = nil;
                
                UIActivityIndicatorView *act = (UIActivityIndicatorView*)((GeneralProductCell*)cell).act[i];
                [act startAnimating];
                
                NSLog(@"============================== START GET IMAGE =====================");
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
                    //NSLOG(@"thumb: %@", thumb);
                    [thumb setImage:image];
                    [thumb setContentMode:UIViewContentModeScaleAspectFill];
                    
                    [act stopAnimating];
                    NSLog(@"============================== DONE GET IMAGE =====================");
    #pragma clang diagnostic pop
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [act stopAnimating];
                    
                    NSLog(@"============================== DONE GET IMAGE =====================");
                }];
            }
        }
	} else {
		static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
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


#pragma mark - Action View
-(IBAction)tap:(id)sender{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        switch (button.tag) {
            case 10:
            {
                //BACK
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                //CATEGORY
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                vc.data = @{kTKPDHOME_APIDEPARTMENTTREEKEY:_departmenttree?:@"",
                            kTKPDCATEGORY_DATAPUSHCOUNTKEY : @([[_detailfilter objectForKey:kTKPDCATEGORY_DATAPUSHCOUNTKEY]integerValue]?:0),
                            kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : [_detailfilter objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY]?:@[],
                            kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @([[_detailfilter objectForKey:kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY]boolValue])?:NO,
                            kTKPDCATEGORY_DATAINDEXPATHKEY :[_detailfilter objectForKey:kTKPDCATEGORY_DATACATEGORYINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@""
                            };
                [self.navigationController pushViewController:vc animated:YES];
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        // buttons tag >=20 are tags untuk hashtags
        if (button.tag >=20) {
            //TODO::
            NSArray *hashtagsarray = _hotlistdetail.result.hashtags;
            Hashtags *hashtags = hashtagsarray[button.tag - 20];
            
            NSURL *url = [NSURL URLWithString:hashtags.url];
            NSArray* querry = [[url path] componentsSeparatedByString: @"/"];
            
            // Redirect URI to search category
            if ([querry[1] isEqualToString:kTKPDHOME_DATAURLREDIRECTCATEGORY]) {
                SearchResultViewController *vc = [SearchResultViewController new];
                NSString *searchtext = hashtags.department_id;
                vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
                SearchResultViewController *vc1 = [SearchResultViewController new];
                vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
                SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
                vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
                NSArray *viewcontrollers = @[vc,vc1,vc2];
                
                TKPDTabNavigationController *c = [TKPDTabNavigationController new];
                
                [c setSelectedIndex:0];
                [c setViewControllers:viewcontrollers];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
                [nav.navigationBar setTranslucent:NO];
                [self.navigationController presentViewController:nav animated:YES completion:nil];

                //[self loadData];
            }
            // redirect uri to search hotlist
            //if ([querry[1] isEqualToString:kTKPDHOME_DATAURLREDIRECTHOTKEY]) {
            //    [_detailfilter setObject:querry[2] forKey:kTKPDHOME_APIQUERYKEY];
            //    [_product removeAllObjects];
            //    [_detailhotlist removeAllObjects];
            //    [self loadData];
            //}
        }
        else
        {
            switch (button.tag) {
                case 10:
                {
                    // URUTKAN
                    NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    SortViewController *vc = [SortViewController new];
                    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEHOTLISTVIEWKEY),
                                kTKPDFILTER_DATAINDEXPATHKEY: indexpath};

                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    break;
                }
                case 11:
                {
                    // FILTER
                    FilterViewController *vc = [FilterViewController new];
                    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEHOTLISTVIEWKEY),
                                kTKPDFILTER_DATAFILTERKEY: _detailfilter};
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    break;
                }
                case 12:
                {
                    //SHARE
                    break;
                }
                default:
                    break;
            }
        }
    }
}
- (IBAction)gesture:(id)sender {
    
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)sender;
        switch (swipe.state) {
            case UIGestureRecognizerStateEnded: {
                if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
                    [self descriptionviewhideanimation:YES];
                    _pagecontrol.currentPage=0;
                }
               if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
                   [self descriptionviewshowanimation:YES];
                   _pagecontrol.currentPage=1;
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void)descriptionviewshowanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(_imageview.frame.origin.x, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [self.view addSubview:_descriptionview];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}
-(void)descriptionviewhideanimation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(350, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [self.view addSubview:_descriptionview];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}


#pragma mark - Request + Mapping
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[HotlistDetail class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HotlistDetailResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APICOVERIMAGEKEY:kTKPDHOME_APICOVERIMAGEKEY,
                                                        KTKPDHOME_APIDESCRIPTIONKEY:KTKPDHOME_APIDESCRIPTION1KEY}];
    
    // list mapping
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[List class]];
    [hotlistMapping addAttributeMappingsFromArray:@[kTKPDHOME_APICATALOGIMAGEKEY,
                                                    kTKPDHOME_APICATALOGNAMEKEY,
                                                    kTKPDHOME_APICATALOGPRICEKEY,
                                                    kTKPDHOME_APIPRODUCTPRICEKEY,
                                                    kTKPDHOME_APIPRODUCTIDKEY,
                                                    kTKPDHOME_APISHOPGOLDSTATUSKEY,
                                                    kTKPDHOME_APISHOPLOCATIONKEY,
                                                    kTKPDHOME_APISHOPNAMEKEY,
                                                    kTKPDHOME_APIPRODUCTIMAGEKEY,
                                                    kTKPDHOME_APIPRODUCTNAMEKEY
                                                    ]];
    
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APIURINEXTKEY:kTKPDHOME_APIURINEXTKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // hashtags mapping
    RKObjectMapping *hashtagMapping = [RKObjectMapping mappingForClass:[Hashtags class]];
    [hashtagMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIHASHTAGSNAMEKEY, kTKPDHOME_APIHASHTAGSURLKEY, kTKPDHOME_APIDEPARTMENTIDKEY]];

    // departmenttree mapping
    RKObjectMapping *departmentMapping = [RKObjectMapping mappingForClass:[DepartmentTree class]];
    [departmentMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIHREFKEY,
                                                       kTKPDHOME_APITREEKEY,
                                                       kTKPDHOME_APIDIDKEY,
                                                       kTKPDHOME_APITITLEKEY
                                                       ]];
    // Adjust Relationship
    //add Department tree relationship
    RKRelationshipMapping *depttreeRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIDEPARTMENTTREEKEY toKeyPath:kTKPDHOME_APIDEPARTMENTTREEKEY withMapping:departmentMapping];
    [resultMapping addPropertyMapping:depttreeRel];
    
    //add list relationship
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:hotlistMapping];
    [resultMapping addPropertyMapping:listRel];

    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // hastags relationship
    RKRelationshipMapping *hashtagRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIHASHTAGSKEY toKeyPath:kTKPDHOME_APIHASHTAGSKEY withMapping:hashtagMapping];
    [resultMapping addPropertyMapping:hashtagRel];
    
    // departmentchild relationship
    RKRelationshipMapping *deptchildRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APICHILDTREEKEY toKeyPath:kTKPDHOME_APICHILDTREEKEY withMapping:departmentMapping];
    [departmentMapping addPropertyMapping:deptchildRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    // add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];

}


- (void)loadData
{
    if(_request.isExecuting)return;
    
    _requestcount ++;
    
    NSString *querry =[_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";

	NSDictionary* param = @{
                            //@"auth":@(1),
                            kTKPDHOME_APIQUERYKEY : [_detailfilter objectForKey:kTKPDHOME_DATAQUERYKEY]?:querry,
                            kTKPDHOME_APIPAGEKEY : @(_page),
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLISTRESULT_LIMITPAGE),
                            kTKPDHOME_APIORDERBYKEY : [_detailfilter objectForKey:kTKPDHOME_APIORDERBYKEY]?:@"",
                            kTKPDHOME_APIDEPARTMENTIDKEY: [_detailfilter objectForKey:kTKPDHOME_APIDEPARTMENTIDKEY]?:@"",
                            kTKPDHOME_APILOCATIONKEY :[_detailfilter objectForKey:kTKPDHOME_APILOCATIONKEY]?:@"",
                            kTKPDHOME_APISHOPTYPEKEY :[_detailfilter objectForKey:kTKPDHOME_APISHOPTYPEKEY]?:@"",
                            kTKPDHOME_APIPRICEMINKEY :[_detailfilter objectForKey:kTKPDHOME_APIPRICEMINKEY]?:@"",
                            kTKPDHOME_APIPRICEMAXKEY :[_detailfilter objectForKey:kTKPDHOME_APIPRICEMAXKEY]?:@""
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDHOMEHOTLISTRESULT_APIPATH parameters:param];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        //[_cachecontroller clearCache];
        _table.tableFooterView = _footer;
        [_act startAnimating];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_table reloadData];
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            NSLog(@"============================== DONE GET HOTLIST DETAIL =====================");
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
            [_act stopAnimating];
            _table.tableFooterView = nil;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            NSLog(@"============================== DONE GET HOTLIST DETAIL =====================");
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
	else {
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
    id info = [result objectForKey:@""];
    _hotlistdetail = info;
    NSString *statusstring = _hotlistdetail.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1 && !_isrefreshview) {
            //only save cache for first page
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data to plist
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
            id info = [result objectForKey:@""];
            _hotlistdetail = info;
            NSString *statusstring = _hotlistdetail.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            id info = [result objectForKey:@""];
            _hotlistdetail = info;
            NSString *statusstring = _hotlistdetail.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                
                if (_page == 1) {
                    [_product removeAllObjects];
                }
                
                [_product addObjectsFromArray: _hotlistdetail.result.list];
                _pagecontrol.hidden = NO;
                _swipegestureleft.enabled = YES;
                _swipegestureright.enabled = YES;
                [self setHeaderData];
                
                NSArray * departmenttree = _hotlistdetail.result.department_tree;
                
                //[_departmenttree removeAllObjects];
                if (_departmenttree.count == 0) {
                    [_departmenttree addObjectsFromArray:departmenttree];
                }
                
                if (_product.count >0) {
                    
                    _descriptionview.hidden = NO;
                    _header.hidden = NO;
                    _filterview.hidden = NO;
                    
                    _urinext =  _hotlistdetail.result.paging.uri_next;
                    
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
                    
                    NSLog(@"next page : %d",_page);
                    
                    _isnodata = NO;
                    
                    _filterview.hidden = NO;
                    _barbuttoncategory.enabled = YES;
                    
                    
                    
                }
            }
        }
    }
    else{
        [self cancel];
        NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
        if ([(NSError*)object code] == NSURLErrorCancelled) {
            if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                _table.tableFooterView = _footer;
                [_act startAnimating];
                [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            }
        }
        else
        {
            [_act stopAnimating];
            _table.tableFooterView = nil;
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Cell Delegate
-(void)GeneralProductCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    NSInteger index = indexpath.section+2*(indexpath.row);
    List *list = _product[index];
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Methods
-(void)setHeaderData
{
    if (![_data objectForKey:kTKPHOME_DATAHEADERIMAGEKEY]) {
        NSString *urlstring = _hotlistdetail.result.cover_image;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = _imageview;
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [_act startAnimating];
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
            [thumb setImage:image animated:YES];
            
            [_act stopAnimating];
#pragma clang diagnostic pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [_act stopAnimating];
        }];
    }
    
    _descriptionlabel.text = [NSString convertHTML: _hotlistdetail.result.desc_key];
    [self setHashtags];
}

-(void)setHashtags
{
    NSInteger widthcontenttop=0;
    _buttons = [NSMutableArray new];
    
    NSArray *array = _hotlistdetail.result.hashtags;
    
    /** Adjust hashtags to Scrollview **/
    for (int i = 0; i<array.count; i++) {
        Hashtags *hashtag =array[i];
        NSString *name = [@"# " stringByAppendingFormat:hashtag.name];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:name forState:UIControlStateNormal];

        UIFont * font = kTKPDHOME_FONTSLIDETITLES;
        button.titleLabel.font = font;
        //button.tintColor = [UIColor blackColor];
        
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        CGSize stringSize = [name sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
        CGFloat widthlabel = stringSize.width+10;
        
        
        button.frame = CGRectMake(widthcontenttop,_hashtagsscrollview.frame.size.height/2-10,widthlabel,30);
        button.tag = i+20;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        
        widthcontenttop +=widthlabel;
        
        [_buttons addObject:button];
        [_hashtagsscrollview addSubview:_buttons[i]];
    }
    
    _hashtagsscrollview.contentSize = CGSizeMake(widthcontenttop+10, 0);
}

-(void)reset:(UITableViewCell*)cell
{
    [((GeneralProductCell*)cell).thumb makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    [((GeneralProductCell*)cell).labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [((GeneralProductCell*)cell).viewcell makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_product removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Post Notification Methods

-(void)setDepartmentID:(NSNotification*)notification
{
    [self cancel];
    NSDictionary* userinfo = notification.userInfo;
    [_detailfilter addEntriesFromDictionary:userinfo];
    [self refreshView:nil];
}

- (void)updateView:(NSNotification *)notification;
{
    [self cancel];
    NSDictionary *userinfo = notification.userInfo;
    [_detailfilter addEntriesFromDictionary:userinfo];
    [self refreshView:nil];
}

@end
