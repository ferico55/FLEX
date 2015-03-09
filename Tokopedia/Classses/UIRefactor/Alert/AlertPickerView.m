//
//  AlertPickerView.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AlertPickerView.h"

#pragma mark -
#pragma mark TKPDAlertView category

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@implementation AlertPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *doneButton = (UIButton*)sender;
        [self dismissWithClickedButtonIndex:doneButton.tag animated:YES];
    }
}

#pragma mark - Picker Data Source
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int datacount = (int)_pickerData.count;
    return datacount;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *dataname = [_pickerData[row] objectForKey:DATA_NAME_KEY];
    return dataname;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (!label)
    {
        label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"GothamBook" size:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
    }

    label.text=[_pickerData[row] objectForKey:DATA_NAME_KEY];
    return label;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    _data = @{DATA_INDEX_KEY:@(row)};
}

#pragma mark - Methods
- (void)show
{
	id<TKPDAlertViewDelegate> _delegate = self.delegate;
	
    [_gesture removeTarget:self action:@selector(gesture:)];
    [_gesture addTarget:self action:@selector(gesture:)];
	
	if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(willPresentAlertView:)])) {
		[_delegate willPresentAlertView:self];
	}
	
    _doneButton.layer.cornerRadius = 2;

	CGPoint windowcenter = _window.center;
	CGRect windowbounds = _window.bounds;
	CGSize windowsize = windowbounds.size;
	CGPoint selfcenter = windowcenter;
	CGRect selfbounds = self.bounds;
	CGSize selfsize = selfbounds.size;
	CGPoint hidecenter;
	
	CGFloat delta = windowsize.height - (selfsize.height / 2.0f);
	selfcenter.y = delta;
	
	hidecenter = selfcenter;
	hidecenter.y += selfsize.height;
	
	self.center = hidecenter;
	self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	if (_background.superview == nil) {	//fix dismiss - show race condition
		[_window addSubview:_background];
	}
	[_window addSubview:self];	//from animation block below
	[_window makeKeyAndVisible];
	
	[UIView transitionWithView:_window duration:TKPD_FADEANIMATIONDURATION options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowAnimatedContent) animations:^{
		
		//[_window addSubview:self];	//moved before animation call above
		self.center = selfcenter;
		
	} completion:^(BOOL finished) {
		
		if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(didPresentAlertView:)])) {
			[_delegate didPresentAlertView:self];
		}
	}];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

@end
