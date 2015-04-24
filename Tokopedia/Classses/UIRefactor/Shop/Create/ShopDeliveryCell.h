//
//  ShopDeliveryCell.h
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDeliveryCell : UITableViewCell
{
    UILabel *lblText, *lblValue;
    UITextField *txtField;
}

- (UILabel *)getLblValue;
- (UILabel *)getLblText;
- (UITextField *)getTxtField;
@end
