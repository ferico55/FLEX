//
//  DetailProductInfoCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/23/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "DetailProductViewController.h"
#import "DetailProductInfoCell.h"
#import "TTTAttributedLabel.h"
#import "string_more.h"

@interface DetailProductInfoCell()<TTTAttributedLabelDelegate>
@end


@implementation DetailProductInfoCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"DetailProductInfoCell" owner:nil options:0];
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
    }
    return self;
}

- (void)awakeFromNib
{
    lblMessageRetur.linkAttributes = @{
                                       (id)kCTForegroundColorAttributeName:[
                                                                            UIColor colorWithRed:10/255.0f
                                                                            green:126/255.0f
                                                                            blue:7/255.0f
                                                                            alpha:1.0f],
                                       NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
    lblMessageRetur.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
    _categorybuttons = [NSArray sortViewsWithTagInArray:_categorybuttons];
    self.productInformationView.layer.borderWidth = 0.5f;
    self.productInformationView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1].CGColor;
    self.productInformationView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - View Gestures
- (IBAction)tag:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        [_delegate DetailProductInfoCell:self withbuttonindex:btn.tag];
    }
}


#pragma mark - Method
- (void)setLblDescriptionToko:(NSString *)strText
{
    float labelHeight = 29;
    
    constraintHeightViewRetur.constant = (CPaddingTopDescToko*2)+labelHeight;
    lblMessageRetur.text = strText;
}

- (void)setLblDescriptionToko:(NSString *)strText withImageURL:(NSString *)url withBGColor:(UIColor *)color{
    float labelHeight = 50;
    
    constraintHeightViewRetur.constant = (CPaddingTopDescToko*2)+labelHeight;
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSString *string = [NSString stringReplaceAhrefWithUrl:strText];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    lblMessageRetur.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    lblMessageRetur.attributedText = attributedString;
    lblMessageRetur.delegate = self;
    viewRetur.backgroundColor = color;
    
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult* firstMatch = [linkDetector firstMatchInString:attributedString.string options:0 range:NSMakeRange(0, [attributedString length])];
    
    NSString* replaceString = @"Pelajari lebih lanjut.";
    [attributedString replaceCharactersInRange:firstMatch.range withString:replaceString];
    NSRange range = NSMakeRange(firstMatch.range.location, replaceString.length);
    lblMessageRetur.attributedText = attributedString;
    [lblMessageRetur addLinkToURL:firstMatch.URL withRange:range];
    
    [imgRetur setImageWithURL:[NSURL URLWithString:url]];
}

- (void)hiddenViewRetur
{
    constraintHeightViewRetur.constant = 0;
}

- (TTTAttributedLabel *)getLblRetur
{
    return lblMessageRetur;
}
- (float)getHeightReturView
{
    return constraintHeightViewRetur.constant;
}

#pragma mark - TTTAttributedDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    self.didTapReturnableInfo(url);
}
@end
