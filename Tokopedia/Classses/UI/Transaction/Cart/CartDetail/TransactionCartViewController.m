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

#import "TransactionObjectMapping.h"

#import "TransactionCartViewController.h"
#import "TransactionCartCell.h"
#import "TransactionCartHeaderView.h"
#import "GeneralSwitchCell.h"
#import "TransactionCartCostView.h"
#import "TransactionCartEditViewController.h"
#import "TransactionCartPaymentViewController.h"
#import "TransactionCartShippingViewController.h"
#import "AlertPickerView.h"
#import "TransactionCartFormMandiriClickPayViewController.h"
#import "TransactionCartWebViewViewController.h"
#import "AlertInfoVoucherCodeView.h"
#import "StickyAlertView.h"

@interface TransactionCartViewController () <UITableViewDataSource,UITableViewDelegate,TransactionCartCellDelegate, TransactionCartHeaderViewDelegate,GeneralSwitchCellDelegate, UIActionSheetDelegate,UIAlertViewDelegate,TransactionCartPaymentViewControllerDelegate, TKPDAlertViewDelegate,UITextFieldDelegate, TransactionCartMandiriClickPayFormDelegate,TransactionCartShippingViewControllerDelegate, TransactionCartEditViewControllerDelegate>
{
    NSMutableArray *_list;
    
    TransactionCartResult *_cart;
    TransactionSummaryDetail *_cartSummary;
    
    NSMutableDictionary *_dataInput;
    
    BOOL _isnodata;
    BOOL _isRefreshRequest;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSDictionary *_auth;
    
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
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    NSMutableArray *_rowCountExpandCellForDropshipper;
    NSMutableArray *_isDropshipper;
     NSMutableArray *_stockPartialDetail;
    NSMutableArray *_stockPartialStrList;
    
    NSMutableArray *_senderNameDropshipper;
    NSMutableArray *_senderPhoneDropshipper;
    NSMutableArray *_dropshipStrList;
    NSMutableArray *_cartErrorMessage;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    BOOL _isUsingSaldoTokopedia;
    
    NSMutableArray *_listProductFirstObjectIndexPath;
    
    TransactionObjectMapping *_mapping;
    BOOL _isLoadingRequest;
}

@property (weak, nonatomic) IBOutlet UIView *voucherCodeView;
@property (weak, nonatomic) IBOutlet UIView *voucerCodeBeforeTapView;
@property (weak, nonatomic) IBOutlet UILabel *valueVoucherCodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *voucherCodeButton;

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
@property (strong, nonatomic) IBOutlet UIView *saldoTokopediaView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalPaymentCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *buySummaryCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *saldoTokopediaCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *saldoTokopediaLabel;
@property (weak, nonatomic) IBOutlet UIButton *isUsingSaldoTokopediaButton;

-(void)cancelCartRequest;
-(void)configureRestKitCart;
-(void)requestCart;
-(void)requestSuccessCart:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureCart:(id)object;
-(void)requestProcessCart:(id)object;
-(void)requestTimeoutCart;

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

- (IBAction)tap:(id)sender;
@end

@implementation TransactionCartViewController
@synthesize indexPage =_indexPage;
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _rowCountExpandCellForDropshipper = [NSMutableArray new];
    _isDropshipper = [NSMutableArray new];
    _stockPartialStrList = [NSMutableArray new];
    _senderNameDropshipper = [NSMutableArray new];
    _senderPhoneDropshipper = [NSMutableArray new];
    _dropshipStrList = [NSMutableArray new];
    _cartErrorMessage = [NSMutableArray new];
    _stockPartialDetail = [NSMutableArray new];
    _listProductFirstObjectIndexPath =[NSMutableArray new];
    _mapping = [TransactionObjectMapping new];

    _isUsingSaldoTokopedia = NO;
    _isUsingSaldoTokopediaButton.layer.borderColor = [UIColor blackColor].CGColor;
    _isUsingSaldoTokopediaButton.layer.borderWidth = 1;
    _isUsingSaldoTokopediaButton.layer.cornerRadius = 2;
    _checkoutButton.layer.cornerRadius = 2;
    
    _errorCells = [NSArray sortViewsWithTagInArray:_errorCells];
    _errorLabel = [NSArray sortViewsWithTagInArray:_errorLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
    
    _isnodata = YES;
    _isLoadingRequest = NO;
    _shouldRefresh = NO;
    
    if (_indexPage == 0) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
        [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
        
        [self configureRestKitCart];
        [self requestCart];
        
        _voucherCodeView.hidden = YES;
        _voucherCodeButton.hidden = NO;
        _voucerCodeBeforeTapView.hidden = NO;
        _valueVoucherCodeLabel.hidden = YES;
    }
    
    TransactionCartGateway *gateway = [TransactionCartGateway new];
    gateway.gateway = @(-1);
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_indexPage==1)[self adjustTableViewData:_data];
    if (_shouldRefresh) {
        _isnodata = YES;
        [self configureRestKitCart];
        [self requestCart];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count + 2;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    if (_indexPage == 0) {
        sectionCount = sectionCount +1;
    }
    if (_indexPage == 0 && ![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)]) {
        sectionCount = sectionCount+1;
    }
    if (_indexPage==1 && [_cartSummary.deposit_amount integerValue]>0)
        sectionCount = sectionCount+1;

