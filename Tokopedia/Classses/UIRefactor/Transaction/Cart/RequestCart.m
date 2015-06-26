//
//  RequestCart.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCart.h"

#import "TransactionObjectManager.h"
#import "string_transaction.h"

@interface RequestCart()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManager;
    TokopediaNetworkManager *_networkManagerCancelCart;
    TokopediaNetworkManager *_networkManagerCheckout;
    TokopediaNetworkManager *_networkManagerBuy;
    TokopediaNetworkManager *_networkManagerVoucher;
    TokopediaNetworkManager *_networkManagerEditProduct;
    TokopediaNetworkManager *_networkManagerEMoney;
    TokopediaNetworkManager *_networkManagerBCAClickPay;
    
    TransactionObjectManager *_objectManager;
}

@end

@implementation RequestCart

-(TransactionObjectManager*)objectManager
{
    if (!_objectManager) {
        _objectManager = [TransactionObjectManager new];
    }
    
    return _objectManager;
}

-(TokopediaNetworkManager*)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.tagRequest = TAG_REQUEST_CART;
        _networkManager.delegate = self;
    }
    return _networkManager;
}

-(TokopediaNetworkManager*)networkManagerCancelCart
{
    if (!_networkManagerCancelCart) {
        _networkManagerCancelCart = [TokopediaNetworkManager new];
        _networkManagerCancelCart.tagRequest = TAG_REQUEST_CANCEL_CART;
        _networkManagerCancelCart.delegate = self;
    }
    return _networkManagerCancelCart;
}

-(TokopediaNetworkManager *)networkManagerCheckout
{
    if (!_networkManagerCheckout) {
        _networkManagerCheckout = [TokopediaNetworkManager new];
        _networkManagerCheckout.tagRequest = TAG_REQUEST_CHECKOUT;
        _networkManagerCheckout.delegate = self;
    }
    return _networkManagerCheckout;
}

-(TokopediaNetworkManager*)networkManagerBuy
{
    if (!_networkManagerBuy) {
        _networkManagerBuy = [TokopediaNetworkManager new];
        _networkManagerBuy.tagRequest = TAG_REQUEST_BUY;
        _networkManagerBuy.delegate = self;
    }
    return _networkManagerBuy;
}

-(TokopediaNetworkManager*)networkManagerVoucher
{
    if (!_networkManagerVoucher) {
        _networkManagerVoucher = [TokopediaNetworkManager new];
        _networkManagerVoucher.tagRequest = TAG_REQUEST_VOUCHER;
        _networkManagerVoucher.delegate = self;
    }
    return _networkManagerVoucher;
}

-(TokopediaNetworkManager*)networkManagerEditProduct
{
    if (!_networkManagerEditProduct) {
        _networkManagerEditProduct = [TokopediaNetworkManager new];
        _networkManagerEditProduct.tagRequest = TAG_REQUEST_EDIT_PRODUCT;
        _networkManagerEditProduct.delegate = self;
    }
    return _networkManagerEditProduct;
}

-(TokopediaNetworkManager*)networkManagerEMoney
{
    if (!_networkManagerEMoney) {
        _networkManagerEMoney = [TokopediaNetworkManager new];
        _networkManagerEMoney.tagRequest = TAG_REQUEST_EMONEY;
        _networkManagerEMoney.delegate = self;
    }
    return _networkManagerEMoney;
}

-(TokopediaNetworkManager*)networkManagerBCAClickPay
{
    if (!_networkManagerBCAClickPay) {
        _networkManagerBCAClickPay = [TokopediaNetworkManager new];
        _networkManagerBCAClickPay.tagRequest = TAG_REQUEST_BCA_CLICK_PAY;
        _networkManagerBCAClickPay.delegate = self;
    }
    
    return _networkManagerBCAClickPay;
}


