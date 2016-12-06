//
//  ListOrderStatusComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

#import "ListOrderStatusComponent.h"
#import "TxOrderStatusList.h"
#import "UIColor+TextColor.h"
#import "OrderCellContext.h"

@implementation ListOrderStatusComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context{
    
    ListOrderStatusComponent * component =
    [super newWithComponent:
     [CKInsetComponent
      newWithView:{
          [UIView class],
          {
              {@selector(setBackgroundColor:), [UIColor whiteColor]},
          }
      }
      insets:{8,8,8,8}
      component:
          [CKStackLayoutComponent
           newWithView:{}
           size:{}
           style:{
               .direction = CKStackLayoutDirectionHorizontal,
               .alignItems = CKStackLayoutAlignItemsCenter,
               .spacing = 4,
           }
           children:{
               {[self statusViewWithOrder:order],
                   .alignSelf = CKStackLayoutAlignSelfStart,
                   .flexGrow = YES,
                   .flexShrink = YES
               },
              {
                  [self disclosureImage],
                  .alignSelf = CKStackLayoutAlignSelfCenter,
              }
           }]
     ]];
    component->_order = order;
    component->_context = context;
    return component;
}

+(CKComponent *)statusViewWithOrder:(TxOrderStatusList *)order{
     return
      [CKStackLayoutComponent
       newWithView:{
           [UIView class],
           {
               {CKComponentTapGestureAttribute(@selector(tapDetail))},
           }
       }
       size:{}
       style:{
           .direction = CKStackLayoutDirectionVertical,
           .spacing = 4
       }
       children:{
           {[self labelLastStatus]},
           {[self labelWithStatusOrder:order.lastStatusString]}
       }];
}

+(CKComponent *)disclosureImage{
    return
    [CKImageComponent
     newWithImage:[UIImage imageNamed:@"icon_arrow_right_grey.png"]
     size:{15,15}
     ];
}

+(CKLabelComponent *)labelLastStatus{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = @"Status Terakhir",
         .color = [UIColor textDarkGrayTheme],
         .font = [UIFont microTheme]
     }
     viewAttributes:{
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKLabelComponent *)labelWithStatusOrder:(NSString *)statusOrder{
    CKLabelComponent *component =
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = statusOrder,
         .font = [UIFont smallThemeMedium],
         .lineBreakMode = NSLineBreakByWordWrapping
     }
     viewAttributes:{
         {CKComponentTapGestureAttribute(@selector(tapDetail))},
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
    
    return component;
}

-(void)tapDetail{
    if (_context.onTapDetail) {
        _context.onTapDetail(_order);
    }
}

@end
