//
//  CartCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "string_transaction.h"
#import "TransactionCart.h"
#import "GeneralSwitchCell.h"
#import "TransactionCartCell.h"

@interface CartCell : NSObject

+(UITableViewCell*)cellDetailShipmentTable:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;

+(UITableViewCell*)cellPartialDetail:(NSArray*)partialDetail partialStrList:(NSArray*)partialStrList tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath;

+(UITableViewCell*)cellTextFieldPlaceholder:(NSString*)placeholder List:(NSArray<TransactionCartList *>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath withText:(NSString*)text
;

+(UITableViewCell*)cellIsDropshipper:(NSArray*)isDropshipper tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath;
+
(UITableViewCell*)cellCart:(NSArray<TransactionCartList*>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath page:(NSInteger)page;

+(UITableViewCell *)cellErrorList:(NSArray<TransactionCartList*>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;

@end
