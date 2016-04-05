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

#import "SearchAWS.h"
#import "SearchAWSProduct.h"
#import "SearchAWSResult.h"

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

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#import "URLCacheController.h"
#import "GeneralPhotoProductCell.h"
#import "GeneralSingleProductCell.h"

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"

#import "PromoCollectionReusableView.h"
#import "PromoRequest.h"

#import "Localytics.h"
#import "UIActivityViewController+Extensions.h"
#import "NoResultReusableView.h"
#import "SpellCheckRequest.h"
#import "Tokopedia-Swift.h"

#import "ImageSearchResponse.h"
#import "ImageSearchRequest.h"

#pragma mark - Search Result View Controller

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

static NSString *const startPerPage = @"12";

@interface SearchResultViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
SortViewControllerDelegate,
FilterViewControllerDelegate,
PromoCollectionViewDelegate,
NoResultDelegate,
SpellCheckRequestDelegate,
ImageSearchRequestDelegate
>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSMutableArray *product;
@property (strong, nonatomic) NSMutableArray<NSArray<PromoResult*>*> *promo;
@property (strong, nonatomic) NSMutableDictionary *similarityDictionary;

@property (nonatomic) UITableViewCellType cellType;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) PromoRequest *promoRequest;
@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;
@property (strong, nonatomic) SpellCheckRequest *spellCheckRequest;

@property (strong, nonatomic) ImageSearchRequest *imageSearchRequest;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageSearchToolbarButtons;

@end

@implementation SearchResultViewController {
    NSInteger _start;
    NSInteger _limit;
    
    NSMutableDictionary *_params;
    NSString *_urinext;
    
    
    UIRefreshControl *_refreshControl;
    SearchAWS *_searchObject;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NSOperationQueue *_operationQueue;
    
    UserAuthentificationManager *_userManager;
    TAGContainer *_gtmContainer;
    NoResultReusableView *_noResultView;
    
    NSString *_searchBaseUrl;
    NSString *_searchPostUrl;
    NSString *_searchFullUrl;
    NSString *_suggestion;
    
    NSString *_strImageSearchResult;
    NSInteger allProductsCount;
    
    BOOL _isFailRequest;
    
    NSIndexPath *_sortIndexPath;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [_noResultView generateAllElements:@"no-result.png"
                                 title:@"Oops... hasil pencarian Anda tidak dapat ditemukan."
                                  desc:@"Silahkan lakukan pencarian dengan kata kunci lain"
                               btnTitle:@""];
    [_noResultView hideButton:YES];
    _noResultView.delegate = self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userManager = [UserAuthentificationManager new];
    
    _product = [NSMutableArray new];
    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    _similarityDictionary = [NSMutableDictionary new];
    
    _params = [NSMutableDictionary new];
    _start = 0;
    
    [self initNoResultView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE]];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
    [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, headerHeight)];
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_firstFooter setFrame:CGRectMake(0, 0, _flowLayout.footerReferenceSize.width, 50)];
    [_collectionView addSubview:_firstFooter];
    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    
    [_params setDictionary:_data];
    
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
        if(self.isFromAutoComplete) {
            [TPAnalytics trackScreenName:@"Product Search Results (From Auto Complete Search)" gridType:self.cellType];
            self.screenName = @"Product Search Results (From Auto Complete Search)";
        } else {
            [TPAnalytics trackScreenName:@"Product Search Results" gridType:self.cellType];
            self.screenName = @"Product Search Results";
        }
    }
    else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        [TPAnalytics trackScreenName:@"Catalog Search Results"];
        self.screenName = @"Catalog Search Results";
    }
    
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
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
    [_collectionView registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];
    
    [self configureGTM];
    
    _promoRequest = [PromoRequest new];
    self.scrollDirection = ScrollDirectionDown;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    if(_isFromImageSearch){
        _imageSearchRequest = [[ImageSearchRequest alloc]init];
        _imageSearchRequest.delegate = self;
        _imageSearchRequest.view = self.view;
        
        [_imageSearchRequest requestSearchbyImage:_imageQueryInfo];
        [_fourButtonsToolbar setHidden:YES];
        [_threeButtonsToolbar setHidden:NO];
        [_fourButtonsToolbar setUserInteractionEnabled:NO];
        [_threeButtonsToolbar setUserInteractionEnabled:YES];
    } else{
        [self requestSearch];
        
        [_fourButtonsToolbar setHidden:NO];
        [_threeButtonsToolbar setHidden:YES];
        [_fourButtonsToolbar setUserInteractionEnabled:YES];
        [_threeButtonsToolbar setUserInteractionEnabled:NO];
    }
    
    _spellCheckRequest = [SpellCheckRequest new];
    _spellCheckRequest.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _suggestion = @"";
    [_collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_networkManager requestCancel];
}

