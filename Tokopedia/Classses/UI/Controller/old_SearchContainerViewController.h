//
//  SearchContainerViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultViewController.h"

@interface SearchContainerViewController : UIViewController

@property (strong,nonatomic)NSArray *viewcontrollers;
-(void)setContainerViewControllers:(NSArray*)viewControllers;

@end
