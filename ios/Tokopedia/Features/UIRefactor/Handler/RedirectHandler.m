//
//  RedirectHandler.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RedirectHandler.h"

#import "InboxTalkViewController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "SalesNewOrderViewController.h"
#import "TxOrderStatusViewController.h"

#import "NotificationState.h"

#import "NavigateViewController.h"
#import "SalesTransactionListViewController.h"
#import "ShipmentStatusViewController.h"

#import "Tokopedia-Swift.h"

@implementation RedirectHandler
{
    NavigateViewController *_navigate;
}

-(NavigateViewController*)navigate
{
    if (!_navigate) {
        _navigate = [NavigateViewController new];
    }
    
    return _navigate;
}

- (id)init {
    self = [super init];
    
    if(self != nil) {

    }
    
    return self;
}

- (void)proxyRequest:(int)state{
    if(state == STATE_NEW_MESSAGE) {
        [self redirectToMessage];
    } else if(state == STATE_NEW_TALK) {
        [self redirectToTalk];
    } else if(state == STATE_NEW_REPSYS ||
              state == STATE_NEW_REVIEW ||
              state == STATE_EDIT_REPSYS ||
              state == STATE_EDIT_REVIEW ||
              state == STATE_REPLY_REVIEW) {
        [self redirectToReview];
    } else if (state == STATE_EDIT_RESOLUTION ||
               state == STATE_RESCENTER_SELLER_REPLY ||
               state == STATE_RESCENTER_BUYER_REPLY ||
               state == STATE_RESCENTER_SELLER_AGREE ||
               state == STATE_RESCENTER_BUYER_AGREE  ||
               state == STATE_RESCENTER_ADMIN_SELLER_REPLY ||
               state == STATE_RESCENTER_ADMIN_BUYER_REPLY ) {
  	     [self redirectToResolution];
	} else if (state == STATE_PURCHASE_PROCESS_PARTIAL) {
        //TODO: KONFIRMASI ORDER PROCESSED
        [self redirectToProcessedOrder];
    }
    
    switch (state) {
        case StateOrderSellerNewOrder:
            [self redirectToNewOrder];
            break;
            
        case StateOrderSellerInvalidResi:
            [self redirectToShipmentStatus];
            break;
            
        case StateOrderSellerFinishOrder:
            [self redirectToTransactionListSeller];
            break;
            
        case StateOrderBuyerConfirmShipping:
            [self redirectToProcessedOrder];
            break;
            
        case StateOrderBuyerDelivered:
            [self redirectToConfirmPackageArrived];
            break;
            
        case StateOrderBuyerFinishOrder:
            [self redirectToTransactionListBuyer];
            break;
            
        case StateOrderSellerAutoCancel2D:
            [self redirectToTransactionListSeller];
            break;
            
        case StateOrderSellerAutoCancel4D:
            [self redirectToTransactionListSeller];
            break;
            
        case StateOrderSellerOrderDelivered:
            [self redirectToShipmentStatus];
            break;
            
        case StateOrderSellerReceivedComplain:
            [self redirectToBuyerComplaint];
            break;
            
        case StateOrderBuyerNewOrder:
            [self redirectToProcessedOrder];
            break;
            
        case StateOrderBuyerRejected:
            [self redirectToRejectedOrder];
            break;
            
        case StateOrderBuyerAutoCancel2D:
            [self redirectToTransactionListBuyer];
            break;
            
        case StateOrderBuyerAutoCancel4D:
            [self redirectToTransactionListBuyer];
            break;
            
        case StateOrderBuyerShippingRejected:
            [self redirectToRejectedOrder];
            break;
            
        case StateOrderBuyerReminderFinishOrder:
            [self redirectToConfirmPackageArrived];
            break;
            
        default:
            break;
    }
}

- (void)redirectToMessage {
    [TPRoutes routeURL:[NSURL URLWithString:@"tokopedia://topchat"]];
}

- (void)redirectToTalk {
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxTalkFromViewController:_navigationController];
}

- (void)redirectToReview {
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxReviewFromViewController:_navigationController];
}

-(void)redirectToResolution{
    _navigationController = (UINavigationController*)_delegate;    
    [[self navigate]navigateToInboxResolutionFromViewController:_navigationController];
}

-(void)redirectToBuyerComplaint{
    _navigationController = (UINavigationController*)_delegate;
    [[self navigate]navigateToInboxResolutionFromViewController:_navigationController atIndex:2];
}

- (void)redirectToNewOrder {
    UINavigationController *nav = (UINavigationController*)_delegate;
    _navigationController = (UINavigationController*)_delegate;
    
    SalesNewOrderViewController *controller = [[SalesNewOrderViewController alloc] init];
    if ([_navigationController conformsToProtocol:@protocol(NewOrderDelegate)]) {
        controller.delegate = (id <NewOrderDelegate>)_navigationController;
    }
    controller.hidesBottomBarWhenPushed = YES;
    
    [nav.navigationController pushViewController:controller animated:YES];
}

- (void)redirectToRejectedOrder {
    _navigationController = (UINavigationController*)_delegate;
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_list";
    controller.isCanceledPayment = YES;
    controller.viewControllerTitle = @"Pesanan Dibatalkan";
    [_navigationController.navigationController pushViewController:controller animated:YES];
}

- (void)redirectToProcessedOrder {
    _navigationController = (UINavigationController*)_delegate;
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_status";
    controller.viewControllerTitle = @"Status Pemesanan";
    [_navigationController.navigationController pushViewController:controller animated:YES];
}

- (void)redirectToConfirmPackageArrived {
    //TODO: KONFIRMASI TELAH DIKIRIM
    _navigationController = (UINavigationController*)_delegate;
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_deliver";
    controller.viewControllerTitle = @"Konfirmasi Penerimaan";
    [_navigationController.navigationController pushViewController:controller animated:YES];
}

- (void)redirectToTransactionListBuyer {
    _navigationController = (UINavigationController*)_delegate;
    TxOrderStatusViewController *controller =[TxOrderStatusViewController new];
    controller.action = @"get_tx_order_list";
    controller.viewControllerTitle = @"Daftar Transaksi";
    [_navigationController.navigationController pushViewController:controller animated:YES];
}

-(void)redirectToTransactionListSeller{
    SalesTransactionListViewController *controller = [SalesTransactionListViewController new];
    [[self navigationController].navigationController pushViewController:controller animated:YES];
}

-(void)redirectToShipmentStatus{
    ShipmentStatusViewController *controller = [ShipmentStatusViewController new];
    [[self navigationController].navigationController pushViewController:controller animated:YES];
}

-(UINavigationController *)navigationController{
    if (!_navigationController) {
        _navigationController = (UINavigationController*)_delegate;
    }
    return _navigationController;
}

@end
