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

#import "TxEmoney.h"

#import "TokopediaNetworkManager.h"

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
    TokopediaNetworkManagerDelegate
>
{
    NSMutableArray *_list;
    
    TransactionCartResult *_cart;
    TransactionSummaryDetail *_cartSummary;
    TransactionBuyResult *_cartBuy;
    
    NSMutableDictionary *_dataInput;
    
    BOOL _isnodata;
    BOOL _isRefreshRequest;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    UIRefreshControl *_refreshControl;
    
    BOOL _isaddressexpanded;
    __weak RKObjectManager *_objectManagerCart;
    __weak RKManagedObjectRequestOperation *_requestCart;
    
    __weak RKObjectManager *_objectManagerActionCancelCart;
    __weak RKManagedObjectRequestOperation *_requestActionCancelCart;
    
    __weak RKObjectManager *_objectManagerActionCheckout;
    __weak RKManagedObjectRequestOperation *_requestActionCheckout;
    
    __weak RKObjectManager *_objectManagerActionBuy;
    __weak RKManagedObjectRequestOperation *_requestActionBuy;
    
    __weak RKObjectManager *_objectManagerActionVoucher;
    __weak RKManagedObjectRequestOperation *_requestActionVoucher;
    
    __weak RKObjectManager *_objectManagerActionEditProductCart;
    __weak RKManagedObjectRequestOperation *_requestActionEditProductCart;
    
    __weak RKObjectManager *_objectManagerEMoney;
    __weak RKManagedObjectRequestOperation *_requestEMoney;
    
    __weak RKObjectManager *_objectManagerBCAClickPay;
    __weak RKManagedObjectRequestOperation *_requestBCAClickPay;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    NSMutableArray *_isDropshipper;
    NSMutableArray *_stockPartialDetail;
    NSMutableArray *_stockPartialStrList;
    
    NSMutableArray *_senderNameDropshipper;
    NSMutableArray *_senderPhoneDropshipper;
    NSMutableArray *_dropshipStrList;
    NSMutableArray *_listProductFirstObjectIndexPath;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    BOOL _isUsingSaldoTokopedia;
    
    TransactionObjectMapping *_mapping;
    BOOL _isLoadingRequest;
    
    BOOL _refreshFromShipment;
    
    NavigateViewController *_navigate;
    
    NSString *_saldoTokopedia;
    NSIndexPath *_switchSaldoIndexPath;
    
    NSMutableDictionary *_textAttributes;
    
    TokopediaNetworkManager *_networkManager;
    TransactionCartShippingViewController *_shipmentViewController;
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

-(void)cancelActionCancelCartRequest;
-(void)configureRestKitActionCancelCart;
-(void)requestActionCancelCart:(id)object;
-(void)requestSuccessActionCancelCart:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionCancelCart:(id)object;
-(void)requestProcessActionCancelCart:(id)object;
-(void)requestTimeoutActionCancelCart;

-(void)cancelActionCheckout;
-(void)configureRestKitActionCheckout;
-(void)requestActionCheckout:(id)object;
-(void)requestSuccessActionCheckout:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionCheckout:(id)object;
-(void)requestProcessActionCheckout:(id)object;
-(void)requestTimeoutActionCheckout;

-(void)cancelActionBuy;
-(void)configureRestKitActionBuy;
-(void)requestActionBuy:(id)object;
-(void)requestSuccessActionBuy:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionBuy:(id)object;
-(void)requestProcessActionBuy:(id)object;
-(void)requestTimeoutActionBuy;

-(void)cancelActionEditProductCartRequest;
-(void)configureRestKitActionEditProductCart;
-(void)requestActionEditProductCart:(id)object;
-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionEditProductCart:(id)object;
-(void)requestProcessActionEditProductCart:(id)object;
-(void)requestTimeoutActionEditProductCart;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucherUsedCell;

- (IBAction)tap:(id)sender;
@end

#define TAG_ALERT_PARTIAL 13
#define DATA_PARTIAL_SECTION @"data_partial"
#define DATA_CART_GRAND_TOTAL_BEFORE_DECREASE @"data_grand_totoal"
#define DATA_DETAIL_CART_FOR_SHIPMENT @"data_detail_cart_fort_shipment"

#define TAG_REQUEST_CART 10
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
    _listProductFirstObjectIndexPath =[NSMutableArray new];
    _mapping = [TransactionObjectMapping new];
    _navigate = [NavigateViewController new];
    _shipmentViewController = [TransactionCartShippingViewController new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.tagRequest = TAG_REQUEST_CART;
    _networkManager.delegate = self;

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:SHOULD_REFRESH_CART
                                               object:nil];

    if (_indexPage == 0) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
        [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
        
        [_networkManager doRequest];
    }
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _networkManager.delegate = self;
    
    self.navigationController.title = @"Keranjang";
    
    if (_indexPage == 0) {
        if (_shouldRefresh) {
            [self refreshRequestCart];
        }
        TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
        [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:selectedGateway.gateway_name?:@"Pilih"];
    }
    else
    {
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
    
    if(!_requestCart.executing && !_isnodata) _tableView.tableFooterView = (_indexPage==1)?_buyView:_checkoutView;

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
    
    if (_shouldRefresh) {
        _shouldRefresh = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    self.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count + 1;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    if (_indexPage == 0) {
        sectionCount = sectionCount +1;
    }
    if (_indexPage == 0 &&
        ![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] &&
        ![selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] &&
        !([self depositAmountUser] == 0) ) {
        sectionCount = sectionCount+1;
    }
    
    if (_indexPage==1 && [_cartSummary.deposit_amount integerValue]>0)
        sectionCount = sectionCount+1;

    return _isnodata?0:sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger listCount = _list.count;
    NSInteger rowCount;
    NSArray *gatewayList = _cart.gateway_list;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    
    BOOL isNullDeposit = YES;
    for (TransactionCartGateway *gateway in gatewayList) {
        if([gateway.gateway  isEqual:@(0)]) isNullDeposit = NO;
    }
    
    if (section == listCount) {
        switch ([_cartSummary.gateway integerValue]) {
            case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
            case TYPE_GATEWAY_MANDIRI_E_CASH:
            case TYPE_GATEWAY_CLICK_BCA:
                rowCount = 2; //Total Invoice, Total Pembayaran
                break;
            default:
                if (_indexPage == 0)
                    rowCount = 1; // Row Kode Promo Tokopedia
                else
                {
                    rowCount = 3; // Total Invoice, Total Pembayaran, Kode transfer / Tokopedia Terpakai
                }
                break;
        }
        
        if ([_cartSummary.deposit_amount integerValue]>0&&[_cartSummary.gateway integerValue]!=TYPE_GATEWAY_TOKOPEDIA) {
            rowCount +=1; //Row Gunakan Saldo Tokopedia
        }
        if ([_cartSummary.voucher_amount integerValue]>0) {
            rowCount +=1; //Row Voucher Amount
        }
    }
    else if (section < listCount) {
        TransactionCartList *list = _list[section];
        NSArray *products = list.cart_products;
        
        if (((TransactionCartList*)_list[section]).cart_products.count <=0) {
            return 0;
        }
        if (_indexPage == 0) {
            NSIndexPath *indexPathFirstObjectProduct = _listProductFirstObjectIndexPath[section];
            rowCount = indexPathFirstObjectProduct.row+products.count+3; //Detail Pengiriman, Partial, Dropshipper
        }
        else
            rowCount = products.count+1; //Detail Pengiriman
        
        if (_indexPage==0)
        {
            if (_isDropshipper.count>0) {
                if ([_isDropshipper[section] boolValue] == YES ) {
                    rowCount +=2; //Receiver Name, Receiver phone
                }
            }
        }
    }
    else if (_indexPage == 0 && section == listCount+1 &&
             ![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] &&
             ![selectedGateway.gateway isEqual:@(NOT_SELECT_GATEWAY)] &&
             !([self depositAmountUser] == 0))
        rowCount = _isUsingSaldoTokopedia?2:1;
    else rowCount = 1;
    
    return _isnodata?0:rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;

    NSInteger shopCount = _list.count;
    
    if (indexPath.section <shopCount)
        cell = [self cellListCartByShopAtIndexPath:indexPath];
    else if (indexPath.section == shopCount)
        cell = [self cellPaymentInformationAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+1 && _indexPage == 0)
        cell = [self cellAdjustDepositAtIndexPath:indexPath];
    else if (indexPath.section == shopCount+2 &&_indexPage == 0)
    {
        cell = _totalPaymentCell;
        [cell.detailTextLabel setText:_cart.grand_total_idr];
    }
    else
        cell = _passwordCell;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define DEFAULT_ROW_HEIGHT 44
#define CELL_PRODUCT_ROW_HEIGHT 212
    
    NSInteger listCount = _list.count;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

    if (indexPath.section < listCount)
    {
        TransactionCartList *list = _list[indexPath.section];
        NSArray *products = list.cart_products;
        
        NSIndexPath *indexPathFirstObjectProduct = (_indexPage == 0)?(NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section]:[NSIndexPath indexPathForRow:0 inSection:0];

        //adjust height error message by shop
        if (indexPath.row < indexPathFirstObjectProduct.row) {
            ((UILabel*)_errorLabel[0]).text = list.cart_error_message_1;
            NSString *error1 = [list.cart_error_message_1 isEqualToString:@"0"]?@"":list.cart_error_message_1;
            NSString *error2 = [list.cart_error_message_2 isEqualToString:@"0"]?@"":list.cart_error_message_2;
            NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
            CGSize maximumLabelSize = CGSizeMake(290,9999);
            UILabel *errorLabel = (UILabel*)_errorLabel[0];
            [errorLabel setCustomAttributedText:string];
            CGSize expectedLabelSize = [string sizeWithFont:errorLabel.font
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:errorLabel.lineBreakMode];
            
            return expectedLabelSize.height+40;
        }
        else if (labs(indexPathFirstObjectProduct.row-indexPath.row)<products.count) {
            return CELL_PRODUCT_ROW_HEIGHT;
        }
        else
        {
            if ( indexPath.row == indexPathFirstObjectProduct.row+2 && [list.cart_total_product integerValue]<=1) {
                //adjust total partial cell tidak muncul ketika jumlah barang hanya 1
                return 0;
            }
            return DEFAULT_ROW_HEIGHT;
        }
        
    }
    else if (indexPath.section == listCount)
    {
        NSArray *gatewayList = _cart.gateway_list;
        BOOL isNullDeposit = YES;
        for (TransactionCartGateway *gateway in gatewayList) {
            if([gateway.gateway  isEqual:@(0)]) isNullDeposit = NO;
        }
        if (indexPath.row == 1) {
            return ([selectedGateway.gateway isEqual: @(TYPE_GATEWAY_TOKOPEDIA)])?_totalPaymentCell.frame.size.height:(_indexPage==0)?_saldoTokopediaCell.frame.size.height:DEFAULT_ROW_HEIGHT;
        }

        else
            return DEFAULT_ROW_HEIGHT;
    }
    else return DEFAULT_ROW_HEIGHT;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < _list.count) return 44;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
#define HEIGHT_VIEW_SUBTOTAL 156
#define HEIGHT_VIEW_TOTAL_DEPOSIT 30
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSInteger listCount = _list.count;
    
    if (section < listCount)
        return HEIGHT_VIEW_SUBTOTAL;
    else if(section == listCount)
    {
        if (_indexPage==1 && [_cartSummary.deposit_amount integerValue]>0) {
            return 0;
        }
    }
    else if (section == _list.count+1 && _indexPage == 0) {
        if (![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] &&
            ![selectedGateway.gateway isEqual:@(-1)] &&
            !([self depositAmountUser] == 0)) {
            return HEIGHT_VIEW_TOTAL_DEPOSIT;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLoadingRequest) {
        NSInteger listCount = _list.count;
        if (indexPath.section == listCount)
        {
            if (indexPath.row == 1) {
                
            }
        }
        else if (indexPath.section < listCount) {
            NSIndexPath *indexPathFirstObjectProduct = (_indexPage == 0)?(NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section]:[NSIndexPath indexPathForRow:0 inSection:0];
            TransactionCartList *list = _list[indexPath.section];
            NSArray *products = list.cart_products;
            NSInteger rowCount = products.count;
            
            
            if (indexPath.row == indexPathFirstObjectProduct.row+rowCount) {
                [self pushShipmentIndex:indexPath.section];
            }
            else if (indexPath.row == indexPathFirstObjectProduct.row+rowCount+1)
            {
                AlertPickerView *picker = [AlertPickerView newview];
                picker.delegate = self;
                [_dataInput setObject:@(indexPath.section) forKey:DATA_PARTIAL_SECTION];
                picker.pickerData =ARRAY_IF_STOCK_AVAILABLE_PARTIALLY;
                picker.tag = TAG_ALERT_PARTIAL;
                [picker show];
            }
        }
        else
        {
            [_passwordTextField becomeFirstResponder];
        }
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

    if (!_shipmentViewController) {
        _shipmentViewController = [TransactionCartShippingViewController new];
    }
    _shipmentViewController.data = @{DATA_CART_DETAIL_LIST_KEY:list,
                                    DATA_DROPSHIPPER_NAME_KEY: dropshipName,
                                    DATA_DROPSHIPPER_PHONE_KEY:dropshipPhone,
                                    DATA_PARTIAL_LIST_KEY :partial,
                                    DATA_INDEX_KEY : @(index)
                                    };
    [_dataInput setObject:list forKey:DATA_DETAIL_CART_FOR_SHIPMENT];
    _shipmentViewController.indexPage = _indexPage;
    _shipmentViewController.delegate = self;
    [self.navigationController pushViewController:_shipmentViewController animated:YES];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
}

#pragma mark - Request Cart
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        return [self objectManagerCart];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    return @{};
}

-(NSString *)getPath:(int)tag
{
    return API_TRANSACTION_PATH;
}

-(void)actionBeforeRequest:(int)tag
{
    if ([((UILabel*)_selectedPaymentMethodLabels[0]).text isEqualToString:@"Pilih"]) {
        [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
    }
    
    _tableView.tableFooterView = _footerView;
    [_act startAnimating];
    _isLoadingRequest = YES;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    TransactionCart *cart = stat;
    
    return cart.status;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
    _isLoadingRequest = NO;
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCart *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(cart.message_error)
        {
            NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            
            [_list removeAllObjects];
            
            NSArray *list = cart.result.list;
            [_list addObjectsFromArray:list];
            
            _cart = cart.result;
            
            [self adjustAfterUpdateList];
            
            if (_shipmentViewController) {
                NSInteger index = [[_dataInput objectForKey:DATA_INDEX_KEY] integerValue];
                _shipmentViewController.data = @{DATA_CART_DETAIL_LIST_KEY:list[index],
                                                 DATA_INDEX_KEY : @(index)
                                                 };
                [_dataInput setObject:list forKey:DATA_DETAIL_CART_FOR_SHIPMENT];
                _shipmentViewController.indexPage = _indexPage;
                _shipmentViewController.delegate = self;
            }
        }
    }
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
    _isLoadingRequest = NO;
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
    _isLoadingRequest = NO;
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
    }
    [_delegate isNodata:_isnodata];
    
    
    NSInteger listCount = _list.count;
    
    if (!_refreshFromShipment) {
        [self resetAllArray];
    }
    [_listProductFirstObjectIndexPath removeAllObjects];
    
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        
        NSArray *products = list.cart_products;
        NSInteger productCount = products.count;
        
        NSIndexPath *firstProductIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        if (![list.cart_error_message_1 isEqualToString:@"0"]||![list.cart_error_message_2 isEqualToString:@"0"])
            firstProductIndexPath = [NSIndexPath indexPathForRow:1 inSection:i];
        [_listProductFirstObjectIndexPath addObject:firstProductIndexPath];
        
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
            [_listProductFirstObjectIndexPath removeObjectAtIndex:i];
        }
        
    }
    if (listCount>0) {
        NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:[_dataInput objectForKey:DATA_DETAIL_CART_FOR_SHIPMENT]?:[TransactionCartList new]};
        [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil userInfo:info];

        
        if (_indexPage == 0) {
            _paymentMethodView.hidden = NO;
            _paymentMethodSelectedView.hidden = YES;
            _checkoutView.hidden = NO;
            _tableView.tableFooterView = _checkoutView;
        }
        else if (_indexPage == 1) {
            _paymentMethodView.hidden = YES;
            _paymentMethodSelectedView.hidden = NO;
            _buyView.hidden = NO;
            _tableView.tableFooterView = _buyView;
        }
    }
    
    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    NSNumber *grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    NSString *depositAmount = [_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSInteger deposit = [depositAmount integerValue];
    NSInteger grandTotalInteger = [grandTotal integerValue] - deposit;
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];

    _cart.grand_total_idr = [[[self grandTotalFormater] stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
    
    _grandTotalLabel.text = ([_cart.grand_total integerValue]<=0)?@"Rp 0,-":_cart.grand_total_idr;
    
    if (_firstInit) _firstInit = NO;
    
    [self adjustDropshipperListParam];
    [self adjustPartialListParam];
    
    _refreshFromShipment = NO;
    
    [_tableView reloadData];

}

#pragma mark - Request Cancel Cart
-(void)cancelActionCancelCartRequest
{
    [_requestActionCancelCart cancel];
    _requestActionCancelCart = nil;
    [_objectManagerActionCancelCart.operationQueue cancelAllOperations];
    _objectManagerActionCancelCart = nil;
}

-(void)configureRestKitActionCancelCart
{
    _objectManagerActionCancelCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionCancelCart addResponseDescriptor:responseDescriptor];
    
}

