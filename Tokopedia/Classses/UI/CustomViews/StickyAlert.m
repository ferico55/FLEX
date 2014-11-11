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
    NSTimer *timer;
    UIView *bg;
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
    //TODO :: Need To Rework, Really Ugly because only placed using Y position
    UILabel* errorlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    NSString *joinedstring = [NSString convertHTML:[errorArray componentsJoinedByString:@"\n"]];
    
    for (UIView *subview in [_view subviews]) {
        if (subview.tag == 1 || subview.tag == 17) {
            [subview removeFromSuperview];
        }
    }
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [joinedstring sizeWithFont:errorlabel.font constrainedToSize:maximumLabelSize lineBreakMode:errorlabel.lineBreakMode];
    CGRect newFrame = errorlabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.origin.x = 5.0f;
    newFrame.origin.y = 3.0f;
    errorlabel.frame = newFrame;
    errorlabel.tag = 1;
    errorlabel.text = joinedstring;
    errorlabel.font = [UIFont fontWithName:@"GothamMedium" size:13.0f];
    errorlabel.textColor = [UIColor whiteColor];
    errorlabel.numberOfLines = 0;
    
    bg = [[UIView alloc]initWithFrame:CGRectMake(0, 63, 320, 110)];
    bg.backgroundColor = [UIColor colorWithRed:(131/255.0) green:(3/255.0) blue:(0/255.0) alpha:1];
    CGRect newFrameBg = bg.frame;
    newFrameBg.size.height = expectedLabelSize.height + 6;
    bg.frame = newFrameBg;
    bg.tag = 1;
    [bg addSubview:errorlabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(300, 65, 15, 15)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"icon_cancel.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.tag = 17;
//    closeButton.backgroundColor = [UIColor greenColor];   
    
    if([errorArray count] != 0) {
        [_view addSubview: bg];
        [_view addSubview: closeButton];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_STICKYFADEOUTINTERVAL target:self selector:@selector(tap:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    
}

- (void) alertSuccess :(NSArray*)errorArray{
    [self alertError:errorArray];
    bg.backgroundColor = [UIColor colorWithRed:(10/255.0) green:(126/255.0) blue:(7/255.0) alpha:1];
}


#pragma mark - View Action
-(void)tap:(id)sender {
    NSLog(@"button was clicked");
    
    for (UIView *subview in [_view subviews]) {
        if (subview.tag == 1 || subview.tag == 17) {
            [subview removeFromSuperview];
        }
    }
    
    [timer invalidate];
    timer = nil;
    
}

-(void) initView:(UIView*)view {
    _view = view;
}





@end