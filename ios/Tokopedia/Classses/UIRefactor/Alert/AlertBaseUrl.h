//
//  AlertReputation.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface AlertBaseUrl : TKPDAlertView {
    NSString *baseUrl;
}

@property (weak, nonatomic) IBOutlet UITextField *baseUrlText;
@property (weak, nonatomic) IBOutlet UIButton *swithButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;



@end
