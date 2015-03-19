//
//  CategoryMenuViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER @"CategoryResultViewCellIdentifier"

@interface CategoryMenuViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UIImageView *imagenext;

+(id)newcell;

@end
