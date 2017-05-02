//
//  TransactionShipmentATCTableViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/20/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionShipmentATCTableViewControllerDelegate <NSObject>

@optional

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectObject:(id)object;
- (void)viewController:(UITableViewController *)viewController didSelectObject:(id)object;

@end

@interface TransactionShipmentATCTableViewController : UITableViewController

@property (strong, nonatomic) id selectedObject;
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *objectImages;
@property (strong, nonatomic) id<TransactionShipmentATCTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *senderIndexPath;
@property UITableViewCellStyle tableViewCellStyle;

@end
