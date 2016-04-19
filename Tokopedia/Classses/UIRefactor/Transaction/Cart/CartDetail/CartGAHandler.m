//
//  CartGAHandler.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CartGAHandler.h"
#import "GAIDictionaryBuilder.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceFields.h"

@implementation CartGAHandler

+ (void)sendingProductCart:(NSArray<TransactionCartList*>*)list page:(NSInteger)page gateway:(NSString*)gateway {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                                           action:@"Checkout"
                                                                            label:nil
                                                                            value:nil];
    
    // Add the step number and additional info about the checkout to the action.
    GAIEcommerceProductAction *action = [[GAIEcommerceProductAction alloc] init];
    [action setAction:kGAIPACheckout];
    [action setCheckoutStep:(page == 0)?@1:@2];
    [action setCheckoutOption:gateway];
    
    for(TransactionCartList *cart in list) {
        for(ProductDetail *detailProduct in cart.cart_products) {
            GAIEcommerceProduct *product = [[GAIEcommerceProduct alloc] init];
            [product setId:detailProduct.product_id?:@""];
            [product setName:detailProduct.product_name?:@""];
            [product setCategory:[NSString stringWithFormat:@"%zd", detailProduct.product_department_id]];
            [product setPrice:@([detailProduct.product_price integerValue])];
            [product setQuantity:@([detailProduct.product_quantity integerValue])];
            
            [builder addProduct:product];
            [builder setProductAction:action];
        }
    }
    [tracker send:[builder build]];
}

@end
