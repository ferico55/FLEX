//
//  TransactionCartViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "string_transaction.h"
#import "NoResult.h"
#import "NavigateViewController.h"

#import "TransactionCartViewController.h"
#import "TransactionCartHeaderView.h"
#import "TransactionCartCostView.h"
#import "TransactionCartEditViewController.h"
#import "TransactionCartShippingViewController.h"
#import "AlertPickerView.h"
#import "TransactionCartWebViewViewController.h"
#import "AlertInfoView.h"
#import "StickyAlertView.h"
#import "GeneralTableViewController.h"

#import "CartCell.h"
#import "CartValidation.h"

#import "RequestCart.h"
#import "TAGDataLayer.h"

#import "TagManagerHandler.h"

#import "LoadingView.h"

#import "GeneralTableViewController.h"

#import "NoResultReusableView.h"
#import "NSNumberFormatter+IDRFormater.h"

#import "CustomNotificationView.h"

#import "NSStringCategory.h"

#import "Tokopedia-Swift.h"

#import "UITableView+FDTemplateLayoutCell.h"

#define DurationInstallmentFormat @"%@ bulan (%@)"
@import SwiftOverlays;
@import NSAttributedString_DDHTML;

@interface TransactionCartViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITextFieldDelegate,
TransactionCartCellDelegate,
TransactionCartHeaderViewDelegate,
GeneralSwitchCellDelegate,
GeneralTableViewControllerDelegate,
TKPDAlertViewDelegate,
TransactionCartShippingViewControllerDelegate,
TransactionCartEditViewControllerDelegate,
TransactionCartWebViewViewControllerDelegate,
LoadingViewDelegate,
GeneralTableViewControllerDelegate,
NoResultDelegate,
InputPromoViewDelegate
>
{
    NSMutableArray<TransactionCartList *> *_list;
    
    TransactionCartResult *_cart;
    
    NSMutableDictionary *_dataInput;
    
    UITextField *_activeTextField;
    
    UIRefreshControl *_refreshControl;
    UIRefreshControl *_refreshControlNoResult;
    
    BOOL _isLoadingRequest;
    
    BOOL _popFromToppay;
    
    UIAlertView *_alertLoading;
    
    LoadingView *_loadingView;
    TAGContainer *_gtmContainer;
    
    BOOL _isSaldoError;
    BOOL _isDropshipperError;
    BOOL _shouldDisplayButtonOnErrorAlert;
    BOOL _hasDisplayedPaymentError;
    
    TransactionVoucherData *_voucherData;
    
    TopAdsService *_topAdsService;
    UIScrollView *_noResultScrollView;
    TopAdsView *_topAdsView;
    NoResultReusableView *_noResultView;
    NoResultReusableView *_noInternetConnectionView;
    NoResultReusableView *_noLoginView;
    
    NSMutableArray *_errorMessages;
    NotificationBarButton *_barButton;
    
    NSString *_editedCartId;
    
    UIView *_lineView;
    UIView *lastNotificationView;
    
    PromoType _promoType;
    
    UserAuthentificationManager *_userManager;
    
    CartRequest *_request;
    UIView *tickerView;
    UILabel *couponLabel;
    UIView *containerView;
    UIButton *buttonClose;
}

@property (strong, nonatomic) IBOutlet UIView *checkoutView;

@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLabel;
- (IBAction)insuranceButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITableViewCell *usedLPCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *LPCashbackCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *donasiCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *promoCell;
@property (strong, nonatomic) IBOutlet UILabel *promoLabel;
@property (strong, nonatomic) IBOutlet UILabel *promoCTALabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *usedVoucherCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucherCell;
@property (weak, nonatomic) IBOutlet UILabel *lblUsedVoucherCode;
@property (weak, nonatomic) IBOutlet UILabel *lblUsedVoucherMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelUseVoucher;
@property (weak, nonatomic) IBOutlet UIButton *btnUseVoucher;

- (IBAction)tap:(id)sender;
@end

#define TAG_ALERT_PARTIAL 13
#define DATA_PARTIAL_SECTION @"data_partial"
#define DATA_CART_GRAND_TOTAL @"cart_grand_total"
#define DATA_CART_GRAND_TOTAL_W_LP @"cart_grand_total_w_lp"
#define DATA_CART_GRAND_TOTAL_WO_LP @"cart_grand_total_wo_lp"
#define DATA_UPDATED_GRAND_TOTAL @"data_grand_total"
#define DATA_VOUCHER_AMOUNT @"data_voucher_amount"
#define DATA_CART_USED_VOUCHER_AMOUNT @"data_used_voucher_amount"
#define DATA_DETAIL_CART_FOR_SHIPMENT @"data_detail_cart_fort_shipment"

#define HEIGHT_VIEW_SUBTOTAL 156
#define HEIGHT_VIEW_TOTAL_DEPOSIT 30
#define DEFAULT_ROW_HEIGHT 44
#define CELL_PRODUCT_ROW_HEIGHT 150

#define NOT_SELECT_GATEWAY -1

@implementation TransactionCartViewController
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _topAdsService = [TopAdsService new];
    _request = [CartRequest new];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    [self initNotification];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControlNoResult = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    _refreshControlNoResult.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequestCart)forControlEvents:UIControlEventValueChanged];
    [_refreshControlNoResult addTarget:self action:@selector(refreshRequestCart)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];

    [self initAllNoResult];
    [self setupTickerAndNoResultView];
    [self refreshRequestCart];
    
    [AnalyticsManager trackScreenName:@"Shopping Cart"];
    _tableView.accessibilityLabel = @"cartTableView";
    _noResultScrollView.accessibilityLabel = @"noResultView";
    _noLoginView.accessibilityLabel = @"noLoginView";
    
    _barButton = [[NotificationBarButton alloc] initWithParentViewController:self];
    
    _userManager = [UserAuthentificationManager new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_popFromToppay) {
        _popFromToppay = NO;
        [self refreshRequestCart];
    }
    if (_list.count>0) {
        _tableView.tableFooterView =_checkoutView;
    } else _tableView.tableFooterView = nil;
    
    [self initNotificationManager];
    [self autofillVoucherCode];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    @try {
        [self setupTopAdsViewContraints];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _activeTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertErrorMessage:)
                                                 name:@"AddErrorMessage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequestCart)
                                                 name:@"doRefreshingCart" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLogin)
                                                 name:TKPDUserDidLoginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLogout)
                                                 name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRequestCart)
                                                 name:SHOULD_REFRESH_CART
                                               object:nil];
}

