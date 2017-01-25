//
//  InboxResolutionCenterTabViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResolutionWebViewController;

@interface InboxResolutionCenterTabViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceButtons;
@property (strong, nonatomic)UIViewController *splitVC;
@property (strong, nonatomic)ResolutionWebViewController *detailViewController;

-(instancetype)initWithSelectedIndex:(int)index;

@end
