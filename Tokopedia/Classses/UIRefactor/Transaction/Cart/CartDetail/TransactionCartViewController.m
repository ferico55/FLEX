
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

#import "SwiftOverlays.h"
#import "CustomNotificationView.h"

#import "NSStringCategory.h"

#import "Tokopedia-Swift.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "RegisterViewController.h"
#import "NotificationManager.h"

#define DurationInstallmentFormat @"%@ bulan (%@)"

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
    NoResultDelegate
>
{
    NSMutableArray<TransactionCartList *> *_list;
    
    TransactionCartResult *_cart;
    
    NSMutableDictionary *_dataInput;
    
    UITextField *_activeTextField;
    
    UIRefreshControl *_refreshControl;
    
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

    NoResultReusableView *_noResultView;
    NoResultReusableView *_noInternetConnectionView;
    NoLoginView *_noLoginView;
    
    NSMutableArray *_errorMessages;
    NotificationManager *_notifManager;
    
    UIView *_lineView;
}

@property (weak, nonatomic) IBOutlet UIView *voucerCodeBeforeTapView;
@property (weak, nonatomic) IBOutlet UIButton *voucherCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *voucherAmountLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *voucerCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalInvoiceCell;

@property (strong, nonatomic) IBOutlet UIView *checkoutView;

@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet UIButton *buttonVoucherInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancelVoucher;
@property (strong, nonatomic) IBOutlet UITableViewCell *usedLPCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *LPCashbackCell;

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
#define CELL_PRODUCT_ROW_HEIGHT 126

#define NOT_SELECT_GATEWAY -1

@implementation TransactionCartViewController
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    
    [self initNotification];

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequestCart)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self initNoResultView];
    [self initNoInternetConnectionView];
    [self initNoLoginView];
    [self initNotificationManager];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    if (auth.isLogin) {
        [self refreshRequestCart];
        _noLoginView.hidden = YES;
    }
    
    [AnalyticsManager trackScreenName:@"Shopping Cart"];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertErrorMessage:)
                                                 name:@"AddErrorMessage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
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

#pragma mark - Notification Manager

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem =_notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

#pragma mark - Notification delegate

- (void)reloadNotification
{
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 50, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    _noResultView.delegate = self;
    _noResultView.button.tag = 1;
    [_noResultView generateAllElements:@"Keranjang.png"
                                 title:@"Keranjang belanja Anda kosong"
                                  desc:@"Pilih dan beli produk yang anda inginkan,\nayo mulai belanja!"
                              btnTitle:@"Ayo mulai belanja!"];
}

- (void)initNoInternetConnectionView {
    _noInternetConnectionView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _noInternetConnectionView.delegate = self;
    _noInternetConnectionView.button.tag = 2;
}

-(void)initNoLoginView{
    _noLoginView = [NoLoginView newView];
    __weak typeof(self) wself= self;
    _noLoginView.onTapRegister = ^(){
        RegisterViewController* controller = [RegisterViewController new];
        controller.onLoginSuccess = ^() {
            [wself.tabBarController setSelectedIndex:3];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR object:nil userInfo:nil];
        };
        [wself.navigationController pushViewController:controller animated:YES];
    };
    [self.view addSubview:_noLoginView];
    [_noLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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

}

-(void)userLogin{
    _noLoginView.hidden = YES;
}

-(void)userLogout{
    _noLoginView.hidden = NO;
}

-(UIAlertView*)alertLoading{
    if (!_alertLoading) {
        _loadingView = [LoadingView new];
        _loadingView.delegate = self;
        _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    }
    
    return _alertLoading;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _activeTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Delegate & Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count + 4;
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
        rowCount = 0;

    else rowCount = 1; // total pembayaran
    
    return (_list.count==0)?0:rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;

    NSInteger shopCount = _list.count;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

    if (indexPath.section <shopCount)
        cell = [self cellListCartByShopAtIndexPath:indexPath];
    else if (indexPath.section == shopCount)
        cell =  [self cellLoyaltyPointAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+1)
        cell = [self cellPaymentInformationAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+2)
        cell = nil;
    else
    {
        cell = _totalPaymentCell;
        NSString *totalPayment;
        if ([self isUseGrandTotalWithoutLP]) {
            totalPayment = _cart.grand_total_without_lp_idr;
        }
        else
            totalPayment = _cart.grand_total_idr;
        [cell.detailTextLabel setText:totalPayment animated:YES];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, _tableView.frame.size.width,1)];
    if (indexPath.section != shopCount+2) {
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
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

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
    else if (section == _list.count+2)
    {
            if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] ||
                ([self depositAmountUser] == 0) )
                return 0.1f;
            else
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
}

