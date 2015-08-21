//
//  HotlistResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "GeneralProductCollectionViewCell.h"
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

#import "URLCacheController.h"
#import "GeneralAlertCell.h"
#import "ProductSingleViewCell.h"
#import "ProductCell.h"
#import "ProductThumbCell.h"

#import "GeneralSingleProductCell.h"
#import "GeneralPhotoProductCell.h"
#import "NavigateViewController.h"

#import "PromoCollectionReusableView.h"
#import "PromoRequest.h"

#import "DetailProductViewController.h"

#define CTagGeneralProductCollectionView @"ProductCell"
#define CTagGeneralProductIdentifier @"ProductCellIdentifier"
#define CTagFooterCollectionView @"FooterCollectionReusableView"
#define CTagFooterCollectionIdentifier @"FooterView"
#define CTagRetryCollectionView @"RetryCollectionReusableView"
#define CTagRetryCollectionIdentifier @"RetryView"
#define CTagHeaderCollectionView @"HeaderCollectionReusableView"
#define CTagHeaderIdentifier @"HeaderIdentifier"
#define CProductSingleView @"ProductSingleViewCell"
#define CProductSingleViewIdentifier @"ProductSingleViewIdentifier"
#define CProductThumbView @"ProductThumbCell"
#define CProductThumbIdentifier @"ProductThumbCellIdentifier"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
} ScrollDirection;

@interface HotlistResultViewController ()
<
    GeneralProductCellDelegate,
    CategoryMenuViewDelegate,
    SortViewControllerDelegate,
    FilterViewControllerDelegate,
    GeneralSingleProductDelegate,
    GeneralPhotoProductDelegate,
    PromoCollectionViewDelegate,
    PromoRequestDelegate
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
    BOOL isFailedRequest;
    
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
    NoResultView *_noResultView;
    
    PromoRequest *_promoRequest;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
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

@property (strong, nonatomic) NSMutableArray *promo;

