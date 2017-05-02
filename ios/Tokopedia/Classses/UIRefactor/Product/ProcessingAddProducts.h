//
//  ProcessingAddProducts.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductEditResult;

@interface ProcessingAddProducts : NSObject

@property (nonatomic, retain) NSMutableArray<ProductEditResult*> *products;
+(ProcessingAddProducts *)sharedInstance;

@end
