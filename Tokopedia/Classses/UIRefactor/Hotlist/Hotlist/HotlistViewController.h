//
//  HotlistViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTabHomeViewController.h"
#import "HotListCell.h"

@interface HotlistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HotlistCellDelegate>

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSDictionary *data;
@property (weak, nonatomic) id<TKPDTabHomeDelegate> delegate;

@end
