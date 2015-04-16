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
        [self addSubview:self.view];
        
        _buttonRetry.layer.cornerRadius = 3.0;
    }
    _buttonRetry.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _buttonRetry.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_buttonRetry setTitle:@"Terjadi kendala teknis \nMohon ulangi permintaan." forState:UIControlStateNormal];
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
