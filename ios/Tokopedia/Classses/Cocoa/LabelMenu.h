//
//  LabelMenu.h
//  Tokopedia
//
//  Created by Tokopedia on 6/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LabelMenuDelegate
- (void)duplicate:(int)tag;
@end


@interface LabelMenu : UILabel

@property (nonatomic, unsafe_unretained) id<LabelMenuDelegate> delegate;
@end
