//
//  TKPDTabInboxTalkNavigationController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "controller.h"
#import "string_inbox_talk.h"
#import "TKPDTabInboxTalkNavigationController.h"


@interface TKPDTabInboxTalkNavigationController () {
    UIView* _tabbar;
    NSArray* _buttons;
    NSInteger _unloadSelectedIndex;
    NSArray* _unloadViewControllers;
    
    NSString *_titleNavTalk;
    NSString *_titleNavMyProductTalk;
    NSString *_titleNavFollowingTalk;
}


@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol;
@property (weak, nonatomic) IBOutlet UIView *readOption;
@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *unreadBtn;
@property (weak, nonatomic) IBOutlet UIView *allSign;
@property (weak, nonatomic) IBOutlet UIView *unreadSign;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;
@property (weak, nonatomic) IBOutlet UIView *segmentContainer;

- (IBAction)tap:(UISegmentedControl *)sender;
- (UIEdgeInsets)contentInsetForContainerController;
- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller;

@end

#pragma mark -
#pragma mark TKPDTabBarController

@implementation TKPDTabInboxTalkNavigationController

@synthesize viewControllers = _viewControllers;
@synthesize selectedViewController = _selectedViewController;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@dynamic contentInsetForChildController;

@synthesize container = _container;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedIndex = -1;
        _unloadSelectedIndex = -1;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"icon_arrow_white.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 25, 35)];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -26, 0, 0)];
    
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    [_segmentContainer.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_segmentContainer.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_segmentContainer.layer setShadowRadius:1];
    [_segmentContainer.layer setShadowOpacity:0.3];
    
    _titleNavTalk = ALL_TALK;
    _titleNavMyProductTalk = ALL_TALK;
    _titleNavFollowingTalk = ALL_TALK;
    
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleLabel setTitle:ALL_TALK forState:UIControlStateNormal];
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    titleLabel.tag = 15;
    [titleLabel addTarget:self action:@selector(tapbutton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleLabel;
    
    [self markAllTalkButton];
    
    
    if (_unloadSelectedIndex != -1) {
        [self setViewControllers:_unloadViewControllers];
        
        _unloadSelectedIndex = -1;
        _unloadViewControllers = nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableButtonRead:)
                                                 name:@"enableButtonRead" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableButtonRead:)
                                                 name:@"disableButtonRead" object:nil];
    
    self.hidesBottomBarWhenPushed = YES;

    _verticalSpaceButtons.constant = -89;

    CGRect frame = _buttonsContainer.frame;
    frame.origin.y = -89;
    _buttonsContainer.frame = frame;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _selectedViewController.view.frame = _container.bounds;
    
//    UIEdgeInsets inset = [self contentInsetForContainerController];
//    
//    UIView* tabbar;
//    CGRect frame;
//
//    tabbar = _tabbar;
//    frame = tabbar.frame;
//    frame.origin.y = inset.top;
//    
//    if ([_selectedViewController isKindOfClass:[UINavigationController class]]) {	//TODO: bars
//        UINavigationController* n = (UINavigationController*)_selectedViewController;
//        
//        if ((n != nil) && !n.navigationBarHidden && !n.navigationBar.hidden) {
//            CGRect rect = n.navigationBar.frame;
//            frame = CGRectOffset(frame, 0.0f, CGRectGetHeight(rect));
//        }
//    }
    
    UIEdgeInsets inset = [self contentInsetForChildController];
    if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(tabBarController:childControllerContentInset:)])) {
        [_delegate tabBarController:self childControllerContentInset:inset];
    }
}

