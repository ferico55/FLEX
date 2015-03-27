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

#import "string_home.h"
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
#import "GeneralAlertCell.h"

#import "GeneralSingleProductCell.h"
#import "GeneralPhotoProductCell.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

@interface HotlistResultViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    GeneralProductCellDelegate,
    CategoryMenuViewDelegate,
    SortViewControllerDelegate,
    FilterViewControllerDelegate,
    GeneralSingleProductDelegate,
    GeneralPhotoProductDelegate
>
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
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (nonatomic) UITableViewCellType cellType;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
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
    if ([_data objectForKey:kTKPDHOME_DATATITLEKEY]) {
        self.title = [_data objectForKey:kTKPDHOME_DATATITLEKEY];
    } else if ([_data objectForKey:kTKPDSEARCHHOTLIST_APIQUERYKEY]) {
        self.title = [[[_data objectForKey:kTKPDSEARCHHOTLIST_APIQUERYKEY] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    }
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
    
    _table.tableHeaderView = _header;
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    backBarButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    _barbuttoncategory = [[UIBarButtonItem alloc] initWithTitle:@"Kategori"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(tap:)];
    _barbuttoncategory.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttoncategory;
    
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
    self.navigationController.navigationBar.translucent = NO;
    
    self.cellType = UITableViewCellTypeTwoColumn;
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
    
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        count = _product.count;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        count = (_product.count%3==0)?_product.count/3:_product.count/3+1;
    }
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellType == UITableViewCellTypeOneColumn) {
        return 230;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        return 215;
    } else {
        return 103;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (_isnodata) {
        static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
    } else {
        if (self.cellType == UITableViewCellTypeOneColumn) {
            cell = [self tableView:tableView oneColumnCellForRowAtIndexPath:indexPath];
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            cell = [self tableView:tableView twoColumnCellForRowAtIndexPath:indexPath];
        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            cell = [self tableView:tableView threeColumnCellForRowAtIndexPath:indexPath];
        }
    }
	return cell;
}

- (GeneralSingleProductCell *)tableView:(UITableView *)tableView oneColumnCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GeneralSingleProductCell *cell;
    
    NSString *cellIdentifier = kTKPDGENERAL_SINGLE_PRODUCT_CELL_IDENTIFIER;

    cell = (GeneralSingleProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [GeneralSingleProductCell initCell];
        cell.delegate = self;
    }
    
    List *list = [_product objectAtIndex:indexPath.row];
    
    cell.productNameLabel.text = list.product_name;
    cell.productPriceLabel.text = list.product_price;

    UIFont *boldFont = [UIFont fontWithName:@"GothamMedium" size:12];
    
    NSString *stats = [NSString stringWithFormat:@"%@ Ulasan   %@ Diskusi",
                       list.product_review_count,
                       list.product_talk_count];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:stats];
    [attributedText addAttribute:NSFontAttributeName
                           value:boldFont
                           range:NSMakeRange(0, list.product_review_count.length)];
    [attributedText addAttribute:NSFontAttributeName
                           value:boldFont
                           range:NSMakeRange(list.product_review_count.length + 11, list.product_talk_count.length)];

    cell.productInfoLabel.attributedText = attributedText;

    cell.indexPath = indexPath;

    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image_full]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    cell.productImageView.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
    cell.productImageView.contentMode = UIViewContentModeCenter;
    
    [cell.productImageView setImageWithURLRequest:request
                 placeholderImage:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                              [cell.productImageView setImage:image animated:YES];
                              [cell.productImageView setContentMode:UIViewContentModeScaleAspectFill];
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                              cell.productImageView.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
                          }];

    return cell;
}

