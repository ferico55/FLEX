//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "LoadingView.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopProductPageViewController.h"
#import "MyShopNoteDetailViewController.h"
#import "GeneralProductCell.h"

#import "Notes.h"
#import "GeneralAction.h"
#import "EtalaseList.h"
#import "SearchItem.h"

#import "inbox.h"
#import "string_home.h"
#import "string_product.h"
#import "search.h"
#import "sortfiltershare.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"
#import "generalcell.h"
#import "GeneralAlertCell.h"
#import "ShopPageHeader.h"

#import "URLCacheController.h"
#import "SortViewController.h"
#import "MyShopEtalaseFilterViewController.h"

#import "GeneralSingleProductCell.h"
#import "GeneralPhotoProductCell.h"
#import "DetailProductViewController.h"

#import "NoResult.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

@interface ShopProductPageViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIAlertViewDelegate,
    UISearchBarDelegate,
    LoadingViewDelegate,
    TKPDTabInboxTalkNavigationControllerDelegate,
    ShopPageHeaderDelegate,
    SortViewControllerDelegate,
    MyShopEtalaseFilterViewControllerDelegate,
    GeneralProductCellDelegate,
    GeneralSingleProductDelegate,
    GeneralPhotoProductDelegate
>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;

@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic) UITableViewCellType cellType;

@end

@implementation ShopProductPageViewController
{
    BOOL _isNoData;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    NSString *_uriNext;
    NSString *_talkNavigationFlag;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    SearchItem *_searchitem;
    
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    
    LoadingView *loadingView;
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NSMutableArray *_product;
    Shop *_shop;
    NoResultView *_noResult;
    
    BOOL _navigationBarIsAnimating;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;

}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _isrefreshview = NO;
        _isNoData = YES;
    }
    
    return self;
}


- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProductHeaderPosition:)
                                                 name:@"updateProductHeaderPosition" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    
    _operationQueue = [NSOperationQueue new];
    _limit = kTKPDSHOPPRODUCT_LIMITPAGE;

    _product = [NSMutableArray new];
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];

    _isrefreshview = NO;
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _table.delegate = self;
    _table.dataSource = self;
    
    _shopPageHeader = [ShopPageHeader new];
    _shopPageHeader.delegate = self;
    _shopPageHeader.data = _data;
    _navigationBarIsAnimating = NO;
    
    _header = _shopPageHeader.view;

    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:19];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    UIView *searchView = _shopPageHeader.searchView;
    UISearchBar *searchBar = _shopPageHeader.searchBar;
    searchBar.delegate = self;
    
    CGRect newHeaderPosition = searchView.frame;
    newHeaderPosition.origin.y = _header.frame.size.height;
    searchView.frame = newHeaderPosition;
    searchView.backgroundColor = [UIColor clearColor];
    
    CGRect newFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _header.frame.size.height + searchView.frame.size.height);
    _header.frame = newFrame;
    [_header addSubview:searchView];
    
    [_header setClipsToBounds:YES];
    [_header.layer setMasksToBounds:YES];
    UIView *header = [[UIView alloc] initWithFrame:_header.frame];
    [header setBackgroundColor:[UIColor whiteColor]];
    [header addSubview:_header];
    _table.tableHeaderView = header;
    _table.tableFooterView = _footer;
    
    
    [_refreshControl addTarget:self action:@selector(refreshRequest:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_fakeStickyTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_fakeStickyTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_fakeStickyTab.layer setShadowRadius:1];
    [_fakeStickyTab.layer setShadowOpacity:0.3];
    
    [self initNotification];
    [self configureRestKit];
    [self loadData];
 
    NSDictionary *data = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
    if ([data objectForKey:USER_LAYOUT_PREFERENCES]) {
        self.cellType = [[data objectForKey:USER_LAYOUT_PREFERENCES] integerValue];
        if (self.cellType == UITableViewCellTypeOneColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                   forState:UIControlStateNormal];
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                   forState:UIControlStateNormal];
        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                   forState:UIControlStateNormal];
        }
    } else {
        self.cellType = UITableViewCellTypeTwoColumn;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                               forState:UIControlStateNormal];
    }

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshView:) name:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Shop - Product List";
    self.hidesBottomBarWhenPushed = YES;
    if (!_isrefreshview) {
        [self configureRestKit];
        
        if (_isNoData && _page < 1) {
            [self loadData];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotesList *list = _list[indexPath.row];
    MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY),
                kTKPDNOTES_APINOTEIDKEY:list.note_id,
                kTKPDNOTES_APINOTETITLEKEY:list.note_title,
                kTKPDNOTES_APINOTESTATUSKEY:list.note_status,
                };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self configureRestKit];
            [self loadData];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}

