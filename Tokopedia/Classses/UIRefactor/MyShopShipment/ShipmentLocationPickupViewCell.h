//
//  ShipmentLocaltionPickupViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTextView.h"
#import "Tokopedia-Swift.h"

@interface ShipmentLocationPickupViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet RSKPlaceholderTextView *pickupAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;

@end
