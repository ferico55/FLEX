//
//  GeneralList1GestureCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

#define kTKPDGENERALLIST1GESTURECELL_IDENTIFIER @"GeneralListCellIdentifier"

@interface GeneralList1GestureCell : MGSwipeTableCell

@property (nonatomic) NSInteger type;
@property (strong, nonatomic) NSIndexPath *indexpath;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cellLableLeadingConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *iconPinPoint;


+(id)newcell;

@end
