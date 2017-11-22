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
#import "ProductQuantityViewController.h"
#import "OrderRejectExplanationViewController.h"
#import "ShipmentConfirmationViewController.h"
#import "DetailShipmentStatusViewController.h"
#import "SalesNewOrderViewController.h"
#import "ShipmentStatusViewController.h"
#import "CancelShipmentViewController.h"
#import "SubmitShipmentConfirmationViewController.h"
#import "NavigateViewController.h"
#import "AlertInfoView.h"
#import "OrderBookingData.h"
#import "OrderBookingResponse.h"
#import "AlertShipmentCodeView.h"
#import "RejectReasonViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "UIAlertView+BlocksKit.h"
#import "Tokopedia-Swift.h"

#import "SendMessageViewController.h"

@interface OrderDetailViewController ()
<
    SubmitShipmentConfirmationDelegate,
    CancelShipmentConfirmationDelegate
>

@property (strong, nonatomic) AlertShipmentCodeView *alert;
@property (strong, nonatomic) IBOutlet UIView *retryView;

@end

@implementation OrderDetailViewController{
    OAStackView *_stackView;
    OrderButtonView *_buttonView;
    UIScrollView *_scrollView;
    OrderDetailReceiverView *_receiverView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"Detail Transaksi";
    
    [self request];
    [self initStackView];
    [self hideRetry];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyRejectOperation) name:@"applyRejectOperation" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Order Detail Page"];
}

-(void)applyRejectOperation{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Methods
- (void)setBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)request {
    if (_shouldRequestIDropCode) {
        [self requestIDropCode];
    }
}

-(void)initStackView{
    
    //button need to be sticky
    _buttonView = [[OrderButtonView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,40)];
    _buttonView.backgroundColor = [UIColor whiteColor];
    [_buttonView setClipsToBounds:YES];
    [self addButtonView:_buttonView];

    _scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([self showTopButtonView]) {
            make.top.equalTo(_buttonView.mas_bottom);
        } else {
            make.top.equalTo(self.view);
        }
        make.bottom.left.right.equalTo(self.view);
    }];
    
    _stackView = [OAStackView new];
    _stackView.axis = MASAxisTypeVertical;
    _stackView.alignment = OAStackViewAlignmentFill;
    _stackView.distribution = OAStackViewDistributionFill;
    
    [_scrollView addSubview:_stackView];
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(_scrollView);
        make.width.equalTo(self.view);
    }];
    
    [self addOrderInfoView];
    [self addBuyerView];
    [self addProductView];
    [self addPickupView];
    [self addReceiverDetailView];
    [self addDropshipView];
    [self addTotalOrderView];
    [self addOrderDateView];
    [self.view bringSubviewToFront:_retryView];
}

-(void)addOrderDateView{
    if (!self.isDetailShipmentConfirmation) {
        return;
    }
    
    OrderDateView *dateView = [OrderDateView newView];
    [dateView setOrder:_transaction];
    [_stackView addArrangedSubview:dateView];
    
    [dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@188);
    }];
}

-(void)addTotalOrderView{
    OrderTotalView *totalView = [OrderTotalView newView:_transaction];
    [_stackView addArrangedSubview:totalView];
    
    [totalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@216);
    }];
    
    __weak typeof(self) wself = self;
    totalView.onTapInfoButton = ^{
        [wself showAdditionalFeeInfo];
    };
}

-(void)showAdditionalFeeInfo{
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info Biaya Tambahan";
    alertInfo.detailText = @"Biaya tambahan termasuk biaya asuransi dan biaya administrasi pengiriman";
    [alertInfo show];
}

-(void)addDropshipView{
    if (![self showDropshipView]) {
        return;
    }

    OrderDetailDropshipView *dropshipView = [OrderDetailDropshipView newView:_transaction];
    [_stackView addArrangedSubview:dropshipView];
    
    [dropshipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@165);
    }];
}

-(void)addPickupView{
    if (![self showPickupView]) {
        return;
    }
    
    PickupAddressView *pickUpView = [PickupAddressView  newView:_transaction.order_shop.address_street];
    [_stackView addArrangedSubview:pickUpView];
    
    [pickUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@130);
    }];
}