//# sub cancel_cart example URL
//# www.tkpdevel-pg.ekarisky/ws/action/tx-cart.pl?action=cancel_cart&
//# product_cart_id=&
//# address_id=&
//# shop_id=&
//# shipment_id=&
//# shipment_package_id=&

-(void)requestActionCancelCart:(id)object
{
    if (_requestActionCancelCart.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    NSIndexPath *indexPathCancelProduct = [userInfo objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    
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

    
    _requestActionCancelCart = [_objectManagerActionCancelCart appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionCancelCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCancelCart:mappingResult withOperation:operation];
        [timer invalidate];
        [_refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCancelCart:error];
        [timer invalidate];
        [_refreshControl endRefreshing];
    }];
    
    [_operationQueue addOperation:_requestActionCancelCart];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionCancelCart) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionCancelCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionCancelCart:object];
    }
}

-(void)requestFailureActionCancelCart:(id)object
{
    [self requestProcessActionCancelCart:object];
}

-(void)requestProcessActionCancelCart:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(action.message_error)
                {
                    NSArray *errorMessages = action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                else{
                    if (action.result.is_success == 1) {

                        NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                        [alert show];
                        
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
                        
                        
                        [self adjustAfterUpdateList];
                                                
                        [self refreshView:nil];
                        
                    }
                }
            }
        }
        else{
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = [[[error userInfo]objectForKey:NSUnderlyingErrorKey]localizedDescription];
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionCancelCart
{
    [self cancelActionCancelCartRequest];
}

#pragma mark - Request Checkout
-(void)cancelActionCheckout
{
    [_requestActionCancelCart cancel];
    _requestActionCancelCart = nil;
    [_objectManagerActionCancelCart.operationQueue cancelAllOperations];
    _objectManagerActionCancelCart = nil;
}

-(void)configureRestKitActionCheckout
{
    _objectManagerActionCheckout = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionSummary class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionSummaryResult class]];

    RKObjectMapping *transactionMapping = [_mapping transactionDetailSummaryMapping];
    RKObjectMapping *listMapping        = [_mapping transactionCartListMapping];
    RKObjectMapping *productMapping     = [_mapping productMapping];
    RKObjectMapping *addressMapping     = [_mapping addressMapping];
    RKObjectMapping *shipmentsMapping   = [_mapping shipmentsMapping];
    RKObjectMapping *shopinfoMapping    = [_mapping shopInfoMapping];
    
    NSInteger gatewayID = [[_dataInput objectForKey:API_GATEWAY_LIST_ID_KEY]integerValue];
    if(gatewayID == TYPE_GATEWAY_CLICK_BCA){
        RKObjectMapping *BCAParamMapping = [_mapping BCAParamMapping];
        RKRelationshipMapping *bcaParamRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_BCA_PARAM_KEY
                                                                                         toKeyPath:API_BCA_PARAM_KEY
                                                                                       withMapping:BCAParamMapping];
        [transactionMapping addPropertyMapping:bcaParamRel];
    }
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY
                                                                                  toKeyPath:API_TRANSACTION_SUMMARY_KEY
                                                                                withMapping:transactionMapping]];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                                 toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET
                                                                                               withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY
                                                                                toKeyPath:API_CART_DESTINATION_KEY
                                                                              withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY
                                                                                toKeyPath:API_CART_SHOP_KEY
                                                                              withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY
                                                                                    toKeyPath:API_CART_PRODUCTS_KEY
                                                                                  withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY
                                                                                     toKeyPath:API_CART_SHIPMENTS_KEY
                                                                                   withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                toKeyPath:kTKPD_APIRESULTKEY
                                                                              withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_TRANSACTION_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionCheckout addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionCheckout:(id)object
{
    if (_requestActionCheckout.isExecuting) return;
    
    NSTimer *timer;
    
    [self adjustDropshipperListParam];
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
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
    NSDictionary *dropshipperDetail = [userInfo objectForKey:DATA_DROPSHIPPER_LIST_KEY]?:@{};
    
    NSString * partialString = [[tempPartialStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];
    NSDictionary *partialDetail = [userInfo objectForKey:DATA_PARTIAL_LIST_KEY]?:@{};
    
    NSNumber *usedSaldo = _isUsingSaldoTokopedia?[_dataInput objectForKey:DATA_USED_SALDO_KEY]?:@"0":@"0";
    
    NSString *voucherCode = [userInfo objectForKey:API_VOUCHER_CODE_KEY]?:@"";
    
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
    
    _checkoutButton.enabled = NO;
    _checkoutButton.layer.opacity = 0.8;
    _requestActionCheckout = [_objectManagerActionCheckout appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_checkoutButton setTitle:@"Processing" forState:UIControlStateNormal];
    [_requestActionCheckout setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         _checkoutButton.enabled = YES;
        [self requestSuccessActionCheckout:mappingResult withOperation:operation];
        [timer invalidate];
        _tableView.tableFooterView = (_indexPage==1)?_buyView:_checkoutView;
        [_checkoutButton setTitle:@"Checkout" forState:UIControlStateNormal];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         _checkoutButton.enabled = YES;
        [self requestFailureActionCheckout:error];
        _tableView.tableFooterView = (_indexPage==1)?_buyView:_checkoutView;
        [timer invalidate];
        [_checkoutButton setTitle:@"Checkout" forState:UIControlStateNormal];
    }];
    

    [_operationQueue addOperation:_requestActionCheckout];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionCheckout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionCheckout:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionSummary *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionCheckout:object];
    }
}