-(void)pushShipmentCart:(TransactionCartList*)cart
{
    TransactionCartShippingViewController *shipmentViewController = [TransactionCartShippingViewController new];
    shipmentViewController.cart = cart;
    shipmentViewController.indexPage = 0;
    shipmentViewController.delegate = self;
    [self.navigationController pushViewController:shipmentViewController animated:YES];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 10:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kode Voucher"
                                                            message:@"Masukan kode voucher"
                                                           delegate:self
                                                  cancelButtonTitle:@"Batal"
                                                  otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = TAG_BUTTON_VOUCHER;
            [alert show];
        }
            break;
        case 11:
        {
            AlertInfoView *alertInfo = [AlertInfoView newview];
            alertInfo.text = @"Info Kode Voucher Tokopedia";
            alertInfo.detailText = @"Hanya berlaku untuk satu kali pembayaran. Sisa nilai voucher tidak dapat dikembalikan";
            [alertInfo show];
        }
        case 12:
        {
            _voucherCodeButton.hidden = NO;
            _voucherAmountLabel.hidden = YES;
            _buttonCancelVoucher.hidden = YES;
            _buttonVoucherInfo.hidden = NO;
            
            _voucherData = [TransactionVoucherData new];
            [_dataInput setObject:@"" forKey:API_VOUCHER_CODE_KEY];
            [self adjustGrandTotal];
            [_tableView reloadData];
        }
            break;
        default:
            if (_hasDisplayedPaymentError) {
                [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Checkout after error"];
            } else {
                [AnalyticsManager trackEventName:@"clickCheckout" category:GA_EVENT_CATEGORY_CHECKOUT action:GA_EVENT_ACTION_CLICK label:@"Checkout"];
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
-(void)TransactionCartShipping:(TransactionCartList *)cart
{
    [self isLoading:YES];
    [self requestCartData];
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo
{
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
        product.product_error_msg == nil ) {
        [NavigateViewController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_pic withShopName:list.cart_shop.shop_name];
    }
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {
        [NavigateViewController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_pic withShopName:list.cart_shop.shop_name];
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
        [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:[_errorMessages copy]]
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
        //NSInteger shipmentID = [list.cart_shipments.shipment_id integerValue];
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
        
        [AnalyticsManager trackRemoveProductsFromCart:_list];
        
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
    
    [AnalyticsManager trackRemoveProductFromCart:product];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART_PRODUCT,list.cart_shop.shop_name, product.product_name, product.product_total_price_idr];
        UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
        cancelCartAlert.tag = 10;
        [cancelCartAlert show];
    } else {
        if (product.errors.count == 0 ||
            list.errors.count == 0 ||
            [[product.errors firstObject].name isEqualToString:@"product-less-than-min"] ||
            [[product.errors firstObject].name isEqualToString:@"product-more-than-max"] ||
            [[list.errors firstObject].name isEqualToString:@"shopping-limit-exceeded"]) {
            TransactionCartEditViewController *editViewController = [TransactionCartEditViewController new];
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
            editViewController.data = _dataInput;
            editViewController.delegate = self;
            [self.navigationController pushViewController:editViewController animated:YES];
        }
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
        case TAG_BUTTON_VOUCHER:
        {
            if (buttonIndex == 1) {
                NSString *voucherCode = [[alertView textFieldAtIndex:0] text];
                [_dataInput setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
                if ([CartValidation isValidInputVoucherCode:voucherCode]) {
                    [self doRequestVoucher];
                } else {
                    [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
                }
            }
        }
            break;
        case TAG_ALERT_PARTIAL:
        {
            NSInteger partialSection = [[_dataInput objectForKey:DATA_PARTIAL_SECTION] integerValue];
            NSInteger index = [[((AlertPickerView*)alertView).data objectForKey:DATA_INDEX_KEY] integerValue];
            TransactionCartList *list = _list[partialSection];
            NSInteger shopID = [list.cart_shop.shop_id integerValue];
            NSInteger addressID =[list.cart_destination.address_id integerValue];
            //NSInteger shipmentID = [list.cart_shipments.shipment_id integerValue];
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
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
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
        if (_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
        }
        if (_list.count>0) {
            _tableView.tableFooterView = _checkoutView;
        } else _tableView.tableFooterView = nil;
        [[self alertLoading] dismissWithClickedButtonIndex:0 animated:YES];
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
    [self requestCartData];
}

-(void)doClearAllData
{
    [_dataInput removeAllObjects];
    [_list removeAllObjects];
    
    _voucherCodeButton.hidden = NO;
    _voucherAmountLabel.hidden = YES;
    _buttonVoucherInfo.hidden = NO;
    _buttonCancelVoucher.hidden = YES;
    
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
            cell = [CartCell cellIsPartial:_list[indexPath.section].cart_is_partial tableView:_tableView atIndextPath:indexPath];
        } else if (indexPath.row == productCount+3) {
            cell = [CartCell cellIsDropshipper:_list[indexPath.section].cart_is_dropshipper tableView:_tableView atIndextPath:indexPath];
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
            cell = _voucerCell;
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
            if ([list.cart_total_product integerValue]<=1) {
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
        if ([self isUseGrandTotalWithoutLP]) {
            return 0;
        }
        
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
        }
    }

    return DEFAULT_ROW_HEIGHT;
}

-(CGFloat)errorLabelHeight:(TransactionCartList*)list
{
    NSString *error1 = ([list.cart_error_message_1 isEqualToString:@"0"] || !(list.cart_error_message_1))?@"":list.cart_error_message_1;
    NSString *error2 = ([list.cart_error_message_2 isEqualToString:@"0"] || !(list.cart_error_message_2))?@"":list.cart_error_message_2;
    if ([error1 isEqualToString:@""]&& [error2 isEqualToString:@""])
    {
        return 0;
    }
    else
    {
        NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
        CGSize maximumLabelSize = CGSizeMake(_tableView.frame.size.width,9999);
        NSStringDrawingContext *context = [NSStringDrawingContext new];
        CGSize expectedLabelSize = [string boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont title1Theme]}
                                                        context:context].size;
        
        return expectedLabelSize.height;
    }
}

-(CGFloat)productRowHeight:(ProductDetail*)product
{
    NSString *productNotes = [product.product_notes stringByReplacingOccurrencesOfString:@"\n" withString:@"; "];
    NSString *string = productNotes;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(_tableView.frame.size.width,9999);
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont title1Theme]
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    
    
    if ([productNotes isEqualToString:@""]) {
        expectedLabelSize.height = 0;
    }
    
    CGSize expectedErrorLabelSize;
    
    if (product.errors.count > 0) {
        Errors *error = product.errors[0];
        
        NSString *errorText = [NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc];
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
                                       
                                       [AnalyticsManager localyticsEvent:@"Event : Finished Transaction"
                                                              attributes:@{
                                                                           @"Payment Method" : paymentMethod,
                                                                           @"Total Transaction" : [revenue stringValue]?:@"",
                                                                           @"Total Quantity" : [@(quantity) stringValue]?:@"",
                                                                           @"Total Shipping Fee" : @""
                                                                           }
                                                   customerValueIncrease:revenue];
                                       
                                       [AnalyticsManager localyticsIncrementValue:[revenue integerValue]
                                                                 profileAttribute:@"Profile : Total Transaction"
                                                                            scope:LLProfileScopeApplication];
                                   }
                                   [self requestCartData];
                               } error:^(NSError *error) {
                                [self requestCartData];
                                     
                                 }];
    

}

