//
//  NewOrderDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "LabelMenu.h"
#import "OrderDetailViewController.h"
#import "OrderDetailProductCell.h"
#import "OrderDetailProductInformationCell.h"
#import "ProductQuantityViewController.h"
#import "ChooseProductViewController.h"
#import "OrderRejectExplanationViewController.h"
#import "ShipmentConfirmationViewController.h"
#import "DetailShipmentStatusViewController.h"
#import "SalesNewOrderViewController.h"
#import "ShipmentStatusViewController.h"
#import "CancelShipmentViewController.h"
#import "SubmitShipmentConfirmationViewController.h"
#import "TKPDTabProfileNavigationController.h"
#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"
#import "AlertInfoView.h"
#import "OrderBookingData.h"
#import "OrderBookingResponse.h"

#define CTagAddress 2
#define CTagPhone 3

typedef enum TagRequest {
    OrderDetailTag
} TagRequest;

@interface OrderDetailViewController ()
<
    LabelMenuDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    ProductQuantityDelegate,
    ChooseProductDelegate,
    RejectExplanationDelegate,
    SubmitShipmentConfirmationDelegate,
    CancelShipmentConfirmationDelegate,
    TokopediaNetworkManagerDelegate
>

@property (weak, nonatomic) IBOutlet UIView *topButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;

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

@property (weak, nonatomic) IBOutlet LabelMenu *addressLabel;
@property (weak, nonatomic) IBOutlet LabelMenu *cityLabel;
@property (weak, nonatomic) IBOutlet LabelMenu *countryLabel;

@property (weak, nonatomic) IBOutlet LabelMenu *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *courierAgentLabel;
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;

@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalProductLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTotalFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *assuranceFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipmentFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFeeLabel;

@property (weak, nonatomic) IBOutlet UIView *dropshipView;
@property (weak, nonatomic) IBOutlet UILabel *dropshipSenderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropshipSenderPhoneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropshipViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIView *detailTransactionView;
@property (weak, nonatomic) IBOutlet UILabel *transactionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *transactionDueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivePartialOrderLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoAddFeeButton;
@property (weak, nonatomic) IBOutlet UILabel *insuranceTextLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shipmentDestinationLayoutConstraintTop;
@property (strong, nonatomic) IBOutlet UIView *pickupLocationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickupLocationHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationAddressLabel;

@property (strong, nonatomic) UITapGestureRecognizer *singleTapGestureRecognizer;

@property (strong, nonatomic) NSDictionary *textAttributes;

@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation OrderDetailViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"Detail Transaksi";

    [self initializeTableView];
    
    [self setContentFrame];
    
    [self setBackButton];
    
    [self addGestureToLabels];
    
    [self request];

    [self setData];
    
    if ([_delegate isKindOfClass:[SalesNewOrderViewController class]]) {
        [self updateFrameForNewOrder];
    } else if ([_delegate isKindOfClass:[ShipmentConfirmationViewController class]]) {
        [self updateFrameForShipmentConfirmation];
    } else if ([_delegate isKindOfClass:[DetailShipmentStatusViewController class]]) {
        [self updateFrameForShipmentStatus];
    }
    
    CGFloat top = _tableView.contentInset.top;
    CGFloat left = _tableView.contentInset.left;
    CGFloat bottom = _tableView.contentInset.bottom + _addressLabel.frame.size.height;
    CGFloat right = _tableView.contentInset.right;

    _tableView.contentInset = UIEdgeInsetsMake(top, right, bottom, left);
    _tableView.contentOffset = CGPointMake(0, -66);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods

- (void)setContentFrame {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGRect frame = _detailTransactionView.frame;
    frame.size.width = screenWidth;
    _detailTransactionView.frame = frame;
}

