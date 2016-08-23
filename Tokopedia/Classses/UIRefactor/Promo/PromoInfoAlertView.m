//
//  PromoInfoAlertView.m
//  Tokopedia
//
//  Created by Tokopedia on 8/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoInfoAlertView.h"

#pragma mark TKPDAlertView category

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@interface PromoInfoAlertView ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *firstParagraph;
@property (weak, nonatomic) IBOutlet UILabel *secondParagraph;
@property (weak, nonatomic) IBOutlet UILabel *thirdParagraph;

@end

@implementation PromoInfoAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.button.layer.cornerRadius = 5;
}

- (IBAction)tap:(id)sender {
    [self dismissindex:1 silent:NO animated:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

- (void)show {
    [super show];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    UIFont *font = [UIFont largeTheme];

    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSString *firstParagraph = @"Toko dan produk Anda akan lebih mudah ditemukan oleh pengunjung Tokopedia";
    NSString *secondParagraph = @"TopAds membantu Anda menjangkau calon pembeli yang sesuai, melalui pencarian produk dan penelusuran";
    NSString *thirdParagraph = @"Dengan TopAds, hasil yang Anda harapkan sesuai dengan biaya yang Anda keluarkan";
    
    NSAttributedString *firstAttributedString = [[NSAttributedString alloc] initWithString:firstParagraph attributes:attributes];
    self.firstParagraph.attributedText = firstAttributedString;
    [self.firstParagraph sizeToFit];
    
    NSAttributedString *secondAttributedString = [[NSAttributedString alloc] initWithString:secondParagraph attributes:attributes];
    self.secondParagraph.attributedText = secondAttributedString;
    [self.secondParagraph sizeToFit];
    
    NSAttributedString *thirdAttributedString = [[NSAttributedString alloc] initWithString:thirdParagraph attributes:attributes];
    self.thirdParagraph.attributedText = thirdAttributedString;
    [self.thirdParagraph sizeToFit];
}

@end
