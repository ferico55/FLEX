//
//  SticktAlertView.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickyAlertView : UIView

@property BOOL disableAutoDismiss;

-(id)initWithErrorMessages:(NSArray *)messages delegate:(id)delegate;
-(id)initWithSuccessMessages:(NSArray *)messages delegate:(id)delegate;
-(id)initWithLoadingMessages:(NSArray *)messages delegate:(id)delegate;
- (id)initWithWarningMessages:(NSArray*)messages delegate:(id)delegate;

- (void)show;
- (void)dismiss;

@end
