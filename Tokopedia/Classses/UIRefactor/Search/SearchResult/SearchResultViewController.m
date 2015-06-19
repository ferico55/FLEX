//
//  SearchResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "sortfiltershare.h"
#import "string_product.h"
#import "detail.h"

#import "SearchItem.h"
#import "SearchRedirect.h"
#import "List.h"
#import "Paging.h"
#import "DepartmentTree.h"

#import "DetailProductViewController.h"
#import "CatalogViewController.h"

#import "GeneralProductCell.h"
#import "SearchResultViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "HotlistResultViewController.h"
#import "TKPDTabNavigationController.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#import "URLCacheController.h"
#import "GeneralPhotoProductCell.h"
#import "GeneralSingleProductCell.h"

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"

#pragma mark - Search Result View Controller

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

@interface SearchResultViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
GeneralProductCellDelegate,
TKPDTabNavigationControllerDelegate,
SortViewControllerDelegate,
FilterViewControllerDelegate,
GeneralPhotoProductDelegate,
GeneralSingleProductDelegate,
TokopediaNetworkManagerDelegate,
LoadingViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *catalogproductview;

@property (strong, nonatomic) NSMutableArray *product;
@property (nonatomic) UITableViewCellType cellType;

//toolbar view without share button
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)cancel;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation SearchResultViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSMutableArray *_urlarray;
    NSMutableDictionary *_params;
    
    NSString *_urinext;
    NSString *_uriredirect;
    
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    LoadingView *loadingView;
    
    SearchItem *_searchitem;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    BOOL _isFailRequest;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
        _requestcount = 0;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [tokopediaNetworkManager requestCancel];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    /** create new **/
    _product = [NSMutableArray new];
    _urlarray = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    
    /** set first page become 1 **/
    _page = 1;
    
    /** set max data per page request **/
    _limit = kTKPDSEARCH_LIMITPAGE;
    
    /** set table footer view (loading act) **/
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    if (_data) {
        [_params addEntriesFromDictionary:_data];
    }
    
    
    [_act startAnimating];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_params setObject:[_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"" forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    _catalogproductview.hidden = YES;
    
    //cache
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDSEARCH_CACHEFILEPATH];
    NSString *query =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDSEARCHPRODUCT_APIRESPONSEFILEFORMAT,query?:deptid]];
        self.screenName = @"Search Result - Product Tab";
    }else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDSEARCHCATALOG_APIRESPONSEFILEFORMAT,query?:deptid]];
        self.screenName = @"Search Result - Catalog Tab";
    }
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    if ([_data objectForKey:API_DEPARTMENT_ID_KEY]) {
        self.toolbarView.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:)
                                                 name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY
                                               object:nil];
    
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

    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *singleCellNib = [UINib nibWithNibName:@"ProductSingleViewCell" bundle:nil];
    [_collectionView registerNib:singleCellNib forCellWithReuseIdentifier:@"ProductSingleViewIdentifier"];
    UINib *thumbCellNib = [UINib nibWithNibName:@"ProductThumbCell" bundle:nil];
    [_collectionView registerNib:thumbCellNib forCellWithReuseIdentifier:@"ProductThumbCellIdentifier"];
    
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self request];
        }
    }
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [tokopediaNetworkManager requestCancel];
    [self cancel];
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid;
    UICollectionViewCell *cell = nil;
    
    List *list = [_product objectAtIndex:indexPath.row];
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cellid = @"ProductSingleViewIdentifier";
        cell = (ProductSingleViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductSingleViewCell*)cell setViewModel:list.viewModel];
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            ((ProductSingleViewCell*)cell).infoContraint.constant = 0;
        }
        else
        {
            ((ProductSingleViewCell*)cell).infoContraint.constant = 19;
        }
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cellid = @"ProductCellIdentifier";
        cell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductCell*)cell setViewModel:list.viewModel];
    } else {
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductThumbCell*)cell setViewModel:list.viewModel];
    }
    
    //next page if already last cell
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            _isFailRequest = NO;
            [[self getNetworkManager] doRequest];
        }
    }
    
    return cell;
}


- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    List *product = [_product objectAtIndex:indexPath.row];
    [navigateController navigateToProductFromViewController:self withProductID:product.product_id];
}

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
        heightRatio = 390;
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            heightRatio = 370;
        }
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
    
    CGFloat cellWidth = screenWidth/cellCount-inset;
    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
    return cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Request + Mapping
