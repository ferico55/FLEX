//
//  HeaderInvoiceComponent.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

@class TxOrderStatusList;
@class OrderCellContext;

@interface HeaderInvoiceComponent : CKCompositeComponent

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context;

@end
