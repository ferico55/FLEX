//
//  KatalogViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDKATALOGCELL_IDENTIFIER @"KatalogViewCell"

@interface KatalogViewCell : UITableViewCell

@property(strong,nonatomic)NSDictionary *data;

+(id)newcell;

@end
