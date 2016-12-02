//
//  testViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HomeTabHeaderViewController.h"
#import "UserAuthentificationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "OAStackView.h"
#import "Masonry.h"

#define STACKVIEW_LEFTRIGHT_MARGIN 20

@interface HomeTabHeaderViewController () <UIScrollViewDelegate> {
    CGFloat _totalOffset;
    NSInteger _viewControllerIndex;
    BOOL _isAbleToSwipe;
    BOOL _loggedIn;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) OAStackView *stackView;
@property (nonatomic) CGFloat maxXInScrollView;

@end

@implementation HomeTabHeaderViewController

#pragma mark - Init
- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomeTab:)
                                                 name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout:) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];
    //set change orientation
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    

}

- (void)initButton {
    UIButton * (^createButton)(NSString* , NSInteger) = ^UIButton * (NSString* buttonTitle, NSInteger buttonTag) {
        UIButton *button;
        button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont title2ThemeMedium];
        button.tag = buttonTag;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    };
    _stackView = [[OAStackView alloc] initWithArrangedSubviews:
                  @[createButton(@"HOME", 1),
                    createButton(@"FEED", 2),
                    createButton(@"PROMO", 3),
                    createButton(@"TERAKHIR DILIHAT", 4),
                    createButton(@"FAVORIT", 5)]];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = OAStackViewAlignmentFill;
    _stackView.layoutMarginsRelativeArrangement = YES;
    _stackView.layoutMargins = UIEdgeInsetsMake(0, STACKVIEW_LEFTRIGHT_MARGIN, 0, STACKVIEW_LEFTRIGHT_MARGIN);
}

#pragma mark - Lifecycle
- (void)viewDidLayoutSubviews {
    [_scrollView addSubview:_stackView];
    CGRect newFrame = _scrollView.frame;
    newFrame.size.width = [[UIScreen mainScreen]bounds].size.width;
    _scrollView.frame = newFrame;
    if(IS_IPAD) {
        _stackView.distribution = OAStackViewDistributionEqualSpacing;
        _stackView.spacing = 0.0;
        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.height.width.mas_equalTo(_scrollView);
        }];
    } else {
        _stackView.distribution = OAStackViewDistributionFillProportionally;
        _stackView.spacing = 35.0;
        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.height.mas_equalTo(_scrollView);
        }];

    }
    
    _maxXInScrollView = [self xInScrollViewFormula: [_stackView.arrangedSubviews count]] - SCREEN_WIDTH + [_stackView.arrangedSubviews objectAtIndex:[_stackView.arrangedSubviews count]-1].frame.size.width+ STACKVIEW_LEFTRIGHT_MARGIN;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotificationCenter];

    _scrollView.delegate = self;
    _scrollView.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    _scrollView.bounces = NO;
    
    [self initButton];
    
    UserAuthentificationManager *manager = [[UserAuthentificationManager alloc] init];
    _loggedIn = YES;
    if (![manager isLogin]) {
        [self userDidLogout:nil];
        _loggedIn = NO;
    }
    
    [self.view.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [self.view.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [self.view.layer setShadowRadius:1];
    [self.view.layer setShadowOpacity:0.3];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_loggedIn) {
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y)];
        [self tap:1];
        [self setActiveButton];
    }
}

- (void)userDidLogin:(NSNotification *)notification {
    [_scrollView setScrollEnabled:YES];
    [_stackView removeFromSuperview];
    [self initButton];
    [self viewDidLayoutSubviews];
    _loggedIn = YES;
}

- (void)userDidLogout:(NSNotification *)notification {
    [self removeButton];
    [_scrollView setScrollEnabled:NO];
    _loggedIn = NO;
}

#pragma mark _ Tap Action
- (void)tapButtonAnimate:(CGFloat)totalOffset{
    if(IS_IPAD == false) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = CGPointMake(totalOffset, 0);
        }];
    }
}

- (void)tapButton:(UIButton*)button {
    [self tap:button.tag];
    
    NSString *name = @"";
    
    switch (button.tag) {
        case 1:
            name = @"Home";
            break;
        case 2:
            name = @"Product Feed";
            break;
        case 3:
            name = @"Promo";
            break;
        case 4:
            name = @"Last Seen";
            break;
        case 5:
            name = @"Favorite";
            break;
        default:
            break;
    }
    
    [AnalyticsManager trackEventName:@"clickHomepage"
                            category:GA_EVENT_CATEGORY_HOMEPAGE
                              action:GA_EVENT_ACTION_CLICK
                               label:name];
    NSDictionary *userInfo = @{@"page" : @(button.tag)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeHomePage" object:nil userInfo:userInfo];
    [self setActiveButton];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"tag"]integerValue]+1;
    [self tap:index];
    [self setActiveButton];
}

- (void)tap:(int)page {
    [self.view layoutIfNeeded];
    NSInteger xInScrollView = [self xInScrollViewFormula: page];
    switch (page) {
        case 1 :{
            _totalOffset = 0;
            break;
        }
        case 5 :{
            _totalOffset = _maxXInScrollView;
            break;
        }
        default:
            _totalOffset = [self totalOffsetFormula:xInScrollView page:page];
            break;
    }
    _viewControllerIndex = page;
    [self tapButtonAnimate:_totalOffset];
}

- (NSInteger) xInScrollViewFormula: (NSInteger)page {
    return [[_stackView.arrangedSubviews objectAtIndex:page-1] convertPoint:CGPointZero toView:_scrollView].x;
}

- (CGFloat) totalOffsetFormula: (NSInteger)xInScrollView page: (NSInteger) page {
    CGFloat totalOffset = xInScrollView - ((_stackView.arrangedSubviews[page-2].frame.size.width / 2)*(page-1) + _stackView.spacing);
    if (totalOffset >= _maxXInScrollView) {
        totalOffset = _maxXInScrollView;
    }
    return totalOffset;
}

- (void)setActiveButton
{
    for (UIButton *button in _stackView.arrangedSubviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag == _viewControllerIndex) {
                [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
            } else {
                [button setTitleColor:[UIColor colorWithRed:182.0/255.0 green:223.0/255.0 blue:185.0/255.0 alpha:1] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)removeButton {
    for (UIButton *button in _stackView.arrangedSubviews) {
        if(button.tag > 1) {
            [button removeFromSuperview];
        }
    }
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_scrollView setDelegate:nil];
}

@end