#ifdef TRANSACTION_NODATA_ENABLE
    return _isnodata?1:sectionCount;
#else
    return _isnodata?0:sectionCount;
#endif
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger listCount = _list.count;
    NSInteger rowCount;
    NSArray *gatewayList = _cart.gateway_list;
    BOOL isNullDeposit = YES;
    for (TransactionCartGateway *gateway in gatewayList) {
        if([gateway.gateway  isEqual:@(0)]) isNullDeposit = NO;
    }
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

    if (section == 0) rowCount = 1;
    else if (section == listCount+1) {
        switch ([_cartSummary.gateway integerValue]) {
            case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
            case TYPE_GATEWAY_MANDIRI_E_CASH:
            case TYPE_GATEWAY_CLICK_BCA:
                rowCount = 2;
                if ([_cartSummary.deposit_amount integerValue]>0) {
                    rowCount +=1;
                }
                break;
            default:
                if (_indexPage == 0)
                    rowCount = 1;
                else rowCount = ([_cartSummary.deposit_amount integerValue]>0&&[_cartSummary.gateway integerValue]!=TYPE_GATEWAY_TOKOPEDIA)?4:3;
                break;
        }
    }
    else if (section <= listCount) {
        TransactionCartList *list = _list[section-1];
        NSArray *products = list.cart_products;
        NSIndexPath *indexPathFirstObjectProduct = (NSIndexPath*)_listProductFirstObjectIndexPath[section-1];
        rowCount = (_indexPage==0)?indexPathFirstObjectProduct.row+[_rowCountExpandCellForDropshipper[section-1]integerValue]:indexPathFirstObjectProduct.row+products.count+1;
    }
    else if (_indexPage == 0 && section == listCount+2 && ![selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)])
        rowCount = _isUsingSaldoTokopedia?2:1;
    else rowCount = 1;
    
#ifdef TRANSACTION_NODATA_ENABLE
    return _isnodata?1:1;
#else
    return _isnodata?0:rowCount;
