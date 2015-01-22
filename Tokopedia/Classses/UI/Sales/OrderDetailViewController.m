//
//  NewOrderDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailProductCell.h"
#import "OrderDetailProductInformationCell.h"

@interface OrderDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *orderHeaderView;
@property (strong, nonatomic) IBOutlet UIView *orderFooterView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *automaticallyRejectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLeftLabel;

@property (weak, nonatomic) IBOutlet UILabel *buyerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buyerProfileImageView;

@property (weak, nonatomic) IBOutlet UILabel *receiverNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *courierAgentLabel;

@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalProductLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTotalFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *assuranceFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFeeLabel;

@end

@implementation OrderDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Detail Transaksi";

    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered
                                                                     target:nil
                                                                     action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    _tableView.tableHeaderView = _orderHeaderView;
    _tableView.tableFooterView = _orderFooterView;
    _tableView.contentInset = UIEdgeInsetsMake(22, 0, 44, 0);
    _tableView.contentOffset = CGPointMake(0, -22);
    
    UITapGestureRecognizer *buyerNameGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(tap:)];
    [_buyerNameLabel addGestureRecognizer:buyerNameGesture];
    _buyerNameLabel.text = _transaction.order_customer.customer_name;

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_transaction.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    [_buyerProfileImageView setImageWithURLRequest:request
                                  placeholderImage:_buyerProfileImageView.image
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
       _buyerProfileImageView.image = image;
       _buyerProfileImageView.clipsToBounds = YES;
       _buyerProfileImageView.contentMode = UIViewContentModeScaleToFill;
    } failure:nil];
    
    _invoiceNumberLabel.text = _transaction.order_detail.detail_invoice;
    
    if (_transaction.order_payment.payment_process_day_left == 1) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:145.0/255.0
                                                                   blue:0.0/255.0
                                                                  alpha:1];
        _dayLeftLabel.text = @"Besok";
        
    } else if (_transaction.order_payment.payment_process_day_left == 0) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                                  green:59.0/255.0
                                                                   blue:48.0/255.0
                                                                  alpha:1];
        _dayLeftLabel.text = @"Hari ini";
        
    } else if (_transaction.order_payment.payment_process_day_left < 0) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:158.0/255.0
                                                                  green:158.0/255.0
                                                                   blue:158.0/255.0
                                                                  alpha:1];
        _dayLeftLabel.text = @"Expired";
        
    } else {
        _dayLeftLabel.text = [NSString stringWithFormat:@"%d Hari lagi", (int)_transaction.order_payment.payment_process_day_left];
    }
    
    _receiverNameLabel.text = _transaction.order_destination.receiver_name;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:13],
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *addressAttributedString = [[NSAttributedString alloc] initWithString:_transaction.order_destination.address_street
                                                                                    attributes:attributes];
    _addressLabel.attributedText = addressAttributedString;
    _addressLabel.numberOfLines = 0;
    [_addressLabel sizeToFit];
    

    NSAttributedString *cityAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@",
                                                                                           _transaction.order_destination.address_city,
                                                                                           _transaction.order_destination.address_district]
                                                                                  attributes:attributes];
    _cityLabel.attributedText = cityAttributedString;
    _cityLabel.numberOfLines = 0;
    [_cityLabel sizeToFit];
    
    
    NSAttributedString *countryAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@, %@",
                                                                                           _transaction.order_destination.address_province,
                                                                                           _transaction.order_destination.address_country,
                                                                                           _transaction.order_destination.address_postal]
                                                                               attributes:attributes];
    _countryLabel.attributedText = countryAttributedString;
    _countryLabel.numberOfLines = 0;
    [_countryLabel sizeToFit];
    
    _phoneNumberLabel.text = _transaction.order_destination.receiver_phone;
    _courierAgentLabel.text = [NSString stringWithFormat:@"%@ - %@",
                               _transaction.order_shipment.shipment_product,
                               _transaction.order_shipment.shipment_name];
    
    _paymentMethodLabel.text = _transaction.order_payment.payment_gateway_name;
    
    _totalProductLabel.text = [NSString stringWithFormat:@"%@ Barang (%.3f kg)",
                               [NSNumber numberWithInteger:_transaction.order_detail.detail_quantity],
                               _transaction.order_detail.detail_total_weight];
    
    _subTotalFeeLabel.text = _transaction.order_detail.detail_product_price_idr;
    _assuranceFeeLabel.text = _transaction.order_detail.detail_insurance_price_idr;
    _shipmentFeeLabel.text = _transaction.order_detail.detail_shipping_price_idr;
    _totalFeeLabel.text = _transaction.order_detail.detail_open_amount_idr;
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    topBorder.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:0.2];
    [_orderFooterView addSubview:topBorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_transaction.order_products count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 150.0;
    } else {
        return 64.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderProduct *product = [_transaction.order_products objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {

        static NSString *productCellIdentifer = @"OrderDetailProductCell";
        OrderDetailProductCell *cell = (OrderDetailProductCell *)[tableView dequeueReusableCellWithIdentifier:productCellIdentifer];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:productCellIdentifer owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.productNameLabel.text = product.product_name;
        cell.productPriceLabel.text = product.product_price;
        cell.productWeightLabel.text = [NSString stringWithFormat:@"%@ kg", product.product_weight];
        
        CGFloat totalWeight = product.product_quantity * [product.product_weight floatValue];
        cell.productTotalWeightLabel.text = [NSString stringWithFormat:@"%@ Barang (%.3f kg)",
                                             [NSNumber numberWithInteger:product.product_quantity],
                                             totalWeight];
        
        cell.productTotalPriceLabel.text = product.order_subtotal_price_idr;
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_picture]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        cell.productImageView.image = nil;
        [cell.productImageView setImageWithURLRequest:request
                                     placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.productImageView.image = image;
            cell.productImageView.clipsToBounds = YES;
            cell.productImageView.contentMode = UIViewContentModeScaleAspectFill;
        } failure:nil];
        
        return cell;

    } else {

        static NSString *productCellIdentifer = @"OrderDetailProductInformationCell";
        OrderDetailProductInformationCell *cell = (OrderDetailProductInformationCell *)[tableView dequeueReusableCellWithIdentifier:productCellIdentifer];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:productCellIdentifer owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        if ([product.product_notes isEqualToString:@"0"]) {
            cell.productInformationLabel.text = @"-";
        } else {
            cell.productInformationLabel.text = product.product_notes;
        }
        
        return cell;
        
    }
}

#pragma mark - Action

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            
        } else if (button.tag == 2) {
            
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
