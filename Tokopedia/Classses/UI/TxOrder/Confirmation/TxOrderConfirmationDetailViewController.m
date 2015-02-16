//
//  TxOrderConfirmationDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_tx_order.h"

#import "TxOrderConfirmationDetailViewController.h"
#import "TxOrderConfirmationDetailHeaderView.h"
#import "TxOrderConfirmationProductCell.h"
#import "TxOrderConfirmationCostCell.h"
#import "TxOrderConfirmationDropshipCell.h"
#import "TxOrderConfirmationShipmentCell.h"
#import "TxOrderConfirmationList.h"
#import "TxOrderPaymentViewController.h"

@interface TxOrderConfirmationDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_list;
    BOOL _isNodata;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *payDueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDatelLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *depositAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *grandTotalLabel;

@end

@implementation TxOrderConfirmationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 10) {
        [_delegate shouldCancelOrderAtIndexPath:_indexPath];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
        TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
        vc.data = @{DATA_SELECTED_ORDER_KEY : @[detailOrder]};
        [self.navigationController pushViewController:vc animated:YES];
    }
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
#define PRODUCT_CELL_HEIGHT 210
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
        height = PRODUCT_CELL_HEIGHT;
    else if(indexPath.row == rowCount)
        height = SHIPMENT_HEIGHT;
    else if (indexPath.row == rowCount+1)
        height = (isDropshipper)?DROPSHIP_HEIGHT:COST_CELL_HEIGHT;
    else
        height = COST_CELL_HEIGHT;
    
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

#pragma mark - Methods
-(void)setData
{
    _tableView.tableHeaderView = _headerView;
    TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
    _list = detailOrder.order_list;
    
    _isNodata = !(_list.count>0);
    
    _payDueDateLabel.text = detailOrder.confirmation.pay_due_date;
    _transactionDatelLabel.text = detailOrder.confirmation.create_time;
    _totalPaymentLabel.text = detailOrder.confirmation.open_amount_before_fee;
    _depositAmountLabel.text = detailOrder.confirmation.deposit_amount;
    _transferCodeLabel.text = detailOrder.total_extra_fee;
    _grandTotalLabel.text = detailOrder.confirmation.open_amount;
}

-(UITableViewCell*)cellProductAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_ORDER_CONFIRMATION_PRODUCT_CELL_IDENTIFIER;
    
    TxOrderConfirmationProductCell *cell = (TxOrderConfirmationProductCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationProductCell newCell];
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *orderProduct = orderList.order_products[indexPath.row];
    
    NSString *weightTotal = [NSString stringWithFormat:@"%zd Barang (%@ kg)",orderProduct.product_quantity,orderProduct.product_weight];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_12 range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",orderProduct.product_weight]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",orderProduct.product_weight]]];
    cell.productWeightLabel.attributedText = attributedString;
    
    cell.productNameLabel.text = orderProduct.product_name;
    cell.productPriceLabel.text = orderProduct.product_price;
    cell.remarkTextView.text = [orderProduct.product_notes isEqualToString:@"0"]?@"":orderProduct.product_notes;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:orderProduct.product_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.productThumbImageView;
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

-(UITableViewCell*)cellCostAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = COST_CELL_IDENTIFIER;
    
    TxOrderConfirmationCostCell *cell = (TxOrderConfirmationCostCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationCostCell newCell];
    }
    
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    
    //TODO:: Biaya Tambahan
    cell.subtotalLabel.text = orderList.order_detail.detail_open_amount_idr;
    cell.insuranceLabel.text = orderList.order_detail.detail_insurance_price_idr;
    cell.shipmentFeeLabel.text = orderList.order_detail.detail_shipping_price_idr;
    cell.totalPaymentLabel.text = orderList.order_detail.detail_open_amount_idr;
    
    cell.recieverNameLabel.text = orderList.order_destination.receiver_name;
    cell.addressLabel.text = orderList.order_destination.address_street;
    cell.addressStreetLabel.text = orderList.order_destination.address_city;
    cell.addressCityLabel.text = [NSString stringWithFormat:@"%@, %@",orderList.order_destination.address_country,orderList.order_destination.address_postal];
    cell.recieverPhoneLabel.text = orderList.order_destination.receiver_phone;
                                    
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
    cell.insuranceLabel.text = (orderList.order_detail.detail_force_insurance==1)?@"Wajib Asuransi":([orderList.order_detail.detail_insurance_price isEqualToString:@"0"])?@"Ya":@"Tidak";
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
