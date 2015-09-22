//
//  NoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NoResultView.h"

@implementation NoResultView

#pragma mark - Initialization

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NoResultView"
                                      owner:self
                                    options:nil];
        [self.view setFrame:CGRectMake(0, 0, frame.size.width?:[[UIScreen mainScreen]bounds].size.width, 200)];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setNoResultText:(NSString*)string {
    [_titleLabel setText:string];
}


@end