#endif
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;

    NSInteger listCount = _list.count;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    _isUsingSaldoTokopediaButton.selected = _isUsingSaldoTokopedia;
    NSArray *gatewayList = _cart.gateway_list;
    BOOL isNullDeposit = YES;
    for (TransactionCartGateway *gateway in gatewayList) {
        if([gateway.gateway  isEqual: @(0)])
            isNullDeposit = NO;
    }
    if (indexPath.section == 0) {
        if (_indexPage == 0) {
            cell = _paymentGatewayCell;
            cell.detailTextLabel.text = selectedGateway.gateway_name?:STRING_DEFAULT_PAYMENT;

        }
        else
        {
            cell = _paymentGatewaySummaryCell;
            cell.textLabel.text = [NSString stringWithFormat:FORMAT_PAYMENT_METHOD,_cartSummary.gateway_name?:@""];

        }

    }
    else if (indexPath.section > 0 && indexPath.section <=listCount)
    {
        NSIndexPath *indexPathFirstObjectProduct = (NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section-1];
        TransactionCartList *list = _list[indexPath.section-1];
        NSArray *products = list.cart_products;
        NSInteger rowCount = products.count;
        
        if (indexPath.section <= listCount) {
            NSIndexPath *indexPathWithoutErrorCell = [NSIndexPath indexPathForRow:labs(indexPathFirstObjectProduct.row-indexPath.row) inSection:indexPath.section];
            if (indexPath.row<indexPathFirstObjectProduct.row) {
                ((UILabel*)_errorLabel[0]).text = list.cart_error_message_1;
                NSString *string = list.cart_error_message_1;
                [_errorLabel[0] setText:string animated:YES];
                [(UILabel*)_errorLabel[0] multipleLineLabel:(UILabel*)_errorLabel];
                cell = _errorCells[indexPath.row];
            }
            else if (labs(indexPathFirstObjectProduct.row-indexPath.row) < rowCount)
                cell = [self cellTransactionCartAtIndexPath:indexPathWithoutErrorCell];
            else
            {
                //otherCell
                if (indexPath.row == indexPathFirstObjectProduct.row+rowCount)
                    cell = [self cellDetailShipmentAtIndexPath:indexPathWithoutErrorCell];
                else if (indexPath.row == indexPathFirstObjectProduct.row+rowCount+1)
                    cell = [self cellPartialStockAtIndextPath:indexPathWithoutErrorCell];
                else if (indexPath.row == indexPathFirstObjectProduct.row+rowCount+2)
                    cell = [self cellIsDropshipperAtIndextPath:indexPath];
                else if (indexPath.row > indexPathFirstObjectProduct.row+rowCount+2){
                    cell = [self cellTextFieldAtIndexPath:indexPathWithoutErrorCell];
                }
            }
        }
    }
    else if (indexPath.section == listCount+1)
    {
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
                    cell = ([_cartSummary.deposit_amount integerValue]>0 &&
                            [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)
                                ?_usedSaldoCell:
                                _totalPaymentCell;
                    [cell.detailTextLabel setText:([_cartSummary.deposit_amount integerValue]>0 &&
                                                   [_cartSummary.gateway integerValue]==TYPE_GATEWAY_TRANSFER_BANK)?_cartSummary.deposit_amount_idr:_cartSummary.payment_left_idr animated:YES];
                }
                break;
            }
            case 3:
                cell = _totalPaymentCell;
                [cell.detailTextLabel setText:_cartSummary.payment_left_idr animated:YES];
            default:
                break;
        }
    }
    else if (indexPath.section == listCount+2 && _indexPage == 0) {
        if ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)])
        {
            cell = _totalPaymentCell;
            [cell.detailTextLabel setText:_cart.grand_total_idr];
        }
        else
        {
            cell = _saldoTokopediaCell;
            if (indexPath.row==1) {
                cell = _saldoTextFieldCell;
            }
        }
    }
    else if (indexPath.section == listCount+3 &&_indexPage == 0)
    {
        cell = _totalPaymentCell;
        [cell.detailTextLabel setText:_cart.grand_total_idr];
    }
    else
    {
        cell = _passwordCell;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


#pragma mark - Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define DEFAULT_ROW_HEIGHT 44
#define CELL_ROW_HEIGHT 212
    
    NSInteger listCount = _list.count;
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];

    if (indexPath.section == 0) {
        return DEFAULT_ROW_HEIGHT;
    }
    else if (indexPath.section <= listCount)
    {
        TransactionCartList *list = _list[indexPath.section-1];
        NSArray *products = list.cart_products;
        
        NSIndexPath *indexPathFirstObjectProduct = (NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section-1];
        //TODO:: if errorMessage
        if (indexPath.row < indexPathFirstObjectProduct.row) {
            return ((UITableViewCell*)_errorCells[0]).frame.size.height;
        }
        else if (labs(indexPathFirstObjectProduct.row-indexPath.row)<products.count) {
            return CELL_ROW_HEIGHT;
        }
        else
            return DEFAULT_ROW_HEIGHT;
    }
    else if (indexPath.section == listCount+1)
    {
        NSArray *gatewayList = _cart.gateway_list;
        BOOL isNullDeposit = YES;
        for (TransactionCartGateway *gateway in gatewayList) {
            if([gateway.gateway  isEqual:@(0)]) isNullDeposit = NO;
        }
        if (indexPath.row == 1) {
            return ([selectedGateway.gateway isEqual: @(0)])?_totalPaymentCell.frame.size.height:(_indexPage==0)?_saldoTokopediaCell.frame.size.height:DEFAULT_ROW_HEIGHT;
        }

        else
            return DEFAULT_ROW_HEIGHT;
    }
    else return DEFAULT_ROW_HEIGHT;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section <= _list.count) return 44;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    NSInteger listCount = _list.count;
    if (section == 0)
        return 20;
    else if (section <= listCount)
        return 156;
    else if(section == listCount+1)
    {
        if (_indexPage==1 && [_cartSummary.deposit_amount integerValue]>0) {
            return 0;
        }
        else
            return (_indexPage==0)?0:_buyView.frame.size.height;
    }
    else if (section == listCount+2 && _indexPage == 0)
    {
        return ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)])?_checkoutView.frame.size.height:0;
    }
    else
    {
        return (_indexPage==0)?_checkoutView.frame.size.height:_buyView.frame.size.height;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section <= _list.count && section>0)
    {
        TransactionCartList *list = _list[section-1];
        NSString *shopName = list.cart_shop.shop_name;
        
        TransactionCartHeaderView *headerView = [TransactionCartHeaderView newview];
        headerView.shopNameLabel.text = shopName;
        if (_indexPage==1) {
            headerView.shopNameLabel.textColor = [UIColor blackColor];
            headerView.deleteButton.hidden = YES;
        }
        headerView.section = section-1;
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
    TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    else if (section <= _list.count)
    {
        TransactionCartList *list = _list[section-1];
        TransactionCartCostView *footerView = [TransactionCartCostView newview];
        footerView.biayaInsuranceLabel.text = ([list.cart_logistic_fee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
        footerView.infoButton.hidden = ([list.cart_logistic_fee integerValue]==0);
        [footerView.subtotalLabel setText:list.cart_total_product_price_idr animated:YES];
        NSInteger aditionalFeeValue = [list.cart_logistic_fee integerValue]+[list.cart_insurance_price integerValue];
        NSString *formatAdditionalFeeValue = [NSString stringWithFormat:@"Rp %zd,-",aditionalFeeValue];
        [footerView.insuranceLabel setText:formatAdditionalFeeValue animated:YES];
        [footerView.shippingCostLabel setText:list.cart_shipping_rate_idr animated:YES];
        [footerView.totalLabel setText:list.cart_total_amount_idr animated:YES];
        return footerView;
    }
    else if (section == _list.count+1)
    {
        if (_indexPage==1 && [_cartSummary.deposit_amount integerValue]>0) {
            return nil;
        }
        else
            return (_indexPage==0)?nil:_buyView;
    }
    else if (section == _list.count+2 && _indexPage == 0)
    {
        return ([selectedGateway.gateway isEqual:@(TYPE_GATEWAY_TOKOPEDIA)])?_checkoutView:nil;
    }
    else
    {
        return (_indexPage==0)?_checkoutView:_buyView;
    }
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLoadingRequest) {
        NSInteger listCount = _list.count;
        if (indexPath.section == 0) {
            NSIndexPath *selectedIndexPathGateway = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_GATEWAY_CART_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            TransactionCartPaymentViewController *paymentViewController = [TransactionCartPaymentViewController new];
            paymentViewController.data = @{DATA_CART_GATEWAY_KEY:_cart.gateway_list,
                                           DATA_INDEXPATH_KEY:selectedIndexPathGateway};
            paymentViewController.delegate = self;
            [self.navigationController pushViewController:paymentViewController animated:YES];
        }
        else if (indexPath.section == listCount+1)
        {
            if (indexPath.row == 1) {
                
            }
        }
        else if (indexPath.section <= listCount) {
            NSUInteger indexCart = indexPath.section-1;
            NSIndexPath *indexPathFirstObjectProduct = (NSIndexPath*)_listProductFirstObjectIndexPath[indexPath.section-1];
            TransactionCartList *list = _list[indexPath.section-1];
            NSArray *products = list.cart_products;
            NSInteger rowCount = products.count;
            
            if (indexPath.row == indexPathFirstObjectProduct.row+rowCount) {
                TransactionCartShippingViewController *shipmentViewController = [TransactionCartShippingViewController new];
                shipmentViewController.data = @{DATA_CART_DETAIL_LIST_KEY:list,
                                                DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper[indexCart]?:@"",
                                                DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper[indexCart]?:@"",
                                                DATA_INDEX_KEY : @(indexPath.section-1)
                                                };
                shipmentViewController.indexPage = _indexPage;
                shipmentViewController.delegate = self;
                [self.navigationController pushViewController:shipmentViewController animated:YES];
            }
            else if (indexPath.row == indexPathFirstObjectProduct.row+rowCount+1)
            {
                AlertPickerView *picker = [AlertPickerView newview];
                picker.delegate = self;
                picker.tag = indexPath.section;
                picker.pickerData =ARRAY_IF_STOCK_AVAILABLE_PARTIALLY;
                [picker show];
            }
        }
        else if (indexPath.section == listCount+2)
        {
            _isUsingSaldoTokopedia = _isUsingSaldoTokopedia?NO:YES;
            _isUsingSaldoTokopediaButton.selected = _isUsingSaldoTokopedia;
            if (_isUsingSaldoTokopedia) {
                [self.tableView beginUpdates];
                NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self.tableView insertRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
            }
            else
            {
                [self.tableView beginUpdates];
                NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
        }
        else
        {
            [_passwordTextField becomeFirstResponder];
        }
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
}

#pragma mark - Request Cart
-(void)cancelCartRequest
{
    [_requestCart cancel];
    _requestCart = nil;
    [_objectManagerCart.operationQueue cancelAllOperations];
    _objectManagerCart = nil;
}


-(void)configureRestKitCart
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
}

-(void)requestCart
{
    if (_requestCart.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *param = @{};
    
    _requestcount ++;
    
    _requestCart = [_objectManagerCart appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    _tableView.tableFooterView = _footerView;
    [_act startAnimating];
    _isLoadingRequest = YES;
    [_requestCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessCart:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        //_tableView.tableFooterView = nil;
        [_act stopAnimating];
        _isLoadingRequest = NO;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCart:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        _isLoadingRequest = NO;
    }];
    
    [_operationQueue addOperation:_requestCart];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutCart) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCart *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessCart:object];
    }
}

