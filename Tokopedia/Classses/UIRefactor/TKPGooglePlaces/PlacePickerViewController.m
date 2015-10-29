//
//  PlacePickerViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "PlacePickerViewController.h"

@interface PlacePickerViewController () <UITextViewDelegate>

@end

@implementation PlacePickerViewController
{
    GMSPlacePicker *_placePicker;
}

- (instancetype)init {
    if ((self = [super init])) {
        CLLocationCoordinate2D southWestSydney = CLLocationCoordinate2DMake(-6.211544, 106.845172);
        CLLocationCoordinate2D northEastSydney = CLLocationCoordinate2DMake(-6.211544, 106.845172);
        GMSCoordinateBounds *sydneyBounds =
        [[GMSCoordinateBounds alloc] initWithCoordinate:southWestSydney coordinate:northEastSydney];
        GMSPlacePickerConfig *config =
        [[GMSPlacePickerConfig alloc] initWithViewport:sydneyBounds];
        _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.delegate = self;
    textView.editable = NO;
    [self.view addSubview:textView];
    __weak UITextView *weakResultView = textView;
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        UITextView *resultView = weakResultView;
        if (resultView == nil) {
            return;
        }
        if (place) {
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc] initWithString:[place description]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [text appendAttributedString:place.attributions];
            resultView.attributedText = text;
        } else if (error) {
            resultView.text =
            [NSString stringWithFormat:@"Place picking failed with error: %@", error];
        } else {
            resultView.text = @"Place picking cancelled.";
        }
    }];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)url
         inRange:(NSRange)characterRange {
    // Make links clickable.
    return YES;
}

@end