-(void) requestPromo{
    
    TopAdsFilter *filter = [TopAdsFilter new];
    filter.type = TopAdsFilterTypeRecommendationCategory;
    filter.source = TopAdsSourceEmptyCart;
    filter.numberOfProductItems = 4;
    
    __weak typeof(self) weakSelf = self;
    [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> * result) {
        [_topAdsView setPromoWithAds:result];
        [weakSelf setupTopAdsViewContraints];
    } onFailure:^(NSError * error) {
        
    }];
}
- (void)autofillVoucherCode {
    NSString* voucherCode = [[NSUserDefaults standardUserDefaults] valueForKey:API_VOUCHER_CODE_KEY];
    if (voucherCode && _voucherData == nil && _list.count > 0) {
        [_dataInput setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
        [self doRequestVoucher];
    }
}
#pragma mark - Notification Manager

- (void)initNotificationManager {
    if ([_userManager isLogin]) {
        self.navigationItem.rightBarButtonItem = _barButton;
        [_barButton reloadNotifications];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)initAllNoResult{
    _noResultScrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultScrollView.userInteractionEnabled = true;
    
    _topAdsView = [TopAdsView new];
    
    couponLabel = [UILabel new];
    couponLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    couponLabel.textColor = [UIColor tpSecondaryBlackText];
    couponLabel.lineBreakMode = NSLineBreakByWordWrapping;
    couponLabel.numberOfLines = 0;
    
    buttonClose = [UIButton new];
    [buttonClose setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    
    tickerView = [UIView new];
    tickerView.backgroundColor = [UIColor fromHexString:@"f8f8f8"];
    tickerView.borderColor = UIColor.tpBorder;
    tickerView.borderWidth = 1;
    tickerView.cornerRadius = 3;
    
    containerView = [UIView new];
    
    
    [self initNoResultView];
    [self initNoInternetConnectionView];
    [self initNoLoginView];
    
    [_noResultScrollView addSubview:_refreshControlNoResult];
    [_noResultScrollView addSubview:containerView];
    
    [tickerView addSubview:couponLabel];
    [tickerView addSubview:buttonClose];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 350)];
    _noResultView.delegate = self;
    _noResultView.button.tag = 1;
    [_noResultView generateAllElements:@"Keranjang.png"
                                 title:@"Keranjang belanja Anda kosong"
                                  desc:@"Pilih dan beli produk yang anda inginkan,\nayo mulai belanja!"
                              btnTitle:@"Ayo mulai belanja!"];
}

- (void)initNoInternetConnectionView {
    _noInternetConnectionView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _noInternetConnectionView.delegate = self;
    _noInternetConnectionView.button.tag = 2;
}

- (void)initNoLoginView {
    __weak typeof(self) weakSelf = self;
    
    _noLoginView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 350)];
    _noLoginView.delegate = self;
    [_noLoginView generateAllElements:@"icon_no_data_grey.png"
                                    title:@"Anda belum login"
                                     desc:@"Belum punya akun Tokopedia?"
                                 btnTitle:@"Daftar di sini!"];
    _noLoginView.button.backgroundColor = [UIColor tpGreen];
    _noLoginView.onButtonTap = ^(NoResultReusableView *noResultView) {
        
        RegisterBaseViewController *controller = [RegisterBaseViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        controller.onLoginSuccess = ^(LoginResult *result){
            [weakSelf.tabBarController setSelectedIndex:3];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR object:nil userInfo:nil];
        };
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
}

- (void) setupTopAdsViewContraints {
    [_topAdsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UserAuthentificationManager *manager = [UserAuthentificationManager new];
        if (manager.isLogin) {
            make.top.equalTo(_noResultView.mas_bottom).offset(30);
        } else {
            make.top.equalTo(_noLoginView.mas_bottom).offset(30);
        }
        if (IS_IPAD) {
            make.width.equalTo([NSNumber numberWithFloat:UIScreen.mainScreen.bounds.size.width - 208]);
            make.left.equalTo(containerView.mas_left).offset(104);
            make.right.equalTo(containerView.mas_right).offset(-104);
        } else {
            make.width.equalTo([NSNumber numberWithFloat:UIScreen.mainScreen.bounds.size.width]);
        }
        make.height.equalTo([NSNumber numberWithFloat:_topAdsView.frame.size.height]);
        make.bottom.equalTo(containerView.mas_bottom);
    }];
    [containerView layoutIfNeeded];
}

-(void)userLogin{
    [_noResultScrollView removeFromSuperview];
    [_noLoginView removeFromSuperview];
}

-(void)userLogout{
    [_noResultScrollView removeFromSuperview];
    [_noResultView removeFromSuperview];
    [self.view addSubview:_noResultScrollView];
    [containerView addSubview:_noLoginView];
    [_noResultScrollView addSubview:containerView];
    [_noResultScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self requestPromo];
}

-(UIAlertView*)alertLoading{
    if (!_alertLoading) {
        _loadingView = [LoadingView new];
        _loadingView.delegate = self;
        _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    }
    
    return _alertLoading;
}

#pragma mark - Table View Delegate & Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count + 5;
    return (_list.count==0)?0:sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger listCount = _list.count;
    NSInteger rowCount;
    
    if (section < listCount) {
        TransactionCartList *list = _list[section];
        NSArray *products = list.cart_products;
        rowCount = products.count+6; //ErrorMessage, Detail Pengiriman, Partial, Dropshipper, dropshipper name, dropshipper phone
    }
    else if (section == listCount)
        rowCount = 1;
    else if (section == listCount+1) {
        rowCount = 2; // Kode Promo Tokopedia, LPcell
    }
    else if (section == listCount+2)
        rowCount = _cart.donation?1:0; //donation
    
    else rowCount = 1; // total pembayaran
    
    return (_list.count==0)?0:rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    
    NSInteger shopCount = _list.count;
    
    if (indexPath.section <shopCount)
        cell = [self cellListCartByShopAtIndexPath:indexPath];
    else if (indexPath.section == shopCount)
        cell =  [self cellLoyaltyPointAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+1)
        cell = [self cellPaymentInformationAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+2){
        cell = _promoCell;
    } else if (indexPath.section == shopCount+3) {
        cell = [[TransactionCartDonationCell alloc] initWithDonation: _cart.donation];
        ((TransactionCartDonationCell*)cell).onTapCheckBox = ^(BOOL isOn) {
            _cart.donation.isSelected = isOn;
            [self adjustGrandTotal];
        };
    }
    else
    {
        cell = _totalPaymentCell;
        NSString *totalPayment;
        if ([self isUseGrandTotalWithoutLP]) {
            totalPayment = _cart.grand_total_without_lp_idr;
        } else
            totalPayment = _cart.grand_total_idr;
        [_grandTotalLabel setText:totalPayment animated:YES];
        _insuranceLabel.text = @"Dengan membayar, saya menyetujui syarat dan ketentuan asuransi.";
        NSString *text = _insuranceLabel.text;
        NSMutableAttributedString *link = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:@"syarat dan ketentuan asuransi"];
        [link addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        UIFont *font = [UIFont microTheme];
        [link addAttribute:NSFontAttributeName value:font range:range];
        [link addAttribute:NSForegroundColorAttributeName value:[UIColor tpGreen] range:range];
        _insuranceLabel.attributedText = link;
        
        for (TransactionCartList* list in _cart.list) {
            if ([list.insuranceUsedType isEqualToString:@"2"] && ![list.insurancePrice isEqualToString:@"0"]) {
                _insuranceLabel.hidden = NO;
                break;
            }
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, _tableView.frame.size.width,1)];
    if (indexPath.section != shopCount+3 && indexPath.section != shopCount+2 && indexPath.section != shopCount+1) {
        lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
        [cell.contentView addSubview:lineView];
    }
    if (indexPath.section<_list.count) {
        TransactionCartList *list = _list[indexPath.section];
        NSArray *products = list.cart_products;
        NSInteger productCount = products.count;
        if (indexPath.section <shopCount && indexPath.row <=productCount) {
            [lineView removeFromSuperview];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width,1)];
            lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
            [cell.contentView addSubview:lineView];
        }
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.clipsToBounds = YES;
    cell.contentView.clipsToBounds = YES;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_list.count>0)
    {
        return [self rowHeightPage1AtIndexPath:indexPath];
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_list.count==0) {
        return 0;
    }
    
    if (section < _list.count)
    {
        if (_list[section].errors.count > 0) {
            if (![_list[section].errors[0].name isEqualToString:@"product-not-available"]) {
                NSString *string = [NSString stringWithFormat:@"%@\n\n%@", _list[section].errors[0].title, _list[section].errors[0].desc];
                return 44 + [self getLabelHeightWithText:string];
            } else {
                return 44;
            }
        } else {
            return 44;
        }
    }
    else if (section == _list.count)
    {
        if ([_cart.cashback integerValue] == 0) {
            return 0.1f;
        }
    }
    else if (section == _list.count+3) {
        return 10;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if (_list.count==0) {
        return 0;
    }
    
    NSInteger listCount = _list.count;
    
    if (section < listCount)
        return HEIGHT_VIEW_SUBTOTAL;
    else if (section == listCount)
    {
        if ([_cart.cashback integerValue] == 0) {
            return 0.1f;
        }
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Detail Pengiriman"]) {
        [self pushShipmentCart:_list[indexPath.section]];
    }
    if ([cell.textLabel.text isEqualToString:@"Stock Tersedia Sebagian"])
    {
        AlertPickerView *picker = [AlertPickerView newview];
        picker.delegate = self;
        [_dataInput setObject:@(indexPath.section) forKey:DATA_PARTIAL_SECTION];
        picker.pickerData =ARRAY_IF_STOCK_AVAILABLE_PARTIALLY;
        picker.tag = TAG_ALERT_PARTIAL;
        [picker show];
    }
    if (indexPath.section == _list.count + 1) { // voucher
        InputPromoViewController *vc = [[InputPromoViewController alloc] initWithServiceType:PromoServiceTypeMarketplace couponEnabled:[_cart.is_coupon_active isEqualToString:@"1"] defaultTab:[_cart.default_promo_dialog_tab isEqualToString:@"voucher"] ? PromoTypeVoucher : PromoTypeCoupon];
        vc.delegate = self;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:true completion:nil];
    }
    if (indexPath.section == _list.count+2) { //promo
        [_dataInput setObject:_cart.promoSuggestion.promoCode forKey:API_VOUCHER_CODE_KEY];
        [_dataInput setObject:@(YES) forKey:@"isUsingPromoSuggestion"];
        [self doRequestVoucher];
    }
}

