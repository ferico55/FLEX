//
//  RejectReasonViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RejectReason.h"

@protocol RejectReasonDelegate <NSObject>
- (void) didChooseRejectReason:(RejectReason*)reason withExplanation:(NSString*)explanation;
@end

@interface RejectReasonViewController : UIViewController
@property (weak, nonatomic) id<RejectReasonDelegate> delegate;
@end