#pragma mark - Properties
- (void)setData:(NSDictionary *)data {
    _data = data;
    
    if (_data) {
        [_params setObject:data[@"department_id"] forKey:@"department_id"];
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}

#pragma mark - Collection Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _product.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([[_product objectAtIndex:section] count] != 0)?[[_product objectAtIndex:section] count]:0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid;
    UICollectionViewCell *cell = nil;
    
    SearchAWSProduct *list = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cellid = @"ProductSingleViewIdentifier";
        cell = (ProductSingleViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductSingleViewCell*)cell setCatalogViewModel:list.catalogViewModel];
            ((ProductSingleViewCell*)cell).infoContraint.constant = 0;
        }
        else {
            [(ProductSingleViewCell*)cell setViewModel:list.viewModel];
            ((ProductSingleViewCell*)cell).infoContraint.constant = 19;
        }
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cellid = @"ProductCellIdentifier";
        cell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductCell*)cell setCatalogViewModel:list.catalogViewModel];
        } else {
            [(ProductCell*)cell setViewModel:list.viewModel];
        }
        
    } else {
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductThumbCell*)cell setCatalogViewModel:list.catalogViewModel];
        } else {
            [(ProductThumbCell*)cell setViewModel:list.viewModel];
        }
    }
    
    //next page if already last cell
    
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""]) {
            _isFailRequest = NO;

            [self requestSearch];
        }
    }
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY] &&
            _promo.count > indexPath.section) {
            
            NSArray *currentPromo = [_promo objectAtIndex:indexPath.section];
            if(_promoCellType == PromoCollectionViewCellTypeThumbnail){
                if(indexPath.section % 2 == 0){
                    if (currentPromo && currentPromo.count > 0) {
                        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"
                                                                                 forIndexPath:indexPath];
                        NSMutableArray<PromoResult*> *combinedPromoResults = [NSMutableArray arrayWithArray:[_promo objectAtIndex:indexPath.section]];
                        if(_promo.count > indexPath.section){
                            [combinedPromoResults addObjectsFromArray:[_promo objectAtIndex:indexPath.section+1]];
                        }
                        ((PromoCollectionReusableView *)reusableView).collectionViewCellType = _promoCellType;
                        ((PromoCollectionReusableView *)reusableView).promo = combinedPromoResults;
                        ((PromoCollectionReusableView *)reusableView).scrollPosition = [_promoScrollPosition objectAtIndex:indexPath.section];
                        ((PromoCollectionReusableView *)reusableView).delegate = self;
                        ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
                        if (self.scrollDirection == ScrollDirectionDown && indexPath.section == 1) {
                            [((PromoCollectionReusableView *)reusableView) scrollToCenter];
                        }
                    }
                }
            }else{
                if (currentPromo && currentPromo.count > 0) {
                    reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"
                                                                             forIndexPath:indexPath];
                    ((PromoCollectionReusableView *)reusableView).collectionViewCellType = _promoCellType;
                    ((PromoCollectionReusableView *)reusableView).promo = [_promo objectAtIndex:indexPath.section];
                    ((PromoCollectionReusableView *)reusableView).scrollPosition = [_promoScrollPosition objectAtIndex:indexPath.section];
                    ((PromoCollectionReusableView *)reusableView).delegate = self;
                    ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
                    if (self.scrollDirection == ScrollDirectionDown && indexPath.section == 1) {
                        [((PromoCollectionReusableView *)reusableView) scrollToCenter];
                    }
                    
                }
            }
        } else {
            reusableView = nil;
        }
    }
    else if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"RetryView"
                                                                     forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"FooterView"
                                                                     forIndexPath:indexPath];
        }
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    SearchAWSProduct *product = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        CatalogViewController *vc = [CatalogViewController new];
        vc.catalogID = product.catalog_id;
        vc.catalogName = product.catalog_name;
        vc.catalogPrice = product.catalog_price;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [TPAnalytics trackProductClick:product];
        [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCellSize sizeWithType:self.cellType];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
        if (_promo.count > section) {
            NSArray *currentPromo = [_promo objectAtIndex:section];
            
            if(_promoCellType == PromoCollectionViewCellTypeThumbnail){
                if(section % 2 == 0){
                    if (currentPromo && currentPromo.count > 0) {
                        CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
                        size = CGSizeMake(self.view.frame.size.width, headerHeight);
                    }
                }
            }else{
                if (currentPromo && currentPromo.count > 0) {
                    CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
                    size = CGSizeMake(self.view.frame.size.width, headerHeight);
                }
            }
        }
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    NSInteger lastSection = [self numberOfSectionsInCollectionView:collectionView] - 1;
    if (section == lastSection) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""]) {
            size = CGSizeMake(self.view.frame.size.width, 50);
        }
    } else if (_product.count == 0 && _start == 0) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh {
    _start = 0;
    _urinext = nil;
    
    [_refreshControl beginRefreshing];
    [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    
    [self requestSearch];
    
    [_act startAnimating];
}

-(IBAction)tap:(id)sender { 
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            // Action Urutkan Button
            SortViewController *controller = [SortViewController new];
            controller.delegate = self;
            controller.selectedIndexPath = _sortIndexPath;
            if(_isFromImageSearch){
                controller.sortType = SortImageSearch;
            }else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
                controller.sortType = SortProductSearch;
            } else {
                controller.sortType = SortCatalogSearch;
            }
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
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
                title = [_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTTITLEKEY];
            } else if ([_data objectForKey:kTKPDSEARCH_APIDEPARTMENTNAMEKEY]) {
                title = [_data objectForKey:kTKPDSEARCH_APIDEPARTMENTNAMEKEY];
            } else if ([_data objectForKey:kTKPDSEARCH_DATASEARCHKEY]) {
                title = [_data objectForKey:kTKPDSEARCH_DATASEARCHKEY];
            }
            title = [[NSString stringWithFormat:@"Jual %@ | Tokopedia", title] capitalizedString];
            NSURL *url = [NSURL URLWithString: _searchObject.result.share_url?:@"www.tokopedia.com"];
            UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                              url:url
                                                                                           anchor:button];
            
            [self presentViewController:controller animated:YES completion:nil];
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
            
            _collectionView.contentOffset = CGPointMake(0, 0);
            [_collectionView reloadData];
            [_collectionView layoutIfNeeded];
            
            NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
            [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_params setObject:sort forKey:@"order_by"];
    
    if([[_params objectForKey:@"order_by"] isEqualToString:@"99"]){
        [self restoreSimilarity];
        //image search sort by similarity
        NSArray* sortedProducts = [[_product firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
            CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
            return first > second;
        }];
        _product[0] = [NSMutableArray arrayWithArray:sortedProducts];
        _sortIndexPath = indexPath;
        [_refreshControl beginRefreshing];
        [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_refreshControl endRefreshing];
            [_collectionView reloadData];
        });
    } else {
        //normal sort
        [self refreshView:nil];
        _sortIndexPath = indexPath;
    }
    
}

