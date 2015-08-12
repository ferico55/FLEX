//
//  SplitReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 8/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SplitReputationVcProtocol
- (void)deallocVC;
@end


@interface SplitReputationViewController : UIViewController
@property (nonatomic, unsafe_unretained) UISplitViewController *splitViewController;
@property (nonatomic, unsafe_unretained) id<SplitReputationVcProtocol> del;
@end
