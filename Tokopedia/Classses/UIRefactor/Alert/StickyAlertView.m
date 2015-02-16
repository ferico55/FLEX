//
//  SticktAlertView.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "StickyAlertView.h"

@interface StickyAlertView ()

@property (nonatomic, retain) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end


@implementation StickyAlertView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"StickyAlertView"
                                      owner:self
                                    options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (id)initWithMessages:(NSArray *)messages textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor delegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.hidden = YES;

        self.view.backgroundColor = backgroundColor;
        [self attributedTextWithArray:messages color:textColor];
        
        CGRect frame = self.view.frame;
        frame.size.height = _textLabel.frame.size.height + 24;
        self.view.frame = frame;
    
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                          target:self
                                                        selector:@selector(timeout)
                                                        userInfo:nil
                                                         repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        [[(UIViewController *)delegate view] addSubview:self];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

-(id)initWithErrorMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [self initWithMessages:messages
                        textColor:[UIColor whiteColor]
                  backgroundColor:[UIColor colorWithRed:131.0/255.0 green:3.0/255.0 blue:0.0/255.0 alpha:1]
                         delegate:delegate];
    return self;
}

-(id)initWithSuccessMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [self initWithMessages:messages
                        textColor:[UIColor whiteColor]
                  backgroundColor:[UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1]
                         delegate:delegate];
    return self;
}

-(id)initWithLoadingMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [self initWithMessages:messages
                        textColor:[UIColor blackColor]
                  backgroundColor:[UIColor whiteColor]
                         delegate:delegate];
    return self;
}

- (void)show
{
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

- (void)timeout
{
    if (!_disableAutoDismiss) [self dismiss];
}

- (void)attributedTextWithArray:(NSArray *)texts color:(UIColor *)color
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : color,
                                 NSFontAttributeName            : _textLabel.font,
                                 NSParagraphStyleAttributeName  : style,
                                 };
    
    NSString *joinedString = @"";
    if ([texts count] > 1) {
        joinedString = [NSString stringWithFormat:@"\u25CF  %@\n", [[texts valueForKey:@"description"] componentsJoinedByString:@"\u25CF  \n"]];
    } else {
        joinedString = [texts objectAtIndex:0];
    }
    
    _textLabel.attributedText = [[NSAttributedString alloc] initWithString:joinedString attributes:attributes];
    _textLabel.numberOfLines = 0;
    [_textLabel sizeToFit];
}

@end
