//
//  ReactOrderManager.m
//  Tokopedia
//
//  Created by Dhio Etanasti on 11/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactOrderManager.h"
#import <Foundation/Foundation.h>
#import "Tokopedia-Swift.h"
#import "AnalyticsManager.h"
#import "RejectReasonViewController.h"
#import "SubmitShipmentConfirmationViewController.h"
#import "ChangeReceiptNumberViewController.h"
#import "TrackOrderViewController.h"
#import "ProductQuantityViewController.h"

@implementation ReactOrderManager

OrderTransaction* currentOrder;
NSArray *currentShipmentCouriers;

+(void)setCurrentOrder:(OrderTransaction*)order {
    currentOrder = order;
}

+(void)setCurrentShipmentCouriers:(NSArray*)shipmentCouriers {
    currentShipmentCouriers = shipmentCouriers;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

// PEMBELIAN DI SKIP
//"ask_seller": 0, // SKIP
//"request_cancel": 0, // SKIP
//"receive_confirmation": 0, // SKIP
//"finish_order": 0, // SKIP
//"complaint": 0, // SKIP
//"cancel_peluang": 0, // SKIP
//"order_detail": 0, // SKIP

RCT_EXPORT_METHOD(seeInvoice:(NSString*)invoiceURL) {
    [AnalyticsManager trackEventName:@"clickNewOrder" category:GA_EVENT_CATEGORY_SHIPPING action:GA_EVENT_ACTION_VIEW label:@"Invoice"];
    UIViewController *topViewController = [UIApplication topViewController];
    [NavigateViewController navigateToInvoiceFromViewController:topViewController withInvoiceURL:invoiceURL];
}

//"ask_buyer"
RCT_EXPORT_METHOD(askBuyer) {
    SendChatViewController *vc = [[SendChatViewController alloc] initWithUserID:currentOrder.order_customer.customer_id shopID:nil name:currentOrder.order_customer.customer_name imageURL:currentOrder.order_customer.customer_image invoiceURL:currentOrder.order_detail.detail_pdf_uri productURL:nil source:@"tx_ask_buyer"];
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController pushViewController:vc animated:YES];
}

// additional helper
-(void)showAlertViewAcceptPartialConfirmation{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Terima Pesanan"
                                                                   message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* rejectAction = [UIAlertAction actionWithTitle:@"Terima Pesanan" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self requestAcceptOrder];
                                                         }];
    UIAlertAction* acceptPartialAction = [UIAlertAction actionWithTitle:@"Terima Sebagian" style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    [self showAcceptPartialProductChooser];
                                                                }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:rejectAction];
    [alert addAction:acceptPartialAction];
    [alert addAction:cancelAction];
    
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController presentViewController:alert animated:YES completion:nil];
}

-(void)showAlertViewRejectPartialConfirmation{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Tolak Pesanan"
                                                                   message:@"Pembeli menyetujui apabila stok barang yang tersedia hanya sebagian"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* rejectAction = [UIAlertAction actionWithTitle:@"Tolak Pesanan" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self showRejectReason];
                                                          }];
    UIAlertAction* acceptPartialAction = [UIAlertAction actionWithTitle:@"Terima Sebagian" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self showAcceptPartialProductChooser];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:rejectAction];
    [alert addAction:acceptPartialAction];
    [alert addAction:cancelAction];
    
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController presentViewController:alert animated:YES completion:nil];
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
    vc.order = currentOrder;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)showAcceptPartialProductChooser{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
    ProductQuantityViewController *controller = [[ProductQuantityViewController alloc] init];
    controller.products = currentOrder.order_products;
    controller.orderID = currentOrder.order_detail.detail_order_id;
    controller.shippingLeft = currentOrder.order_last.last_est_shipping_left;
    
    controller.didAcceptOrder = ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNewOrderList" object:nil];
        ReactEventManager *eventManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
        [eventManager popNavigation];
    };
    
    navigationController.viewControllers = @[controller];
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)requestAcceptOrder{
    
    [RequestSales fetchAcceptOrder :currentOrder.order_detail.detail_order_id
                       shippingLeft:currentOrder.order_last.last_est_shipping_left
                          onSuccess:^() {
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNewOrderList" object:nil];
                              ReactEventManager *eventManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
                              [eventManager popNavigation];
                              
                          } onFailure:^() {
                              
                          }];
}

//"accept_order"
RCT_EXPORT_METHOD(acceptOrder) {
    if (currentOrder.order_detail.detail_partial_order == 1) {
        [self showAlertViewAcceptPartialConfirmation];
    } else {
        [self showAlertViewAcceptConfirmation];
    }
}

//"reject_order new order"
RCT_EXPORT_METHOD(rejectNewOrder) {
    if (currentOrder.order_detail.detail_partial_order == 1) {
        [self showAlertViewRejectPartialConfirmation];
    } else {
        [self showRejectReason];
        
    }
}

//"reject_order"
RCT_EXPORT_METHOD(rejectOrder) {
    CancelOrderShipmentViewController *controller = [[CancelOrderShipmentViewController alloc] initWithOrderTransaction:currentOrder];
    
    controller.onFinishRequestCancel = ^(BOOL isSuccess) {
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDataOnShipmentConfirmation" object:nil];
        }
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

//"confirm_shipping" & "request_pickup"
RCT_EXPORT_METHOD(confirmShipping) {
    SubmitShipmentConfirmationViewController *controller = [SubmitShipmentConfirmationViewController new];
    controller.shipmentCouriers = currentShipmentCouriers;
    controller.order = currentOrder;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

//"change_awb"
RCT_EXPORT_METHOD(changeAWB:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    
    ChangeReceiptNumberViewController *controller = [ChangeReceiptNumberViewController new];
    controller.receiptNumber = currentOrder.order_detail.detail_ship_ref_num;
    controller.orderID = currentOrder.order_detail.detail_order_id;
    navigationController.viewControllers = @[controller];
    
    controller.didSuccessEditReceipt = ^(NSString *newReceipt){
        [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_TRACKING action:GA_EVENT_ACTION_EDIT label:@"Receipt Number"];
        currentOrder.order_detail.detail_ship_ref_num = newReceipt;
        [ReactOrderManager setCurrentOrder:currentOrder];
        resolve(@"");
    };
    
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

//"track"
RCT_EXPORT_METHOD(trackOrder) {
    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_ORDER_STATUS action:GA_EVENT_ACTION_CLICK label:@"Track"];
    
    TrackOrderViewController *controller = [TrackOrderViewController new];
    controller.order = currentOrder;
    controller.hidesBottomBarWhenPushed = YES;
    
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController pushViewController:controller animated:YES];
}

//"view_complaint"
RCT_EXPORT_METHOD(seeComplaint:(NSString*)resoId) {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *urlString = [auth webViewUrlFromUrl: [NSString stringWithFormat:@"%@/resolution/%@/mobile",[NSString mobileSiteUrl], resoId]];
    
    WKWebViewController *vc = [[WKWebViewController alloc] initWithUrlString: urlString];
    UIViewController *topViewController = [UIApplication topViewController];
    [topViewController.navigationController pushViewController:vc animated:YES];
}

//"change_courier" -> hide dulu

@end
