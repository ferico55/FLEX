//
//  RetryCollectionReusableView.m
//  Tokopedia
//
//  Created by Tonito Acen on 5/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RetryCollectionReusableView.h"

@implementation RetryCollectionReusableView

- (void)awakeFromNib {
    // Initialization code
}


- (IBAction)tapRetryButton:(id)sender {
    [_delegate pressRetryButton];
}

@end
