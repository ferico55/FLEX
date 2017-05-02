//
//  ListOrderComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKNetworkImageDownloading.h>

#import "ListOrderComponent.h"
#import "ListOrderInvoiceComponent.h"
#import "ListOrderShopComponent.h"
#import "OrderCellContext.h"
#import "ListOrderStatusComponent.h"
#import "ListOrderButtonsComponent.h"

@implementation ListOrderComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context {
    
    ListOrderComponent *component =
    [super newWithComponent:
     [CKInsetComponent
      newWithView:{}
      insets:{5,10,5,10}
      component:
          [CKStackLayoutComponent
           newWithView:{}
           size:{}
           style:{
               .direction = CKStackLayoutDirectionVertical,
               .alignItems = CKStackLayoutAlignItemsStretch,
           }
           children:{
               {[self componentHorizontalBorder]},
               {[ListOrderInvoiceComponent newWithOrder:order context:context],
                   .alignSelf = CKStackLayoutAlignSelfStretch,
               },
               {[self componentHorizontalBorder]},
               {[ListOrderShopComponent newWithOrder:order context:context]},
               {[self componentHorizontalBorder]},
               {[ListOrderStatusComponent newWithOrder:order context:context]},
               {[self componentHorizontalBorder]},
               {[self componentButtonsWithOrder:order context:context]}
           }]
      ]
     ];
    
    component ->_order = order;
    component ->_context = context;
    return component;
}

+ (CKComponent *)componentButtonsWithOrder:order context:context{
    return
    [CKInsetComponent
     newWithView:{
         [UIView class],
         {
             {@selector(setBackgroundColor:), [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1]}
         }
     }
     insets:{}
     component:
         [ListOrderButtonsComponent newWithOrder:order context:context]
     ];
}

+ (CKComponent *)componentHorizontalBorder{
    return
    [CKComponent
     newWithView:{
         [UIView class],
         {{@selector(setBackgroundColor:), [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1]}}
     }
     size:{.height = 1}];
}

@end
