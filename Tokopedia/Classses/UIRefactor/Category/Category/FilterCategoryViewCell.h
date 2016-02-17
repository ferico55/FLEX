//
//  FilterCategoryViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCategoryViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end
