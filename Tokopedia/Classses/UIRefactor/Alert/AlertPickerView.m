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
{
    NSInteger index;
    NSInteger secondIndex;
    __weak IBOutlet UIPickerView *pickerView;
}

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

- (IBAction)gesture:(UITapGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            UIView* view = [_window.subviews lastObject];
            if (self == view) {
                [self dismissWithClickedButtonIndex:-1 animated:YES];
            }
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - Picker Data Source
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_pickerCount==0) {
        _pickerCount = 1;
    }
    return _pickerCount;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int datacount = 0;
    if (component == 0) {
        datacount = (int)_pickerData.count;
    }
    if (component == 1) {
        datacount = (int)_secondPickerData.count;
    }
    return datacount;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *dataname = [_pickerData[row] objectForKey:DATA_NAME_KEY];
    if (component == 0) {
        dataname = [_pickerData[row] objectForKey:DATA_NAME_KEY];
    }
    if (component == 1) {
        dataname = [_secondPickerData[row] objectForKey:DATA_NAME_KEY];
    }
    return dataname;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (!label)
    {
        label = [[UILabel alloc] init];
        label.font = [UIFont title1Theme];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
    }

    if (component == 0) {
        label.text = [NSString stringWithFormat:@"%@",[_pickerData[row] objectForKey:DATA_NAME_KEY]];
    }
    if (component == 1) {
        label.text = [NSString stringWithFormat:@"%@",[_secondPickerData[row] objectForKey:DATA_NAME_KEY]];
    }
    
    return label;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if (component == 0) {
        index = row;
    }
    if (component == 1) {
        secondIndex = row;
    }
    _data = @{DATA_INDEX_KEY:@(index),DATA_INDEX_SECOND_KEY:@(secondIndex)};
}

#pragma mark - Methods
- (void)show
{
    [super show];
    
	id<TKPDAlertViewDelegate> _delegate = self.delegate;
	
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

    self.frame = CGRectMake(0, self.frame.origin.y, _window.bounds.size.width, self.bounds.size.height);
	[_window addSubview:self];	//from animation block below
	[_window makeKeyAndVisible];
	
	[UIView transitionWithView:_window duration:0.5 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowAnimatedContent) animations:^{
		
		//[_window addSubview:self];	//moved before animation call above
		self.center = selfcenter;
		
	} completion:^(BOOL finished) {
		
		if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(didPresentAlertView:)])) {
			[_delegate didPresentAlertView:self];
		}
	}];
    
    index = [[_data objectForKey:DATA_INDEX_KEY] integerValue];
    secondIndex = [[_data objectForKey:DATA_INDEX_SECOND_KEY] integerValue];
    
    [pickerView selectRow:index inComponent:0 animated:NO];
    if (_pickerCount==2) {
        [pickerView selectRow:secondIndex?:0 inComponent:1 animated:NO];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

@end
