//
//  TxOrderConfirmationDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_tx_order.h"

#import "NavigateViewController.h"

#import "TxOrderConfirmationDetailViewController.h"
#import "TxOrderConfirmationDetailHeaderView.h"
#import "TxOrderConfirmationProductCell.h"
#import "TxOrderConfirmationCostCell.h"
#import "TxOrderConfirmationDropshipCell.h"
#import "TxOrderConfirmationShipmentCell.h"
#import "TxOrderConfirmationList.h"
#import "TxOrderPaymentViewController.h"
#import "AlertListBankView.h"

#import "ListRekeningBank.h"

#import "TransactionCartCell.h"
#import "RequestOrderData.h"

@interface TxOrderConfirmationDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TxOrderConfirmationDetailHeaderViewDelegate,
    TxOrderConfirmationProductCellDelegate
>
{
    NSArray *_list;
    BOOL _isNodata;
    
    NavigateViewController *_navigate;
    
    UILabel *_addressLabel;
    UILabel *_remarkLabel;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *payDueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDatelLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *depositAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRekeningInfo;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation TxOrderConfirmationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self setData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Detail Transaksi";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.title = @" ";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tapCancelPayment:(id)sender {
    
    [self doRequestDataCancelPayment];
    
}
- (IBAction)tapConfirmPayment:(id)sender {
    
    TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
    TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
    vc.paymentID = @[detailOrder.confirmation.confirmation_id];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)tapRekInfo:(id)sender {
    AlertListBankView *popUp = [AlertListBankView newview];
    ListRekeningBank *listBank = [ListRekeningBank new];
    popUp.list = [listBank getRekeningBankList];
    [popUp show];
}


#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *product = orderList.order_products[indexPath.row];
//    [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
    [_navigate navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_picture withShopName:orderList.order_shop.shop_name];
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *product = orderList.order_products[indexPath.row];
    [_navigate navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_picture withShopName:orderList.order_shop.shop_name];
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger rowCount = _list.count;
    return _isNodata ? 0 : rowCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    TxOrderConfirmationListOrder *orderList = _list[section];
    NSInteger rowCount = orderList.order_products.count+2;
    
    BOOL isDropshipper = (![orderList.order_detail.detail_dropship_name isEqualToString:@"0"]);
    if (isDropshipper) {
        rowCount=orderList.order_products.count+3;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    NSInteger rowCount = orderList.order_products.count;
    BOOL isDropshipper = (![orderList.order_detail.detail_dropship_name isEqualToString:@"0"]);
    
    if (indexPath.row < rowCount)
        cell = [self cellProductAtIndexPath:indexPath];
    else if(indexPath.row == rowCount)
        cell = [self cellShipmentAtIndexPath:indexPath];
    else if(indexPath.row == rowCount+1)
        cell = (isDropshipper)?[self cellDropshipAtIndexPath:indexPath]:[self cellCostAtIndexPath:indexPath];
    else
        cell = [self cellCostAtIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
#define PRODUCT_CELL_HEIGHT 126
#define DROPSHIP_HEIGHT 165
#define SHIPMENT_HEIGHT 200
#define COST_CELL_HEIGHT 435
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    BOOL isDropshipper = (![orderList.order_detail.detail_dropship_name isEqualToString:@"0"]);
    NSInteger rowCount = orderList.order_products.count;
    if (indexPath.row < rowCount)
    {
        OrderProduct *orderProduct = orderList.order_products[indexPath.row];
        
        CGSize maximumLabelSize = CGSizeMake(190,9999);
        
        NSString *string = [orderProduct.viewModel.productNotes isEqualToString:@"0"]?@"":orderProduct.viewModel.productNotes;
        
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_16
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByTruncatingTail];
        
        return PRODUCT_CELL_HEIGHT+expectedLabelSize.height;
    }
    else if(indexPath.row == rowCount)
        height = SHIPMENT_HEIGHT;
    else if (indexPath.row == rowCount+1)
    {
        if (isDropshipper) {
            height = DROPSHIP_HEIGHT;
        }
        else
        {
            //Calculate the expected size based on the font and linebreak mode of your label
            CGSize maximumLabelSize = CGSizeMake(290,9999);
            
            CGSize expectedLabelSize = [_addressLabel.text sizeWithFont:_addressLabel.font
                                                          constrainedToSize:maximumLabelSize
                                                              lineBreakMode:_addressLabel.lineBreakMode];
            
            //adjust the label the the new height.
            CGRect newFrame = _addressLabel.frame;
            newFrame.size.height = expectedLabelSize.height;
            height = COST_CELL_HEIGHT + newFrame.size.height;
        }
    }
    else
    {
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(290,9999);
        
        CGSize expectedLabelSize = [_addressLabel.text sizeWithFont:_addressLabel.font
                                          constrainedToSize:maximumLabelSize
                                              lineBreakMode:_addressLabel.lineBreakMode];
        
        //adjust the label the the new height.
        CGRect newFrame = _addressLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        height = COST_CELL_HEIGHT + newFrame.size.height;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TxOrderConfirmationListOrder *orderList = _list[section];
    OrderShop *orderShop =orderList.order_shop;
    OrderDetail *orderDetail = orderList.order_detail;
    
    TxOrderConfirmationDetailHeaderView *headerView = [TxOrderConfirmationDetailHeaderView newview];
    headerView.shopNameLabel.text = orderShop.shop_name;
    headerView.invoiceLabel.text = orderDetail.detail_invoice;
    headerView.delegate = self;
    headerView.section = section;
    
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));

    }
}

