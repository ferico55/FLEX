//
//  TxOrderConfirmedCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TxOrderConfirmedList;
#define CONFIRMED_CELL_IDENTIFIER @"TxOrderConfirmedCellIdentifier"

@interface TxOrderConfirmedCell : UITableViewCell

@property (nonatomic, copy) void(^didTapInvoice)(TxOrderConfirmedList *);
@property (nonatomic, copy) void(^didTapPaymentProof)(TxOrderConfirmedList *);
@property (nonatomic, copy) void(^didTapUploadProof)(TxOrderConfirmedList *);
@property (nonatomic, copy) void(^didTapEditPayment)(TxOrderConfirmedList *);
@property (nonatomic, copy) void(^didTapCancelPayment)(TxOrderConfirmedList *);


+(id)newCell;
- (void)setupViewWithOrder:(TxOrderConfirmedList*)order;

@end
