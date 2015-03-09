//
//  TxOrderConfirmationShipmentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHIPMENT_CELL_IDENTIFIER @"TxOrderConfirmationShipmentCellIdentifier"

@interface TxOrderConfirmationShipmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *shipmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLabel;
@property (weak, nonatomic) IBOutlet UILabel *partialLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropshipLabel;

+(id)newCell;

@end
