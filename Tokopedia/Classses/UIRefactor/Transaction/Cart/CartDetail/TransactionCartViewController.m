
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
#import "TransactionCartFormMandiriClickPayViewController.h"
#import "TransactionCartWebViewViewController.h"
#import "AlertInfoView.h"
#import "StickyAlertView.h"
#import "GeneralTableViewController.h"

#import "CartCell.h"
#import "CartValidation.h"

#import "TransactionCCViewController.h"

#import "RequestCart.h"
#import "TAGDataLayer.h"

#import "TagManagerHandler.h"

#import "LoadingView.h"

#import "GeneralTableViewController.h"

#import "ListRekeningBank.h"
#import "NoResultReusableView.h"
#import "NSNumberFormatter+IDRFormater.h"

#import "TxOrderTabViewController.h"
#import "SwiftOverlays.h"
#import "CustomNotificationView.h"

#import "NSStringCategory.h"

#import "Tokopedia-Swift.h"

#import "UITableView+FDTemplateLayoutCell.h"

#import "TPAnalytics.h"
#import "TPLocalytics.h"

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
    TransactionCartMandiriClickPayFormDelegate,
    TransactionCartShippingViewControllerDelegate,
    TransactionCartEditViewControllerDelegate,
    TransactionCartWebViewViewControllerDelegate,
    LoadingViewDelegate,
    TransactionCCViewControllerDelegate,
    GeneralTableViewControllerDelegate,
    NoResultDelegate
>
{
    NSMutableArray<TransactionCartList *> *_list;
    
    TransactionCartResult *_cart;
    TransactionSummaryDetail *_cartSummary;
    TransactionBuyResult *_cartBuy;
    
    NSMutableDictionary *_dataInput;
    
    UITextField *_activeTextField;
    
    UIRefreshControl *_refreshControl;
    BOOL _isUsingSaldoTokopedia;
    
    BOOL _isLoadingRequest;
    
    BOOL _popFromToppay;
    
    UIAlertView *_alertLoading;
    
    LoadingView *_loadingView;
    TAGContainer *_gtmContainer;
    
    BOOL _isSelectBankInstallment;
    BOOL _isSelectDurationInstallment;
    BOOL _isSaldoError;
    BOOL _isDropshipperError;
    BOOL _shouldDisplayButtonOnErrorAlert;
    
    TransactionVoucherData *_voucherData;

    NoResultReusableView *_noResultView;
    NoResultReusableView *_noInternetConnectionView;
    
    NSMutableArray *_errorMessages;
    
    UIView *_lineView;
}
@property (weak, nonatomic) IBOutlet UIView *paymentMethodView;
@property (weak, nonatomic) IBOutlet UIView *paymentMethodSelectedView;
@property (weak, nonatomic) IBOutlet UIButton *choosePaymentButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *selectedPaymentMethodLabels;

@property (weak, nonatomic) IBOutlet UIView *voucerCodeBeforeTapView;
@property (weak, nonatomic) IBOutlet UIButton *voucherCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *voucherAmountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *saldoErrorIcon;
@property (weak, nonatomic) IBOutlet UISwitch *switchUsingSaldo;

@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UITextField *saldoTokopediaAmountTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *paymentGatewayCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *paymentGatewaySummaryCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucerCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalInvoiceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *transferCodeCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *errorCells;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *errorLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *saldoTextFieldCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *usedSaldoCell;

@property (strong, nonatomic) IBOutlet UIView *checkoutView;
@property (strong, nonatomic) IBOutlet UIView *buyView;

@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *saldoTokopediaCell;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet UIButton *buttonVoucherInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancelVoucher;
@property (strong, nonatomic) IBOutlet UITableViewCell *depositAmmountCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ccAdministrationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ccFeeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *usedLPCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *LPCashbackCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *usedLP1Cell;
@property (strong, nonatomic) IBOutlet UITableViewCell *LPCashback1Cell;

@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentDetail;
@property (weak, nonatomic) IBOutlet UILabel *depositAmountLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucherUsedCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *klikBCAUserIDCell;
@property (weak, nonatomic) IBOutlet UITextField *userIDKlikBCATextField;

@property (strong, nonatomic) IBOutlet UIView *chooseBankDurationView;
@property (weak, nonatomic) IBOutlet UILabel *bankInstallmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationInstallmentLabel;

@property (weak, nonatomic) IBOutlet UIView *bankView;
@property (weak, nonatomic) IBOutlet UIView *durationView;
@property (strong, nonatomic) IBOutlet UILabel *transferCodeInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *transferCodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *klikBCANotes;

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
@synthesize indexPage =_indexPage;
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];

    _selectedPaymentMethodLabels = [NSArray sortViewsWithTagInArray:_selectedPaymentMethodLabels];
    
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

    if (_indexPage == 0) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
        [_refreshControl addTarget:self action:@selector(refreshRequestCart)forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
        
        if (_isLogin) {
            [_refreshControl beginRefreshing];
            [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
            [_refreshControl beginRefreshing];
            [self requestCartData];
        }
        _paymentMethodView.hidden = YES;
        
    }
    [self initNoResultView];
    [self initNoInternetConnectionView];
    [self setDefaultInputData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertErrorMessage:)
                                                 name:@"AddErrorMessage"
                                               object:nil];

    [_klikBCANotes setCustomAttributedText:_klikBCANotes.text];
    
    _saldoErrorIcon.hidden = YES;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, -30, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    _noResultView.delegate = self;
    _noResultView.button.tag = 1;
    [_noResultView generateAllElements:@"Keranjang.png"
                                 title:@"Keranjang belanja Anda kosong"
                                  desc:@"Pilih dan beli produk yang anda inginkan,\nayo mulai belanja!"
                              btnTitle:@"Ayo mulai belanja!"];
    [_transferCodeInfoLabel setCustomAttributedText:_transferCodeInfoLabel.text];
}

- (void)initNoInternetConnectionView {
    _noInternetConnectionView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, -30, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _noInternetConnectionView.delegate = self;
    _noInternetConnectionView.button.tag = 2;
    [_transferCodeInfoLabel setCustomAttributedText:_transferCodeInfoLabel.text];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_indexPage == 0) {
        [TPAnalytics trackScreenName:@"Shopping Cart"];
        self.screenName = @"Shopping Cart";
        
        TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
        [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
        
        if (_popFromToppay) {
            _popFromToppay = NO;
            [self refreshRequestCart];
        }
        if (_list.count>0) {
            _tableView.tableFooterView =_checkoutView;
        } else _tableView.tableFooterView = nil;
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 40)];
        
    } else {
        [TPAnalytics trackScreenName:@"Shopping Cart Summary"];
        self.screenName = @"Shopping Cart Summary";
        [self adjustTableViewData:_data];
        _passwordTextField.text = @"";
        if (_list.count>0) {
            _tableView.tableFooterView =_buyView;
        } else _tableView.tableFooterView = nil;
    }

    _tableView.scrollsToTop = YES;
    [self adjustPaymentMethodView];
    [self swipeView:_paymentMethodView];
}

