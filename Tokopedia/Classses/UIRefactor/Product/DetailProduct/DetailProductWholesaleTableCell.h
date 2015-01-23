//
//  DetailProductWholesaleTableCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/23/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDDETAILPRODUCTWHOLESALETABLECELLIDENTIFIER @"DetailProductWholesaleTableCellIdentifier"

@interface DetailProductWholesaleTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *price;

+(id)newcell;

@end