#pragma mark - AlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self doRequestCancelPayment];
    }
}

-(void)doRequestDataCancelPayment{
    
    for (UIButton *button in _buttons) {
        button.enabled = NO;
    }
    
    TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
    NSString * confirmationID = detailOrder.confirmation.confirmation_id?:@"";
    
    [RequestOrderData fetchDataCancelConfirmationID:confirmationID Success:^(TxOrderCancelPaymentFormForm *data) {
        
        NSString *cancelAlertDesc;
        NSString *totalRefund = [data.total_refund stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@",-" withString:@""];
        totalRefund = [totalRefund stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([totalRefund isEqualToString:@"0"])
            cancelAlertDesc = @"Apakah anda yakin membatalkan transaksi ini?";
        else
            cancelAlertDesc = [NSString stringWithFormat:ALERT_DESCRIPTION_CANCEL_PAYMENT_CONFIRMATION,data.total_refund];
        
        UIAlertView *cancelAlert = [[UIAlertView alloc]initWithTitle:ALERT_TITLE_CANCEL_PAYMENT_CONFIRMATION
                                                             message:cancelAlertDesc
                                                            delegate:self
                                                   cancelButtonTitle:@"Tidak"
                                                   otherButtonTitles:@"Ya", nil];
        [cancelAlert show];
        
        for (UIButton *button in _buttons) {
            button.enabled = YES;
        }
    } failure:^(NSError *error) {
        for (UIButton *button in _buttons) {
            button.enabled = YES;
        }
    }];
}

-(void)doRequestCancelPayment{
    TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
    NSString * confirmationID = detailOrder.confirmation.confirmation_id?:@"";
    
    [RequestOrderAction fetchCancelConfirmationID:confirmationID Success:^(TransactionAction *data) {
        
        [_delegate didCancelOrder:detailOrder];
        NSDictionary *userInfo = @{DATA_PAYMENT_CONFIRMATION_COUNT_KEY:@(1)};
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:userInfo];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Header Delegate
-(void)goToInvoiceAtSection:(NSInteger)section
{
    TxOrderConfirmationListOrder *orderList = _list[section];
    [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:orderList.order_detail.detail_pdf_uri];
}

-(void)goToShopAtSection:(NSInteger)section
{
    TxOrderConfirmationListOrder *orderList = _list[section];
    [_navigate navigateToShopFromViewController:self withShopID:orderList.order_shop.shop_id];
}

#pragma mark - Methods
-(void)setData
{
    _tableView.tableHeaderView = _headerView;
    TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
    _list = detailOrder.order_list;
    
    _isNodata = !(_list.count>0);
    
    _payDueDateLabel.text = detailOrder.confirmation.pay_due_date;
    _transactionDatelLabel.text = detailOrder.confirmation.create_time;
    _totalPaymentLabel.text = detailOrder.confirmation.open_amount_before_fee?:@"Rp 0,-";
    _depositAmountLabel.text = detailOrder.confirmation.deposit_amount?:@"Rp 0,-";
    _transferCodeLabel.text = detailOrder.total_extra_fee?:@"Rp 0,-";
    _grandTotalLabel.text = detailOrder.confirmation.left_amount;
}


-(UITableViewCell*)cellProductAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_ORDER_CONFIRMATION_PRODUCT_CELL_IDENTIFIER;
    
    TransactionCartCell *cell = (TransactionCartCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartCell newcell];
        cell.delegate = self;
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *orderProduct = orderList.order_products[indexPath.row];
    
    ((TransactionCartCell*)cell).indexPage = 1;
    [(TransactionCartCell*)cell setViewModel:orderProduct.viewModel];
    NSString *productNotes = orderProduct.viewModel.productNotes;
    
    if ([productNotes isEqualToString:@""] || [productNotes isEqualToString:@"0"]) {
        productNotes = @"-";
    }
    [cell.remarkLabel setCustomAttributedText:productNotes];
    
    cell.indexPath = indexPath;
    
    return cell;
}

-(UITableViewCell*)cellCostAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = COST_CELL_IDENTIFIER;
    
    TxOrderConfirmationCostCell *cell = (TxOrderConfirmationCostCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationCostCell newCell];
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    
    cell.subtotalLabel.text = orderList.order_detail.detail_product_price_idr;
    cell.shipmentFeeLabel.text = orderList.order_detail.detail_shipping_price_idr;
    cell.totalPaymentLabel.text = orderList.order_detail.detail_open_amount_idr;
    cell.InsuranceTitle.text = ([orderList.order_detail.detail_additional_fee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
    cell.insuranceLabel.text = ([orderList.order_detail.detail_additional_fee integerValue]==0)?orderList.order_detail.detail_insurance_price_idr:orderList.order_detail.detail_total_add_fee_idr;
    cell.infoButton.hidden = ([orderList.order_detail.detail_additional_fee integerValue]==0);
    cell.recieverNameLabel.text = orderList.order_destination.receiver_name;
    NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@ %@",
                         orderList.order_destination.address_street,
                         orderList.order_destination.address_district,
                         orderList.order_destination.address_city,
                         orderList.order_destination.address_province,
                         orderList.order_destination.address_postal];
    [cell.addressLabel setCustomAttributedText:[NSString convertHTML:address]];
    cell.recieverPhoneLabel.text = orderList.order_destination.receiver_phone;
    _addressLabel = cell.addressLabel;
    
    return cell;
}

-(UITableViewCell*)cellShipmentAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = SHIPMENT_CELL_IDENTIFIER;
    
    TxOrderConfirmationShipmentCell *cell = (TxOrderConfirmationShipmentCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationShipmentCell newCell];
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    cell.shipmentLabel.text = [NSString stringWithFormat:@"%@ - %@",orderList.order_shipment.shipment_name, orderList.order_shipment.shipment_product];
    BOOL isDropshipper = (![orderList.order_detail.detail_dropship_name isEqualToString:@"0"]);
    [cell.dropshipLabel setText:(isDropshipper)?@"Ya":@"Tidak" animated:YES];
    cell.insuranceLabel.text = ([orderList.order_detail.detail_insurance_price isEqualToString:@"0"])?@"Tidak":@"Ya";
    //(orderList.order_detail.detail_force_insurance==1)?@"Wajib Asuransi":([orderList.order_detail.detail_insurance_price isEqualToString:@"0"])?@"Tidak":@"Ya";
    cell.partialLabel.text = (orderList.order_detail.detail_partial_order==0)?@"Tidak":@"Ya";
    return cell;
}

-(UITableViewCell*)cellDropshipAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = DROPSHIP_CELL_IDENTIFIER;
    
    TxOrderConfirmationDropshipCell *cell = (TxOrderConfirmationDropshipCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationDropshipCell newCell];
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];

    [cell.dropshipNameLabel setText:orderList.order_detail.detail_dropship_name animated:YES];
    [cell.dropshipPhoneLabel setText:orderList.order_detail.detail_dropship_telp animated:YES];
    
    return cell;
}

@end
