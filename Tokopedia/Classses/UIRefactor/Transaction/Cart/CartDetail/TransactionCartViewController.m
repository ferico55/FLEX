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

#import "TransactionObjectMapping.h"

#import "TransactionCartViewController.h"
#import "TransactionCartCell.h"
#import "TransactionCartHeaderView.h"
#import "GeneralSwitchCell.h"
#import "TransactionCartCostView.h"
#import "TransactionCartEditViewController.h"
#import "TransactionCartShippingViewController.h"
#import "AlertPickerView.h"
#import "TransactionCartFormMandiriClickPayViewController.h"
#import "TransactionCartWebViewViewController.h"
#import "AlertInfoView.h"
#import "StickyAlertView.h"
#import "GeneralTableViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceFields.h"

#import "TransactionObjectManager.h"
#import "RequestCart.h"

#import "LoadingView.h"

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
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate,
    RequestCartDelegate
>
{
    NSMutableArray *_list;
    
    TransactionCartResult *_cart;
    TransactionSummaryDetail *_cartSummary;
    TransactionBuyResult *_cartBuy;
    
    NSMutableDictionary *_dataInput;
    
    BOOL _isnodata;

    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    UIRefreshControl *_refreshControl;
    
    BOOL _isaddressexpanded;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    NSMutableArray *_isDropshipper;
    NSMutableArray *_stockPartialDetail;
    NSMutableArray *_stockPartialStrList;
    
    NSMutableArray *_senderNameDropshipper;
    NSMutableArray *_senderPhoneDropshipper;
    NSMutableArray *_dropshipStrList;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    BOOL _isUsingSaldoTokopedia;
    
    TransactionObjectMapping *_mapping;
    BOOL _isLoadingRequest;
    
    BOOL _refreshFromShipment;
    BOOL _popFromShipment;
    
    NavigateViewController *_navigate;
    
    NSString *_saldoTokopedia;
    NSIndexPath *_switchSaldoIndexPath;
    
    NSMutableDictionary *_textAttributes;
    
    NSInteger _indexSelectedShipment;
    
    NSNumberFormatter *_IDRformatter;
    
    TransactionObjectManager *_objectManager;
    
    RequestCart *_requestCart;
    
    UIAlertView *_alertLoading;
    
    LoadingView *_loadingView;
    
}
@property (weak, nonatomic) IBOutlet UIView *paymentMethodView;
@property (weak, nonatomic) IBOutlet UIView *paymentMethodSelectedView;
@property (weak, nonatomic) IBOutlet UIButton *choosePaymentButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *selectedPaymentMethodLabels;

@property (weak, nonatomic) IBOutlet UIView *voucerCodeBeforeTapView;
@property (weak, nonatomic) IBOutlet UIButton *voucherCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *voucherAmountLabel;

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

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *saldoTokopediaCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet UIButton *buttonVoucherInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancelVoucher;
@property (strong, nonatomic) IBOutlet UITableViewCell *depositAmmountCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentDetail;
@property (weak, nonatomic) IBOutlet UILabel *depositAmountLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucherUsedCell;

- (IBAction)tap:(id)sender;
@end

#define TAG_ALERT_PARTIAL 13
#define DATA_PARTIAL_SECTION @"data_partial"
#define DATA_CART_GRAND_TOTAL @"cart_grand_total"
#define DATA_CART_GRAND_TOTAL_BEFORE_DECREASE @"data_grand_total"
#define DATA_VOUCHER_AMOUNT @"data_voucher_amount"
#define DATA_CART_USED_VOUCHER_AMOUNT @"data_used_voucher_amount"
#define DATA_DETAIL_CART_FOR_SHIPMENT @"data_detail_cart_fort_shipment"

#define HEIGHT_VIEW_SUBTOTAL 156
#define HEIGHT_VIEW_TOTAL_DEPOSIT 30
#define DEFAULT_ROW_HEIGHT 44
#define CELL_PRODUCT_ROW_HEIGHT 212

#define TAG_REQUEST_CART 10
#define TAG_REQUEST_CANCEL_CART 11
#define TAG_REQUEST_CHECKOUT 12
#define TAG_REQUEST_BUY 13
#define TAG_REQUEST_VOUCHER 14
#define TAG_REQUEST_EDIT_PRODUCT 15
#define TAG_REQUEST_EMONEY 16
#define TAG_REQUEST_BCA_CLICK_PAY 17

#define NOT_SELECT_GATEWAY -1