-(void)pushShipmentCart:(TransactionCartList*)cart {
    TransactionCartShippingViewController *shipmentViewController = [TransactionCartShippingViewController new];
    shipmentViewController.cart = cart;
    shipmentViewController.delegate = self;
    [self.navigationController pushViewController:shipmentViewController animated:YES];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 1833:
        {
            // btn cancel voucher
            [_request cancelVoucher];
            _cart.promoSuggestion.isUsingVoucher = NO;
            
            _voucherData = nil;
            [_dataInput setObject:@"" forKey:API_VOUCHER_CODE_KEY];
            [self adjustGrandTotal];
            [_tableView reloadData];
        }
            break;
        default:
            if (_hasDisplayedPaymentError) {
                [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Checkout after error"];
            } else {
                [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Checkout"]; //checkout
            }
            if([self isValidInput]) {
                [self doCheckoutWithToppay];
            }
            break;
    }
}

- (IBAction)tapChoosePayment:(id)sender {
    [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Payment Method"];
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY]?:[TransactionCartGateway new];
    
    NSMutableArray *gatewayListWithoutHiddenPayment= [NSMutableArray new];
    NSMutableArray *gatewayImages= [NSMutableArray new];
    
    
    for (TransactionCartGateway *gateway in _cart.gateway_list) {
        [gatewayListWithoutHiddenPayment addObject:gateway.gateway_name?:@""];
        [gatewayImages addObject:gateway.gateway_image?:@""];
    }
    
    GeneralTableViewController *vc = [GeneralTableViewController new];
    vc.tableViewCellStyle = UITableViewCellStyleDefault;
    vc.selectedObject = selectedGateway.gateway_name;
    vc.objectImages = [gatewayImages copy];
    vc.objects = [gatewayListWithoutHiddenPayment copy];
    vc.delegate = self;
    vc.title = @"Metode Pembayaran";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GTM
-(TAGContainer *)gtmContainer
{
    if (!_gtmContainer) {
        TagManagerHandler *handler = [TagManagerHandler new];
        _gtmContainer = [TagManagerHandler getContainer];
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        [handler pushDataLayer:@{@"user_id" : [_userManager getUserId]}];
    }
    return _gtmContainer;
}

#pragma mark - Delegate
-(void)TransactionCartShipping:(TransactionCartList *)cart {
    BOOL isPreorder = (cart.cart_products[0].product_preorder.process_day > 0);
    NSString *preorderStatus = isPreorder?@"preorder":@"regular";
    NSString *productId = isPreorder?cart.cart_products[0].product_id:@"0";
    _editedCartId = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@", cart.cart_shop.shop_id,cart.cart_destination.address_id,cart.cart_shipments.shipment_id, cart.cart_shipments.shipment_package_id, preorderStatus, productId];
    [self isLoading:YES];
    [self requestCartData];
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo {
    [_dataInput addEntriesFromDictionary:userInfo];
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    [self doRequestEditProduct:product];
}
#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    if ([product.product_error_msg isEqualToString:@""] ||
        [product.product_error_msg isEqualToString:@"0"] ||
        product.product_error_msg == nil) {
        [NavigateViewController navigateToProductFromViewController:self
                                                      withProductID:product.product_id
                                                            andName:product.product_name
                                                           andPrice:product.product_price
                                                        andImageURL:product.product_picture
                                                        andShopName:list.cart_shop.shop_name];
    }
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    if (product.isProductClickable) {
        [NavigateViewController navigateToProductFromViewController:self
                                                      withProductID:product.product_id
                                                            andName:product.product_name
                                                           andPrice:product.product_price
                                                        andImageURL:product.product_picture
                                                        andShopName:list.cart_shop.shop_name];
    }
}

#pragma mark - Methods

-(void)setData:(NSDictionary *)data
{
    _data = data;
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    _errorMessages = [NSMutableArray new];
    _shouldDisplayButtonOnErrorAlert = NO;
    
    NSInteger firstErrorCartIndex = -1;
    
    for (NSInteger i = 0; i < _list.count; i++) {
        if ([_list[i].cart_is_dropshipper integerValue] == 1) {
            if ([_list[i].cart_dropship_name isEqualToString:@""] || _list[i].cart_dropship_name==nil) {
                if (firstErrorCartIndex == -1) {
                    firstErrorCartIndex = i;
                }
                isValid = NO;
                _list[i].isDropshipperNameError = YES;
                if (![_errorMessages containsObject:ERRORMESSAGE_SENDER_NAME_NILL])
                    [_errorMessages addObject:ERRORMESSAGE_SENDER_NAME_NILL];
            } else {
                _list[i].isDropshipperNameError = NO;
            }
            if ([_list[i].cart_dropship_phone isEqualToString:@""] || _list[i].cart_dropship_phone==nil) {
                if (firstErrorCartIndex == -1) {
                    firstErrorCartIndex = i;
                }
                isValid = NO;
                _list[i].isDropshipperPhoneError = YES;
                if (![_errorMessages containsObject:ERRORMESSAGE_SENDER_PHONE_NILL])
                    [_errorMessages addObject:ERRORMESSAGE_SENDER_PHONE_NILL];
            } else if (_list[i].cart_dropship_phone.length < 6) {
                if (firstErrorCartIndex == -1) {
                    firstErrorCartIndex = i;
                }
                isValid = NO;
                _list[i].isDropshipperPhoneError = YES;
                if (![_errorMessages containsObject:@"Nomor telepon terlalu pendek, minimum 6 karakter."])
                    [_errorMessages addObject:@"Nomor telepon terlalu pendek, minimum 6 karakter."];
            } else {
                _list[i].isDropshipperPhoneError = NO;
            }
        }
    }
    
    if (firstErrorCartIndex != -1) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:firstErrorCartIndex] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    
    
    NSLog(@"%d",isValid);
    if (!isValid && _errorMessages.count > 0) {
        if(lastNotificationView) {
            [lastNotificationView setHidden:YES];
            lastNotificationView = nil;
            [NSObject cancelPreviousPerformRequestsWithTarget:SwiftOverlays.class];
        }
        lastNotificationView = [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:[_errorMessages copy]]
                                                                        type:NotificationTypeError
                                                                    duration:4.0
                                                                 buttonTitle:_shouldDisplayButtonOnErrorAlert?@"Belanja Lagi":nil
                                                                 dismissable:YES
                                                                      action:_shouldDisplayButtonOnErrorAlert?^{
                                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
                                                                      }:nil];
    }
    
    return isValid;
}

