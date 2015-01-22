//
//  TransactionCartViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "string_alert.h"
#import "detail.h"
#import "profile.h"
#import "string_product.h"
#import "TransactionCartViewController.h"
#import "TransactionCartCell.h"
#import "TransactionCartHeaderView.h"
#import "TransactionCart.h"
#import "GeneralSwitchCell.h"
#import "TransactionCartCostView.h"
#import "TransactionCartEditViewController.h"
#import "TransactionCartPaymentViewController.h"
#import "TransactionCartShippingViewController.h"
#import "AlertPickerView.h"
#import "TransactionAction.h"
#import "TransactionSummary.h"
#import "TransactionBuy.h"
#import "TransactionCartFormMandiriClickPayViewController.h"

@interface TransactionCartViewController () <UITableViewDataSource,UITableViewDelegate,TransactionCartCellDelegate, TransactionCartHeaderViewDelegate,GeneralSwitchCellDelegate, UIActionSheetDelegate,UIAlertViewDelegate,TransactionCartPaymentViewControllerDelegate, TKPDAlertViewDelegate,UITextFieldDelegate, TransactionCartMandiriClickPayFormDelegate>
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
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    NSMutableArray *_rowCountExpandCellForDropshipper;
    NSMutableArray *_isDropshipper;
    NSMutableArray *_stockPartial;
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
}

@property (strong, nonatomic) IBOutlet UITableViewCell *paymentGatewayCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *paymentGatewaySummaryCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *voucerCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalInvoiceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *transferCodeCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *errorCells;



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

- (IBAction)tap:(id)sender;
@end

@implementation TransactionCartViewController
@synthesize indexPage =_indexPage;
@synthesize data = _data;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    _isnodata = YES;
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _rowCountExpandCellForDropshipper = [NSMutableArray new];
    _isDropshipper = [NSMutableArray new];
    _stockPartial = [NSMutableArray new];
    _stockPartialStrList = [NSMutableArray new];
    _senderNameDropshipper = [NSMutableArray new];
    _senderPhoneDropshipper = [NSMutableArray new];
    _dropshipStrList = [NSMutableArray new];
    _cartErrorMessage = [NSMutableArray new];

    _isUsingSaldoTokopedia = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEditCart:)
                                                 name:EDIT_CART_POST_NOTIFICATION_NAME
                                               object:nil];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
    
    if (_indexPage==0) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
        [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
        
        [self configureRestKitCart];
        [self requestCart];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_indexPage==1)[self adjustTableViewData:_data];
    
    _isUsingSaldoTokopediaButton.layer.borderColor = [UIColor blackColor].CGColor;
    _isUsingSaldoTokopediaButton.layer.borderWidth = 1;
    _isUsingSaldoTokopediaButton.layer.cornerRadius = 2;
    _checkoutButton.layer.cornerRadius = 2;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = _list.count +2;
#ifdef TRANSACTION_NODATA_ENABLE
    return _isnodata?1:sectionCount;
#else
    return _isnodata?0:sectionCount;
