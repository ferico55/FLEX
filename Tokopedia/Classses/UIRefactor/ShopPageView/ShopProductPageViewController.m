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

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"

#import "RetryCollectionReusableView.h"

#import "NoResult.h"

#import "PromoRequest.h"

#import "UIActivityViewController+Extensions.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

typedef enum TagRequest {
    ProductTag
} TagRequest;

@interface ShopProductPageViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIAlertViewDelegate,
UISearchBarDelegate,
LoadingViewDelegate,
TKPDTabInboxTalkNavigationControllerDelegate,
ShopPageHeaderDelegate,
SortViewControllerDelegate,
MyShopEtalaseFilterViewControllerDelegate,
GeneralProductCellDelegate,
GeneralSingleProductDelegate,
GeneralPhotoProductDelegate,
TokopediaNetworkManagerDelegate
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;

@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic) UITableViewCellType cellType;

@end

@implementation ShopProductPageViewController {
    BOOL _isNoData;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _tmpPage;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    NSString *_talkNavigationFlag;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    UISearchBar *_searchbar;
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
    
    TokopediaNetworkManager *_networkManager;
    NavigateViewController *_TKPDNavigator;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    
    LoadingView *loadingView;
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NSMutableArray *_product;
    NSArray *_tmpProduct;
    Shop *_shop;
    NoResultView *_noResult;
    NSString *_nextPageUri;
    NSString *_tmpNextPageUri;
    
    BOOL _navigationBarIsAnimating;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;

    BOOL _isFailRequest;
    
    PromoRequest *_promoRequest;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
    _TKPDNavigator = [NavigateViewController new];
    
    _operationQueue = [NSOperationQueue new];
    _limit = kTKPDSHOPPRODUCT_LIMITPAGE;
    
    _product = [NSMutableArray new];

    
    _isrefreshview = NO;
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    _shopPageHeader = [ShopPageHeader new];
    _shopPageHeader.delegate = self;
    _shopPageHeader.data = _data;
    _navigationBarIsAnimating = NO;
    
    _header = _shopPageHeader.view;
    
    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:19];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    UIView *searchView = _shopPageHeader.searchView;
    [searchView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, searchView.frame.size.height)];
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
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, _header.frame.size.height, [UIScreen mainScreen].bounds.size.width, 200)];
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_fakeStickyTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_fakeStickyTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_fakeStickyTab.layer setShadowRadius:1];
    [_fakeStickyTab.layer setShadowOpacity:0.3];
    
    [self initNotification];
    //todo with network
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = ProductTag;
    [_networkManager doRequest];
    
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
    
    if(_data) {
        [_detailfilter setValue:[_data objectForKey:@"product_etalase_id"] forKey:@"product_etalase_id"];
        [_detailfilter setValue:[_data objectForKey:@"product_etalase_name"] forKey:@"product_etalase_name"];
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshView:) name:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
    
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
    
    UINib *headerNib = [UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:nil];
    [_collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Shop - Product List";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, _header.frame.size.height);
    return CGSizeMake(self.view.bounds.size.width, _header.bounds.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;

    if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}



- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
            ((RetryCollectionReusableView*)reusableView).delegate = self;
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    else if(kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
        [_header removeFromSuperview];
        [reusableView addSubview:_header];
    }
    
    return reusableView;
}

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
        ((ProductSingleViewCell*)cell).infoContraint.constant = 0;
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
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
            _isFailRequest = NO;
            [_networkManager doRequest];
        }
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    List *product = [_product objectAtIndex:indexPath.row];
    
    NSString *shopName = product.shop_name;
    if ([shopName isEqualToString:@""]|| [shopName integerValue] == 0) {
        shopName = [_data objectForKey:@"shop_name"];
    }

    [_TKPDNavigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:shopName];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh {
    /** clear object **/
    _page = 1;
    _isrefreshview = YES;
    
    if(!_refreshControl.isRefreshing) {
        [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    }

    [_networkManager doRequest];
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

- (void)updateProductHeaderPosition:(NSNotification *)notification {
    id userinfo = notification.userInfo;
    float ypos;
    if([[userinfo objectForKey:@"y_position"] floatValue] < 0) {
        ypos = 0;
    } else {
        ypos = [[userinfo objectForKey:@"y_position"] floatValue];
    }
    
    CGPoint cgpoint = CGPointMake(0, ypos);
    _collectionView.contentOffset = cgpoint;
}

#pragma mark - SearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *searchBarBefore = [_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
        [self reloadDataSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    
    searchBar.text = @"";
    
    NSString *searchBarBefore = [_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
        [self reloadDataSearch];
    }
}

-(void)reloadDataSearch
{
    _tmpProduct = [NSArray arrayWithArray:_product];
    [_product removeAllObjects];
    
    [_collectionView reloadData];
    
    _tmpNextPageUri = _nextPageUri;
    _tmpPage = _page;
    
    _page = 1;
    
    _isrefreshview = YES;
    
    [_networkManager doRequest];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
                
                break;
            }
                
            case 11 : {
                // etalase button action
                
                break;
            }
                
            case 13:
            {
                
                
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)tapToShare:(id)sender {
    if (_shop) {
        NSString *title = [NSString stringWithFormat:@"%@ - %@ | Tokopedia ",
                           _shop.result.info.shop_name,
                           _shop.result.info.shop_location];
        NSURL *url = [NSURL URLWithString:_shop.result.info.shop_url];
        
        UIActivityViewController* shareDialogController = [UIActivityViewController
                                                           shareDialogWithTitle:title url:url
                                                           anchor:sender];
        [self presentViewController:shareDialogController animated:YES completion:nil];
    }
}

- (IBAction)tapToEtalase:(id)sender {
    NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    MyShopEtalaseFilterViewController *vc =[MyShopEtalaseFilterViewController new];
    //ProductEtalaseViewController *vc = [ProductEtalaseViewController new];
    vc.data = @{kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                @"object_selected":[_detailfilter objectForKey:DATA_ETALASE_KEY]?:@0,
                @"product_etalase_name" : [_detailfilter objectForKey:@"product_etalase_name"]?:@"",
                @"product_etalase_id" : [_detailfilter objectForKey:@"product_etalase_id"]?:@"",
                kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.navigationController.navigationBar.alpha = 0;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)tapToGrid:(id)sender {
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
    
    //self.table.contentOffset = CGPointMake(0, 0);
    [_collectionView reloadData];
    
    NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
    [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
}

- (IBAction)tapToSort:(id)sender {
    NSIndexPath *indexpath = [_detailfilter objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    SortViewController *vc = [SortViewController new];
    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY),
                kTKPDFILTER_DATAINDEXPATHKEY: indexpath};
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.navigationController.navigationBar.alpha = 0;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Shop header delegate
- (void)didReceiveShop:(Shop *)shop {
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Sort Delegate
-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Filter Delegate
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_networkManager requestCancel];
    [_detailfilter removeAllObjects];
    [_detailfilter setObject:[userInfo objectForKey:DATA_ETALASE_KEY]?:@""
                      forKey:DATA_ETALASE_KEY];
    
    [_detailfilter setObject:[userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:@""
                      forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
    
    
    [self refreshView:nil];
}

#pragma mark - Cell Delegate
-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = 0;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        index = indexPath.row;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        index = indexPath.section+2*(indexPath.row);
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        index = indexPath.section+3*(indexPath.row);
    }
    
    List *list = _product[index];
    
    NSString *shopName = list.shop_name;
    if ([shopName isEqualToString:@""]|| [shopName integerValue] == 0) {
        shopName = [_data objectForKey:@"shop_name"];
    }
    
    [_TKPDNavigator navigateToProductFromViewController:self withName:list.product_name withPrice:list.product_price withId:list.product_id withImageurl:list.product_image withShopName:shopName];
    }

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)info {
    _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
    _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    NSDictionary* keyboardInfo = [info userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    _collectionView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    [_networkManager doRequest];
    _isFailRequest = NO;
    [_collectionView reloadData];
}



#pragma mark - TokopediaNetworkDelegate
- (NSDictionary *)getParameter:(int)tag {
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
    
    if([_data objectForKey:@"product_etalase_id"] && !etalase) {
        etalaseid = [_data objectForKey:@"product_etalase_id"];
    }
    
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY    :   kTKPDDETAIL_APIGETSHOPPRODUCTKEY,
                            kTKPDDETAIL_APISHOPIDKEY    :   @(shopID),
                            @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                            kTKPDDETAIL_APIPAGEKEY      :   @(_page),
                            kTKPDDETAIL_APILIMITKEY     :   @(_limit),
                            kTKPDDETAIL_APIORERBYKEY    :   @(sort),
                            kTKPDDETAIL_APIKEYWORDKEY   :   querry,
                            kTKPDDETAIL_APIETALASEIDKEY :   etalaseid};
    
    return param;
}

- (NSString *)getPath:(int)tag {
    return kTKPDDETAILSHOP_APIPATH;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *dict = ((RKMappingResult*)result).dictionary;
    id info = [dict objectForKey:@""];
    _searchitem = info;
    
    return _searchitem.status;
}

- (id)getObjectManager:(int)tag {
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
    return  _objectmanager;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    SearchItem *feed = [result objectForKey:@""];
//    [_collectionView setContentInset:UIEdgeInsetsZero];
    [_noResult removeFromSuperview];
    
    if(_page == 1) {
        _product = [feed.result.list mutableCopy];
        [self addImpressionClick];
    } else {
        [_product addObjectsFromArray: feed.result.list];
    }
    
    if (_product.count >0) {
        _isNoData = NO;
        _nextPageUri =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_nextPageUri] integerValue];
        
        if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"]) {
            //remove loadingview if there is no more item
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        }
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        [_collectionView addSubview:_noResult];
        [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, _noResult.frame.size.height, 0)];
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } else  {
        [_collectionView reloadData];
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    
    _isFailRequest = YES;
    [_collectionView reloadData];
}

#pragma mark - Promo Request

- (void)addImpressionClick {
    if ([_data objectForKey:PromoImpressionKey]) {
        _promoRequest = [[PromoRequest alloc] init];
        NSString *adKey = [_data objectForKey:PromoImpressionKey];
        NSString *adSemKey = [_data objectForKey:PromoSemKey];
        NSString *adReferralKey = [_data objectForKey:PromoReferralKey];
        [_promoRequest addImpressionKey:adKey
                                 semKey:adSemKey
                            referralKey:adReferralKey
                                 source:PromoRequestSourceFavoriteShop];
    }
}

@end