-(void)addReceiverDetailView{
    _receiverView = [OrderDetailReceiverView newView:_transaction];
    [_stackView addArrangedSubview:_receiverView];
    [_receiverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(@365);
    }];
    
    __weak typeof(self) wself = self;
    _receiverView.onTapGetIDropCode = ^{
        [wself request];
    };
}

-(IDropCodeRequestObject*)requestObject{
    IDropCodeRequestObject *object = [IDropCodeRequestObject new];
    object.shopID = _booking.shop_id;
    object.bookingType = _booking.type;
    object.bookingUT = _booking.ut;
    object.bookingToken = _booking.token;
    object.orderID = _transaction.order_detail.detail_order_id;
    return object;
}

-(void)requestIDropCode{

    [SalesOrderRequest fetchIDropCode:_booking.api_url
                        objectRequest:[self requestObject]
                            onSuccess:^(OrderBookingData * data)
    {
        NSString *code = data.tiket_code;
        if (![code isEqualToString:@"try again"]) {
            _alert = [AlertShipmentCodeView newview];
            [_alert setText:code];
            [_alert show];
        }

        [_receiverView setIDropCode:code];
        
    }];
}

-(void)addProductView{
    for (OrderProduct *product in _transaction.order_products) {
        OrderProductView *productView = [OrderProductView newView:product];
        [_stackView addArrangedSubview:productView];
        [productView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.greaterThanOrEqualTo(@213);
        }];
        
        __weak typeof(self) weakSelf = self;
        productView.didTapProduct = ^{
            
            [NavigateViewController navigateToProductFromViewController:weakSelf
                                                          withProductID:product.product_id
                                                                andName:product.product_name
                                                               andPrice:product.product_price
                                                            andImageURL:product.product_picture
                                                            andShopName:nil];
        };
    }
}

-(void)addBuyerView{
    OrderBuyerView *buyerView = [OrderBuyerView newView:_transaction showDaysLeft:self.isDetailNewOrder];
    [_stackView addArrangedSubview:buyerView];
    
    __weak typeof(self) weakSelf = self;
    
    buyerView.didTapInvoice = ^(OrderTransaction *order){
        [AnalyticsManager trackEventName:@"clickNewOrder" category:GA_EVENT_CATEGORY_SHIPPING action:GA_EVENT_ACTION_VIEW label:@"Invoice"];
        [NavigateViewController navigateToInvoiceFromViewController:weakSelf withInvoiceURL:weakSelf.transaction.order_detail.detail_pdf_uri];
    };
    
    buyerView.didTapBuyer = ^(OrderTransaction *order){
        NavigateViewController *controller = [NavigateViewController new];
        [controller navigateToProfileFromViewController:weakSelf withUserID:weakSelf.transaction.order_customer.customer_id];
    };
    
    [buyerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@133);
    }];
}

-(void)addOrderInfoView{
    if (![self showInfoView]){
        return;
    }
    
    OrderInfoView *infoView = [OrderInfoView newView:_transaction.order_detail.detail_cancel_request.reasonFormattedString];
    [_stackView addArrangedSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@60);
    }];
}

-(void)addButtonView:(OrderButtonView*)buttonView{
    if (![self showTopButtonView]) {
        return;
    }
    
    [self.view addSubview:buttonView];
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.greaterThanOrEqualTo(@44);
    }];
    
    __weak typeof(self) wself = self;
    if (self.isDetailNewOrder) {
        [buttonView addRejectButton:^{
            if ([wself isBuyerAcceptPartial]) {
                [wself showAlertViewRejectPartialConfirmation];
            } else {
                [wself showRejectReason];
                
            }
        }];
        
        [buttonView addAskBuyerButton:^{
            [wself doAskBuyer];
        }];
        
        [buttonView addAcceptButton:^{
            if ([wself isOrderNotExpired]) {
                if ([wself isBuyerAcceptPartial]) {
                    [wself showAlertViewAcceptPartialConfirmation];
                } else {
                    [wself showAlertViewAcceptConfirmation];
                }
            } else {
                [wself showAlertViewAcceptExpiredConfirmation];
            }
        }];
    }
    
    if (self.isDetailShipmentConfirmation) {
        
        __weak typeof(self) weakSelf = self;
        [buttonView addCancelButton:^{
        	
        	CancelOrderShipmentViewController *controller = [[CancelOrderShipmentViewController alloc] initWithOrderTransaction:_transaction];
            
        	controller.onFinishRequestCancel = ^(BOOL isSuccess) {
        	    if (isSuccess) {
        	        [weakSelf.delegate refreshData];
        	        [weakSelf.navigationController popViewControllerAnimated:YES];
        	    }
        	};
        	
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        	[weakSelf.navigationController presentViewController:navigationController animated:YES completion:nil];
        

        }];
        
        [buttonView addAskBuyerButton:^{
            [wself doAskBuyer];
        }];
        
        if (_transaction.order_is_pickup == 1) {
            [buttonView addPickupButton:^{
                SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
                controller.delegate = wself;
                controller.shipmentCouriers = _shipmentCouriers;
                controller.order = _transaction;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                [wself.navigationController presentViewController:navigationController animated:YES completion:nil];
            }];
            
        } else {
            [buttonView addConfirmButton:^{
                SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
                controller.delegate = wself;
                controller.shipmentCouriers = _shipmentCouriers;
                controller.order = _transaction;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                [wself.navigationController presentViewController:navigationController animated:YES completion:nil];
            }];
        }
    }
}