-(void)requestFailureCart:(id)object
{
    [self requestProcessCart:object];
}

-(void)requestProcessCart:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionCart *cart = stat;
            BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(cart.message_error)
                {
                    NSArray *array = cart.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    [_list removeAllObjects];
                    if (_isRefreshRequest) {
                        [_rowCountExpandCellForDropshipper removeAllObjects];
                        [_isDropshipper removeAllObjects];
                        [_stockPartialStrList removeAllObjects];
                        [_senderNameDropshipper removeAllObjects];
                        [_senderPhoneDropshipper removeAllObjects];
                        [_dropshipStrList removeAllObjects];
                        [_cartErrorMessage removeAllObjects];
                        [_listProductFirstObjectIndexPath removeAllObjects];
                        [_stockPartialDetail removeAllObjects];
                    }
                    NSArray *list = cart.result.list;
                    [_list addObjectsFromArray:list];
                    if (_list.count>0) {
                        _isnodata = NO;
                    }
                    _cart = cart.result;
                    NSInteger listCount = _list.count;
                    for (int i = 0; i<listCount; i++) {
                        TransactionCartList *list = _list[i];
                        NSArray *products = list.cart_products;
                        NSInteger productCount = products.count;
                        NSInteger rowCount = productCount+3;
                        
                        //TODO:: adjust when error message appear~
                        NSIndexPath *firstProductIndexPath = [NSIndexPath indexPathForRow:0 inSection:i+1];
                        if (![list.cart_error_message_1 isEqualToString:@"0"]||![list.cart_error_message_2 isEqualToString:@"0"])
                            firstProductIndexPath = [NSIndexPath indexPathForRow:1 inSection:i+1];
                        //if (![list.cart_error_message_2 isEqualToString:@"0"])
                        //   firstProductIndexPath = [NSIndexPath indexPathForRow:2 inSection:i+1];
                        
                        [_listProductFirstObjectIndexPath addObject:firstProductIndexPath];
                        [_rowCountExpandCellForDropshipper addObject:@(rowCount)];
                        [_isDropshipper addObject:@(NO)];
                        [_stockPartialStrList addObject:@""];
                        [_senderNameDropshipper addObject:@""];
                        [_senderPhoneDropshipper addObject:@""];
                        [_dropshipStrList addObject:@""];
                        [_stockPartialDetail addObject:@(0)];
                    }
                    if (!_isnodata) {
                        NSInteger indexSelectedShipment = [[_dataInput objectForKey:DATA_INDEX_KEY] integerValue]?:0;
                        NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:((TransactionCartList*)_list[indexSelectedShipment])};
                        [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_POST_NOTIFICATION_NAME object:nil userInfo:info];
                        _tableView.tableFooterView = nil;
                    }
                    else {
                        NoResult *noResultView = [[NoResult alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
                        _tableView.tableFooterView = noResultView;
                    }
                    [_tableView reloadData];
                    _tableView.contentInset = UIEdgeInsetsMake(-14.0, 0, 0, 0);
                }
            }
        }
        else {
            
            [self cancelCartRequest];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutCart
{
    [self cancelCartRequest];
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
                    NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    if (action.result.is_success == 1) {

                        NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                        
                        [self refreshView:nil];
                    }
                }
            }
        }
        else{
            
            [self cancelCartRequest];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
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
    
    NSIndexPath *selectedIndexPathGateway = [userInfo objectForKey:DATA_INDEXPATH_SELECTED_GATEWAY_CART_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *gateway_list = _cart.gateway_list;
    TransactionCartGateway *gateway = gateway_list[selectedIndexPathGateway.row];
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
    
    NSNumber *usedSaldo = _isUsingSaldoTokopedia?[_dataInput objectForKey:DATA_USED_SALDO_KEY]:@"0";
    
    NSString *voucherCode = [userInfo objectForKey:API_VOUCHER_CODE_KEY]?:@"";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{API_STEP_KEY:@(STEP_CHECKOUT),
                                      API_TOKEN_KEY:token,
                                      API_GATEWAY_LIST_ID_KEY:gatewayID,
                                      API_DROPSHIP_STRING_KEY:dropshipString,
                                      API_PARTIAL_STRING_KEY :partialString,
                                      API_USE_DEPOSIT_KEY:@(_isUsingSaldoTokopedia),
                                      @"deposit_amt":usedSaldo,
                                      API_VOUCHER_CODE_KEY : voucherCode,
                                      kTKPD_USERIDKEY : [_auth objectForKey:kTKPD_USERIDKEY],
                                      kTKPD_SHOPIDKEY: [_auth objectForKey:kTKPD_SHOPIDKEY]
                                      };
    
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipperDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    _checkoutButton.enabled = NO;
    [_checkoutButton setTitle:@"Processing ..." forState:UIControlStateNormal];
    _requestActionCheckout = [_objectManagerActionCheckout appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionCheckout setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCheckout:mappingResult withOperation:operation];
        _checkoutButton.enabled = YES;
        [_checkoutButton setTitle:@"CHECKOUT" forState:UIControlStateNormal];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCheckout:error];
        _checkoutButton.enabled = YES;
        [_checkoutButton setTitle:@"CHECKOUT" forState:UIControlStateNormal];
        [timer invalidate];
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
                    NSArray *array = cart.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:cart.result.transaction?:@"",
                                               DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper?:@"",
                                               DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper?:@"",
                                               DATA_PARTIAL_LIST_KEY:_stockPartialStrList?:@{},
                                               DATA_TYPE_KEY:@(TYPE_CART_SUMMARY)
                                               };
                    [_delegate didFinishRequestCheckoutData:userInfo];
                }
                if(cart.message_status)
                {
                    NSArray *array = cart.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            
            [self cancelActionCheckout];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
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
    [_buyButton setTitle:@"Processing ..." forState:UIControlStateNormal];
    _requestActionBuy = [_objectManagerActionBuy appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionBuy setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionBuy:mappingResult withOperation:operation];
        [timer invalidate];
        _buyButton.enabled = YES;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionBuy:error];
        [timer invalidate];
        _buyButton.enabled = YES;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
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
                    NSArray *array = cart.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    switch ([_cartSummary.gateway integerValue]) {
                        case TYPE_GATEWAY_TRANSFER_BANK:
                            break;
                        case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                        {
                            TransactionCartFormMandiriClickPayViewController *vc = [TransactionCartFormMandiriClickPayViewController new];
                            vc.data = @{DATA_KEY:_dataInput,
                                        DATA_CART_SUMMARY_KEY: _cartSummary
                                        };
                            vc.delegate = self;
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                            break;
                        default:
                            break;
                    }
                }
                if(cart.message_status)
                {
                    NSArray *array = cart.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                if (cart.result.is_success == 1) {
                    NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:cart.result};
                    [_delegate didFinishRequestBuyData:userInfo];
                }
            }
        }
        else{
            
            [self cancelActionBuy];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
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
                    NSArray *array = dataVoucher.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    _voucerCodeBeforeTapView.hidden = NO;
                    _voucherCodeView.hidden = YES;
                    _valueVoucherCodeLabel.hidden = NO;
                    _voucherCodeButton.hidden = YES;
                    
                    _valueVoucherCodeLabel.text = dataVoucher.result.data_voucher.voucher_amount;
                    
                    [self refreshView:nil];
                }
            }
        }
        else{
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
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
                    NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    if (action.result.is_success == 1) {
                        NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                        
                        [_tableView reloadData];
                    }
                }
            }
        }
        else{
            
            [self cancelActionEditProductCartRequest];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
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
                    AlertInfoVoucherCodeView *alertInfo = [AlertInfoVoucherCodeView newview];
                    [alertInfo show];
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
                    TransactionCartFormMandiriClickPayViewController *vc = [TransactionCartFormMandiriClickPayViewController new];
                    vc.data = @{DATA_KEY:_dataInput,
                                DATA_CART_SUMMARY_KEY: _cartSummary
                                };
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case TYPE_GATEWAY_CLICK_BCA:
                {
                    TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }

        }
    }
}

