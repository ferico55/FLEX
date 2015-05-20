//
//  NoResult.h
//  Tokopedia
//
//  Created by Tokopedia on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoResultView : UIView

@property (nonatomic, retain) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setNoResultText:(NSString*)string;


@end
