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

static CGFloat messageTextSize = 14.0;

- (void)awakeFromNib {
    _circle.layer.cornerRadius = _circle.frame.size.width / 2;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    _textAttributes = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                                                      NSParagraphStyleAttributeName  : style,
                                                                      NSForegroundColorAttributeName : [UIColor blackColor]}];
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
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n\n"];
        [_textAttributes setObject:[UIFont fontWithName:@"GothamMedium" size:12] forKey:NSFontAttributeName];
        _statusLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:_textAttributes];    
    }
}

- (void)setSubjectLabelText:(NSString *)text
{
    [_textAttributes setObject:[UIFont fontWithName:@"GothamBook" size:10] forKey:NSFontAttributeName];
    _subjectLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:_textAttributes];
    [_subjectLabel sizeToFit];
}

- (void)hideLine
{
    _verticalLine.hidden = YES;
}

+ (CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 220.0f;
    } else {
        return 400.0f;
    }
}

+ (CGSize)messageSize:(NSString*)message {
    message = [message stringByAppendingString:@"\n\n"];
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:messageTextSize]
                      constrainedToSize:CGSizeMake([self maxTextWidth], CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    size.height += 40;
    return size;
}

@end