#pragma mark - TableView Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        count = _product.count;
        #ifdef kTKPDSEARCHRESULT_NODATAENABLE
            count = _isNoData?1:count;
        #else
            count = _isNoData?0:count;
        #endif
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
        #ifdef kTKPDSEARCHRESULT_NODATAENABLE
            count = _isNoData?1:count;
        #else
            count = _isNoData?0:count;
        #endif
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        count = (_product.count%3==0)?_product.count/3:_product.count/3+1;
        #ifdef kTKPDSEARCHRESULT_NODATAENABLE
            count = _isNoData?1:count;
        #else
            count = _isNoData?0:count;
        #endif
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellType == UITableViewCellTypeOneColumn) {
        return 390;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        return 205;
    } else {
        return 103;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (_isNoData) {
        static NSString *CellIdentifier = @"GeneralAlertCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [GeneralAlertCell newCell];
        }
        
        if (!_searchBar.resignFirstResponder) {
            cell.textLabel.text = [NSString stringWithFormat:@"No result found for '%@'", _searchBar.text];
        } else {
            cell.textLabel.text = @"No product";
        }
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

- (UITableViewCell *)tableView:(UITableView *)tableView oneColumnCellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    cell.productShopLabel.text = @"";
    cell.infoLabelConstraint.constant = 0;
    
    UIFont *boldFont = [UIFont fontWithName:@"GothamMedium" size:12];
    
    NSString *stats = [NSString stringWithFormat:@"%@ Ulasan   %@ Diskusi",
                       list.product_review_count, list.product_talk_count];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:stats];
    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, list.product_review_count.length)];
    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(list.product_review_count.length + 10, list.product_talk_count.length)];
    
    cell.productInfoLabel.attributedText = attributedText;
    
    cell.indexPath = indexPath;
    
    cell.badge.hidden = (![list.shop_gold_status boolValue]);
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image_full]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    cell.productImageView.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
    cell.productImageView.contentMode = UIViewContentModeCenter;
    
    [cell.productImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              [cell.productImageView setImage:image];
                                              [cell.productImageView setContentMode:UIViewContentModeScaleAspectFill];
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              cell.productImageView.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
                                          }];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView twoColumnCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
    UITableViewCell* cell = nil;
    
    cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralProductCell newcell];
        ((GeneralProductCell *)cell).delegate = self;
    }
    
    if (_product.count > indexPath.row) {
        /** Flexible view count **/
        NSUInteger indexsegment = indexPath.row * 2;
        NSUInteger indexmax = indexsegment + 2;
        NSUInteger indexlimit = MIN(indexmax, _product.count);
        
        NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
        
        for (UIView *view in ((GeneralProductCell*)cell).viewcell ) {
            view.hidden = YES;
        }
        
        for (int i = 0; (indexsegment + i) < indexlimit; i++) {
            List *list = [_product objectAtIndex:indexsegment + i];
            ((UIView*)((GeneralProductCell*)cell).viewcell[i]).hidden = NO;
            (((GeneralProductCell*)cell).indexpath) = indexPath;
            
            UIView *view = ((UIView*)((GeneralProductCell*)cell).viewcell[i]);
            CGRect newFrame = view.frame;
            newFrame.size.height = 195;
            view.frame = newFrame;
            
            ((UILabel*)((GeneralProductCell*)cell).labelprice[i]).text = list.catalog_price?:list.product_price;
            ((UILabel*)((GeneralProductCell*)cell).labeldescription[i]).text = list.catalog_name?:list.product_name;            
            
            NSString *urlstring = list.catalog_image?:list.product_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)((GeneralProductCell*)cell).thumb[i];
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
#pragma clang diagnostic pop
            } failure:nil];
            
            if([list.shop_gold_status isEqualToString:@"1"]) {
                ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = NO;
            } else {
                ((UIImageView*)((GeneralProductCell*)cell).isGoldShop[i]).hidden = YES;
            }
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

    
    NSUInteger indexsegment = indexPath.row * 3;
    NSUInteger indexmax = indexsegment + 3;
    NSUInteger indexlimit = MIN(indexmax, _product.count);
    
    NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
    
    for (UIView *view in ((GeneralPhotoProductCell*)cell).viewcell ) {
        view.hidden = YES;
    }
    
    for (int i = 0; (indexsegment + i) < indexlimit; i++) {
        List *list = [_product objectAtIndex:indexsegment + i];
        ((UIView*)((GeneralPhotoProductCell*)cell).viewcell[i]).hidden = NO;
        
        (((GeneralPhotoProductCell*)cell).indexPath) = indexPath;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = [cell.productImageViews objectAtIndex:i];
        thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
        thumb.contentMode = UIViewContentModeCenter;
        thumb.hidden = NO;
        
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
        
        [[cell.badges objectAtIndex:i] setHidden:(![list.shop_gold_status boolValue])];
    }
    
    return cell;
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchItem class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY}];
    
    // searchs list mapping
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[List class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIPRODUCTIMAGEKEY,
                                                 kTKPDSEARCH_APIPRODUCTIMAGEFULLKEY,
                                                 kTKPDSEARCH_APIPRODUCTPRICEKEY,
                                                 kTKPDSEARCH_APIPRODUCTNAMEKEY,
                                                 kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                 kTKPDSEARCH_APIPRODUCTTALKCOUNTKEY,
                                                 kTKPDSEARCH_APIPRODUCTREVIEWCOUNTKEY,
                                                 kTKPDSEARCH_APICATALOGIMAGEKEY,
                                                 kTKPDSEARCH_APICATALOGNAMEKEY,
                                                 kTKPDSEARCH_APICATALOGPRICEKEY,
                                                 kTKPDSEARCH_APIPRODUCTIDKEY,
                                                 kTKPDSEARCH_APISHOPGOLDSTATUS,
                                                 kTKPDSEARCH_APICATALOGIDKEY]];
    
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    RKObjectMapping *departmentMapping = [RKObjectMapping mappingForClass:[DepartmentTree class]];
    [departmentMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIHREFKEY, kTKPDSEARCH_APITREEKEY, kTKPDSEARCH_APIDIDKEY, kTKPDSEARCH_APITITLEKEY,kTKPDSEARCH_APICHILDTREEKEY]];
    
    /** redirect mapping & hascatalog **/
    RKObjectMapping *redirectMapping = [RKObjectMapping mappingForClass:[SearchRedirect class]];
    [redirectMapping addAttributeMappingsFromDictionary: @{kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY,
                                                           kTKPDSEARCH_APIDEPARTMENTIDKEY:kTKPDSEARCH_APIDEPARTMENTIDKEY,
                                                           kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY}];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APILISTKEY
                                                                                 toKeyPath:kTKPDSEARCH_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDSEARCH_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDSHOP_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
}