#pragma mark - Delegate
-(void)TransactionCartShippingViewController:(TransactionCartShippingViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

-(void)shouldEditCartWithUserInfo:(NSDictionary *)userInfo
{
    [_dataInput addEntriesFromDictionary:userInfo];
    [self configureRestKitActionEditProductCart];
    [self requestActionEditProductCart:_dataInput];
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
    [_senderPhoneDropshipper removeAllObjects];
    [_senderNameDropshipper removeAllObjects];
    [_list addObjectsFromArray:list];
    if (_list.count>0) {
        _isnodata = NO;
    }
    
    _cartSummary = summaryDetail;
    NSInteger listCount = _list.count;
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSArray *products = list.cart_products;
        NSInteger rowCount = products.count+1;
        [_rowCountExpandCellForDropshipper addObject:@(rowCount)];
        NSIndexPath *listProductFirstIndexPath = [NSIndexPath indexPathForRow:0 inSection:i+1];
        [_listProductFirstObjectIndexPath addObject:listProductFirstIndexPath];
    }
    
    _isUsingSaldoTokopedia = ([_cartSummary.deposit_amount integerValue]>0);
    
    NSArray *dropshipNameArray = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
    [_senderNameDropshipper addObjectsFromArray:dropshipNameArray];
    NSArray *dropshipPhoneArray = [_data objectForKey:DATA_DROPSHIPPER_PHONE_KEY];
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
    }
    else if (_indexPage == 1 && [_cartSummary.deposit_amount integerValue]>0) {
        NSString *password = [_dataInput objectForKey:API_PASSWORD_KEY];
        if ([password isEqualToString:@""] || !(password)) {
            isValid = NO;
            [messageError addObject:ERRORMESSAGE_NULL_CART_PASSWORD];
        }
    }
    
    if (!isValid) {
        NSArray *array = messageError;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
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
    /** clear object **/
    _requestcount = 0;
    _isRefreshRequest = YES;
    
    /** request data **/
    
    [self configureRestKitCart];
    [self requestCart];
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
    }
    [_dataInput setObject:dropshipListParam forKey:DATA_DROPSHIPPER_LIST_KEY];
}

