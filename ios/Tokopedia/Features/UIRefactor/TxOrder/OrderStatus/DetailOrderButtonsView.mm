//
//  DetailOrderButtonsView.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKNetworkImageDownloading.h>
#import "DetailOrderButtonsView.h"
#import "TxOrderStatusList.h"
#import "ListOrderButtonsComponent.h"
#import "ListOrderButtonsComponent.h"
#import "HeaderInvoiceComponent.h"

@implementation DetailOrderButtonsView{
    TxOrderStatusList *_order;
    OrderCellContext *_context;
}

-(instancetype)initWithOrder:(TxOrderStatusList *)order{
    
    CKComponentFlexibleSizeRangeProvider *sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider
                                                               providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    
    self = [super initWithComponentProvider:[self class]
                          sizeRangeProvider:sizeRangeProvider];
    
    _order = order;
    
    [self updateContext:[self context] mode:CKUpdateModeSynchronous];
    [self updateModel:order mode:CKUpdateModeSynchronous];
    
    return self;
}

- (void)removeAcceptButton{
    [_order accept];
    [self updateModel:_order mode:CKUpdateModeSynchronous];
}

- (void)removeCancelReplacementButton {
    _order.canCancelReplacement = NO;
    [self updateModel:_order mode:CKUpdateModeSynchronous];
}

-(void)removeSeeComplaintButton{
    _order.canSeeComplaint = NO;
    [self updateModel:_order mode:CKUpdateModeSynchronous];
}

-(void)removeRequestCancelButton{
    _order.canRequestCancel = 0;
    [self updateModel:_order mode:CKUpdateModeSynchronous];
}

-(void)removeComplaintButton {
    _order.canComplaint = NO;
    [self updateModel:_order mode:CKUpdateModeSynchronous];
}

-(OrderCellContext*)context{
    if (!_context) {
        _context = [OrderCellContext new];
    }
    return _context;
}

+ (CKComponent *)componentForModel:(TxOrderStatusList *)order context:(OrderCellContext *)context {
    return
    [CKStackLayoutComponent
     newWithView:{}
     size:{}
     style:{
         .direction = CKStackLayoutDirectionVertical,
         .alignItems = CKStackLayoutAlignItemsStretch,
     }
     children:{
         {[self componentButtonsWithOrder:order context:context]},
         {[self componentHorizontalBorder]},
         {[self componentInvoiceWithOrder:order context:context]},
         {[self componentHorizontalBorder]}
     }];
}

+ (CKComponent *)componentButtonsWithOrder:order context:context{
    return
    [CKInsetComponent
     newWithView:{
         [UIView class],
         {
             {@selector(setBackgroundColor:), [UIColor whiteColor]}
         }
     }
     insets:{}
     component:
     [ListOrderButtonsComponent newWithOrder:order context:context]
     ];
}

+ (CKComponent *)componentInvoiceWithOrder:order context:context{
    return
    [CKInsetComponent
     newWithView:{
         [UIView class],
         {
             {@selector(setBackgroundColor:), [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1]}
         }
     }
     insets:{
         .top = 15,
         .bottom = 15
     }
     component:
         [HeaderInvoiceComponent newWithOrder:order context:context]
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