@implementation TransactionCartViewController
@synthesize indexPage =_indexPage;
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _isDropshipper = [NSMutableArray new];
    _stockPartialStrList = [NSMutableArray new];
    _senderNameDropshipper = [NSMutableArray new];
    _senderPhoneDropshipper = [NSMutableArray new];
    _dropshipStrList = [NSMutableArray new];
    _stockPartialDetail = [NSMutableArray new];
    _objectManager = [TransactionObjectManager new];
    _mapping = [TransactionObjectMapping new];
    _navigate = [NavigateViewController new];
    _requestCart = [RequestCart new];
    _requestCart.viewController = self;
    _requestCart.delegate = self;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
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
        
        _requestCart.param = @{};
        [_requestCart doRequestCart];
        
        //[_networkManager doRequest];
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    
    _textAttributes = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                      NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                                                      NSParagraphStyleAttributeName  : style,
                                                                      NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                                                      }];
    
    _saldoTokopediaAmountTextField.delegate = self;
    
    _checkoutButton.layer.cornerRadius = 2;
    _checkoutButton.layer.opacity = 1;
    
    _buyButton.layer.cornerRadius = 2;
    _buyButton.layer.opacity = 1;
    
    [self setDefaultInputData];
    
    _popFromShipment = NO;
    
    _IDRformatter = [[NSNumberFormatter alloc] init];
    _IDRformatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _IDRformatter.currencyCode = @"Rp ";
    _IDRformatter.currencyGroupingSeparator = @".";
    _IDRformatter.currencyDecimalSeparator = @",";
    _IDRformatter.maximumFractionDigits = 0;
    _IDRformatter.minimumFractionDigits = 0;
    
    _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];

    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_indexPage == 0) {
        TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
        [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
    }
    else
    {
        if (!_popFromShipment) {
            [_tableView setContentOffset:CGPointMake(0, -40) animated:YES];
        }
        if (_popFromShipment) {
            _popFromShipment = NO;
        }
        
        [self adjustTableViewData:_data];
        _passwordTextField.text = @"";
        TransactionCartGateway *selectedGateway = [_data objectForKey:DATA_CART_GATEWAY_KEY];
        [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
    }
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    if(!_isnodata) _tableView.tableFooterView = _isnodata?nil:(_indexPage==1)?_buyView:_checkoutView;

    _tableView.scrollsToTop = YES;
    
    if (_isnodata) {
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
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;

    self.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count + 3;
    return _isnodata?0:sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger listCount = _list.count;
    NSInteger rowCount;
    
    if (section == listCount) {
        rowCount = 6; // Kode Promo Tokopedia, Total invoice, Saldo Tokopedia Terpakai, Kode Transfer, Voucher, Total Pembayaran
    }
    else if (section < listCount) {
        TransactionCartList *list = _list[section];
        NSArray *products = list.cart_products;
        rowCount = products.count+6; //ErrorMessage, Detail Pengiriman, Partial, Dropshipper, dropshipper name, dropshipper phone
    }
    else if (section == listCount+1)
        rowCount = 4; //saldo tokopedia, textfield saldo, deposit amount, password tokopedia
    else rowCount = 1; // total pembayaran
    
    return _isnodata?0:rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;

    NSInteger shopCount = _list.count;

    if (indexPath.section <shopCount)
        cell = [self cellListCartByShopAtIndexPath:indexPath];
    else if (indexPath.section == shopCount)
        cell = [self cellPaymentInformationAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+1)
        cell = [self cellAdjustDepositAtIndexPath:indexPath];
    else
    {
        cell = _totalPaymentCell;
        [cell.detailTextLabel setText:(_indexPage ==0)?_cart.grand_total_idr:_cartSummary.payment_left_idr animated:YES];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, cell.contentView.frame.size.width,1)];
    if (indexPath.section != shopCount+1) {
        lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
        [cell.contentView addSubview:lineView];
    }
    if (indexPath.section<_list.count) {
        TransactionCartList *list = _list[indexPath.section];
        NSArray *products = list.cart_products;
        NSInteger productCount = products.count;
        if (indexPath.section <shopCount && indexPath.row <=productCount) {
            [lineView removeFromSuperview];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width,1)];
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
    if (!_isnodata)
    {
        return (_indexPage==0)?[self rowHeightPage1AtIndexPath:indexPath]:[self rowHeightPage2AtIndexPath:indexPath];
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isnodata) {
        return 0;
    }
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

    if (section < _list.count) return 44;
    else if (section == _list.count+1)
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
    
    if (_isnodata) {
        return 0;
    }
    
    NSInteger listCount = _list.count;
    
    if (section < listCount)
        return HEIGHT_VIEW_SUBTOTAL;
    else if(section == listCount+1)
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

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Detail Pengiriman"]) {
        [self pushShipmentIndex:indexPath.section];
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

-(void)pushShipmentIndex:(NSInteger)index
{
    NSString *dropshipName = @"";
    NSString *dropshipPhone = @"";
    NSString *partial = @"";
    TransactionCartList *list = _list[index];
    if (_indexPage == 1) {
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *dropshipStringObjectFormat = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_CART_SUMMARY_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        NSString *partialStringObjectFormat = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_CART_SUMMARY_KEY,shopID,addressID,shipmentPackageID];
        
        NSDictionary *dropshipList = _cartSummary.dropship_list;
        for (int i = 0; i<[dropshipList allKeys].count; i++) {
            if ([[dropshipList allKeys][i] isEqualToString:dropshipStringObjectFormat]) {
                dropshipName = [[dropshipList objectForKey:dropshipStringObjectFormat]objectForKey:@"name"]?:@"";
                dropshipPhone = [[dropshipList objectForKey:dropshipStringObjectFormat]objectForKey:@"telp"]?:@"";
                break;
            }
        }
        
        NSDictionary *partialList = _cartSummary.data_partial;
        for (int i = 0; i<[partialList allKeys].count; i++) {
            if ([[partialList allKeys][i] isEqualToString:partialStringObjectFormat]) {
                partial = @"Ya";
                break;
            }
        }
    }

    TransactionCartShippingViewController *shipmentViewController = [TransactionCartShippingViewController new];
    shipmentViewController.data = @{DATA_CART_DETAIL_LIST_KEY:list,
                                    DATA_DROPSHIPPER_NAME_KEY: dropshipName,
                                    DATA_DROPSHIPPER_PHONE_KEY:dropshipPhone,
                                    DATA_PARTIAL_LIST_KEY :partial,
                                    DATA_INDEX_KEY : @(index)
                                    };
    [_dataInput setObject:list forKey:DATA_DETAIL_CART_FOR_SHIPMENT];
    _indexSelectedShipment = index;
    shipmentViewController.indexPage = _indexPage;
    shipmentViewController.delegate = self;
    [self.navigationController pushViewController:shipmentViewController animated:YES];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [_delegate shouldBackToFirstPage];
    }
    else {
        if (_indexPage==0){
            UIButton *button = (UIButton*)sender;
            switch (button.tag) {
                case 10:{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kode Kupon"
                                                                    message:@"Masukan kode kupon"
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
                    alertInfo.text = @"Info Kode Kupon Tokopedia";
                    alertInfo.detailText = @"Hanya berlaku untuk satu kali pembayaran. Sisa nilai kupon tidak dapat dikembalikan";
                    [alertInfo show];
                }
                case 12:
                {
                    _voucherCodeButton.hidden = NO;
                    _voucherAmountLabel.hidden = YES;
                    _buttonCancelVoucher.hidden = YES;
                    _buttonVoucherInfo.hidden = NO;
                    
                    NSString *voucher = [_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT];
                    NSInteger grandTotalFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
                    
                    NSString *grandTotal = [_grandTotalLabel.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                    grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
                    grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSInteger totalInteger = [grandTotal integerValue];
                    
                    if (totalInteger>=[voucher integerValue]) {
                        voucher = [_dataInput objectForKey:DATA_VOUCHER_AMOUNT];
                    }
                    
                    if ([voucher integerValue] == grandTotalFromWS) {
                        NSInteger depositAmount = [[_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
                        
                        totalInteger -= depositAmount;
                    }
                    
                    totalInteger += [voucher integerValue];

                    
                    _cart.grand_total = [NSString stringWithFormat:@"%zd", totalInteger];
                    _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:totalInteger]] stringByAppendingString:@",-"];
                    
                    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
                    
                    [_dataInput setObject:@"" forKey:API_VOUCHER_CODE_KEY];
                    [_dataInput setObject:@(0) forKey:DATA_VOUCHER_AMOUNT];
                    [_dataInput setObject:@"" forKey:DATA_CART_USED_VOUCHER_AMOUNT];
                    [_tableView reloadData];
                }
                    break;
                default:
                    if([self isValidInput]) {
                        [self sendingProductDataToGA];
                        _requestCart.param = [self paramCheckout];
                        [_requestCart doRequestCheckout];
                    }
                break;
            }
        }
        if(_indexPage==1)
        {
            switch ([_cartSummary.gateway integerValue]) {
                case TYPE_GATEWAY_TOKOPEDIA:
                {
                    if ([self isValidInput]) {
                        _requestCart.param = [self paramBuy];
                        [_requestCart dorequestBuy];
                        
                    }
                }
                break;
                case TYPE_GATEWAY_TRANSFER_BANK:
                    _requestCart.param = [self paramBuy];
                    [_requestCart dorequestBuy];
                    
                    break;
                case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                {
                    NSDictionary *data = @{DATA_KEY:_dataInput,
                                           DATA_CART_SUMMARY_KEY: _cartSummary
                                           };
                    [_delegate pushVC:self toMandiriClickPayVCwithData:data];
                }
                    break;
                case TYPE_GATEWAY_CLICK_BCA:
                {
                    TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
                    vc.BCAParam = _cartSummary.bca_param;
                    vc.gateway = @(TYPE_GATEWAY_CLICK_BCA);
                    vc.token = _cartSummary.token;
                    vc.cartDetail = _cartSummary;
                    vc.delegate = self;
                    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
                    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                    navigationController.navigationBar.translucent = NO;
                    navigationController.navigationBar.tintColor = [UIColor whiteColor];
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }
                    break;
                case TYPE_GATEWAY_MANDIRI_E_CASH:
                {
                    _requestCart.param = [self paramBuy];
                    [_requestCart dorequestBuy];
                    
                }
                    break;
                default:
                    break;
            }
            [self sendingProductDataToGA];
        }
    }
}

