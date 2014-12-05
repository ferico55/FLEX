//
//  SettingShipmentSectionFooterView.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingShipmentSectionFooterView.h"

@interface SettingShipmentSectionFooterView ()

@end

@implementation SettingShipmentSectionFooterView
{
    UITextField *_activetextfield;
}

#pragma mark - Factory Method
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

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updateView];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    double value = [_stepperminweight value];
    [_labelweightmin setText:[NSString stringWithFormat:@"%d", (int)value]];
    _viewminweight.hidden = (!_switchweightmin.on);
    _viewfee.hidden = (!_switchfee.on);
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
            [self updateViewMinWeight];
        }
        else if ((UISwitch*)sender == _switchfee) {
            [self updateViewFee];
        }
        //[self updateView];
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

-(void)adjustView:(UIView*)view1 withView:(UIView*)view2 isHidden:(BOOL)hidden
{
    CGRect frame = view1.frame;
    if(hidden)frame.origin.y -= view2.frame.size.height;
    else frame.origin.y += view2.frame.size.height;
    [view1 setFrame:frame];
}

-(void)updateView
{
    if(_viewminweightflag.hidden)
    {
        [self adjustView:_viewminweight withView:_viewminweightflag isHidden:YES];
        [self adjustView:_viewdiffcity withView:_viewminweightflag isHidden:YES];
        [self adjustView:_viewswitchfee withView:_viewminweightflag isHidden:YES];
        [self adjustView:_viewfee withView:_viewminweightflag isHidden:YES];
        [self adjustView:_viewinfo withView:_viewminweightflag isHidden:YES];
    }
//    else
//    {
//        [self adjustView:_viewminweight withView:_viewminweightflag isHidden:NO];
//        [self adjustView:_viewdiffcity withView:_viewminweightflag isHidden:NO];
//        [self adjustView:_viewswitchfee withView:_viewminweightflag isHidden:NO];
//        [self adjustView:_viewfee withView:_viewminweightflag isHidden:NO];
//        [self adjustView:_viewinfo withView:_viewminweightflag isHidden:NO];
//    }
    if(_viewminweight.hidden)
    {
        [self adjustView:_viewdiffcity withView:_viewminweight isHidden:YES];
        [self adjustView:_viewswitchfee withView:_viewminweight isHidden:YES];
        [self adjustView:_viewfee withView:_viewminweight isHidden:YES];
        [self adjustView:_viewinfo withView:_viewminweight isHidden:YES];
    }
//    else
//    {
//        [self adjustView:_viewdiffcity withView:_viewminweight isHidden:NO];
//        [self adjustView:_viewswitchfee withView:_viewminweight isHidden:NO];
//        [self adjustView:_viewfee withView:_viewminweight isHidden:NO];
//        [self adjustView:_viewinfo withView:_viewminweight isHidden:NO];
//    }
    if(_viewdiffcity.hidden)
    {
        [self adjustView:_viewswitchfee withView:_viewdiffcity isHidden:YES];
        [self adjustView:_viewfee withView:_viewdiffcity isHidden:YES];
        [self adjustView:_viewinfo withView:_viewdiffcity isHidden:YES];
    }
//    else
//    {
//        [self adjustView:_viewswitchfee withView:_viewdiffcity isHidden:NO];
//        [self adjustView:_viewfee withView:_viewdiffcity isHidden:NO];
//        [self adjustView:_viewinfo withView:_viewdiffcity isHidden:NO];
//    }
    if(_viewswitchfee.hidden)
    {
        [self adjustView:_viewfee withView:_viewswitchfee isHidden:YES];
        [self adjustView:_viewinfo withView:_viewswitchfee isHidden:YES];
    }
//    else
//    {
//        [self adjustView:_viewfee withView:_viewswitchfee isHidden:NO];
//        [self adjustView:_viewinfo withView:_viewswitchfee isHidden:NO];
//    }
    if(_viewfee.hidden)
    {
        [self adjustView:_viewinfo withView:_viewfee isHidden:YES];
    }
//    else
//    {
//        [self adjustView:_viewinfo withView:_viewfee isHidden:NO];
//    }
}

-(void)updateViewMinWeight
{
    _viewminweight.hidden = (!_switchweightmin.on);
    if (!_switchweightmin.on) {
        [self adjustView:_viewdiffcity withView:_viewminweight isHidden:YES];
        [self adjustView:_viewswitchfee withView:_viewminweight isHidden:YES];
        [self adjustView:_viewfee withView:_viewminweight isHidden:YES];
        [self adjustView:_viewinfo withView:_viewminweight isHidden:YES];
    }
    else
    {
        [self adjustView:_viewdiffcity withView:_viewminweight isHidden:NO];
        [self adjustView:_viewswitchfee withView:_viewminweight isHidden:NO];
        [self adjustView:_viewfee withView:_viewminweight isHidden:NO];
        [self adjustView:_viewinfo withView:_viewminweight isHidden:NO];
    }

}

-(void)updateViewFee
{
    _viewfee.hidden = (!_switchfee.on);
    if (!_switchfee.on) {
        [self adjustView:_viewinfo withView:_viewfee isHidden:YES];
    }
    else
    {
        [self adjustView:_viewinfo withView:_viewfee isHidden:NO];
    }
    
}

@end
