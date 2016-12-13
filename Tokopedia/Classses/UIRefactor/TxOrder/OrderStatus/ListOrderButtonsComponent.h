//
//  ListOrderButtonsComponent.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TxOrderStatusList;
@class OrderCellContext;

@interface ListOrderButtonsComponent : CKCompositeComponent

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext *)context;

@end