-(void)adjustDropshipperListParam;
{
    NSInteger listCount = _list.count;
    NSMutableDictionary *dropshipListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =[list.cart_destination.address_id integerValue];
        NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *dropshipperNameKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_NAME_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        NSString *dropshipperPhoneKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_PHONE_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        if (_list.count >i) {
            [dropshipListParam setObject:_list[i].cart_dropship_name?:@"" forKey:dropshipperNameKey];
            [dropshipListParam setObject:_list[i].cart_dropship_phone?:@"" forKey:dropshipperPhoneKey];
        } else{
            [dropshipListParam setObject:@"" forKey:dropshipperNameKey];
            [dropshipListParam setObject:@"" forKey:dropshipperPhoneKey];
        }
        
        if (_list.count>0)
        {
            if ([_list[i].cart_is_dropshipper boolValue]==YES) {
                NSString *dropshipStringObject = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
                _list[i].cart_dropship_param = dropshipStringObject;
            }
            else
            {
                _list[i].cart_dropship_param = @"";
            }
        }
    }
    [_dataInput setObject:dropshipListParam forKey:DATA_DROPSHIPPER_LIST_KEY];
    [self adjustPartialListParam];
}

-(void)adjustPartialListParam;
{
    NSInteger listCount = _list.count;
    NSMutableDictionary *partialListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =[list.cart_destination.address_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *partialDetailKey = [NSString stringWithFormat:FORMAT_CART_CANCEL_PARTIAL_KEY,shopID,addressID, shipmentPackageID];
        
        if([_list[i].cart_is_partial boolValue])
            _list[i].cart_partial_param = [NSString stringWithFormat:@"%zd~%zd~%zd",shopID,addressID, shipmentPackageID];
        else {
            _list[i].cart_partial_param = @"";
        }
        
        [partialListParam setObject:_list[i].cart_is_partial?:@"0" forKey:partialDetailKey];
    }
    [_dataInput setObject:partialListParam forKey:DATA_PARTIAL_LIST_KEY];
}

- (CGFloat)getLabelHeightWithText:(NSString*)text {
    NSInteger labelWidth = 253;
    CGSize maximumLabelSize = CGSizeMake(labelWidth,9999);
    NSStringDrawingContext *context = [NSStringDrawingContext new];
    CGSize expectedLabelSize = [text boundingRectWithSize:maximumLabelSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[UIFont title1Theme]}
                                                  context:context].size;
    
    return expectedLabelSize.height;
}

- (void)insertErrorMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    [_errorMessages addObject:[userInfo objectForKey:@"errorMessage"]];
    _shouldDisplayButtonOnErrorAlert = ![[userInfo objectForKey:@"buttonTitle"] isEqualToString:@""];
}

#pragma mark - Custom Error Message View Delegate
- (void)didTapCloseButton {
    [self removeAllOverlays];
}

- (void)didTapActionButton {
    
}

#pragma mark - Cell Delegate
-(void)tapMoreButtonActionAtIndexPath:(NSIndexPath*)indexPath
{
    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
}

-(void)GeneralSwitchCell:(GeneralSwitchCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    if (cell.settingSwitch.isOn) {
        [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Dropshipper"];
    }
    _list[indexPath.section].cart_is_dropshipper = [NSString stringWithFormat:@"%zd",cell.settingSwitch.on];
    [_tableView reloadData];
}

#pragma mark - Header View Delegate
-(void)deleteTransactionCartHeaderView:(TransactionCartHeaderView *)view atSection:(NSInteger)section
{
    if (!_isLoadingRequest) {
        TransactionCartList *list = _list[section];
        
        NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART,list.cart_shop.shop_name, list.cart_total_amount_idr];
        UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
        cancelCartAlert.tag = 11;
        [cancelCartAlert show];
        
        [_dataInput setObject:[NSIndexPath indexPathForRow:0 inSection:section] forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    }
}

-(void)didTapShopAtSection:(NSInteger)section
{
    TransactionCartList *list = _list[section];
    [NavigateViewController navigateToShopFromViewController:self withShopID:list.cart_shop.shop_id];
}

-(void)addData:(NSDictionary *)dataInput
{
    [_dataInput addEntriesFromDictionary:dataInput];
}

#pragma mark - Actionsheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    TransactionCartList *list = _list[indexPathCancelProduct.section];
    NSArray *products = list.cart_products;
    ProductDetail *product = products[indexPathCancelProduct.row];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART_PRODUCT,list.cart_shop.shop_name, product.product_name, product.product_total_price_idr];
        UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
        cancelCartAlert.tag = 10;
        [cancelCartAlert show];
    } else {
        TransactionCartEditViewController *editViewController = [TransactionCartEditViewController new];
        [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
        editViewController.data = _dataInput;
        editViewController.delegate = self;
        [self.navigationController pushViewController:editViewController animated:YES];
        [_dataInput setObject:list forKey:@"cartInfo"];
    }
}