#pragma mark - Category notification
- (void)changeCategory:(NSNotification *)notification {
    [_params setObject:[notification.userInfo objectForKey:@"department_id"] forKey:@"department_id"];
    [_params setObject:[_data objectForKey:@"search"]?:@"" forKey:@"search"];
    
    [self refreshView:nil];
}

#pragma mark - LoadingView Delegate
- (IBAction)pressRetryButton:(id)sender {
    [self requestSearch];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter {
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject:@"ios" forKey:@"device"];
    [parameter setObject:[_params objectForKey:@"department_id"]?:@"" forKey:@"sc"];
    [parameter setObject:[_params objectForKey:@"location"]?:@"" forKey:@"floc"];
    [parameter setObject:[_params objectForKey:@"order_by"]?:@"" forKey:@"ob"];
    [parameter setObject:[_params objectForKey:@"price_min"]?:@"" forKey:@"pmin"];
    [parameter setObject:[_params objectForKey:@"price_max"]?:@"" forKey:@"pmax"];
    [parameter setObject:[_params objectForKey:@"shop_type"]?:@"" forKey:@"fshop"];
    [parameter setObject:[_params objectForKey:@"sc_identifier"]?:@"" forKey:@"sc_identifier"];
    if(_isFromImageSearch){
        [parameter setObject:_image_url forKey:@"image_url"];
        if (_strImageSearchResult) {
            [parameter setObject:_strImageSearchResult forKey:@"id"];
            [parameter setObject:@(allProductsCount) forKey:@"rows"];
        }
        if([_product firstObject] != nil && [[_product firstObject] count] > 0){
            [parameter setObject:@(0) forKey:@"start"];
        }
    } else {
        [parameter setObject:[_params objectForKey:@"search"]?:@"" forKey:@"q"];
        [parameter setObject:startPerPage forKey:@"rows"];
        [parameter setObject:@(_start) forKey:@"start"];
        [parameter setObject:@"true" forKey:@"breadcrumb"];
    }
    return parameter;
}

