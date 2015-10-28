//
//  UIViewController+TKPAdditions.h
//  Tokopedia
//
//  Created by Harshad Dange on 18/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPAppFlow.h"

@interface UIViewController (TKPAdditions)

+ (id <TKPAppFlow>)TKP_rootController;

@end
