//
//  GeneralAlertCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralAlertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

+ (id)newCell;

@end