-(void)requestFailureActionCheckout:(id)object
{
    [self requestProcessActionCheckout:object];
}

-(void)requestProcessActionCheckout:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionSummary *cart = stat;
            BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(cart.message_error)
                {
                    NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                else{
                    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
                    NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:cart.result.transaction?:[TransactionSummaryDetail new],
                                               DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper?:@"",
                                               DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper?:@"",
                                               DATA_PARTIAL_LIST_KEY:_stockPartialStrList?:@{},
                                               DATA_TYPE_KEY:@(TYPE_CART_SUMMARY),
                                               DATA_CART_GATEWAY_KEY :selectedGateway
                                               };
                    [_delegate didFinishRequestCheckoutData:userInfo];
                }
                if(cart.message_status)
                {
                    NSArray *successMessages = cart.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                }
            }
        }
        else{
            
            [self cancelActionCheckout];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = [[[error userInfo]objectForKey:NSUnderlyingErrorKey]localizedDescription];
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionCheckout
{
    [self cancelActionCheckout];
}

#pragma mark - Request Buy
-(void)cancelActionBuy
{
    [_requestActionCancelCart cancel];
    _requestActionCancelCart = nil;
    [_objectManagerActionCancelCart.operationQueue cancelAllOperations];
    _objectManagerActionCancelCart = nil;
}

-(void)configureRestKitActionBuy
{
    _objectManagerActionBuy = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY,
                                                   API_LINK_MANDIRI_KEY]];

    RKObjectMapping *systemBankMapping = [_mapping systemBankMapping];
    RKObjectMapping *transactionMapping = [_mapping transactionDetailSummaryMapping];
    RKObjectMapping *listMapping = [_mapping transactionCartListMapping];
    RKObjectMapping *productMapping = [_mapping productMapping];
    RKObjectMapping *addressMapping = [_mapping addressMapping];
    RKObjectMapping *shipmentsMapping = [_mapping shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [_mapping shopInfoMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
    
    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY toKeyPath:API_SYSTEM_BANK_KEY withMapping:systemBankMapping];
    [resultMapping addPropertyMapping:systemBankRel];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionBuy addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionBuy:(id)object
{
    if (_requestActionBuy.isExecuting) return;
    
    NSTimer *timer;
    
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
    
    _buyButton.enabled = NO;
    _buyButton.layer.opacity = 0.8;
    
    UIAlertView *alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alertLoading show];

    _requestActionBuy = [_objectManagerActionBuy appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_buyButton setTitle:@"Processing" forState:UIControlStateNormal];
    [_requestActionBuy setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionBuy:mappingResult withOperation:operation];
        [timer invalidate];
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionBuy:error];
        [timer invalidate];
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }];
    
    [_operationQueue addOperation:_requestActionBuy];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionBuy) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
}