-(UIAlertView*)alertLoading{
    if (!_alertLoading) {
        _loadingView = [LoadingView new];
        _loadingView.delegate = self;
        _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    }
    
    return _alertLoading;
}

-(void)headerInstallmentAnimating
{
    if ([_durationInstallmentLabel.text isEqualToString:@"Pilih"]) {
        [self swipeView:_durationView];
    }
    if ([_bankInstallmentLabel.text isEqualToString:@"Pilih"]) {
        [self swipeView:_bankView];
    }
}

-(void)adjustPaymentMethodView
{
    if (_list.count==0) {
        _paymentMethodView.hidden = YES;
        _paymentMethodSelectedView.hidden = YES;
    }
    else
    {
        if (_indexPage == 0) {
            _paymentMethodView.hidden = NO;
            _paymentMethodSelectedView.hidden = YES;
        }
        else if (_indexPage == 1) {
            _paymentMethodView.hidden = YES;
            _paymentMethodSelectedView.hidden = NO;
        }
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
        rowCount = 9; // Kode Promo Tokopedia LPcell, Total invoice, Saldo Tokopedia Terpakai, Kode Transfer, Voucher, Biaya Administrasi,Total Pembayaran
    }
    else if (section == listCount+2)
        rowCount = 5; //saldo tokopedia, textfield saldo, deposit amount, password tokopedia, userID klik BCA

    else rowCount = 2; // Biaya administrasi, total pembayaran
    
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
        cell = [self cellAdjustDepositAtIndexPath:indexPath];
    else
    {
        if (indexPath.row == 1) {
            cell = _ccFeeCell;
            _ccFeeCell.textLabel.text = @"Total belum termasuk biaya layanan.";
        }
        else
        {
            cell = _totalPaymentCell;
            NSString *totalPayment;
            if (_indexPage == 0) {
                if ([self isUseGrandTotalWithoutLP]) {
                    totalPayment = _cart.grand_total_without_lp_idr;
                }
                else
                    totalPayment = _cart.grand_total_idr;
            }
            else
                totalPayment = _cartSummary.payment_left_idr;
            
            [cell.detailTextLabel setText:totalPayment animated:YES];
        }
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
        return (_indexPage==0)?[self rowHeightPage1AtIndexPath:indexPath]:[self rowHeightPage2AtIndexPath:indexPath];
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
        if (_indexPage == 0) {
            if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] ||
                ([self depositAmountUser] == 0) )
                return 0.1f;
            else
                return 10;
        }
        if (_indexPage==1)
        {
            if ([_cartSummary.deposit_amount integerValue]<=0 ||
                [_cartSummary.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA)
                return 0.1f;
        }
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
        if (_indexPage==0)
        {
            if ([_cart.cashback integerValue] == 0) {
                return 0.1f;
            }
        }
        if (_indexPage==1)
        {
            if ([_cartSummary.lp_amount integerValue] <= 0) {
                return 0.1f;
            }
        }
    }
    else if(section == listCount+2)
    {
        if (_indexPage==1)
        {
            if ([_cartSummary.deposit_amount integerValue]<=0 ||
                [_cartSummary.gateway integerValue] == TYPE_GATEWAY_TOKOPEDIA)
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
    shipmentViewController.indexPage = _indexPage;
    shipmentViewController.delegate = self;
    [self.navigationController pushViewController:shipmentViewController animated:YES];
}

-(void)setDataDropshipperCartSummary{
    for (TransactionCartList *cart in _cartSummary.carts) {
        NSInteger shopID = [cart.cart_shop.shop_id integerValue];
        NSInteger addressID = [cart.cart_destination.address_id integerValue];
        NSInteger shipmentID =[cart.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [cart.cart_shipments.shipment_package_id integerValue];
        NSString *dropshipStringObjectFormat = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_CART_SUMMARY_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        NSString *partialStringObjectFormat = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_CART_SUMMARY_KEY,shopID,addressID,shipmentPackageID];
        
        NSDictionary *dropshipList = _cartSummary.dropship_list;
        for (int i = 0; i<[dropshipList allKeys].count; i++) {
            if ([[dropshipList allKeys][i] isEqualToString:dropshipStringObjectFormat]) {
                cart.cart_is_dropshipper = @"1";
                cart.cart_dropship_name = [[dropshipList objectForKey:dropshipStringObjectFormat]objectForKey:@"name"]?:@"";
                cart.cart_dropship_phone = [[dropshipList objectForKey:dropshipStringObjectFormat]objectForKey:@"telp"]?:@"";
                break;
            }
        }
        
        NSDictionary *partialList = _cartSummary.data_partial;
        for (int i = 0; i<[partialList allKeys].count; i++) {
            if ([[partialList allKeys][i] isEqualToString:partialStringObjectFormat]) {
                cart.cart_is_partial = @"1";
                break;
            }
        }
    }
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [_delegate shouldBackToFirstPage];
    }
    else {
        if (_indexPage==0){
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
                    [self adjustGrandTotalWithDeposit:_saldoTokopediaAmountTextField.text];
                    [_tableView reloadData];
                }
                    break;
                default:
                    [TPAnalytics trackClickCartLabel:@"Checkout"];
                    if([self isValidInput]) {
						_saldoErrorIcon.hidden = YES;
                        if([self isHandlePaymentWithNative]) {
                            [self doCheckout];
                        } else if ([self isCanUseToppay]) {
                            [self doCheckoutWithToppay];
                        }
                    }
                break;
            }
        }
        if(_indexPage==1)
        {
            [TPAnalytics trackPaymentEvent:@"clickPayment" category:@"Payment" action:@"Click" label:@"Pay Now"];
            switch ([_cartSummary.gateway integerValue]) {
                case TYPE_GATEWAY_TOKOPEDIA:
                case TYPE_GATEWAY_TRANSFER_BANK:
                case TYPE_GATEWAY_BCA_KLIK_BCA:
                case TYPE_GATEWAY_INDOMARET:
                    if ([self isValidInput]) {
                        [self doRequestBuy];
                    }
                    break;
                 default:
                    break;
            }
        }
    }
}
- (IBAction)tapInfoTransferCode:(id)sender {
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Kode Unik";
    alertInfo.detailText = @"Kode Unik adalah nominal unik yang ditambahkan untuk mempermudah proses verifikasi.";
    [alertInfo show];
}

-(BOOL)isCanUseToppay
{
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    
    if ([gateway.toppay_flag isEqualToString:@""] || [gateway.toppay_flag isEqualToString:@"0"]) {
        return NO;
    } else
        return YES;
}

-(BOOL)isHandlePaymentWithNative
{
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    if([[self getGatewayIDNative] containsObject:gateway.gateway]) {
        return YES;
    }
    
    return NO;
}