#pragma mark - UIAlertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TYPE_CANCEL_CART_PRODUCT:
            switch (buttonIndex) {
                case 1:
                {
                    [_dataInput setObject:@(TYPE_CANCEL_CART_PRODUCT) forKey:DATA_CANCEL_TYPE_KEY];
                    [self doCancelCart];
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case TYPE_CANCEL_CART_SHOP:
            switch (buttonIndex) {
                case 1:
                {
                    [_dataInput setObject:@(TYPE_CANCEL_CART_SHOP) forKey:DATA_CANCEL_TYPE_KEY];
                    [self doCancelCart];
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case TAG_ALERT_PARTIAL:
        {
            NSInteger partialSection = [[_dataInput objectForKey:DATA_PARTIAL_SECTION] integerValue];
            NSInteger index = [[((AlertPickerView*)alertView).data objectForKey:DATA_INDEX_KEY] integerValue];
            TransactionCartList *list = _list[partialSection];
            NSInteger shopID = [list.cart_shop.shop_id integerValue];
            NSInteger addressID =[list.cart_destination.address_id integerValue];
            NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
            
            if (index == 0){
                _list[partialSection].cart_is_partial = @"0";
                _list[partialSection].cart_partial_param = @"";
            }
            else
            {
                NSString *partialStringObject = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_KEY,shopID,addressID,shipmentPackageID];
                _list[partialSection].cart_is_partial = @"1";
                _list[partialSection].cart_partial_param = partialStringObject;
            }
            
            [self adjustPartialListParam];
            [_tableView reloadData];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activeTextField = textField;
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag > 0 )
    {
        _list[textField.tag-1].cart_dropship_name = textField.text;
    }
    else if (textField.tag < 0)
    {
        _list[-textField.tag-1].cart_dropship_phone = textField.text;
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // should be phone numbers text field
    if (textField.tag < 0) {
        if ([[NSNumberFormatter new] numberFromString:string] == nil && ![string isEqualToString:@""]) {
            return NO;
        }
        
        NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return [newString isNumber];
    }
    
    return YES;
}

-(BOOL)isUseGrandTotalWithoutLP
{
    BOOL isNotUsingLP = NO;
    
    NSString *isAvailableInstallment = [[self gtmContainer]stringForKey:GTMIsLuckyInstallmentAvailableKey];
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    
    if ([selectedGateway.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT && [isAvailableInstallment integerValue] == 0) {
        isNotUsingLP = YES;
    }
    
    if ([_voucherData.voucher_no_other_promotion integerValue] == 1) {
        isNotUsingLP = YES;
    }
    
    return isNotUsingLP;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Webview Payment Delegate
-(void)isLoading:(BOOL)isLoading{
    _isLoadingRequest = isLoading;
    _checkoutButton.enabled = !isLoading;
    if (isLoading) {
        [[self alertLoading] show];
    } else{
        if (_refreshControl.isRefreshing || _refreshControlNoResult.isRefreshing) {
            [_refreshControl endRefreshing];
            [_refreshControlNoResult endRefreshing];
        }
        if (_list.count>0) {
            _tableView.tableFooterView = _checkoutView;
        } else _tableView.tableFooterView = nil;
        [[self alertLoading] dismissWithClickedButtonIndex:0 animated:NO];
        [_tableView setContentOffset:CGPointZero];
        [_noResultScrollView setContentOffset:CGPointZero];
    }
}

-(void)shouldDoRequestTopPayThxCode:(NSString *)code toppayParam:(NSDictionary *)param
{
    [self isLoading:NO];
    [self requestThanksPayment:param paymentID:code];
}

#pragma mark - Methods


-(NSInteger)depositAmountUser
{
    NSInteger depositAmountUser = [[[NSNumberFormatter IDRFormatter] numberFromString:_cart.deposit_idr] integerValue];
    return depositAmountUser;
}

-(void)refreshRequestCart
{
    [self doClearAllData];
    [_refreshControl beginRefreshing];
    [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:NO];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [_noInternetConnectionView removeFromSuperview];
    [self isLoading:NO];
    if (auth.isLogin) {
        [self userLogin];
        [self requestCartData];
    } else {
        [self userLogout];
    }
}

-(void)doClearAllData
{
    [_dataInput removeAllObjects];
    [_list removeAllObjects];
    
    _voucherData = nil;
    _tableView.tableFooterView = nil;
    
    [_tableView reloadData];
}

-(void)adjustGrandTotal {
    NSInteger grandTotalCartFromWS = ([self isUseGrandTotalWithoutLP])?[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_WO_LP] integerValue]:[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
    
    [_dataInput setObject:@(grandTotalCartFromWS) forKey:DATA_UPDATED_GRAND_TOTAL];
    
    NSInteger voucherAmount = [_voucherData.voucher_amount integerValue];
    
    grandTotalCartFromWS -= voucherAmount;
    if (grandTotalCartFromWS <0) {
        grandTotalCartFromWS = 0;
    }
    
    grandTotalCartFromWS += [_cart.donation.usedDonationValue integerValue];
    
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalCartFromWS]];
    
    _cart.grand_total_idr = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:grandTotalCartFromWS]];
    
    _cart.grand_total_without_lp = _cart.grand_total;
    _cart.grand_total_without_lp_idr = _cart.grand_total_idr;
    
    [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_UPDATED_GRAND_TOTAL];
    [_tableView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    
}

#pragma mark - Footer View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section < _list.count)
    {
        TransactionCartHeaderView *headerView = [TransactionCartHeaderView newview];
        [headerView setViewModel:_list[section].viewModel page:0 section:section delegate:self];
        return headerView;
    }
    else
    {
        return nil;
    }
}

-(NSInteger)LPAmount
{
    NSInteger LPAmount = [_cart.lp_amount integerValue];
    return LPAmount;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self FirstPageCartfooterViewAtSection:section];
}

-(UIView *)FirstPageCartfooterViewAtSection:(NSInteger)section
{
    if (section < _list.count)
    {
        return [self CartSubTotalViewAtSection:section];
    }
    return nil;
}

-(UIView*)CartSubTotalViewAtSection:(NSInteger)section
{
    TransactionCartCostView *view = [TransactionCartCostView newview];
    [view setViewModel:_list[section].viewModel];
    return view;
}

#pragma mark - Table View Cell

-(UITableViewCell *)cellListCartByShopAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    
    TransactionCartList *list = _list[indexPath.section];
    NSArray *products = list.cart_products;
    NSInteger productCount = products.count;
    
    if (indexPath.row == 0) {
        cell = [CartCell cellErrorList:[_list copy] tableView:_tableView atIndexPath:indexPath];
    }
    else if (indexPath.row <= productCount)
    {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        cell = [CartCell cellCart:[_list copy] tableView:_tableView atIndexPath:newIndexPath page:0];
    }
    else
    {
        //otherCell
        if (indexPath.row == productCount+1) {
            cell = [CartCell cellDetailShipmentTable:_tableView indexPath:indexPath];
        } else if (indexPath.row == productCount+2) {
            cell = [CartCell cellIsPartial:_list[indexPath.section].cart_is_partial tableView:_tableView atIndextPath:indexPath isDisabled:!list.isEditingEnabled];
        } else if (indexPath.row == productCount+3) {
            cell = [CartCell cellIsDropshipper:_list[indexPath.section].cart_is_dropshipper tableView:_tableView atIndextPath:indexPath isDisabled:!list.isEditingEnabled];
        } else if (indexPath.row == productCount+4) {
            cell = [CartCell cellTextFieldPlaceholder:@"Nama Pengirim" List:[_list copy] tableView:_tableView atIndexPath:indexPath withText:_list[indexPath.section].cart_dropship_name?:@""];
            
        } else if (indexPath.row == productCount+5) {
            cell = [CartCell cellTextFieldPlaceholder:@"Nomor Telepon" List:[_list copy] tableView:_tableView atIndexPath:indexPath withText:_list[indexPath.section].cart_dropship_phone?:@""];
        }
    }
    
    return cell;
}

-(UITableViewCell*)cellPaymentInformationAtIndexPath:(NSIndexPath*)indexPath
{
    //0 Kode Promo Tokopedia?, 1 LPCell 2 Total invoice, 3 Saldo Tokopedia Terpakai, 4 Voucher terpakai 7 Total Pembayaran
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            if (_voucherData == nil) {
                cell = _voucherCell;
            }
            else {
                cell = _usedVoucherCell;
            }
            break;
        case 1:
        {
            cell = _usedLPCell;
            NSString *LPAmountStr = [NSString stringWithFormat:@"(%@)",_cart.lp_amount_idr];
            cell.detailTextLabel.text = LPAmountStr;
        }
            break;
        default:
            break;
    }
    return cell;
}

-(UITableViewCell *)cellLoyaltyPointAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = _LPCashbackCell;
            cell.detailTextLabel.text = _cart.cashback_idr;
            break;
            
        default:
            break;
    }
    return cell;
}

-(NSString*)roundingFloatFromString:(NSString*)string
{
    string = [NSString stringWithFormat:@"%.3f",[string floatValue]];
    CGFloat weightFloat = [string floatValue];
    NSInteger weightInt = [string integerValue];
    CGFloat floatMod= fmodf(weightFloat, weightInt);
    if (floatMod == 0) {
        string = [NSString stringWithFormat:@"%zd",weightInt];
    }
    
    return string;
}

