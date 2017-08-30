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
          {(order.canRequestCancel)?[self buttonRequestCancelOrder]:nil,
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
          {(order.canComplaint)?[self buttonComplaint]:nil,
              .alignSelf = CKStackLayoutAlignSelfStretch,
              .flexGrow = YES
          },
          {(order.canBeDone)?[self buttonDone]:nil,
              .alignSelf = CKStackLayoutAlignSelfStretch,
              .flexGrow = YES
          },
          {(order.canSeeComplaint)?[self buttonSeeComplaint]:nil,
              .alignSelf = CKStackLayoutAlignSelfStretch,
              .flexGrow = YES
          },
          {(order.canCancelReplacement)?[self buttonCancelReplacement]:nil,
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
    return [self buttonWithTitle:@"Tanya Penjual" action:@selector(tapAskSeller)];
}

+(CKButtonComponent*)buttonRequestCancelOrder{
    return [self buttonWithTitle:@"Ajukan Pembatalan" action:@selector(tapCancel)];
}

+(CKButtonComponent*)buttonTrack{
    return [self buttonWithTitle:@"Lacak" action:@selector(tapTracking)];
}

+(CKButtonComponent*)buttonNotReceived{
    return [self buttonWithTitle:@"Belum Terima" action:@selector(tapComplaintNotReceived)];
}

+(CKButtonComponent*)buttonDone{
    return [self buttonWithTitle:@"Selesai" action:@selector(tapReceivedOrder)];
}

+(CKButtonComponent*)buttonSeeComplaint{
    return [self buttonWithTitle:@"Lihat Komplain" action:@selector(tapSeeComplaint)];
}

+(CKButtonComponent*)buttonReorder{
    return [self buttonWithTitle:@"Pesan Ulang" action:@selector(tapReorder)];
}

+(CKButtonComponent*)buttonComplaint{
    return [self buttonWithTitle:@"Komplain" action:@selector(tapComplaint)];
}

+(CKButtonComponent*)buttonCancelReplacement{
    return [self buttonWithTitle:@"Batalkan Pesanan" action:@selector(tapCancelReplacement)];
}

+ (CKButtonComponent *)buttonWithTitle:(NSString *)title action:(SEL)action {
    return [CKButtonComponent
            newWithTitles:{
                {UIControlStateNormal, title}
            }
            titleColors:{
                {UIControlStateNormal, [UIColor textDarkGrayTheme]}
            }
            images: {}
            backgroundImages:{}
            titleFont:[UIFont microTheme]
            selected:NO
            enabled:YES
            action:nil
            size:{
                .height = 40
            }
            attributes:{
                {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 0.5},
                {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1] CGColor]},
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

-(void)tapCancelReplacement{
    if (_context.onTapCancelReplacement){
        _context.onTapCancelReplacement(_order);
    }
}

- (void)tapComplaint {
    if (_context.onTapComplaint) {
        _context.onTapComplaint(_order);
    }
}

@end