- (void)setBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)addGestureToLabels {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    
    _addressLabel.gestureRecognizers = @[recognizer];
    _addressLabel.userInteractionEnabled = YES;
    _addressLabel.delegate = self;
    _addressLabel.tag = CTagAddress;

    _cityLabel.gestureRecognizers = @[recognizer];
    _cityLabel.userInteractionEnabled = YES;
    _cityLabel.delegate = self;
    _cityLabel.tag = CTagAddress;
    
    _countryLabel.gestureRecognizers = @[recognizer];
    _countryLabel.userInteractionEnabled = YES;
    _countryLabel.delegate = self;
    _countryLabel.tag = CTagAddress;

    _phoneNumberLabel.gestureRecognizers = @[recognizer];
    _phoneNumberLabel.userInteractionEnabled = YES;
    _phoneNumberLabel.delegate = self;
    _phoneNumberLabel.tag = CTagPhone;
}

- (void)setData {
    [self setInvoiceData];
    [self setBuyerInformation];
    [self setReceiverData];
    [self setPickupData];
    [self setCostData];
    [self setFooterView];
}

- (void)setInvoiceData {
    _invoiceNumberLabel.text = _transaction.order_detail.detail_invoice;
    _invoiceDateLabel.text = _transaction.order_payment.payment_verify_date;
}

- (void)setBuyerInformation {
    UITapGestureRecognizer *buyerNameGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(tap:)];
    _buyerNameLabel.gestureRecognizers = @[buyerNameGesture];
    _buyerNameLabel.text = _transaction.order_customer.customer_name;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_transaction.order_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    _buyerProfileImageView.layer.cornerRadius = _buyerProfileImageView.frame.size.width/2;
    [_buyerProfileImageView setImageWithURLRequest:request
                                  placeholderImage:_buyerProfileImageView.image
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               _buyerProfileImageView.image = image;
                                               _buyerProfileImageView.clipsToBounds = YES;
                                               _buyerProfileImageView.contentMode = UIViewContentModeScaleToFill;
                                           } failure:nil];
}

