//
//  UIApplication+React.h
//  Tokopedia
//
//  Created by Samuel Edwin on 5/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

@import UIKit;

@class RCTBridge;

@interface UIApplication(React)

@property(nonatomic, readonly) RCTBridge *reactBridge;

@end
