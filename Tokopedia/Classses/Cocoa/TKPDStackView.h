//
//  TKPDStackView.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TKPDStackViewOrientation){
    TKPDStackViewOrientationLeftToRight,
    TKPDStackViewOrientationRightToLeft,
    TKPDStackViewOrientationTopToBottom,
    TKPDStackViewOrientationBottomToTop
};

@interface TKPDStackView : UIView
@property TKPDStackViewOrientation orientation;
@property (atomic) NSInteger counter;

-(void)pushView:(UIView*)view;
-(void)removeAllPushedView;
@end