- (NSString*)generateProductIdString{
    NSString* strResult = @"";
    NSMutableArray *products = [_product firstObject];
    for(SearchAWSProduct *prod in products){
        strResult = [strResult stringByAppendingString:[NSString stringWithFormat:@"%@,", prod.product_id]];
    }
    if([strResult length] > 0){
        strResult = [strResult substringToIndex:[strResult length] - 1];
    }
    return strResult;
}


#pragma mark - requestWithBaseUrl
- (void)requestSearch {
    [_networkManager requestWithBaseUrl:@"https://ace.tokopedia.com"
                                   path:[[self pathUrls] objectForKey:[_data objectForKey:@"type"]]
                                 method:RKRequestMethodGET
                              parameter:[self getParameter]
                                mapping:[SearchAWS mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self reloadView];
                                  [self searchMappingResult:successResult];
                              } onFailure:nil];
}

- (NSDictionary*)pathUrls {
    NSDictionary *pathDictionary = @{
                                     @"search_catalog" : @"/search/v1/catalog",
                                     @"search_shop" : @"/search/v1/shop",
                                     @"search_product" : @"/search/v1/product"
                                     };
    return pathDictionary;
}

- (void)backupSimilarity{
    for(SearchAWSProduct *prod in [_product firstObject]){
        [_similarityDictionary setObject:prod.similarity_rank forKey:prod.product_id];
    }
}

- (void)restoreSimilarity{
    NSMutableArray *products = [_product firstObject];
    for(int i=0;i<[products count];i++){
        NSString* productId = ((SearchAWSProduct*)products[i]).product_id;
        ((SearchAWSProduct*)products[i]).similarity_rank = [_similarityDictionary objectForKey:productId];
    }
    if (_product.count > 0) {
        _product[0] = products;
    }
}

- (void)reloadView {
    [_noResultView removeFromSuperview];
    [_firstFooter removeFromSuperview];
    
    if(_start == 0) {
        [_product removeAllObjects];
        [_promo removeAllObjects];
    }
}


