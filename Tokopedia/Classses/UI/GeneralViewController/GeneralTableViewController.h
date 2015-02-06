//
//  GeneralTableViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GeneralTableViewControllerDelegate <NSObject>

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath;

@end

@interface GeneralTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) id selectedObject;
@property (strong, nonatomic) NSIndexPath *senderIndexPath;
@property (weak, nonatomic) id<GeneralTableViewControllerDelegate> delegate;

@end