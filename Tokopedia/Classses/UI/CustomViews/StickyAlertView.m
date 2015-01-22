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
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

-(id)initWithErrorMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [super init];
    self.hidden = YES;
    
    _textLabel.text = [NSString convertHTML:[messages componentsJoinedByString:@"\n"]];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.numberOfLines = 0;
    [_textLabel sizeToFit];
    
    self.backgroundColor = [UIColor colorWithRed:131.0/255.0 green:3.0/255.0 blue:0.0/255.0 alpha:1];

    return self;
}

-(id)initWithSuccessMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [super init];
    self.hidden = YES;
    
    _textLabel.text = [NSString convertHTML:[messages componentsJoinedByString:@"\n"]];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.numberOfLines = 0;
    [_textLabel sizeToFit];

    self.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1];
    
    return self;
}

-(id)initWithInfoMessages:(NSArray *)messages delegate:(id)delegate;
{
    self = [super init];
    self.hidden = YES;
    
    return self;
}

-(id)initWithLoadingMessage:(NSString *)message delegate:(id)delegate;
{
    self = [super init];
    self.hidden = YES;
    
    _textLabel.text = message;
    self.backgroundColor = [UIColor yellowColor];
    [[(UIViewController *)delegate view] addSubview:self];

    return self;
}

- (void)show
{
    self.hidden = NO;
}

- (void)dismiss
{
    self.hidden = YES;
    [self removeFromSuperview];
}

@end
