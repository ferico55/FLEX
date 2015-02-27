//
//  NoResult.m
//  Tokopedia
//
//  Created by Tokopedia on 1/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NoResult.h"

@interface NoResult ()
{

}

@property (strong, nonatomic) IBOutlet UILabel *noResultLabel;

@end

@implementation NoResult

#pragma mark - Initialization
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"NoResult"
                                      owner:self
                                    options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

- (void)setNoResultText:(NSString*)string {
    [_noResultLabel setText:string];
}


@end
