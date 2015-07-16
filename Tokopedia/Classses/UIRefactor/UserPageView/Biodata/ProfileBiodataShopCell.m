//
//  ProfileBiodataShopCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileBiodataShopCell.h"

@implementation ProfileBiodataShopCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ProfileBiodataShopCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    //Set image and title kecepatan
    CGFloat spacing = 6.0;
    CGSize imageSize = btnKecepatan.imageView.frame.size;
    btnKecepatan.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    CGSize titleSize = btnKecepatan.titleLabel.frame.size;
    btnKecepatan.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    //Set image and title reputasi
    imageSize = btnReputasi.imageView.frame.size;
    btnReputasi.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    titleSize = btnReputasi.titleLabel.frame.size;
    btnReputasi.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



#pragma mark - Method
- (void)setBadgeIcon:(NSString *)badge {
    if([badge isEqualToString:CBadgeSpeedGood]) {
        [btnKecepatan setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_fast" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else if([badge isEqualToString:CBadgeSpeedBad]) {
        [btnKecepatan setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_bad" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else if([badge isEqualToString:CBadgeSpeedNeutral]) {
        [btnKecepatan setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_neutral" ofType:@"png"]] forState:UIControlStateNormal];
    }
}

- (void)actionReputasi:(id)sender {
    [_delegate actionReputasi:sender];
}

- (IBAction)actionKecepatan:(id)sender {
    [_delegate actionKecepatan:sender];
}
@end
