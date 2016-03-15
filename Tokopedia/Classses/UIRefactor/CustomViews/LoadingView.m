//
//  NoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
{

}


@end

@implementation LoadingView

#pragma mark - Initialization
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"LoadingView"
                                      owner:self
                                    options:nil];
        
        CGFloat width = ((UIViewController*)_delegate).view.frame.size.width;
        CGRect frame = self.view.frame;
        frame.size.width = width;
        self.view.frame = frame;
        self.frame = frame;
        [self addSubview:self.view];
        [self layoutIfNeeded];
        _buttonRetry.layer.cornerRadius = 3.0;
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

- (void)setNoResultText:(NSString*)string {
    [_buttonRetry setTitle:string forState:UIControlStateNormal];
}

- (IBAction)tapRetryButton:(id)sender {
    [_delegate pressRetryButton];
}


@end
