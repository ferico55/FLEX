//
//  HotlistViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotListCell.h"
#import "GAITrackedViewController.h"

@interface HotlistViewController : GAITrackedViewController <HotlistCellDelegate>

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSDictionary *data;

- (void) scrollToTop;

@end