#endif
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger listCount = _list.count;
    if (section == 0) {
        return 1;
    }
    else if (section == listCount+1) {
        switch ([_cartSummary.gateway integerValue]) {
            case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
            case TYPE_GATEWAY_MANDIRI_E_CASH:
            case TYPE_GATEWAY_CLICK_BCA:
                return 2;
                break;
            default:
                return _isUsingSaldoTokopedia?4:3;
                break;
        }
    }
    else{

    #ifdef TRANSACTION_NODATA_ENABLE
        return _isnodata?1:rowCount;
    #else
        if (!_isnodata) {
            NSInteger rowCount = [_rowCountExpandCellForDropshipper[section-1]integerValue];
            return rowCount;
        }
        return 0;
    #endif
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSInteger listCount = _list.count;
    _isUsingSaldoTokopediaButton.selected = _isUsingSaldoTokopedia;
    if (indexPath.section == 0) {
        if (_indexPage == 0) {
            TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
            _paymentGatewayCell.detailTextLabel.text = selectedGateway.gateway_name?:STRING_DEFAULT_PAYMENT;
            cell = _paymentGatewayCell;
        }
        else
        {
            _paymentGatewaySummaryCell.textLabel.text = [NSString stringWithFormat:FORMAT_PAYMENT_METHOD,_cartSummary.gateway_name?:@""];
            cell = _paymentGatewaySummaryCell;
        }

    }
    else if (indexPath.section == listCount+1)
    {
        switch (indexPath.row) {
            case 0:
                [_totalInvoiceCell.detailTextLabel setText:_cartSummary.grand_total_before_fee_idr animated:YES];
                cell = (_indexPage==0)?_voucerCell:_totalInvoiceCell;
                break;
            case 1:
                switch ([_cartSummary.gateway integerValue]) {
                    case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                    case TYPE_GATEWAY_MANDIRI_E_CASH:
                    case TYPE_GATEWAY_CLICK_BCA:
                        [_totalPaymentCell.detailTextLabel setText:(_indexPage==0)?_cart.grand_total_idr:_cartSummary.grand_total_idr animated:YES];
                        cell = _totalPaymentCell;
                        break;
                    default:
                        if (_indexPage==0) {
                            [_saldoTokopediaLabel setText:[NSString stringWithFormat:FORMAT_SALDO_TOKOPEDIA,_cart.deposit_idr?:@"Rp.0,-"] animated:YES];
                            cell = _saldoTokopediaCell;
                        }
                        else
                        {
                            [_transferCodeCell.detailTextLabel setText:_cartSummary.conf_code_idr animated:YES];
                            cell = _transferCodeCell;
                        }
                        break;
                }
                break;
            case 2:
                [_totalPaymentCell.detailTextLabel setText:(_indexPage==0)?_cart.grand_total_idr:_cartSummary.grand_total_idr animated:YES];
                cell = _isUsingSaldoTokopedia?[self cellTextFieldAtIndexPath:indexPath]:_totalPaymentCell;
                break;
            case 3:
                [_totalPaymentCell.detailTextLabel setText:(_indexPage==0)?_cart.grand_total_idr:_cartSummary.grand_total_idr animated:YES];
                cell = _totalPaymentCell;
                break;
            default:
                break;
        }
    }
    else{
        if (!_isnodata) {
            TransactionCartList *list = _list[indexPath.section-1];
            NSArray *products = list.cart_products;
            NSInteger rowCount = products.count;
            
            NSInteger indexProduct = (list.cart_error_message_1)?indexPath.row+1:indexPath.row;
            //TODO:: if errorMessage
            //if (list.cart_error_message_1)rowCount = rowCount+_cartErrorMessage.count;
            //if (indexPath.row == 0)
            //    cell = (list.cart_error_message_1)?_errorCells[0]:[self cellTransactionCartAtIndexPath:indexPath];
            //else if (rowCount > indexProduct)
            if (rowCount > indexPath.row)
                cell = [self cellTransactionCartAtIndexPath:indexPath];
            else
            {
                //otherCell
                if (indexPath.row == rowCount)
                    cell = [self cellDetailShipmentAtIndexPath:indexPath];
                else if (indexPath.row == rowCount+1)
                    cell = [self cellPartialStockAtIndextPath:indexPath];
                else if (indexPath.row == rowCount+2)
                    cell = [self cellIsDropshipperAtIndextPath:indexPath];
                else{
                    cell = [self cellTextFieldAtIndexPath:indexPath];
                }
            }
        } else {
            cell = [self cellNoData];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


#pragma mark - Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define DEFAULT_ROW_HEIGHT 40
    NSInteger listCount = _list.count;

    if (indexPath.section == 0) {
        return DEFAULT_ROW_HEIGHT;
    }
    else if (indexPath.section <= listCount)
    {
        TransactionCartList *list = _list[indexPath.section-1];
        NSArray *products = list.cart_products;
        NSInteger rowCount = products.count;
        
        //TODO:: if errorMessage
        //if (list.cart_error_message_1) {
        //    rowCount = rowCount+_cartErrorMessage.count;
        //    if (indexPath.row == 0) {
        //        return DEFAULT_ROW_HEIGHT;
        //    }
        //    else
        //        return DEFAULT_ROW_HEIGHT;
        //}
        //else if (rowCount>indexPath.row){
        if (indexPath.row<products.count) {
            return 236;
        }
        else
            return DEFAULT_ROW_HEIGHT;
    }
    else if (indexPath.section == listCount+1)
    {
        if (indexPath.row == 1) {
            return (_indexPage==0)?_saldoTokopediaCell.frame.size.height:DEFAULT_ROW_HEIGHT;
        }

        else
            return DEFAULT_ROW_HEIGHT;
    }
    else return DEFAULT_ROW_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section <= _list.count)return 40;
    else return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return 40;
    else if (section <= _list.count)
        return 156;
    else if(section == _list.count+1)
        return (_indexPage==0)?_checkoutView.frame.size.height:_buyView.frame.size.height;
    else return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    else if (section == _list.count+1)
    {
        return nil;
    }
    else
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
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    else if (section <= _list.count)
    {
        TransactionCartList *list = _list[section-1];
        TransactionCartCostView *footerView = [TransactionCartCostView newview];
        
        [footerView.subtotalLabel setText:list.cart_total_product_price_idr animated:YES];
        [footerView.insuranceLabel setText:list.cart_insurance_price_idr animated:YES];
        [footerView.shippingCostLabel setText:list.cart_shipping_rate_idr animated:YES];
        [footerView.totalLabel setText:list.cart_total_amount_idr animated:YES];
        return footerView;
    }
    else if (section == _list.count+1)
    {
        return (_indexPage==0)?_checkoutView:_buyView;
    }
    else return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            _isUsingSaldoTokopedia = _isUsingSaldoTokopedia?NO:YES;
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
    }
    else{
        NSUInteger indexCart = indexPath.section-1;
        TransactionCartList *list = _list[indexCart];
        NSArray *products = list.cart_products;
        NSInteger rowCount = products.count;
        if (indexPath.row == rowCount) {
            TransactionCartShippingViewController *shipmentViewController = [TransactionCartShippingViewController new];
            shipmentViewController.data = @{DATA_CART_DETAIL_LIST_KEY:list,
                                            DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper[indexCart]?:@"",
                                            DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper[indexCart]?:@"",
                                            };
            shipmentViewController.indexPage = _indexPage;
            [self.navigationController pushViewController:shipmentViewController animated:YES];
        }
        else if (indexPath.row == rowCount+1)
        {
            AlertPickerView *picker = [AlertPickerView newview];
            picker.delegate = self;
            picker.tag = indexPath.section-1;
            picker.pickerData =ARRAY_IF_STOCK_AVAILABLE_PARTIALLY;
            [picker show];
        }
        else if (indexPath.row == rowCount+2)
        {
            
        }
    }
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
    [resultMapping addAttributeMappingsFromArray:@[API_TOKEN_KEY]];

    RKObjectMapping *listMapping = [self transactionCartListMapping];
    RKObjectMapping *productMapping = [self productMapping];
    RKObjectMapping *addressMapping = [self addressMapping];
    RKObjectMapping *gatewayMapping = [self gatewayMapping];
    RKObjectMapping *shipmentsMapping = [self shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [self shopInfoMapping];
    
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
    [_requestCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessCart:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureCart:error];
        [_refreshControl endRefreshing];
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
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
                    if (_isRefreshRequest) {
                        [_list removeAllObjects];
                        [_rowCountExpandCellForDropshipper removeAllObjects];
                        [_isDropshipper removeAllObjects];
                        [_stockPartial removeAllObjects];
                        [_stockPartialStrList removeAllObjects];
                        [_senderNameDropshipper removeAllObjects];
                        [_senderPhoneDropshipper removeAllObjects];
                        [_dropshipStrList removeAllObjects];
                        [_cartErrorMessage removeAllObjects];
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
                        NSInteger rowCount = products.count+3;
                        
                        //TODO:: adjust when error message appear~
                        //if (list.cart_error_message_1) rowCount=rowCount+1;
                        //if (list.cart_error_message_2) rowCount=rowCount+1;
                        [_cartErrorMessage addObject:list.cart_error_message_1];
                        
                        [_rowCountExpandCellForDropshipper addObject:@(rowCount)];
                        [_isDropshipper addObject:@(NO)];
                        [_stockPartial addObject:@(0)];
                        [_stockPartialStrList addObject:@""];
                        [_senderNameDropshipper addObject:@""];
                        [_senderPhoneDropshipper addObject:@""];
                        [_dropshipStrList addObject:@""];
                    }
                    [_tableView reloadData];
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
    NSInteger shopID = list.cart_shop.shop_id;
    NSInteger addressID = list.cart_destination.address_id;
    NSInteger shipmentID = list.cart_shipments.shipment_id;
    NSInteger shipmentPackageID = list.cart_shipments.shipment_package_id;
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_CANCEL_CART,
                            API_PRODUCT_CART_ID_KEY : @(productCartID),
                            kTKPD_SHOPIDKEY:@(shopID),
                            API_ADDRESS_ID_KEY:@(addressID),
                            API_SHIPMENT_ID_KEY:@(shipmentID),
                            API_SHIPMENT_PACKAGE_ID:@(shipmentPackageID)
                            };
    _requestcount ++;
    
    _requestActionCancelCart = [_objectManagerActionCancelCart appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionCancelCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCancelCart:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCancelCart:error];
        [timer invalidate];
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
    
    RKObjectMapping *transactionMapping = [self transactionDetailSummaryMapping];
    
    RKObjectMapping *listMapping = [self transactionCartListMapping];
    RKObjectMapping *productMapping = [self productMapping];
    RKObjectMapping *addressMapping = [self addressMapping];
    RKObjectMapping *shipmentsMapping = [self shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [self shopInfoMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TRANSACTION_SUMMARY_KEY toKeyPath:API_TRANSACTION_SUMMARY_KEY withMapping:transactionMapping]];
    
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
    
    [_objectManagerActionCheckout addResponseDescriptor:responseDescriptor];
    
}