- (void)changeSwitchSaldo:(UISwitch *)switchSaldo
{
    _isUsingSaldoTokopedia = _isUsingSaldoTokopedia?NO:YES;
    if (!_isUsingSaldoTokopedia) {
        NSString *grandTotal = [_grandTotalLabel.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"," withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSInteger depositAmount = [[_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
        NSInteger grandTotalInteger = [grandTotal integerValue] + depositAmount;
        
        NSInteger grandTotalCartFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
        
        NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
        NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
        
        if (voucherUsedAmount<voucherAmount) {
            if (voucherUsedAmount+ depositAmount > grandTotalCartFromWS) {
                
            }
            else
                voucherUsedAmount = voucherUsedAmount+ depositAmount;
            
            if (voucherUsedAmount>voucherAmount) {
                voucherUsedAmount = voucherAmount;
                grandTotalInteger = voucherUsedAmount - voucherAmount;
            }
            else
            {
                depositAmount = 0;
                grandTotalInteger = 0;
            }
            

            [_dataInput setObject:@(depositAmount) forKey:DATA_USED_SALDO_KEY];
            [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
        }
        
        if (grandTotalInteger>grandTotalCartFromWS) {
            grandTotalInteger = grandTotalCartFromWS;
        }

        _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
        
        _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
        
        _saldoTokopediaAmountTextField.text = @"";
        
    }
    [_tableView reloadData];

}
- (IBAction)tapChoosePayment:(id)sender {
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY]?:[TransactionCartGateway new];
    
    NSMutableArray *gatewayListWithoutCreditCart = [NSMutableArray new];
    
    for (TransactionCartGateway *gateway in _cart.gateway_list) {
        if (![gateway.gateway isEqual:@(8)] && ![gateway.gateway isEqual:@(9)] && ![gateway.gateway isEqual:@(10)]) {
            [gatewayListWithoutCreditCart addObject:gateway.gateway_name];
        }
    }
    
    GeneralTableViewController *vc = [GeneralTableViewController new];
    vc.selectedObject = selectedGateway.gateway_name;
    vc.objects = gatewayListWithoutCreditCart;
    vc.delegate = self;
    vc.title = @"Metode Pembayaran";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Delegate
-(void)TransactionCartShippingViewController:(TransactionCartShippingViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
        
        NSInteger index = [[userInfo objectForKey:DATA_INDEX_KEY] integerValue];
        [_list replaceObjectAtIndex:index withObject:[userInfo objectForKey:DATA_CART_DETAIL_LIST_KEY]];
        
        [self adjustDropshipperListParam];
        _refreshFromShipment = YES;
        _requestCart.param = @{};
        [_requestCart doRequestCart];
        
    }
}

-(void)editInsuranceUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
        
        NSInteger index = [[userInfo objectForKey:DATA_INDEX_KEY] integerValue];
        [_dataInput setObject:@(index) forKey:DATA_INDEX_KEY];
        [_list replaceObjectAtIndex:index withObject:[userInfo objectForKey:DATA_CART_DETAIL_LIST_KEY]];
        
        _requestCart.param = @{};
        [_requestCart doRequestCart];
        
        _refreshFromShipment = YES;
    }
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
         _requestCart.param = [self paramEditProduct];
        [_requestCart doRequestEditProduct];
       
    }
}
#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {
        [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
    }
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {

        [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
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
    NSArray *list = summaryDetail.carts;
    [_list removeAllObjects];

    [_list addObjectsFromArray:list];
    if (_list.count>0) {
        _isnodata = NO;
    }
    
    _cartSummary = summaryDetail;
    
    _isUsingSaldoTokopedia = ([_cartSummary.deposit_amount integerValue]>0);
    
    NSArray *dropshipNameArray = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
    [_senderNameDropshipper removeAllObjects];
    [_senderNameDropshipper addObjectsFromArray:dropshipNameArray];
    NSArray *dropshipPhoneArray = [_data objectForKey:DATA_DROPSHIPPER_PHONE_KEY];
    [_senderPhoneDropshipper removeAllObjects];
    [_senderPhoneDropshipper addObjectsFromArray:dropshipPhoneArray];
    [_tableView reloadData];
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    NSMutableArray *messageError = [NSMutableArray new];
    
    if (_indexPage == 0) {
        NSInteger gateway = [[_dataInput objectForKey:API_GATEWAY_LIST_ID_KEY]integerValue];
        if (gateway == -1) {
            isValid = NO;
            [messageError addObject:ERRORMESSAGE_NULL_CART_PAYMENT];
        }
        if (_isUsingSaldoTokopedia)
        {
            NSNumber *grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
            NSNumber *deposit = [_dataInput objectForKey:DATA_USED_SALDO_KEY];
            if ([deposit integerValue]> [grandTotal integerValue])
            {
                isValid = NO;
                [messageError addObject:@"Jumlah Saldo Tokopedia yang Anda masukkan terlalu banyak. Gunakan Pembayaran Saldo Tokopedia apabila mencukupi."];
            }
            if ([deposit integerValue]> [self depositAmountUser]) {
                isValid = NO;
                [messageError addObject:@"Saldo Tokopedia Anda tidak mencukupi."];
            }
        }
    }
    else if (_indexPage == 1 && [_cartSummary.deposit_amount integerValue]>0) {
        NSString *password = [_dataInput objectForKey:API_PASSWORD_KEY];
        if ([password isEqualToString:@""] || password == nil) {
            isValid = NO;
            [messageError addObject:ERRORMESSAGE_NULL_CART_PASSWORD];
        }
    }
    
    for (int i = 0; i<_isDropshipper.count; i++) {
        if ([_isDropshipper[i] boolValue] == 1) {
            if ([_senderNameDropshipper[i] isEqualToString:@""] || _senderNameDropshipper[i]==nil) {
                isValid = NO;
                if (![messageError containsObject:ERRORMESSAGE_SENDER_NAME_NILL])
                    [messageError addObject:ERRORMESSAGE_SENDER_NAME_NILL];
            }
            if ([_senderPhoneDropshipper[i] isEqualToString:@""] || _senderPhoneDropshipper[i]==nil) {
                isValid = NO;
                if (![messageError containsObject:ERRORMESSAGE_SENDER_PHONE_NILL])
                    [messageError addObject:ERRORMESSAGE_SENDER_PHONE_NILL];
            }
            else if (((NSString*)_senderPhoneDropshipper[i]).length < 6) {
                isValid = NO;
                if (![messageError containsObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT])
                    [messageError addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT];
            }
        }
    }
    
    NSLog(@"%d",isValid);
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messageError delegate:self];
        [alert show];
    }

    return  isValid;
}

-(BOOL)isValidInputVoucher
{
    BOOL isValid = YES;
    
    NSMutableArray *errorMessages = [NSMutableArray new];
    
    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY];
    if (!(voucherCode) || [voucherCode isEqualToString:@""]) {
        isValid = NO;
        [errorMessages addObject:ERRORMESSAGE_NULL_VOUCHER_CODE];
    }
    if (voucherCode.length != 12)
    {
        isValid = NO;
        [errorMessages addObject:ERRORMESSAGE_VOUCHER_CODE_LENGHT];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
    
    return  isValid;
}

-(void)adjustDropshipperListParam;
{
    NSInteger listCount = _list.count;
    NSMutableDictionary *dropshipListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *dropshipperNameKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_NAME_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        NSString *dropshipperPhoneKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_PHONE_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        [dropshipListParam setObject:_senderNameDropshipper[i] forKey:dropshipperNameKey];
        [dropshipListParam setObject:_senderPhoneDropshipper[i] forKey:dropshipperPhoneKey];
        
        if (_isDropshipper.count>0)
        {
            if ([_isDropshipper[i] boolValue]==YES) {
                NSString *dropshipStringObject = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
                [_dropshipStrList replaceObjectAtIndex:i withObject:dropshipStringObject];
            }
            else
            {
                [_dropshipStrList replaceObjectAtIndex:i withObject:@""];
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
        NSInteger addressID =list.cart_destination.address_id;
        //NSInteger shipmentID = [list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *partialDetailKey = [NSString stringWithFormat:FORMAT_CART_CANCEL_PARTIAL_KEY,shopID,addressID, shipmentPackageID];
        if(_stockPartialDetail.count>0)
            [partialListParam setObject:_stockPartialDetail[i] forKey:partialDetailKey];
    }
    [_dataInput setObject:partialListParam forKey:DATA_PARTIAL_LIST_KEY];
}

#pragma mark - Cell Delegate
-(void)tapMoreButtonActionAtIndexPath:(NSIndexPath*)indexPath
{
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:
                                @"Hapus",
                                @"Edit",
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    }
    else
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:
                                @"Hapus",
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    }
}

-(void)GeneralSwitchCell:(GeneralSwitchCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    //NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    TransactionCartList *list = _list[indexPath.section];
    NSInteger shopID = [list.cart_shop.shop_id integerValue];
    NSInteger addressID =list.cart_destination.address_id;
    NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
    NSInteger shipmentPackageID =[list.cart_shipments.shipment_package_id integerValue];
    
    [_isDropshipper replaceObjectAtIndex:indexPath.section withObject:@(cell.settingSwitch.on)];
    
    if (cell.settingSwitch.on) {
        NSString *dropshipStringObject = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        [_dropshipStrList replaceObjectAtIndex:indexPath.section withObject:dropshipStringObject];
    }
    else
    {
        [_dropshipStrList replaceObjectAtIndex:indexPath.section withObject:@""];
    }
    
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
    if (_indexPage == 0) {
        TransactionCartList *list = _list[section];
        [_navigate navigateToShopFromViewController:self withShopID:list.cart_shop.shop_id];
    }
}

