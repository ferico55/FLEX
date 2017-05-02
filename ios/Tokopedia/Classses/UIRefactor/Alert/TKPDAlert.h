//
//  AlertView.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface TKPDAlert : TKPDAlertView

@property (strong, nonatomic) NSString *text;
@property (copy, nonatomic) void(^didTapActionButton)();

@end
