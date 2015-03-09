//
//  CatalogProductCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@end