#pragma mark - Network Manager Delegate
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        return [[self objectManager] objectManagerCart];
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        return [[self objectManager] objectManagerCancelCart];
    }
    if (tag == TAG_REQUEST_CHECKOUT) {
        return [[self objectManager] objectManagerCheckout];
    }
    if (tag == TAG_REQUEST_BUY) {
        return [[self objectManager] objectManagerBuy];
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        return  [[self objectManager] objectManagerVoucher];
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        return [[self objectManager] objectMangerEditProduct];
    }

    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        return @{};
    }
    return @{};
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        return API_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        return API_ACTION_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_CHECKOUT) {
        return API_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_BUY) {
        return API_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        return API_CHECK_VOUCHER_PATH;
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        return API_ACTION_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_EMONEY) {
        return API_EMONEY_PATH;
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        return API_BCA_KLICK_PAY_PATH;
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        if ([((UILabel*)_selectedPaymentMethodLabels[0]).text isEqualToString:@"Pilih"]) {
            [_dataInput setObject:@(-1) forKey:API_GATEWAY_LIST_ID_KEY];
        }
        
        if (![_refreshControl isRefreshing]) {
            _tableView.tableFooterView = _footerView;
            [_act startAnimating];
        }
        _isLoadingRequest = YES;
    }
    
    if (tag == TAG_REQUEST_CANCEL_CART) {
        
    }
    
    if (tag == TAG_REQUEST_CHECKOUT) {
        _checkoutButton.enabled = NO;
        [_alertLoading show];
    }
    
    if (tag == TAG_REQUEST_BUY) {
        _buyButton.enabled = NO;
        _buyButton.layer.opacity = 0.8;
        
        [_alertLoading show];
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
    }
    if (tag == TAG_REQUEST_EMONEY) {
        [_alertLoading show];
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        [_alertLoading show];
    }
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_CART) {
        TransactionCart *cart = stat;
        return cart.status;
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_CHECKOUT) {
        TransactionSummary *cart = stat;
        return cart.status;
    }
    if (tag == TAG_REQUEST_BUY) {
        TransactionBuy *cart = stat;
        return cart.status;
    }
    
    if (tag == TAG_REQUEST_VOUCHER) {
        TransactionVoucher *dataVoucher = stat;
        return dataVoucher.status;
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_EMONEY) {
        TxEmoney *emoney = stat;
        return emoney.status;
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        TransactionBuy *BCAClickPay = stat;
        return BCAClickPay.status;
    }
    return nil;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        [self requestSuccessCart:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        [self requestSuccessActionCancelCart:successResult withOperation:operation];
        [self endRefreshing];
    }
    if (tag == TAG_REQUEST_CHECKOUT) {
        [self requestSuccessActionCheckout:successResult withOperation:operation];
        _checkoutButton.enabled = YES;
        _tableView.tableFooterView = (_indexPage==1)?_buyView:_checkoutView;
        [_checkoutButton setTitle:@"Checkout" forState:UIControlStateNormal];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_BUY) {
        [self requestSuccessActionBuy:successResult withOperation:operation];
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        [self requestSuccessActionVoucher:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        [self requestSuccessActionEditProductCart:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_EMONEY) {
        [self requestSuccessEMoney:successResult withOperation:operation];
        [_act stopAnimating];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        [self requestSuccessBCAClickPay:successResult withOperation:operation];
        [_act stopAnimating];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)endRefreshing
{
    if (_refreshControl.isRefreshing) {
        [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [_refreshControl endRefreshing];
    }
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    //[self actionAfterFailRequestMaxTries:tag];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_CART) {
        [self endRefreshing];
        [_act stopAnimating];
        _isLoadingRequest = NO;
    }
    if (tag == TAG_REQUEST_CANCEL_CART) {
        [self endRefreshing];
    }
    
    if (tag == TAG_REQUEST_CHECKOUT) {
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_BUY) {
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        [_buyButton setTitle:@"BAYAR" forState:UIControlStateNormal];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_VOUCHER) {
        
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        
    }
    if (tag == TAG_REQUEST_EMONEY) {
        [_act stopAnimating];
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
        [_act stopAnimating];
    }
    [self endRefreshing];
}

#pragma mark - Request Cart



-(void)requestSuccessCart:(id)successResult withOperation:(RKObjectRequestOperation*)operation
{
    [self endRefreshing];
    [_act stopAnimating];
    _isLoadingRequest = NO;
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCart *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(cart.message_error)
        {
            NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            
            [_list removeAllObjects];
            
            NSArray *list = cart.result.list;
            [_list addObjectsFromArray:list];
            
            _cart = cart.result;
            [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL];
            
            [self adjustAfterUpdateList];
            
            NSDictionary *info = @{DATA_CART_DETAIL_LIST_KEY:_list.count > 0?_list[_indexSelectedShipment]:@{}};
            [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil userInfo:info];
        }
    }
}


-(void)adjustAfterUpdateList
{
    
    if (_list.count>0) {
        _isnodata = NO;
    }
    else
    {
        _isnodata = YES;
        _paymentMethodView.hidden = YES;
        _tableView.tableFooterView = nil;
    }
    [_delegate isNodata:_isnodata];
    
    
    NSInteger listCount = _list.count;
    
    if (!_refreshFromShipment) {
        [self resetAllArray];
    }
    [_listProductFirstObjectIndexPath removeAllObjects];
    
    for (int i = 0; i<listCount; i++) {
        TransactionCartList *list = _list[i];
        
        NSArray *products = list.cart_products;
        NSInteger productCount = products.count;
        
        NSIndexPath *firstProductIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        if (![list.cart_error_message_1 isEqualToString:@"0"]||![list.cart_error_message_2 isEqualToString:@"0"])
            firstProductIndexPath = [NSIndexPath indexPathForRow:1 inSection:i];
        [_listProductFirstObjectIndexPath addObject:firstProductIndexPath];
        
        if (!_refreshFromShipment) {
            [self addArrayObjectTemp];
        }
        
        if (productCount<=0) {
            [_isDropshipper removeObjectAtIndex:i];
            [_stockPartialStrList removeObjectAtIndex:i];
            [_senderNameDropshipper removeObjectAtIndex:i];
            [_senderPhoneDropshipper removeObjectAtIndex:i];
            [_dropshipStrList removeObjectAtIndex:i];
            [_stockPartialDetail removeObjectAtIndex:i];
            [_listProductFirstObjectIndexPath removeObjectAtIndex:i];
        }
        
    }
    if (listCount>0) {
        
        
        if (_indexPage == 0) {
            _paymentMethodView.hidden = NO;
            _paymentMethodSelectedView.hidden = YES;
            _checkoutView.hidden = NO;
            _tableView.tableFooterView = _checkoutView;
        }
        else if (_indexPage == 1) {
            _paymentMethodView.hidden = YES;
            _paymentMethodSelectedView.hidden = NO;
            _buyView.hidden = NO;
            _tableView.tableFooterView = _buyView;
        }
    }
    
    [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    if (_firstInit) _firstInit = NO;
    
    [self adjustDropshipperListParam];
    [self adjustPartialListParam];
    
    NSNumber *grandTotal = [_dataInput objectForKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    NSString *deposit = [_saldoTokopediaAmountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"," withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *voucher = [_dataInput objectForKey:DATA_VOUCHER_AMOUNT];
    
    NSInteger totalInteger = [grandTotal integerValue];
    totalInteger -= [voucher integerValue];
    if (totalInteger<0) {
        totalInteger = 0;
    }
    
    NSInteger grandTotalInteger = 0;
    NSInteger voucherAmount = [[_dataInput objectForKey:DATA_VOUCHER_AMOUNT]integerValue];
    NSInteger voucherUsedAmount = [[_dataInput objectForKey:DATA_CART_USED_VOUCHER_AMOUNT]integerValue];
    NSInteger grandTotalCartFromWS = [[_dataInput objectForKey:DATA_CART_GRAND_TOTAL] integerValue];
    
    if (grandTotalCartFromWS<voucherAmount) {
        voucherUsedAmount = grandTotalCartFromWS;
        if (voucherUsedAmount>voucherAmount) {
            voucherUsedAmount = voucherAmount;
        }
    }
    
    grandTotalInteger = totalInteger;
    
    
    
    [_dataInput setObject:@(grandTotalCartFromWS) forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
    
    [_dataInput setObject:@(voucherUsedAmount) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
    
    grandTotalInteger -= [deposit integerValue];
    if (grandTotalInteger <0) {
        grandTotalInteger = 0;
    }
    
    _cart.grand_total = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:grandTotalInteger]];
    
    _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:grandTotalInteger]] stringByAppendingString:@",-"];
    
    
    _refreshFromShipment = NO;
    
    [_tableView reloadData];
    
}


#pragma mark - Request Cancel Cart


-(void)requestSuccessActionCancelCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(action.message_error)
        {
            NSArray *errorMessages = action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            if (action.result.is_success == 1) {
                
                NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                [alert show];
                
                NSIndexPath *indexPathCancelProduct = [_dataInput objectForKey:DATA_INDEXPATH_SELECTED_PRODUCT_CART_KEY];
                TransactionCartList *list = _list[indexPathCancelProduct.section];
                
                NSInteger type = [[_dataInput objectForKey:DATA_CANCEL_TYPE_KEY]integerValue];
                NSMutableArray *products = [NSMutableArray new];
                [products addObjectsFromArray:list.cart_products];
                ProductDetail *product = products[indexPathCancelProduct.row];
                
                if (type == TYPE_CANCEL_CART_PRODUCT ) {
                    [products removeObject:product];
                    ((TransactionCartList*)[_list objectAtIndex:indexPathCancelProduct.section]).cart_products = products;
                    if (((TransactionCartList*)[_list objectAtIndex:indexPathCancelProduct.section]).cart_products.count<=0) {
                        [_list removeObject:_list[indexPathCancelProduct.section]];
                    }
                }
                else
                {
                    [_list removeObject:list];
                }
                
                
                [self adjustAfterUpdateList];
                
                [self refreshView:nil];
                
            }
        }
    }
}


