#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JLContactsPermission.h"
#import "JLPermissionsCore+Internal.h"
#import "JLPermissionsCore.h"
#import "JLNotificationPermission.h"

FOUNDATION_EXPORT double JLPermissionsVersionNumber;
FOUNDATION_EXPORT const unsigned char JLPermissionsVersionString[];