-(void)requestSuccessActionBuy:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionBuy *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionBuy:object];
    }
}

-(void)requestFailureActionBuy:(id)object
{
    [self requestProcessActionBuy:object];
}

-(void)requestProcessActionBuy:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionBuy *cart = stat;
            BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(cart.message_error)
                {

                    NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                    
                    switch ([_cartSummary.gateway integerValue]) {
                        case TYPE_GATEWAY_TRANSFER_BANK:
                            break;
                        case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                        {
                            //NSDictionary *data = @{DATA_KEY:_dataInput,
                            //                      DATA_CART_SUMMARY_KEY: _cartSummary
                            //                       };
                            //[_delegate pushVC:self toMandiriClickPayVCwithData:data];
                        }
                            break;
                        default:
                            break;
                    }
                }
                if(cart.message_status)
                {
                    NSArray *successMessages = cart.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                }
                if (cart.result.is_success == 1) {
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
                }
            }
        }
        else{
            
            [self cancelActionBuy];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = [[[error userInfo]objectForKey:NSUnderlyingErrorKey]localizedDescription];
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}


-(void)requestTimeoutActionBuy
{
    [self cancelActionBuy];
}

#pragma mark - Request Action Voucher
-(void)cancelActionVoucher
{
    [_requestActionVoucher cancel];
    _requestActionVoucher = nil;
    [_objectManagerActionVoucher.operationQueue cancelAllOperations];
    _objectManagerActionVoucher = nil;
}

-(void)configureRestKitActionVoucher
{
    _objectManagerActionVoucher = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionVoucher class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionVoucherResult class]];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[TransactionVoucherData class]];
    [dataMapping addAttributeMappingsFromArray:@[API_DATA_VOUCHER_AMOUNT_KEY,
                                                 API_DATA_VOUCHER_EXPIRED_KEY,
                                                 API_DATA_VOUCHER_ID_KEY,
                                                 API_DATA_VOUCHER_MINIMAL_AMOUNT_KEY,
                                                 API_DATA_VOUCHER_STATUS_KEY
                                                 ]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_DATA_VOUCHER_KEY toKeyPath:API_DATA_VOUCHER_KEY withMapping:dataMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_CHECK_VOUCHER_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionVoucher addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionVoucher:(id)object
{
    if (_requestActionVoucher.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;

    NSString *voucherCode = [userInfo objectForKey:API_VOUCHER_CODE_KEY];
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_CECK_VOUCHER_CODE,
                            API_VOUCHER_CODE_KEY : voucherCode
                            };
    
    _requestActionVoucher = [_objectManagerActionVoucher appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_CHECK_VOUCHER_PATH parameters:[param encrypt]];
    [_requestActionVoucher setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionVoucher:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionVoucher:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionVoucher];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionVoucher) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionVoucher:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionVoucher *dataVoucher = stat;
    BOOL status = [dataVoucher.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionVoucher:object];
    }
}