//# sub cancel_cart example URL
//# www.tkpdevel-pg.ekarisky/ws/action/tx-cart.pl?action=cancel_cart&
//# product_cart_id=&
//# address_id=&
//# shop_id=&
//# shipment_id=&
//# shipment_package_id=&

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
    NSDictionary *dropshipperDetail = [userInfo objectForKey:DATA_DROPSHIPPER_LIST_KEY];
    
    NSString * partialString = [[tempPartialStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];
    NSDictionary *partialDetail = [userInfo objectForKey:DATA_PARTIAL_LIST_KEY];
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{API_STEP_KEY:@(STEP_CHECKOUT),
                                      API_TOKEN_KEY:token,
                                      API_GATEWAY_LIST_ID_KEY:gatewayID,
                                      API_DROPSHIP_STRING_KEY:dropshipString,
                                      API_PARTIAL_STRING_KEY :partialString,
                                      };
    
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipperDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    _requestcount ++;
    _checkoutButton.enabled = NO;
    _requestActionCheckout = [_objectManagerActionCheckout appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionCheckout setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCheckout:mappingResult withOperation:operation];
        _checkoutButton.enabled = YES;
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCheckout:error];
        _checkoutButton.enabled = YES;
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
                    NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:cart.result.transaction,
                                               DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper?:@"",
                                               DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper?:@"",
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

    RKObjectMapping *systemBankMapping = [self systemBankMapping];
    RKObjectMapping *transactionMapping = [self transactionDetailSummaryMapping];
    RKObjectMapping *listMapping = [self transactionCartListMapping];
    RKObjectMapping *productMapping = [self productMapping];
    RKObjectMapping *addressMapping = [self addressMapping];
    RKObjectMapping *shipmentsMapping = [self shipmentsMapping];
    RKObjectMapping *shopinfoMapping = [self shopInfoMapping];
    
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
    
    NSDictionary* param = @{API_STEP_KEY:@(STEP_BUY),
                           API_TOKEN_KEY:token,
                           API_GATEWAY_LIST_ID_KEY:gatewayID,
                            API_MANDIRI_TOKEN_KEY:mandiriToken,
                            API_CARD_NUMBER_KEY:cardNumber
                          };
    
    _requestcount ++;
    _buyButton.enabled = NO;
    _requestActionBuy = [_objectManagerActionBuy appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionBuy setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionBuy:mappingResult withOperation:operation];
        [timer invalidate];
        _buyButton.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionBuy:error];
        [timer invalidate];
        _buyButton.enabled = YES;
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
                            vc.data = @{DATA_KEY:_dataInput
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


#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if (_indexPage==0){
        UIButton *button = (UIButton*)sender;
        if (button.tag == 10) {
                
        }
        else{
            if([self isValidInput]) {
                [self configureRestKitActionCheckout];
                [self requestActionCheckout:_dataInput];
            }
        }
    }
    if(_indexPage==1)
    {
        switch ([_cartSummary.gateway integerValue]) {
            case TYPE_GATEWAY_TRANSFER_BANK:
                [self configureRestKitActionBuy];
                [self requestActionBuy:_dataInput];
                break;
            case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
            {
                TransactionCartFormMandiriClickPayViewController *vc = [TransactionCartFormMandiriClickPayViewController new];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }

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
    }
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
    
    NSInteger gateway = [[_dataInput objectForKey:API_GATEWAY_LIST_ID_KEY]integerValue];
    if (gateway == -1) {
        isValid = NO;
        [messageError addObject:ERRORMESSAGE_NULL_PAYMENT];
    }
    
    if (!isValid) {
        NSArray *array = messageError;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
    }

    return  isValid;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    //[self cancelCartRequest];
    _requestcount = 0;
    _isRefreshRequest = YES;
    
    /** request data **/
    
    [self configureRestKitCart];
    [self requestCart];
}