#pragma mark - Actionsheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    TransactionCartList *list = _list[indexPathCancelProduct.section];
    NSArray *products = list.cart_products;
    ProductDetail *product = products[indexPathCancelProduct.row];
    switch (buttonIndex) {
        case 0:
        {
            NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART_PRODUCT,list.cart_shop.shop_name, product.product_name, product.product_total_price_idr];
            UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
            cancelCartAlert.tag = 10;
            [cancelCartAlert show];
            break;
        }
        case 1:
        {
            if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {
                TransactionCartEditViewController *editViewController = [TransactionCartEditViewController new];
                [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
                editViewController.data = _dataInput;
                editViewController.delegate = self;
                [self.navigationController pushViewController:editViewController animated:YES];
            }
            break;
        }
        default:
            break;
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
        NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
        NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
        
        NSInteger depositAmount = [[_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
        
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
        
        NSString *grandTotal = [_grandTotalLabel.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"," withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSInteger grandTotalInteger = [grandTotal integerValue] + depositAmount;
        
        if (grandTotalInteger < 0) {
            grandTotalInteger = 0;
        }
        
        
        _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
        
        _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
        
        _saldoTokopediaAmountTextField.text = @"";
        
    }
    [_tableView reloadData];
}

#pragma mark - UIAlertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    switch (alertView.tag) {
        case TYPE_CANCEL_CART_PRODUCT:
            switch (buttonIndex) {
                case 1:
                {
                    [_dataInput setObject:@(TYPE_CANCEL_CART_PRODUCT) forKey:DATA_CANCEL_TYPE_KEY];
                    _requestCart.param = [self paramCancelCart];
                    [_requestCart doRequestCancelCart];
                    
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
                    _requestCart.param = [self paramCancelCart];
                    [_requestCart doRequestCancelCart];
                    
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
                if ([self isValidInputVoucher]) {
                    _requestCart.param = [self paramVoucher];
                    [_requestCart doRequestVoucher];
                    
                }
                else
                {
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
            NSInteger addressID =list.cart_destination.address_id;
            //NSInteger shipmentID = [list.cart_shipments.shipment_id integerValue];
            NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
            
            if (index == 0){
                [_stockPartialStrList replaceObjectAtIndex:partialSection withObject:@""];
                [_stockPartialDetail replaceObjectAtIndex:partialSection withObject:@(0)];
            }
            else
            {
                NSString *partialStringObject = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_KEY,shopID,addressID,shipmentPackageID];
                [_stockPartialStrList replaceObjectAtIndex:partialSection withObject:partialStringObject];
                [_stockPartialDetail replaceObjectAtIndex:partialSection withObject:@(1)];
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
    [_requestCart dorequestBuy];
    _requestCart.param = [self paramBuy];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activeTextField = textField;
    if (textField == _saldoTokopediaAmountTextField) {
        NSString *grandTotal = [_grandTotalLabel.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"," withString:@""];
        grandTotal = [grandTotal stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [_dataInput setObject:grandTotal forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    }

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag > 0 )
    {
        [_senderNameDropshipper replaceObjectAtIndex:textField.tag-1 withObject:textField.text];
    }
    else if (textField.tag < 0)
    {
        [_senderPhoneDropshipper replaceObjectAtIndex:-textField.tag-1 withObject:textField.text];
    }
    if (textField == _saldoTokopediaAmountTextField) {
        
        [_tableView reloadData];
    }
    if (textField == _passwordTextField) {
        [_dataInput setObject:textField.text forKey:API_PASSWORD_KEY];
    }
    
    //_checkoutButton.enabled = isValid;

    [self adjustDropshipperListParam];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _saldoTokopediaAmountTextField) {
        
        NSString *textFieldValue = [NSString stringWithFormat:@"%@%@", textField.text, string];
        
        NSNumber * grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL];

        NSString *depositAmount = [textFieldValue stringByReplacingOccurrencesOfString:@"." withString:@""];
        [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];

        NSString *textFieldText = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];

        if (range.length > 0)
        {
            
            NSString *textFieldRemoveOneChar = [[textField.text substringToIndex:[textField.text length]-1] stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSInteger deposit = [textFieldRemoveOneChar integerValue];
            NSInteger grandTotalInteger = [grandTotal integerValue] - deposit;
                        NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
            NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
            NSInteger grandTotalCartFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
            
            if (grandTotalInteger<0) {
                if (voucherUsedAmount<voucherAmount && voucherUsedAmount< grandTotalCartFromWS) {
                    voucherUsedAmount = voucherUsedAmount+ deposit;
                    if (voucherUsedAmount>voucherAmount) {
                        voucherUsedAmount = voucherAmount;
                    }
                    else
                    {
                        depositAmount = 0;
                    }
                    //[_dataInput setObject:@(deposit) forKey:DATA_USED_SALDO_KEY];
                    [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
                }
                grandTotalInteger = 0;
            }
            grandTotalInteger -= voucherUsedAmount;
            if (grandTotalInteger <0) {
                grandTotalInteger = 0;
            }
            
            _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
            _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
            _grandTotalLabel.text = ([_cart.grand_total integerValue]<=0)?@"Rp 0,-":_cart.grand_total_idr;
            
            NSString *depositAmount = [textFieldRemoveOneChar stringByReplacingOccurrencesOfString:@"." withString:@""];
            [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];
            
        }
        else if ([textFieldText integerValue] <= [grandTotal integerValue] || [textFieldText integerValue] <= [self depositAmountUser])
        {
            grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL];
            NSInteger deposit = [depositAmount integerValue];
            NSInteger grandTotalInteger = [grandTotal integerValue] - deposit;
            NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
            NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
            NSInteger grandTotalCartFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
            
            if (grandTotalInteger<0) {
                if (voucherUsedAmount<voucherAmount && voucherUsedAmount< grandTotalCartFromWS) {
                    voucherUsedAmount = voucherUsedAmount+ deposit;
                    if (voucherUsedAmount>voucherAmount) {
                        voucherUsedAmount = voucherAmount;
                        deposit = voucherUsedAmount - voucherAmount;
                    }
                    else
                    {
                        depositAmount = 0;
                    }
                    //[_dataInput setObject:@(deposit) forKey:DATA_USED_SALDO_KEY];
                    [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
                }
                grandTotalInteger = 0;
            }
            grandTotalInteger -= voucherUsedAmount;
            if (grandTotalInteger <0) {
                grandTotalInteger = 0;
            }
            
            NSLog(@"%zd",deposit);
            _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
            _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
            [_dataInput setObject:@(deposit) forKey:DATA_USED_SALDO_KEY];
            
            _grandTotalLabel.text = ([_cart.grand_total integerValue]<=0)?@"Rp 0,-":_cart.grand_total_idr;
            
            
        }
        
       NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
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
     _requestCart.param = [self paramEMoney];
    [_requestCart doRequestEMoney];
}

-(void)shouldDoRequestBCAClickPay
{
    _requestCart.param = @{};
    [_requestCart doRequestBCAClickPay];
}

#pragma mark - Methods

-(void)addArrayObjectTemp
{
    [_isDropshipper addObject:@(NO)];
    [_stockPartialStrList addObject:@""];
    [_senderNameDropshipper addObject:@""];
    [_senderPhoneDropshipper addObject:@""];
    [_dropshipStrList addObject:@""];
    [_stockPartialDetail addObject:@(0)];
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
}

-(NSInteger)depositAmountUser
{
    NSString *depositAmountUser = _cart.deposit_idr;
    depositAmountUser = [depositAmountUser stringByReplacingOccurrencesOfString:@"." withString:@""];
    depositAmountUser = [depositAmountUser stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    depositAmountUser = [depositAmountUser stringByReplacingOccurrencesOfString:@"," withString:@""];
    depositAmountUser = [depositAmountUser stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [depositAmountUser integerValue];
}

-(void)refreshRequestCart
{
    [self doClearAllData];
    
    if (![_tableView.tableFooterView isEqual:_footerView]) {
        _tableView.tableFooterView = _footerView;
        [_refreshControl beginRefreshing];
        [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height-40) animated:YES];
    }
    
    _requestCart.param = @{};
    [_requestCart doRequestCart];
}

-(void)doClearAllData
{
    _isnodata = YES;
    _indexPage = 0;
    [_delegate isNodata:NO];
    [_dataInput removeAllObjects];
    [_dropshipStrList removeAllObjects];
    [_senderNameDropshipper removeAllObjects];
    [_senderPhoneDropshipper removeAllObjects];
    [_isDropshipper removeAllObjects];
    [_stockPartialDetail removeAllObjects];
    [_stockPartialStrList removeAllObjects];
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
    
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"Pilih"];
    
    _saldoTokopediaAmountTextField.text = @"";
    
    _voucherCodeButton.hidden = NO;
    _voucherAmountLabel.hidden = YES;
    _buttonVoucherInfo.hidden = NO;
    _buttonCancelVoucher.hidden = YES;
    
    _tableView.tableFooterView = nil;
    _saldoTokopediaAmountTextField.text = @"";
    
    [_tableView reloadData];
}

-(void)popShippingViewController
{
    if (_indexPage == 0) {
        _requestCart.param = @{};
         [_requestCart doRequestCart];
        
        _refreshFromShipment = YES;
    }
    else
    {
        _popFromShipment = YES;
    }
}

-(void)setDefaultInputData
{
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
    
    _isnodata = YES;
    _isLoadingRequest = NO;
    
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
}

#pragma mark - Footer View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section < _list.count)
    {
        TransactionCartList *list = _list[section];
        NSString *shopName = list.cart_shop.shop_name;
        
        TransactionCartHeaderView *headerView = [TransactionCartHeaderView newview];
        headerView.shopNameLabel.text = shopName;
        if (_indexPage==1) {
            headerView.shopNameLabel.textColor = [UIColor blackColor];
            headerView.deleteButton.hidden = YES;
            headerView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
        }
        headerView.section = section;
        headerView.delegate = self;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height, headerView.frame.size.width,1)];
        lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
        [headerView addSubview:lineView];
        return headerView;
    }
    else
    {
        return nil;
    }
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
    TransactionCartList *list = _list[section];
    TransactionCartCostView *view = [TransactionCartCostView newview];
    view.biayaInsuranceLabel.text = ([list.cart_logistic_fee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
    view.infoButton.hidden = ([list.cart_logistic_fee integerValue]==0);
    [view.subtotalLabel setText:list.cart_total_product_price_idr animated:YES];
    NSInteger aditionalFeeValue = [list.cart_logistic_fee integerValue]+[list.cart_insurance_price integerValue];
    NSString *formatAdditionalFeeValue = [_IDRformatter stringFromNumber:@(aditionalFeeValue)];
    [view.insuranceLabel setText:formatAdditionalFeeValue animated:YES];
    [view.shippingCostLabel setText:list.cart_shipping_rate_idr animated:YES];
    [view.totalLabel setText:list.cart_total_amount_idr animated:YES];
    
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
        cell = [self cellErrorAtIndexPath:indexPath];
    }
    else if (indexPath.row <= productCount)
    {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        cell = [self cellTransactionCartAtIndexPath:newIndexPath];
    }
    else
    {
        //otherCell
        if (indexPath.row == productCount+1)
            cell = [self cellDetailShipmentAtIndexPath:indexPath];
        else if (indexPath.row == productCount+2)
            cell = [self cellPartialStockAtIndextPath:indexPath];
        else if (indexPath.row == productCount+3)
            cell = [self cellIsDropshipperAtIndextPath:indexPath];
        else if (indexPath.row == productCount+4){
            NSInteger count =_senderNameDropshipper.count;
            if (indexPath.section>count-1) {
                for (int i=count-1; i<=indexPath.section; i++) {
                    [_senderNameDropshipper addObject:@""];
                }
            }
            cell = [self cellTextFieldPlaceholder:@"Nama Pengirim" atIndexPath:indexPath withText:[_senderNameDropshipper objectAtIndex:indexPath.section]?:@""];
        }
        else if (indexPath.row == productCount+5)
        {
            NSInteger count =_senderPhoneDropshipper.count;
            if (indexPath.section>count-1) {
                for (int i=count-1; i<indexPath.section; i++) {
                    [_senderPhoneDropshipper addObject:@""];
                }
            }
            cell = [self cellTextFieldPlaceholder:@"Nomer Telepon" atIndexPath:indexPath withText:_senderPhoneDropshipper[indexPath.section]];
        }
    }
    
    return cell;
}

-(UITableViewCell *)cellErrorAtIndexPath:(NSIndexPath*)indexPath
{
    TransactionCartList *list = _list[indexPath.section];

    static NSString *CellIdentifier = @"ErrorIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSString *error1 = [list.cart_error_message_1 isEqualToString:@"0"]?@"":list.cart_error_message_1;
    NSString *error2 = [list.cart_error_message_2 isEqualToString:@"0"]?@"":list.cart_error_message_2;
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;

    NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
    [cell.textLabel setCustomAttributedText:string];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor redColor];
    
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    cell.clipsToBounds = YES;
    cell.contentView.clipsToBounds = YES;
    
    
    return cell;
}

-(UITableViewCell*)cellPaymentInformationAtIndexPath:(NSIndexPath*)indexPath
{
    //0 Kode Promo Tokopedia?, 1 Total invoice, 2 Saldo Tokopedia Terpakai, 3 Voucher terpakai 4 Kode Transfer, 5 Total Pembayaran
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = _voucerCell;
            break;
        case 1:
            cell = _totalInvoiceCell;
            cell.detailTextLabel.text =_cartSummary.grand_total_before_fee_idr;
            break;
        case 2:
            cell = _usedSaldoCell;
            [cell.detailTextLabel setText:_cartSummary.deposit_amount_idr animated:YES];
            break;
        case 3:
            cell = _voucherUsedCell;
            [cell.detailTextLabel setText:_cartSummary.voucher_amount_idr];
            break;
        case 4:
            cell = _transferCodeCell;
            [cell.detailTextLabel setText:_cartSummary.conf_code_idr animated:YES];
            break;
        case 5:
            cell = _totalPaymentDetail;
            [cell.detailTextLabel setText:_cartSummary.payment_left_idr animated:YES];
            break;
        default:
            break;
     }
    return cell;
}


-(UITableViewCell*)cellAdjustDepositAtIndexPath:(NSIndexPath*)indexPath
{
    // 0 saldo tokopedia, 1 textfield saldo, 2 password tokopedia
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
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*)cellDetailShipmentAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"shipmentDetailIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Detail Pengiriman";
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width,1)];
        lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
        [cell.contentView addSubview:lineView];
    return cell;
}