-(void)requestFailureActionVoucher:(id)object
{
    [self requestProcessActionVoucher:object];
}

-(void)requestProcessActionVoucher:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionVoucher *dataVoucher = stat;
            BOOL status = [dataVoucher.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(dataVoucher.message_error)
                {
                    [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
                    NSArray *errorMessages = dataVoucher.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                else{
                    _voucherCodeButton.hidden = YES;
                    _voucherAmountLabel.hidden = NO;
                    
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
                    formatter.currencyCode = @"Rp ";
                    formatter.currencyGroupingSeparator = @".";
                    formatter.currencyDecimalSeparator = @",";
                    formatter.maximumFractionDigits = 0;
                    formatter.minimumFractionDigits = 0;
                    
                    NSInteger voucher = [dataVoucher.result.data_voucher.voucher_amount integerValue];
                    NSString *voucherString = [formatter stringFromNumber:[NSNumber numberWithInteger:voucher]];
                    voucherString = [NSString stringWithFormat:@"Anda mendapatkan voucher %@,-", voucherString];
                    _voucherAmountLabel.text = voucherString;
                    _voucherAmountLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
                    
                    _buttonVoucherInfo.hidden = YES;
                    _buttonCancelVoucher.hidden = NO;
                }
            }
        }
        else{
            if ([object code] != NSURLErrorCancelled) {
                
                NSString *errorDescription = [object localizedDescription];
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];

                [_dataInput setObject:@"" forKey:API_VOUCHER_CODE_KEY];
            }
        }
    }
}

-(void)requestTimeoutActionVoucher
{
    [self cancelActionVoucher];
}

#pragma mark - Request Edit Product
-(void)cancelActionEditProductCartRequest
{
    [_requestActionEditProductCart cancel];
    _requestActionEditProductCart = nil;
    [_objectManagerActionEditProductCart.operationQueue cancelAllOperations];
    _objectManagerActionEditProductCart = nil;
}

-(void)configureRestKitActionEditProductCart
{
    _objectManagerActionEditProductCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionEditProductCart addResponseDescriptor:responseDescriptor];
}

-(void)requestActionEditProductCart:(id)object
{
    if (_requestActionEditProductCart.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    ProductDetail *product = [userInfo objectForKey:DATA_PRODUCT_DETAIL_KEY];
    
    NSInteger productCartID = [product.product_cart_id integerValue];
    NSString *productNotes = product.product_notes?:@"";
    NSString *productQty = product.product_quantity?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_EDIT_PRODUCT_CART,
                            API_PRODUCT_CART_ID_KEY : @(productCartID),
                            API_CART_PRODUCT_NOTES_KEY:productNotes,
                            API_PRODUCT_QUANTITY_KEY:productQty
                            };
    
    _requestActionEditProductCart = [_objectManagerActionEditProductCart appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionEditProductCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditProductCart:mappingResult withOperation:operation];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionEditProductCart:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionEditProductCart];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionEditProductCart) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionEditProductCart:object];
    }
}

-(void)requestFailureActionEditProductCart:(id)object
{
    [self requestProcessActionEditProductCart:object];
}

-(void)requestProcessActionEditProductCart:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(action.message_error)
                {
                    NSArray *errorMessages = action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                    [alert show];
                }
                else{
                    if (action.result.is_success == 1) {
                        NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                        [alert show];
                        if (_indexPage == 0) {
                            [_networkManager doRequest];
                            _refreshFromShipment = YES;
                        }
                        [_tableView reloadData];
                    }
                }
            }
        }
        else{
            
            [self cancelActionEditProductCartRequest];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = [[[error userInfo]objectForKey:NSUnderlyingErrorKey]localizedDescription];
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionEditProductCart
{
    [self cancelActionEditProductCartRequest];
}


#pragma mark - Request E-Money
-(void)cancelEMoney
{
    
}

-(void)configureRestKitEMoney
{
    _objectManagerEMoney = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxEmoney class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxEMoneyResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];

    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[TxEMoneyData class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TRACE_NUM_KEY,
                                                   API_STATUS_KEY,
                                                   API_NOMOR_HP_KEY,
                                                   API_TRX_ID_KEY,
                                                   API_ID_EMONEY_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_EMONEY_DATA_KEY toKeyPath:API_EMONEY_DATA_KEY withMapping:dataMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_EMONEY_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerEMoney addResponseDescriptor:responseDescriptor];
}

-(void)requestEMoney:(BOOL)isWSNew
{
    if (_requestEMoney.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{//API_ACTION_KEY : isWSNew?ACTION_START_UP_EMONEY:ACTION_VALIDATE_CODE_EMONEY,
                            API_ACTION_KEY :ACTION_START_UP_EMONEY,
                            API_MANDIRI_ID_KEY : _cartBuy.transaction.emoney_code?:@""};
    
    _requestEMoney = [_objectManagerEMoney appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_EMONEY_PATH parameters:[param encrypt]];
    
    UIAlertView *alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alertLoading show];
    
    [_requestEMoney setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessEMoney:mappingResult withOperation:operation isWSNew:isWSNew];
        [timer invalidate];
        [_act stopAnimating];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureEMoney:error];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
        [timer invalidate];
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestEMoney];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutEMoney) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessEMoney:(id)object withOperation:(RKObjectRequestOperation *)operation isWSNew:(BOOL)isWSNew
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxEmoney *emoney = stat;
    BOOL status = [emoney.status isEqualToString:kTKPDREQUEST_OKSTATUS];

    if (status) {
        //if (isWSNew) {
            if (emoney.result.is_success == 1) {
                NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy?:@{}};
                [_delegate didFinishRequestBuyData:userInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
            }
            else
            {
                StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Pembayaran gagal"] delegate:self];
                [failedAlert show];
                [_delegate shouldBackToFirstPage];
            }
        //}
        //else
        //{
        //    if (emoney.result.is_success == 1) {
        //        if ([emoney.result.data.status rangeOfString:@"FAILED"].location != NSNotFound) {
        //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FAILED" message:@"Pembayaran gagal. Silahkan coba lagi." delegate:self cancelButtonTitle:@"Tutup" otherButtonTitles:nil];
        //            [alert show];
        //        }
        //        else if([emoney.result.data.status rangeOfString:@"SUCCESS"].location != NSNotFound)
        //        {
        //            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy};
        //            [_delegate didFinishRequestBuyData:userInfo];
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        //        }
        //    }
        //}

    }
}

-(void)requestFailureEMoney:(id)object
{
    [self requestProcessEMoney:object];
}

-(void)requestProcessEMoney:(id)object
{

}

-(void)requestTimeoutEMoney
{
    [self cancelEMoney];
}



#pragma mark - Request BCA ClickPay
-(void)cancelBCAClickPay
{
    
}

