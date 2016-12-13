//
//  ListOrderButtonsComponent.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "ListOrderButtonsComponent.h"
#import "TxOrderStatusList.h"
#import "UIColor+TextColor.h"
#import "OrderCellContext.h"

@implementation ListOrderButtonsComponent{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

+ (instancetype)newWithOrder:(TxOrderStatusList *)order context:(OrderCellContext *)context{
    
    ListOrderButtonsComponent *component =
    [super newWithComponent:
      [CKStackLayoutComponent
       newWithView:{
           [UIView class],
           {
               {@selector(setBackgroundColor:), [UIColor clearColor]},
           }
       }
       size:{}
       style:{
           .direction = CKStackLayoutDirectionHorizontal,
           .alignItems = CKStackLayoutAlignItemsStretch,
       }
       children:{
           { (order.canAskSeller)?[self buttonAskSeller]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           {(order.canRequestCancel)?[self buttonRequestCancelOrder]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           {(order.canComplaintNotReceived)?[self buttonNotReceived]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           { (order.canReorder)?[self buttonReorder]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           { (order.trackable)?[self buttonTrack]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           {(order.canAccept)?[self buttonAccept]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
           {(order.canSeeComplaint)?[self buttonSeeComplaint]:nil,
               .alignSelf = CKStackLayoutAlignSelfStretch,
               .flexGrow = YES
           },
       }]
     ];
    component -> _order = order;
    component ->_context = context;
    return component;
}

+(CKButtonComponent*)buttonAskSeller{
    return [self buttonWithTitle:@"Tanya Penjual" imageName:@"icon_order_message_grey" action:@selector(tapAskSeller)];
}

+(CKButtonComponent*)buttonRequestCancelOrder{
    return [self buttonWithTitle:@"Ajukan Pembatalan" imageName:@"icon_order_cancel-01.png" action:@selector(tapCancel)];
}

+(CKButtonComponent*)buttonTrack{
    return [self buttonWithTitle:@"Lacak" imageName:@"icon_track_grey.png" action:@selector(tapTracking)];
}

+(CKButtonComponent*)buttonNotReceived{
    return [self buttonWithTitle:@"Belum Terima" imageName:@"icon_order_cancel-01.png" action:@selector(tapComplaintNotReceived)];
}

+(CKButtonComponent*)buttonAccept{
    return [self buttonWithTitle:@"Sudah Terima" imageName:@"icon_order_check-01.png" action:@selector(tapReceivedOrder)];
}

+(CKButtonComponent*)buttonSeeComplaint{
    return [self buttonWithTitle:@"Lihat Komplain" imageName:@"icon_lihat_komplain.png" action:@selector(tapSeeComplaint)];
}

+(CKButtonComponent*)buttonReorder{
    return [self buttonWithTitle:@"Pesan Ulang" imageName:@"icon_pesan_ulang.png" action:@selector(tapReorder)];
}

+(CKButtonComponent *)buttonWithTitle:(NSString*)title imageName:(NSString*)imageName action:(SEL)action{
    
    return
    [CKButtonComponent
     newWithTitles:{
         {UIControlStateNormal, title}
     }
     titleColors:{
         {UIControlStateNormal, [UIColor textDarkGrayTheme]}
     }
     images:{
         {UIControlStateNormal, [UIImage imageNamed:imageName]}
     }
     backgroundImages:{}
     titleFont:[UIFont systemFontOfSize:10]
     selected:NO
     enabled:YES
     action:nil
     size:{
         .height = 40
     }
     attributes:{
         {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 0.5},
         {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1] CGColor]},
         {@selector(setTitleEdgeInsets:), UIEdgeInsetsMake(0, 10, 0, 0)},
         {CKComponentActionAttribute(action)}
     }
     accessibilityConfiguration:{}];
}

-(void)tapCancel{
    if(_context.onTapCancel){
        _context.onTapCancel(_order);
    }
}

-(void)tapAskSeller{
    if (_context.onTapAskSeller) {
        _context.onTapAskSeller(_order);
    }
}

-(void)tapTracking{
    if (_context.onTapTracking){
        _context.onTapTracking(_order);
    }
}

-(void)tapComplaintNotReceived{
    if(_context.onTapComplaintNotReceived){
        _context.onTapComplaintNotReceived(_order);
    }
}

-(void)tapReceivedOrder{
    if(_context.onTapReceivedOrder){
        _context.onTapReceivedOrder(_order);
    }
}

-(void)tapSeeComplaint{
    if(_context.onTapSeeComplaint){
        _context.onTapSeeComplaint(_order);
    }
}

-(void)tapReorder{
    if (_context.onTapReorder){
        _context.onTapReorder(_order);
    }
}

@end