- (void)imageSearchMappingResult:(RKMappingResult *)mappingResult {
    ImageSearchResponse *search = [mappingResult.dictionary objectForKey:@""];
    if(search.data.similar_prods.count > 0){
        
        [_product addObject:search.data.similar_prods];
        
        [self backupSimilarity];
        
        _strImageSearchResult = [self generateProductIdString];
        allProductsCount = [[_product firstObject] count];
        _start = [[self splitUriToPage:_urinext] integerValue];
        if([_urinext isEqualToString:@""]) {
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:[_params objectForKey:@"search"]];
        [_noResultView removeFromSuperview];
        
        for (UIButton *button in self.imageSearchToolbarButtons) {
            button.enabled = YES;
        }
        
    } else {
        //no data at all
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        
        if([self isUsingAnyFilter]){
            _suggestion = @"";
            [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan filter lain"];
            [_noResultView hideButton:YES];
        }else{
            [_noResultView setNoResultDesc:@"Mohon maaf, gambar serupa tidak dapat ditemukan. Coba foto lagi dari sisi yang berbeda."];
            [_noResultView hideButton:YES];
        }
        [_collectionView addSubview:_noResultView];
    }
    
    //if(_start > 0) [self requestPromo];
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else  {
        [_collectionView reloadData];
    }
}

- (void)searchMappingResult:(RKMappingResult *)mappingResult {
    SearchAWS *search = [mappingResult.dictionary objectForKey:@""];
    _searchObject = search;
    
    [self reloadView];
    
    if ([_delegate respondsToSelector:@selector(updateCategories:)]) {
        [_delegate updateCategories:search.result.breadcrumb];
    }
    
    NSString *redirect_url = search.result.redirect_url;
    if(search.result.department_id && ![search.result.department_id isEqualToString:@"0"]) {
        NSString *departementID = search.result.department_id?:@"";
        [_params setObject:departementID forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
        if ([_delegate respondsToSelector:@selector(updateTabCategory:)]) {
            CategoryDetail *category = [CategoryDetail new];
            category.categoryId = departementID;
            [_delegate updateTabCategory:category];
        }
    }
    if([redirect_url isEqualToString:@""] || redirect_url == nil || [redirect_url isEqualToString:@"0"]) {
        NSString *hascatalog = search.result.has_catalog;
        
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            hascatalog = @"1";
        }
        
        //setting is this product has catalog or not
        if ([hascatalog isEqualToString:@"1"] && hascatalog) {
            NSDictionary *userInfo = @{@"count":@(3)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        else if ([hascatalog isEqualToString:@"0"] && hascatalog){
            NSDictionary *userInfo = @{@"count":@(2)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        
        
        if([[_data objectForKey:@"type"] isEqualToString:@"search_product"]) {
            if(search.result.products.count > 0) {
                [_product addObject: search.result.products];
                [TPAnalytics trackProductImpressions:search.result.products];
            }
            
        } else {
            if(search.result.catalogs.count > 0) {
                //_product[0] is for products
                //so everything is in first index
                //you're welcome!
                [_product addObject: search.result.catalogs];
            }
            
        }
        
        if(_start == 0) {
            [_collectionView setContentOffset:CGPointZero animated:YES];
            
            [_collectionView reloadData];
            //            [_collectionView layoutIfNeeded];
        }
        [self requestPromo];
        if (search.result.products.count > 0 || search.result.catalogs.count > 0) {
            _urinext =  search.result.paging.uri_next;
            _start = [[self splitUriToPage:_urinext] integerValue];
            if([_urinext isEqualToString:@""]) {
                [_flowLayout setFooterReferenceSize:CGSizeZero];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:[_params objectForKey:@"search"]];
            [_noResultView removeFromSuperview];
            
            if(_isFromImageSearch && [_params objectForKey:@"order_by"] && [[_params objectForKey:@"order_by"] isEqualToString:@"99"]){
                [self restoreSimilarity];
                //image search sort by similarity
                NSArray* sortedProducts = [[_product firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
                    CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
                    return first > second;
                }];
                _product[0] = [NSMutableArray arrayWithArray:sortedProducts];
            }
        } else {
            //no data at all
            [_flowLayout setFooterReferenceSize:CGSizeZero];
            
            if([self isUsingAnyFilter]){
                _suggestion = @"";
                [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan filter lain"];
                [_noResultView hideButton:YES];
            }else{
                if([_data objectForKey:@"search"] && ![[_data objectForKey:@"search"] isEqualToString:@""]){
                    [_spellCheckRequest getSpellingSuggestion:@"product" query:[_data objectForKey:@"search"] category:@"0"];
                }else{
                    _suggestion = @"";
                }
            }
            
            [_collectionView addSubview:_noResultView];
        }
        
        
        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
            [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else  {
            [_collectionView reloadData];
        }
    } else {
        
        NSURL *url = [NSURL URLWithString:search.result.redirect_url];
        NSArray* query = [[url path] componentsSeparatedByString: @"/"];
        
        // Redirect URI to hotlist
        if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTHOTKEY]) {
            [self performSelector:@selector(redirectToHotlistResult) withObject:nil afterDelay:1.0f];
        }
        
        // redirect uri to search category
        else if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTCATEGORY]) {
            NSString *departementID = search.result.department_id?:@"";
            [_params setObject:departementID forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
            [_params removeObjectForKey:@"search"];
            [_networkManager requestCancel];
            
            if ([self.delegate respondsToSelector:@selector(updateTabCategory:)]) {
                CategoryDetail *category = [CategoryDetail new];
                category.categoryId = departementID;
                [self.delegate updateTabCategory:category];
            }
            
            [self refreshView:nil];
            
            [Localytics triggerInAppMessage:@"Category Result Screen"];
        }
        
        else if ([query[1] isEqualToString:@"catalog"]) {
            [self performSelector:@selector(redirectToCatalogResult) withObject:nil afterDelay:1.0f];
        }
        
        else {
            [Localytics triggerInAppMessage:@"Search Result Screen"];
        }
    }
}

- (void)redirectToCatalogResult{
    NSURL *url = [NSURL URLWithString:_searchObject.result.redirect_url];
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

- (void)redirectToHotlistResult{
    [Localytics triggerInAppMessage:@"Hot List Result Screen"];
    
    NSURL *url = [NSURL URLWithString:_searchObject.result.redirect_url];
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

- (NSString*)splitUriToPage:(NSString*)uri {
    NSURL *url = [NSURL URLWithString:uri];
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
    
    return [queries objectForKey:@"start"];
}

#pragma mark - No Result Delegate

- (void) buttonDidTapped:(id)sender{
    [_params setObject:_suggestion forKey:@"search"];
    [_noResultView removeFromSuperview];
    
    NSDictionary *newData = @{
                            @"auth" : [_data objectForKey:@"auth"],
                            @"type" : [_data objectForKey:@"type"],
                            @"search": _suggestion
                            };
    _data = newData;
    self.title = _suggestion;
    
//    [_networkManager doRequest];
    [self requestSearch];
}

#pragma mark - Other Method
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _searchBaseUrl = [_gtmContainer stringForKey:GTMKeySearchBase];
    _searchPostUrl = [_gtmContainer stringForKey:GTMKeySearchPost];
    _searchFullUrl = [_gtmContainer stringForKey:GTMKeySearchFull];
}

- (BOOL) isUsingAnyFilter{
    BOOL isUsingLocationFilter = [_params objectForKey:@"location"] != nil && ![[_params objectForKey:@"location"] isEqualToString:@""];
    BOOL isUsingDepFilter = [_params objectForKey:@"department_id"] != nil;
    BOOL isUsingPriceMinFilter = [_params objectForKey:@"price_min"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"price_min"]] isEqualToString:@"0"];
    BOOL isUsingPriceMaxFilter = [_params objectForKey:@"price_max"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"price_max"]] isEqualToString:@"0"];;
    BOOL isUsingShopTypeFilter = [_params objectForKey:@"shop_type"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"shop_type"]] isEqualToString:@"0"];;
    
    return  (isUsingDepFilter || isUsingLocationFilter || isUsingPriceMaxFilter || isUsingPriceMinFilter || isUsingShopTypeFilter);
}