-(UITableViewCell*)cellPartialStockAtIndextPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"leftStockIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger choosenIndex;
    if (_stockPartialDetail.count>0) {
        choosenIndex = [_stockPartialStrList[indexPath.section] isEqualToString:@""]?0:1;
    }
    else
    {
        choosenIndex = 0;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Stock Tersedia Sebagian";
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    cell.detailTextLabel.text = [ARRAY_IF_STOCK_AVAILABLE_PARTIALLY[choosenIndex]objectForKey:DATA_NAME_KEY];
    cell.detailTextLabel.font = FONT_DETAIL_DEFAULT_CELL_TKPD;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    cell.clipsToBounds = YES;
    return cell;
}

-(UITableViewCell*)cellTextFieldPlaceholder:(NSString*)placeholder atIndexPath:(NSIndexPath*)indexPath withText:(NSString*)text
{
    
    static NSString *CellIdentifier = @"textfieldCellIdentifier";
    BOOL isSaldoTokopediaTextField = (indexPath.section==_list.count);
    NSInteger indexList = (isSaldoTokopediaTextField)?0:(indexPath.section);
    TransactionCartList *list = _list[indexList];
    NSArray *products = list.cart_products;
    UITableViewCell *cell;
    
    //if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 44)];
    
        textField.placeholder = placeholder;
        textField.text = text;
        textField.delegate = self;
        if ([placeholder isEqualToString:@"Nama Pengirim"]) {
            textField.tag = indexPath.section+1;
            textField.keyboardType = UIKeyboardTypeDefault;
        }
        else
        {
            textField.tag = -indexPath.section -1;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        textField.font = FONT_DEFAULT_CELL_TKPD;
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.text = text;
        [cell addSubview:textField];
    //}

    return cell;
}

-(UITableViewCell*)cellIsDropshipperAtIndextPath:(NSIndexPath*)indexPath
{
    NSString *cellid = GENERAL_SWITCH_CELL_IDENTIFIER;
    
    UITableViewCell *cell = (GeneralSwitchCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralSwitchCell newcell];
        ((GeneralSwitchCell*)cell).delegate = self;
    }
    
    ((GeneralSwitchCell*)cell).indexPath = indexPath;
    ((GeneralSwitchCell*)cell).textCellLabel.text = @"Dropshipper";
    if (_isDropshipper.count>0) {
        ((GeneralSwitchCell*)cell).settingSwitch.on = [_isDropshipper[indexPath.section] boolValue];
    }
    else
    {
        ((GeneralSwitchCell*)cell).settingSwitch.on = NO;
    }
    
    return cell;
}

