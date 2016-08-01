//
//  ResolutionCenterSellerEditProductCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterSellerEditProductCell.h"

@interface ResolutionCenterSellerEditProductCell ()

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIButton *productNameButton;
@property (strong, nonatomic) IBOutlet UILabel *problemLabel;
@property (strong, nonatomic) IBOutlet UILabel *problemDescriptionLabel;

@end

@implementation ResolutionCenterSellerEditProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
