//
//  PlacePickerViewController.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol PlacePickerDelegate <NSObject>

-(void)PickAddress:(GMSAddress*)address longitude:(double)longitude latitude:(double)latitude;

@end

@interface PlacePickerViewController : UIViewController

@property (weak, nonatomic) id<PlacePickerDelegate> delegate;

@property (nonatomic) CLLocationCoordinate2D firstCoordinate;

@end
