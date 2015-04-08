//
//  HomeTabHeaderViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HomeTabHeaderViewController.h"
#import "UserAuthentificationManager.h"

@interface HomeTabHeaderViewController () <UIScrollViewDelegate> {
    CGFloat _totalOffset;
    NSInteger _viewControllerIndex;
    UserAuthentificationManager *_userManager;
    BOOL _isAbleToSwipe;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HomeTabHeaderViewController

#pragma mark - Init
- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomeTab:)
                                                 name:@"didSwipeHomeTab" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setStateLogout)
                                                 name:@"setStateLogout" object:nil];
}

- (void)initButton {
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*1, 0, (self.view.frame.size.width/3), 44)];
    [button1 setTitle:@"Hotlist" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 0, (self.view.frame.size.width/3), 44)];
    [button2 setTitle:@"Produk Feed" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button2.tag = 2;
    [button2 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button2];
    
    UIButton *buttonWishList = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/3)*3, 0, self.view.bounds.size.width/3, 44)];
    [buttonWishList setTitle:@"WishList" forState:UIControlStateNormal];
    [buttonWishList setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    buttonWishList.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    buttonWishList.tag = 3;
    [buttonWishList addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:buttonWishList];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*4, 0, (self.view.frame.size.width/3), 44)];
    [button3 setTitle:@"Terakhir Dilihat" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button3.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button3.tag = 4;
    [button3 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button3];
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/3)*5, 0, (self.view.frame.size.width/3), 44)];
    [button4 setTitle:@"Toko Favorit" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
    button4.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    button4.tag = 5;
    [button4 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button4];
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotificationCenter];
    
    _scrollView.contentSize = CGSizeMake((self.view.frame.size.width/3)*6, self.view.frame.size.height);
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    _scrollView.delegate = self;
    [self initButton];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _userManager = [UserAuthentificationManager new];
    [self initButton];
    if([[_userManager getUserId] isEqualToString:@"0"]) {
        _isAbleToSwipe = NO;
        [self removeButton];
    } else {
        _isAbleToSwipe = YES;


    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
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
            _totalOffset = (self.view.frame.size.width/3)*0;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 1;
            break;
        }
            
        case 2 : {
            _totalOffset = (self.view.frame.size.width/3)*1;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 2;
            break;
        }
            
        case 3 : {
            _totalOffset = (self.view.frame.size.width/3)*2;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 3;
            break;
        }
            
        case 4 : {
            _totalOffset = (self.view.frame.size.width/3)*3;
            [self tapButtonAnimate:_totalOffset];
            _viewControllerIndex = 4;
            break;
        }
    
        case 5 : {
            _totalOffset = (self.view.frame.size.width/3)*4;
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
                [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
            } else {
                [button setTitleColor:[UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1] forState:UIControlStateNormal];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
