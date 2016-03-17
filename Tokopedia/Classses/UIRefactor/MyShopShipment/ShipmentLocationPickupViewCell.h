//
//  ShipmentLocaltionPickupViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShipmentLocationPickupViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *pickupAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;

@end