-(UITableViewCell*)cellTransactionCartAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_CART_CELL_IDENTIFIER;
    
    TransactionCartCell *cell = (TransactionCartCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartCell newcell];
        ((TransactionCartCell*)cell).delegate = self;
    }
    TransactionCartList *list = _list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    cell.backgroundColor = (_indexPage==0)?[UIColor whiteColor]:[UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1];

    NSAttributedString *attributedText;
    if (_indexPage==0) {
        UIColor *color = [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1];
        [_textAttributes setObject:color forKey:NSForegroundColorAttributeName];
        attributedText = [[NSAttributedString alloc] initWithString:product.product_name
                                                         attributes:_textAttributes];
    } else {
        [_textAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        attributedText = [[NSAttributedString alloc] initWithString:product.product_name
                                                         attributes:_textAttributes];
    }
    [cell.productNameLabel setAttributedText:attributedText];

    NSString *priceIsChangedString = [NSString stringWithFormat:@"%@ (Sebelumnya %@)", product.product_price_idr, product.product_price_last];
    NSString *productSebelumnya = [NSString stringWithFormat:@"(Sebelumnya %@)", product.product_price_last];
    NSString *priceString = product.product_price_idr;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priceIsChangedString];
    [attributedString addAttribute:NSFontAttributeName
                             value:FONT_GOTHAM_BOOK_10
                             range:[priceIsChangedString rangeOfString:productSebelumnya]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[priceIsChangedString rangeOfString:productSebelumnya]];
    if ([list.cart_is_price_changed integerValue] == 1)
        cell.productPriceLabel.attributedText = attributedString;
    else
        cell.productPriceLabel.text = priceString;
    
    NSString *weightTotal = [NSString stringWithFormat:@"%@ Barang (%@ kg)",product.product_quantity, product.product_total_weight];
    attributedString = [[NSMutableAttributedString alloc] initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName
                             value:FONT_GOTHAM_BOOK_12
                             range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    cell.quantityLabel.attributedText = attributedString;
    
    NSIndexPath *indexPathCell = [NSIndexPath indexPathForRow:indexProduct inSection:indexPath.section];
    ((TransactionCartCell*)cell).indexPath = indexPathCell;
    NSString *productNotes = [product.product_notes stringByReplacingOccurrencesOfString:@"\n" withString:@"; "];
    [cell.remarkLabel setCustomAttributedText:productNotes?:@"-"];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.productThumbImageView;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey2.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [thumb setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        thumb.image = [UIImage imageNamed:@"Icon_no_photo_transparan.png"];
    }];
    
    cell.editButton.hidden = (_indexPage == 1);
    
    if ([product.product_error_msg isEqualToString:@""] || [product.product_error_msg isEqualToString:@"0"] || product.product_error_msg == nil) {
        cell.errorProductLabel.hidden = YES;
    }
    else
    {
        cell.errorProductLabel.hidden = NO;
        if ([product.product_error_msg isEqualToString:@"Produk ini berada di gudang"]) {
            cell.errorProductLabel.text = @"GUDANG";
        }
        else if ([product.product_error_msg isEqualToString:@"Produk ini dalam moderasi"])
        {
            cell.errorProductLabel.text = @"MODERASI";
        }
        else
            cell.errorProductLabel.text = @"HAPUS";
    }
    
    if ([list.cart_is_price_changed integerValue] == 1)
    {
        cell.errorProductLabel.hidden = NO;
        [cell.errorProductLabel setCustomAttributedText:@"HARGA BERUBAH"];
    }
    
    cell.userInteractionEnabled = (_indexPage ==0);
    return cell;
}

#pragma mark - Cell Height
-(CGFloat)rowHeightPage1AtIndexPath:(NSIndexPath*)indexPath
{
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    
    if (indexPath.section == _list.count) {
        if (indexPath.row >0) {
            return 0;
        }
    }
    else if (indexPath.section < _list.count) {
        TransactionCartList *list = _list[indexPath.section];
        if (indexPath.row == 0)
            return [self errorLabelHeight:list];
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
        else if (indexPath.row == list.cart_products.count + 4)
        {
            if (![_isDropshipper[indexPath.section] boolValue]) {
                return 0;
            }
        }
        else if (indexPath.row == list.cart_products.count + 5)
        {
            if (![_isDropshipper[indexPath.section] boolValue]) {
                return 0;
            }
        }
    }
    else if (indexPath.section == _list.count+1)
    {
        if (indexPath.row == 0 || indexPath.row == 2) {
            if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
                [selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] ||
                ([self depositAmountUser] == 0) ) {
                return 0;
            }
        }
        if (indexPath.row == 1 ) {
            if (!_isUsingSaldoTokopedia) {
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
        //0 Kode Promo Tokopedia?, 1 Total invoice, 2 Saldo Tokopedia Terpakai, 3 Voucher terpakai 4 Kode Transfer, 5 Total Pembayaran
        if (indexPath.row == 0)
        {
            return 0;
        }
        if (indexPath.row == 2)
        {
            if ([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TOKOPEDIA &&
                [_cartSummary.deposit_amount integerValue] <= 0) {
                return 0;
            }
        }
        if (indexPath.row == 3) {
            if ([_cartSummary.voucher_amount_idr integerValue]<=0) {
                return 0;
            }
        }
        if (indexPath.row == 4) {
            if ([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TRANSFER_BANK)
                return 0;
        }
    }
    else if (indexPath.section == _list.count+1)
    {
        //0 saldo tokopedia, 1 textfield saldo, 2 deposit amount, 3 password tokopedia
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
            if ([_cartSummary.gateway integerValue] != TYPE_GATEWAY_TOKOPEDIA &&
                [_cartSummary.deposit_amount integerValue] <= 0) {
                return 0;
            }
        }
        
    }
    else if (indexPath.section == _list.count+2)
    {
        return 0;
    }
    return DEFAULT_ROW_HEIGHT;
}

-(CGFloat)errorLabelHeight:(TransactionCartList*)list
{
    NSString *error1 = [list.cart_error_message_1 isEqualToString:@"0"]?@"":list.cart_error_message_1;
    NSString *error2 = [list.cart_error_message_2 isEqualToString:@"0"]?@"":list.cart_error_message_2;
    if ([error1 isEqualToString:@""]&& [error2 isEqualToString:@""])
    {
        return 0;
    }
    else
    {
        NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
        CGSize maximumLabelSize = CGSizeMake(290,9999);
        CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_18
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByTruncatingTail];
        
        return expectedLabelSize.height;
    }
}

-(CGFloat)productRowHeight:(ProductDetail*)product
{
    NSString *productNotes = [product.product_notes stringByReplacingOccurrencesOfString:@"\n" withString:@"; "];
    NSString *string = productNotes;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(290,9999);
    CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_14
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    return CELL_PRODUCT_ROW_HEIGHT+expectedLabelSize.height;
}

#pragma mark - Network Manager Delegate
-(NSDictionary *)paramCancelCart
{
    NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    
    TransactionCartList *list = _list[indexPathCancelProduct.section];
    NSArray *products = list.cart_products;
    ProductDetail *product = products[indexPathCancelProduct.row];
    
    NSInteger type = [[_dataInput objectForKey:DATA_CANCEL_TYPE_KEY]integerValue];
    
    NSInteger productCartID = (type == TYPE_CANCEL_CART_PRODUCT)?[product.product_cart_id integerValue]:0;
    NSString *shopID = list.cart_shop.shop_id?:@"";
    NSInteger addressID = list.cart_destination.address_id;
    NSString *shipmentID = list.cart_shipments.shipment_id?:@"";
    NSString *shipmentPackageID = list.cart_shipments.shipment_package_id?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_CANCEL_CART,
                            API_PRODUCT_CART_ID_KEY : @(productCartID),
                            kTKPD_SHOPIDKEY:shopID,
                            API_ADDRESS_ID_KEY:@(addressID),
                            API_SHIPMENT_ID_KEY:shipmentID,
                            API_SHIPMENT_PACKAGE_ID:shipmentPackageID
                            };
    return param;
}