- (void)loadData
{
    if (_request.isExecuting) return;
    
    loadingView = nil;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    _requestCount ++;
    
    NSString *querry =[_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    NSInteger sort =  [[_detailfilter objectForKey:kTKPDDETAIL_APIORERBYKEY]integerValue];
    NSInteger shopID = [[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0;
    EtalaseList *etalase = [_detailfilter objectForKey:DATA_ETALASE_KEY];
    BOOL isSoldProduct = ([etalase.etalase_id integerValue] == 7);
    BOOL isAllEtalase = (etalase.etalase_id == 0);
    
    id etalaseid;
    
    if (isSoldProduct) {
        etalaseid = @"sold";
        if(sort == 0)sort = [etalase.etalase_id integerValue];
    }
    else if (isAllEtalase)
        etalaseid = @"all";
    else{
        etalaseid = etalase.etalase_id?:@"";
    }
    
    if([_data objectForKey:@"product_etalase_id"]) {
        etalaseid = [_data objectForKey:@"product_etalase_id"];
    }
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY    :   kTKPDDETAIL_APIGETSHOPPRODUCTKEY,
                            kTKPDDETAIL_APISHOPIDKEY    :   @(shopID),
                            kTKPDDETAIL_APIPAGEKEY      :   @(_page),
                            kTKPDDETAIL_APILIMITKEY     :   @(_limit),
                            kTKPDDETAIL_APIORERBYKEY    :   @(sort),
                            kTKPDDETAIL_APIKEYWORDKEY   :   querry,
                            kTKPDDETAIL_APIETALASEIDKEY :   etalaseid};
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST
                                                                      path:kTKPDDETAILSHOP_APIPATH
                                                                parameters:[param encrypt]];
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        [_table reloadData];
        [self endRefreshing];
        [_timer invalidate];
        _timer = nil;
        _isrefreshview = NO;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(_product==nil || _product.count==0) {
            loadingView = [LoadingView new];
            loadingView.delegate = self;
            _table.tableFooterView = loadingView.view;
            [self cancel];
        }
        else {
            _table.tableFooterView = nil;
        }

        [_act stopAnimating];
        [self endRefreshing];
        [_timer invalidate];
        _timer = nil;
        _isrefreshview = NO;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];


}

