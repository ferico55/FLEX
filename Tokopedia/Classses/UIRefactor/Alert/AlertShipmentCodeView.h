//
//  AlertShipmentCodeView.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface AlertShipmentCodeView : TKPDAlertView

@property (strong, nonatomic) NSString *text;

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end