-(NSDictionary*)paramCheckout
{
    [self adjustDropshipperListParam];
    
    NSString *token = _cart.token;
    
    TransactionCartGateway *gateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSNumber *gatewayID = gateway.gateway;
    
    NSMutableArray *tempDropshipStringList = [NSMutableArray new];
    for (NSString *dropshipString in _dropshipStrList) {
        if (![dropshipString isEqualToString:@""]) {
            [tempDropshipStringList addObject:dropshipString];
        }
    }
    NSMutableArray *tempPartialStringList = [NSMutableArray new];
    for (NSString *partialString in _stockPartialStrList) {
        if (![partialString isEqualToString:@""]) {
            [tempPartialStringList addObject:partialString];
        }
    }
    
    NSString * dropshipString = [[tempDropshipStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];
    NSDictionary *dropshipperDetail = [_dataInput objectForKey:DATA_DROPSHIPPER_LIST_KEY]?:@{};
    
    NSString * partialString = [[tempPartialStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];
    NSDictionary *partialDetail = [_dataInput objectForKey:DATA_PARTIAL_LIST_KEY]?:@{};
    
    NSNumber *usedSaldo = _isUsingSaldoTokopedia?[_dataInput objectForKey:DATA_USED_SALDO_KEY]?:@"0":@"0";
    
    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY]?:@"";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{API_STEP_KEY:@(STEP_CHECKOUT),
                                      API_TOKEN_KEY:token,
                                      API_GATEWAY_LIST_ID_KEY:gatewayID,
                                      API_DROPSHIP_STRING_KEY:dropshipString,
                                      API_PARTIAL_STRING_KEY :partialString,
                                      API_USE_DEPOSIT_KEY:@(_isUsingSaldoTokopedia),
                                      API_DEPOSIT_AMT_KEY:usedSaldo
                                      };
    
    if (![voucherCode isEqualToString:@""]) {
        [param setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
    }
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipperDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    
    return param;
}

-(NSDictionary*)paramBuy
{
    NSString *token = _cartSummary.token;
    NSNumber *gatewayID = _cartSummary.gateway;
    NSString *mandiriToken = [_dataInput objectForKey:API_MANDIRI_TOKEN_KEY]?:@"";
    NSString *cardNumber = [_dataInput objectForKey:API_CARD_NUMBER_KEY]?:@"";
    NSString *password = [_dataInput objectForKey:API_PASSWORD_KEY]?:@"";
    
    NSDictionary* param = @{API_STEP_KEY:@(STEP_BUY),
                            API_TOKEN_KEY:token,
                            API_GATEWAY_LIST_ID_KEY:gatewayID,
                            API_MANDIRI_TOKEN_KEY:mandiriToken,
                            API_CARD_NUMBER_KEY:cardNumber,
                            API_PASSWORD_KEY:password
                            };
    return param;
}

-(NSDictionary*)paramVoucher
{
    NSString *voucherCode = [_dataInput objectForKey:API_VOUCHER_CODE_KEY];
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_CECK_VOUCHER_CODE,
                            API_VOUCHER_CODE_KEY : voucherCode
                            };
    
    return param;
}

-(NSDictionary*)paramEditProduct
{
    ProductDetail *product = [_dataInput objectForKey:DATA_PRODUCT_DETAIL_KEY];
    
    NSInteger productCartID = [product.product_cart_id integerValue];
    NSString *productNotes = product.product_notes?:@"";
    NSString *productQty = product.product_quantity?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_EDIT_PRODUCT_CART,
                            API_PRODUCT_CART_ID_KEY : @(productCartID),
                            API_CART_PRODUCT_NOTES_KEY:productNotes,
                            API_PRODUCT_QUANTITY_KEY:productQty
                            };
    return param;

}

-(NSDictionary*)paramEMoney
{
    NSDictionary* param = @{//API_ACTION_KEY : isWSNew?ACTION_START_UP_EMONEY:ACTION_VALIDATE_CODE_EMONEY,
                            API_ACTION_KEY :ACTION_START_UP_EMONEY,
                            API_MANDIRI_ID_KEY : _cartBuy.transaction.emoney_code?:@""};
    return param;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        if ([((UILabel*)_selectedPaymentMethodLabels[0]).text isEqualToString:@"Pilih"])
        {
            [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
        }
        if (![_refreshControl isRefreshing]) {
            _tableView.tableFooterView = _footerView;
            [_act startAnimating];
        }
        _isLoadingRequest = YES;
    }
    
    if (tag == TAG_REQUEST_CANCEL_CART) {
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
        [_alertLoading show];
    }
    
    if (tag == TAG_REQUEST_CHECKOUT) {
        _checkoutButton.enabled = NO;
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
        [_alertLoading show];
    }
    
    if (tag == TAG_REQUEST_BUY) {
        _buyButton.enabled = NO;
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
        [_alertLoading show];
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
    }
    if (tag == TAG_REQUEST_EMONEY) {
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
        [_alertLoading show];

    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
        [_alertLoading show];

    }
}


-(void)endRefreshing
{
    if (_refreshControl.isRefreshing) {
        [_tableView setContentOffset:CGPointMake(0, -40) animated:YES];
        [_refreshControl endRefreshing];
    }
}
-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        [self endRefreshing];
        [_act stopAnimating];
        _isLoadingRequest = NO;
        _tableView.tableFooterView = _loadingView.view;
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        [self endRefreshing];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    if (tag == TAG_REQUEST_CHECKOUT) {
        _checkoutButton.enabled = YES;
        _checkoutButton.layer.opacity = 1;
    }
    if (tag == TAG_REQUEST_BUY) {
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        
    }
    if (tag == TAG_REQUEST_EMONEY) {
        [_delegate shouldBackToFirstPage];
        [_act stopAnimating];
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        [_delegate shouldBackToFirstPage];
        [_act stopAnimating];
    }
    [self endRefreshing];
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Request Cart

-(void)requestSuccessCart:(id)successResult withOperation:(RKObjectRequestOperation*)operation
{
    [self endRefreshing];
    [_act stopAnimating];
    _isLoadingRequest = NO;
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCart *cart = stat;
            
    [_list removeAllObjects];
    
    NSArray *list = cart.result.list;
    [_list addObjectsFromArray:list];
    
    _cart = cart.result;
    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL];
    
    [self adjustAfterUpdateList];
    
    NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:_list.count > 0?_list[_indexSelectedShipment]:@{}};
    [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil userInfo:info];
    
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

}