-(void)didEditCart:(NSNotification*)notification
{
    [self refreshView:nil];
}

-(void)adjustDropshipperListParam;
{
    NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    NSInteger listCount = _list.count;
    NSMutableDictionary *dropshipListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =list.cart_shipments.shipment_id;
        NSInteger shipmentPackageID = list.cart_shipments.shipment_package_id;
        NSString *dropshipperNameKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_NAME_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        NSString *dropshipperPhoneKey = [NSString stringWithFormat:FORMAT_CART_DROPSHIP_PHONE_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        [dropshipListParam setObject:_senderNameDropshipper[i] forKey:dropshipperNameKey];
        [dropshipListParam setObject:_senderPhoneDropshipper[i] forKey:dropshipperPhoneKey];
    }
    [_dataInput setObject:dropshipListParam forKey:DATA_DROPSHIPPER_LIST_KEY];
}

-(void)adjustPartialListParam;
{
    NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    NSInteger listCount = _list.count;
    NSMutableDictionary *partialListParam = [NSMutableDictionary new];
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        NSInteger addressID =list.cart_destination.address_id;
        NSInteger shipmentID =list.cart_shipments.shipment_id;
        NSInteger shipmentPackageID = list.cart_shipments.shipment_package_id;
        NSString *partialDetailKey = [NSString stringWithFormat:FORMAT_CART_CANCEL_PARTIAL_PHONE_KEY,shopID,addressID,shipmentID,shipmentPackageID];
        
        [partialListParam setObject:_stockPartial[i] forKey:partialDetailKey];
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
    NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
    TransactionCartList *list = _list[indexPath.section-1];
    NSInteger addressID =list.cart_destination.address_id;
    NSInteger shipmentID =list.cart_shipments.shipment_id;
    NSInteger shipmentPackageID = list.cart_shipments.shipment_package_id;
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
        [self.tableView deleteRowsAtIndexPaths:@[indexPath1,indexPath2] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
        [_dropshipStrList replaceObjectAtIndex:indexPath.section-1 withObject:@""];
    }
    [_isDropshipper replaceObjectAtIndex:indexPath.section-1 withObject:@(cell.settingSwitch.on)];
}