- (void)setReceiverData {
    _receiverNameLabel.text = _transaction.order_destination.receiver_name;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:13],
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSString *address = [_transaction.order_destination.address_street stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    address = [address stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    address = [address stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    NSAttributedString *addressAttributedString = [[NSAttributedString alloc] initWithString:address
                                                                                  attributes:attributes];
    _addressLabel.attributedText = addressAttributedString;
    _addressLabel.numberOfLines = 0;
    [_addressLabel sizeToFit];
    
    NSString *city = [NSString stringWithFormat:@"%@\n%@",
                      _transaction.order_destination.address_district,
                      _transaction.order_destination.address_city];
    city = [city stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    city = [city stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    NSAttributedString *cityAttributedString = [[NSAttributedString alloc] initWithString:city
                                                                               attributes:attributes];
    _cityLabel.attributedText = cityAttributedString;
    _cityLabel.numberOfLines = 0;
    [_cityLabel sizeToFit];
    
    NSString *country = [NSString stringWithFormat:@"%@, %@, %@",
                         _transaction.order_destination.address_province,
                         _transaction.order_destination.address_country,
                         _transaction.order_destination.address_postal];
    country = [country stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    country = [country stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    NSAttributedString *countryAttributedString = [[NSAttributedString alloc] initWithString:country
                                                                                  attributes:attributes];
    _countryLabel.attributedText = countryAttributedString;
    _countryLabel.numberOfLines = 0;
    [_countryLabel sizeToFit];
    
    _phoneNumberLabel.text = _transaction.order_destination.receiver_phone;
    
    _courierAgentLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                               _transaction.order_shipment.shipment_name,
                               _transaction.order_shipment.shipment_product];
    
    _receivePartialOrderLabel.text = _transaction.order_detail.detail_partial_order?@"Ya":@"Tidak";
}

- (void)setPickupData {
    // GO-KILAT
    if (_transaction.order_shipment.shipment_id == 10) {
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 6.0;
        
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName  : [UIColor blackColor],
            NSFontAttributeName             : [UIFont fontWithName:@"GothamBook" size:13],
            NSParagraphStyleAttributeName   : style,
        };
        
        CGFloat previousHeight = _pickupLocationAddressLabel.frame.size.height;
        
        NSString *address = _transaction.order_shop.address_street;
        _pickupLocationAddressLabel.attributedText = [[NSAttributedString alloc] initWithString:address attributes:attributes];
        [_pickupLocationAddressLabel sizeToFit];
        
        CGFloat newHeight = _pickupLocationAddressLabel.frame.size.height + 5; // Additional 5 point
        CGFloat additionalHeight = newHeight - previousHeight;
        CGFloat newFrameHeight = _pickupLocationView.frame.size.height + additionalHeight;
        
        [self.orderFooterView addSubview:_pickupLocationView];
        self.shipmentDestinationLayoutConstraintTop.constant += newFrameHeight;
        
    } else {
        CGRect frame = self.pickupLocationView.frame;
        frame.size.height = 0;
        self.pickupLocationView.frame = frame;
        self.pickupLocationView.hidden = YES;
        self.pickupLocationHeightConstraint.constant = 0;
        
        CGRect footerFrame = _orderFooterView.frame;
        footerFrame.size.height -= 10;
        _orderFooterView.frame = footerFrame;
    }
}

- (void)setCostData {
    _paymentMethodLabel.text = _transaction.order_payment.payment_gateway_name;
    
    _totalProductLabel.text = [NSString stringWithFormat:@"%@ Barang (%.3f kg)",
                               [NSNumber numberWithInteger:_transaction.order_detail.detail_quantity],
                               _transaction.order_detail.detail_total_weight];
    
    _subTotalFeeLabel.text = _transaction.order_detail.detail_product_price_idr;
    _assuranceFeeLabel.text = _transaction.order_detail.detail_insurance_price_idr;
    _insuranceTextLabel.text = ([_transaction.order_detail.detail_additional_fee integerValue]==0)?@"Biaya Asuransi":@"Biaya Tambahan";
    _assuranceFeeLabel.text = ([_transaction.order_detail.detail_additional_fee integerValue]==0)?_transaction.order_detail.detail_insurance_price_idr:_transaction.order_detail.detail_total_add_fee_idr;
    _infoAddFeeButton.hidden = ([_transaction.order_detail.detail_additional_fee integerValue]==0);
    
    _shipmentFeeLabel.text = _transaction.order_detail.detail_shipping_price_idr;
    _totalFeeLabel.text = _transaction.order_detail.detail_open_amount_idr;
}

- (void)setDropshipData {
    _dropshipSenderNameLabel.text = _transaction.order_detail.detail_dropship_name;
    _dropshipSenderPhoneLabel.text = _transaction.order_detail.detail_dropship_telp;
}

- (void)request {
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = OrderDetailTag;
    _networkManager.isUsingHmac = YES;
    [_networkManager doRequest];
}

- (void)initializeTableView {
    _tableView.tableHeaderView = _orderHeaderView;
    _tableView.contentOffset = CGPointMake(0, -22);
}

- (void)setFooterView {
    CGFloat additionalHeight = 0;
    additionalHeight += _pickupLocationView.frame.size.height;
    additionalHeight += _addressLabel.frame.size.height;
    additionalHeight += _cityLabel.frame.size.height;
    additionalHeight += _countryLabel.frame.size.height;
    
    CGFloat heightLeftOvers = 30;
    additionalHeight -= heightLeftOvers;
    
    CGRect frame = _orderFooterView.frame;
    frame.size.height += additionalHeight;
    _orderFooterView.frame = frame;
    
    _tableView.tableFooterView = _orderFooterView;
    
    _tableView.contentInset = UIEdgeInsetsMake(66, 0, 20, 0);
}

- (void)updateFrameForNewOrder {
    [self setDayLeft:_transaction.order_payment.payment_process_day_left];
    
    if ([_transaction.order_detail.detail_dropship_name isEqualToString:@"0"]) {
        
        // Hide dropship view if dropship not available
        _dropshipView.hidden = YES;
        _dropshipViewHeightConstraint.constant = 0;
        
        // Update table content inset after hide dropship
        _tableView.contentInset = UIEdgeInsetsMake(66, 0, -_dropshipView.frame.size.height + 44, 0);
        
        // Update table height
        CGRect frame = _orderFooterView.frame;
        frame.size.height -= (_dropshipView.frame.size.height - 15);
        _orderFooterView.frame = frame;
        
    } else  {
        [self setDropshipData];
    }
}

- (void)updateFrameForShipmentConfirmation {
    [self setDayLeft:_transaction.order_deadline.deadline_shipping_day_left];
    
    [_rejectButton setTitle:@"Batal" forState:UIControlStateNormal];

    if (_transaction.order_shipment.shipment_id == 10) {
        [_acceptButton setTitle:@"Pickup" forState:UIControlStateNormal];
    } else {
        [_acceptButton setTitle:@"Konfirmasi" forState:UIControlStateNormal];
    }
    
    if (_transaction.order_deadline.deadline_shipping_day_left < 0) {
        _acceptButton.enabled = NO;
        _acceptButton.layer.opacity = 0.25;
    }
    
    if ([_transaction.order_detail.detail_dropship_name isEqualToString:@"0"]) {
        
        // Hide dropship view if dropship not available
        _dropshipView.hidden = YES;
        _dropshipViewHeightConstraint.constant = 0;
        
        // Add detail transaction view
        [self addTransactionDetailView];
        
        // Update table height
        CGRect frame = _orderFooterView.frame;
        frame.size.height -= _dropshipView.frame.size.height;
        _orderFooterView.frame = frame;
        
        // Update transaction view position
        frame = _detailTransactionView.frame;
        frame.origin.y = _orderFooterView.frame.size.height;
        _detailTransactionView.frame = frame;
        
        // Update table content inset after hide dropship
        CGFloat bottom = -_dropshipView.frame.size.height + _detailTransactionView.frame.size.height;
        _tableView.contentInset = UIEdgeInsetsMake(66, 0, bottom, 0);
        
    } else {
        
        [self setDropshipData];
        
        // Add detail transaction view
        [self addTransactionDetailView];
        
        // Update transaction view position
        CGRect frame = _detailTransactionView.frame;
        frame.origin.y = _orderFooterView.frame.size.height;
        _detailTransactionView.frame = frame;
        
        _tableView.contentInset = UIEdgeInsetsMake(66, 0, _detailTransactionView.frame.size.height, 0);
    }
}

- (void)addTransactionDetailView {
    // Add detail transaction view
    [_orderFooterView addSubview:_detailTransactionView];
    _transactionDateLabel.text = _transaction.order_detail.detail_order_date;
    _transactionDueDateLabel.text = _transaction.order_payment.payment_shipping_due_date;
}

- (void)updateFrameForShipmentStatus {
    _topButtonsView.hidden = YES;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    _dayLeftLabel.hidden = YES;
    _automaticallyRejectedLabel.hidden = YES;
    
    if ([_transaction.order_detail.detail_dropship_name isEqualToString:@"0"]) {
        
        // Hide dropship view if dropship not available
        _dropshipView.hidden = YES;
        _dropshipViewHeightConstraint.constant = 0;
        
        // Update table content inset after hide dropship
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, -_dropshipView.frame.size.height, 0);
        
        // Update table height
        CGRect frame = _orderFooterView.frame;
        frame.size.height -= (_dropshipView.frame.size.height - 15);
        _orderFooterView.frame = frame;
        
    } else {
        [self setDropshipData];
        _tableView.contentInset = UIEdgeInsetsZero;
    }
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
        OrderProduct *product = [_transaction.order_products objectAtIndex:indexPath.section];
        if ([product.product_notes isEqualToString:@"0"]) {
            return 80;
        } else {
            CGSize messageSize = [OrderDetailProductInformationCell messageSize:product.product_notes];
            return messageSize.height + [OrderDetailProductInformationCell textMarginVertical];
        }
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
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:13],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                     };
        
        cell.productNameLabel.attributedText = [[NSAttributedString alloc] initWithString:product.product_name
                                                                               attributes:attributes];
        [cell.productNameLabel sizeToFit];
        
        cell.productPriceLabel.text = product.product_price;
        cell.productWeightLabel.hidden = YES;
        
        cell.productTotalWeightLabel.text = [NSString stringWithFormat:@"%@ Barang (%.3f kg)",
                                             [NSNumber numberWithInteger:product.product_quantity],
                                             [product.product_weight floatValue]];
        
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
            cell.productInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:@"-"
                                                                                          attributes:_textAttributes];
        } else {
            cell.productInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:product.product_notes
                                                                                          attributes:_textAttributes];
        }
        [cell.productInformationLabel sizeToFit];
        
        return cell;
        
    }
}