#pragma mark - Cell Height
-(CGFloat)rowHeightPage1AtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section < _list.count) {
        TransactionCartList *list = _list[indexPath.section];
        if (indexPath.row == 0) {
            return 0;
        }
        else if(indexPath.row <= list.cart_products.count) {
            ProductDetail *product = list.cart_products[indexPath.row-1];
            return [self productRowHeight:product];
        }
        else if ( indexPath.row == list.cart_products.count + 2) {
            //adjust total partial cell tidak muncul ketika jumlah barang hanya 1
            if ([list.cart_total_product integerValue]<=1 || !_cart.enable_cancel_partial.boolValue) {
                return 0;
            }
        }
        else if (indexPath.row == list.cart_products.count + 4) // Dropshipper name
        {
            if ([_list[indexPath.section].cart_is_dropshipper integerValue] == 0) {
                return 0;
            }
        }
        else if (indexPath.row == list.cart_products.count + 5) // Dropshipper phone
        {
            if ([_list[indexPath.section].cart_is_dropshipper integerValue] == 0) {
                return 0;
            }
        }
    }
    else if (indexPath.section == _list.count) {
        if ([_cart.cashback integerValue] == 0) {
            return 0;
        }
        
        return 44;
    }
    else if (indexPath.section == _list.count+1) {
        if (indexPath.row == 1) {
            if ([self isUseGrandTotalWithoutLP]) {
                return 0;
            }
            
            if ([_cart.lp_amount integerValue] <= 0) {
                return 0;
            }
            
            return 44;
        }
        else if (indexPath.row >1) {
            return 0;
        } else {
            if (_voucherData == nil) {
                return 44;
            }
            else {
                return UITableViewAutomaticDimension;
            }
        }
    } else if (indexPath.section == _list.count+2){
        return (_cart.promoSuggestion.isVisible) ? UITableViewAutomaticDimension : 0; //promo
    } else if (indexPath.section == _list.count+3){
        return 75; // donasi
    } else if (indexPath.section == _list.count+4){ //total pembayaran
        for (TransactionCartList* list in _cart.list) {
            if ([list.insuranceUsedType isEqualToString:@"2"] && ![list.insurancePrice isEqualToString:@"0"]) {
                return 96;
            }
            return 44;
        }
        return UITableViewAutomaticDimension;
    }
    
    return DEFAULT_ROW_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == _list.count+2) {
        return 40;
    } else {
        return [self rowHeightPage1AtIndexPath:indexPath];
    }
}

-(CGFloat)productRowHeight:(ProductDetail*)product
{
    NSString *productNotes = [product.product_notes stringByReplacingOccurrencesOfString:@"\n" withString:@"; "];
    NSString *string = productNotes;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(_tableView.frame.size.width,9999);
    CGRect expectedLabelFrame = [string boundingRectWithSize:maximumLabelSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont title1Theme]}
                                                     context:nil];
    CGSize expectedLabelSize = expectedLabelFrame.size;
    
    if ([productNotes isEqualToString:@""]) {
        expectedLabelSize.height = 0;
    }
    
    CGSize expectedErrorLabelSize;
    
    if (product.errors.count > 0) {
        Errors *error = product.errors[0];
        
        NSString *errorText = @"";
        if (error.desc == nil) {
            errorText = error.title;
        } else {
            errorText = [NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc];
        }
        CGSize maximumLabelSize = CGSizeMake(250,9999);
        NSStringDrawingContext *context = [NSStringDrawingContext new];
        expectedErrorLabelSize = [errorText boundingRectWithSize:maximumLabelSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:[UIFont title2Theme]}
                                                         context:context].size;
        expectedErrorLabelSize.height = expectedErrorLabelSize.height + 32;
    } else {
        expectedErrorLabelSize.height = 0;
    }
    
    return CELL_PRODUCT_ROW_HEIGHT + expectedLabelSize.height + expectedErrorLabelSize.height;
}

#pragma mark - Request

- (void)requestThanksPayment:(NSDictionary *)param paymentID:(NSString *)paymentID {
    NSArray *products = param[@"items"];
    NSMutableArray *productIDs = [NSMutableArray new];
    NSInteger quantity = 0;
    
    for (NSDictionary *product in products) {
        [productIDs addObject:product[@"id"]];
        quantity = quantity + [product[@"quantity"] integerValue];
    }
    [AnalyticsManager trackEventName:@"clickBack" category:GA_EVENT_CATEGORY_PAYMENT action:GA_EVENT_ACTION_ABANDON label:@"Thank You Page"];
    [RequestCart fetchToppayThanksCode:paymentID
                               success:^(TransactionActionResult *data) {
                                   if (data.is_success == 1) {
                                       NSDictionary *parameter = data.parameter;
                                       NSString *paymentMethod = [parameter objectForKey:@"gateway_name"]?:@"";
                                       NSNumber *revenue = [[NSNumberFormatter IDRFormatter] numberFromString:[parameter objectForKey:@"order_open_amt"]];
                                       
                                       [AnalyticsManager trackScreenName:[NSString stringWithFormat:@"Thank you page - %@", paymentMethod]];
                                       [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{AFEventParamRevenue : [revenue stringValue]?:@"",
                                                                                                                 AFEventParamContentType : @"Product",
                                                                                                                 AFEventParamContentId : [NSString jsonStringArrayFromArray:productIDs]?:@"",
                                                                                                                 AFEventParamQuantity : [@(quantity) stringValue]?:@"",
                                                                                                                 AFEventParamCurrency : param[@"currency"]?:@"",
                                                                                                                 AFEventOrderId : paymentID}];
                                       
                                       [AnalyticsManager moEngageTrackEventWithName:@"Thank_You_Page_Launched"
                                                                         attributes:@{@"payment_type" : paymentMethod ?: @"",
                                                                                      @"purchase_site" : @"Marketplace",
                                                                                      @"total_price" : revenue ?: @(0)}];
                                       
                                   }
                                   [self requestCartData];
                               } error:^(NSError *error) {
                                   [self requestCartData];
                                   
                               }];
    
    
}

-(void)requestCartData{
    
    _checkoutButton.enabled = NO;
    
    CartRequest * request = [CartRequest new];
    [request fetchCartData:^(TransactionCartResult * data) {
        [self trackCheckoutProduct:data step:@"1" optionName:@"cart page loaded" paymentID:nil];
        
        NSArray<TransactionCartList*> *list = [self setCartDataFromPreviousCarts:_cart.list toNewCarts:data.list];
        [_list removeAllObjects];
        [_list addObjectsFromArray:list];
        
        if(list.count >0){
            [_noResultScrollView removeFromSuperview];
            [self autofillVoucherCode];
        }else{
            couponLabel.text = data.autoCode.title;
            [couponLabel layoutIfNeeded];
            [self requestPromo];
            [self setupTickerAndNoResultView];
        }
        
        _cart = data;
        [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL];
        [_dataInput setObject:_cart.grand_total_without_lp?:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL_WO_LP];
        [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL_W_LP];
        _cart.promoSuggestion.isUsingVoucher = ([_dataInput objectForKey:API_VOUCHER_CODE_KEY] && ![[_dataInput objectForKey:API_VOUCHER_CODE_KEY] isEqualToString:@""]);
        
        if ([data.is_coupon_active isEqualToString:@"1"]) {
            [_btnUseVoucher setTitle:@"Gunakan Kode Promo atau Kupon" forState:UIControlStateNormal];
        }
        else {
            [_btnUseVoucher setTitle:@"Gunakan Kode Promo" forState:UIControlStateNormal];
        }
        
        [self adjustGrandTotal];
        [self isLoading:NO];
        [self initNotificationManager];
        if (_cart.autoCode != nil && _cart.autoCode.success) {
            _voucherData = [TransactionVoucherData new];
            [_voucherData setVoucher_amount:[NSString stringWithFormat:@"%f",_cart.autoCode.discountAmount]];
            [_voucherData setVoucher_id:[NSString stringWithFormat:@"%zd",_cart.autoCode.id]];
            [_voucherData setVoucher_promo_desc:_cart.autoCode.message];
            [_voucherData setVoucher_code:_cart.autoCode.code];
            [_voucherData setCoupon_title:_cart.autoCode.title];
            _promoType = _cart.autoCode.isCoupon ? PromoTypeCoupon : PromoTypeVoucher;
            [_dataInput setObject:_voucherData.voucher_code forKey:API_VOUCHER_CODE_KEY];
            [_dataInput setObject:@(NO) forKey:@"isUsingPromoSuggestion"];
            
            [self useVoucher];
        } else {
            [self setPromoSuggestion];
        }
    } onFailure:^(NSError *error) {
        [self doClearAllData];
        [_noInternetConnectionView generateRequestErrorViewWithError:error];
        [_tableView addSubview:_noInternetConnectionView];
        [self isLoading:NO];
    }];
}