-(void)configureRestKitBCAClickPay
{
    _objectManagerBCAClickPay = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionBuy class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionBuyResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    RKObjectMapping *systemBankMapping = [_mapping systemBankMapping];
    RKObjectMapping *transactionMapping = [_mapping transactionDetailSummaryMapping];
    RKObjectMapping *listMapping = [_mapping transactionCartListMapping];
    RKObjectMapping *productMapping = [_mapping productMapping];
    RKObjectMapping *addressMapping = [_mapping addressMapping];
    RKObjectMapping *shipmentsMapping = [_mapping shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [_mapping shopInfoMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
    
    RKRelationshipMapping *systemBankRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY toKeyPath:API_SYSTEM_BANK_KEY withMapping:systemBankMapping];
    [resultMapping addPropertyMapping:systemBankRel];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET toKeyPath:API_TRANSACTION_SUMMARY_PRODUCT_KET withMapping:listMapping];
    [transactionMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_BCA_KLICK_PAY_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerBCAClickPay addResponseDescriptor:responseDescriptor];
}

-(void)requestBCAClickPay
{
    if (_requestBCAClickPay.isExecuting) return;
    NSTimer *timer;
    
    
    NSDictionary* param = @{};
    
    _requestBCAClickPay = [_objectManagerBCAClickPay appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_BCA_KLICK_PAY_PATH parameters:[param encrypt]];
    
    UIAlertView *alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alertLoading show];
    
    [_requestBCAClickPay setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessBCAClickPay:mappingResult withOperation:operation];
        [timer invalidate];
        [_act stopAnimating];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureBCAClickPay:error];
        [alertLoading dismissWithClickedButtonIndex:0 animated:YES];
        [timer invalidate];
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_requestBCAClickPay];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutBCAClickPay) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessBCAClickPay:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionBuy *BCAClickPay = stat;
    BOOL status = [BCAClickPay.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (BCAClickPay.result.is_success == 1) {
            
            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:BCAClickPay.result?:[TransactionBuyResult new]};
            [_delegate didFinishRequestBuyData:userInfo?:@{}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        }
        else
        {
            StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Pembayaran gagal"] delegate:self];
            [failedAlert show];
            [_delegate shouldBackToFirstPage];
        }
    }
}

-(void)requestFailureBCAClickPay:(id)object
{
    [self requestProcessBCAClickPay:object];
}

-(void)requestProcessBCAClickPay:(id)object
{
    
}

-(void)requestTimeoutBCAClickPay
{
    [self cancelBCAClickPay];
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
                    
                    [_dataInput setObject:@"" forKey:API_VOUCHER_CODE_KEY];
                }
                    break;
                default:
                    if([self isValidInput]) {
                        [self configureRestKitActionCheckout];
                        [self requestActionCheckout:_dataInput];
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
                        [self configureRestKitActionBuy];
                        [self requestActionBuy:_dataInput];
                    }
                }
                case TYPE_GATEWAY_TRANSFER_BANK:
                    [self configureRestKitActionBuy];
                    [self requestActionBuy:_dataInput];
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
                    break;
                }
                case TYPE_GATEWAY_MANDIRI_E_CASH:
                {
                    [self configureRestKitActionBuy];
                    [self requestActionBuy:_dataInput];
                    break;
                }
                default:
                    break;
            }

        }
    }
}

- (void)changeSwitchSaldo:(UISwitch *)switchSaldo
{
    _isUsingSaldoTokopedia = _isUsingSaldoTokopedia?NO:YES;
    if (_isUsingSaldoTokopedia) {
        [self.tableView beginUpdates];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_switchSaldoIndexPath.row+1 inSection:_switchSaldoIndexPath.section];
        [self.tableView insertRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        [self.tableView beginUpdates];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_switchSaldoIndexPath.row+1 inSection:_switchSaldoIndexPath.section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
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
        _shouldRefresh = NO;
        _refreshFromShipment = YES;
        _networkManager.delegate = self;
        [_networkManager doRequest];
    }
}

-(void)editInsuranceUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
        
        NSInteger index = [[userInfo objectForKey:DATA_INDEX_KEY] integerValue];
        [_dataInput setObject:@(index) forKey:DATA_INDEX_KEY];
        [_list replaceObjectAtIndex:index withObject:[userInfo objectForKey:DATA_CART_DETAIL_LIST_KEY]];
        
        _networkManager.delegate = self;
        [_networkManager doRequest];
        _shouldRefresh = NO;
        _refreshFromShipment = YES;
    }
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    if (_indexPage == 0) {
        [self configureRestKitActionEditProductCart];
        [self requestActionEditProductCart:_dataInput];
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
    NSInteger listCount = _list.count;
    for (int i = 0; i<listCount; i++) {
        NSIndexPath *listProductFirstIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [_listProductFirstObjectIndexPath addObject:listProductFirstIndexPath];
    }
    
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
        if ([password isEqualToString:@""] || !(password)) {
            isValid = NO;
            [messageError addObject:ERRORMESSAGE_NULL_CART_PASSWORD];
        }
    }
    
    for (int i = 0; i<_isDropshipper.count; i++) {
        if (_isDropshipper[i]) {
            if ([_senderNameDropshipper[i] isEqualToString:@""] || _senderNameDropshipper[i]==nil) {
                isValid = NO;
                [messageError addObject:ERRORMESSAGE_SENDER_NAME_NILL];
            }
            if ([_senderPhoneDropshipper[i] isEqualToString:@""] || _senderPhoneDropshipper[i]==nil) {
                isValid = NO;
                [messageError addObject:ERRORMESSAGE_SENDER_PHONE_NILL];
            }
            else if (((NSString*)_senderPhoneDropshipper[i]).length < 6) {
                isValid = NO;
                [messageError addObject:@"Nomor Telephon Harus Lebih Dari 6 Karakter"];
            }
        }
    }
    
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

