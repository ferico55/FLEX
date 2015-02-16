//
//  SortCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDSORTCELL_IDENTIFIER @"SortCellIdentifier"

#import <UIKit/UIKit.h>

@interface SortCell : UITableViewCell

@property (strong,nonatomic) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;


+(id)newcell;

@end
