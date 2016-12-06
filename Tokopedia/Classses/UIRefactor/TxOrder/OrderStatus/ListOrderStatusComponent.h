//
//  ListOrderStatusComponent.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TxOrderStatusList;
@class OrderCellContext;

@interface ListOrderStatusComponent : CKCompositeComponent

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context;

@end