- (BOOL) isUsingAnyFilterExceptCategory{
    BOOL isUsingLocationFilter = [_params objectForKey:@"location"] != nil && ![[_params objectForKey:@"location"] isEqualToString:@""];
    BOOL isUsingPriceMinFilter = [_params objectForKey:@"price_min"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"price_min"]] isEqualToString:@"0"];
    BOOL isUsingPriceMaxFilter = [_params objectForKey:@"price_max"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"price_max"]] isEqualToString:@"0"];;
    BOOL isUsingShopTypeFilter = [_params objectForKey:@"shop_type"] != nil && ![[[NSString alloc]initWithFormat:@"%@", [_params objectForKey:@"shop_type"]] isEqualToString:@"0"];;
    
    return  ( isUsingLocationFilter || isUsingPriceMaxFilter || isUsingPriceMinFilter || isUsingShopTypeFilter);
}

#pragma mark - Promo collection delegate

- (void)requestPromo {
    NSInteger page = _start/[startPerPage integerValue];
    
    if(page % 2 == 0){
        NSString *search =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY]?:@"";
        NSString *departmentId =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]?:@"";
        [_promoRequest requestForProductQuery:search
                                   department:departmentId
                                         page:page
                                    onSuccess:^(NSArray<PromoResult *> *promoResult) {
                                        if (promoResult) {
                                            if(promoResult.count > 2){
                                                NSRange arrayRangeToBeTaken = NSMakeRange(0, promoResult.count/2);
                                                NSArray *promoArrayFirstHalf = [promoResult subarrayWithRange:arrayRangeToBeTaken];
                                                arrayRangeToBeTaken.location = arrayRangeToBeTaken.length;
                                                arrayRangeToBeTaken.length = promoResult.count - arrayRangeToBeTaken.length;
                                                NSArray *promoArrayLastHalf = [promoResult subarrayWithRange:arrayRangeToBeTaken];
                                                
                                                [_promo addObject:promoArrayLastHalf];
                                                [_promo addObject:promoArrayFirstHalf];
                                                [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
                                                [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
                                            }else{
                                                [_promo addObject:promoResult];
                                                [_promo addObject:[NSArray new]];
                                                [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
                                                [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
                                            }
                                        } else if (promoResult == nil && _start == [startPerPage integerValue]) {
                                            [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
                                        }
                                        [_collectionView reloadData];
                                    } onFailure:^(NSError *error) {
                                        [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
                                        [_collectionView reloadData];
                                    }];
    }
}

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (void)didSelectPromoProduct:(PromoResult *)promoResult {
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHPRODUCTKEY]) {
        NavigateViewController *navigateController = [NavigateViewController new];
        NSDictionary *productData = @{
            @"product_id"       : promoResult.product.product_id?:@"",
            @"product_name"     : promoResult.product.name?:@"",
            @"product_image"    : promoResult.product.image.s_url?:@"",
            @"product_price"    : promoResult.product.price_format?:@"",
            @"shop_name"        : promoResult.shop.name?:@""
        };

        PromoRequestSourceType source;
        if ([_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY]) {
            source = PromoRequestSourceCategory;
        } else if ([_params objectForKey:kTKPDSEARCH_DATASEARCHKEY]) {
            source = PromoRequestSourceSearch;
        }

        NSDictionary *promoData = @{
            kTKPDDETAIL_APIPRODUCTIDKEY : promoResult.product.product_id,
            PromoImpressionKey          : promoResult.ad_ref_key,
            PromoClickURL               : promoResult.product_click_url,
            PromoRequestSource          : @(source)
        };

        [navigateController navigateToProductFromViewController:self
                                                      promoData:promoData
                                                    productData:productData];
    }
}

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

#pragma mark - Spell Check Delegate

-(void)didReceiveSpellSuggestion:(NSString *)suggestion totalData:(NSString *)totalData{
    _suggestion = suggestion;
    if([_suggestion isEqual:nil] || [_suggestion isEqual:@""]){
        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan kata kunci lain"];
        [_noResultView hideButton:YES];
    }else if([_data count] > 3){
        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan filter lain"];
        [_noResultView hideButton:YES];
    }else{
        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan kata kunci lain. Mungkin maksud Anda: "];
        [_noResultView setNoResultButtonTitle:_suggestion];
        [_noResultView hideButton:NO];
    }
}

#pragma mark - ImageSearchRequest Delegate
-(void)didReceiveUploadedImageURL:(NSString *)imageURL{
    _image_url = imageURL;

    [_networkManager requestWithBaseUrl:@"https://ws.tokopedia.com"
                                   path:@"/v4/search/snapsearch.pl"
                                 method:RKRequestMethodGET
                              parameter:[self getParameter]
                                mapping:[ImageSearchResponse mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self reloadView];
                                  [self imageSearchMappingResult:successResult];
                              } onFailure:nil];
}

- (void)orientationChanged:(NSNotification*)note {
    [_collectionView reloadData];
}



@end