-(void)requestCartData{
    
    _isLoadingRequest = YES;
    _checkoutButton.enabled = NO;

    [RequestCart fetchCartData:^(TransactionCartResult *data) {
        [_noInternetConnectionView removeFromSuperview];
        NSArray<TransactionCartList*> *list = [self setCartDataFromPreviousCarts:_cart.list toNewCarts:data.list];
        [_list removeAllObjects];
        [_list addObjectsFromArray:list];
        
        if(list.count >0){
            [_noResultView removeFromSuperview];
        }else{
            [_tableView addSubview:_noResultView];
        }
        
        _cart = data;
        [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL];
        [_dataInput setObject:_cart.grand_total_without_lp?:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL_WO_LP];
        [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_CART_GRAND_TOTAL_W_LP];
        
        [self adjustGrandTotal];
        
        [self isLoading:NO];
        [AnalyticsManager localyticsTrackCartView:_cart];
        [self reloadNotification];
        
    } error:^(NSError *error) {
        [_noResultView removeFromSuperview];
        [_noInternetConnectionView generateRequestErrorViewWithError:error];
        [_tableView addSubview:_noInternetConnectionView];
        if (_list.count <=0) {
            _tableView.tableFooterView =_loadingView.view;
        }
        [self isLoading:NO];
    }];
}