-(void)cancel
{
    //    [_request cancel];
    //    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}


- (void)request
{
    if([self getNetworkManager].getObjectRequest.isExecuting) return;
    NSLog(@"========= Request Count : %zd ==============", _requestcount);
    
    if (!_isrefreshview) {
        [_act startAnimating];
    }
    
    [[self getNetworkManager] doRequest];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _searchitem = stats;
    BOOL status = [_searchitem.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    [self requestprocess:object];
}

-(void)requestprocess:(id)object
{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        
        _searchitem = [result objectForKey: @""];
        
        NSString *statusstring = _searchitem.status;
        BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            
            NSString *uriredirect = _searchitem.result.redirect_url;
            NSString *hascatalog = _searchitem.result.has_catalog;
            
            if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
                hascatalog = @"1";
            }
            
            if (uriredirect == nil) {
                //setting is this product has catalog or not
                if ([hascatalog isEqualToString:@"1"] && hascatalog) {
                    NSDictionary *userInfo = @{@"count":@(3)};
                    [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
                }
                else if ([hascatalog isEqualToString:@"0"] && hascatalog){
                    NSDictionary *userInfo = @{@"count":@(2)};
                    [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
                }
                if (_page == 1) {
                    [_product removeAllObjects];
                    [_collectionView setContentOffset:CGPointZero animated:YES];
                }
                [_product addObjectsFromArray: _searchitem.result.list];
                
                if (_product.count == 0) {
                    [_act stopAnimating];
                    NoResultView *noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
                }
                
                if (_product.count >0) {
                    _urinext = _searchitem.result.paging.uri_next;
                    
                    NSURL *url = [NSURL URLWithString:_urinext];
                    NSArray* query = [[url query] componentsSeparatedByString: @"&"];
                    
                    NSMutableDictionary *queries = [NSMutableDictionary new];
                    [queries removeAllObjects];
                    for (NSString *keyValuePair in query)
                    {
                        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                        NSString *key = [pairComponents objectAtIndex:0];
                        NSString *value = [pairComponents objectAtIndex:1];
                        
                        [queries setObject:value forKey:key];
                    }
                    
                    _page = [[queries objectForKey:kTKPDSEARCH_APIPAGEKEY] integerValue];
                    
                    NSLog(@"next page : %zd",_page);
                    _isnodata = NO;
                    [_collectionView reloadData];
                }
            
            } else {
                _uriredirect =  uriredirect;
                NSURL *url = [NSURL URLWithString:_uriredirect];
                NSArray* query = [[url path] componentsSeparatedByString: @"/"];
                
                // Redirect URI to hotlist
                if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTHOTKEY]) {
                    [self performSelector:@selector(redirectToHotlistResult) withObject:nil afterDelay:1.0f];
                }
                // redirect uri to search category
                else if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTCATEGORY]) {
                    NSString *departementID = _searchitem.result.department_id;
                    [_params setObject:departementID forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
                    [_params setObject:@(YES) forKey:kTKPDSEARCH_DATAISREDIRECTKEY];
                    [self cancel];
                    [_act startAnimating];
                    
                    if ([self.delegate respondsToSelector:@selector(updateTabCategory:)]) {
                        [self.delegate updateTabCategory:departementID];
                    }
                    
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                
                else if ([query[1] isEqualToString:@"catalog"]) {
                    [self performSelector:@selector(redirectToCatalogResult) withObject:nil afterDelay:1.0f];
                }
            }
            _catalogproductview.hidden = NO;
        }
    }

}

- (void)redirectToCatalogResult {
    NSURL *url = [NSURL URLWithString:_uriredirect];
    NSArray* query = [[url path] componentsSeparatedByString: @"/"];
    
    NSString *catalogID = query[2];
    CatalogViewController *vc = [CatalogViewController new];
    vc.catalogID = catalogID;
    NSArray *catalogNames = [query[3] componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"-"]
                             ];
    vc.catalogName = [[catalogNames componentsJoinedByString:@" "] capitalizedString];
    vc.catalogPrice = @"";
    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    if(viewControllers.count > 0) {
        [viewControllers replaceObjectAtIndex:(viewControllers.count - 1) withObject:vc];
    }
    
    self.navigationController.viewControllers = viewControllers;
}

