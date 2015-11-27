//
//  AlertView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertPhoneVerification.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@interface AlertPhoneVerification ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *positiveButton;
@property (weak, nonatomic) IBOutlet UIButton *negativeButton;

@end

@implementation AlertPhoneVerification

- (void)setText:(NSString *)text
{
    _text = text?:@"";
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    UIColor *color = [UIColor colorWithRed:66.0/255.0
                                     green:66.0/255.0
                                      blue:66.0/255.0
                                     alpha:1];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : font,
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : color
                                 };
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    _textLabel.attributedText = attributedText;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2;
    

}

- (IBAction)didTapPositiveButton:(id)sender {
    [super dismissWithClickedButtonIndex:1 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:1];
        [self dismissindex:0 silent:NO animated:YES];
    }
}

- (IBAction)didTapNegativeButton:(id)sender {
    [super dismissWithClickedButtonIndex:0 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:0];
        [self dismissindex:0 silent:NO animated:YES];
    }
}

@end