-(void)adjustPartialListParam;
{
    NSInteger listCount = _list.count;
    NSMutableDictionary *partialListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        NSString *partialDetailKey = [NSString stringWithFormat:FORMAT_CART_CANCEL_PARTIAL_PHONE_KEY,shopID,addressID,shipmentPackageID];
        
        [partialListParam setObject:_stockPartialDetail[i] forKey:partialDetailKey];
    }
    [_dataInput setObject:partialListParam forKey:DATA_PARTIAL_LIST_KEY];
}

#pragma mark - Cell Delegate
-(void)tapMoreButtonActionAtIndexPath:(NSIndexPath*)indexPath
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Hapus",
                            @"Edit",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
    
}

-(void)GeneralSwitchCell:(GeneralSwitchCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLoadingRequest) {
        //NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
        TransactionCartList *list = _list[indexPath.section-1];
        NSInteger shopID = [list.cart_shop.shop_id integerValue];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =[list.cart_shipments.shipment_id integerValue];
        NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
        if (cell.settingSwitch.on) {
            NSInteger rowcount = [_rowCountExpandCellForDropshipper[indexPath.section-1]integerValue];
            [_rowCountExpandCellForDropshipper replaceObjectAtIndex:indexPath.section-1 withObject:@(rowcount+2)];
            
            [self.tableView beginUpdates];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
            [self.tableView insertRowsAtIndexPaths:@[indexPath1] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            
            NSString *dropshipStringObject = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
            [_dropshipStrList replaceObjectAtIndex:indexPath.section-1 withObject:dropshipStringObject];
        }
        else
        {
            NSInteger rowcount = [_rowCountExpandCellForDropshipper[indexPath.section-1]integerValue];
            [_rowCountExpandCellForDropshipper replaceObjectAtIndex:indexPath.section-1 withObject:@(rowcount-2)];
            [self.tableView beginUpdates];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath1, indexPath2] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
            
            [_dropshipStrList replaceObjectAtIndex:indexPath.section-1 withObject:@""];
        }
        [_isDropshipper replaceObjectAtIndex:indexPath.section-1 withObject:@(cell.settingSwitch.on)];
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
            TransactionCartEditViewController *editViewController = [TransactionCartEditViewController new];
            [_dataInput setObject:product forKey:DATA_PRODUCT_DETAIL_KEY];
            editViewController.data = _dataInput;
            editViewController.delegate = self;
            [self.navigationController pushViewController:editViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - PaymentDelegate
-(void)TransactionCartPaymentViewController:(TransactionCartPaymentViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    NSIndexPath *selectedIndexPathGateway = [userInfo objectForKey:DATA_INDEXPATH_KEY];
    [_dataInput setObject:selectedIndexPathGateway forKey:DATA_INDEXPATH_SELECTED_GATEWAY_CART_KEY];
    NSArray *gatewayList = _cart.gateway_list;
    TransactionCartGateway *gateway = gatewayList[selectedIndexPathGateway.row];
    [_dataInput setObject:gateway forKey:DATA_CART_GATEWAY_KEY];
    [_dataInput setObject:gateway.gateway forKey:API_GATEWAY_LIST_ID_KEY];
    [_tableView reloadData];
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
            }
        }
            break;
        default://TODO: JANGAN MASUKIN KE DEFAULT.
        {
            if (alertView.tag>0) {
                NSInteger index = [[((AlertPickerView*)alertView).data objectForKey:DATA_INDEX_KEY] integerValue];
                //NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
                TransactionCartList *list = _list[index-1];
                NSInteger shopID = [list.cart_shop.shop_id integerValue];
                NSInteger addressID =list.cart_destination.address_id;
                NSInteger shipmentPackageID = [list.cart_shipments.shipment_package_id integerValue];
                
                if (index == 0){
                    [_stockPartialStrList replaceObjectAtIndex:alertView.tag-1 withObject:@""];
                    [_stockPartialDetail replaceObjectAtIndex:alertView.tag-1 withObject:@(0)];
                }
                else
                {
                    NSString *partialStringObject = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_KEY,shopID,addressID,shipmentPackageID];
                    [_stockPartialStrList replaceObjectAtIndex:alertView.tag-1 withObject:partialStringObject];
                    [_stockPartialDetail replaceObjectAtIndex:alertView.tag-1 withObject:@(1)];
                }
                [self adjustPartialListParam];
                [_tableView reloadData];
            }
        }
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
    if (textField.tag > 0 )
        [_senderNameDropshipper replaceObjectAtIndex:textField.tag-1 withObject:textField.text];
    else if (textField.tag < 0)
        [_senderPhoneDropshipper replaceObjectAtIndex:-textField.tag-1 withObject:textField.text];
    if (textField == _saldoTokopediaAmountTextField) {
        NSString *depositAmount = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        [_dataInput setObject:depositAmount forKey:DATA_USED_SALDO_KEY];
    }
    if (textField == _passwordTextField) {
        [_dataInput setObject:textField.text forKey:API_PASSWORD_KEY];
    }
    
    [self adjustDropshipperListParam];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _saldoTokopediaAmountTextField) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            return YES;
        }
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
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_list.count+2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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

