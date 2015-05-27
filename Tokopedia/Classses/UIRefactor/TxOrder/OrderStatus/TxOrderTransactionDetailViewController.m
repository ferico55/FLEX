//
//  TxOrderTransactionDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderTransactionDetailViewController.h"

#import "NavigateViewController.h"

#import "TransactionCartCell.h"
#import "string_tx_order.h"

@interface TxOrderTransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource, TransactionCartCellDelegate>
{
    NavigateViewController *_navigate;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *shopView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *dropshipView;
@property (weak, nonatomic) IBOutlet UILabel *cancelAutomaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *insurancePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverName;
@property (weak, nonatomic) IBOutlet UILabel *addressStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverPhone;
@property (weak, nonatomic) IBOutlet UILabel *shipmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *partialLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopThumb;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *senderPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropshipHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressHeightConstraint;
@end

@implementation TxOrderTransactionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigate = [NavigateViewController new];
    
    self.title = @"Detail Transaksi";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    _tableView.tableHeaderView = _shopView;
    [self setDefaultData];

    NSString *textString = _addressStreetLabel.text;
    [_addressStreetLabel setCustomAttributedText:textString];
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    
    CGSize expectedLabelSize = [textString sizeWithFont:_addressStreetLabel.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:_addressStreetLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = _addressStreetLabel.frame;
    newFrame.size.height = expectedLabelSize.height + 26;
    _addressStreetLabel.frame = newFrame;
    
    CGRect frame = _detailView.frame;
    frame.size.height = 500+_dropshipHeightConstraint.constant+_addressStreetLabel.frame.size.height;
    _addressHeightConstraint.constant = 343 + _addressStreetLabel.frame.size.height;
    _detailView.frame = frame;
    
    _tableView.tableFooterView = _detailView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tap:(id)sender
{

}
- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if (gesture.view.tag == 10) {
        [_navigate navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
    }
    else
    {
        [_navigate navigateToShopFromViewController:self withShopID:_order.order_shop.shop_id];
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _order.order_products.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellTransactionCartAtIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Calculate the expected size based on the font and linebreak mode of your label
    NSInteger indexProduct = indexPath.row;//(list.cart_error_message_1)?indexPath.row-1:indexPath.row; //TODO:: adjust when error message appear
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexProduct];
    CGSize maximumLabelSize = CGSizeMake(190,9999);
    NSString *productNotes = (product.product_notes && ![product.product_notes isEqualToString:@"0"])?product.product_notes:@"-";
    NSString *string = productNotes;
    CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_13
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    return 210+expectedLabelSize.height;
}


#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexPath.row];
    [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexPath.row];
    [_navigate navigateToProductFromViewController:self withProductID:product.product_id];
}

- (void)tapMoreButtonActionAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(UITableViewCell*)cellTransactionCartAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellid = TRANSACTION_CART_CELL_IDENTIFIER;
    
    TransactionCartCell *cell = (TransactionCartCell*)[_tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartCell newcell];
        cell.delegate = self;
    }
    
    cell.border.hidden = NO;
    NSInteger indexProduct = indexPath.row;//(list.cart_error_message_1)?indexPath.row-1:indexPath.row; //TODO:: adjust when error message appear
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexProduct];
    cell.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1];
    [cell.productNameLabel setText:product.product_name animated:YES];
    [cell.productPriceLabel setText:product.order_subtotal_price_idr animated:YES];
    
    NSString *weightTotal = [NSString stringWithFormat:@"%zd Barang (%@ kg)",product.product_quantity, product.product_weight];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:weightTotal];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_12 range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_weight]]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",product.product_weight]]];
    cell.quantityLabel.attributedText = attributedString;
    
    NSIndexPath *indexPathCell = [NSIndexPath indexPathForRow:indexProduct inSection:indexPath.section-1];
    cell.indexPath = indexPathCell;
    cell.editButton.hidden = YES;
    NSString *productNotes = (product.product_notes && ![product.product_notes isEqualToString:@"0"])?product.product_notes:@"-";
    [cell.remarkLabel setCustomAttributedText:[NSString convertHTML:productNotes]];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.productThumbImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    return cell;
}

-(void)setDefaultData
{
    NSString *finishLabelText;
    UIColor *finishLabelColor;
    
    switch (_order.order_deadline.deadline_process_day_left) {
        case 3:
            finishLabelText = @"3 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            break;
        case 2:
            finishLabelText = @"2 Hari Lagi";
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
            break;
        case 1:
            finishLabelText = @"Besok";
            finishLabelColor = COLOR_STATUS_CANCEL_TOMORROW;
            break;
        case  0:
            finishLabelText = @"Hari Ini";
            finishLabelColor = COLOR_STATUS_CANCEL_TODAY;
            break;
        default:
            break;
    }
    
    if (_order.order_deadline.deadline_process_day_left<0) {
        finishLabelText = @"Expired";
        finishLabelColor = COLOR_STATUS_EXPIRED;
        [_finishLabel setHidden:NO];
        [_cancelAutomaticLabel setHidden:NO];
    }
    
    [_finishLabel setText:finishLabelText];
    _finishLabel.backgroundColor = finishLabelColor;
    
    _shopNameLabel.text = _order.order_shop.shop_name;
    
    [_invoiceLabel setCustomAttributedText:_order.order_detail.detail_invoice];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_order.order_shop.shop_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _shopThumb;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    _transactionDateLabel.text = _order.order_detail.detail_order_date;
    _subtotalLabel.text = _order.order_detail.detail_product_price_idr;
    _insurancePriceLabel.text = _order.order_detail.detail_insurance_price_idr;
    _shipmentPriceLabel.text = _order.order_detail.detail_shipping_price_idr;
    _totalPaymentLabel.text = _order.order_detail.detail_open_amount_idr;
    _recieverName.text = _order.order_destination.receiver_name;
    _recieverPhone.text = _order.order_destination.receiver_phone;
    NSString *address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@ %@",
                         _order.order_destination.address_street,
                         _order.order_destination.address_district,
                         _order.order_destination.address_city,
                         _order.order_destination.address_province,
                         _order.order_destination.address_postal];
    [_addressStreetLabel setCustomAttributedText:[NSString convertHTML:address]];
    _cityLabel.text = _order.order_destination.address_city;
    _countryLabel.text = [NSString stringWithFormat:@"%@, %@ %@",_order.order_destination.address_district,_order.order_destination.address_province, _order.order_destination.address_postal];
    _shipmentLabel.text = [NSString stringWithFormat:@"%@ - %@",_order.order_shipment.shipment_name,_order.order_shipment.shipment_product];
    _partialLabel.text = (_order.order_detail.detail_partial_order == 1)?@"Ya":@"Tidak";
    
    NSString *dropshipName = _order.order_detail.detail_dropship_name;
    if (!dropshipName || [dropshipName isEqualToString:@""] || [dropshipName isEqualToString:@"0"]) {
        _dropshipHeightConstraint.constant = 0;
        _dropshipView.hidden = YES;
    }
    else
    {
        _senderName.text = dropshipName;
        _senderPhone.text = _order.order_detail.detail_dropship_telp;
    }
}

@end