-(NSArray <TransactionCartList*> *)setCartDataFromPreviousCarts:(NSArray <TransactionCartList*> *)previousCarts toNewCarts:(NSArray <TransactionCartList*> *)newCarts{
    for (TransactionCartList *cart in previousCarts) {
        for (TransactionCartList *newCart in newCarts) {
            
            if ([newCart.cart_shop.shop_id integerValue] == [cart.cart_shop.shop_id integerValue] &&
                [newCart.cart_destination.address_id integerValue] == [cart.cart_destination.address_id integerValue] &&
                [newCart.cart_shipments.shipment_id integerValue] == [cart.cart_shipments.shipment_id integerValue] &&
                [newCart.cart_shipments.shipment_package_id integerValue] == [cart.cart_shipments.shipment_package_id integerValue]
                ) {
                
                newCart.cart_dropship_name = cart.cart_dropship_name?:@"";
                newCart.cart_dropship_phone = cart.cart_dropship_phone?:@"";
                newCart.cart_is_dropshipper = cart.cart_is_dropshipper?:@"";
                newCart.cart_dropship_param = cart.cart_dropship_param?:@"";
                newCart.cart_is_partial = cart.cart_is_partial?:@"0";
                newCart.cart_partial_param = cart.cart_partial_param?:@"";
                
                NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:newCart};
                [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil userInfo:info];
                
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
                                    NSMutableArray *products = [NSMutableArray new];
                                    [products addObjectsFromArray:list.cart_products];
                                    [products removeObject:product];
                                    ([_list objectAtIndex:indexPathCancelProduct.section]).cart_products = products;
                                    if (([_list objectAtIndex:indexPathCancelProduct.section]).cart_products.count<=0) {
                                        [_list removeObject:_list[indexPathCancelProduct.section]];
                                    }
                                } else {
                                    [_list removeObject:list];
                                }
                                [self requestCartData];
                                [self isLoading:NO];
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
    [RequestCart fetchVoucherCode:voucherCode success:^(TransactionVoucher *voucher) {
        
        _voucherData = voucher.data.data_voucher;
        
        _voucherCodeButton.hidden = YES;
        _voucherAmountLabel.hidden = NO;
        
        NSInteger voucherAmount = [_voucherData.voucher_amount integerValue];
        NSString *voucherString = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:voucherAmount]];
        voucherString = [NSString stringWithFormat:@"Anda mendapatkan voucher %@", voucherString];
        if (![_voucherData.voucher_promo_desc isEqualToString:@""]){
            voucherString = _voucherData.voucher_promo_desc;
        }
        _voucherAmountLabel.text = voucherString;
        _voucherAmountLabel.font = [UIFont microTheme];
        
        _buttonVoucherInfo.hidden = YES;
        _buttonCancelVoucher.hidden = NO;
        
        [self isLoading:NO];
        [self adjustGrandTotal];
        [_tableView reloadData];
    } error:^(NSError *error) {
        [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
        [self isLoading:NO];
    }];
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
    
    [RequestCart fetchToppayWithToken:_cart.token
                         listDropship:[dropshipStrList copy]
                       dropshipDetail:dropshipperDetail
                          listPartial:[partialStrList copy]
                        partialDetail:partialDetail
                          voucherCode:voucherCode
							  success:^(TransactionActionResult *data) {
                              
                              [TransactionCartWebViewViewController pushToppayFrom:self data:data];
                              _popFromToppay = YES;
                              [self isLoading:NO];

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

@end
