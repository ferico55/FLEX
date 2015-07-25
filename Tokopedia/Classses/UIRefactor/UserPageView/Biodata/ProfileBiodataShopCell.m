//
//  ProfileBiodataShopCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "DetailProductViewController.h"
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

- (void)generateMedal:(NSString *)value {
    int valueStar = value==nil||[value isEqualToString:@""]?0:[value intValue];
    valueStar = valueStar>0?valueStar:0;
    if(valueStar == 0) {
        [btnReputasi setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal" ofType:@"png"]] withCount:1] forState:UIControlStateNormal];
    }
    else {
        ///Set medal image
        int n = 0;
        if(valueStar<10 || (valueStar>250 && valueStar<=500) || (valueStar>10000 && valueStar<=20000) || (valueStar>500000 && valueStar<=1000000)) {
            n = 1;
        }
        else if((valueStar>10 && valueStar<=40) || (valueStar>500 && valueStar<=1000) || (valueStar>20000 && valueStar<=50000) || (valueStar>1000000 && valueStar<=2000000)) {
            n = 2;
        }
        else if((valueStar>40 && valueStar<=90) || (valueStar>1000 && valueStar<=2000) || (valueStar>50000 && valueStar<=100000) || (valueStar>2000000 && valueStar<=5000000)) {
            n = 3;
        }
        else if((valueStar>90 && valueStar<=150) || (valueStar>2000 && valueStar<=5000) || (valueStar>100000 && valueStar<=200000) || (valueStar>5000000 && valueStar<=10000000)) {
            n = 4;
        }
        else if((valueStar>150 && valueStar<=250) || (valueStar>5000 && valueStar<=10000) || (valueStar>200000 && valueStar<=500000) || valueStar>10000000) {
            n = 4;
        }
        
        //Check image medal
        if(valueStar <= 250) {
            [btnReputasi setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_bronze" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else if(valueStar <= 10000) {
            [btnReputasi setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_silver" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else if(valueStar <= 500000) {
            [btnReputasi setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_gold" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
        else {
            [btnReputasi setImage:[DetailProductViewController generateImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_medal_diamond_one" ofType:@"png"]] withCount:n] forState:UIControlStateNormal];
        }
    }
    
    //Set image and title reputasi
    CGFloat spacing = 6.0;
    CGSize imageSize = btnReputasi.imageView.frame.size;
    btnReputasi.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    CGSize titleSize = btnReputasi.titleLabel.frame.size;
    btnReputasi.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

- (void)actionReputasi:(id)sender {
    [_delegate actionReputasi:sender];
}

- (IBAction)actionKecepatan:(id)sender {
    [_delegate actionKecepatan:sender];
}
@end
