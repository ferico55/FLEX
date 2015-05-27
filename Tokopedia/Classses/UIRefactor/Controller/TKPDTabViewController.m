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
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *menuButtonCheckmark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuContainerTopConstraint;

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
    
    [self setTitleViewAtIndex:0];
    
    self.menuContainerTopConstraint.constant = -self.menuContainerView.frame.size.height;
    self.menuView.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)valueChangedSegmentedControl:(UISegmentedControl *)sender {
    UIViewController *controller = [self.viewControllers objectAtIndex:sender.selectedSegmentIndex];
    controller.view.frame = _containerView.bounds;
    [_containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (IBAction)touchUpMenuButton:(UIButton *)sender {
    for (UIImageView *iconCheckmark in self.menuButtonCheckmark) {
        if (iconCheckmark.tag == sender.tag) {
            iconCheckmark.hidden = NO;
        } else {
            iconCheckmark.hidden = YES;
        }
    }
}

- (void)setTitleViewAtIndex:(NSInteger)index
{
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:1],
                                 NSFontAttributeName            : [UIFont boldSystemFontOfSize:16],
                                 };
    
    NSString *title = [self.tabTitles objectAtIndex:index];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title
                                                                               attributes:attributes];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Semua Layanan Pengguna" forState:UIControlStateNormal];
    
    UIImage *arrowImage = [UIImage imageNamed:@"icon_triangle_down_white.png"];
    
    CGRect rect = CGRectMake(0,0,10,7);
    UIGraphicsBeginImageContext( rect.size );
    [arrowImage drawInRect:rect];
    arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setImage:arrowImage forState:UIControlStateNormal];
    
    
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);


    button.frame = CGRectMake(0, 0, 70, 44);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 11;
    button.backgroundColor = [UIColor blackColor];
    button.titleLabel.font = [UIFont fontWithName:@"GothamMedium" size:13.0f];
    
    self.navigationItem.titleView = button;
    float test = [@"Semua Layanan Pengguna" sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(self.view.bounds.size.width, 44) lineBreakMode:NSLineBreakByWordWrapping].width;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, test, 0, -45);
}

- (void)tapButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(segmentController:didSelectSegmentAtIndex:)]) {
        [self.delegate segmentController:_segmentedControl didSelectSegmentAtIndex:_segmentedControl.selectedSegmentIndex];
    }
}

@end
