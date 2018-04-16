//
//  DepositViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 2/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepositSummaryViewController : GAITrackedViewController {
    IBOutlet NSLayoutConstraint *constraintHeightHeader, *constraintHeightSuperHeader;
}

@property (strong, nonatomic) NSDictionary *data;

@end
