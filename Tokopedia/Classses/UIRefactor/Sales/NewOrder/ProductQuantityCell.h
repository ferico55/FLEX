//
//  ProductQuantityCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductQuantityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UITextField *productQuantityTextField;


@end
