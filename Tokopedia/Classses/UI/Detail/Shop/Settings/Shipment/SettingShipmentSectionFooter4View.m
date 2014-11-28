//
//  SettingShipmentSectionFooter4View.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingShipmentSectionFooter4View.h"

@interface SettingShipmentSectionFooter4View ()

@property (weak, nonatomic) IBOutlet UIView *viewfee;
@property (weak, nonatomic) IBOutlet UIView *viewminweight;
@property (weak, nonatomic) IBOutlet UIView *viewswitchfee;

@end

@implementation SettingShipmentSectionFooter4View
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

-(void)awakeFromNib
{
    [super awakeFromNib];
    //[self updateViewFee];
}

#pragma mark - View Action

- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UISwitch class]]) {
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


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [_delegate SettingShipmentSectionFooterView:self];
    return YES;
}

#pragma mark - Methods

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
