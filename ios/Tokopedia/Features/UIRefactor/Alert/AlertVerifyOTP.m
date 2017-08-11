//
//  AlertVerifyOTP.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertVerifyOTP.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@interface AlertVerifyOTP ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *positiveButton;

@end

@implementation AlertVerifyOTP

- (void)setText:(NSString *)text
{
    _text = text?:@"";
    _textLabel.text = _text;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2;
    _positiveButton.layer.cornerRadius = 2;
    

}

- (IBAction)didTapPositiveButton:(id)sender {
    [super dismissWithClickedButtonIndex:1 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:1];
        [self dismissindex:0 silent:NO animated:YES];
    }
}

@end