#pragma mark - Request Checkout



-(void)requestSuccessActionCheckout:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionSummary *cart = stat;
    BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(cart.message_error)
        {
            NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            TransactionCartGateway *selectedGateway = [_dataInput objectForKey:DATA_CART_GATEWAY_KEY];
            NSDictionary *userInfo = @{DATA_CART_SUMMARY_KEY:cart.result.transaction?:[TransactionSummaryDetail new],
                                       DATA_DROPSHIPPER_NAME_KEY: _senderNameDropshipper?:@"",
                                       DATA_DROPSHIPPER_PHONE_KEY:_senderPhoneDropshipper?:@"",
                                       DATA_PARTIAL_LIST_KEY:_stockPartialStrList?:@{},
                                       DATA_TYPE_KEY:@(TYPE_CART_SUMMARY),
                                       DATA_CART_GATEWAY_KEY :selectedGateway
                                       };
            [_delegate didFinishRequestCheckoutData:userInfo];
        }
        if(cart.message_status)
        {
            NSArray *successMessages = cart.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
            [alert show];
        }
    }
}


#pragma mark - Request Buy



-(void)requestSuccessActionBuy:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    if ([object isKindOfClass:[RKMappingResult class]]) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        TransactionBuy *cart = stat;
        BOOL status = [cart.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(cart.message_error)
            {
                
                NSArray *errorMessages = cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                [alert show];
                
                switch ([_cartSummary.gateway integerValue]) {
                    case TYPE_GATEWAY_TRANSFER_BANK:
                        break;
                    case TYPE_GATEWAY_MANDIRI_CLICK_PAY:
                    {
                        //NSDictionary *data = @{DATA_KEY:_dataInput,
                        //                      DATA_CART_SUMMARY_KEY: _cartSummary
                        //                       };
                        //[_delegate pushVC:self toMandiriClickPayVCwithData:data];
                    }
                        break;
                    default:
                        break;
                }
            }
            if(cart.message_status)
            {
                NSArray *successMessages = cart.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                [alert show];
            }
            if (cart.result.is_success == 1) {
                _cartBuy = cart.result;
                switch ([_cartSummary.gateway integerValue]) {
                    case TYPE_GATEWAY_MANDIRI_E_CASH:
                    {
                        TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
                        vc.gateway = @(TYPE_GATEWAY_MANDIRI_E_CASH);
                        vc.token = _cartSummary.token;
                        vc.URLStringMandiri = cart.result.link_mandiri?:@"";
                        vc.cartDetail = _cartSummary;
                        vc.emoney_code = cart.result.transaction.emoney_code;
                        vc.delegate = self;
                        UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
                        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                        navigationController.navigationBar.translucent = NO;
                        navigationController.navigationBar.tintColor = [UIColor whiteColor];
                        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                    }
                        break;
                    default:
                    {
                        NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:cart.result};
                        [_delegate didFinishRequestBuyData:userInfo];
                        [_dataInput removeAllObjects];
                        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                    }
                        break;
                }
            }
        }
    }
}

