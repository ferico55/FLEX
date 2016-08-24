//
//  DetailProductCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductDescriptionCell.h"
#import "detail.h"

@implementation DetailProductDescriptionCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DetailProductDescriptionCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    if (_descriptionText) [self updateLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setDescriptionText:(NSString *)descriptionText
{
    if ([descriptionText isEqualToString:@"0"]) {
        _descriptionText = [NSString stringWithFormat:@"%@\n\n", KTKPDETAIL_DESCRIPTION_EMPTY];
    }
    else {
        _descriptionText = [NSString stringWithFormat:@"%@\n\n", descriptionText];
    }
    [self updateLabel];
}

- (void)updateLabel
{

    UIFont *font = [UIFont smallTheme];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *myString = [[NSAttributedString alloc] initWithString:self.descriptionText
                                                                   attributes:attributes];
    self.descriptionlabel.attributedText = myString;
    [self.descriptionlabel sizeToFit];
}

@end
