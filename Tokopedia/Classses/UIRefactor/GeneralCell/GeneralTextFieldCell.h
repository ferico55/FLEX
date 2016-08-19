//
//  GeneralTextFieldCell.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralTextFieldCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIImageView *errorIcon;

+ (id)newCell;

@end
