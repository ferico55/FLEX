//
//  AlertInfoView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface AlertInfoView : TKPDAlertView

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *detailText;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@end