-(IBAction)tapBackButton:(id)sender
{
    if (!_splitVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [_splitVC.navigationController popViewControllerAnimated:YES];

}


#pragma mark -
#pragma mark Properties

-(void)setData:(NSDictionary *)data
{
    _data = data;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (viewControllers != nil) {
        NSUInteger count = viewControllers.count;
        [_segmentcontrol setSelectedSegmentIndex:0];
        [self setViewControllers:nil animated:NO];
        UIViewController* c;
        for (NSInteger i = 0; i < count; i++) {
            c = viewControllers[i];
            if (c.TKPDTabNavigationItem == nil) {
                c.TKPDTabNavigationItem = (TKPDTabNavigationItem*)c.tabBarItem;
            }
        }
        
        _viewControllers = [viewControllers copy];
        if (_unloadSelectedIndex == -1) {
            [self setSelectedIndex:0 animated:animated];
        } else {
            [self setSelectedIndex:_unloadSelectedIndex animated:animated];
        }
        
    } else {
        if (_selectedViewController != nil) {
            
            [_selectedViewController willMoveToParentViewController:nil];
            [_selectedViewController.view removeFromSuperview];
            [_selectedViewController removeFromParentViewController];
        }
        
        _viewControllers = nil;
        _selectedViewController = nil;
        _selectedIndex = -1;
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    if ((selectedViewController != nil) && (_viewControllers.count == (_buttons.count - 0)) && (selectedViewController != _selectedViewController)) {
        
        UIViewController* c;
        NSInteger i;
        
        for (i = 0; i < _viewControllers.count; i++) {
            c = _viewControllers[i];
            if (c == selectedViewController) {
                break;
            }
        }
        
        if (c != nil) {
            [self setSelectedIndex:i];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndexTitle {
    UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(_selectedIndex == SEGMENT_INBOX_TALK) {
        [self setLabelButtonWithArrow:titleLabel withString:_titleNavTalk];
        if([_titleNavTalk isEqualToString:ALL_TALK]) {
            [self markAllTalkButton];
        } else {
            [self markUnreadTalkButton];
        }
    }
    
    if(_selectedIndex == SEGMENT_INBOX_TALK_MY_PRODUCT) {
        [self setLabelButtonWithArrow:titleLabel withString:_titleNavMyProductTalk];
        if([_titleNavMyProductTalk isEqualToString:ALL_TALK]) {
            [self markAllTalkButton];
        } else {
            [self markUnreadTalkButton];
        }
    }
    
    if(_selectedIndex == SEGMENT_INBOX_TALK_FOLLOWING) {
        [self setLabelButtonWithArrow:titleLabel withString:_titleNavFollowingTalk];
        if([_titleNavFollowingTalk isEqualToString:ALL_TALK]) {
            [self markAllTalkButton];
        } else {
            [self markUnreadTalkButton];
        }
    }
    
    titleLabel.frame = CGRectMake(0, 0, 70, 44);
    [titleLabel addTarget:self action:@selector(tapbutton:) forControlEvents:UIControlEventTouchUpInside];
    titleLabel.tag = 15;
    self.navigationItem.titleView = titleLabel;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
    
    if (selectedIndex == _selectedIndex) return;
    
    if (_viewControllers != nil) {

        UIViewController* deselect = _selectedViewController;
        UIViewController* select = _viewControllers[selectedIndex];
        
//        UIEdgeInsets inset = [self contentInsetForContainerController];
//        if ([select isKindOfClass:[UINavigationController class]]) {	//TODO: bars
//            
//            UINavigationController* n = (UINavigationController*)select;
//            if (!n.navigationBarHidden && !n.navigationBar.hidden) {
//                selectframe.origin.y = inset.top;
//                selectframe = CGRectZero;
//            } else {
//                selectframe = CGRectZero;
//            }
//        } else {
//            selectframe = CGRectZero;
//        }
        
        int navigate = 0;
        
        if (_selectedIndex < selectedIndex) {
            navigate = +1;
        } else {
            navigate = -1;
        }
        
        _selectedIndex = selectedIndex;
        _selectedViewController = _viewControllers[selectedIndex];
        
        [self setSelectedIndexTitle];
        
        if (animated && (deselect != nil) && (navigate != 0)) {
            
            if (deselect != nil) {
                [deselect willMoveToParentViewController:nil];
            }
            
            [self addChildViewController:select];
            
            if (navigate == 0) {
                select.view.frame = _container.bounds;	//dead code
            } else {
                if (navigate > 0) {
                    select.view.frame = CGRectOffset(_container.bounds, (CGRectGetWidth(_container.bounds)), 0.0f);
                } else {
                    select.view.frame = CGRectOffset(_container.bounds, -(CGRectGetWidth(_container.bounds)), 0.0f);
                }
            }
            
            [self transitionFromViewController:deselect toViewController:select duration:0.3 options:(0) animations:^{
                if (navigate != 0) {
                    if (navigate > 0) {
                        deselect.view.frame = CGRectOffset(_container.bounds, -(CGRectGetWidth(_container.bounds)), 0.0f);
                    } else {
                        deselect.view.frame = CGRectOffset(_container.bounds, (CGRectGetWidth(_container.bounds)), 0.0f);
                    }
                    select.view.frame = _container.bounds;
                }
                _tabbar.userInteractionEnabled = NO;	//race condition
            } completion:^(BOOL finished) {
                [deselect removeFromParentViewController];
                [select didMoveToParentViewController:self];
                _tabbar.userInteractionEnabled = YES;	//race condition
            }];
        } else {
            if (deselect != nil) {
                [deselect willMoveToParentViewController:nil];
                [deselect.view removeFromSuperview];
                [deselect removeFromParentViewController];
            }
            
            [self addChildViewController:select];
            
            select.view.frame = _container.bounds;
            
            [_container addSubview:select.view];
            [select didMoveToParentViewController:self];
        }
    }
}

- (UIEdgeInsets)contentInsetForChildController
{
    UIEdgeInsets inset = [self contentInsetForContainerController];
    CGRect bounds = _tabbar.bounds;
    inset.top += CGRectGetHeight(bounds);
    
    return inset;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
    
    NSLog(@"isViewLoaded: %@", self.isViewLoaded ? @"YES" : @"NO");
    
    if (self.isViewLoaded && (self.view.window == nil)) {
        
        _unloadSelectedIndex = _selectedIndex;
        _unloadViewControllers = _viewControllers;
        [self setViewControllers:nil];
        
        self.view = nil;
    }
    
    NSLog(@"isViewLoaded: %@", self.isViewLoaded ? @"YES" : @"NO");
}

#ifdef _DEBUG
- (void)dealloc
{
    NSLog(@"%@: %@", [self class], NSStringFromSelector(_cmd));
}
#endif


#pragma mark View actions
-(IBAction)tap:(UISegmentedControl*) sender
{
    if (_viewControllers != nil) {
        NSInteger index = sender.selectedSegmentIndex;
        [self setSelectedIndex:index animated:NO];
    }else {
        if (_selectedViewController != nil) {
            
            [_selectedViewController willMoveToParentViewController:nil];
            [_selectedViewController.view removeFromSuperview];
            [_selectedViewController removeFromParentViewController];
        }
        _viewControllers = nil;
        _selectedViewController = nil;
        _selectedIndex = -1;
    }
}

-(IBAction)tapbutton:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        if (btn.tag == 10) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        NSString *showReadSubfix;
        
        if(!_selectedIndex) {
            showReadSubfix = NAV_TALK;
        } else if (_selectedIndex == SEGMENT_INBOX_TALK_MY_PRODUCT) {
            showReadSubfix = NAV_TALK_MYPRODUCT;
        } else if (_selectedIndex == SEGMENT_INBOX_TALK_FOLLOWING) {
            showReadSubfix = NAV_TALK_FOLLOWING;
        }
        
        switch (btn.tag) {
            case 15: {
                if(_readOption.isHidden) {

                    _verticalSpaceButtons.constant = -89;
                    
                    CGRect frame = _buttonsContainer.frame;
                    frame.origin.y = -89;
                    _buttonsContainer.frame = frame;

                    _readOption.hidden = NO;
                    _readOption.alpha = 0;
                    [UIView animateWithDuration:0.2 animations:^{
                        _readOption.alpha = 1;
                    }];
                    
                    _verticalSpaceButtons.constant = 0;
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        CGRect frame = _buttonsContainer.frame;
                        frame.origin.y = 0;
                        _buttonsContainer.frame = frame;
                    }];
                } else {
                    _verticalSpaceButtons.constant = -89;
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        CGRect frame = _buttonsContainer.frame;
                        frame.origin.y = -89;
                        _buttonsContainer.frame = frame;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            _readOption.alpha = 0;
                        } completion:^(BOOL finished) {
                            _readOption.hidden = YES;
                        }];
                    }];
                }
                break;
            }
            case 16: {
                UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
                
                if(_selectedIndex == SEGMENT_INBOX_TALK) {
                    _titleNavTalk = ALL_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavTalk];
                } else if (_selectedIndex == SEGMENT_INBOX_TALK_MY_PRODUCT) {
                    _titleNavMyProductTalk = ALL_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavMyProductTalk];
                } else if (_selectedIndex == SEGMENT_INBOX_TALK_FOLLOWING) {
                    _titleNavFollowingTalk = ALL_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavFollowingTalk];
                }
                
                self.navigationItem.titleView = titleLabel;
                
                titleLabel.frame = CGRectMake(0, 0, 70, 44);
                [titleLabel addTarget:self action:@selector(tapbutton:) forControlEvents:UIControlEventTouchUpInside];
                titleLabel.tag = 15;
                self.navigationItem.titleView = titleLabel;
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"show_read", nil];
 
                NSString *notifName = [NSString stringWithFormat:@"%@%@", @"showRead", showReadSubfix] ;
                [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil userInfo:dict];
                
                [self markAllTalkButton];
                break;
            }
            case 17: {
                UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
                
                titleLabel.frame = CGRectMake(0, 0, 70, 44);
                [titleLabel addTarget:self action:@selector(tapbutton:) forControlEvents:UIControlEventTouchUpInside];
                titleLabel.tag = 15;
                
                if(_selectedIndex == SEGMENT_INBOX_TALK) {
                    _titleNavTalk = UNREAD_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavTalk];
                } else if (_selectedIndex == SEGMENT_INBOX_TALK_MY_PRODUCT) {
                    _titleNavMyProductTalk = UNREAD_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavMyProductTalk];
                } else if (_selectedIndex == SEGMENT_INBOX_TALK_FOLLOWING) {
                    _titleNavFollowingTalk = UNREAD_TALK;
                    [self setLabelButtonWithArrow:titleLabel withString:_titleNavFollowingTalk];
                }
                
                self.navigationItem.titleView = titleLabel;
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"show_read", nil];
                
                NSString *notifName = [NSString stringWithFormat:@"%@%@", @"showRead", showReadSubfix];
                [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:nil userInfo:dict];
                
                [self markUnreadTalkButton];
                break;
            }
            default: {
                break;
            }
        }
    } else {
        _verticalSpaceButtons.constant = -89;
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = _buttonsContainer.frame;
            frame.origin.y = -89;
            _buttonsContainer.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _readOption.alpha = 0;
            } completion:^(BOOL finished) {
                _readOption.hidden = YES;
            }];
        }];
    }
}


