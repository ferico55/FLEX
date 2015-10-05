//
//  ResizeableImageCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResizeableImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *textCellLabel;

+ (id)newCell;

@end
