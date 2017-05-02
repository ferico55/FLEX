//
//  DetailOrderButtonsView.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/CKComponentHostingView.h>
#import <Foundation/Foundation.h>
#import "TxOrderStatusList.h"

#import "OrderCellContext.h"

@interface DetailOrderButtonsView : CKComponentHostingView

- (instancetype)initWithOrder:(TxOrderStatusList *)order;

- (OrderCellContext*)context;

-(void)removeSeeComplaintButton;
-(void)removeRequestCancelButton;
-(void)removeAcceptButton;
-(void)removeComplaintNotReceivedButton;

@end