#pragma mark -
#pragma mark Methods

- (UIEdgeInsets)contentInsetForContainerController
{
    UIEdgeInsets inset = UIEdgeInsetsZero;
    
    if ((self.parentViewController != nil) && [self.parentViewController respondsToSelector:@selector(contentInsetForChildController)]) {
        UIEdgeInsets bar = [((id)self.parentViewController) contentInsetForChildController];
        
        inset.top += bar.top;
        inset.bottom += bar.bottom;
        inset.left += bar.left;
        inset.right += bar.right;
        
    } else {
        UIApplication* app = [UIApplication sharedApplication];
        if (!app.statusBarHidden) {
            
            CGRect bar = app.statusBarFrame;
            CGRect view = _selectedViewController.view.frame;
            
            UINavigationController* n = (UINavigationController*)[self isChildViewControllersContainsNavigationController:self];
            if (n != nil) {
                UINavigationBar* nbar = n.navigationBar;
                if ((nbar != nil) && !n.navigationBarHidden && !nbar.hidden && nbar.translucent) {
                    if (_selectedViewController.view.window != nil) {	//TODO:
                        view = [_selectedViewController.view.superview convertRect:view toView:_selectedViewController.view.window];
                        NSAssert(_selectedViewController.view.window != nil, @"nil view's window");
                        if (CGRectIntersectsRect(bar, view)) {
                            bar = CGRectIntersection(bar, view);
                            inset.top += CGRectGetHeight(bar);
                            inset.bottom += CGRectGetHeight(bar);
                        }
                        
                    } else if (nbar.translucent) {
                        inset.top += CGRectGetHeight(bar);
                    }
                }
            }
        }
    }
    
    return inset;
}

