//
//  AlertDatePickerView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "AlertDatePickerView.h"

#pragma mark -
#pragma mark TKPDAlertView category

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@interface AlertDatePickerView ()
{
    NSInteger _type;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datepicker;

@end

@implementation AlertDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{


}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        //done button
        NSDate *pickerDate = [_datepicker date];
        NSLog(@"%@",pickerDate);
        _data = @{kTKPDALERTVIEW_DATADATEPICKERKEY:pickerDate};
        UIButton *doneButton = (UIButton*)sender;
        [self dismissWithClickedButtonIndex:doneButton.tag animated:YES];
    }
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
    
    _type = [[_data objectForKey:kTKPDALERTVIEW_DATATYPEKEY]integerValue];
    switch (_type) {
        case kTKPDALERT_DATAALERTTYPESHOPEDITKEY:
        {
            NSDateComponents* deltaComps = [NSDateComponents new];
            [deltaComps setDay:1];
            NSDate* tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:[NSDate date] options:0];
            _datepicker.minimumDate = tomorrow;
            [deltaComps setDay:7];
            NSDate* nextweek = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:[NSDate date] options:0];
            [_datepicker setDate:nextweek];
            break;
        }
        default:
        {
            _datepicker.maximumDate = [NSDate date];
            break;
        }
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

#pragma mark - Properties
-(void)setCurrentdate:(NSDate *)currentdate
{
    _currentdate = currentdate;
    
    if (currentdate) {
        _datepicker.date = _currentdate;
    }
}

@end
