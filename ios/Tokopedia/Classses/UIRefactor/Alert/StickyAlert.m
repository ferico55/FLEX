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
    CGRect frame = _view.superview.frame;

    UILabel* errorlabel = [[UILabel alloc]initWithFrame:frame];
    NSString *joinedstring = [NSString stringWithFormat:@"\n  \u25CF  %@", [[errorArray valueForKey:@"description"] componentsJoinedByString:@"\n  \u25CF  "]];
    //[NSString convertHTML:[errorArray componentsJoinedByString:@"\n"]];
    
    UIFont *font = [UIFont microTheme];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:joinedstring
                                                                                    attributes:attributes];
    
    errorlabel.attributedText = productNameAttributedText;
    
    for (UIView *subview in [_view subviews]) {
        if (subview.tag == 1 || subview.tag == 17) {
            [subview removeFromSuperview];
        }
    }
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [joinedstring sizeWithFont:errorlabel.font constrainedToSize:maximumLabelSize lineBreakMode:errorlabel.lineBreakMode];
    expectedLabelSize.height += style.lineSpacing *errorArray.count;
    CGRect newFrame = errorlabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.origin.x = 5.0f;
    newFrame.origin.y -= 3.0f;
    errorlabel.frame = newFrame;
    errorlabel.tag = 1;
    //errorlabel.text = joinedstring;
    errorlabel.textColor = [UIColor whiteColor];
    errorlabel.numberOfLines = 0;
    
    frame.origin.y = 64; //TODO:: navigationbar height
    frame.size.height = expectedLabelSize.height + 10;
    bg = [[UIView alloc]initWithFrame:frame];
    bg.backgroundColor = [UIColor colorWithRed:(131/255.0) green:(3/255.0) blue:(0/255.0) alpha:1];
    bg.tag = 1;
    [bg addSubview:errorlabel];
    
    //NSInteger originXCloseButton = _view.frame.size.width- 30;
    //UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(originXCloseButton, 65, 30, 30)];
    //[closeButton setBackgroundImage:[UIImage imageNamed:@"icon_cancel.png"] forState:UIControlStateNormal];
    //[closeButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    //closeButton.tag = 17;
    //closeButton.backgroundColor = [UIColor greenColor];   
    
    if([errorArray count] != 0 || ![[errorArray firstObject] isEqual:kTKPDNETWORK_ERRORDESCS]) {
        [_view addSubview: bg];
        //[_view addSubview: closeButton];
        
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
}

-(void) initView:(UIView*)view {
    _view = view;
}





@end