#pragma mark - Header View Delegate
-(void)deleteTransactionCartHeaderView:(TransactionCartHeaderView *)view atSection:(NSInteger)section
{
    TransactionCartList *list = _list[section];

    NSString *message = [NSString stringWithFormat:FORMAT_CANCEL_CART,list.cart_shop.shop_name, list.cart_total_amount_idr];
    UIAlertView *cancelCartAlert = [[UIAlertView alloc]initWithTitle:TITLE_ALERT_CANCEL_CART message:message delegate:self cancelButtonTitle:TITLE_BUTTON_CANCEL_DEFAULT otherButtonTitles:TITLE_BUTTON_OK_DEFAULT, nil];
    cancelCartAlert.tag = 11;
    [cancelCartAlert show];
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
            editViewController.data = @{DATA_CART_PRODUCT_KEY:product};
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
        default:
        {
            if (alertView.tag!=0) {
                NSInteger index = [[((AlertPickerView*)alertView).data objectForKey:DATA_INDEX_KEY] integerValue];
                NSInteger shopID = [[_auth objectForKey:kTKPD_USERIDKEY]integerValue];
                TransactionCartList *list = _list[index];
                NSInteger addressID =list.cart_destination.address_id;
                NSInteger shipmentID =list.cart_shipments.shipment_id;
                NSInteger shipmentPackageID = list.cart_shipments.shipment_package_id;
                
                [_stockPartial replaceObjectAtIndex:alertView.tag withObject:@(index)];
                if (index == 0)
                    [_stockPartialStrList replaceObjectAtIndex:alertView.tag withObject:@""];
                else
                {
                    NSString *partialStringObject = [NSString stringWithFormat:FORMAT_CART_PARTIAL_STR_KEY,shopID,addressID,shipmentID,shipmentPackageID];
                    [_stockPartialStrList replaceObjectAtIndex:alertView.tag withObject:partialStringObject];
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

#pragma mark - ScrollView Delegate
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
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
    else
        [_senderPhoneDropshipper replaceObjectAtIndex:-textField.tag-1 withObject:textField.text];
    
    [self adjustDropshipperListParam];
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        _scrollviewContentSize = [_tableView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_tableView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_tableView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if (_activeTextField != nil && ((self.view.frame.origin.y + _activeTextField.frame.origin.y+_activeTextField.frame.size.height)> _keyboardPosition.y)) {
                                 UIEdgeInsets inset = _tableView.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activeTextField.frame.origin.y+_activeTextField.frame.size.height + 10));
                                 [_tableView setContentInset:inset];
                             }
                         }
                         completion:^(BOOL finished){
                         }];
        
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
    cell.textLabel.textColor = TEXT_COLOUR_DEFAULT_CELL_TEXT;
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
    
    NSInteger choosenIndex = [_stockPartial[indexPath.section-1]integerValue];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Stock Tersedia Sebagian";
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    cell.textLabel.textColor = TEXT_COLOUR_DEFAULT_CELL_TEXT;
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
    
    NSString *weightTotal = [NSString stringWithFormat:@"%zd Barang (%@ kg)",product.product_quantity, product.product_total_weight];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_12 range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_total_weight]]];
    [((TransactionCartCell*)cell).quantityLabel setText:[NSString stringWithFormat:@"%zd Barang (%@ kg)",product.product_quantity, product.product_total_weight] animated:YES];
    
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


