//
//  SettingShipmentSectionFooterView.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingShipmentSectionFooterView.h"

@interface SettingShipmentSectionFooterView ()

@property (weak, nonatomic) IBOutlet UIView *viewfee;
@property (weak, nonatomic) IBOutlet UIView *viewdiffcity;
@property (weak, nonatomic) IBOutlet UIView *viewminweight;
@property (weak, nonatomic) IBOutlet UIView *viewswitchfee;

@end

@implementation SettingShipmentSectionFooterView
{
    UITextField *_activetextfield;
}

#pragma mark - Factory Method
- (IBAction)switchoutsidecity:(id)sender {
}

+ (id)newview
{
	NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (id view in views) {
		if ([view isKindOfClass:[self class]]) {
			return view;
		}
	}
	return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    double value = [_stepperminweight value];
    [_labelweightmin setText:[NSString stringWithFormat:@"%d", (int)value]];
    //[self updateViewMinWeight];
    //[self updateViewFee];
}

#pragma mark - View Action
- (IBAction)valuechange:(UIStepper*)sender {
    [_activetextfield resignFirstResponder];
    double value = [sender value];
    
    [_labelweightmin setText:[NSString stringWithFormat:@"%d", (int)value]];
    [_delegate SettingShipmentSectionFooterView:self];
}

- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UISwitch class]]) {
        if ((UISwitch*)sender == _switchweightmin) {
            //[self updateViewMinWeight];
        }
        if ((UISwitch*)sender == _switchfee) {
            //[self updateViewFee];
        }
    }
    [_delegate SettingShipmentSectionFooterView:self];
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (gesture.view.tag == 10) {
                [_delegate MoveToInfoView:self];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Text View Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activetextfield = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    [_delegate SettingShipmentSectionFooterView:self];
    return (newLength > 4) ? NO : YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [_delegate SettingShipmentSectionFooterView:self];
    return YES;
}

#pragma mark - Methods

-(void)updateViewMinWeight
{
    _viewminweight.hidden = (!_switchweightmin.on);
    if (!_switchweightmin.on) {
        CGRect frame = _viewdiffcity.frame;
        frame.origin.y -= _viewminweight.frame.size.height;
        [_viewdiffcity setFrame:frame];
        frame = _viewswitchfee.frame;
        frame.origin.y -= _viewminweight.frame.size.height;
        [_viewswitchfee setFrame:frame];
        frame = _viewfee.frame;
        frame.origin.y -= _viewminweight.frame.size.height;
        [_viewfee setFrame:frame];
        frame = _viewinfo.frame;
        frame.origin.y -= _viewminweight.frame.size.height;
        [_viewinfo setFrame:frame];
    }
    else
    {
        CGRect frame = _viewdiffcity.frame;
        frame.origin.y += _viewminweight.frame.size.height;
        [_viewdiffcity setFrame:frame];
        frame = _viewswitchfee.frame;
        frame.origin.y += _viewminweight.frame.size.height;
        [_viewswitchfee setFrame:frame];
        frame = _viewfee.frame;
        frame.origin.y += _viewminweight.frame.size.height;
        [_viewfee setFrame:frame];
        frame = _viewinfo.frame;
        frame.origin.y += _viewminweight.frame.size.height;
        [_viewinfo setFrame:frame];
    }

}

-(void)updateViewFee
{
    _viewfee.hidden = (!_switchfee.on);
    if (!_switchfee.on) {
        CGRect frame = _viewinfo.frame;
        frame.origin.y -= _viewfee.frame.size.height;
        [_viewinfo setFrame:frame];
    }
    else
    {
        CGRect frame = _viewinfo.frame;
        frame.origin.y += _viewfee.frame.size.height;
        [_viewinfo setFrame:frame];
    }
    
}

@end
