//
//  NSArray+TKPGooglePlacesAutocompleteUtilities.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#define kGoogleAPIKey @"YOUR_API_KEY"
#define kGoogleAPINSErrorCode 42

#import <Foundation/Foundation.h>

@class CLPlacemark;

typedef enum {
    SPPlaceTypeGeocode = 0,
    SPPlaceTypeEstablishment
} SPGooglePlacesAutocompletePlaceType;

typedef void (^SPGooglePlacesPlacemarkResultBlock)(CLPlacemark *placemark, NSString *addressString, NSError *error);
typedef void (^SPGooglePlacesAutocompleteResultBlock)(NSArray *places, NSError *error);
typedef void (^SPGooglePlacesPlaceDetailResultBlock)(NSDictionary *placeDictionary, NSError *error);

extern SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary);
extern NSString *SPBooleanStringForBool(BOOL boolean);
extern NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type);
extern BOOL SPEnsureGoogleAPIKey();
extern void SPPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title);
extern BOOL SPIsEmptyString(NSString *string);

@interface NSArray (TKPGooglePlacesAutocompleteUtilities)

@end
