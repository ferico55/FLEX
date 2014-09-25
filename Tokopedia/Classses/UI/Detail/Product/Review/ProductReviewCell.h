//
//  ProductReviewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StarsRateView.h"

#define kTKPDPRODUCTREVIEWCELLIDENTIFIER @"ProductReviewCellIdentifier"

#pragma mark - Product Review Cell
@interface ProductReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrate;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;
@property (weak, nonatomic) IBOutlet UIButton *commentbutton;

+(id)newcell;

@end
