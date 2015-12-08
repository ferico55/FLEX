//
//  TransactionShipmentATCTableViewCell.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionShipmentATCTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *autoResiLogo;
@property (weak, nonatomic) IBOutlet UILabel *shipmentNameLabel;

+ (id)newCell;

@end