-(void)refreshView:(UIRefreshControl*)refresh
{
    _isRefreshRequest = YES;
    _networkManager.delegate = self;
    [_networkManager doRequest];
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
    if (!_isLoadingRequest) {
        //NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
        TransactionCartList *list = _list[indexPath.section];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID =[list.cart_shipments.shipment_package_id integerValue];
        
        [_isDropshipper replaceObjectAtIndex:indexPath.section withObject:@(cell.settingSwitch.on)];
        
        if (cell.settingSwitch.on) {
            //NSInteger rowcount = [_rowCountExpandCellForDropshipper[indexPath.section]integerValue];
            //[_rowCountExpandCellForDropshipper replaceObjectAtIndex:indexPath.section withObject:@(rowcount+2)];
            
            [self.tableView beginUpdates];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
            [self.tableView insertRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            
            NSString *dropshipStringObject = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
            [_dropshipStrList replaceObjectAtIndex:indexPath.section withObject:dropshipStringObject];
        }
        else
        {
            //NSInteger rowcount = [_rowCountExpandCellForDropshipper[indexPath.section]integerValue];
            //[_rowCountExpandCellForDropshipper replaceObjectAtIndex:indexPath.section withObject:@(rowcount-2)];
            [self.tableView beginUpdates];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath1, indexPath2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            [_dropshipStrList replaceObjectAtIndex:indexPath.section withObject:@""];
        }
    }
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
    _isRefreshRequest = NO;
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
                    [self configureRestKitActionCancelCart];
                    [self requestActionCancelCart:_dataInput];
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
                    [self configureRestKitActionCancelCart];
                    [self requestActionCancelCart:_dataInput];
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
                    [self configureRestKitActionVoucher];
                    [self requestActionVoucher:_dataInput];
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
    [self configureRestKitActionBuy];
    [self requestActionBuy:_dataInput];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activeTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL isValid = YES;
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
        
        NSNumber *grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
        
        NSString *depositAmount = [textFieldValue stringByReplacingOccurrencesOfString:@"." withString:@""];
        [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];

        NSString *textFieldText = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];

        if (range.length > 0)
        {
            NSString *textFieldRemoveOneChar = [[textField.text substringToIndex:[textField.text length]-1] stringByReplacingOccurrencesOfString:@"." withString:@""];

            NSInteger deposit = [textFieldRemoveOneChar integerValue];
            NSInteger grandTotalInteger = [grandTotal integerValue] - deposit;
            _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
            _cart.grand_total_idr = [[[self grandTotalFormater] stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
            
            _grandTotalLabel.text = ([_cart.grand_total integerValue]<=0)?@"Rp 0,-":_cart.grand_total_idr;
            
            NSString *depositAmount = [textFieldRemoveOneChar stringByReplacingOccurrencesOfString:@"." withString:@""];
            [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];
            
        }
        else if ([textFieldText integerValue] <= [grandTotal integerValue] || [textFieldText integerValue] <= [self depositAmountUser])
        {
            NSInteger deposit = [depositAmount integerValue];
            NSInteger grandTotalInteger = [grandTotal integerValue] - deposit;
            _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
            _cart.grand_total_idr = [[[self grandTotalFormater] stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
            
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
    [self configureRestKitEMoney];
    [self requestEMoney:isWSNew];
}

-(void)shouldDoRequestBCAClickPay
{
    [self configureRestKitBCAClickPay];
    [self requestBCAClickPay];
}

-(void)refreshCartAfterCancelPayment
{
    //[_delegate shouldBackToFirstPage];
}

#pragma mark - Methods
-(void)resetAllArray
{
    [_isDropshipper removeAllObjects];
    [_stockPartialStrList removeAllObjects];
    [_senderNameDropshipper removeAllObjects];
    [_senderPhoneDropshipper removeAllObjects];
    [_dropshipStrList removeAllObjects];
    [_stockPartialDetail removeAllObjects];
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
    if (_shipmentViewController) {
        _shipmentViewController = nil;
    }
}

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

-(NSNumberFormatter*)grandTotalFormater
{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"Rp ";
    formatter.currencyGroupingSeparator = @".";
    formatter.currencyDecimalSeparator = @",";
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    
    return formatter;
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
    [self resetAllArray];
    
    _isnodata = YES;
    [_dataInput removeAllObjects];
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    [_selectedPaymentMethodLabels makeObjectsPerformSelector:@selector(setText:) withObject:@"Pilih"];
    
    _saldoTokopediaAmountTextField.text = @"";
    
    _voucherCodeButton.hidden = NO;
    _voucherAmountLabel.hidden = YES;
    _buttonVoucherInfo.hidden = NO;
    _buttonCancelVoucher.hidden = YES;
    
    [_networkManager doRequest];
}

-(void)popShippingViewController
{
    _networkManager.delegate = self;
    if (_indexPage == 0) {
        [_networkManager doRequest];
        _refreshFromShipment = YES;
    }
}

-(void)setDefaultInputData
{
    _isUsingSaldoTokopedia = NO;
    _switchUsingSaldo.on = _isUsingSaldoTokopedia;
    
    _isnodata = YES;
    _isLoadingRequest = NO;
    _shouldRefresh = NO;
    
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
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    if (section < _list.count)
    {
        return [self CartSubTotalViewAtSection:section];
    }
    else if (section == _list.count+1) {
        if (![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] &&
            ![selectedGateway.gateway isEqual:@(-1)] &&
            !([self depositAmountUser]==0))
        {
            return [self TotalDepositView];
        }
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
    NSString *formatAdditionalFeeValue = [NSString stringWithFormat:@"Rp %zd,-",aditionalFeeValue];
    [view.insuranceLabel setText:formatAdditionalFeeValue animated:YES];
    [view.shippingCostLabel setText:list.cart_shipping_rate_idr animated:YES];
    [view.totalLabel setText:list.cart_total_amount_idr animated:YES];
    
    return view;
}

-(UIView*)TotalDepositView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 34)];
    label.text = [NSString stringWithFormat:@"(Saldo Tokopedia anda %@)", _cart.deposit_idr];
    label.font = [UIFont fontWithName:@"GothamBook" size:12];
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    
    return view;
}

#pragma mark - Table View Cell

-(UITableViewCell *)cellListCartByShopAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger listCount = _list.count;
    
    NSIndexPath *indexPathFirstObjectProduct = (_indexPage == 0)?(NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section]:[NSIndexPath indexPathForRow:0 inSection:0];
    
    TransactionCartList *list = _list[indexPath.section];
    NSArray *products = list.cart_products;
    NSInteger productCount = products.count;
    
    if (indexPath.section < listCount) {
        NSIndexPath *indexPathWithoutErrorCell = [NSIndexPath indexPathForRow:labs(indexPathFirstObjectProduct.row-indexPath.row) inSection:indexPath.section];
        if (indexPath.row<indexPathFirstObjectProduct.row) {
            ((UILabel*)_errorLabel[0]).text = list.cart_error_message_1;
            NSString *error1 = [list.cart_error_message_1 isEqualToString:@"0"]?@"":list.cart_error_message_1;
            NSString *error2 = [list.cart_error_message_2 isEqualToString:@"0"]?@"":list.cart_error_message_2;
            NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
            [(UILabel*)_errorLabel[0] setCustomAttributedText:string];
            cell = _errorCells[indexPath.row];
        }
        else if (labs(indexPathFirstObjectProduct.row-indexPath.row) < productCount)
            cell = [self cellTransactionCartAtIndexPath:indexPathWithoutErrorCell];
        else
        {
            //otherCell
            if (indexPath.row == indexPathFirstObjectProduct.row+productCount)
                cell = [self cellDetailShipmentAtIndexPath:indexPathWithoutErrorCell];
            else if (indexPath.row == indexPathFirstObjectProduct.row+productCount+1)
                cell = [self cellPartialStockAtIndextPath:indexPathWithoutErrorCell];
            else if (indexPath.row == indexPathFirstObjectProduct.row+productCount+2)
                cell = [self cellIsDropshipperAtIndextPath:indexPath];
            else if (indexPath.row > indexPathFirstObjectProduct.row+productCount+2){
                if (indexPath.row == indexPathFirstObjectProduct.row+productCount+3)
                    cell = [self cellTextFieldPlaceholder:@"Nama Pengirim" atIndexPath:indexPath withText:_senderNameDropshipper[indexPath.section]];
                else if (indexPath.row == indexPathFirstObjectProduct.row+productCount+4)
                    cell = [self cellTextFieldPlaceholder:@"Nomer Telepon" atIndexPath:indexPath withText:_senderPhoneDropshipper[indexPath.section]];
            }
        }
    }
    
    return cell;
}

-(UITableViewCell*)cellPaymentInformationAtIndexPath:(NSIndexPath*)indexPath
{
    
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = (_indexPage==0)?_voucerCell:_totalInvoiceCell;
            cell.detailTextLabel.text =_cartSummary.grand_total_before_fee_idr;
            break;
        case 1:
            if ([_cartSummary.deposit_amount integerValue]>0 &&
                [_cartSummary.gateway integerValue]!=TYPE_GATEWAY_TRANSFER_BANK) {
                cell = _usedSaldoCell;
                [cell.detailTextLabel setText:_cartSummary.deposit_amount_idr animated:YES];
            }
            else{
                switch ([_cartSummary.gateway integerValue]) {
                    case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                    case TYPE_GATEWAY_MANDIRI_E_CASH:
                    case TYPE_GATEWAY_CLICK_BCA:
                        cell = _totalPaymentCell;
                        [cell.detailTextLabel setText:(_indexPage==0)?_cart.grand_total_idr:_cartSummary.payment_left_idr animated:YES];
                        break;
                    case TYPE_GATEWAY_TRANSFER_BANK:
                        cell = _transferCodeCell;
                        [cell.detailTextLabel setText:_cartSummary.conf_code_idr animated:YES];
                        break;
                    case TYPE_GATEWAY_TOKOPEDIA:
                        cell = _usedSaldoCell;
                        [cell.detailTextLabel setText:_cartSummary.deposit_amount_idr animated:YES];
                        break;
                    default:
                        break;
                }
            }
            break;
        case 2:
        {
            if (_indexPage == 0) {
                cell = _saldoTextFieldCell;
                [cell.detailTextLabel setText:_cart.grand_total_idr animated:YES];
            }
            else
            {
                if ([_cartSummary.voucher_amount integerValue] >0) {
                    cell = _voucherUsedCell;
                    [cell.detailTextLabel setText:_cartSummary.voucher_amount_idr];
                }
                else
                {
                    cell = ([_cartSummary.deposit_amount integerValue]>0 &&
                            [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)
                    ?_usedSaldoCell:
                    _totalPaymentCell;
                    [cell.detailTextLabel setText:([_cartSummary.deposit_amount integerValue]>0 &&
                                                   [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)?_cartSummary.deposit_amount_idr:_cartSummary.payment_left_idr animated:YES];
                }
            }
            break;
        }
        case 3:
            if ([_cartSummary.voucher_amount integerValue]>0) {
                cell = ([_cartSummary.deposit_amount integerValue]>0 &&
                        [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)
                ?_usedSaldoCell:
                _totalPaymentCell;
                [cell.detailTextLabel setText:([_cartSummary.deposit_amount integerValue]>0 &&
                                               [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)?_cartSummary.deposit_amount_idr:_cartSummary.payment_left_idr animated:YES];
            }
            else
            {
                cell = _totalPaymentCell;
                [cell.detailTextLabel setText:_cartSummary.payment_left_idr animated:YES];
            }
            break;
        case 4:
            cell = _totalPaymentCell;
            [cell.detailTextLabel setText:_cartSummary.payment_left_idr animated:YES];
            break;
        default:
            break;
    }
    return cell;
}

-(UITableViewCell*)cellAdjustDepositAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSArray *gatewayList = _cart.gateway_list;
    BOOL isNullDeposit = YES;
    for (TransactionCartGateway *gateway in gatewayList) {
        if([gateway.gateway  isEqual: @(0)])
            isNullDeposit = NO;
    }
    
    if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)] ||
        [selectedGateway.gateway isEqual:@(-1)] ||
        [self depositAmountUser] == 0
        )
    {
        NSString *depositAmount = [_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSInteger deposit = [depositAmount integerValue];
        NSNumber *grandTotalBefore = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
        NSInteger grandTotal = [grandTotalBefore integerValue] - deposit;
        _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotal]];
        _cart.grand_total_idr = [[[self grandTotalFormater] stringFromNumber:[NSNumber numberWithInteger:grandTotal]] stringByAppendingString:@",-"];
        _grandTotalLabel.text = _cart.grand_total_idr;
        cell = _totalPaymentCell;
        [cell.detailTextLabel setText:_cart.grand_total_idr];
    }
    else
    {
        cell = _saldoTokopediaCell;
        if (indexPath.row == 0) {
            UISwitch *switchSaldo = (UISwitch *)[cell viewWithTag:1];
            [switchSaldo addTarget:self
                            action:@selector(changeSwitchSaldo:)
                  forControlEvents:UIControlEventValueChanged];
            _switchSaldoIndexPath = indexPath;
        }
        if (indexPath.row==1) {
            cell = _saldoTextFieldCell;
        }
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
    NSInteger rowCount = products.count+3;
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 44)];
        textField.placeholder = placeholder;
        textField.text = (indexPath.section==_list.count+1)?@"":(indexPath.row == rowCount)?_senderNameDropshipper[indexPath.section]:_senderPhoneDropshipper[indexPath.section];
        textField.delegate = self;
        if ([placeholder isEqualToString:@"Nama Pengirim"]) {
            textField.tag = indexPath.section+1;
        }
        else
        {
            textField.tag = -indexPath.section -1;
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
    //(list.cart_error_message_1)?indexPath.row-1:indexPath.row;
    //TODO:: adjust when error message appear
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

    [cell.productPriceLabel setText:product.product_total_price_idr animated:YES];
    
    NSString *weightTotal = [NSString stringWithFormat:@"%@ Barang (%@ kg)",product.product_quantity, product.product_total_weight];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName
                             value:FONT_GOTHAM_BOOK_12
                             range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    cell.quantityLabel.attributedText = attributedString;
    
    NSIndexPath *indexPathCell = [NSIndexPath indexPathForRow:indexProduct inSection:indexPath.section];
    ((TransactionCartCell*)cell).indexPath = indexPathCell;
    cell.remarkLabel.text = product.product_notes;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.productThumbImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
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
    
    
    cell.userInteractionEnabled = (_indexPage ==0);
    return cell;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}

