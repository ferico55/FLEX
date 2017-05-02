//
//  ProgressBarView.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProgressBarView.h"

@interface ProgressBarView()
{
    UIImageView * _imageviewnonactive;
    UIImageView * _imageviewactive;
}

@end

#pragma mark - Progress Bar View
@implementation ProgressBarView

@synthesize floatcount =_floatcount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib
{
    _imageviewnonactive = [UIImageView new];
    _imageviewactive = [UIImageView new];
}

-(void)setFloatcount:(CGFloat)floatcount
{
    _floatcount = floatcount/100;
    
    float widthOfJaggedBit = 4.0f;
    UIImage * imagenonactive= [[UIImage imageNamed:@"icon_cart"] stretchableImageWithLeftCapWidth:widthOfJaggedBit topCapHeight:0.0f];
    UIImage * imageactive= [[UIImage imageNamed:@"icon_cart_active"] stretchableImageWithLeftCapWidth:widthOfJaggedBit topCapHeight:0.0f];
    
     CGRect frame =self.frame;
    
    _imageviewactive.frame = CGRectMake(0.0f, 0.0f, frame.size.width*_floatcount, frame.size.height);
    _imageviewnonactive.frame = CGRectMake(frame.size.width*_floatcount, 0.f, frame.size.width - (frame.size.width*_floatcount), frame.size.height);
    
    _imageviewactive.image = imageactive;
    _imageviewnonactive.image = imagenonactive;
    
    [self addSubview:_imageviewnonactive];
    [self addSubview:_imageviewactive];
    
//    frame.size.width = frame.size.width*_floatcount;
//    [_imageviewactive setFrame:frame];
//    
//    frame = self.frame;
//    frame.origin.x = frame.size.width*_floatcount;
//    frame.size.width =frame.size.width - (frame.size.width*_floatcount);
//    [_imageviewnonactive setFrame:frame];
//    
//    _imageviewactive.image = imageactive;
//    _imageviewnonactive.image = imagenonactive;
    
    // imageViewA.contentStretch = CGRectMake(widthOfJaggedBit, 0, imageA.size.width - 2*widthOfJaggedBit, imageA.size.height) ;
    // imageViewB.contentStretch = CGRectMake(widthOfJaggedBit, 0, imageB.size.width - 2*widthOfJaggedBit, imageB.size.height) ;
}


@end