-(void)setPromoSuggestion{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringFromHTML: _cart.promoSuggestion.text?:@"" normalFont:[UIFont largeTheme] boldFont:[UIFont largeThemeMedium] italicFont:[UIFont largeTheme]]];
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineSpacing = 0.5;
    [text addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, text.length)];
    _promoLabel.attributedText = text;
    _promoCTALabel.text = _cart.promoSuggestion.cta;
    _promoCTALabel.textColor = [UIColor fromHexString:_cart.promoSuggestion.ctaColor];
}

-(NSArray <TransactionCartList*> *)setCartDataFromPreviousCarts:(NSArray <TransactionCartList*> *)previousCarts toNewCarts:(NSArray <TransactionCartList*> *)newCarts{
    for (TransactionCartList *cart in previousCarts) {
        for (TransactionCartList *newCart in newCarts) {
            
            if ([newCart.cartString isEqualToString:_editedCartId]){
                NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:newCart};
                [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil userInfo:info];
            }
            
            if ([newCart.cartString isEqualToString:cart.cartString]) {
                
                newCart.cart_dropship_name = cart.cart_dropship_name?:@"";
                newCart.cart_dropship_phone = cart.cart_dropship_phone?:@"";
                newCart.cart_is_dropshipper = cart.cart_is_dropshipper?:@"";
                newCart.cart_dropship_param = cart.cart_dropship_param?:@"";
                newCart.cart_is_partial = cart.cart_is_partial?:@"0";
                newCart.cart_partial_param = cart.cart_partial_param?:@"";
                
                break;
            }
        }
    }
    
    return newCarts;
}

-(void)doCancelCart{
    [self isLoading:YES];
    NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    
    TransactionCartList *list = _list[indexPathCancelProduct.section];
    NSArray *products = list.cart_products;
    ProductDetail *product = products[indexPathCancelProduct.row];
    
    NSInteger type = [[_dataInput objectForKey:DATA_CANCEL_TYPE_KEY] integerValue];
    
    [RequestCart fetchDeleteProduct:product
                               cart:list
                           withType:type
                            success:^(TransactionAction *data, ProductDetail *product, TransactionCartList *cart, NSInteger type) {
                                
                                if (type == TYPE_CANCEL_CART_PRODUCT ) {
                                    [self trackRemoveProductFromCart:list productIndex:(int)indexPathCancelProduct.row];
                                    NSMutableArray *products = [NSMutableArray new];
                                    [products addObjectsFromArray:list.cart_products];
                                    [products removeObject:product];
                                    ([_list objectAtIndex:indexPathCancelProduct.section]).cart_products = products;
                                    if (([_list objectAtIndex:indexPathCancelProduct.section]).cart_products.count<=0) {
                                        [_list removeObject:_list[indexPathCancelProduct.section]];
                                    }
                                } else {
                                    [self trackRemoveProductFromCart:list productIndex:-1];
                                    [_list removeObject:list];
                                }
                                [_tableView reloadData];
                                [self requestCartData];
                                [self isLoading:NO];
                                [_tableView reloadData];
                            } error:^(NSError *error) {
                                [self doClearAllData];
                                [_noInternetConnectionView generateRequestErrorViewWithError:error];
                                [_tableView addSubview:_noInternetConnectionView];
                                [self isLoading:NO];
                            }];
}

-(void)doRequestVoucher{
    [self isLoading:YES];
    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY]?:@"";
    BOOL isPromoSuggestion = [[_dataInput objectForKey:@"isUsingPromoSuggestion"]  isEqual: @(YES)];
    [RequestCart fetchVoucherCode: voucherCode isPromoSuggestion: isPromoSuggestion success: ^(TransactionVoucher *voucher) {
        _voucherData = voucher.data.data_voucher;
        _voucherData.voucher_code = [_dataInput objectForKey:API_VOUCHER_CODE_KEY];
        _promoType = PromoTypeVoucher;
        
        [self isLoading:NO];
        [self useVoucher];
    } error:^(NSError *error) {
        [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
        [self isLoading:NO];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:API_VOUCHER_CODE_KEY] && error == nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:API_VOUCHER_CODE_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)useVoucher {
    _cart.promoSuggestion.isUsingVoucher = YES;
    
    NSString *usedCouponString = @"";
    int startVoucher = 0;
    switch (_promoType) {
        case PromoTypeCoupon:
            usedCouponString = [NSString stringWithFormat:@"Kupon Saya: %@", _voucherData.coupon_title];
            startVoucher = 12;
            break;
        case PromoTypeVoucher:
            usedCouponString = [NSString stringWithFormat:@"Kode Voucher: %@", _voucherData.voucher_code];
            startVoucher = 13;
            break;
    }
    NSMutableAttributedString *voucherCodeText = [[NSMutableAttributedString alloc] initWithString:usedCouponString attributes:@{NSFontAttributeName: _lblUsedVoucherCode.font}];
    [voucherCodeText addAttribute:NSForegroundColorAttributeName value:[UIColor fromHexString:@"#FD5830"] range:NSMakeRange(startVoucher, voucherCodeText.length - startVoucher)];
    _lblUsedVoucherCode.attributedText = voucherCodeText;
    _lblUsedVoucherMessage.text = _voucherData.voucher_promo_desc;
        
    [self adjustGrandTotal];
    [_tableView reloadData];
}

-(void)doCheckoutWithToppay{
    
    [self isLoading:YES];
    
    [self adjustDropshipperListParam];
    
    NSDictionary *dropshipperDetail = [_dataInput objectForKey:DATA_DROPSHIPPER_LIST_KEY]?:@{};
    NSDictionary *partialDetail = [_dataInput objectForKey:DATA_PARTIAL_LIST_KEY]?:@{};
    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY]?:@"";
    NSMutableArray *dropshipStrList = [NSMutableArray new];
    for (TransactionCartList *cart in _list) {
        [dropshipStrList addObject:cart.cart_dropship_param?:@""];
    }
    NSMutableArray *partialStrList = [NSMutableArray new];
    for (TransactionCartList *cart in _list) {
        [partialStrList addObject:cart.cart_partial_param?:@""];
    }
    
    NSMutableDictionary *cartListRate = [NSMutableDictionary new];
    for (TransactionCartList *cart in _list) {
        [cartListRate setValue:cart.rateValue forKey:cart.rateString];
    }
    
    __weak typeof(self) weakSelf = self;
    [RequestCart fetchToppayWithToken:_cart.token
                         listDropship:[dropshipStrList copy]
                       dropshipDetail:dropshipperDetail
                          listPartial:[partialStrList copy]
                        partialDetail:partialDetail
                          voucherCode:voucherCode
                       donationAmount:_cart.donation.usedDonationValue
                         cartListRate:cartListRate
     
                              success:^(TransactionActionResult *data) {
                                  
                                  NSString * transactionID = [data.parameter objectForKey:@"transaction_id"];
                                  [weakSelf trackCheckoutProduct:_cart
                                                            step:@"2"
                                                      optionName:@"click payment option button"
                                                       paymentID:transactionID];
                                  
                                  [TransactionCartWebViewViewController pushToppayFrom:self data:data];
                                  _popFromToppay = YES;
                                  [weakSelf isLoading:NO];
                                  
                              } error:^(NSError *error) {
                                  if (error) {
                                      [weakSelf doClearAllData];
                                      [weakSelf isLoading:NO];
                                      [_noInternetConnectionView generateRequestErrorViewWithError:error];
                                      [_tableView addSubview:_noInternetConnectionView];
                                      
                                  }
                                  [weakSelf isLoading:NO];
                              }];
}

