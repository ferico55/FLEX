//
//  ProcessingAddProducts.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ProcessingAddProducts.h"

@implementation ProcessingAddProducts

+(ProcessingAddProducts *)sharedInstance {
    static dispatch_once_t pred;
    static ProcessingAddProducts *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[ProcessingAddProducts alloc] init];
        shared.products = [[NSMutableArray alloc] init];
    });
    return shared;
}

@end
