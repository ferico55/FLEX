//
//  DetailCatalogSpecViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDDETAILCATALOGSPECVIEWCELLIDENTIFIER @"DetailCatalogSpecViewCellIdentifier"

#import <UIKit/UIKit.h>

@interface DetailCatalogSpecViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *specvallabel;
@property (weak, nonatomic) IBOutlet UILabel *speckeylabel;

+ (id)newcell;

@end