-(void)doAskBuyer{
    SendChatViewController *vc = [[SendChatViewController alloc] initWithUserID:_transaction.order_customer.customer_id shopID:nil name:_transaction.order_customer.customer_name imageURL:_transaction.order_customer.customer_image invoiceURL:_transaction.order_detail.detail_pdf_uri productURL:nil source:@"tx_ask_buyer"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)showInfoView{
    return ([_transaction.order_detail.detail_cancel_request.cancel_request isEqualToString:@"1"] && [self isDetailNewOrder]);
}

-(BOOL)showTopButtonView{
    return (self.isDetailNewOrder || self.isDetailShipmentConfirmation);
}

-(BOOL)showPickupView{
    return (_transaction.order_is_pickup == 1);
}

-(BOOL)showDropshipView{
    return (![_transaction.order_detail.detail_dropship_name isEqualToString:@"0"]);
}

#pragma mark - Method
- (IBAction)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UILabel *lbl = (UILabel *)sender.view;
        [lbl becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:lbl.frame inView:lbl.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}


-(void)showAlertViewAcceptExpiredConfirmation{
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Pesanan Expired" message:@"Pesanan ini telah melewati batas waktu respon (3 hari)"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    __weak typeof(self) wself = self;
    [alert bk_addButtonWithTitle:@"Tolak Pesanan" handler:^{
        [wself requestAcceptExpiredOrder];
    }];
    [alert show];
}

-(void)requestAcceptExpiredOrder{
    
    [RequestSales fetchAcceptExpiredOrder:_transaction.order_detail.detail_order_id
                             shippingLeft:_transaction.order_last.last_est_shipping_left
                                onSuccess:^{
                                    
                                    if(_didAcceptOrder){
                                        _didAcceptOrder();
                                    }
        
    } onFailure:^{
        
    }];
}

-(void)showAlertViewAcceptPartialConfirmation{
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Terima Pesanan" message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Terima Pesanan" handler:^{
        [self requestAcceptOrder];
    }];
    [alert bk_addButtonWithTitle:@"Terima Sebagian" handler:^{
        [self showAcceptPartialProductChooser];
    }];
    [alert show];
}

-(void)showAlertViewRejectPartialConfirmation{    
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Tolak Pesanan" message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    [alert bk_addButtonWithTitle:@"Tolak Pesanan" handler:^{
        [self showRejectReason];
    }];
    [alert bk_addButtonWithTitle:@"Terima Sebagian" handler:^{
        [self showAcceptPartialProductChooser];
    }];
    [alert show];
}

-(void)requestAcceptOrder{
    
    __weak typeof(self) wself = self;
    [RequestSales fetchAcceptOrder :_transaction.order_detail.detail_order_id
                       shippingLeft:_transaction.order_last.last_est_shipping_left
                          onSuccess:^() {
                              
                              if (_didAcceptOrder) {
                                  _didAcceptOrder();
                              }
                              
                              [wself hideButtonView];
                              
                          } onFailure:^() {
                              
                          }];
}

