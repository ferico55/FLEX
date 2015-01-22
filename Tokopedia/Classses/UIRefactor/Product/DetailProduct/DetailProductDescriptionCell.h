//
//  DetailProductCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDDETAILPRODUCTCELLIDENTIFIER @"DetailProductDescriptionIdentifier"

@interface DetailProductDescriptionCell : UITableViewCell

@property (weak, nonatomic) NSString *descriptionText;
@property (weak, nonatomic) IBOutlet UILabel *descriptionlabel;

+(id)newcell;

@end
