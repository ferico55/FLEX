//
//  DetailPriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "CMPopTipView.h"
#import "Catalog.h"
#import "CatalogViewController.h"
#import "CatalogShops.h"
#import "detail.h"
#import "DepartmentTableViewController.h"
#import "DetailPriceAlert.h"
#import "DetailProductResult.h"
#import "DetailCatalogResult.h"
#import "DetailPriceAlertTableViewCell.h"
#import "DetailPriceAlertViewController.h"
#import "LoginViewController.h"
#import "LoadingView.h"
#import "NoResult.h"
#import "Paging.h"
#import "PriceAlertCell.h"
#import "Product.h"
#import "PriceAlertViewController.h"
#import "ProductDetail.h"
#import "PriceAlert.h"
#import "PriceAlertResult.h"
#import "ShopStats.h"
#import "ShopReputation.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "ShopContainerViewController.h"
#import "string_price_alert.h"
#import "string_product.h"
#import "string_catalog.h"
#import "string_transaction.h"
#import "TokopediaNetworkManager.h"
#import "TransactionATCViewController.h"
#import "NavigateViewController.h"
#import "PriceAlertRequest.h"
#define CCellIdentifier @"cell"

#define CTagGetDetailPriceList 1
#define CHeaderViewContent 1
#define CHeaderImg 2
#define CHeaderLabelHeader 3
#define CHeaderLabelDate 4
#define CTagGetProductDetail 5
#define CTagGoldMerchant 6
#define CTagLocation 7
#define CTagKecepatan 8
#define CTagAkurasi 9
#define CTagPelayanan 10
#define CTagSmiley 11
#define CTagSort 1
#define CTagFilter 2

@interface BtnSmiley : UIButton
@property (nonatomic) int intTag;
@end

@implementation BtnSmiley
@synthesize intTag;
@end

@interface DetailPriceAlertViewController ()<TokopediaNetworkManagerDelegate, LoginViewDelegate, LoadingViewDelegate, DepartmentListDelegate, CMPopTipViewDelegate> {
    CMPopTipView *cmPopTitpView;
    NSMutableArray *catalogList;
    PriceAlertCell *priceAlertCell;
    TokopediaNetworkManager *tokopediaNetworkManager;
    DepartmentTableViewController *departmentViewController;
    RKObjectManager *objectManager;
    
    NSString *strTempProductID;
    NoResultView *noResultView;
    UIActivityIndicatorView *activityIndicatorView, *activityIndicatorLoadProductDetail;
    LoadingView *loadingView;
    NavigateViewController *_TKPDNavigator;
    int nSelectedFilter, nSelectedSort, page;
    
    PriceAlertRequest *_request;
}

@end

@implementation DetailPriceAlertViewController
- (void)dealloc {
    [self deallocNetworkManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CStringNotificationHarga;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CStringUbah style:UIBarButtonItemStylePlain target:self action:@selector(actionUbah:)];
    
    _TKPDNavigator = [NavigateViewController new];
    
    page = 1;
    NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:@"PriceAlertCell" owner:nil options:0];
    priceAlertCell = [arrPriceAlert objectAtIndex:0];
    [self.view addSubview:priceAlertCell.getViewContent];
    
    priceAlertCell.getBtnProductName.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    priceAlertCell.getBtnProductName.titleLabel.numberOfLines = 2;

    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintTrailling];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintBottom];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintX];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintY];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdatePriceAlert:) name:@"UpdatePriceAlert" object:nil];
    
    _request = [PriceAlertRequest new];
    
    //Set Header
    [self setHeader];
}


- (void)notificationUpdatePriceAlert:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *price = [userInfo objectForKey:@"price"];
    
    [self updatePriceAlert:price];
}

