//
//  PlacePickerViewController.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

typedef enum{
    TypeEditPlace,
    TypeShowPlace
}TypePlacePicker;

@protocol PlacePickerDelegate <NSObject>

-(void)PickAddress:(GMSAddress*)address suggestion:(NSString*)suggestion longitude:(double)longitude latitude:(double)latitude map:(UIImage *)map;

@end

@interface PlacePickerViewController : UIViewController

@property (weak, nonatomic) id<PlacePickerDelegate> delegate;

@property NSInteger type;
@property (nonatomic) CLLocationCoordinate2D firstCoordinate;

+(void)focusMap:(GMSMapView*)mapView toMarker:(GMSMarker*)marker;
+ (UIImage *)captureScreen:(GMSMapView *)mapView;

@end
