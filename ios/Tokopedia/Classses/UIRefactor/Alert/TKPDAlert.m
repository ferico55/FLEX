//
//  AlertView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlert.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@interface TKPDAlert ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation TKPDAlert

- (void)awakeFromNib {
    [super awakeFromNib];
    self.button.layer.cornerRadius = 5;
}

- (void)setText:(NSString *)text
{
    _text = text?:@"";
    _textLabel.text = _text;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;

}

- (IBAction)didTapLoginButton:(UIButton *)sender {
    if (_didTapActionButton) {
        _didTapActionButton();
    }
    
    [super dismissWithClickedButtonIndex:0 animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:0];
        [self dismissindex:0 silent:NO animated:YES];
    }
}

@end
