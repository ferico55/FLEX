//
//  ListOrderInvoiceComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "UIColor+TextColor.h"
#import "OrderCellContext.h"
#import "TxOrderStatusList.h"
#import "UIColor+Theme.h"
#import "ListOrderInvoiceComponent.h"

@implementation ListOrderInvoiceComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+(UIColor*) colorWithDayLeft:(NSInteger)dayLeft{
    
    UIColor *threeDaysLeft = [UIColor colorWithRed:0/255.f green:121.f/255.f blue:255.f/255.f alpha:1];
    UIColor *tomorrow = [UIColor colorWithRed:255.f/255.f green:145.f/255.f blue:0/255.f alpha:1];
    UIColor *today = [UIColor colorWithRed:255.f/255.f green:59.f/255.f blue:48.f/255.f alpha:1];
    UIColor *expired = [UIColor colorWithRed:158.f/255.f green:158.f/255.f blue:158.f/255.f alpha:1];
    
    if (dayLeft<0) {
        return expired;
    }
    
    switch (dayLeft) {
        case 1:
            return tomorrow;
            break;
        case  0:
            return today;
            break;
        default:
            return threeDaysLeft;
            break;
    }
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext *)context{
        
    ListOrderInvoiceComponent *component =
    [super newWithComponent:
    [CKInsetComponent
     newWithView:{
         [UIView class],
         {
             {@selector(setBackgroundColor:), [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1]},
         }
     }
     insets:{4,8,4,8}
     component:
     [CKStackLayoutComponent
      newWithView:{}
      size:{}
      style:{
          .direction = CKStackLayoutDirectionHorizontal,
          .alignItems = CKStackLayoutAlignItemsStretch,
          .spacing = 10
      }
      children:{
          {
              [CKStackLayoutComponent
               newWithView:{}
               size:{}
               style:{
                   .direction = CKStackLayoutDirectionVertical,
                   .alignItems = CKStackLayoutAlignItemsStretch,
                   .spacing = 4
               }
               children:{
                   {[self labelWithInvoice:order.order_detail.detail_invoice]},
                   {[self labelWithOrderDate:order.order_detail.detail_order_date]},
               }],
              .alignSelf = CKStackLayoutAlignSelfStretch,
              .flexGrow = YES,
              .flexShrink = YES
          },
          {
              (order.hasDueDate)?[self dayLeftViewWithOrder:order]:nil,
              .alignSelf = CKStackLayoutAlignSelfCenter,
          },
      }]]];
    
    component->_order = order;
    component->_context = context;
    
    return component;
}

+(CKStackLayoutComponent *)dayLeftViewWithOrder:(TxOrderStatusList *)order{
    return
    [CKStackLayoutComponent
     newWithView:{}
     size:{}
     style:{
         .direction = CKStackLayoutDirectionVertical,
         .alignItems = CKStackLayoutAlignItemsStretch,
         .spacing = 4
     }
     children:{
         {[self labelAutomaticallyCanceled]},
         {[self labelDayLeftOrder:order]},
     }];
}

+(CKLabelComponent *)labelWithInvoice:(NSString*)invoice{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = invoice,
         .color = [UIColor textGreenTheme],
         .font = [UIFont microThemeMedium],
         .maximumNumberOfLines = 1,
         .lineBreakMode = NSLineBreakByTruncatingMiddle
     }
     viewAttributes:{
         {CKComponentTapGestureAttribute(@selector(tapInvoice:))},
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKLabelComponent *)labelWithOrderDate:(NSString*)date {
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = date,
         .color = [UIColor textLightGrayTheme],
         .font = [UIFont microTheme],
     }
     viewAttributes:{
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKLabelComponent *)labelAutomaticallyCanceled{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = @"Batal Otomatis",
         .color = [UIColor textDarkGrayTheme],
         .font = [UIFont systemFontOfSize:10],
     }
     viewAttributes:{
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKInsetComponent *)labelDayLeftOrder:(TxOrderStatusList *)order{
    return
    [CKInsetComponent
     newWithView:{
         [UIView class],
         {
             {@selector(setBackgroundColor:), [UIColor fromHexString:order.order_deadline.deadline_color]},
         }
     }
     insets:{2,2,2,2}
     component:
     [CKLabelComponent
      newWithLabelAttributes:{
          .string = order.dayLeftString,
          .color = [UIColor whiteColor],
          .font = [UIFont microTheme],
          .alignment = NSTextAlignmentCenter,
      }
      viewAttributes:{
          {@selector(setBackgroundColor:), [UIColor clearColor]},
      }
      size:{}]
     ];
}

-(void)tapInvoice:(CKComponent *)sender{
    if (_context.onTapInvoice){
        _context.onTapInvoice(_order);
    }
}

@end
