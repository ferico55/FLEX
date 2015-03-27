//
//  AlertView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertView.h"

@interface AlertView ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation AlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AlertView"
                                      owner:self
                                    options:nil];
        
        _button.layer.cornerRadius = 2;
        
        [self addSubview:self.window];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8.0;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:13],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:66.0/255.0
                                                                                      green:66.0/255.0
                                                                                       blue:66.0/255.0
                                                                                      alpha:1],
                                     };
        
        _textLabel.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:attributes];        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.window];
}

- (IBAction)tap:(id)sender {
    [self.delegate alertViewDismissed:self];
}

- (void)show
{
    self.layer.opacity = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.opacity = 1;
    } completion:^(BOOL finished) {
        [[(UIViewController *)_delegate view] addSubview:self];
    }];
}

- (void)dismiss
{
    CGRect frame = self.contentView.frame;
    frame.origin.y -= 100;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = frame;
        self.contentView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