@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;

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
    _noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, _header.frame.size.height, self.view.frame.size.width, 100)];

    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];

    // set max data per page request
    _limit = kTKPDHOMEHOTLISTRESULT_LIMITPAGE;
    
    _page = 1;
    
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    backBarButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon_category_list_white" ofType:@"png"]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        _barbuttoncategory = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    
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
    
    NSDictionary *data = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
    if ([data objectForKey:USER_LAYOUT_PREFERENCES]) {
        self.cellType = [[data objectForKey:USER_LAYOUT_PREFERENCES] integerValue];
        if (self.cellType == UITableViewCellTypeOneColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeNormal;
            
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeNormal;

        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeThumbnail;

        }
    } else {
        self.cellType = UITableViewCellTypeTwoColumn;
        self.promoCellType = PromoCollectionViewCellTypeNormal;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                               forState:UIControlStateNormal];
    }
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [viewCollection addSubview:_refreshControl];
    
    _promoRequest = [PromoRequest new];
    _promoRequest.delegate = self;
    [self requestPromo];
    
    self.scrollDirection = ScrollDirectionDown;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Set CollectionView
    if(viewCollection.backgroundColor != [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f]) {
        [self registerNibCell:CTagGeneralProductCollectionView withIdentifier:CTagGeneralProductIdentifier isFooterView:NO isHeader:NO];
        [self registerNibCell:CTagFooterCollectionView withIdentifier:CTagFooterCollectionIdentifier isFooterView:YES isHeader:NO];
        [self registerNibCell:CTagRetryCollectionView withIdentifier:CTagRetryCollectionIdentifier isFooterView:YES isHeader:NO];
        [self registerNibCell:CTagHeaderCollectionView withIdentifier:CTagHeaderIdentifier isFooterView:NO isHeader:YES];
        [self registerNibCell:CProductSingleView withIdentifier:CProductSingleViewIdentifier isFooterView:NO isHeader:NO];
        [self registerNibCell:CProductThumbView withIdentifier:CProductThumbIdentifier isFooterView:NO isHeader:NO];
        
        UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
        [viewCollection registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];

        viewCollection.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
        [viewCollection setAlwaysBounceVertical:YES];
        [flowLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width, 50)];
        [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    
    
    self.screenName = @"Browse HotList Detail";
    [self configureRestKit];
    if (_isnodata) {
        [self request];
    }
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
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
                vc.selectedCategoryID = [[_detailfilter objectForKey:@"selected_id"] integerValue];
                vc.delegate = self;
                
                UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
                break;
            case 12 : {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
                [c setData:@{kTKPDHASHTAG_HOTLIST: @(kTKPDCATEGORY_DATATYPECATEGORYKEY)}];
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
                    NSString *title;
                    NSURL *url;
                    if ([_data objectForKey:@"title"] && [_data objectForKey:@"url"]) {
                        title = [NSString stringWithFormat:@"Jual %@ | Tokopedia ", [_data objectForKey:@"title"]];
                        url = [NSURL URLWithString:[_data objectForKey:@"url"]];
                    } else if (_hotlistdetail) {
                        title = [NSString stringWithFormat:@"Jual %@ | Tokopedia ", _hotlistdetail.result.info.title_enc];
                        url = [NSURL URLWithString:_hotlistdetail.result.hotlist_url];
                    }
                    
                    if (title && url) {
                        UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                          applicationActivities:nil];
                        act.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                        [self presentViewController:act animated:YES completion:nil];
                    }
                    
                    break;
                }
                case 13:
                {
                    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                    
                    if (self.cellType == UITableViewCellTypeOneColumn) {
                        self.cellType = UITableViewCellTypeTwoColumn;
                        self.promoCellType = PromoCollectionViewCellTypeNormal;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                               forState:UIControlStateNormal];
                        
                    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
                        self.cellType = UITableViewCellTypeThreeColumn;
                        self.promoCellType = PromoCollectionViewCellTypeThumbnail;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                               forState:UIControlStateNormal];
                        
                    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
                        self.cellType = UITableViewCellTypeOneColumn;
                        self.promoCellType = PromoCollectionViewCellTypeNormal;
                        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                               forState:UIControlStateNormal];
                        
                    }
                    
                    NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
                    [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
                    [viewCollection reloadData];
                    [viewCollection layoutIfNeeded];
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
        _descriptionview.frame = CGRectMake(_descriptionview.frame.origin.x, _descriptionview.frame.origin.y, _imageview.bounds.size.width, _imageview.bounds.size.height);
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
                             [_descriptionview setFrame:CGRectMake(self.view.bounds.size.width, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             //                             [self.view addSubview:_descriptionview];
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
                                                        KTKPDHOME_APIDESCRIPTIONKEY:KTKPDHOME_APIDESCRIPTION1KEY,
                                                        kTKPDHOME_APIHOTLISTURLKEY:kTKPDHOME_APIHOTLISTURLKEY}];
    
    RKObjectMapping *resultInfoMapping = [RKObjectMapping mappingForClass:[HotlistResultInfo class]];
    [resultInfoMapping addAttributeMappingsFromDictionary:@{
                                                            kTKPDHOMEHOTLIST_NEGATIVE_KEYWORD_KEY   : kTKPDHOMEHOTLIST_NEGATIVE_KEYWORD_KEY,
                                                            kTKPDHOMEHOTLIST_KEYWORD_KEY            : kTKPDHOMEHOTLIST_KEYWORD_KEY,
                                                            kTKPDHOMEHOTLIST_TITLE_ENC              : kTKPDHOMEHOTLIST_TITLE_ENC,
                                                            kTKPDHOMEHOTLIST_CATALOG_KEY            : kTKPDHOMEHOTLIST_CATALOG_KEY,
                                                            kTKPDHOMEHOTLIST_MIN_PRICE_KEY          : kTKPDHOMEHOTLIST_MIN_PRICE_KEY,
                                                            kTKPDHOMEHOTLIST_HASHTAG_KEY            : kTKPDHOMEHOTLIST_HASHTAG_KEY,
                                                            kTKPDHOMEHOTLIST_FILE_NAME_KEY          : kTKPDHOMEHOTLIST_FILE_NAME_KEY,
                                                            kTKPDHOMEHOTLIST_ALIAS_KEY              : kTKPDHOMEHOTLIST_ALIAS_KEY,
                                                            kTKPDHOMEHOTLIST_COVER_IMG_KEY          : kTKPDHOMEHOTLIST_COVER_IMG_KEY,
                                                            kTKPDHOMEHOTLIST_URL_KEY                : kTKPDHOMEHOTLIST_URL_KEY,
                                                            kTKPDHOMEHOTLIST_ID_KEY                 : kTKPDHOMEHOTLIST_ID_KEY,
                                                            kTKPDHOMEHOTLIST_D_ID_KEY               : kTKPDHOMEHOTLIST_D_ID_KEY,
                                                            kTKPDHOMEHOTLIST_FILE_PATH_KEY          : kTKPDHOMEHOTLIST_FILE_PATH_KEY,
                                                            kTKPDHOMEHOTLIST_META_DESCRIPTION_KEY   : kTKPDHOMEHOTLIST_META_DESCRIPTION_KEY,
                                                            kTKPDHOMEHOTLIST_SORT_BY_KEY            : kTKPDHOMEHOTLIST_SORT_BY_KEY,
                                                            kTKPDHOMEHOTLIST_SHARE_FILE_PATH_KEY    : kTKPDHOMEHOTLIST_SHARE_FILE_PATH_KEY,
                                                            kTKPDHOMEHOTLIST_DESCRIPTION_KEY        : kTKPDHOMEHOTLIST_HOTLIST_DESCRIPTION_KEY,
                                                            kTKPDHOMEHOTLIST_MAX_PRICE_KEY          : kTKPDHOMEHOTLIST_MAX_PRICE_KEY,
                                                            kTKPDHOMEHOTLIST_SHOP_KEY               : kTKPDHOMEHOTLIST_SHOP_KEY,
                                                            kTKPDHOMEHOTLIST_TITLE_KEY              : kTKPDHOMEHOTLIST_TITLE_KEY,
                                                            kTKPDHOMEHOTLIST_SHARE_FILE_NAME        : kTKPDHOMEHOTLIST_SHARE_FILE_NAME,
                                                            }];
    
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
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOMEHOTLIST_INFO_KEY
                                                                                  toKeyPath:kTKPDHOMEHOTLIST_INFO_KEY
                                                                                withMapping:resultInfoMapping]];
    
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
                            kTKPDHOME_APILIMITPAGEKEY : @"30",
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
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
    
    if (_isrefreshview) {
        [self requestprocess:object];
    }
    else {
        isFailedRequest = YES;
        [viewCollection reloadData];
        [viewCollection layoutIfNeeded];
    }
}

