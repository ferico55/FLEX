//
//  FilterConditionViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterConditionViewController;

#pragma mark - Filter Condition View Controller Delegate
@protocol FilterConditionViewControllerDelegate <NSObject>
@required
-(void)FilterConditionViewController:(FilterConditionViewController*)viewcontroller withdata:(NSDictionary*)data;

@end

#pragma mark - Filter Condition View Controller
@interface FilterConditionViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<FilterConditionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *data;

@end