- (void)setHeader {
    UIView *tempViewContent = priceAlertCell.getViewContent;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[tempViewContent]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[tempViewContent]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    priceAlertCell.getConstraintProductNameAndX.constant -= priceAlertCell.getBtnClose.bounds.size.width;
    [priceAlertCell.getBtnClose setHidden:YES];
    [self setContentValue];
    constraintYLineHeader.constant = tempViewContent.frame.origin.y + tempViewContent.bounds.size.height + 1;
    constraintHeightTable.constant = self.view.bounds.size.height - (viewLineHeader.frame.origin.y+viewLineHeader.bounds.size.height);
    
    [self.view bringSubviewToFront:viewLineHeader];
    [self.view layoutIfNeeded];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    [self getPriceAlertDetail];
    [self isGettingCatalogList:YES];
    
    
    tblDetailPriceAlert.allowsSelection = NO;
    if ([_detailPriceAlert.pricealert_type isEqualToString:@"1"]) {//Catalog
        constraintWidthUrutkan.constant = 0;
        constraintWidthFilter.constant = self.view.bounds.size.width;
        constraintWidthSeparatorButton.constant = 0;
        btnFilter.titleLabel.font = [UIFont fontWithName:CGothamBook size:15.0f];
        [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Action View
- (void)actionDetailProduct:(id)sender {
    if (strTempProductID != nil) {
        [self deallocNetworkManager];
        [self showActivityIndicatorGetProductDetail:NO];
    }
    
    if ([_detailPriceAlert.pricealert_type isEqualToString:@"1"]) {
        [self redirectToDetailProduct:nil];
    }
    else {
        CatalogViewController *catalogViewController = [CatalogViewController new];
        catalogViewController.catalogID = _detailPriceAlert.pricealert_product_id;
        catalogViewController.catalogName = _detailPriceAlert.pricealert_product_name;
        catalogViewController.catalogImage = _detailPriceAlert.pricealert_product_image;
        catalogViewController.catalogPrice = _detailPriceAlert.pricealert_price;
        [self.navigationController pushViewController:catalogViewController animated:YES];
    }
}

- (void)actionSort:(id)sender {
    if (tblDetailPriceAlert.delegate != nil) {
        departmentViewController = [DepartmentTableViewController new];
        departmentViewController.del = self;
        departmentViewController.arrList = @[CStringPembaruanTerakhir, CStringProductTerjual, CStringUlasan, CStringHargaTerendah, CStringHargaTertinggi];
        departmentViewController.selectedIndex = nSelectedSort;
        departmentViewController.tag = CTagSort;
        departmentViewController.navigationItem.title = CStringSort;
        [self.navigationController pushViewController:departmentViewController animated:YES];
    }
}

- (void)actionFilter:(id)sender {
    if (tblDetailPriceAlert.delegate != nil) {
        departmentViewController = [DepartmentTableViewController new];
        departmentViewController.del = self;
        departmentViewController.arrList = @[CStringSemuaKondisi, CStringBaru, CStringBekas];
        departmentViewController.selectedIndex = nSelectedFilter;
        departmentViewController.tag = CTagFilter;
        departmentViewController.navigationItem.title = CstringFilter;
        [self.navigationController pushViewController:departmentViewController animated:YES];
    }
}

- (void)actionShopName:(id)sender {
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    CatalogShops *catalogShop = [catalogList objectAtIndex:((CustomButton *) sender).tagIndexPath.section];
    ShopContainerViewController *shopContainerViewController = [ShopContainerViewController new];
    shopContainerViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:catalogShop.shop_id,
                                         kTKPDDETAIL_APISHOPNAMEKEY:catalogShop.shop_name,
                                         kTKPD_AUTHKEY:_auth?:@{}};
    [self.navigationController pushViewController:shopContainerViewController animated:YES];
}

- (void)actionProductName:(id)sender {
    [self redirectToDetailProduct:((ProductDetail *) [((CatalogShops *) [catalogList objectAtIndex:((CustomButton *) sender).tagIndexPath.section]).product_list objectAtIndex:((CustomButton *) sender).tagIndexPath.row])];
}

- (void)actionBuy:(id)sender {
    CustomButton *btnBuy = (CustomButton *)sender;
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    ProductDetail *tempProductDetail = [((CatalogShops *) [catalogList objectAtIndex:btnBuy.tagIndexPath.section]).product_list objectAtIndex:btnBuy.tagIndexPath.row];
    
    if (_auth) {
        strTempProductID = tempProductDetail.product_id;
        [self showActivityIndicatorGetProductDetail:YES];
        [[self getNetworkManager:CTagGetProductDetail] doRequest];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)actionSmiley:(BtnSmiley *)btnSmile {
    CatalogShops *catalogShops = [catalogList objectAtIndex:btnSmile.intTag];
    
    NSString *strText = [NSString stringWithFormat:@"%@ %@", catalogShops.shop_reputation_badge.reputation_score==nil||[catalogShops.shop_reputation_badge.reputation_score isEqualToString:@""]? @"0":catalogShops.shop_reputation_badge.reputation_score, CStringPoin];
    [self initPopUp:strText withSender:btnSmile withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
}


#pragma mark - Method
- (void)getPriceAlertDetail {
    NSInteger filter = 0;
    
    if (nSelectedFilter > 0) {
        filter = (NSInteger) nSelectedFilter;
    }
    
    [_request requestGetPriceAlertDetailWithPriceAlertID:_detailPriceAlert.pricealert_id?:@""
                                               condition:filter
                                                 orderBy:((NSInteger) nSelectedSort) + 1
                                                    page:(NSInteger) page
                                               onSuccess:^(PriceAlertResult *result) {
                                                   if (page == 1) {
                                                       catalogList = [NSMutableArray arrayWithArray:result.list_catalog_shop];
                                                       [tblDetailPriceAlert scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                                                   } else {
                                                       [catalogList addObjectsFromArray:result.list_catalog_shop];
                                                   }
                                                   
                                                   [self isGettingCatalogList:NO];
                                                   
                                                   if (catalogList==nil || catalogList.count==0) {
                                                       [tblDetailPriceAlert addSubview:[self getNoResultView]];
                                                   } else if (noResultView != nil) {
                                                       [noResultView.view removeFromSuperview];
                                                       noResultView = nil;
                                                   }
                                                   
                                                   if (tblDetailPriceAlert.delegate == nil) {
                                                       tblDetailPriceAlert.delegate = self;
                                                       tblDetailPriceAlert.dataSource = self;
                                                   }
                                                   
                                                   
                                                   if (![result.paging.uri_next isEqualToString:@"0"]) {
                                                       NSURL *url = [NSURL URLWithString:result.paging.uri_next];
                                                       NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                                                       NSMutableDictionary *queries = [NSMutableDictionary new];
                                                       for (NSString *keyValuePair in querry) {
                                                           NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                                                           NSString *key = [pairComponents objectAtIndex:0];
                                                           NSString *value = [pairComponents objectAtIndex:1];
                                                           
                                                           [queries setObject:value forKey:key];
                                                       }
                                                       
                                                       page = [[queries objectForKey:@"page"] intValue];
                                                   }
                                                   else {
                                                       page = 1;
                                                   }
                                                   
                                                   
                                                   [tblDetailPriceAlert reloadData];
                                               }
                                               onFailure:^(NSError *error) {
                                                   [self isGettingCatalogList:NO];
                                                   [self showRetryLoadCatalog:YES withTag:1];
                                               }];
}

- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range {
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}


- (void)redirectToDetailProduct:(ProductDetail *)detailProduct {
    [_TKPDNavigator navigateToProductFromViewController:self withName:detailProduct.product_name?:_detailPriceAlert.pricealert_product_name withPrice:detailProduct.product_price?:_detailPriceAlert.pricealert_price withId:detailProduct.product_id?:_detailPriceAlert.pricealert_product_id withImageurl:detailProduct.product_pic?:_detailPriceAlert.pricealert_product_image withShopName:nil];
}


- (BOOL)canRedirectView {
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    return [viewController isMemberOfClass:[self class]];
}

- (void)deallocNetworkManager {
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager = nil;
}

- (void)continueProcessBuy:(DetailProductResult *)productDetail {
    TransactionATCViewController *transactionVC = [TransactionATCViewController new];
    transactionVC.data = @{DATA_DETAIL_PRODUCT_KEY:productDetail};
    transactionVC.productID = productDetail.product.product_id;
    [self.navigationController pushViewController:transactionVC animated:YES];
}

- (void)isGettingCatalogList:(BOOL)isLoad {
    if (isLoad) {
        tblDetailPriceAlert.tableFooterView = [self getActivityIndicator];
    }
    else {
        [activityIndicatorView stopAnimating];
        activityIndicatorView = nil;
        tblDetailPriceAlert.tableFooterView = nil;
    }
}

- (void)showRetryLoadCatalog:(BOOL)retryLoadCatalog withTag:(int)tag {
    if (retryLoadCatalog) {
        tblDetailPriceAlert.tableFooterView = [self getLoadingView:tag].view;
    }
    else {
        loadingView = nil;
        tblDetailPriceAlert.tableFooterView = nil;
    }
}

- (LoadingView *)getLoadingView:(int)tag {
    if (loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    loadingView.tag = tag;
    
    return loadingView;
}

- (UIActivityIndicatorView *)getActivityIndicator {
    if (activityIndicatorView == nil) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.frame = CGRectMake(0, 10, 40, 40);
        [activityIndicatorView startAnimating];
    }
    
    return activityIndicatorView;
}

- (void)showActivityIndicatorGetProductDetail:(BOOL)show {
    if (show) {
        tblDetailPriceAlert.userInteractionEnabled = NO;
        activityIndicatorLoadProductDetail = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        activityIndicatorLoadProductDetail.color = [UIColor blackColor];
        [activityIndicatorLoadProductDetail startAnimating];
        activityIndicatorLoadProductDetail.center = CGPointMake(self.view.bounds.size.width/2.0f, (self.view.bounds.size.height/2.0f)+(priceAlertCell.contentView.bounds.size.height/2.0f));
        [self.view addSubview:activityIndicatorLoadProductDetail];
    }
    else {
        tblDetailPriceAlert.userInteractionEnabled = YES;
        [activityIndicatorLoadProductDetail removeFromSuperview];
        [activityIndicatorLoadProductDetail stopAnimating];
        activityIndicatorLoadProductDetail = nil;
    }
}

- (NoResultView *)getNoResultView {
    if (noResultView == nil) {
        noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, tblDetailPriceAlert.frame.size.width, 200)];
    }
    
    return noResultView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if (tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}


- (NSString *)getPrice:(NSString *)strTempPrice {
    return [strTempPrice isEqualToString:@"Rp 0"]? CStringAllPrice:strTempPrice;
}


- (void)updatePriceAlert:(NSString *)strPrice {
    _detailPriceAlert.pricealert_price = [self getPrice:strPrice];
    [priceAlertCell setPriceNotification:_detailPriceAlert.pricealert_price];
    
    [catalogList removeAllObjects];
    [tblDetailPriceAlert reloadData];
    [self isGettingCatalogList:YES];
    [self getPriceAlertDetail];
}


- (void)setContentValue {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: style};
    NSAttributedString *myString = [[NSAttributedString alloc] initWithString:_detailPriceAlert.pricealert_product_name?:@"" attributes:attributes];
    priceAlertCell.getBtnProductName.titleLabel.attributedText = myString;
    
    CGSize tempSize = [priceAlertCell.getBtnProductName.titleLabel sizeThatFits:CGSizeMake(priceAlertCell.getBtnProductName.bounds.size.width, 9999)];
    if ((priceAlertCell.getConstraintHeigthProductName.constant*2) < tempSize.height)
        priceAlertCell.getConstraintHeigthProductName.constant += priceAlertCell.getConstraintHeigthProductName.constant;
    else if (tempSize.height > priceAlertCell.getConstraintHeigthProductName.constant)
        priceAlertCell.getConstraintHeigthProductName.constant = tempSize.height;
    
    [priceAlertCell setImageProduct:_imageHeader?:nil];
    [priceAlertCell setLblDateProduct:_detailPriceAlert.pricealert_time?:@""];
    [priceAlertCell setPriceNotification:[self getPrice:_detailPriceAlert.pricealert_price?:@""]];
    [priceAlertCell setLowPrice:_detailPriceAlert.pricealert_price_min?:@""];
    [priceAlertCell setProductName:_detailPriceAlert.pricealert_product_name?:@""];
    
    [priceAlertCell getBtnProductName].userInteractionEnabled = YES;
    [[priceAlertCell getBtnProductName] addTarget:self action:@selector(actionDetailProduct:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)actionUbah:(id)sender {
    if (strTempProductID != nil) {
        [self deallocNetworkManager];
        [self showActivityIndicatorGetProductDetail:NO];
    }
    
    if ([self canRedirectView]) {
        PriceAlertViewController *priceAlertViewController = [PriceAlertViewController new];
        priceAlertViewController.detailPriceAlert = _detailPriceAlert;
        [self.navigationController pushViewController:priceAlertViewController animated:YES];
    }
}

#pragma mark - UITableView Delegate And DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return catalogList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((CatalogShops *) [catalogList objectAtIndex:section]).product_list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    int diameterImage = 50;
    int diameterGold = 20;
    int padding = 8;
    int heightProductName = 17;

    UITableViewHeaderFooterView *view = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 74)];
        view.backgroundColor = tableView.backgroundColor;
        view.contentView.backgroundColor = tableView.backgroundColor;
        
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(8, 8, tableView.bounds.size.width-(8*2), 66)];
        viewContent.backgroundColor = [UIColor whiteColor];
        viewContent.tag = CHeaderViewContent;
        [view.contentView addSubview:viewContent];
        
        UIImageView *imgHeader = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, diameterImage, diameterImage)];
        imgHeader.tag = CHeaderImg;
        imgHeader.layer.cornerRadius = imgHeader.bounds.size.width/2.0f;
        imgHeader.layer.masksToBounds = YES;
        [viewContent addSubview:imgHeader];
        
        
        //Init Gold Merchant
        UIImageView *imgGoldMerchant = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, diameterGold, diameterGold)];
        imgGoldMerchant.tag = CTagGoldMerchant;
        imgGoldMerchant.image = [UIImage imageNamed:@"badges_gold_merchant.png"];
        [viewContent addSubview:imgGoldMerchant];
        
        //Init ProductName
        CustomButton *btnHeaderName = [CustomButton buttonWithType:UIButtonTypeCustom];
        btnHeaderName.backgroundColor = [UIColor clearColor];
        btnHeaderName.tag = CHeaderLabelHeader;
        btnHeaderName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnHeaderName setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnHeaderName.titleLabel.font = [UIFont fontWithName:CGothamBook size:15.0f];
        [btnHeaderName addTarget:self action:@selector(actionShopName:) forControlEvents:UIControlEventTouchUpInside];
        [viewContent addSubview:btnHeaderName];
        
        //Location
        UIButton *btnLokasi = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnLokasi setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_location" ofType:@"png"]] forState:UIControlStateNormal];
        btnLokasi.titleLabel.font = [UIFont fontWithName:CGothamBook size:12.0f];
        btnLokasi.tag = CTagLocation;
        [btnLokasi setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLokasi.frame = CGRectMake(viewContent.bounds.size.width-130, heightProductName+padding+(padding/2.0f), 130, heightProductName);
        [viewContent addSubview:btnLokasi];
        
        //Set Smiley
        BtnSmiley *btnSmiley = [BtnSmiley buttonWithType:UIButtonTypeCustom];
        [btnSmiley addTarget:self action:@selector(actionSmiley:) forControlEvents:UIControlEventTouchUpInside];
        btnSmiley.frame = CGRectMake(imgHeader.frame.origin.x+imgHeader.bounds.size.height + padding, btnLokasi.frame.origin.y, 100, btnLokasi.bounds.size.height);
        btnSmiley.tag = CTagSmiley;
        [btnSmiley setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        btnSmiley.titleLabel.font = btnLokasi.titleLabel.font;
        [btnSmiley setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [viewContent addSubview:btnSmiley];
    }
    
    CatalogShops *catalogShop = [catalogList objectAtIndex:section];
    UIView *tempViewContent = [view viewWithTag:CHeaderViewContent];
    __weak UIImageView *tempImage = (UIImageView *)[tempViewContent viewWithTag:CHeaderImg];
    [tempImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:catalogShop.shop_image]]  placeholderImage:[UIImage imageNamed:@""] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        tempImage.image = image;
    } failure:nil];

    
    UIImageView *imgGoldShop = (UIImageView *)[tempViewContent viewWithTag:CTagGoldMerchant];
    imgGoldShop.frame = (catalogShop.is_gold_shop)?CGRectMake(tempImage.frame.origin.x+tempImage.bounds.size.width + padding, padding, diameterGold, diameterGold) : CGRectMake(tempImage.frame.origin.x+tempImage.bounds.size.width + padding, padding, 0, diameterGold);
    
    CustomButton *btnHeaderName = (CustomButton *)[tempViewContent viewWithTag:CHeaderLabelHeader];
    btnHeaderName.frame = CGRectMake(imgGoldShop.frame.origin.x+imgGoldShop.bounds.size.width+padding/2.0f, padding, tempViewContent.bounds.size.width-(imgGoldShop.frame.origin.x+imgGoldShop.bounds.size.height+padding/2.0f), heightProductName);
    btnHeaderName.tagIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [btnHeaderName setTitle:catalogShop.shop_name forState:UIControlStateNormal];

    //Lokasi
    UIButton *btnLokasi= (UIButton *)[tempViewContent viewWithTag:CTagLocation];
    [btnLokasi setTitle:catalogShop.shop_location forState:UIControlStateNormal];
    
    //Smiley
    BtnSmiley *btnSmiley = (BtnSmiley *)[tempViewContent viewWithTag:CTagSmiley];
    [SmileyAndMedal generateMedalWithLevel:catalogShop.shop_reputation_badge.reputation_badge_object.level withSet:catalogShop.shop_reputation_badge.reputation_badge_object.set withImage:btnSmiley isLarge:NO];
    btnSmiley.intTag = (int)section;
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 144.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==catalogList.count-1 && page>1 && (!tokopediaNetworkManager.getObjectRequest.isExecuting && objectManager==nil) && tblDetailPriceAlert.tableFooterView==nil) {
        [self isGettingCatalogList:YES];
        [self getPriceAlertDetail];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailPriceAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if (cell == nil) {
        NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:@"DetailPriceAlertTableViewCell" owner:nil options:0];
        cell = [arrPriceAlert objectAtIndex:0];
    }
    
    cell.getBtnBuy.tagIndexPath = indexPath;
    cell.getBtnProductName.tagIndexPath = indexPath;
    ProductDetail *tempProductDetail = [((CatalogShops *) [catalogList objectAtIndex:indexPath.section]).product_list objectAtIndex:indexPath.row];
    [cell setNameProduct:tempProductDetail.product_name];
    [cell setKondisiProduct:tempProductDetail.product_condition];
    [cell setProductPrice:tempProductDetail.product_price_fmt];

    return cell;
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if (tag == CTagGetDetailPriceList) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:CGetPriceAlertDetail forKey:CAction];
        [param setObject:_detailPriceAlert.pricealert_id?:@"" forKey:CPriceAlertID];
        [param setObject:@(page) forKey:CPage];
        
        if (nSelectedFilter > 0) {
            [param setObject:@(nSelectedFilter) forKey:CCondition];
        }
        [param setObject:@(nSelectedSort+1) forKey:CSort];
        
        return param;
    }
    else if (tag == CTagGetProductDetail) {
        return @{
                 kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETDETAILACTIONKEY,
                 kTKPDDETAIL_APIPRODUCTIDKEY : strTempProductID
                 };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if (tag == CTagGetDetailPriceList) {
        return CInboxPriceAlert;
    }
    else if (tag == CTagGetProductDetail) {
        return kTKPDDETAILPRODUCT_APIPATH;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if (tag == CTagGetDetailPriceList) {
        objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PriceAlert class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PriceAlertResult class]];
        RKObjectMapping *priceAlertMapping = [RKObjectMapping mappingForClass:[DetailPriceAlert class]];
        [priceAlertMapping addAttributeMappingsFromDictionary:@{CPriceAlertTotalProduct:CPriceAlertTotalProduct,
                                                                CPriceAlertItemImage:CPriceAlertItemImage,
                                                                CPriceAlertItemName:CPriceAlertItemName,
                                                                CPriceAlertTotalUnread:CPriceAlertTotalUnread,
                                                                CPriceAlertProductShopID:CPriceAlertProductShopID,
                                                                CPriceAlertProductStatus:CPriceAlertProductStatus,
                                                                CPriceAlertType:CPriceAlertType,
                                                                CPriceAlertPrice:CPriceAlertPrice,
                                                                CPriceAlertCatalogID:CPriceAlertCatalogID,
                                                                CPriceAlertTypeDesc:CPriceAlertTypeDesc,
                                                                CPriceAlertPriceMin:CPriceAlertPriceMin,
                                                                CPriceAlertItemID:CPriceAlertItemID,
                                                                CPriceAlertProductCatalogID:CPriceAlertProductCatalogID,
                                                                CPriceAlertProductDepartmentID:CPriceAlertProductDepartmentID,
                                                                CPriceAlertCatalogDepartmentID:CPriceAlertCatalogDepartmentID,
                                                                CPriceAlertItemURI:CPriceAlertItemURI,
                                                                CPriceAlertCatalogName:CPriceAlertCatalogName,
                                                                CPriceAlertCatalogStatus:CPriceAlertCatalogStatus,
                                                                CPriceAlertID:CPriceAlertID
                                                                }];
        
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{CUriNext:CUriNext, CUriPrevious:CUriPrevious}];
        
        
        RKObjectMapping *catalogShopMapping = [RKObjectMapping mappingForClass:[CatalogShops class]];
        [catalogShopMapping addAttributeMappingsFromArray:@[CShopRateAccuracy,
                                                            CShopID,
                                                            CIsGoldShop,
                                                            CShopUri,
                                                            CShopRating,
                                                            CShopTotalProduct,
                                                            CShopImage,
                                                            CShopLocation,
                                                            CShopName,
                                                            CShopRateSpeed,
                                                            CShopTotalAddress,
                                                            CShopIsOwner,
                                                            CShopRatingDesc,
                                                            CShopRateService,
                                                            CShopDomain]];
        
        RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
        [shopReputationMapping addAttributeMappingsFromDictionary:@{CToolTip:CToolTip,
                                                                    @"reputation_score":CShopReputationScore}];
        
        RKObjectMapping *shopBadgeLeveMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
        [shopBadgeLeveMapping addAttributeMappingsFromArray:@[CLevel, CSet]];

        
        RKObjectMapping *productDetailMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
        [productDetailMapping addAttributeMappingsFromArray:@[CProductPrice, CProductID, CProductCondition, CProductName, CProductPriceFmt, CProductUri]];
        
        
        
        
        //relation
        [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CShopBadgeLevel withMapping:shopBadgeLeveMapping]];
        [catalogShopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopReputation toKeyPath:CShopReputation withMapping:shopReputationMapping]];
        
        
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *priceRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CPriceAlertDetail toKeyPath:CPriceAlertDetail withMapping:priceAlertMapping];
        [resultMapping addPropertyMapping:priceRel];
        
        RKRelationshipMapping *pagingRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pagingRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:catalogShopMapping];
        [resultMapping addPropertyMapping:listRel];
        
        RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CProductList toKeyPath:CProductList withMapping:productDetailMapping];
        [catalogShopMapping addPropertyMapping:productRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if (tag == CTagGetProductDetail) {
        objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
        [productMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
        RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
        [infoMapping addAttributeMappingsFromDictionary:@{CProductName:CProductName,
                                                          API_PRODUCT_WEIGHT_UNIT_KEY:API_PRODUCT_WEIGHT_UNIT_KEY,
                                                          API_PRODUCT_WEIGHT_KEY:API_PRODUCT_WEIGHT_KEY,
                                                          API_PRODUCT_DESCRIPTION_KEY:API_PRODUCT_DESCRIPTION_KEY,
                                                          API_PRODUCT_PRICE_KEY:API_PRODUCT_PRICE_KEY,
                                                          API_PRODUCT_INSURANCE_KEY:API_PRODUCT_INSURANCE_KEY,
                                                          API_PRODUCT_CONDITION_KEY:API_PRODUCT_CONDITION_KEY,
                                                          API_PRODUCT_ETALASE_ID_KEY:API_PRODUCT_ETALASE_ID_KEY,
                                                          KTKPDPRODUCT_RETURNABLE:KTKPDPRODUCT_RETURNABLE,
                                                          API_PRODUCT_ETALASE_KEY:API_PRODUCT_ETALASE_KEY,
                                                          API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTURLKEY:kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                          kTKPDPRODUCT_ALREADY_WISHLIST:kTKPDPRODUCT_ALREADY_WISHLIST
                                                          }];
        
        RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
        [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY
                                                               
                                                               }];
        
        RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
        [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                              kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPHASTERMKEY:kTKPDDETAILPRODUCT_APISHOPHASTERMKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                              API_IS_GOLD_SHOP_KEY:API_IS_GOLD_SHOP_KEY,
                                                              kTKPDDETAILPRODUCT_APISHOPSTATUSKEY:kTKPDDETAILPRODUCT_APISHOPSTATUSKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL:kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON:kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE:kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE,
                                                              kTKPDDETAILPRODUCT_APISHOPURLKEY:kTKPDDETAILPRODUCT_APISHOPURLKEY
                                                              }];
        
        RKObjectMapping *productRatingMapping = [RKObjectMapping mappingForClass:[Rating class]];
        [productRatingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APIQUALITYRATE:kTKPDDETAILPRODUCT_APIQUALITYRATE,
                                                                   kTKPDDETAILPRODUCT_APIQUALITYSTAR:kTKPDDETAILPRODUCT_APIQUALITYSTAR,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYRATE:kTKPDDETAILPRODUCT_APIACCURACYRATE,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYSTAR:kTKPDDETAILPRODUCT_APIACCURACYSTAR
                                                                   }];
        
        
        RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
        [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                               }];
        
        RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
        [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
        
        RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
        [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
        
        RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
        [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,CProductName,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
        
        RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
        [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
        
        // Relationship Mapping
        [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY toKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY withMapping:productRatingMapping]];
        
        [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
        
        RKRelationshipMapping *breadcrumbRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY toKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY withMapping:breadcrumbMapping];
        [resultMapping addPropertyMapping:breadcrumbRel];
        RKRelationshipMapping *otherproductRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherproductMapping];
        [resultMapping addPropertyMapping:otherproductRel];
        RKRelationshipMapping *productimageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY withMapping:imagesMapping];
        [resultMapping addPropertyMapping:productimageRel];
        RKRelationshipMapping *wholesaleRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY toKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY withMapping:wholesaleMapping];
        [resultMapping addPropertyMapping:wholesaleRel];
        
        // Response Descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptor];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if (tag == CTagGetDetailPriceList) {
        PriceAlert *priceAlert = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return priceAlert.status;
    }
    else if (tag == CTagGetProductDetail) {
        Product *product = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return product.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    objectManager = nil;
    if (tag == CTagGetDetailPriceList) {
        PriceAlert *priceAlert = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if (page == 1) {
            catalogList = [NSMutableArray arrayWithArray:priceAlert.result.list];
            [tblDetailPriceAlert scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
        else {
            [catalogList addObjectsFromArray:priceAlert.result.list];
        }
        [self isGettingCatalogList:NO];
        
        if (catalogList==nil || catalogList.count==0) {
            [tblDetailPriceAlert addSubview:[self getNoResultView]];
        }
        else if (noResultView != nil) {
            [noResultView.view removeFromSuperview];
            noResultView = nil;
        }
        
        if (tblDetailPriceAlert.delegate == nil) {
            tblDetailPriceAlert.delegate = self;
            tblDetailPriceAlert.dataSource = self;
        }
        
        
        if (! [priceAlert.result.paging.uri_next isEqualToString:@"0"]) {
            NSURL *url = [NSURL URLWithString:priceAlert.result.paging.uri_next];
            NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
            NSMutableDictionary *queries = [NSMutableDictionary new];
            for (NSString *keyValuePair in querry) {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [pairComponents objectAtIndex:0];
                NSString *value = [pairComponents objectAtIndex:1];
                
                [queries setObject:value forKey:key];
            }
            
            page = [[queries objectForKey:@"page"] intValue];
        }
        else {
            page = 1;
        }

        
        [tblDetailPriceAlert reloadData];
    }
    else if (tag == CTagGetProductDetail) {
        strTempProductID = nil;
        Product *product = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        [self showActivityIndicatorGetProductDetail:NO];
        
        
        if ([self canRedirectView]) {
            [self continueProcessBuy:product.result];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

- (void)actionBeforeRequest:(int)tag {

}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    objectManager = nil;
    if (tag == CTagGetDetailPriceList) {
        [self isGettingCatalogList:NO];
        [self showRetryLoadCatalog:YES withTag:tag];
    }
    else if (tag == CTagGetProductDetail) {
        strTempProductID = nil;
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedBuyProduct, CStringNoInternet] delegate:self];
        [stickyAlertView show];
        [self showActivityIndicatorGetProductDetail:NO];
    }
}



#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController {
    
}

- (void)cancelLoginView {

}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    switch (loadingView.tag) {
        case CTagGetDetailPriceList:
            [self isGettingCatalogList:YES];
//            [[self getNetworkManager:CTagGetDetailPriceList] doRequest];
            [self getPriceAlertDetail];
            break;
        default:
            break;
    }
}


#pragma mark - Department Delegate
- (void)didFinishSelectedAtRow:(int)row {
    if (departmentViewController.tag == CTagFilter) {
        nSelectedFilter = row;
    }
    else if (departmentViewController.tag == CTagSort) {
        nSelectedSort = row;
    }

    page = 1;
//    [[self getNetworkManager:CTagGetDetailPriceList] doRequest];
    [self getPriceAlertDetail];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:^{
        departmentViewController = nil;
    }];
}


#pragma mark - CMPopTipView Delegate
- (void)dismissAllPopTipViews {
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [self dismissAllPopTipViews];
}

#pragma mark - Replace Selected Data
- (void)replaceDataSelected:(NSDictionary*)data {
    _detailPriceAlert = [data objectForKey:@"price_alert"];
    _imageHeader = [data objectForKey:@"image_header"];
    [catalogList removeAllObjects];
    [tblDetailPriceAlert reloadData];
    page = 1;
    [self setHeader];
    
}

@end