#pragma mark - Table View Cell

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
    
    NSInteger choosenIndex = [_stockPartialStrList[indexPath.section-1] isEqualToString:@""]?0:1;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Stock Tersedia Sebagian";
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    //cell.textLabel.textColor = TEXT_COLOUR_DEFAULT_CELL_TEXT;
    cell.detailTextLabel.text = [ARRAY_IF_STOCK_AVAILABLE_PARTIALLY[choosenIndex]objectForKey:DATA_NAME_KEY];
    cell.detailTextLabel.font = FONT_DETAIL_DEFAULT_CELL_TKPD;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    return cell;
}

-(UITableViewCell*)cellTextFieldAtIndexPath:(NSIndexPath*)indexPath
{
    
    static NSString *CellIdentifier = @"textfieldCellIdentifier";
    BOOL isSaldoTokopediaTextField = (indexPath.section==_list.count+1);
    NSInteger indexList = (isSaldoTokopediaTextField)?0:(indexPath.section-1);
    TransactionCartList *list = _list[indexList];
    NSArray *products = list.cart_products;
    NSInteger rowCount = products.count+3;
    NSString *placeholder = (isSaldoTokopediaTextField)?@"Saldo Tokopedia":(indexPath.row == rowCount)?@"Nama Pengirim":@"Nomor Telepon";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    UIView *accessoryView = [[UIView alloc]initWithFrame:CGRectMake(15, 0, 300, 30)];
    UITextField *textField = [[UITextField alloc]initWithFrame:accessoryView.frame];
    textField.placeholder = placeholder;
    textField.text = (indexPath.section==_list.count+1)?@"":(indexPath.row == rowCount)?_senderNameDropshipper[indexPath.section-1]:_senderPhoneDropshipper[indexPath.section-1];
    textField.delegate = self;
    textField.tag = isSaldoTokopediaTextField?0:(indexPath.row == rowCount)?indexPath.section:-indexPath.section;
    textField.font = FONT_DEFAULT_CELL_TKPD;
    
    [accessoryView addSubview:textField];
    cell.accessoryView = accessoryView;
    
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
    ((GeneralSwitchCell*)cell).settingSwitch.on = [_isDropshipper[indexPath.section-1] boolValue];
    
    return cell;
}

