//
//  SwipeMenuViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeMenuViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UINavigationController *navcon;

-(void)AdjustViewControllers:(NSArray*)viewcontrollers withtitles:(NSArray*)titles;
+(id)newView;

@end
