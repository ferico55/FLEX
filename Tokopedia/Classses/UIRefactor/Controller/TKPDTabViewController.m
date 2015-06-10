//
//  TKPDTabViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabViewController.h"

@interface TKPDTabViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *menuContainerView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *menuButtonView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *menuButtonCheckmark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTopConstraint;
@property NSInteger selectedMenuIndex;
@property (strong, nonatomic) UIImage *arrowImage;

@end

@implementation TKPDTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Reset segment
    [self.segmentedControl removeSegmentAtIndex:0 animated:NO];
    [self.segmentedControl removeSegmentAtIndex:0 animated:NO];
    
    // Set segment titles
    for (int index = 0; index < self.tabTitles.count; index++) {
        [self.segmentedControl insertSegmentWithTitle:[self.tabTitles objectAtIndex:index]
                                              atIndex:index
                                             animated:NO];
    }
    
    // Set selected segment at index 0
    self.segmentedControl.selectedSegmentIndex = 0;

    // Show first child view controller
    [self valueChangedSegmentedControl:_segmentedControl];
    
    self.menuView.hidden = YES;
    self.menuView.alpha = 0;
    self.menuTopConstraint.constant = 0 - self.menuContainerView.frame.size.height;
    
    CGRect frame = self.menuContainerView.frame;
    frame.origin.y = 0 - frame.size.height;
    self.menuContainerView.frame = frame;
    
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(navigationBarTap)];
    backgroundTap.numberOfTapsRequired = 1;
    self.menuView.userInteractionEnabled = YES;
    [self.menuView addGestureRecognizer:backgroundTap];
    
    self.selectedMenuIndex = 0;
    [self touchUpMenuButton:[self.menuButton objectAtIndex:_selectedMenuIndex]];
    
    [self setTitleViewAtIndex];
    
    [self configureMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)valueChangedSegmentedControl:(UISegmentedControl *)sender {
    UIViewController *controller = [self.viewControllers objectAtIndex:sender.selectedSegmentIndex];
    controller.view.frame = _containerView.bounds;
    [_containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    self.delegate = controller;    
}

- (IBAction)touchUpMenuButton:(UIButton *)sender {
    for (UIImageView *iconCheckmark in self.menuButtonCheckmark) {
        if (iconCheckmark.tag == sender.tag) {
            iconCheckmark.hidden = NO;
        } else {
            iconCheckmark.hidden = YES;
        }
    }
    _selectedMenuIndex = sender.tag?:0;
    [self setTitleViewAtIndex];
    [self hideMenu];
        
    if ([self.delegate respondsToSelector:@selector(tabViewController:didTapButtonAtIndex:)]) {
        [self.delegate tabViewController:self didTapButtonAtIndex:_selectedMenuIndex];
    }
    
}

- (void)setTitleViewAtIndex
{
    NSString *title = [self.menuTitles objectAtIndex:_selectedMenuIndex];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    CGSize calculateSize = [title sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(320, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect tempButtonRect = button.frame;
    tempButtonRect.size.width = calculateSize.width;
    button.frame = tempButtonRect;
    [button addTarget:self action:@selector(navigationBarTap) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [self.navigationController.navigationBar.titleTextAttributes objectForKey:NSFontAttributeName];
    
    
    CGRect rect = CGRectMake(0,0,16,10);
    UIGraphicsBeginImageContext( rect.size );
    [self.arrowImage drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect frame = CGRectMake(tempButtonRect.origin.x+tempButtonRect.size.width,
                              (self.navigationController.navigationBar.bounds.size.height-8)/2.0f, 16, 10);
    UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
    img.image = picture1;
    
    CGRect contentFrame = CGRectMake(0, 0, img.frame.origin.x+img.bounds.size.width,
                                     self.navigationController.navigationBar.bounds.size.height);
    UIView *viewContent = [[UIView alloc] initWithFrame:contentFrame];
    [viewContent addSubview:img];
    [viewContent addSubview:button];
    self.navigationItem.titleView = viewContent;
    viewContent.center = self.navigationController.navigationBar.center;
}

- (void)navigationBarTap
{
    if (self.menuView.isHidden) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

- (void)hideMenu
{
    self.arrowImage = [UIImage imageNamed:@"icon_arrow_white_down.png"];

    [UIView animateWithDuration:0.15 animations:^{
        self.menuTopConstraint.constant = 0 - self.menuContainerView.frame.size.height;
        CGRect frame = self.menuContainerView.frame;
        frame.origin.y = 0 - self.menuContainerView.frame.size.height;
        self.menuContainerView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.menuView.alpha = 0;
        } completion:^(BOOL finished) {
            self.menuView.hidden = YES;
        }];
    }];
    
    [self setTitleViewAtIndex];
}

- (void)showMenu
{
    self.arrowImage = [UIImage imageNamed:@"icon_arrow_white_up.png"];
    
    self.menuView.hidden = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.menuView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.menuTopConstraint.constant = 0;
            CGRect frame = self.menuContainerView.frame;
            frame.origin.y = 0;
            self.menuContainerView.frame = frame;
        }];
    }];
    
    [self setTitleViewAtIndex];
}

- (void)configureMenu
{
    for (int i = 0; i < self.menuButton.count; i++) {
        UIButton *button = [self.menuButton objectAtIndex:i];
        UIView *menuButtonView = [self.menuButtonView objectAtIndex:i];
        if (i < self.menuTitles.count) {
            [button setTitle:[self.menuTitles objectAtIndex:i] forState:UIControlStateNormal];
            [button setHidden:NO];
            [menuButtonView setHidden:NO];
        } else {
            [button setHidden:YES];
            [menuButtonView setHidden:YES];
        }
    }
}

@end