-(void)doRequestEditProduct:(ProductDetail*)product{
    [RequestCart fetchEditProduct:product
                          success:^(TransactionAction *data) {
                              [self requestCartData];
                              [_tableView reloadData];
                          } error:^(NSError *error) {
                              if (error) {
                                  [self doClearAllData];
                                  [self isLoading:NO];
                                  [_noInternetConnectionView generateRequestErrorViewWithError:error];
                                  [_tableView addSubview:_noInternetConnectionView];
                              }
                              
                              [self isLoading:NO];
                          }];
}

- (void) setupTickerAndNoResultView {
    [self.view addSubview:_noResultScrollView];
    [containerView addSubview:_noResultView];
    [containerView addSubview:tickerView];
    [containerView addSubview:_topAdsView];
    [_noResultScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_noResultScrollView);
        make.width.mas_equalTo([NSNumber numberWithFloat:UIScreen.mainScreen.bounds.size.width]);
    }];
    [tickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(containerView.mas_top).offset(16);
        make.left.mas_equalTo(containerView.mas_left).offset(16);
        make.right.mas_equalTo(containerView.mas_right).offset(-16);
    }];
    [_noResultView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tickerView.mas_bottom);
        make.left.mas_equalTo(containerView.mas_left);
        make.right.mas_equalTo(containerView.mas_right);
        make.height.mas_equalTo(400);
    }];
    [couponLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tickerView.mas_left).offset(16);
        make.top.mas_equalTo(tickerView.mas_top).offset(16);
        make.bottom.mas_equalTo(tickerView.mas_bottom).offset(-16);
        make.right.mas_equalTo(buttonClose.mas_left).offset(-16);
    }];
    [buttonClose mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(tickerView.mas_right).offset(-16);
        make.centerY.mas_equalTo(tickerView.mas_centerY);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    if (couponLabel == nil || couponLabel.text.length == 0) {
        [tickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [buttonClose mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    [buttonClose bk_whenTapped:^{
        [_request cancelVoucher];
        [tickerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [buttonClose mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [couponLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }];
}

#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    [self refreshRequestCart];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
    } else {
        [_noInternetConnectionView removeFromSuperview];
        [self refreshRequestCart];
    }
}

#pragma mark - InputPromoViewDelegate
- (void)didUseVoucher:(InputPromoViewController *)inputPromoViewController voucherData:(id)voucherData serviceType:(enum PromoServiceType)serviceType promoType:(enum PromoType)promoType {
    _voucherData = (TransactionVoucherData *)voucherData;
    _promoType = promoType;
    
    [_dataInput setObject:_voucherData.voucher_code forKey:API_VOUCHER_CODE_KEY];
    [_dataInput setObject:@(NO) forKey:@"isUsingPromoSuggestion"];
    
    [self useVoucher];
}

- (IBAction)insuranceButton:(id)sender {
    WebViewController *webViewController = [WebViewController new];
    webViewController.strURL = [NSString stringWithFormat: @"%@%@", [NSString v4Url], @"/v4/web-view/get_insurance_info.pl"];
    webViewController.strTitle = @"Syarat dan Ketentuan";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Tracker
- (void)trackCheckoutProduct:(TransactionCartResult*)cartResult
                        step:(NSString *)step
                  optionName:(NSString *)optionName
                   paymentID:(nullable NSString *)paymentID {
    NSMutableArray *products = [NSMutableArray new];
    for (TransactionCartList*cartList in cartResult.list) {
        NSString *shopType = cartList.cart_shop.isOfficial ? @"official_store" : cartList.cart_shop.shop_is_gold==1 ? @"gold_merchant" : @"reguler";
        for (ProductDetail*detail in cartList.cart_products) {
            NSDictionary *product = @{
                                      @"name" : detail.product_name ?: @"",
                                      @"id" : detail.product_id ?: @"",
                                      @"price" : detail.product_price ?: @"0",
                                      @"brand" : @"none/other",
                                      @"category" : detail.product_cat_name_tracking ?: @"",
                                      @"variant" : @"none/other",
                                      @"quantity" : detail.product_quantity ?: @"1",
                                      @"shopId" : cartList.cart_shop.shop_id ?: @"",
                                      @"shop_name" : cartList.cart_shop.shop_name ?: @"",
                                      @"shopType" : shopType,
                                      @"dimension37" : detail.trackerInfo.trackerAttribution ?: @"none/other",
                                      @"ctg_id" : detail.product_cat_id ?: @""
                                      };
            [products addObject:product];
        }
    }
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"event" : @"checkout",
        @"ecommerce" : @{
              @"checkout" : @{
                      @"actionField" : @{
                              @"step" : step ?: @"",
                              @"option" : optionName ?: @""
                              },
                      @"products" : products
                      }
              }
    }];
    
    if ([step  isEqual: @"2"] && paymentID != nil) {
        [data setValue:paymentID forKey:@"payment_id"];
    }
    [AnalyticsManager trackData:data];
}

- (void)trackRemoveProductFromCart:(TransactionCartList*)cartList productIndex:(int)index {
    NSString *shopType = cartList.cart_shop.isOfficial ? @"official_store" : cartList.cart_shop.shop_is_gold==1 ? @"gold_merchant" : @"reguler";
    if (index >= 0) {
        [self doTrackRemovePerProduct:cartList.cart_products[index] cart:cartList type:shopType];
    } else {
        for (ProductDetail*product in cartList.cart_products) {
            [self doTrackRemovePerProduct:product cart:cartList type:shopType];
        }
    }
}

- (void) doTrackRemovePerProduct:(ProductDetail*)product cart:(TransactionCartList*)cartList type:(NSString*)shopType {
    NSDictionary *data = @{
       @"event" : @"removeFromCart",
       @"ecommerce" : @{
           @"currencyCode" : @"IDR",
           @"remove" : @{
               @"products" : @[@{
                   @"name": product.product_name ?: @"",
                   @"id": product.product_id ?: @"",
                   @"price": product.product_price ?: @"",
                   @"brand": @"none/other",
                   @"category": product.product_cat_name_tracking ?: @"",
                   @"variant": @"none/other",
                   @"quantity": product.product_quantity ?: @1,
                   @"shop_id": cartList.cart_shop.shop_id ?: @"",
                   @"shop_type": shopType ?: @"",
                   @"shop_name": cartList.cart_shop.shop_name ?: @"",
                   @"category_id": product.product_cat_id ?: @"",
                   @"cart_id": product.product_cart_id ?: @"",
                   @"dimension37" : product.trackerInfo.trackerAttribution ?: @"none/other"
                   }]
               }
           }
       };
    [AnalyticsManager trackData:data];
}
@end
