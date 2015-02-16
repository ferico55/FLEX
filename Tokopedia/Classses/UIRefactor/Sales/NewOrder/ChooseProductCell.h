//
//  ChooseProductCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@end
