//
//  DetailShipmentStatusCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailShipmentStatusCell.h"

@interface DetailShipmentStatusCell () {
    NSMutableDictionary *_textAttributes;
}

@property (weak, nonatomic) IBOutlet UIView *circle;
@property (weak, nonatomic) IBOutlet UIView *verticalLine;

@end

@implementation DetailShipmentStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _circle.layer.cornerRadius = _circle.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setColorThemeForActionBy:(NSString *)subject
{
    if ([subject isEqualToString:@"Seller"]) {
        _circle.backgroundColor = [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1];
    } else if ([subject isEqualToString:@"Buyer"]) {
        _circle.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:145.0/255.0 blue:0.0/255.0 alpha:1];
    } else {
        _circle.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1];
    }
}

- (void)setStatusLabelText:(NSString *)text;
{
    if (text) {
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        _statusLabel.text = text;
    }
}

- (void)setSubjectLabelText:(NSString *)text
{
    if ([text isEqualToString:@"Seller"]) {
        text = @"Penjual";
    } else if ([text isEqualToString:@"Buyer"]) {
        text = @"Pembeli";
    }
    
    [_textAttributes setObject:[UIFont microTheme] forKey:NSFontAttributeName];
    _subjectLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:_textAttributes];
    [_subjectLabel sizeToFit];
}

- (void)setLineHidden:(BOOL)lineHidden{
    _verticalLine.hidden = lineHidden;
}

+ (CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 197.0f;
    } else {
        return 400.0f;
    }
}

+ (CGSize)messageSize:(NSString*)message {
    message = [message stringByAppendingString:@"\n\n"];
    CGSize size = [message boundingRectWithSize:CGSizeMake([self maxTextWidth], 9999.0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont largeThemeMedium]}
                                        context:[NSStringDrawingContext new]].size;
    size.height += 40;
    return size;
}

@end
