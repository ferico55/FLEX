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

@interface HomeTabHeaderViewController () <UIScrollViewDelegate> {
    CGFloat _totalOffset;
    NSInteger _viewControllerIndex;
    BOOL _isAbleToSwipe;
    BOOL _loggedIn;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
        if(IS_IPAD) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width/5)*multiplier - ([[UIScreen mainScreen]bounds].size.width/5), 0, ([[UIScreen mainScreen]bounds].size.width/5), 44)];
        } else {
            button = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width/2)*multiplier - ([[UIScreen mainScreen]bounds].size.width/4) , 0, ([[UIScreen mainScreen]bounds].size.width/2), 44)];
        }

        button.titleLabel.font = [UIFont title2ThemeMedium];
        button.tag = buttonTag;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    };
    
    if(IS_IPAD) {
        [_scrollView setScrollEnabled:NO];
    }

    [_scrollView addSubview:createButton(@"HOME", 1, 1)];
    [_scrollView addSubview:createButton(@"PRODUCT FEED", 2, 2)];
    [_scrollView addSubview:createButton(@"WISHLIST", 3, 3)];
    [_scrollView addSubview:createButton(@"TERAKHIR DILIHAT", 4, 4)];
    [_scrollView addSubview:createButton(@"TOKO FAVORIT", 5, 5)];
}

#pragma mark - Lifecycle
- (void)viewDidLayoutSubviews {
    CGRect newFrame = _scrollView.frame;
    newFrame.size.width = [[UIScreen mainScreen]bounds].size.width;
    _scrollView.frame = newFrame;
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
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
    
    NSString *name = @"";
    
    switch (button.tag) {
        case 1:
            name = @"Home";
            break;
        case 2:
            name = @"Product Feed";
            break;
        case 3:
            name = @"Wishlist";
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
    int divider = 2;

    switch (page) {
        case 1 :{
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/divider)*0;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 1;
            break;
        }
            
        case 2 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/divider)*1;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 2;
            break;
        }
            
        case 3 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/divider)*2;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 3;
            break;
        }
            
        case 4 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/divider)*3;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 4;
            break;
        }
            
        case 5 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/divider)*4;
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
    for (UIButton *button in _scrollView.subviews) {
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
    for (UIButton *button in _scrollView.subviews) {
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
