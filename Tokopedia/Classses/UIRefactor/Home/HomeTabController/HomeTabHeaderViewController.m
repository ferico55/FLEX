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
#import "TPAnalytics.h"
#import "OAStackView.h"
#import "Masonry.h"

@interface HomeTabHeaderViewController () <UIScrollViewDelegate> {
    CGFloat _totalOffset;
    NSInteger _viewControllerIndex;
    BOOL _isAbleToSwipe;
    BOOL _loggedIn;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) OAStackView *stackView;

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
    UIButton * (^createButton)(NSString* ,NSInteger, NSInteger) = ^UIButton * (NSString* buttonTitle, NSInteger multiplier, NSInteger buttonTag) {
        UIButton *button;
        button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont title2ThemeMedium];
        button.tag = buttonTag;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    };
    _stackView = [[OAStackView alloc] initWithArrangedSubviews:
                  @[createButton(@"HOME", 1, 1),
                    createButton(@"FEED", 2, 2),
                    createButton(@"WISHLIST", 3, 3),
                    createButton(@"TERAKHIR DILIHAT", 4, 4),
                    createButton(@"FAVORIT", 5, 5)]];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = OAStackViewAlignmentFill;
    [_scrollView addSubview:_stackView];
    if(IS_IPAD) {
        [_scrollView setScrollEnabled:NO];
        _stackView.distribution = OAStackViewDistributionFillEqually;
        _stackView.spacing = 0.0;
        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(_scrollView);
            make.left.mas_equalTo(self.view);
            make.right.mas_equalTo(self.view);
        }];
    } else {
        _stackView.distribution = OAStackViewDistributionFillProportionally;
        _stackView.spacing = 35.0;
    }
}

#pragma mark - Lifecycle
- (void)viewDidLayoutSubviews {
    CGRect newFrame = _scrollView.frame;
    newFrame.size.width = [[UIScreen mainScreen]bounds].size.width;
    _scrollView.frame = newFrame;
    [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(_scrollView);
        make.left.mas_equalTo(_scrollView).with.offset([self calculateLeadingNeededToMakeButtonCentered:0]);
        make.right.mas_equalTo(_scrollView).with.offset((-[[UIScreen mainScreen]bounds].size.width / 2) + [_stackView.arrangedSubviews lastObject].frame.size.width / 2);
        make.height.mas_equalTo(_scrollView);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotificationCenter];
    
    _scrollView.contentSize = CGSizeMake(([[UIScreen mainScreen]bounds].size.width/2)*6, self.view.frame.size.height);
    
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
    [TPAnalytics trackGoToHomepageTabWithIndex:button.tag];
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

- (NSInteger) calculateLeadingNeededToMakeButtonCentered:(NSInteger) arrangedSubViewAtIndex {
    return ([UIScreen mainScreen].bounds.size.width / 2 ) - ([_stackView.arrangedSubviews objectAtIndex:arrangedSubViewAtIndex].bounds.size.width / 2);
}


- (void)tap:(int)page {

    switch (page) {
        case 1 :{
            NSInteger xInScrollView = [[_stackView.arrangedSubviews objectAtIndex:0] convertPoint:CGPointZero toView:_scrollView].x;
            _totalOffset = xInScrollView - [self calculateLeadingNeededToMakeButtonCentered:0];
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 1;
            break;
        }
            
        case 2 : {
            NSInteger xInScrollView = [[_stackView.arrangedSubviews objectAtIndex:1] convertPoint:CGPointZero toView:_scrollView].x;
            _totalOffset = xInScrollView - [self calculateLeadingNeededToMakeButtonCentered:1];
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 2;
            break;
        }
            
        case 3 : {
            NSInteger xInScrollView = [[_stackView.arrangedSubviews objectAtIndex:2] convertPoint:CGPointZero toView:_scrollView].x;
            _totalOffset = xInScrollView - [self calculateLeadingNeededToMakeButtonCentered:2];            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 3;
            break;
        }
            
        case 4 : {
            NSInteger xInScrollView = [[_stackView.arrangedSubviews objectAtIndex:3] convertPoint:CGPointZero toView:_scrollView].x;
            _totalOffset = xInScrollView - [self calculateLeadingNeededToMakeButtonCentered:3];
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 4;
            break;
        }
            
        case 5 : {
            NSInteger xInScrollView = [[_stackView.arrangedSubviews objectAtIndex:4] convertPoint:CGPointZero toView:_scrollView].x;
            _totalOffset = xInScrollView - [self calculateLeadingNeededToMakeButtonCentered:4];
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 5;
            break;
        }
            
        default:
            break;
    }
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
