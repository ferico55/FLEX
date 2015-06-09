//
//  TKPDAlertView.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark TKPDAlertViewDelegate

@class TKPDAlertView;

@protocol TKPDAlertViewDelegate <NSObject>
@optional
- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertViewCancel:(TKPDAlertView *)alertView;

- (void)willPresentAlertView:(TKPDAlertView *)alertView;
- (void)didPresentAlertView:(TKPDAlertView *)alertView;

- (void)alertView:(TKPDAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(TKPDAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end

#pragma mark -
#pragma mark TKPDAlertView

@interface TKPDAlertView : UIView {
    //#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
    //	id<TKPDAlertViewDelegate> __weak _delegate;
    //#else
    //	id<TKPDAlertViewDelegate> _delegate;
    //#endif
	NSDictionary* _data;
	
    //	NSArray* _buttons;
	UIWindow* _window;
	UIView* _background;
	UITapGestureRecognizer* _gesture;
}


@property (nonatomic, weak) IBOutlet id<TKPDAlertViewDelegate> delegate;
@property (nonatomic, strong, setter = setData:) NSDictionary* data;

+ (id)newview;
- (void)reset;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end