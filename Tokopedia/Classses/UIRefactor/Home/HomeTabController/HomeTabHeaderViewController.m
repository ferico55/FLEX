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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    

}

- (void)initButton {
    UIButton * (^createButton)(NSString* ,NSInteger, NSInteger) = ^UIButton * (NSString* buttonTitle, NSInteger multiplier, NSInteger buttonTag) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width/2)*multiplier - ([[UIScreen mainScreen]bounds].size.width/4) , 0, ([[UIScreen mainScreen]bounds].size.width/2), 44)];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"GothamMedium" size:14]];
        button.tag = buttonTag;
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    };

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
    
    _scrollView.contentSize = CGSizeMake(([[UIScreen mainScreen]bounds].size.width/3)*6, self.scrollView.frame.size.height);
    
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
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(totalOffset, 0);
    }];
}

- (void)tapButton:(UIButton*)button {
    [self tap:button.tag];
    
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
    switch (page) {
        case 1 :{
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/2)*0;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 1;
            break;
        }
            
        case 2 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/2)*1;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 2;
            break;
        }
            
        case 3 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/2)*2;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 3;
            break;
        }
            
        case 4 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/2)*3;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 4;
            break;
        }
            
        case 5 : {
            _totalOffset = ([[UIScreen mainScreen]bounds].size.width/2)*4;
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

// MARK: Cleanup

- (void)orientationChanged:(NSNotification *)note {
    for (UIButton *button in _scrollView.subviews) {
        [button removeFromSuperview];
    }
    
    if(_loggedIn) {
        [self initButton];
    } else {
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width/3)*1, 0, ([[UIScreen mainScreen]bounds].size.width/3), 44)];
        [button1 setTitle:@"Beranda" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
        button1.titleLabel.font = [UIFont fontWithName:@"GothamMedium" size:14];
        button1.tag = 1;
        [button1 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button1];
    }

}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_scrollView setDelegate:nil];
}

@end
