//
//  ShipmentLocaltionPickupViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTextView.h"

@class RSKPlaceholderTextView;

@interface ShipmentLocationPickupViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet RSKPlaceholderTextView *pickupAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *viewPinpoint;
@property (weak, nonatomic) IBOutlet UILabel *lblOptional;

- (void)showPinpointView:(BOOL)show;

@end
