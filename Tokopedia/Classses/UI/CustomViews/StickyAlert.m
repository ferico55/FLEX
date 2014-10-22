//
//  BackgroundLayer.m
//  Tokopedia
//
//  Created by Tokopedia on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "StickyAlert.h"

@interface StickyAlert()
{
    UIView *_view;
}

@end

@implementation StickyAlert

- (id)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
    
}



- (void) alertError:(NSArray*)errorArray{
    //error experimental
    UILabel* errorlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    NSString *joinedstring = [NSString convertHTML:[errorArray componentsJoinedByString:@"\n"]];
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [joinedstring sizeWithFont:errorlabel.font constrainedToSize:maximumLabelSize lineBreakMode:errorlabel.lineBreakMode];
    CGRect newFrame = errorlabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    errorlabel.frame = newFrame;
    
    errorlabel.backgroundColor = [UIColor grayColor];
    errorlabel.text = joinedstring;
    errorlabel.numberOfLines = 0;
    [_view addSubview: errorlabel];
    //end of error experimental
}

-(void) initView:(UIView*)view {
    _view = view;
}





@end