#pragma mark - RKObjectMapping
-(RKObjectMapping*)transactionCartListMapping
{
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TransactionCartList class]];
    [listMapping addAttributeMappingsFromArray:@[API_CART_TOTAL_LOGISTIC_FEE_KEY,
                                                 API_TOTAL_CART_COUNT_KEY,
                                                 API_CART_TOTAL_LOGISTIC_FEE_IDR_KEY,
                                                 API_CART_CAN_PROCESS_KEY,
                                                 API_TOTAL_PRODUCT_PRICE_KEY,
                                                 API_INSURANCE_PRICE_KEY,
                                                 API_CART_TOTAL_TOTAL_PRODUCT_PRICE_IDR_KEY,
                                                 API_CART_TOTAL_WEIGHT_KEY,
                                                 API_CART_CUTOMER_ID_KEY,
                                                 API_CART_INSURANCE_PRODUCT_KEY,
                                                 API_TOTAL_AMOUNT_IDR_KEY,
                                                 API_SHIPPING_RATE_IDR_KEY,
                                                 API_IS_ALLOW_CHECKOUT_KEY,
                                                 API_PRODUCT_TYPE_KEY,
                                                 API_FORCE_INSURANCE_KEY ,
                                                 API_CANNOT_INSURANCE_KEY ,
                                                 API_TOTAL_PRODUCT_KEY,
                                                 API_INSURANCE_PRICE_IDR_KEY,
                                                 API_TOTAL_TOTAL_AMOUNT_KEY,
                                                 API_TOTAL_SHIPPING_RATE_KEY,
                                                 API_TOTAL_LOGISTIC_FEE_KEY,
                                                 API_CART_ERROR_1,
                                                 API_CART_ERROR_2
                                                 ]];
    return listMapping;
}