- (GeneralProductCell *)tableView:(UITableView *)tableView twoColumnCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GeneralProductCell* cell = nil;

    NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
    
    cell = (GeneralProductCell *)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralProductCell newcell];
        cell.delegate = self;
    }
    
    [self reset:cell];
    
    if (_product.count > indexPath.row) {
        /** Flexible view count **/
        NSUInteger indexSegment = indexPath.row * 2;
        NSUInteger indexMax = indexSegment + 2;
        NSUInteger indexLimit = MIN(indexMax, _product.count);
        
        NSAssert(!(indexLimit > _product.count), @"producs out of bounds");
        
        NSUInteger i;
        
        for (i = 0; (indexSegment + i) < indexLimit; i++) {
            List *list = [_product objectAtIndex:indexSegment + i];
            
            ((UIView *)[cell.viewcell objectAtIndex:i]).hidden = NO;
            
            cell.indexpath = indexPath;

            [[cell.labelprice objectAtIndex:i] setText:list.catalog_price?:list.product_price animated:YES];
            [[cell.labeldescription objectAtIndex:i] setText:list.catalog_name?:list.product_name animated:YES];
            [[cell.labelalbum objectAtIndex:i] setText:list.shop_name?:@"" animated:YES];
            
            NSString *urlString = list.catalog_image?:list.product_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)[cell.thumb objectAtIndex:i];
            thumb.image = nil;
            
            NSLog(@"============================== START GET IMAGE =====================");
            [thumb setImageWithURLRequest:request
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
                [thumb setContentMode:UIViewContentModeScaleAspectFill];
#pragma clang diagnostic pop
            } failure:nil];
        }
    }
    return cell;
}

- (GeneralPhotoProductCell *)tableView:(UITableView *)tableView threeColumnCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = kTKPDGENERAL_PHOTO_PRODUCT_CELL_IDENTIFIER;

    GeneralPhotoProductCell *cell;

    cell = (GeneralPhotoProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [GeneralPhotoProductCell initCell];
        cell.delegate = self;
    }
    cell.indexPath = indexPath;
    
    NSUInteger index = indexPath.row * 3;
    
    for (int i = 0; i < cell.productImageViews.count; i++) {
        NSUInteger indexProduct = index + i;
        if (indexProduct < _product.count) {
            List *list = [_product objectAtIndex:indexProduct];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

            UIImageView *thumb = [cell.productImageViews objectAtIndex:i];
            thumb.hidden = NO;
            thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
            thumb.contentMode = UIViewContentModeCenter;

            [thumb setImageWithURLRequest:request
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      thumb.image = image;
                                      thumb.contentMode = UIViewContentModeScaleAspectFill;
#pragma clang diagnostic pop
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
                                  }];
        }
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


#pragma mark - Action View
-(IBAction)tap:(id)sender{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        switch (button.tag) {
            case 10:
            {
                //BACK
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                //CATEGORY
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                vc.data = @{kTKPDHOME_APIDEPARTMENTTREEKEY:_departmenttree?:@(0),
                            kTKPDCATEGORY_DATAPUSHCOUNTKEY : @([[_detailfilter objectForKey:kTKPDCATEGORY_DATAPUSHCOUNTKEY]integerValue]?:0),
                            kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : [_detailfilter objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY]?:@[],
                            kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @([[_detailfilter objectForKey:kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY]boolValue])?:NO,
                            kTKPDCATEGORY_DATAINDEXPATHKEY :[_detailfilter objectForKey:kTKPDCATEGORY_DATACATEGORYINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            DATA_PUSH_COUNT_CONTROL : @([[_detailfilter objectForKey:DATA_PUSH_COUNT_CONTROL]integerValue])
                            };
                vc.delegate = self;
                
                UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];                
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
                vc.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
                SearchResultViewController *vc1 = [SearchResultViewController new];
                vc1.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
                SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
                vc2.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
                NSArray *viewcontrollers = @[vc,vc1,vc2];
                
                TKPDTabNavigationController *c = [TKPDTabNavigationController new];
                [c setNavigationTitle:hashtags.name];
                [c setSelectedIndex:0];
                [c setViewControllers:viewcontrollers];
                [self.navigationController pushViewController:c animated:YES];
            }
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
                    vc.delegate = self;
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    break;
                }
                case 11:
                {
                    // FILTER
                    FilterViewController *vc = [FilterViewController new];
                    vc.delegate = self;
                    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEHOTLISTVIEWKEY),
                                kTKPDFILTER_DATAFILTERKEY: _detailfilter};
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    break;
                }
                case 12:
                {
                    // SHARE
                    NSString *activityItem = [NSString stringWithFormat:@"Jual %@ | Tokopedia %@", [_data objectForKey:@"title"], [_data objectForKey:@"url"]];
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityItem,]
                                                                                                     applicationActivities:nil];
                    activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                    [self presentViewController:activityController animated:YES completion:nil];
                    break;
                }
                case 13:
                {
                    if (self.cellType == UITableViewCellTypeOneColumn) {
                        self.cellType = UITableViewCellTypeTwoColumn;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                               forState:UIControlStateNormal];
                        
                    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
                        self.cellType = UITableViewCellTypeThreeColumn;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                               forState:UIControlStateNormal];

                    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
                        self.cellType = UITableViewCellTypeOneColumn;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                               forState:UIControlStateNormal];
                        
                    }
                    self.table.contentOffset = CGPointMake(0, 0);
                    [self.table reloadData];
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
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(_imageview.frame.origin.x, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [_imageview addSubview:_descriptionview];
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
                            options: UIViewAnimationOptionCurveEaseInOut
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
                                                    kTKPDHOME_APIPRODUCTIMAGEFULLKEY,
                                                    kTKPDHOME_APIPRODUCTNAMEKEY,
                                                    kTKPDHOME_APIPRODUCTREVIEWCOUNTKEY,
                                                    kTKPDHOME_APIPRODUCTTALKCOUNTKEY
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    // add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];

}