-(UITableViewCell*)cellTransactionCartAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_CART_CELL_IDENTIFIER;
    
    UITableViewCell *cell = (TransactionCartCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartCell newcell];
        ((TransactionCartCell*)cell).delegate = self;
    }
    TransactionCartList *list = _list[indexPath.section-1];
    NSInteger indexProduct = indexPath.row;//(list.cart_error_message_1)?indexPath.row-1:indexPath.row; //TODO:: adjust when error message appear
    NSArray *listProducts = list.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    cell.backgroundColor = (_indexPage==0)?[UIColor whiteColor]:[UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1];
    [((TransactionCartCell*)cell).productNameLabel setText:product.product_name animated:YES];
    if (_indexPage==1) ((TransactionCartCell*)cell).productNameLabel.textColor= [UIColor blackColor];
    [((TransactionCartCell*)cell).productPriceLabel setText:product.product_total_price_idr animated:YES];
    
    NSString *weightTotal = [NSString stringWithFormat:@"%@ Barang (%@ kg)",product.product_quantity, product.product_total_weight];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_12 range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    ((TransactionCartCell*)cell).quantityLabel.attributedText = attributedString;
    
    NSIndexPath *indexPathCell = [NSIndexPath indexPathForRow:indexProduct inSection:indexPath.section-1];
    ((TransactionCartCell*)cell).indexPath = indexPathCell;
    ((TransactionCartCell*)cell).editButton.hidden = (_indexPage == 1);
    ((TransactionCartCell*)cell).remarkTextView.text = product.product_notes;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = ((TransactionCartCell*)cell).productThumbImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    return cell;
}

-(UITableViewCell*)cellNoData
{
    static NSString *CellIdentifier = TRANSACTION_STANDARDTABLEVIEWCELLIDENTIFIER;
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = TRANSACTION_NODATACELLTITLE;
    cell.detailTextLabel.text = TRANSACTION_NODATACELLDESCS;
    return cell;
}



//TODO:: Change color Action Sheet cancel button
//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
//{
//    for (UIView *subview in actionSheet.subviews) {
//        if ([subview isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)subview;
//            button.titleLabel.textColor = [UIColor greenColor];
//        }
//    }
//}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
