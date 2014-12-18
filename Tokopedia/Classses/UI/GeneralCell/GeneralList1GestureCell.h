//
//  GeneralList1GestureCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

#define kTKPDGENERALLIST1GESTURECELL_IDENTIFIER @"GeneralList1GeneralCellIdentifier"

@interface GeneralList1GestureCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labeldefault;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UIButton *buttondefault;
@property (weak, nonatomic) IBOutlet UILabel *labelvalue;

@property (nonatomic) NSInteger type;

+(id)newcell;
-(void)viewdetailresetposanimation:(BOOL)animated;
-(void)viewdetailshowanimation:(BOOL)animated;

@end
