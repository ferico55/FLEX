//
//  ListOrderShopComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "UIColor+TextColor.h"
#import "TxOrderStatusList.h"
#import "OrderCellContext.h"

#import "ListOrderShopComponent.h"

@implementation ListOrderShopComponent{
    TxOrderStatusList *_order;
    OrderCellContext* _context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext*)context {
    
    ListOrderShopComponent *component =
    [super newWithComponent:
        [CKInsetComponent
         newWithView:{
             [UIView class],
             {
                 {CKComponentTapGestureAttribute(@selector(tapDetail))},
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
                  .spacing = 10
              }
              children:{
                  {[ListOrderShopComponent thumbWithShopUrlString:order.order_shop.shop_pic context:context]},
                  {
                      [CKStackLayoutComponent
                       newWithView:{}
                       size:{}
                       style:{
                           .direction = CKStackLayoutDirectionVertical,
                           .spacing = 4,
                       }
                       children:{
                           {[self labelBuyFrom]},
                           {[self labelWithShopName:order.order_shop.shop_name]}
                       }],
                  }
              }]
         ]
     ];
    component -> _order = order;
    component -> _context = context;
    return component;
}

+(CKNetworkImageComponent *)thumbWithShopUrlString:(NSString*)urlString context:(OrderCellContext*)context{
    return
    [CKNetworkImageComponent
     newWithURL:[NSURL URLWithString:urlString]
     imageDownloader:context.imageDownloader
     scenePath:nil
     size:{ .width = 44, .height = 44 }
     options:{}
     attributes:{
         {CKComponentTapGestureAttribute(@selector(tapShop))},
         {@selector(setUserInteractionEnabled:), YES}
     }];
}

+(CKLabelComponent *)labelBuyFrom{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = @"Pembelian Dari",
         .color = [UIColor textLightGrayTheme],
         .font = [UIFont smallTheme]
     }
     viewAttributes:{
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

+(CKLabelComponent *)labelWithShopName:(NSString*)shopName{
    return
    [CKLabelComponent
     newWithLabelAttributes:{
         .string = shopName,
         .color = [UIColor textGreenTheme],
         .font = [UIFont smallThemeMedium],
     }
     viewAttributes:{
         {CKComponentTapGestureAttribute(@selector(tapShop))},
         {@selector(setBackgroundColor:), [UIColor clearColor]},
     }
     size:{}];
}

-(void)tapShop{
    if (_context.onTapShop) {
        _context.onTapShop(_order);
    }
}

-(void)tapDetail{
    if (_context.onTapDetail) {
        _context.onTapDetail(_order);
    }
}

@end
