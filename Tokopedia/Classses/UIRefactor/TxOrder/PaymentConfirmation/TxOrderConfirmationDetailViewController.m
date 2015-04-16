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
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button.tag == 10) {
        [_delegate shouldCancelOrderAtIndexPath:_indexPath viewController:self];
    }
    else
    {
        TxOrderConfirmationList *detailOrder = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
        TxOrderPaymentViewController *vc = [TxOrderPaymentViewController new];
        vc.data = @{DATA_SELECTED_ORDER_KEY : @[detailOrder]};
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *product = orderList.order_products[indexPath.row];
    [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmationListOrder *orderList = _list[indexPath.section];
    OrderProduct *product = orderList.order_products[indexPath.row];
    [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
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
    {
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        
        CGSize expectedLabelSize = [_remarkLabel.text sizeWithFont:_remarkLabel.font
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:_remarkLabel.lineBreakMode];
        
        //adjust the label the the new height.
        CGRect newFrame = _remarkLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        height = PRODUCT_CELL_HEIGHT + newFrame.size.height;
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
            CGSize maximumLabelSize = CGSizeMake(200,9999);
            
            CGSize expectedLabelSize = [_addressLabel.text sizeWithFont:_addressLabel.font
                                                          constrainedToSize:maximumLabelSize
                                                              lineBreakMode:_addressLabel.lineBreakMode];
            
            //adjust the label the the new height.
            CGRect newFrame = _addressLabel.frame;
            newFrame.size.height = expectedLabelSize.height;
            height = COST_CELL_HEIGHT - 50 + newFrame.size.height;
        }
    }
    else
    {
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        
        CGSize expectedLabelSize = [_addressLabel.text sizeWithFont:_addressLabel.font
                                          constrainedToSize:maximumLabelSize
                                              lineBreakMode:_addressLabel.lineBreakMode];
        
        //adjust the label the the new height.
        CGRect newFrame = _addressLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        height = COST_CELL_HEIGHT - 50 + newFrame.size.height;
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
        //[self actionCancelConfirmationObject:_objectProcessingCancel];
        [_delegate didTapAlertCancelOrder];
        [self.navigationController popViewControllerAnimated:YES];
    }
    //[_objectProcessingCancel removeAllObjects];
}

#pragma mark - Header Delegate
-(void)goToInvoiceAtSection:(NSInteger)section
{
    TxOrderConfirmationListOrder *orderList = _list[section];
    [_navigate navigateToInvoiceFromViewController:self withInvoiceURL:orderList.order_detail.detail_pdf_uri];
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
    
    TxOrderConfirmationProductCell *cell = (TxOrderConfirmationProductCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TxOrderConfirmationProductCell newCell];
        cell.delegate = self;
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
    [cell.remarkLabel setCustomAttributedText:[orderProduct.product_notes isEqualToString:@"0"]?@"":[NSString convertHTML:orderProduct.product_notes]];
    _remarkLabel = cell.remarkLabel;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:orderProduct.product_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.productThumbImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
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
    cell.insuranceLabel.text = orderList.order_detail.detail_insurance_price_idr;
    cell.shipmentFeeLabel.text = orderList.order_detail.detail_shipping_price_idr;
    cell.totalPaymentLabel.text = orderList.order_detail.detail_open_amount_idr;
    
    cell.recieverNameLabel.text = orderList.order_destination.receiver_name;
    NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@, %@ %@",
                         orderList.order_destination.address_street,
                         orderList.order_destination.address_city,
                         orderList.order_destination.address_district,
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
    cell.insuranceLabel.text = (orderList.order_detail.detail_force_insurance==1)?@"Wajib Asuransi":([orderList.order_detail.detail_insurance_price isEqualToString:@"0"])?@"Tidak":@"Ya";
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