- (void)redirectToHotlistResult
{
    NSURL *url = [NSURL URLWithString:_uriredirect];
    NSArray* query = [[url path] componentsSeparatedByString: @"/"];
    
    HotlistResultViewController *vc = [HotlistResultViewController new];
    vc.data = @{
                kTKPDSEARCH_DATAISSEARCHHOTLISTKEY : @(YES),
                kTKPDSEARCHHOTLIST_APIQUERYKEY : query[2]
                };

    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    if(viewControllers.count > 0) {
        [viewControllers replaceObjectAtIndex:(viewControllers.count - 1) withObject:vc];
    }
    self.navigationController.viewControllers = viewControllers;
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Cell Delegate
-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]){
        // Go to product detail
        
        NSInteger index = 0;
        if (self.cellType == UITableViewCellTypeOneColumn) {
            index = indexPath.row;
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            index = indexPath.section+2*(indexPath.row);
        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            index = indexPath.section+3*(indexPath.row);
        }
        
        DetailProductViewController *vc = [DetailProductViewController new];
        List *list = _product[index];
        vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : list.product_id?:@(0),
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY])
    {
        // Go to catalog detail
        NSInteger index = 0;
        if (self.cellType == UITableViewCellTypeOneColumn) {
            index = indexPath.row;
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            index = indexPath.section+2*(indexPath.row);
        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            index = indexPath.section+3*(indexPath.row);
        }
        
        CatalogViewController *controller = [CatalogViewController new];
        controller.list = _product[index];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - TKPDTabNavigationController Tap Button Notification
-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            NSIndexPath *indexpath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            // Action Urutkan Button
            SortViewController *vc = [SortViewController new];
            if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY])
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEPRODUCTVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath?:@0};
            else
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPECATALOGVIEWKEY),
                            kTKPDFILTER_DATAINDEXPATHKEY: indexpath?:@0};
            vc.delegate = self;
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0)) {
                [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
            }
            UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            vc.screenshotImage = screenshotImage;
            
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        case 11:
        {
            // Action Filter Button
            FilterViewController *vc = [FilterViewController new];
            if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY])
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEPRODUCTVIEWKEY),
                            kTKPDFILTER_DATAFILTERKEY: _params
                            };
            else
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPECATALOGVIEWKEY),
                            kTKPDFILTER_DATAFILTERKEY: _params};
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        case 12:
        {
            NSString *title;
            if ([_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTTITLEKEY]) {
                title = [NSString stringWithFormat:@"Jual %@ | Tokopedia",
                         [_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTTITLEKEY]];
            } else if ([_data objectForKey:kTKPDSEARCH_DATASEARCHKEY]) {
                title = [NSString stringWithFormat:@"Jual %@ | Tokopedia",
                         [[_data objectForKey:kTKPDSEARCH_DATASEARCHKEY] capitalizedString]];
            }
            NSURL *url = [NSURL URLWithString: _searchitem.result.search_url?:@"www.tokopedia.com"];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                             applicationActivities:nil];
            activityController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
            [self presentViewController:activityController animated:YES completion:nil];
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
            
            _collectionView.contentOffset = CGPointMake(0, 0);
            [_collectionView reloadData];
            
            NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
            [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];

            break;
        }
        default:
            break;
    }
}

#pragma mark - Methods
- (LoadingView *)getLoadView
{
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}

