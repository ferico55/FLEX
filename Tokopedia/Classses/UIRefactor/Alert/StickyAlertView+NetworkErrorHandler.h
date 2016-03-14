//
//  StickyAlertView+NetworkErrorHandler.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "StickyAlertView.h"

@interface StickyAlertView (NetworkErrorHandler)

+ (StickyAlertView*)showNetworkError:(NSError *)error;
+ (StickyAlertView*)showSuccessMessage:(NSArray *)successMessage;
+ (StickyAlertView*)showErrorMessage:(NSArray *)errorMessage;

@end