- (IBAction)switchUsingSaldo:(id)sender {
}

- (RKObjectManager *)objectManagerCart
{
    _objectManagerCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCart class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCartResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TOKEN_KEY,
                                                   API_DEPOSIT_IDR_KEY,
                                                   API_GRAND_TOTAL_KEY,
                                                   API_GRAND_TOTAL_IDR_KEY,
                                                   API_GATEWAY_LIST_ID_KEY]];
    
    RKObjectMapping *listMapping = [_mapping transactionCartListMapping];
    RKObjectMapping *productMapping = [_mapping productMapping];
    RKObjectMapping *addressMapping = [_mapping addressMapping];
    RKObjectMapping *gatewayMapping = [_mapping gatewayMapping];
    RKObjectMapping *shipmentsMapping = [_mapping shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [_mapping shopInfoMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRelationshipMapping];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_DESTINATION_KEY toKeyPath:API_CART_DESTINATION_KEY withMapping:addressMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHOP_KEY toKeyPath:API_CART_SHOP_KEY withMapping:shopinfoMapping]];
    
    RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_PRODUCTS_KEY toKeyPath:API_CART_PRODUCTS_KEY withMapping:productMapping];
    [listMapping addPropertyMapping:productRel];
    
    RKRelationshipMapping *gatewayRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_GATEAWAY_LIST_KEY toKeyPath:API_GATEAWAY_LIST_KEY withMapping:gatewayMapping];
    [resultMapping addPropertyMapping:gatewayRel];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CART_SHIPMENTS_KEY toKeyPath:API_CART_SHIPMENTS_KEY withMapping:shipmentsMapping];
    [listMapping addPropertyMapping:shipmentRel];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerCart addResponseDescriptor:responseDescriptor];
    
    return _objectManagerCart;

}
@end