- (IBAction)tapBankInstallment:(id)sender {
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Bank";
    controller.delegate = self;
    
    NSMutableArray *objects = [NSMutableArray new];
    
    for (InstallmentBank *bank in _cartSummary.installment_bank_option) {
        [objects addObject:bank.bank_name];
    }
    
    controller.objects = [objects copy];
    controller.selectedObject = _selectedInstallmentBank.bank_name;
    controller.tag = 1;
    _isSelectBankInstallment = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (IBAction)tapBankDuration:(id)sender {
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.title = @"Pilih Durasi";
    controller.delegate = self;
    
    NSMutableArray *objects = [NSMutableArray new];
    
    for (InstallmentTerm *term in _selectedInstallmentBank.installment_term) {
        [objects addObject:[NSString stringWithFormat:DurationInstallmentFormat,term.duration,term.monthly_price_idr]];
    }
    controller.objects = [objects copy];
    controller.selectedObject = [NSString stringWithFormat:DurationInstallmentFormat,_selectedInstallmentDuration.duration ,_selectedInstallmentDuration.monthly_price_idr];
    controller.tag = 2;
    _isSelectDurationInstallment = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)changeSwitchSaldo:(UISwitch *)switchSaldo
{
    _isUsingSaldoTokopedia = _isUsingSaldoTokopedia?NO:YES;
    if (!_isUsingSaldoTokopedia) {
        _saldoTokopediaAmountTextField.text = @"";
        [self adjustGrandTotalWithDeposit:_saldoTokopediaAmountTextField.text];
    }
    [_tableView reloadData];

    if (switchSaldo.isOn) {
        [TPAnalytics trackClickEvent:@"clickCheckout" category:@"Checkout" label:@"Use Deposit"];
    }
}
- (IBAction)tapChoosePayment:(id)sender {
    [TPAnalytics trackClickEvent:@"clickCheckout" category:@"Checkout" label:@"Payment Method"];
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY]?:[TransactionCartGateway new];
    
    NSMutableArray *gatewayListWithoutHiddenPayment= [NSMutableArray new];
    NSMutableArray *gatewayImages= [NSMutableArray new];
    
    NSString *hiddenGatewayString = [[self gtmContainer] stringForKey:GTMHiddenPaymentKey]?:@"-1";
    hiddenGatewayString = ([hiddenGatewayString isEqualToString:@""])?@"-1":hiddenGatewayString;
    NSArray *hiddenGatewayArray = [hiddenGatewayString componentsSeparatedByString: @","];
    
    NSMutableArray *hiddenGatewayName = [NSMutableArray new];
    NSMutableArray *hiddenGatewayImage = [NSMutableArray new];
    
    for (TransactionCartGateway *gateway in _cart.gateway_list) {
        [gatewayListWithoutHiddenPayment addObject:gateway.gateway_name?:@""];
        [gatewayImages addObject:gateway.gateway_image?:@""];
#ifdef DEBUG
        
#else
        for (NSString *hiddenGateway in hiddenGatewayArray) {
            if ([gateway.gateway isEqual:@([hiddenGateway integerValue])] && ![hiddenGatewayName containsObject:gateway.gateway_name]) {
                [hiddenGatewayImage addObject:gateway.gateway_image?:@""];
                [hiddenGatewayName addObject:gateway.gateway_name];
            }
        }
#endif
    }
    
    [gatewayImages removeObjectsInArray:hiddenGatewayImage];
    [gatewayListWithoutHiddenPayment removeObjectsInArray:hiddenGatewayName];
    
    GeneralTableViewController *vc = [GeneralTableViewController new];
    vc.tableViewCellStyle = UITableViewCellStyleDefault;
    vc.selectedObject = selectedGateway.gateway_name;
    vc.objectImages = [gatewayImages copy];
    vc.objects = [gatewayListWithoutHiddenPayment copy];
    vc.delegate = self;
    vc.title = @"Metode Pembayaran";
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSArray *)getGatewayIDNative
{
    NSString *nativeGatewayIDString = [[self gtmContainer] stringForKey:@"native_gateway_list"]?:@"-1";
    nativeGatewayIDString = ([nativeGatewayIDString isEqualToString:@""])?@"-1":nativeGatewayIDString;
    NSArray * nativeGatewayIDArray = [nativeGatewayIDString componentsSeparatedByString: @","];
    NSMutableArray *listGateway = [NSMutableArray new];
    for (NSString *gatewayID in nativeGatewayIDArray) {
        [listGateway addObject:@([gatewayID integerValue])];
    }
    
    return [listGateway copy];
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
    if (_indexPage == 0) {
        [self isLoading:YES];
        [self requestCartData];
        
    }
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
        ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
        [self doRequestEditProduct:product];       
    }
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

-(void)setIndexPage:(NSInteger)indexPage
{
    _indexPage = indexPage;
}

