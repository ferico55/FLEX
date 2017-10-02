//
//  TxOrderTransactionDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "LabelMenu.h"
#import "TxOrderTransactionDetailViewController.h"

#import "NavigateViewController.h"

#import "TransactionCartCell.h"
#import "string_tx_order.h"

#import "AlertInfoView.h"
#import "Tokopedia-Swift.h"

#define CTagAddress 2
#define CTagPhone 3

@interface TxOrderTransactionDetailViewController () <UITableViewDelegate, UITableViewDataSource, TransactionCartCellDelegate, LabelMenuDelegate>
{
    NavigateViewController *_navigate;
}
@property (weak, nonatomic) IBOutlet UILabel *insuranceTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoAddFeeButton;

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
@property (weak, nonatomic) IBOutlet LabelMenu *addressStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet LabelMenu *recieverPhone;
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
    _addressStreetLabel.tag = CTagAddress;
    _recieverPhone.tag = CTagPhone;
    
    _addressStreetLabel.delegate = _recieverPhone.delegate = self;
    [_addressStreetLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    [_recieverPhone addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    
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
    
    CGRect expectedLabelFrame = [textString boundingRectWithSize:maximumLabelSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{ NSFontAttributeName:_addressStreetLabel.font }
                                                         context:nil];
    CGSize expectedLabelSize = expectedLabelFrame.size;
    
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:_order.order_detail.detail_pdf_uri];
    }
    else
    {
        [_navigate navigateToShopFromViewController:self withShopID:_order.order_shop.shop_id];
    }
}
- (IBAction)tapInfoAddFee:(id)sender {
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Biaya Tambahan";
    alertInfo.detailText = @"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman";
    [alertInfo show];
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
    
    CGRect expectedLabelFrame = [string boundingRectWithSize:maximumLabelSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{ NSFontAttributeName:[UIFont title1Theme] }
                                                     context:nil];
    CGSize expectedLabelSize = expectedLabelFrame.size;
    
    return 126+expectedLabelSize.height;
}


#pragma mark - Method
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UILabel *lbl = (UILabel *)sender.view;
        [lbl becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:lbl.frame inView:lbl.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}


#pragma mark - Cell Delegate
-(void)didTapImageViewAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexPath.row];
    
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:product.product_id
                                                        andName:product.product_name
                                                       andPrice:product.product_price
                                                    andImageURL:product.product_picture
                                                    andShopName:_order.order_shop.shop_name];
}

-(void)didTapProductAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listProducts = _order.order_products;
    OrderProduct *product = listProducts[indexPath.row];
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:product.product_id
                                                        andName:product.product_name
                                                       andPrice:product.product_price
                                                    andImageURL:product.product_picture
                                                    andShopName:_order.order_shop.shop_name];
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
    
    ((TransactionCartCell*)cell).indexPage = 1;
    ((TransactionCartCell*)cell).indexPath = indexPath;
    [(TransactionCartCell*)cell setViewModel:product.viewModel];
    NSString *productNotes = product.viewModel.productNotes;
    
    if ([productNotes isEqualToString:@""] || [productNotes isEqualToString:@"0"]) {
        productNotes = @"-";
    }
    [cell.remarkLabel setCustomAttributedText:productNotes];
    
    return cell;
}

-(void)setDefaultData
{
    NSString *finishLabelText;
    UIColor *finishLabelColor;
    
    switch (_order.order_deadline.deadline_process_day_left) {
        case 1:
            finishLabelText = @"Besok";
            finishLabelColor = COLOR_STATUS_CANCEL_TOMORROW;
            break;
        case  0:
            finishLabelText = @"Hari Ini";
            finishLabelColor = COLOR_STATUS_CANCEL_TODAY;
            break;
        default:
            finishLabelText = [NSString stringWithFormat:@"%zd Hari Lagi",_order.order_deadline.deadline_process_day_left];
            finishLabelColor = COLOR_STATUS_CANCEL_3DAYS;
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
    _insuranceTextLabel.text = ([_order.order_detail.detail_additional_fee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
    _insurancePriceLabel.text = ([_order.order_detail.detail_additional_fee integerValue]==0)?_order.order_detail.detail_insurance_price_idr:_order.order_detail.detail_total_add_fee_idr;
    _infoAddFeeButton.hidden = ([_order.order_detail.detail_additional_fee integerValue]==0);
    
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


#pragma mark - LabelMenu Delegate
- (void)duplicate:(int)tag
{
    if(tag == CTagAddress) {
        [UIPasteboard generalPasteboard].string = _addressStreetLabel.text;
    }
    else if(tag == CTagPhone) {
        [UIPasteboard generalPasteboard].string = _recieverPhone.text;
    }
}
@end
