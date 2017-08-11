//
//  CatalogAddProduct.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogResult.h"

@interface CatalogAddProduct : NSObject  <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray<NSString*> *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) CatalogResult *data;

@end
