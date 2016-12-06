//
//  HeaderInvoiceComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "HeaderInvoiceComponent.h"
#import "TxOrderStatusList.h"
#import "UIColor+TextColor.h"
#import "OrderCellContext.h"
#import "ListOrderStatusComponent.h"

@implementation HeaderInvoiceComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context{

    HeaderInvoiceComponent *component =
    [super newWithComponent:
      [CKLabelComponent
       newWithLabelAttributes:{
           .string = order.order_detail.detail_invoice,
           .color = [UIColor textGreenTheme],
           .font = [UIFont largeThemeMedium],
           .alignment = NSTextAlignmentCenter
       }
       viewAttributes:{
           {CKComponentTapGestureAttribute(@selector(tapInvoice:))},
           {@selector(setBackgroundColor:), [UIColor clearColor]},
       }
       size:{}]
     ];
    component->_order = order;
    component->_context = context;
    
    return component;
}

-(void)tapInvoice:(CKLabelComponent*)sender{
    if (_context.onTapInvoice) {
        _context.onTapInvoice(_order);
    }
}

@end
