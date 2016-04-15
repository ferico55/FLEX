//
//  StickyAlertView+NetworkErrorHandler.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "StickyAlertView+NetworkErrorHandler.h"

@implementation StickyAlertView (NetworkErrorHandler)

+ (StickyAlertView*)showNetworkError:(NSError *)error{
    
    NSArray *errors;
    
    if(error.code == -1011) {
        NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
        NSError *aerror = nil;
        NSDictionary *errorFromWs = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options: NSJSONReadingMutableContainers
                                                                      error: &aerror];
        if (errorFromWs && !aerror) {
            errors = [errorFromWs[@"errors"] valueForKeyPath:@"@distinctUnionOfObjects.title"];
        } else
            errors = @[@"Mohon maaf, terjadi kendala pada server"];
    } else if (error.code==-1009) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[error.localizedDescription];
    }
    
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errors delegate:[((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
    [alert show];
    
    return alert;
}

+ (StickyAlertView*)showSuccessMessage:(NSArray *)successMessage{
    
    StickyAlertView *alert = [[self alloc] initWithSuccessMessages:successMessage delegate:[((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
    [alert show];
    
    return alert;
}

+ (StickyAlertView*)showErrorMessage:(NSArray *)errorMessage{
    
    StickyAlertView *alert = [[self alloc] initWithErrorMessages:errorMessage delegate:[((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
    [alert show];
    
    return alert;
}
@end