#pragma mark - Table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderProduct *product = [_transaction.order_products objectAtIndex:indexPath.section];
    
    [[NavigateViewController new] navigateToProductFromViewController:self
                                                             withName:product.product_name
                                                            withPrice:product.product_price
                                                               withId:product.product_id
                                                         withImageurl:nil
                                                         withShopName:nil];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return NO;
    }
    return YES;
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


#pragma mark - Action

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if ([_delegate isKindOfClass:[SalesNewOrderViewController class]]) {
            [self newOrderActionButton:button];
        } else if ([_delegate isKindOfClass:[ShipmentConfirmationViewController class]]) {
            [self shipmentConfirmationActionButton:button];
        }
    } else if ([[sender view] isKindOfClass:[UILabel class]]) {
        
        NSURL *desktopURL = [NSURL URLWithString:_transaction.order_detail.detail_pdf_uri];
        
        NSString *pdf = [[[[[desktopURL query] componentsSeparatedByString:@"&"] objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
        NSString *invoiceID = [[[[[desktopURL query] componentsSeparatedByString:@"&"] objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
        
        UserAuthentificationManager *authManager = [UserAuthentificationManager new];
        NSString *userID = authManager.getUserId;
        
        NSString *url = [NSString stringWithFormat:@"%@/invoice.pl?invoice_pdf=%@&id=%@&user_id=%@",
                         kTkpdBaseURLString, pdf, invoiceID, userID];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:[self.view bounds]];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        webView.scalesPageToFit = YES;
        UIViewController *controller = [UIViewController new];
        controller.title = _transaction.order_detail.detail_invoice;
        [controller.view addSubview:webView];
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([[sender view] isKindOfClass:[UIView class]]) {
        NavigateViewController *controller = [NavigateViewController new];
        [controller navigateToProfileFromViewController:self withUserID:_transaction.order_customer.customer_id];
    }
}

- (void)shipmentConfirmationActionButton:(UIButton *)button
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (button.tag == 1) {
        
        CancelShipmentViewController *controller = [CancelShipmentViewController new];
        controller.delegate = self;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
    } else if (button.tag == 2) {
        
        SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
        controller.delegate = self;
        controller.shipmentCouriers = _shipmentCouriers;
        controller.order = _transaction;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
    }
}

- (void)newOrderActionButton:(UIButton *)button
{
    if (button.tag == 1) {
        if (_transaction.order_detail.detail_partial_order == 1) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tolak Pesanan"
                                                                message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Tolak Pesanan", @"Terima Sebagian", nil];
            alertView.tag = 1;
            [alertView show];
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pilih Alasan Penolakan"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Pesanan barang habis", @"Barang tidak dapat dikirim", @"Lainnya", nil];
            alertView.tag = 3;
            [alertView show];
            
        }
    } else if (button.tag == 2) {
        if (_transaction.order_payment.payment_process_day_left >= 0) {
            if (_transaction.order_detail.detail_partial_order == 1) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terima Pesanan"
                                                                    message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Batal"
                                                          otherButtonTitles:@"Terima Pesanan", @"Terima Sebagian", nil];
                alertView.tag = 2;
                [alertView show];
                
            } else {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Terima Pesanan"
                                                                    message:@"Apakah Anda yakin ingin menerima pesanan ini?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Batal"
                                                          otherButtonTitles:@"Ya", nil];
                alertView.tag = 4;
                [alertView show];
                
            }
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pesanan Expired"
                                                                message:@"Pesanan ini telah melewati batas waktu respon (3 hari)"
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Tolak Pesanan", nil];
            alertView.tag = 5;
            [alertView show];
            
        }
    }
}

