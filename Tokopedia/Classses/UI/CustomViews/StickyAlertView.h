//
//  SticktAlertView.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickyAlertView : UIView

-(id)initWithErrorMessages:(NSArray *)messages delegate:(id)delegate;
-(id)initWithSuccessMessages:(NSArray *)messages delegate:(id)delegate;
-(id)initWithInfoMessages:(NSArray *)messages delegate:(id)delegate;
-(id)initWithLoadingMessage:(NSString *)message delegate:(id)delegate;

- (void)show;
- (void)dismiss;

@end
