//
//  BarCodeViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 6/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BarCodeDelegate
- (void)didFinishScan:(NSString *)strResult;
@end


@interface BarCodeViewController : UIViewController
@property (nonatomic, unsafe_unretained) id<BarCodeDelegate> delegate;
@end