- (IBAction)tapInfoAddFee:(id)sender {
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Biaya Tambahan";
    alertInfo.detailText = @"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman";
    [alertInfo show];
}

- (IBAction)tapGetCode:(id)sender {
    _courierAgentLabel.text = [[NSString stringWithFormat:@"%@ (%@)",
                                         _transaction.order_shipment.shipment_name,
                                         _transaction.order_shipment.shipment_product] stringByAppendingString:@" - Loading..."];
    [_getCodeButton setHidden:YES];
    _getCodeButton.enabled = NO;
    [_networkManager doRequest];
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        if (buttonIndex == 1) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Pilih Alasan Penolakan"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Batal"
                                                      otherButtonTitles:@"Pesanan barang habis", @"Barang tidak dapat dikirim", @"Lainnya", nil];
            alertView.tag = 3;
            [alertView show];
            
        } else if (buttonIndex == 2) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
            controller.products = _transaction.order_products;
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
        
    } else if (alertView.tag == 2) {
        
        if (buttonIndex == 1) {
            
            [self.delegate didReceiveActionType:@"accept"
                                         reason:nil
                                       products:nil
                                productQuantity:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if (buttonIndex == 2) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
            controller.products = _transaction.order_products;
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
        
    } else if (alertView.tag == 3) {
        
        if (buttonIndex == 1) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.translucent = NO;
            ChooseProductViewController *controller = [[ChooseProductViewController alloc] init];
            controller.delegate = self;
            controller.products = _transaction.order_products;
            navigationController.viewControllers = @[controller];
            
            [self.navigationController presentViewController:navigationController
                                                    animated:YES
                                                  completion:nil];
            
        } else if (buttonIndex == 2) {
            
            [self.delegate didReceiveActionType:@"reject"
                                         reason:@"Barang tidak dapat dikirim"
                                       products:_transaction.order_products
                                productQuantity:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if (buttonIndex == 3) {
            
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.translucent = NO;
            OrderRejectExplanationViewController *controller = [[OrderRejectExplanationViewController alloc] init];
            controller.delegate = self;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController
                                                    animated:YES
                                                  completion:nil];
            
        }
    } else if (alertView.tag == 4) {
        if (buttonIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(didReceiveActionType:reason:products:productQuantity:)]) {
                [self.delegate didReceiveActionType:@"accept"
                                             reason:nil
                                           products:nil
                                    productQuantity:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else if (alertView.tag == 5) {
        if (buttonIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(didReceiveActionType:reason:products:productQuantity:)]) {
                [self.delegate didReceiveActionType:@"reject"
                                             reason:@"Order expired"
                                           products:nil
                                    productQuantity:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - Choose product delegate

- (void)didSelectProducts:(NSArray *)products
{
    [self.delegate didReceiveActionType:@"reject"
                                 reason:@"Persediaan barang habis"
                               products:products
                        productQuantity:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Reject explanation delegate

- (void)didFinishWritingExplanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:@"reject"
                                 reason:explanation
                               products:nil
                        productQuantity:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Product quantity delegate

- (void)didUpdateProductQuantity:(NSArray *)productQuantity explanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:@"partial"
                                 reason:explanation
                               products:nil
                        productQuantity:productQuantity];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Cancel shipment delegate

- (void)cancelShipmentWithExplanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:@"reject"
                                courier:nil
                         courierPackage:nil
                          receiptNumber:nil
                        rejectionReason:explanation];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Confirm shipment delegate

- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage
{
    [self.delegate didReceiveActionType:@"confirm"
                                courier:courier
                         courierPackage:courierPackage
                          receiptNumber:receiptNumber
                        rejectionReason:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other methods

- (void)setDayLeft:(NSInteger)dayLeft
{
    if (dayLeft == 1) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                        green:145.0/255.0
                                                         blue:0.0/255.0
                                                        alpha:1];
        _dayLeftLabel.text = @"Besok";
        
    } else if (dayLeft == 0) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                        green:59.0/255.0
                                                         blue:48.0/255.0
                                                        alpha:1];
        _dayLeftLabel.text = @"Hari ini";
        
    } else if (dayLeft < 0) {
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:158.0/255.0
                                                        green:158.0/255.0
                                                         blue:158.0/255.0
                                                        alpha:1];
        _dayLeftLabel.text = @"Expired";
        
        _automaticallyRejectedLabel.hidden = YES;
        
    } else {
        
        _dayLeftLabel.text = [NSString stringWithFormat:@"%d Hari lagi", (int)dayLeft];
        
        _dayLeftLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0
                                                        green:121.0/255.0
                                                         blue:255.0/255.0
                                                        alpha:1];
    }
}

- (void)successConfirmOrder:(OrderTransaction *)order
{
    [self.navigationController popViewControllerAnimated:NO];
    if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
        [self.delegate successConfirmOrder:_transaction];
    }
}



#pragma mark - LabelMenu Delegate
- (void)duplicate:(int)tag
{
    if(tag == CTagAddress) {
        [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@ %@ %@", _addressLabel.text, _cityLabel.text, _countryLabel.text];
    }
    else if(tag == CTagPhone) {
        [UIPasteboard generalPasteboard].string = _phoneNumberLabel.text;
    }
}

#pragma mark - Tokopedia Network Delegate

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = [[NSDictionary alloc]
                               initWithObjectsAndKeys:_booking.shop_id, @"shopid",
                               _booking.type, @"type",
                               _booking.token, @"token",
                               _booking.ut, @"ut",
                               _transaction.order_detail.detail_order_id, @"orders",
                               nil];
    return parameter;
}

- (NSString *)getPath:(int)tag {
    NSURL *url = [NSURL URLWithString:_booking.api_url];
    NSString *urlPathComponents = [NSString stringWithFormat:@"%@/%@",
                         url.pathComponents[1],
                         url.pathComponents[2]];
    
    return urlPathComponents;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    OrderBookingResponse *list = stat;
    
    return list.status;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    NSURL *url = [NSURL URLWithString:_booking.api_url];
    NSString *urlHost = [NSString stringWithFormat:@"%@://%@/",
                         url.scheme,
                         url.host];
    
    _objectManager = [RKObjectManager sharedClient:urlHost];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[OrderBookingResponse class]];
    [statusMapping addAttributeMappingsFromDictionary:@{@"Status":@"status"}];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[OrderBookingData class]];
    
    [dataMapping addAttributeMappingsFromDictionary:@{@"id":@"booking_id",
                                                      @"type":@"type",
                                                      @"status":@"status",
                                                      @"order_id":@"order_id",
                                                      @"tiket_code":@"tiket_code"}];
    
    RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
    [statusMapping addPropertyMapping:dataRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:OrderDetailTag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectManager;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    OrderBookingResponse *response = [result objectForKey:@""];
    
    NSMutableAttributedString *kurir = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)",
                                                                                          _transaction.order_shipment.shipment_name,
                                                                                          _transaction.order_shipment.shipment_product]];
    NSString *code = ((OrderBookingData*)response.data[0]).tiket_code;
    
    NSAttributedString *text;
    
    _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGetCode:)];
    _singleTapGestureRecognizer.numberOfTapsRequired = 1;
    
    if([code isEqualToString:@"try again"]) {
        text = [[NSAttributedString alloc] initWithString:code attributes:@{
                                                                            NSForegroundColorAttributeName:[UIColor colorWithRed:(62.0/255.0) green:(170.0/255.0) blue:(36.0/255.0) alpha:(255.0/255.0)],
                                                                            NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0]
                                                                            }];
        [_getCodeButton setImage:[UIImage imageNamed:@"icon_pesan_ulang.png"] forState:UIControlStateNormal];
        [_getCodeButton setHidden:NO];
        _getCodeButton.enabled = YES;
        
        [_courierAgentLabel addGestureRecognizer:_singleTapGestureRecognizer];
        [_courierAgentLabel setUserInteractionEnabled:YES];
        _singleTapGestureRecognizer.cancelsTouchesInView = NO;
        _singleTapGestureRecognizer.enabled = YES;
    } else {
        text = [[NSAttributedString alloc] initWithString:code attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        [_getCodeButton setHidden:YES];
        _getCodeButton.enabled = NO;
        
        [_courierAgentLabel removeGestureRecognizer:_singleTapGestureRecognizer];
        [_courierAgentLabel setUserInteractionEnabled:NO];
        _singleTapGestureRecognizer.enabled = NO;
        [_singleTapGestureRecognizer removeTarget:self action:@selector(tapGetCode:)];
    }
    
    NSAttributedString *dash = [[NSAttributedString alloc] initWithString:@" - "];
    
    [kurir appendAttributedString:dash];
    [kurir appendAttributedString:text];
    
    _courierAgentLabel.attributedText = kurir;
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

@end