-(RKObjectMapping*)productMapping
{
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
    [productMapping addAttributeMappingsFromArray: @[API_PRODUCT_NAME_KEY,
                                                     API_PRODUCT_WEIGHT_UNIT_KEY,
                                                     API_PRODUCT_DESCRIPTION_KEY,
                                                     API_PRODUCT_PRICE_KEY,
                                                     API_PRODUCT_INSURANCE_KEY,
                                                     API_PRODUCT_CONDITION_KEY,
                                                     API_PRODUCT_MINIMUM_ORDER_KEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                     API_PRODUCT_PRICE_IDR_KEY,
                                                     API_PRODUCT_TOTAL_PRICE_IDR_KEY,
                                                     API_PRODUCT_TOTAL_PRICE_KEY,
                                                     API_PRODUCT_PICTURE_KEY,
                                                     API_PRODUCT_WEIGHT_KEY,
                                                     API_PRODUCT_QUANTITY_KEY,
                                                     API_PRODUCT_CART_ID_KEY,
                                                     API_PRODUCT_TOTAL_WEIGHT_KEY,
                                                     API_PRODUCT_NOTES_KEY
                                                     ]];
    return productMapping;
}

-(RKObjectMapping*)addressMapping
{
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[AddressFormList class]];
    [addressMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILESETTING_APICOUNTRYNAMEKEY:kTKPDPROFILESETTING_APICOUNTRYNAMEKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERNAMEKEY:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSNAMEKEY:kTKPDPROFILESETTING_APIADDRESSNAMEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSIDKEY:kTKPDPROFILESETTING_APIADDRESSIDKEY,
                                                         kTKPDPROFILESETTING_APIRECEIVERPHONEKEY :kTKPDPROFILESETTING_APIRECEIVERPHONEKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCENAMEKEY:kTKPDPROFILESETTING_APIPROVINCENAMEKEY,
                                                         API_POSTAL_CODE_CART_KEY:kTKPDPROFILESETTING_APIPOSTALCODEKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSSTATUSKEY:kTKPDPROFILESETTING_APIADDRESSSTATUSKEY,
                                                         kTKPDPROFILESETTING_APIADDRESSSTREETKEY:kTKPDPROFILESETTING_APIADDRESSSTREETKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICNAMEKEY:kTKPDPROFILESETTING_APIDISTRICNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYNAMEKEY:kTKPDPROFILESETTING_APICITYNAMEKEY,
                                                         kTKPDPROFILESETTING_APICITYIDKEY:kTKPDPROFILESETTING_APICITYIDKEY,
                                                         kTKPDPROFILESETTING_APIPROVINCEIDKEY:kTKPDPROFILESETTING_APIPROVINCEIDKEY,
                                                         kTKPDPROFILESETTING_APIDISTRICTIDKEY:kTKPDPROFILESETTING_APIDISTRICTIDKEY
                                                         }];
    return addressMapping;
}

-(RKObjectMapping*)gatewayMapping
{
    RKObjectMapping *gatewayMapping = [RKObjectMapping mappingForClass:[TransactionCartGateway class]];
    [gatewayMapping addAttributeMappingsFromDictionary:@{API_GATEWAY_LIST_IMAGE_KEY:API_GATEWAY_LIST_IMAGE_KEY,
                                                         API_GATEWAY_LIST_NAME_KEY:API_GATEWAY_LIST_NAME_KEY,
                                                         API_GATEWAY_LIST_ID_KEY:API_GATEWAY_LIST_ID_KEY
                                                         }];
    return gatewayMapping;
}

