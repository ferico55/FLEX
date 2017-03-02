//
//  TKPDAlertView.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "TKPDAlertView.h"

#pragma mark -
#pragma mark JYAlertView

@interface TKPDAlertView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)tap:(UIButton *)sender;
- (IBAction)gesture:(UITapGestureRecognizer *)sender;

- (void)createwindow;
- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@implementation TKPDAlertView

@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize buttons = _buttons;

#pragma mark -
#pragma mark Factory methods

+ (id)newview
{
    NSString *className = NSStringFromClass([self class]);
    if ([className rangeOfString:@"."].location != NSNotFound) {
        className = [[className componentsSeparatedByString:@"."] lastObject];
    }
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil];
	for (id view in views) {
		if ([view isKindOfClass:[self class]]) {
			[view createwindow];
			[view setButtons:[NSArray sortViewsWithTagInArray:[view buttons]]];
			return view;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark Initializations

- (id)init
{
	//self get released
	return [[self class] newview];
}

-(instancetype)initWithFrame:(CGRect)frame{
    return [[self class] newview];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [super initWithCoder:aDecoder];
}

#pragma mark - View lifecycle

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//	[super willMoveToSuperview];
//	if (newSuperview != nil) {
//		//
//	}
//}
//
//- (void)didMoveToSuperview {
//	[super didMoveToSuperview];
//	if (self.superview == nil) {
//		[self reset];
//	}
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark Memory management

//#ifdef _DEBUG
- (void)dealloc
{
	NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
	
	[_gesture removeTarget:self action:@selector(gesture:)];
}
//#endif

#pragma mark -
#pragma mark View actions

- (IBAction)tap:(UIButton *)sender
{
	[self dismissindex:(sender.tag - 10) silent:NO animated:YES];
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
				[self dismissindex:-1 silent:NO animated:YES];	//cancel
			}
			break;
		}
		default: {
			break;
		}
	}
}

#pragma mark -
#pragma mark Methods

- (void)show
{
	[_gesture removeTarget:self action:@selector(gesture:)];
	[_gesture addTarget:self action:@selector(gesture:)];
	
	if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(willPresentAlertView:)])) {
		[_delegate willPresentAlertView:self];
	}
    
    [_window setFrame:[[UIScreen mainScreen] bounds]];
    [_background setFrame:_window.frame];
	
	self.center = _window.center;
    
	self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	[UIView transitionWithView:_window duration:TKPD_FADEANIMATIONDURATION options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
		
		[_window addSubview:self];
		
	} completion:^(BOOL finished) {
		
		if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(didPresentAlertView:)])) {
			[_delegate didPresentAlertView:self];
		}
	}];
}

- (void)createwindow
{
	static UIWindow* window = nil;
	static UIView* background = nil;
	static UITapGestureRecognizer* gesture = nil;
    static dispatch_once_t once;
	
    dispatch_once(&once, ^{
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.tag = 99;
		window.windowLevel = UIWindowLevelAlert - 1.0f;
		window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		background = [[UIView alloc] initWithFrame:window.bounds];
		background.backgroundColor = [UIColor blackColor];
		background.alpha = 0.5f;
		background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		gesture = [UITapGestureRecognizer new];
		background.gestureRecognizers = @[gesture];
		
		[window addSubview:background];
    });
	
	[window makeKeyAndVisible];
	
	_window = window;
	_background = background;
	_gesture = gesture;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	if ((buttonIndex < _buttons.count) && (self.superview != nil)) {
		[self dismissindex:buttonIndex silent:YES animated:animated];
	}
}

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated
{
	if (!silent) {
		if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])) {
			[_delegate alertView:self willDismissWithButtonIndex:index];
		}
	}
	
	NSArray* windows = [UIApplication sharedApplication].windows;
	for (UIWindow* window in windows) {
		if (window != _window) {	//more than two???
			
			if (animated) {
				[UIView transitionWithView:_window duration:TKPD_FADEANIMATIONDURATION options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
					
					if ((self.superview != nil)) {
						if (_window.subviews.count < 3) {
							[_background removeFromSuperview];
						}
						[self removeFromSuperview];
						
						[_gesture removeTarget:self action:@selector(gesture:)];
					}
					
				} completion:^(BOOL finished) {
					
					if (_background.superview == nil) {
						[window makeKeyAndVisible];
						_window.hidden = YES;
						
						[_window addSubview:_background];
					}
					
					if (!silent) {
						
						if (index >= 0) {
							if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])) {
								[_delegate alertView:self clickedButtonAtIndex:index];
							}
							
						} else {
							if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertViewCancel:)])) {
								[_delegate alertViewCancel:self];
							}
						}
						
						if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])) {
							[_delegate alertView:self didDismissWithButtonIndex:index];
						}
					}
				}];
				
			} else {
				if ((self.superview != nil)) {
					if (_window.subviews.count < 3) {
						[_background removeFromSuperview];
					}
					[self removeFromSuperview];
					
					[_gesture removeTarget:self action:@selector(gesture:)];
				}
				
				if (_background.superview == nil) {
					[window makeKeyAndVisible];
					_window.hidden = YES;
					
					[_window addSubview:_background];
				}
				
				if (!silent) {
					
					if (index >= 0) {
						if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])) {
							[_delegate alertView:self clickedButtonAtIndex:index];
						}
						
					} else {
						if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertViewCancel:)])) {
							[_delegate alertViewCancel:self];
						}
					}
					
					if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])) {
						[_delegate alertView:self didDismissWithButtonIndex:index];
					}
				}
			}
			
			break;
		}
	}
}

- (void)reset
{
	self.data = nil;
}

@end