-(void)requestprocess:(id)object
{
    [_noResultView removeFromSuperview];
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
                    [_promo removeAllObjects];
                }

                [_product addObject:_hotlistdetail.result.list];
                
                _pagecontrol.hidden = NO;
                _swipegestureleft.enabled = YES;
                _swipegestureright.enabled = YES;
                [self setHeaderData];
                
                NSArray * departmenttree = _hotlistdetail.result.department_tree;
                
                if (_departmenttree.count == 0) {
                    [_departmenttree addObjectsFromArray:departmenttree];
                }
                
                if (_product.count > 0) {
                    
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
                    
                    if (_page > 1) [self requestPromo];
                    
                } else {
                    [flowLayout setFooterReferenceSize:CGSizeZero];
                    [viewCollection addSubview:_noResultView];
                    [viewCollection reloadData];
                    [viewCollection layoutIfNeeded];
                }
            }
        }
    }
    else{
        [self cancel];
        NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
        if ([(NSError*)object code] == NSURLErrorCancelled) {
            if (_requestcount<kTKPDREQUESTCOUNTMAX) {
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
            [viewCollection reloadData];
            [viewCollection layoutIfNeeded];
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


#pragma mark - Methods
- (IBAction)pressRetryButton:(id)sender
{
    [viewCollection reloadData];
    [viewCollection layoutIfNeeded];
    [self configureRestKit];
    [self request];
}

- (void)registerNibCell:(NSString *)strTag withIdentifier:(NSString *)strIdentifier isFooterView:(BOOL)isFooter isHeader:(BOOL)isHeader
{
    UINib *cellNib = [UINib nibWithNibName:strTag bundle:nil];
    if(isFooter || isHeader) {
        [viewCollection registerNib:cellNib forSupplementaryViewOfKind:(isFooter?UICollectionElementKindSectionFooter:UICollectionElementKindSectionHeader) withReuseIdentifier:strIdentifier];
    }
    else {
        [viewCollection registerNib:cellNib forCellWithReuseIdentifier:strIdentifier];
    }
}

-(void)setHeaderData
{
    if (![_data objectForKey:kTKPHOME_DATAHEADERIMAGEKEY]) {
        NSString *urlstring = _hotlistdetail.result.cover_image;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = _imageview;
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
#pragma clang diagnostic pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
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
    
    [_refreshControl beginRefreshing];
    
    [self configureRestKit];
    [self request];
}

#pragma mark - Category Delegate
- (void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    [_detailfilter addEntriesFromDictionary:userInfo];
    [_detailfilter setObject:userInfo[@"department_id"] forKey:@"selected_id"];
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


#pragma mark - CollectionView Delegate And Datasource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGSize cellSize = CGSizeMake(0, 0);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSInteger cellCount;
    float heightRatio;
    float widhtRatio;
    float inset;
    
    CGFloat screenWidth = screenRect.size.width;
    
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cellCount = 1;
        heightRatio = 389;
        widhtRatio = 300;
        inset = 15;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cellCount = 2;
        heightRatio = 41;
        widhtRatio = 29;
        inset = 15;
    } else {
        cellCount = 3;
        heightRatio = 1;
        widhtRatio = 1;
        inset = 14;
    }
    
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        screenWidth = screenRect.size.width/2;
        cellWidth = screenWidth/cellCount-inset;
    } else {
        screenWidth = screenRect.size.width;
        cellWidth = screenWidth/cellCount-inset;
    }
    
    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
    return cellSize;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _product.count?:1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _isnodata?0:[[_product objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    List *list = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cell = (ProductSingleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductSingleViewIdentifier forIndexPath:indexPath];
        [(ProductSingleViewCell *)cell setViewModel:list.viewModel];
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cell = (ProductCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CTagGeneralProductIdentifier forIndexPath:indexPath];
        [(ProductCell *)cell setViewModel:list.viewModel];
    } else {
        cell = (ProductThumbCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductThumbIdentifier forIndexPath:indexPath];
        [(ProductThumbCell *)cell setViewModel:list.viewModel];
    }
    
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self configureRestKit];
            [self request];
        }
        else {
            [flowLayout setFooterReferenceSize:CGSizeZero];
        }
    }
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                              withReuseIdentifier:CTagHeaderIdentifier
                                                                     forIndexPath:indexPath];
            [_header removeFromSuperview];
            [reusableView addSubview:_header];
        } else if (_promo.count >= indexPath.section && indexPath.section > 0) {
            if ([_promo objectAtIndex:indexPath.section]) {
                reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                  withReuseIdentifier:@"PromoCollectionReusableView"
                                                                         forIndexPath:indexPath];
                ((PromoCollectionReusableView *)reusableView).collectionViewCellType = _promoCellType;
                ((PromoCollectionReusableView *)reusableView).promo = [_promo objectAtIndex:indexPath.section];
                ((PromoCollectionReusableView *)reusableView).scrollPosition = [_promoScrollPosition objectAtIndex:indexPath.section];
                ((PromoCollectionReusableView *)reusableView).delegate = self;
                ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
                if (self.scrollDirection == ScrollDirectionDown) {
                    [((PromoCollectionReusableView *)reusableView) scrollToCenter];
                } else if (self.scrollDirection == ScrollDirectionUp) {
                    [((PromoCollectionReusableView *)reusableView) scrollToCenterWithoutAnimation];
                }
            } else {
                reusableView = nil;
            }
        } else {
            reusableView = nil;
        }
    }
    else if(kind == UICollectionElementKindSectionFooter) {
        if(isFailedRequest) {
            isFailedRequest = !isFailedRequest;
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"RetryView"
                                                                     forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:CTagFooterCollectionIdentifier
                                                                     forIndexPath:indexPath];
        }
    }

    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (section == 0) {
        _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/1.7f);
        size = CGSizeMake(self.view.bounds.size.width, _header.bounds.size.height);
    } else {
        if (_promo.count > section && section > 0) {
            if ([_promo objectAtIndex:section]) {
                CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
                size = CGSizeMake(self.view.frame.size.width, headerHeight);
            }
        }
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    NSInteger lastSection = [self numberOfSectionsInCollectionView:collectionView] - 1;
    if (section == lastSection) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            size = CGSizeMake(self.view.frame.size.width, 50);
        }
    } else if (_product.count == 0 && _page == 1) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	List *list = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NavigateViewController *navigator = [NavigateViewController new];
    [navigator navigateToProductFromViewController:self withName:list.product_name withPrice:list.product_price withId:list.product_id withImageurl:list.product_image withShopName:list.shop_name];
}

#pragma mark - Promo request delegate

- (void)requestPromo {
    NSString *key = [_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";
    _promoRequest.page = _page;
    [_promoRequest requestForProductHotlist:key];
}

- (void)didReceivePromo:(NSArray *)promo {
    if (promo) {
        [_promo addObject:promo];
        [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
    } else if (promo == nil && _page == 2) {
        [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    }
    [viewCollection reloadData];
    [viewCollection layoutIfNeeded];
}

#pragma mark - Promo collection delegate

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (void)didSelectPromoProduct:(PromoProduct *)product {
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{
                kTKPDDETAIL_APIPRODUCTIDKEY : product.product_id,
                kTKPD_AUTHKEY               : [_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null],
                PromoImpressionKey          : product.ad_key,
                PromoSemKey                 : product.ad_sem_key,
                PromoReferralKey            : product.ad_r
                };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

@end