#pragma mark - Request Action Voucher


-(void)requestSuccessActionVoucher:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionVoucher *dataVoucher = stat;
    BOOL status = [dataVoucher.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(dataVoucher.message_error)
        {
            [_dataInput removeObjectForKey:API_VOUCHER_CODE_KEY];
            NSArray *errorMessages = dataVoucher.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            _voucherCodeButton.hidden = YES;
            _voucherAmountLabel.hidden = NO;
            
            NSInteger voucher = [dataVoucher.result.data_voucher.voucher_amount integerValue];
            NSString *voucherString = [_IDRformatter stringFromNumber:[NSNumber numberWithInteger:voucher]];
            voucherString = [NSString stringWithFormat:@"Anda mendapatkan voucher %@,-", voucherString];
            _voucherAmountLabel.text = voucherString;
            _voucherAmountLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
            
            _buttonVoucherInfo.hidden = YES;
            _buttonCancelVoucher.hidden = NO;
            
            NSString *grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"," withString:@""];
            grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
            grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"-" withString:@""];
            grandTotal = [_cart.grand_total stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSInteger totalInteger = [grandTotal integerValue];
            
            if (totalInteger<=voucher) {
                [_dataInput setObject:@(totalInteger) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
            }
            else
            {
                [_dataInput setObject:@(voucher) forKey:DATA_CART_USED_VOUCHER_AMOUNT];
            }
            
            
            totalInteger -= voucher;
            if (totalInteger <0) {
                totalInteger = 0;
            }
            _cart.grand_total = [NSString stringWithFormat:@"%zd",totalInteger];
            _cart.grand_total_idr = [[_IDRformatter stringFromNumber:[NSNumber numberWithInteger:totalInteger]] stringByAppendingString:@",-"];
            [_dataInput setObject:@(voucher) forKey:DATA_VOUCHER_AMOUNT];
            [_dataInput setObject:_cart.grand_total forKey:DATA_CART_GRAND_TOTAL_BEFORE_DECREASE];
            [_tableView reloadData];
        }
    }
    
}