-(RKObjectMapping*)shipmentsMapping
{
    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipments class]];
    [shipmentsMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY,
                                                           kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY,
                                                           kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY,
                                                           API_SHIPMENT_PACKAGE_NAME:API_SHIPMENT_PACKAGE_NAME,
                                                           API_SHIPMENT_PACKAGE_ID:API_SHIPMENT_PACKAGE_ID
                                                           }];
    return shipmentsMapping;
}

-(RKObjectMapping*)shopInfoMapping
{
    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    return shopinfoMapping;
}

-(RKObjectMapping*)transactionDetailSummaryMapping
{
    RKObjectMapping *transactionMapping = [RKObjectMapping mappingForClass:[TransactionSummaryDetail class]];
    [transactionMapping addAttributeMappingsFromArray:@[API_CONFIRMATION_CODE_KEY,
                                                        API_SUMMARY_GRAN_TOTAL_BEFORE_FEE_IDR_KEY,
                                                        API_PROCESSING_KEY,
                                                        API_DISCOUNT_GATEWAY_KEY,
                                                        API_USER_DEPOSIT_KEY,
                                                        API_STATUS_UNIK_KEY,
                                                        API_LOCK_MANDIRI_KEY,
                                                        API_DEPOSIT_AMOUNT_KEY,
                                                        API_VOUCHER_AMOUNT_KEY,
                                                        API_GRAND_TOTAL_BEFORE_FEE_KEY,
                                                        API_CONFIRMATION_CODE_IDR_KEY,
                                                        API_PAYMENT_LEFT_KEY,
                                                        API_VOUCHER_AMOUNT_IDR_KEY,
                                                        API_CONFIRMATION_DUE_DATE_KEY,
                                                        API_DEPOSIT_AFTER_KEY,
                                                        API_GRAND_TOTAL_KEY,
                                                        API_PAYMENT_LEFT_IDR_KEY,
                                                        API_CONFIRMATION_ID_KEY,
                                                        API_DEPOSIT_LEFT_KEY,
                                                        API_DATA_PARTIAL_KEY,
                                                        API_IS_USE_DEPOSIT_KEY,
                                                        API_PAYMENT_ID_KEY,
                                                        API_BCA_PARAM_KEY,
                                                        API_IS_USE_OTP_KEY,
                                                        API_NOW_DATE_KEY,
                                                        API_EMONEY_CODE_KEY,
                                                        API_UNIK_KEY,
                                                        API_GRAND_TOTAL_IDR_KEY,
                                                        API_DEPOSIT_AMOUNT_ID_KEY,
                                                        API_GA_DATA_KEY,
                                                        API_DISCOUNT_GATEWAY_IDR_KEY,
                                                        API_USER_DEFAULT_IDR_KEY,
                                                        API_MSISDN_VERIFIED_KEY,
                                                        API_GATEWAY_LIST_NAME_KEY,
                                                        API_GATEWAY_LIST_ID_KEY,
                                                        API_TOKEN_KEY,
                                                        API_STEP_KEY
                                                        ]];
    return transactionMapping;
}

-(RKObjectMapping*)systemBankMapping
{
    RKObjectMapping *sbMapping = [RKObjectMapping mappingForClass:[TransactionSystemBank class]];
    [sbMapping addAttributeMappingsFromArray:@[API_SYSTEM_BANK_BANK_CABANG_KEY,
                                                        API_SYSTEM_BANK_PICTURE_KEY,
                                                        API_SYSTEM_BANK_INFO_KEY,
                                                        API_SYSTEM_BANK_BANK_NAME_KEY,
                                                        API_SYSTEM_BANK_ACCOUNT_NUMBER_KEY,
                                                        API_SYSTEM_BANK_ACCOUNT_NAME_KEY
                                                        ]];
    return sbMapping;
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
