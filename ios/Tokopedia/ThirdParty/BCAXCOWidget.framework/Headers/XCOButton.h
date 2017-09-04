//
//  XCOButton.h
//  BCAXCOWidget
//
//  Created by PT Bank Central Asia Tbk on 9/13/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCOButton : UIButton

@property  (nonatomic, assign) CGFloat red;
@property  (nonatomic, assign) CGFloat green;
@property  (nonatomic, assign) CGFloat blue;
@property  (nonatomic) Boolean rounded;

- (void)activeButton;
- (void)inactiveButton;
- (void)cancelButton;
- (void)setTitleButton:(NSString *) string;

@end