-(void)reset:(GeneralProductCell*)cell
{
    [cell.thumb makeObjectsPerformSelector:@selector(setImage:) withObject:nil];
    [cell.labelprice makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.labelalbum makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.labeldescription makeObjectsPerformSelector:@selector(setText:) withObject:nil];
    [cell.viewcell makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    _page = 1;
    _isrefreshview = YES;
    _requestcount = 0;
    
    [_refreshControl beginRefreshing];
    [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    
    [_collectionView reloadData];
    [self request];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
}

#pragma mark - Category notification

- (void)changeCategory:(NSNotification *)notification
{
//    [_product removeAllObjects];
    [_params setObject:[notification.userInfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY] forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
    [_act startAnimating];
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self request];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    NSString *query =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY]?:@"";
    NSString *type = [_params objectForKey:kTKPDSEARCH_DATATYPE]?:@"";
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"";
    BOOL isredirect = [[_params objectForKey:kTKPDSEARCH_DATAISREDIRECTKEY] boolValue];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                 kTKPDSEARCH_APIACTIONTYPEKEY    :   type?:@"",
                                                                                 kTKPDSEARCH_APIPAGEKEY          :   @(_page),
                                                                                 kTKPDSEARCH_APILIMITKEY         :   @(kTKPDSEARCH_LIMITPAGE),
                                                                                 kTKPDSEARCH_APIORDERBYKEY       :   [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                                                                                 kTKPDSEARCH_APILOCATIONKEY      :   [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                                                                                 kTKPDSEARCH_APISHOPTYPEKEY      :   [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                                                                                 kTKPDSEARCH_APIPRICEMINKEY      :   [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                                                                                 kTKPDSEARCH_APIPRICEMAXKEY      :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@"",
                                                                                 kTKPDSEARCH_APIDEPARTEMENTIDKEY :   [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"",
                                                                                 
                                                                                 kTKPDSEARCH_APIDEPARTMENT_1     :   [_params objectForKey:kTKPDSEARCH_APIDEPARTMENT_1]?:@"",
                                                                                 kTKPDSEARCH_APIDEPARTMENT_2     :   [_params objectForKey:kTKPDSEARCH_APIDEPARTMENT_2]?:@"",
                                                                                 kTKPDSEARCH_APIDEPARTMENT_3     :   [_params objectForKey:kTKPDSEARCH_APIDEPARTMENT_3]?:@"",
                                                                                 }];
    
    if (query != nil && ![query isEqualToString:@""] && !isredirect) {
        [param setObject:query forKey:kTKPDSEARCH_APIQUERYKEY];
    }
    else{
        [param setObject:deptid forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    }
    
    if ([_params objectForKey:kTKPDSEARCH_APIMINPRICEKEY]) {
        [param setObject:[_params objectForKey:kTKPDSEARCH_APIMINPRICEKEY] forKey:kTKPDSEARCH_APIPRICEMINKEY];
    }
    if ([_params objectForKey:kTKPDSEARCH_APIMAXPRICEKEY]) {
        [param setObject:[_params objectForKey:kTKPDSEARCH_APIMAXPRICEKEY] forKey:kTKPDSEARCH_APIPRICEMAXKEY];
    }
    if ([_params objectForKey:kTKPDSEARCH_APIOBKEY]) {
        [param setObject:[_params objectForKey:kTKPDSEARCH_APIOBKEY] forKey:kTKPDSEARCH_APIORDERBYKEY];
    }
    if ([_params objectForKey:kTKPDSEARCH_APILOCATIONIDKEY]) {
        [param setObject:[_params objectForKey:kTKPDSEARCH_APILOCATIONIDKEY] forKey:kTKPDSEARCH_APILOCATIONKEY];
    }
    if ([_params objectForKey:kTKPDSEARCH_APIGOLDMERCHANTKEY]) {
        [param setObject:[_params objectForKey:kTKPDSEARCH_APIGOLDMERCHANTKEY] forKey:kTKPDSEARCH_APISHOPTYPEKEY];
    }
    
    NSLog(@"%@", param);
    return param;
}

- (NSString*)getPath:(int)tag
{
    return kTKPDSEARCH_APIPATH;
}

- (id)getObjectManager:(int)tag
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchItem class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY,
                                                        kTKPDSEARCH_APISEARCH_URLKEY:kTKPDSEARCH_APISEARCH_URLKEY,
                                                        kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY,
                                                        kTKPDSEARCH_APIDEPARTMENTIDKEY:kTKPDSEARCH_APIDEPARTMENTIDKEY
                                                        }];
    
    // searchs list mapping
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[List class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIPRODUCTIMAGEKEY,
                                                 kTKPDSEARCH_APIPRODUCTIMAGEFULLKEY,
                                                 kTKPDSEARCH_APIPRODUCTPRICEKEY,
                                                 kTKPDSEARCH_APIPRODUCTNAMEKEY,
                                                 kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                 kTKPDSEARCH_APIPRODUCTIDKEY,
                                                 kTKPDSEARCH_APIPRODUCTREVIEWCOUNTKEY,
                                                 kTKPDSEARCH_APIPRODUCTTALKCOUNTKEY,
                                                 kTKPDSEARCH_APICATALOGIMAGEKEY,
                                                 kTKPDSEARCH_APICATALOGIMAGE300KEY,
                                                 kTKPDSEARCH_APICATALOGNAMEKEY,
                                                 kTKPDSEARCH_APICATALOGPRICEKEY,
                                                 kTKPDSEARCH_APICATALOGIDKEY,
                                                 kTKPDSEARCH_APICATALOGCOUNTSHOPKEY,
                                                 kTKPDSEARCH_APISHOPGOLDSTATUS,
                                                 ]];
    
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    RKObjectMapping *departmentMapping = [RKObjectMapping mappingForClass:[DepartmentTree class]];
    [departmentMapping addAttributeMappingsFromArray:@[kTKPDSEARCH_APIHREFKEY, kTKPDSEARCH_APITREEKEY, kTKPDSEARCH_APIDIDKEY, kTKPDSEARCH_APITITLEKEY,kTKPDSEARCH_APICHILDTREEKEY]];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APILISTKEY toKeyPath:kTKPDSEARCH_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDSEARCH_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
    
    return _objectmanager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((SearchItem *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self requestsuccess:successResult withOperation:operation];
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
}

- (void)actionBeforeRequest:(int)tag
{
    if (!_isrefreshview) {
        [_act startAnimating];
    }
    else{
        [_act stopAnimating];
    }
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    _isrefreshview = NO;
    _isFailRequest = YES;
    [_refreshControl endRefreshing];
    //_table.tableFooterView = [self getLoadView].view;
}

@end