//
//  ResolutionCenterSellerEditProductCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResolutionCenterSellerEditProductCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIButton *productNameButton;
@property (strong, nonatomic) IBOutlet UILabel *problemLabel;
@property (strong, nonatomic) IBOutlet UILabel *problemDescriptionLabel;
+ (id)newcell;
@end