#pragma mark - Request Edit Product


-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(action.message_error)
        {
            NSArray *errorMessages = action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
            [alert show];
        }
        else{
            if (action.result.is_success == 1) {
                NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                [alert show];
                if (_indexPage == 0) {
                    [_networkManager doRequest];
                    _refreshFromShipment = YES;
                }
                [_tableView reloadData];
            }
        }
    }
}

#pragma mark - Request E-Money

-(void)requestSuccessEMoney:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TxEmoney *emoney = stat;
    BOOL status = [emoney.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //if (isWSNew) {
        if (emoney.result.is_success == 1) {
            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy?:@{}};
            [_delegate didFinishRequestBuyData:userInfo];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        }
        else
        {
            StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Pembayaran gagal"] delegate:self];
            [failedAlert show];
            [_delegate shouldBackToFirstPage];
        }
        //}
        //else
        //{
        //    if (emoney.result.is_success == 1) {
        //        if ([emoney.result.data.status rangeOfString:@"FAILED"].location != NSNotFound) {
        //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FAILED" message:@"Pembayaran gagal. Silahkan coba lagi." delegate:self cancelButtonTitle:@"Tutup" otherButtonTitles:nil];
        //            [alert show];
        //        }
        //        else if([emoney.result.data.status rangeOfString:@"SUCCESS"].location != NSNotFound)
        //        {
        //            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:_cartBuy};
        //            [_delegate didFinishRequestBuyData:userInfo];
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        //        }
        //    }
        //}
        
    }
}


#pragma mark - Request BCA ClickPay

-(void)requestSuccessBCAClickPay:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionBuy *BCAClickPay = stat;
    BOOL status = [BCAClickPay.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (BCAClickPay.result.is_success == 1) {
            
            NSDictionary *userInfo = @{DATA_CART_RESULT_KEY:BCAClickPay.result?:[TransactionBuyResult new]};
            [_delegate didFinishRequestBuyData:userInfo?:@{}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
        }
        else
        {
            StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Pembayaran gagal"] delegate:self];
            [failedAlert show];
            [_delegate shouldBackToFirstPage];
        }
    }
}


@end
