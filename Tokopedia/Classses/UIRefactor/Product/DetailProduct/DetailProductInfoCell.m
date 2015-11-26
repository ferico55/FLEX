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
    if(lblMessageRetur == nil) {
        lblMessageRetur = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        lblMessageRetur.textAlignment = NSTextAlignmentLeft;
        lblMessageRetur.font = [UIFont fontWithName:CFont_Gotham_Book size:11.0f];
        lblMessageRetur.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
        lblMessageRetur.lineBreakMode = NSLineBreakByWordWrapping;
        lblMessageRetur.numberOfLines = 0;
        lblMessageRetur.backgroundColor = [UIColor clearColor];
        lblMessageRetur.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblMessageRetur.linkAttributes = @{
                           (id)kCTForegroundColorAttributeName:[
                                                                UIColor colorWithRed:10/255.0f
                                                                green:126/255.0f
                                                                blue:7/255.0f
                                                                alpha:1.0f],
                           NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        [viewRetur addSubview:lblMessageRetur];
    }
    
    
    float height = [((DetailProductViewController *)_delegate) calculateHeightLabelDesc:CGSizeMake(((DetailProductViewController *) _delegate).view.bounds.size.width-CPaddingTopDescToko-CPaddingTopDescToko, 9999) withText:strText withColor:[UIColor whiteColor] withFont:FONT_GOTHAM_BOOK_14 withAlignment:NSTextAlignmentLeft];
    
    lblMessageRetur.frame = CGRectMake(imgRetur.frame.origin.x+imgRetur.bounds.size.width+15,
                                   CPaddingTopDescToko,
                                   ([[UIScreen mainScreen] bounds].size.width-20)-(imgRetur.frame.origin.x+imgRetur.bounds.size.width) - 15,
                                   height);
    constraintHeightViewRetur.constant = (CPaddingTopDescToko*2)+height;
    
    [self setLblRetur:strText];
}

- (void)hiddenViewRetur
{
    constraintHeightViewRetur.constant = 0;
    [imgRetur removeConstraints:imgRetur.constraints];
    [imgRetur addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imgRetur(==0)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imgRetur)]];
}

- (void)setLblRetur:(NSString *)str
{
    lblMessageRetur.text = str;
}

- (TTTAttributedLabel *)getLblRetur
{
    return lblMessageRetur;
}
- (float)getHeightReturView
{
    return constraintHeightViewRetur.constant;
}
@end
