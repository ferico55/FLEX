//
//  DetailProductWholesaleCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDDETAILPRODUCTWHOLESALECELLIDENTIFIER @"DetailProductWholesaleIdentifier"

@interface DetailProductWholesaleCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *data;

+(id)newcell;

@end