- (UIViewController*)isChildViewControllersContainsNavigationController:(UIViewController*)controller
{
    NSArray* childs = controller.childViewControllers;
    for (UIViewController* c in childs) {
        if ([c isKindOfClass:[UINavigationController class]]) {
            return c;
        } else {
            return [self isChildViewControllersContainsNavigationController:c];
        }
    }
    return nil;
}

- (void)setLabelButtonWithArrow:(UIButton *)button withString:(NSString*)string {
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:1],
                                 NSFontAttributeName            : [UIFont title1ThemeMedium],
                                 };
    
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                 attributes:attributes];
    [button setAttributedTitle:myString forState:UIControlStateNormal];
    
    UIImage *arrowImage;

    arrowImage = [UIImage imageNamed:@"icon_triangle_down_white.png"];

    
    
    CGRect rect = CGRectMake(0,0,10,7);
    UIGraphicsBeginImageContext( rect.size );
    [arrowImage drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    
    [button setImage:img forState:UIControlStateNormal];
    
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 115, 0, -10);
}

#pragma mark - Notification
- (void)enableButtonRead:(NSNotification*)notification{
    _allBtn.enabled = YES;
    _unreadBtn.enabled = YES;
    [_allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_unreadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)disableButtonRead:(NSNotification*)notification{
    _allBtn.enabled = NO;
    _unreadBtn.enabled = NO;
    [_allBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_unreadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

#pragma mark - Button Read Action
- (void)markAllTalkButton {
    _verticalSpaceButtons.constant = -89;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _buttonsContainer.frame;
        frame.origin.y = -89;
        _buttonsContainer.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            _readOption.alpha = 0;
        } completion:^(BOOL finished) {
            _readOption.hidden = YES;
        }];
    }];
    
    _allSign.hidden = NO;
    _unreadSign.hidden = YES;
}

- (void)markUnreadTalkButton {
    _verticalSpaceButtons.constant = -89;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _buttonsContainer.frame;
        frame.origin.y = -89;
        _buttonsContainer.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            _readOption.alpha = 0;
        } completion:^(BOOL finished) {
            _readOption.hidden = YES;
        }];
    }];
    
    _allSign.hidden = YES;
    _unreadSign.hidden = NO;
}

@end