- (void)request
{
    if(_request.isExecuting)return;
    
    _requestcount ++;
    
    NSString *querry =[_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";

	NSDictionary* param = @{
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
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDHOMEHOTLISTRESULT_APIPATH
                                                                parameters:[param encrypt]];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        //[_cachecontroller clearCache];
        _table.tableFooterView = _footer;
        [_act startAnimating];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self requestsuccess:mappingResult withOperation:operation];
            [_act stopAnimating];
            [_act setHidden:YES];
//            _table.tableFooterView = nil;
            [_table reloadData];
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [self requestfailure:error];
            [_act stopAnimating];
            [_act setHidden:YES];
//            _table.tableFooterView = nil;
            [_refreshControl endRefreshing];
            [_timer invalidate];
            _timer = nil;
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
                    
                    NSLog(@"next page : %zd",_page);
                    
                    _isnodata = NO;
                    
                    _filterview.hidden = NO;
                    
                } else {
                    
                    NoResultView *noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 103)];
                    _table.tableFooterView = noResultView;
                    _table.sectionFooterHeight = noResultView.frame.size.height;
                    
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
                [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            }
            else
            {
                NSError *error = object;
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
        else
        {
            [_act stopAnimating];
            [_act setHidden:YES];
//            _table.tableFooterView = nil;
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Cell Delegate

-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 0;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        index = indexPath.row;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        index = indexPath.section+2*(indexPath.row);
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        index = indexPath.section+3*(indexPath.row);
    }
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
            [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
            [_act stopAnimating];
            [_act setHidden:YES];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [_act stopAnimating];
            [_act setHidden:YES];
        }];
    }
    
    if (_hotlistdetail.result.desc_key) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     };
        
        _descriptionlabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML: _hotlistdetail.result.desc_key]
                                                                           attributes:attributes];
    }
    
    [self setHashtags];
}

-(void)setHashtags
{
    _buttons = [NSMutableArray new];
    
    NSArray *hashtags = _hotlistdetail.result.hashtags;
    
    CGFloat previousButtonWidth = 10;
    CGFloat totalWidth = 10;
    
    for (int i = 0; i<hashtags.count; i++) {
        Hashtags *hashtag = hashtags[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:[NSString stringWithFormat:@"#%@", hashtag.name] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor]
                     forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:10];
        button.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3;
        button.tag = 20+i;

        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize stringSize = [button.titleLabel.text sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
        stringSize.width += 30;
        button.frame = CGRectMake(totalWidth, 5, stringSize.width, 30);
        
        previousButtonWidth = button.frame.size.width + 7;
        totalWidth += previousButtonWidth;
        
        [_buttons addObject:button];
        [_hashtagsscrollview addSubview:button];
    }
    
    _hashtagsscrollview.contentSize = CGSizeMake(totalWidth, 40);
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
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    
    [self configureRestKit];
    [self request];
}

#pragma mark - Category Delegate
- (void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

@end
