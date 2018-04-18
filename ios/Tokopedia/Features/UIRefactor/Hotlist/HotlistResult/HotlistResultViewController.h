//
//  HotlistResultViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Hotlist Result View Controller
@interface HotlistResultViewController : GAITrackedViewController 


@property (weak, nonatomic) IBOutlet UIImage *image;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) ProductTracker *trackerObject;
@property (strong,nonatomic) NSString* redirectedSearchKeyword;
@property (nonatomic) BOOL isFromAutoComplete;
@property (nonatomic) BOOL hasAttribution;

@end