-(void)showAlertViewAcceptConfirmation{
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"Terima Pesanan" message:@"Apakah Anda yakin ingin menerima pesanan ini?"];
    [alert bk_setCancelButtonWithTitle:@"Batal" handler:^{
        //nope
    }];
    
    __weak typeof(self) wself = self;
    [alert bk_addButtonWithTitle:@"Ya" handler:^{
        [wself requestAcceptOrder];
    }];
    [alert show];
}

-(void)showRejectReason{
    RejectReasonViewController *vc = [RejectReasonViewController new];
    vc.order = _transaction;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)showAcceptPartialProductChooser{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
    ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
    controller.products = _transaction.order_products;
    controller.orderID = _transaction.order_detail.detail_order_id;
    controller.shippingLeft = _transaction.order_last.last_est_shipping_left;
    
    __weak typeof(self) wself = self;
    controller.didAcceptOrder = ^(){
        
        [wself hideButtonView];
        
        if(_didAcceptOrder){
            _didAcceptOrder();
        }
    };
    
    navigationController.viewControllers = @[controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)hideButtonView{
    [_scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.left.right.equalTo(self.view);
    }];
}

#pragma mark - Choose product delegate

- (void)didSelectProducts:(NSArray *)products
{
    [self.delegate didReceiveActionType:ProceedTypeReject
                                 reason:@"Persediaan barang habis"
                               products:products
                        productQuantity:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Reject explanation delegate

- (void)didFinishWritingExplanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:ProceedTypeReject
                                 reason:explanation
                               products:nil
                        productQuantity:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Product quantity delegate

- (void)didUpdateProductQuantity:(NSArray *)productQuantity explanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:ProceedTypePartial
                                 reason:explanation
                               products:nil
                        productQuantity:productQuantity];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Cancel shipment delegate

- (void)cancelShipmentWithExplanation:(NSString *)explanation
{
    [self.delegate didReceiveActionType:ProceedTypeReject
                                courier:nil
                         courierPackage:nil
                          receiptNumber:nil
                        rejectionReason:explanation];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Confirm shipment delegate

- (void)submitConfirmationReceiptNumber:(NSString *)receiptNumber courier:(ShipmentCourier *)courier courierPackage:(ShipmentCourierPackage *)courierPackage
{
    [self.delegate didReceiveActionType:ProceedTypeConfirm
                                courier:courier
                         courierPackage:courierPackage
                          receiptNumber:receiptNumber
                        rejectionReason:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Other methods

- (void)successConfirmOrder:(OrderTransaction *)order
{
    [self.navigationController popViewControllerAnimated:NO];
    if ([self.delegate respondsToSelector:@selector(successConfirmOrder:)]) {
        [self.delegate successConfirmOrder:_transaction];
    }
}

- (BOOL)isOrderNotExpired{
    return _transaction.order_payment.payment_process_day_left >= 0;
}

- (BOOL)isBuyerAcceptPartial{
    return _transaction.order_detail.detail_partial_order == 1;
}

- (IBAction)actionRetryPickup:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Konfirmasi Retry Pickup" message:@"Lakukan Retry Pickup?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [RetryPickupRequest retryPickupOrderWithOrderId:_transaction.order_detail.detail_order_id onSuccess:^(V4Response<GeneralActionResult *> * _Nonnull data) {
            [self didReceiveResult:data];
        } onFailure:^{
        
        }];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:actionCancel];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:true completion:nil];
    
    
}

-(void) hideRetry {
    if (_transaction.order_shipping_retry != 1) {
        _retryView.hidden = YES;
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, _retryView.frame.size.height, 0);
    }
}

- (void) popUpMessagesClose:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController;
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Tutup" style:UIAlertActionStyleCancel handler:nil];
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:true completion:nil];
}



- (void)didReceiveResult:(V4Response<GeneralActionResult*> *)result {
    if ([result.data.is_success isEqualToString:@"1"]) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:result.message_status delegate:self];
        [alert show];
        _transaction.order_shipping_retry = 0;
        [self hideRetry];
        
    } else {
        NSString *title = result.message_error[0];
        NSString *message = result.message_error[1];
        [self popUpMessagesClose:title message:message];
    }
    if (_onSuccessRetry) {
        _onSuccessRetry([result.data.is_success boolValue]);
    }
}

@end