-(void)adjustTableViewData:(NSDictionary*)data
{
    TransactionSummaryDetail *summaryDetail = [_data objectForKey:DATA_CART_SUMMARY_KEY];
    _cartSummary = summaryDetail;

    [_list removeAllObjects];
    [_list addObjectsFromArray:summaryDetail.carts];
    
    TransactionCartGateway *selectedGateway = [_data objectForKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
    _tableView.tableHeaderView = ([selectedGateway.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT)?_chooseBankDurationView:nil;

    _isUsingSaldoTokopedia = ([_cartSummary.deposit_amount integerValue]>0);
    
    if ([selectedGateway.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT) {
        if (!_selectedInstallmentBank) _selectedInstallmentBank = _cartSummary.installment_bank_option[0];
        if (!_selectedInstallmentDuration){
            _selectedInstallmentDuration = ((InstallmentBank*)_cartSummary.installment_bank_option[0]).installment_term[0];
            [self adjustTotalPaymentInstallment];
        }
        
        _bankInstallmentLabel.text = _selectedInstallmentBank.bank_name;
        _durationInstallmentLabel.text = [NSString stringWithFormat:DurationInstallmentFormat,_selectedInstallmentDuration.duration ,_selectedInstallmentDuration.monthly_price_idr];
    }
    
    [_tableView reloadData];
}


-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    _errorMessages = [NSMutableArray new];
    _shouldDisplayButtonOnErrorAlert = NO;
    
    if (_indexPage == 0) {
        if ([((UILabel*)_selectedPaymentMethodLabels[0]).text isEqualToString:@"Pilih"])
            [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
        NSInteger gateway = [[_dataInput objectForKey:API_GATEWAY_LIST_ID_KEY]integerValue];
        if (gateway == -1) {
            isValid = NO;
            [_errorMessages addObject:ERRORMESSAGE_NULL_CART_PAYMENT];
            [self tapChoosePayment:self];
        }
        if (gateway == TYPE_GATEWAY_CC) {
            isValid = [CartValidation isValidInputCCCart:_cart];
        }
        if (gateway == TYPE_GATEWAY_BCA_KLIK_BCA) {
            isValid = [CartValidation isValidInputKlikBCACart:_cart];
        }
        if (gateway == TYPE_GATEWAY_INDOMARET) {
            isValid = [CartValidation isValidInputIndomaretCart:_cart];
        }
        if (_isUsingSaldoTokopedia)
        {
            NSInteger grandTotal = ([self isUseGrandTotalWithoutLP])?[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_WO_LP] integerValue]:[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
            NSNumber *deposit = [_dataInput objectForKey:DATA_USED_SALDO_KEY];
            if ([deposit integerValue] == 0) {
                isValid = NO;
                [_errorMessages addObject:@"Saldo harus diisi."];
                _saldoErrorIcon.hidden = NO;
                [self swipeView:_saldoTextFieldCell];
            } else {
                if ([deposit integerValue] >= grandTotal) {
                    isValid = NO;
                    [_errorMessages addObject:@"Jumlah Saldo Tokopedia yang Anda masukkan terlalu banyak. Gunakan Pembayaran Saldo Tokopedia apabila mencukupi."];
                    _saldoErrorIcon.hidden = NO;
                    [self swipeView:_saldoTextFieldCell];
                }
                if ([deposit integerValue]> [self depositAmountUser]) {
                    isValid = NO;
                    [_errorMessages addObject:@"Saldo Tokopedia Anda tidak mencukupi."];
                    _saldoErrorIcon.hidden = NO;
                    [self swipeView:_saldoTextFieldCell];
                }
            }
            
        }
    }
    
    if (_indexPage == 1) {
        if ([_cartSummary.gateway integerValue] == TYPE_GATEWAY_BCA_KLIK_BCA) {
            NSString *userID = _userIDKlikBCATextField.text;
            if ([userID isEqualToString:@""] || userID == nil) {
                isValid = NO;
                [_errorMessages addObject:ERRORMESSAGE_NULL_CART_USERID];
            }
        }
        if ([_cartSummary.deposit_amount integerValue]>0 && ![self isHalfDepositAndPaymentInstantWithPaymentGatewayIntegerValue:[_cartSummary.gateway integerValue]]) {
            NSString *password = _passwordTextField.text;
            if ([password isEqualToString:@""] || password == nil) {
                isValid = NO;
                [_errorMessages addObject:ERRORMESSAGE_NULL_CART_PASSWORD];
            }
        }
    }
    
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
        [TPAnalytics trackClickEvent:@"clickCheckout" category:@"Checkout" label:@"Dropshipper"];
    }
    _list[indexPath.section].cart_is_dropshipper = [NSString stringWithFormat:@"%zd",cell.settingSwitch.on];
    [_tableView reloadData];
}

#pragma mark - Header View Delegate
-(void)deleteTransactionCartHeaderView:(TransactionCartHeaderView *)view atSection:(NSInteger)section
{
    if (!_isLoadingRequest) {
        TransactionCartList *list = _list[section];
        
        [TPAnalytics trackRemoveProductsFromCart:_list];
        
        NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART,list.cart_shop.shop_name, list.cart_total_amount_idr];
        UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
        cancelCartAlert.tag = 11;
        [cancelCartAlert show];
        
        [_dataInput setObject:[NSIndexPath indexPathForRow:0 inSection:section] forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    }
}

-(void)didTapShopAtSection:(NSInteger)section
{
    if (_indexPage == 0) {
        TransactionCartList *list = _list[section];
        [NavigateViewController navigateToShopFromViewController:self withShopID:list.cart_shop.shop_id];
    }
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
    
    [TPAnalytics trackRemoveProductFromCart:product];
    
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

#pragma mark - PaymentDelegate
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    for (TransactionCartGateway *gateway in _cart.gateway_list) {
        if ([gateway.gateway_name isEqualToString:object]) {
            [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
            [_dataInput setObject:gateway.gateway forKey:API_GATEWAY_LIST_ID_KEY];
            [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:gateway.gateway_name];
        }
    }
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSNumber *gatewayID = gateway.gateway;
    
    if ([gatewayID integerValue] == TYPE_GATEWAY_TOKOPEDIA) {
        _saldoTokopediaAmountTextField.text = @"";
        
    }
    
    [self adjustGrandTotalWithDeposit:_saldoTokopediaAmountTextField.text];
    
    if (_isSelectBankInstallment) { //bank
        for (InstallmentBank *bank in _cartSummary.installment_bank_option) {
            if ([bank.bank_name isEqualToString:object]) {
                _selectedInstallmentBank = bank;
            }
        }
        _selectedInstallmentDuration = _selectedInstallmentBank.installment_term[0];
        [self adjustTotalPaymentInstallment];
        _isSelectBankInstallment = NO;
    }
    
    if (_isSelectDurationInstallment) { //duration
        for (InstallmentTerm *term in _selectedInstallmentBank.installment_term) {
            NSString *termNow = [NSString stringWithFormat:DurationInstallmentFormat,term.duration,term.monthly_price_idr];
            if ([termNow isEqualToString:object]) {
                _selectedInstallmentDuration = term;
                [self adjustTotalPaymentInstallment];
            }
        }
        _isSelectDurationInstallment = NO;
    }
    
    [_tableView reloadData];
}

-(void)adjustTotalPaymentInstallment{
    _cartSummary.conf_code = _selectedInstallmentDuration.admin_price;
    _cartSummary.conf_code_idr = _selectedInstallmentDuration.admin_price_idr;
}

-(void)adjustGrandTotalWithDeposit:(NSString*)deposit
{
    NSInteger voucher = [_voucherData.voucher_amount integerValue];
    NSInteger grandTotal = ([self isUseGrandTotalWithoutLP])?[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_WO_LP] integerValue]:[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_W_LP] integerValue];
    
    if (grandTotal<=voucher) {
        [_dataInput setObject:@(grandTotal) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    }
    else
    {
        [_dataInput setObject:@(voucher) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    }
    [_dataInput setObject:@(voucher) forKey:DATA_VOUCHER_AMOUNT];
    
    NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
    NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
    
    NSInteger depositAmount = [[deposit stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    if (voucherUsedAmount<voucherAmount) {
        voucherUsedAmount = voucherUsedAmount+ depositAmount;
        if (voucherUsedAmount>voucherAmount) {
            voucherUsedAmount = voucherAmount;
            depositAmount = voucherUsedAmount - voucherAmount;
        }
        else
        {
            depositAmount = 0;
        }
        [_dataInput setObject:@(depositAmount) forKey:DATA_USED_SALDO_KEY];
        [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    }
    
    
    NSInteger grandTotalInteger = grandTotal - depositAmount - voucherAmount;
    grandTotalInteger = (grandTotalInteger<0)?0:grandTotalInteger;
    
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
    
    _cart.grand_total_idr = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]];
    _cart.grand_total_without_lp = _cart.grand_total;
    _cart.grand_total_without_lp_idr = _cart.grand_total_idr;
    _grandTotalLabel.text = _cart.grand_total_without_lp_idr;
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

#pragma mark - Mandiri Klik Pay Form Delegate
-(void)TransactionCartMandiriClickPayForm:(TransactionCartFormMandiriClickPayViewController *)VC withUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    [self doRequestBuy];
}

-(void)doRequestCC:(NSDictionary *)param
{
    [_dataInput addEntriesFromDictionary:param];
    [self doRequestBuy];
}

-(void)isSucessSprintAsia:(NSDictionary *)param
{
    _cartBuy = [TransactionBuyResult new];
    _cartBuy.transaction = _cartSummary;
    _cartBuy.is_success = 1;
    NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy};
    [_delegate didFinishRequestBuyData:userInfo];
    [_dataInput removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activeTextField = textField;
    if (textField == _saldoTokopediaAmountTextField) {
        NSInteger grandTotal = [[[NSNumberFormatter IDRFormatter] numberFromString:_grandTotalLabel.text] integerValue];
        [_dataInput setObject:@(grandTotal) forKey:DATA_UPDATED_GRAND_TOTAL];
        _saldoErrorIcon.hidden = YES;
    }

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
    if (textField == _saldoTokopediaAmountTextField) {
        _saldoErrorIcon.hidden = YES;
        [_tableView reloadData];
    }
    if (textField == _passwordTextField) {
        [_dataInput setObject:textField.text?:@"" forKey:API_PASSWORD_KEY];
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
    
    if (textField == _saldoTokopediaAmountTextField) {
        if ([[NSNumberFormatter new] numberFromString:string] == nil && ![string isEqualToString:@""]) {
            return NO;
        }
        
        NSString *textFieldValue = [NSString stringWithFormat:@"%@%@", textField.text, string];
        
        NSInteger grandTotal = ([self isUseGrandTotalWithoutLP])?[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_WO_LP] integerValue]:[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];

        NSString *depositAmount = [textFieldValue stringByReplacingOccurrencesOfString:@"." withString:@""];
        [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];

        NSString *textFieldText = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];

        if (range.length > 0) {
            _saldoErrorIcon.hidden = YES;
            NSString *textFieldRemoveOneChar = [[textField.text substringToIndex:[textField.text length]-1] stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *depositAmount = [textFieldRemoveOneChar stringByReplacingOccurrencesOfString:@"." withString:@""];
            [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];
            [self adjustGrandTotalWithDeposit:textFieldRemoveOneChar];
            
        } else if ([textFieldText integerValue] <= grandTotal || [textFieldText integerValue] <= [self depositAmountUser]) {
            NSString *deposit = depositAmount;
            _saldoErrorIcon.hidden = YES;
            [self adjustGrandTotalWithDeposit:deposit];
            
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0) {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        } else {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""]) {
                num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            return YES;
        }
        
        [_tableView reloadData];
        
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
    
    if (_activeTextField == _passwordTextField) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_list.count+1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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

-(void)shouldDoRequestEMoney:(BOOL)isWSNew
{
    [self doRequestEmoney];
}

-(void)doRequestEmoney{
    [self isLoading:YES];
    
    [RequestCart fetchEMoneyCode:_cartBuy.transaction.emoney_code?:@""
                         success:^(TxEMoneyData *data) {
                             NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy?:@{}};
                             [_delegate didFinishRequestBuyData:userInfo];
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                             [self isLoading:NO];
                         } error:^(NSError *error) {
                             [_delegate shouldBackToFirstPage];
                             [self isLoading:NO];
                         }];
}

-(void)isLoading:(BOOL)isLoading{
    _isLoadingRequest = isLoading;
    _checkoutButton.enabled = !isLoading;
    _buyButton.enabled = !isLoading;
    if (isLoading) {
        [[self alertLoading] show];
    } else{
        if (_refreshControl.isRefreshing) {
            _tableView.contentOffset = CGPointZero;
            [_refreshControl endRefreshing];
        }
        if (_list.count>0) {
            _tableView.tableFooterView = (_indexPage == 1)?_buyView:_checkoutView;
        } else _tableView.tableFooterView = nil;
        [[self alertLoading] dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)shouldDoRequestBCAClickPay
{
    [self doRequestBCAClickPay];
}

-(void)doRequestBCAClickPay{
    [self isLoading:YES];
    [RequestCart fetchBCAClickPaySuccess:^(TransactionBuyResult *data) {
        
        NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:data?:[TransactionBuyResult new]};
        [_delegate didFinishRequestBuyData:userInfo?:@{}];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        [self isLoading:NO];
    } error:^(NSError *error) {
        [_delegate shouldBackToFirstPage];
        [self isLoading:NO];
    }];
}

-(void)shouldDoRequestBRIEPayCode:(NSString *)code
{
    [self isLoading:YES];
    
    [RequestCart fetchBRIEPayCode:code success:^(TransactionActionResult *data) {
        
        TransactionBuyResult *BRIEPay = [TransactionBuyResult new];
        BRIEPay.transaction = _cartSummary;
        
        NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:BRIEPay?:[TransactionBuyResult new]};
        [_delegate didFinishRequestBuyData:userInfo?:@{}];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        [self isLoading:NO];
    } error:^(NSError *error) {
        [_delegate shouldBackToFirstPage];
        [self isLoading:NO];
    }];
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
    [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    [self requestCartData];
    _paymentMethodView.hidden = YES;
}

-(void)doClearAllData
{
    _indexPage = 0;
    [_delegate isNodata:NO];
    [_dataInput removeAllObjects];
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
    [_list removeAllObjects];
    
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"Pilih"];
    
    _saldoTokopediaAmountTextField.text = @"";
    
    _voucherCodeButton.hidden = NO;
    _voucherAmountLabel.hidden = YES;
    _buttonVoucherInfo.hidden = NO;
    _buttonCancelVoucher.hidden = YES;
    
    _saldoTokopediaAmountTextField.text = @"";
    _userIDKlikBCATextField.text = @"";
    
    _selectedInstallmentBank = nil;
    _selectedInstallmentDuration = nil;
    _voucherData = nil;
    _tableView.tableFooterView = nil;
    
    [_tableView reloadData];
}

-(void)swipeView:(UIView*)view{
    CGAffineTransform tr = CGAffineTransformTranslate(view.transform, -40, 0);
    view.transform = tr;
    
    [UIView animateWithDuration:2.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0f options:0 animations:^{
        view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setDefaultInputData
{
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
}


-(void)adjustAfterUpdateList
{
    [self adjustPaymentMethodView];
    [_delegate isNodata:(_list.count==0)];
    
    [self adjustPaymentMethodView];
    [_dataInput setObject:_cart.grand_total?:@"" forKey:DATA_UPDATED_GRAND_TOTAL];
    
    NSNumber *grandTotal = [_dataInput objectForKey:DATA_UPDATED_GRAND_TOTAL];
    NSInteger deposit = [[[NSNumberFormatter IDRFormatter] numberFromString:_saldoTokopediaAmountTextField.text] integerValue];
    NSString *voucher = [_dataInput objectForKey:DATA_VOUCHER_AMOUNT];
    
    NSInteger totalInteger = [grandTotal integerValue];
    totalInteger -= [voucher integerValue];
    if (totalInteger<0) {
        totalInteger = 0;
    }
    
    NSInteger grandTotalInteger = 0;
    NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
    NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
    NSInteger grandTotalCartFromWS = ([self isUseGrandTotalWithoutLP])?[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL_WO_LP] integerValue]:[[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
    
    if (grandTotalCartFromWS<voucherAmount) {
        voucherUsedAmount = grandTotalCartFromWS;
        if (voucherUsedAmount>voucherAmount) {
            voucherUsedAmount = voucherAmount;
        }
    }
    
    grandTotalInteger = totalInteger;
    [_dataInput setObject:@(grandTotalCartFromWS) forKey:DATA_UPDATED_GRAND_TOTAL];
    [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    
    grandTotalInteger -= deposit;
    if (grandTotalInteger <0) {
        grandTotalInteger = 0;
    }
    
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
    
    _cart.grand_total_idr = [[NSNumberFormatter IDRFormatter] stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]];
    
    _cart.grand_total_without_lp = _cart.grand_total;
    _cart.grand_total_without_lp_idr = _cart.grand_total_idr;
    
    [_tableView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    
}

- (IBAction)switchUsingSaldo:(id)sender {
    [self changeSwitchSaldo:sender];
}


#pragma mark - Footer View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section < _list.count)
    {
        TransactionCartHeaderView *headerView = [TransactionCartHeaderView newview];
        [headerView setViewModel:_list[section].viewModel page:_indexPage section:section delegate:self];
        return headerView;
    }
    else
    {
        return nil;
    }
}

-(NSInteger)LPAmount
{
    NSInteger LPAmount = (_indexPage==0)?[_cart.lp_amount integerValue]:[_cartSummary.lp_amount integerValue];
    return LPAmount;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (_indexPage == 0) {
        return [self FirstPageCartfooterViewAtSection:section];
    }
    if (_indexPage == 1) {
        return [self SecondPageCartfooterViewAtSection:section];
    }
    return nil;
}

-(UIView *)FirstPageCartfooterViewAtSection:(NSInteger)section
{
    if (section < _list.count)
    {
        return [self CartSubTotalViewAtSection:section];
    }
    return nil;
}

-(UIView *)SecondPageCartfooterViewAtSection:(NSInteger)section
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
        cell = [CartCell cellCart:[_list copy] tableView:_tableView atIndexPath:newIndexPath page:_indexPage];
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
    //0 Kode Promo Tokopedia?, 1 LPCell 2 Total invoice, 3 Saldo Tokopedia Terpakai, 4 Voucher terpakai 5 Kode Transfer, 6. Biaya Administrasi, 7 Total Pembayaran
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = _voucerCell;
            break;
        case 1:
        {
            cell = _usedLP1Cell;
            NSString *LPAmountStr = (_indexPage==0)?[NSString stringWithFormat:@"(%@)",_cart.lp_amount_idr]:[NSString stringWithFormat:@"(%@)",_cartSummary.lp_amount_idr];
            cell.detailTextLabel.text = LPAmountStr;
        }
            break;
        case 2:
            cell = _totalInvoiceCell;
            cell.detailTextLabel.text =_cartSummary.grand_total_before_fee_idr;
            break;
        case 3:
        {
            cell = _usedSaldoCell;
            NSString *usedDeposit = [NSString stringWithFormat:@"(%@)",_cartSummary.deposit_amount_idr];
            [cell.detailTextLabel setText:usedDeposit];
        }
            break;
        case 4:
        {
            cell = _voucherUsedCell;
            NSString *usedVoucher = [NSString stringWithFormat:@"(%@)",_cartSummary.voucher_amount_idr];
            [cell.detailTextLabel setText:usedVoucher];
            break;
        }
        case 5:
            cell = _transferCodeCell;
            [_transferCodeLabel setText:_cartSummary.conf_code_idr];
            break;
        case 6:
        {
            cell = _ccAdministrationCell;
            NSString *administrationFeeStr = _cartSummary.credit_card.charge_idr?:@"Rp 0";
            TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
            if ([_cartSummary.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT) {
                [cell.detailTextLabel setText:_cartSummary.conf_code_idr?:@"Rp 0"];
            }
            else [cell.detailTextLabel setText:administrationFeeStr];
        }
            break;
        case 7:
        {
            cell = _usedLPCell;
            NSString *LPAmountStr = (_indexPage==0)?[NSString stringWithFormat:@"(%@)",_cart.lp_amount_idr]:[NSString stringWithFormat:@"(%@)",_cartSummary.lp_amount_idr];
            cell.detailTextLabel.text = LPAmountStr;
            break;
        }
        case 8:
        {
            cell = _totalPaymentDetail;
            NSString *paymentLeft = _cartSummary.payment_left_idr?:@"Rp 0";
            if([_cartSummary.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT){
                paymentLeft = _selectedInstallmentDuration.total_price_idr;
            }
            [cell.detailTextLabel setText:paymentLeft animated:YES];
            break;
        }
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
            cell.detailTextLabel.text = (_indexPage == 0)?_cart.cashback_idr:_cartSummary.cashback_idr?:@"Rp 0";
            break;
            
        default:
            break;
    }
    return cell;
}

-(UITableViewCell*)cellAdjustDepositAtIndexPath:(NSIndexPath*)indexPath
{
    // 0 saldo tokopedia, 1 textfield saldo, 2 password tokopedia, 3 Deposit ammount, 4 userID klik BCA
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = _saldoTokopediaCell;
            break;
        case 1:
            cell = _saldoTextFieldCell;
            break;
        case 2:
            cell = _depositAmmountCell;
            _depositAmountLabel.text = [NSString stringWithFormat:@"(Saldo Tokopedia anda %@)", _cart.deposit_idr];
            break;
        case 3:
            cell = _passwordCell;
            break;
        case 4:
            cell = _klikBCAUserIDCell;
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
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    
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
    else if (indexPath.section == _list.count+2)
    {
        //0 saldo tokopedia, 1 textfield saldo, 2 deposit amount, 3 password tokopedia, 4. userID klik BCA
        if (indexPath.row == 0 || indexPath.row == 2) {
            if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] ||
                ([self depositAmountUser] == 0) ) {
                return 0;
            }
        }
        if (indexPath.row == 1 ) {
            if (!_isUsingSaldoTokopedia ||
                [selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)]||
                ([self depositAmountUser] == 0)) {
                return 0;
            }
        }
        if (indexPath.row == 2) {
            if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] ||
                ([self depositAmountUser] == 0) ) {
                return 0;
            }
            else
                return HEIGHT_VIEW_TOTAL_DEPOSIT;
        }
        if (indexPath.row == 3) {
            return 0;
        }
        if (indexPath.row == 4) {
            return 0;
        }
    }
    else
    {
        if (indexPath.row == 1) {
            if ([selectedGateway.gateway integerValue] != TYPE_GATEWAY_CC &&
                [selectedGateway.gateway integerValue] != TYPE_GATEWAY_INDOMARET) {
                return 0;
            }
        }
    }
    
    return DEFAULT_ROW_HEIGHT;
}

-(CGFloat)rowHeightPage2AtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section < _list.count) {
        TransactionCartList *list = _list[indexPath.section];
        if (indexPath.row == 0)
            return [self errorLabelHeight:list];
        else if(indexPath.row <= list.cart_products.count) {
            ProductDetail *product = list.cart_products[indexPath.row-1];
            return [self productRowHeight:product];
        }
        else if ( indexPath.row == list.cart_products.count + 2) {
            //partial
            return 0;
        }
        else if ( indexPath.row == list.cart_products.count + 3) {
            //dropship switch
            return 0;
        }
        else if (indexPath.row == list.cart_products.count + 4)
        {
            // dropship name
            return 0;
        }
        else if (indexPath.row == list.cart_products.count + 5)
        {
            // dropship phone
            return 0;
        }
    }
    else if (indexPath.section == _list.count)
    {
        if ([_cartSummary.cashback integerValue] == 0) {
            return 0;
        }
    }
    else if (indexPath.section == _list.count+1)
    {
        //0 Kode Promo Tokopedia?, 1 lpCELL 2 Total invoice, 3 Saldo Tokopedia Terpakai, 4 Voucher terpakai5 Kode Transfer, 6 Biaya Administrasi, 7 lpCELL, 8 Total Pembayaran
        if (indexPath.row == 0)
        {
            return 0;
        }
        if (indexPath.row == 1) {
            return 0;
        }
        if (indexPath.row == 3)
        {
            if ([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TOKOPEDIA &&
                [_cartSummary.deposit_amount integerValue] <= 0) {
                return 0;
            }
        }
        if (indexPath.row == 4) {
            if ([_cartSummary.voucher_amount integerValue]<=0) {
                return 0;
            }
        }
        if (indexPath.row == 5) {
            if ([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TRANSFER_BANK)
                return 0;
            else return 91;
        }
        if (indexPath.row == 6) {
            if ([_cartSummary.gateway integerValue] == TYPE_GATEWAY_CC || ([_cartSummary.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT && [_cartSummary.conf_code integerValue] != 0)) {
                return 44;
            }
            else
                return 0;
        }
        if (indexPath.row == 7) {
            if ([_cartSummary.lp_amount integerValue] == 0) {
                return 0;
            }
        }

    }
    else if (indexPath.section == _list.count+2)
    {
        //0 saldo tokopedia, 1 textfield saldo, 2 deposit amount, 3 password tokopedia, 4 userID klik BCA
        if (indexPath.row == 0)
        {
            return 0;
        }
        if (indexPath.row == 1)
        {
            return 0;
        }
        if (indexPath.row == 2)
        {
            return 0;
        }
        if (indexPath.row == 3)
        {
            if (([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TOKOPEDIA &&
                [_cartSummary.deposit_amount integerValue] <= 0)||
                [_cartSummary.gateway integerValue] == TYPE_GATEWAY_CC ||
                [_cartSummary.gateway integerValue] == TYPE_GATEWAY_INSTALLMENT || [self isHalfDepositAndPaymentInstantWithPaymentGatewayIntegerValue:[_cartSummary.gateway integerValue]] ) {
                return 0;
            }
        }
        if (indexPath.row == 4) {
            if ([_cartSummary.gateway integerValue] == TYPE_GATEWAY_BCA_KLIK_BCA) {
                return 145;
            }
            else
                return 0;
        }
    }
    else if (indexPath.section == _list.count+3)
    {
        return 0;
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
    [TPAnalytics trackPaymentEvent:@"clickBack" category:@"Payment" action:@"Abandon" label:@"Thank You Page"];
    [RequestCart fetchToppayThanksCode:paymentID
                               success:^(TransactionActionResult *data) {
                                   if (data.is_success == 1) {
                                       NSDictionary *parameter = data.parameter;
                                       NSString *paymentMethod = [parameter objectForKey:@"gateway_name"]?:@"";
                                       NSNumber *revenue = [[NSNumberFormatter IDRFormatter] numberFromString:[parameter objectForKey:@"order_open_amt"]];
                                       
                                       [TPAnalytics trackScreenName:[NSString stringWithFormat:@"Thank you page - %@", paymentMethod]];
                                       
                                       [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{AFEventParamRevenue : [revenue stringValue]?:@"",
                                                                                                                 AFEventParamContentType : @"Product",
                                                                                                                 AFEventParamContentId : [NSString jsonStringArrayFromArray:productIDs]?:@"",
                                                                                                                 AFEventParamQuantity : [@(quantity) stringValue]?:@"",
                                                                                                                 AFEventParamCurrency : param[@"currency"]?:@"",
                                                                                                                 AFEventOrderId : paymentID}];
                                       
                                       [Localytics tagEvent:@"Event : Finished Transaction"
                                                 attributes:@{
                                                              @"Payment Method" : paymentMethod,
                                                              @"Total Transaction" : [revenue stringValue]?:@"",
                                                              @"Total Quantity" : [@(quantity) stringValue]?:@"",
                                                              @"Total Shipping Fee" : @""
                                                              }
                                      customerValueIncrease:revenue];
                                       
                                       [Localytics incrementValueBy:0
                                                forProfileAttribute:@"Profile : Total Transaction"
                                                          withScope:LLProfileScopeApplication];
                                   }
                                   [self requestCartData];
                               } error:^(NSError *error) {
                                [self requestCartData];
                                     
                                 }];
    

}

-(void)requestCartData{
    
    if ([((UILabel*)_selectedPaymentMethodLabels[0]).text isEqualToString:@"Pilih"])
    {
        [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
    }
    
    _isLoadingRequest = YES;
    _checkoutButton.enabled = NO;
    _buyButton.enabled = NO;
    
    [RequestCart fetchCartData:^(TransactionCartResult *data) {
        [_noInternetConnectionView removeFromSuperview];
        _saldoTokopediaCell.contentView.backgroundColor = [UIColor whiteColor];
        _saldoTextFieldCell.contentView.backgroundColor = [UIColor whiteColor];
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
        
        [self adjustAfterUpdateList];
        
        [self isLoading:NO];
        [TPLocalytics trackCartView:_cart];
        
    } error:^(NSError *error) {
        [_noResultView removeFromSuperview];
        [_noInternetConnectionView generateRequestErrorViewWithError:error];
        [_tableView addSubview:_noInternetConnectionView];
        _paymentMethodView.hidden = YES;
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
                newCart.cart_destination.address_id == cart.cart_destination.address_id &&
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
                                [_refreshControl beginRefreshing];
                                [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
                                _paymentMethodView.hidden = YES;
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
        
        [self adjustGrandTotalWithDeposit:_saldoTokopediaAmountTextField.text];
        [self isLoading:NO];
        [_tableView reloadData];
    } error:^(NSError *error) {
        [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
        [self isLoading:NO];
    }];
}

-(void)doCheckout{
    [self isLoading:YES];
    
    [self adjustDropshipperListParam];
    
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSNumber *gatewayID = gateway.gateway;
    
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
    
    [RequestCart fetchCheckoutToken:_cart.token
                          gatewayID:[gatewayID stringValue]
                       listDropship:[dropshipStrList copy]
                     dropshipDetail:dropshipperDetail
                        listPartial:[partialStrList copy]
                      partialDetail:partialDetail
                       isUsingSaldo:_isUsingSaldoTokopedia
                              saldo:_saldoTokopediaAmountTextField.text
                        voucherCode:voucherCode
                            success:^(TransactionSummaryResult *data) {
                                
                                _cartSummary = data.transaction;
                                [TPAnalytics trackCheckout:_cartSummary.carts step:1 option:_cartSummary.gateway_name];
                                [self setDataDropshipperCartSummary];
                                
                                TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
                                NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:_cartSummary?:[TransactionSummaryDetail new],
                                                           DATA_TYPE_KEY:@(TYPE_CART_SUMMARY),
                                                           DATA_CART_GATEWAY_KEY :selectedGateway?:[TransactionCartGateway new],
                                                           DATA_CC_KEY : data.credit_card_data?:[CCData new],
                                                           API_VOUCHER_CODE_KEY: [_dataInput objectForKey:API_VOUCHER_CODE_KEY]?:@""
                                                           };
                                [_delegate didFinishRequestCheckoutData:userInfo];
                                [self isLoading:NO];
                            } error:^(NSError *error) {
                                if (error) {
                                    [self doClearAllData];
                                    [_refreshControl beginRefreshing];
                                    [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
                                    _paymentMethodView.hidden = YES;
                                    [_noInternetConnectionView generateRequestErrorViewWithError:error];
                                    [_tableView addSubview:_noInternetConnectionView];
                                }
                                
                                [self isLoading:NO];
                            }];
}

-(void)doCheckoutWithToppay{
    
    [self isLoading:YES];
    
    [self adjustDropshipperListParam];
    
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSNumber *gatewayID = gateway.gateway;
    
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
                            gatewayID:[gatewayID stringValue]
                         listDropship:[dropshipStrList copy]
                       dropshipDetail:dropshipperDetail
                          listPartial:[partialStrList copy]
                        partialDetail:partialDetail
                         isUsingSaldo:_isUsingSaldoTokopedia
                                saldo:_saldoTokopediaAmountTextField.text
                          voucherCode:voucherCode 
							  success:^(TransactionActionResult *data) {
                              
                              [TransactionCartWebViewViewController pushToppayFrom:self data:data gatewayID:0 gatewayName:gateway.gateway_name];
                              _popFromToppay = YES;
                              [self isLoading:NO];

                          } error:^(NSError *error) {
                              if (error) {
                                  [self doClearAllData];
                                  [_refreshControl beginRefreshing];
                                  [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
                                  _paymentMethodView.hidden = YES;
                                  [_noInternetConnectionView generateRequestErrorViewWithError:error];
                                  [_tableView addSubview:_noInternetConnectionView];
                                  
                              }
                              [self isLoading:NO];
                          }];
}

-(void)doRequestBuy{
    _buyButton.enabled = NO;
    [self isLoading:YES];
    
    NSString *mandiriToken = [_dataInput objectForKey:API_MANDIRI_TOKEN_KEY]?:@"";
    NSString *cardNumber = [_dataInput objectForKey:API_CARD_NUMBER_KEY]?:@"";
    NSString *password = _passwordTextField.text?:@"";
    NSString *userIDKlikBCA = _userIDKlikBCATextField.text?:@"";
    
    [RequestCart fetchBuy:_cartSummary
                   dataCC:_dataInput
             mandiriToken:mandiriToken
               cardNumber:cardNumber
                 password:password
            klikBCAUserID:userIDKlikBCA
                  success:^(TransactionBuyResult *data) {
                      
                      NSArray <TransactionCartList *> *carts = data.transaction.carts;
                      NSMutableArray *productIDs = [NSMutableArray new];
                      NSInteger quantity = 0;
                      
                      for (TransactionCartList *cart in carts) {
                          NSArray <ProductDetail *> *products = cart.cart_products;
                          for (ProductDetail *product in products) {
                              [productIDs addObject:product.product_id];
                          }
                          quantity = quantity + [cart.cart_total_product integerValue];
                      }
                      
                      [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{AFEventParamRevenue : data.transaction.grand_total?:@"",
                                                                                                AFEventParamContentType : @"Product",
                                                                                                AFEventParamContentId : [NSString jsonStringArrayFromArray:productIDs]?:@"",
                                                                                                AFEventParamQuantity : [@(quantity) stringValue]?:@"",
                                                                                                AFEventParamCurrency : @"IDR",
                                                                                                AFEventOrderId : data.transaction.payment_id?:@""}];
                      
                      TransactionSummaryDetail *summary = data.transaction;
                      [TPAnalytics trackCheckout:summary.carts step:2 option:summary.gateway_name];
                      
                      _cartBuy = data;
                      NSDictionary *userInfo = @{
                                                 DATA_CART_RESULT_KEY:data,
                                                 API_VOUCHER_CODE_KEY: [_data objectForKey:API_VOUCHER_CODE_KEY]
                                                 };
                      [self.delegate didFinishRequestBuyData:userInfo];
                      [_dataInput removeAllObjects];
                      [self isLoading:NO];
                  } error:^(NSError *error) {
                      if (error) {
                          [self doClearAllData];
                          [_refreshControl beginRefreshing];
                          [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
                          _paymentMethodView.hidden = YES;
                          [_noInternetConnectionView generateRequestErrorViewWithError:error];
                          [_tableView addSubview:_noInternetConnectionView];
                      }
                      [self isLoading:NO];
                  }];
}

-(void)doRequestEditProduct:(ProductDetail*)product{
    [RequestCart fetchEditProduct:product
                          success:^(TransactionAction *data) {
                              if (_indexPage == 0) {
                                  [self requestCartData];
                              }
                              [_tableView reloadData];
                          } error:^(NSError *error) {
                              if (error) {
                                  [self doClearAllData];
                                  [_refreshControl beginRefreshing];
                                  [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
                                  _paymentMethodView.hidden = YES;
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

#pragma mark - Conditional Status Helper

- (Boolean) isHalfDepositAndPaymentInstantWithPaymentGatewayIntegerValue: (NSInteger) integerValue {
    if (integerValue == TYPE_GATEWAY_BRI_EPAY
        || integerValue == TYPE_GATEWAY_MANDIRI_E_CASH
        || integerValue == TYPE_GATEWAY_BCA_CLICK_PAY
        || integerValue == TYPE_GATEWAY_INSTALLMENT
        || integerValue == TYPE_GATEWAY_CC
        || integerValue == TYPE_GATEWAY_MANDIRI_CLICK_PAY) {
        return YES;
    }
    
    return NO;
}

@end
