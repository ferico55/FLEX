//
//  SticktAlertView.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "StickyAlertView.h"

@interface StickyAlertView () {
    id _delegate;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation StickyAlertView

- (id)initWithFrame:(CGRect)frame
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
        _delegate = delegate;
        
        self.view.backgroundColor = backgroundColor;
        self.view.accessibilityIdentifier = @"errorStickyAlert";
        [self attributedTextWithArray:messages color:textColor];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                          target:self
                                                        selector:@selector(timeout)
                                                        userInfo:nil
                                                         repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        [[[(UIViewController *)delegate view] window] addSubview:self];
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
                  backgroundColor:[UIColor colorWithRed:255.0/255.0
                                                  green:59.0/255.0
                                                   blue:48.0/255.0
                                                  alpha:1]
                         delegate:delegate];
    return self;
}

- (id)initWithWarningMessages:(NSArray*)messages delegate:(id)delegate {
    self = [self initWithMessages:messages
                        textColor:[UIColor blackColor]
                  backgroundColor:[UIColor colorWithRed:255.0/255.0
                                                  green:204.0/255.0
                                                   blue:102.0/255.0
                                                  alpha:1]
                         delegate:delegate];
    return self;
}


-(id)initWithSuccessMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [self initWithMessages:messages
                        textColor:[UIColor whiteColor]
                  backgroundColor:[UIColor colorWithRed:10.0/255.0
                                                  green:126.0/255.0
                                                   blue:7.0/255.0
                                                  alpha:1]
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
    style.lineSpacing = 3.0;
    
    NSDictionary *dict = @{
        NSForegroundColorAttributeName : color,
        NSFontAttributeName            : _textLabel.font,
        NSParagraphStyleAttributeName  : style,
    };

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    NSString *joinedString = @"";
    if ([texts count] > 1) {
        joinedString = [NSString stringWithFormat:@"\u25CF %@", [[texts valueForKey:@"description"] componentsJoinedByString:@"\n\u25CF "]];
    } else if ([texts count] == 1){
        joinedString = [texts objectAtIndex:0]?:@"";
    } else {
        joinedString = @"";
    }
    
    joinedString = [NSString convertHTML:joinedString];
    _textLabel.attributedText = [[NSAttributedString alloc] initWithString:joinedString  attributes:attributes];
    _textLabel.numberOfLines = 0;
    [_textLabel sizeToFit];
    
    CGRect frame = _textLabel.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - _textLabel.frame.origin.x*2;
    _textLabel.frame = frame;
    
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _textLabel.frame.size.height + 24);

    self.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height);
}

@end
