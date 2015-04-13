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

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labeldefault;
@property (weak, nonatomic) IBOutlet UILabel *labelvalue;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic) NSInteger type;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