-(void)adjustAfterUpdateList
{
    
    if (_list.count>0) {
        _isnodata = NO;
    }
    else
    {
        _isnodata = YES;
        _paymentMethodView.hidden = YES;
        _tableView.tableFooterView = nil;
    }
    [_delegate isNodata:_isnodata];
    
    
    NSInteger listCount = _list.count;

    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        
        NSArray *products = list.cart_products;
        NSInteger productCount = products.count;
        
        if (!_refreshFromShipment) {
            [self addArrayObjectTemp];
        }
        
        if (productCount<=0) {
            [_isDropshipper removeObjectAtIndex:i];
            [_stockPartialStrList removeObjectAtIndex:i];
            [_senderNameDropshipper removeObjectAtIndex:i];
            [_senderPhoneDropshipper removeObjectAtIndex:i];
            [_dropshipStrList removeObjectAtIndex:i];
            [_stockPartialDetail removeObjectAtIndex:i];
        }
        
    }
    if (listCount>0) {
        
        
        if (_indexPage == 0) {
            _paymentMethodView.hidden = NO;
            _paymentMethodSelectedView.hidden = YES;
            _checkoutView.hidden = NO;
            _tableView.tableFooterView = _isnodata?nil:_checkoutView;
        }
        else if (_indexPage == 1) {
            _paymentMethodView.hidden = YES;
            _paymentMethodSelectedView.hidden = NO;
            _buyView.hidden = NO;
            _tableView.tableFooterView = _isnodata?nil:_buyView;
        }
    }
    
    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
        
    [self adjustDropshipperListParam];
    [self adjustPartialListParam];
    
    NSNumber *grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    NSString *deposit = [_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"," withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *voucher = [_dataInput objectForKey:DATA_VOUCHER_AMOUNT];
    
    NSInteger totalInteger = [grandTotal integerValue];
    totalInteger -= [voucher integerValue];
    if (totalInteger<0) {
        totalInteger = 0;
    }
    
    NSInteger grandTotalInteger = 0;
    NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
    NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
    NSInteger grandTotalCartFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
    
    if (grandTotalCartFromWS<voucherAmount) {
        voucherUsedAmount = grandTotalCartFromWS;
        if (voucherUsedAmount>voucherAmount) {
            voucherUsedAmount = voucherAmount;
        }
    }
    
    grandTotalInteger = totalInteger;
    
    
    
    [_dataInput setObject:@(grandTotalCartFromWS) forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    
    grandTotalInteger -= [deposit integerValue];
    if (grandTotalInteger <0) {
        grandTotalInteger = 0;
    }
    
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
    
    _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
    
    
    _refreshFromShipment = NO;
    
    [_tableView reloadData];
    
}


#pragma mark - Request Cancel Cart

-(void)requestSuccessActionCancelCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    TransactionCartList *list = _list[indexPathCancelProduct.section];
    
    NSInteger type = [[_dataInput objectForKey:DATA_CANCEL_TYPE_KEY]integerValue];
    NSMutableArray *products = [NSMutableArray new];
    [products addObjectsFromArray:list.cart_products];
    ProductDetail *product = products[indexPathCancelProduct.row];
    
    if (type == TYPE_CANCEL_CART_PRODUCT ) {
        [products removeObject:product];
        ((TransactionCartList*)[_list objectAtIndex:indexPathCancelProduct.section]).cart_products = products;
        if (((TransactionCartList*)[_list objectAtIndex:indexPathCancelProduct.section]).cart_products.count<=0) {
            [_list removeObject:_list[indexPathCancelProduct.section]];
        }
    }
    else
    {
        [_list removeObject:list];
    }
    
    //
    [self adjustAfterUpdateList];
    [self refreshRequestCart];
    [self endRefreshing];
    
}


#pragma mark - Request Checkout

-(void)requestSuccessActionCheckout:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionSummary *cart = stat;
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:cart.result.transaction?:[TransactionSummaryDetail new],
                               DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper?:@"",
                               DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper?:@"",
                               DATA_PARTIAL_LIST_KEY:_stockPartialStrList?:@{},
                               DATA_TYPE_KEY:@(TYPE_CART_SUMMARY),
                               DATA_CART_GATEWAY_KEY :selectedGateway
                               };
    [_delegate didFinishRequestCheckoutData:userInfo];
    
    //
    _checkoutButton.enabled = YES;
    _tableView.tableFooterView = _isnodata?nil:(_indexPage==1)?_buyView:_checkoutView;
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - Request Buy

-(void)requestSuccessActionBuy:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionBuy *cart = stat;
    
    _cartBuy = cart.result;
    switch ([_cartSummary.gateway integerValue]) {
        case TYPE_GATEWAY_MANDIRI_E_CASH:
        {
            TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
            vc.gateway = @(TYPE_GATEWAY_MANDIRI_E_CASH);
            vc.token = _cartSummary.token;
            vc.URLStringMandiri = cart.result.link_mandiri?:@"";
            vc.cartDetail = _cartSummary;
            vc.emoney_code = cart.result.transaction.emoney_code;
            vc.delegate = self;
            UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
        break;
        default:
        {
            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:cart.result};
            [_delegate didFinishRequestBuyData:userInfo];
            [_dataInput removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        }
        break;
    }
    
    //
    _buyButton.enabled = YES;
    _buyButton.layer.opacity = 1;
    [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
    
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

}

#pragma mark - Request Action Voucher

-(void)requestSuccessActionVoucher:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionVoucher *dataVoucher = stat;

    _voucherCodeButton.hidden = YES;
    _voucherAmountLabel.hidden = NO;
    
    NSInteger voucher = [dataVoucher.result.data_voucher.voucher_amount integerValue];
    NSString *voucherString = [_IDRformatter stringFromNumber:[NSNumber numberWithInteger:voucher]];
    voucherString = [NSString stringWithFormat:@"Anda mendapatkan voucher %@,-", voucherString];
    _voucherAmountLabel.text = voucherString;
    _voucherAmountLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
    
    _buttonVoucherInfo.hidden = YES;
    _buttonCancelVoucher.hidden = NO;
    
    NSString *grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"," withString:@""];
    grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"-" withString:@""];
    grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSInteger totalInteger = [grandTotal integerValue];
    
    if (totalInteger<=voucher) {
        [_dataInput setObject:@(totalInteger) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    }
    else
    {
        [_dataInput setObject:@(voucher) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    }
    
    
    totalInteger -= voucher;
    if (totalInteger <0) {
        totalInteger = 0;
    }
    _cart.grand_total = [NSString stringWithFormat:@"%zd",totalInteger];
    _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:totalInteger]] stringByAppendingString:@",-"];
    [_dataInput setObject:@(voucher) forKey:DATA_VOUCHER_AMOUNT];
    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    [_tableView reloadData];
    
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

}

#pragma mark - Request Edit Product
-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    if (_indexPage == 0) {
        _requestCart.param = @{};
        [_requestCart doRequestCart];
        
        _refreshFromShipment = YES;
    }
    [_tableView reloadData];
}

#pragma mark - Request E-Money
-(void)requestSuccessEMoney:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy?:@{}};
    [_delegate didFinishRequestBuyData:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
//
    [_act stopAnimating];

    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

}


#pragma mark - Request BCA ClickPay
-(void)requestSuccessBCAClickPay:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionBuy *BCAClickPay = stat;

    NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:BCAClickPay.result?:[TransactionBuyResult new]};
    [_delegate didFinishRequestBuyData:userInfo?:@{}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];

    //
    [_act stopAnimating];
    
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

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

- (void)refreshCartAfterCancelPayment {
    
}

#pragma mark - Delegate LoadingView
- (void)pressRetryButton {
    [self refreshRequestCart];
}

-(TransactionObjectManager*)objectManager
{
    if (_objectManager) {
        _objectManager = [TransactionObjectManager new];
    }
    return _objectManager;
}


#pragma mark - Sending data to GA 
- (void)sendingProductDataToGA {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                                           action:@"Checkout"
                                                                            label:nil
                                                                            value:nil];
    
    // Add the step number and additional info about the checkout to the action.
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckout];
    [action setCheckoutStep:(_indexPage == 0)?@1:@2];
    [action setCheckoutOption:[_dataInput objectForKey:@"gateway"]];
    
    for(TransactionCartList *list in _cart.list) {
        for(ProductDetail *detailProduct in list.cart_products) {
            GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
            [product setId:detailProduct.product_id?:@""];
            [product setName:detailProduct.product_name?:@""];
            [product setCategory:[NSString stringWithFormat:@"%zd", detailProduct.product_department_id]];
            [product setPrice:@([detailProduct.product_price integerValue])];
            [product setQuantity:@([detailProduct.product_quantity integerValue])];
            
            [builder addProduct:product];
            [builder setProductAction:action];
        }
    }
    [tracker send:[builder build]];
}

@end
