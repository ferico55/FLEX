//
//  CatalogSpecificationCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogSpecificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

- (void)hideTopBorder:(BOOL)hide;
- (void)hideBottomBorder:(BOOL)hide;

@end