-(void)endRefreshing
{
    if (_refreshControl.isRefreshing) {
        [_table setContentOffset:CGPointZero animated:YES];
        [_refreshControl endRefreshing];
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _searchitem = info;
    NSString *statusstring = _searchitem.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id info = [result objectForKey:@""];
            _searchitem = info;
            NSString *statusstring = _searchitem.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                
                if (_page == 1) {
                    [_product removeAllObjects];
                    [_table setContentOffset:CGPointZero animated:YES];
                }
                
                [_product addObjectsFromArray: _searchitem.result.list];
                
                if (_product.count > 0) {
                    
                    _uriNext =  _searchitem.result.paging.uri_next;
                    
                    NSURL *url = [NSURL URLWithString:_uriNext];
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
                    
                    _isNoData = NO;
                    
                } else {
                    _isNoData = YES;
                    _table.tableFooterView = _noResult;
                    _act.hidden = YES;
               }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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
-(void)requestTimeout
{
    [self cancel];
}




#pragma mark - Refresh View
-(void)refreshRequest:(NSNotification*)notification
{
    _page = 1;
    [_refreshControl beginRefreshing];
    [_table setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    [self refreshView:_refreshControl];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    _page = 1;
    _isrefreshview = YES;
    
    [_refreshControl beginRefreshing];
    [_table setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isFakeStickyVisible = scrollView.contentOffset.y > (_header.frame.size.height - _stickyTab.frame.size.height - _shopPageHeader.searchView.frame.size.height);
    
    if(isFakeStickyVisible) {
        _fakeStickyTab.hidden = NO;
    } else {
        _fakeStickyTab.hidden = YES;
    }
    [self determineOtherScrollView:scrollView];
    [self determineNavTitle:scrollView];
}

- (void)determineNavTitle:(UIScrollView*)scrollView {
    if(scrollView.contentOffset.y > 180) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNavigationShopTitle" object:nil userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideNavigationShopTitle" object:nil userInfo:nil];
    }
}


- (void)determineOtherScrollView:(UIScrollView *)scrollView {
    NSDictionary *userInfo = @{@"y_position" : [NSNumber numberWithFloat:scrollView.contentOffset.y]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTalkHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNotesHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateReviewHeaderPosition" object:nil userInfo:userInfo];
    
}

- (void)updateProductHeaderPosition:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    float ypos;
    if([[userinfo objectForKey:@"y_position"] floatValue] < 0) {
        ypos = 0;
    } else {
        ypos = [[userinfo objectForKey:@"y_position"] floatValue];
    }
    
    CGPoint cgpoint = CGPointMake(0, ypos);
    _table.contentOffset = cgpoint;

}

#pragma mark - SearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    _scrollOffset = self.table.contentOffset.y;
    
    [searchBar resignFirstResponder];
    [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
    
    [_product removeAllObjects];
     _table.tableFooterView = _footer;
    [_table reloadData];
    _page = 1;
    _requestCount = 0;
    _isrefreshview = YES;
    [self configureRestKit];
    [self loadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Action
-(IBAction)tapButton:(id)sender {
    
    self.hidesBottomBarWhenPushed = YES;
    
    [_searchBar resignFirstResponder];
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10: {
                // sort button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SortViewController *vc = [SortViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                self.navigationController.navigationBar.alpha = 0;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
                
            case 11 : {
                // etalase button action
                NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                MyShopEtalaseFilterViewController *vc =[MyShopEtalaseFilterViewController new];
                //ProductEtalaseViewController *vc = [ProductEtalaseViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                self.navigationController.navigationBar.alpha = 0;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
                
            case 12 : {
                if (_shop) {
                    NSString *title = [NSString stringWithFormat:@"%@ - %@ | Tokopedia ",
                                       _shop.result.info.shop_name,
                                       _shop.result.info.shop_location];
                    NSURL *url = [NSURL URLWithString:_shop.result.info.shop_url];
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                                     applicationActivities:nil];
                    activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                    [self presentViewController:activityController animated:YES completion:nil];
                }
                break;
            }
            case 13:
            {
                TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                
                if (self.cellType == UITableViewCellTypeOneColumn) {
                    self.cellType = UITableViewCellTypeTwoColumn;
                    [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                           forState:UIControlStateNormal];
                    
                } else if (self.cellType == UITableViewCellTypeTwoColumn) {
                    self.cellType = UITableViewCellTypeThreeColumn;
                    [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                           forState:UIControlStateNormal];
                    
                } else if (self.cellType == UITableViewCellTypeThreeColumn) {
                    self.cellType = UITableViewCellTypeOneColumn;
                    [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                           forState:UIControlStateNormal];
                    
                }
                
                self.table.contentOffset = CGPointMake(0, 0);
                [self.table reloadData];
                
                NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
                [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];

                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
//    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Filter Delegate
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [self cancel];
    [_detailfilter setObject:[userInfo objectForKey:DATA_ETALASE_KEY]?:@""
                      forKey:DATA_ETALASE_KEY];
    
    [_detailfilter setObject:[userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:@""
                      forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
    [self refreshView:nil];
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
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id, @"is_dismissed" : @YES};
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)info {
    _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
    _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    
    CGPoint cgpoint = CGPointMake(0, _keyboardSize.height);
    _table.contentOffset = cgpoint;
}

- (void)keyboardWillHide:(NSNotification *)info {
 
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self configureRestKit];
    [self loadData];
}
@end
