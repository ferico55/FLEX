//
//  ReactAddProductHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 01/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "ReactAddProductHelper.h"
#import "Tkpd.h"
#import "Tokopedia-Swift.h"

@implementation ReactAddProductHelper

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(registerUploadingProduct: (NSDictionary*) product){
    ProcessingProduct *uploadingProduct = [[ProcessingProduct alloc] initWithPrice: [product objectForKey:@"price"]
                                                                     name: [product objectForKey:@"name"]
                                                                  etalase: [product objectForKey:@"showcase"]
                                                                 currency: [product objectForKey:@"currency"]
                                                                   failed: NO];
    
    ProcessingAddProducts *processor = [ProcessingAddProducts sharedInstance];
    NSMutableArray<ProcessingProduct*>* uploadingProducts = [[processor products] mutableCopy];
    [uploadingProducts addObject:uploadingProduct];
    [processor setProducts: uploadingProducts];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RefreshOnProcessAddProduct" object: nil];
    });
}

RCT_EXPORT_METHOD(removeProcessingProduct: (NSDictionary *) product) {
    NSMutableArray<ProcessingProduct*>* uploadingProducts = [NSMutableArray new];
    ProcessingAddProducts *processor = [ProcessingAddProducts sharedInstance];
    ProcessingProduct *successProduct = [[ProcessingProduct alloc] initWithPrice: [product objectForKey:@"price"]
                                                                           name: [product objectForKey:@"name"]
                                                                        etalase: [product objectForKey:@"showcase"]
                                                                       currency: [product objectForKey:@"currency"]
                                                                         failed: NO];

    for (ProcessingProduct *tempProduct in [processor products]) {
        if (![tempProduct isEqual: successProduct]) {
            [uploadingProducts addObject:tempProduct];
        }
    }
    
    [processor setProducts: uploadingProducts];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RefreshOnProcessAddProduct" object: nil];
        if ([product objectForKey:@"refresh"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: ADD_PRODUCT_POST_NOTIFICATION_NAME object: nil];
        }
    });
}

RCT_EXPORT_METHOD(triggerProductListUpdate) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"RefreshOnProcessAddProduct" object: nil];
    });
}

@end
