//
//  SegmentedReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "InboxReviewSplitViewController.h"
#import "InboxReviewViewController.h"
#import "MyReviewReputationViewController.h"
#import "SegmentedReviewReputationViewController.h"
#import "SplitReputationViewController.h"
#import "TKPDTabInboxReviewNavigationController.h"

#import "AlertLuckyView.h"
#import "LuckyDealWord.h"

#define CInboxReputation @"inbox-reputation"
#define CInboxReputationMyProduct @"inbox-reputation-my-product"
#define CInboxReputationMyReview @"inbox-reputation-my-review"

@interface SegmentedReviewReputationViewController ()

@end

@implementation SegmentedReviewReputationViewController
{
    MyReviewReputationViewController *allReviewViewController, *myProductViewController, *myReviewViewController;
    UIButton *btnTitle;
    NSString *selectedFilter;
    UIImage *arrowImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    selectedFilter = CTagSemuaReview;
    [self setNavigationTitle:selectedFilter];
    
    _selectedIndex = _userHasShop?0:2;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"icon_arrow_white.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0, 0, 25, 35)];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -26, 0, 0)];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    //Set text attribute for information change review style
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithAttributedString:lblDescChangeReviewStyle.attributedText];
    NSRange rangeText = [lblDescChangeReviewStyle.text rangeOfString:@"ulasan lama"];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0] range:rangeText];
    [lblDescChangeReviewStyle setAttributedText:attribute];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(viewContent.subviews.count == 0) {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [viewContent setNeedsLayout];
        [viewContent layoutIfNeeded];
        
        segmentedControl.selectedSegmentIndex = _selectedIndex;
        [self actionValueChange:segmentedControl];
    }
}

- (void)viewDidLayoutSubviews {
    if (!_userHasShop) {
        CGRect frame = CGRectZero;
        segmentedControlView.frame = frame;
        segmentedControl.frame = frame;
        
        frame = viewContent.frame;
        frame.origin.y = 0;
        frame.size.height = frame.size.height + 45;
        viewContent.frame = frame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method
- (void)tapBackButton:(id)sender
{
    [_splitVC.navigationController popViewControllerAnimated:YES];
}

- (void)initNavigation
{
    btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnTitle.titleLabel.font = [UIFont title1ThemeMedium];
    btnTitle.backgroundColor = [UIColor clearColor];
    [btnTitle addTarget:self action:@selector(actionChangeFilter:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView = btnTitle;
    [self.navigationItem.titleView sizeToFit];
}

- (void)setNavigationTitle:(NSString *)strTitle {
    if([strTitle isEqualToString:CTagBelumDibaca]) {
        strTitle = btnBelumDibaca.titleLabel.text;
        selectedFilter = CTagBelumDibaca;
    }
    else if([strTitle isEqualToString:CTagSemuaReview]) {
        strTitle = btnAllReview.titleLabel.text;
        selectedFilter = CTagSemuaReview;
    }
    else if([strTitle isEqualToString:CtagBelumDireviw]) {
        strTitle = btnBelumDireview.titleLabel.text;
        selectedFilter = CtagBelumDireviw;
    }
    
    if(arrowImage == nil) {
        arrowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_triangle_down_white" ofType:@"png"]];
        CGRect rect = CGRectMake(0, 0, 10 ,7);
        UIGraphicsBeginImageContext( rect.size );
        [arrowImage drawInRect:rect];
        arrowImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTemp.textColor = btnTitle.titleLabel.textColor;
        lblTemp.font = btnTitle.titleLabel.font;
        lblTemp.text = strTitle;
        CGSize tempSize = [lblTemp sizeThatFits:CGSizeMake(320, 999)];
        btnTitle.frame = CGRectMake(0, 0, tempSize.width+30, self.navigationController.navigationBar.bounds.size.height);
    }
    
    
    [btnTitle setTitle:strTitle forState:UIControlStateNormal];
    [btnTitle setImage:arrowImage forState:UIControlStateNormal];
    btnTitle.titleEdgeInsets = UIEdgeInsetsMake(0, -btnTitle.imageView.frame.size.width-5, 0, btnTitle.imageView.frame.size.width+5);
    btnTitle.imageEdgeInsets = UIEdgeInsetsMake(0, btnTitle.titleLabel.frame.size.width, 0, -btnTitle.titleLabel.frame.size.width);

    [self.navigationItem.titleView sizeToFit];
}

- (int)getSelectedSegmented {
    return (int)segmentedControl.selectedSegmentIndex;
}

- (MyReviewReputationViewController *)getSegmentedViewController {
    switch (segmentedControl.selectedSegmentIndex) {
        case CTagSemua:
        {
            return allReviewViewController;
        }
            break;
        case CTagProductSaya:
        {
            return myProductViewController;
        }
            break;
        case CTagReviewSaya:
        {
            return myReviewViewController;
        }
            break;
    }
    
    return nil;
}

- (NSString *)getSelectedFilter {
    return selectedFilter;
}

- (void)hiddenShadowFilter:(BOOL)isHidden {
    viewShadow.hidden = viewContentAction.hidden = isHidden;
    
    arrowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(isHidden? @"icon_triangle_down_white":@"icon_triangle_up_white") ofType:@"png"]];
    CGRect rect = CGRectMake(0, 0, 10 ,7);
    UIGraphicsBeginImageContext( rect.size );
    [arrowImage drawInRect:rect];
    arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    [btnTitle setImage:arrowImage forState:UIControlStateNormal];
}

#pragma mark - Action 
- (void)actionChangeFilter:(id)sender {
    [self hiddenShadowFilter:!viewShadow.isHidden];
    
    if([selectedFilter isEqualToString:CTagBelumDibaca]) {
        constTopCheckList.constant = btnBelumDibaca.frame.origin.y+5;
    }
    else if([selectedFilter isEqualToString:CTagSemuaReview]) {
        constTopCheckList.constant = btnAllReview.frame.origin.y+5;
    }
    else if([selectedFilter isEqualToString:CtagBelumDireviw]) {
        constTopCheckList.constant = btnBelumDireview.frame.origin.y+5;
    }
}

- (IBAction)actionReview:(id)sender {
    selectedFilter = CTagSemuaReview;
    [self hiddenShadowFilter:YES];
    [self setNavigationTitle:selectedFilter];
    
    [allReviewViewController actionReview:sender];
    [myProductViewController actionReview:sender];
    [myReviewViewController actionReview:sender];
}

- (IBAction)actionBelumDibaca:(id)sender {
    selectedFilter = CTagBelumDibaca;
    [self hiddenShadowFilter:YES];
    [self setNavigationTitle:selectedFilter];
    
    [allReviewViewController actionBelumDibaca:sender];
    [myProductViewController actionBelumDibaca:sender];
    [myReviewViewController actionBelumDibaca:sender];
}

- (IBAction)actionBelumDireview:(id)sender {
    selectedFilter = CtagBelumDireviw;
    [self hiddenShadowFilter:YES];
    [self setNavigationTitle:selectedFilter];
    
    [allReviewViewController actionBelumDireview:sender];
    [myProductViewController actionBelumDireview:sender];
    [myReviewViewController actionBelumDireview:sender];
}

- (IBAction)actionOldReview:(id)sender {
    //Change ViewController
    NSMutableArray *newViewController = [NSMutableArray new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        id tempSplitReputationViewController = self.parentViewController.parentViewController.nextResponder.nextResponder;
        UINavigationController *tmepViewController = (UINavigationController *)((SplitReputationViewController *) tempSplitReputationViewController).parentViewController;
        
        for(UIViewController *tempViewController in tmepViewController.viewControllers) {
            [newViewController addObject:tempViewController];
        }
        [newViewController removeLastObject];
        
        InboxReviewSplitViewController *controller = [InboxReviewSplitViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        [newViewController addObject:controller];
        [tmepViewController setViewControllers:newViewController];
        controller.hidesBottomBarWhenPushed = NO;
    } else {
        for(UIViewController *tempViewController in self.navigationController.viewControllers) {
            [newViewController addObject:tempViewController];
        }
        [newViewController removeLastObject];

        
        InboxReviewViewController *vc = [InboxReviewViewController new];
        vc.data=@{@"nav":@"inbox-review"};
        
        InboxReviewViewController *vc1 = [InboxReviewViewController new];
        vc1.data=@{@"nav":@"inbox-review-my-product"};
        
        InboxReviewViewController *vc2 = [InboxReviewViewController new];
        vc2.data=@{@"nav":@"inbox-review-my-review"};
        
        NSArray *vcs = @[vc,vc1, vc2];
        TKPDTabInboxReviewNavigationController *nc = [TKPDTabInboxReviewNavigationController new];
        [nc setSelectedIndex:2];
        [nc setViewControllers:vcs];
        nc.hidesBottomBarWhenPushed = YES;
        
        [newViewController addObject:nc];
        [self.navigationController setViewControllers:newViewController];
    }
}

- (IBAction)actionValueChange:(id)sender {
    for(UIView *subView in viewContent.subviews) {
        [subView removeFromSuperview];
    }
    [viewContent removeConstraints:viewContent.constraints];
    [allReviewViewController removeFromParentViewController];
    [myProductViewController removeFromParentViewController];
    [myReviewViewController removeFromParentViewController];
    
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case CTagSemua:
        {
            if(allReviewViewController == nil) {
                allReviewViewController = [MyReviewReputationViewController new];
                allReviewViewController.getDataFromMasterDB = _getDataFromMasterDB;
                allReviewViewController.segmentedReviewReputationViewController = self;
                allReviewViewController.strNav = CInboxReputation;
            }
            [self addChildViewController:allReviewViewController];
            [viewContent addSubview:allReviewViewController.view];

            UIView *tempView = allReviewViewController.view;
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[tempView(==%f)]", viewContent.bounds.size.height] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[tempView(==%f)]", viewContent.bounds.size.width] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
            
//            if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"7.1.2"))
                tempView.frame = CGRectMake(0, 0, self.view.bounds.size.width, viewContent.bounds.size.height);
        }
            break;
        case CTagProductSaya:
        {
            if(myProductViewController == nil) {
                myProductViewController = [MyReviewReputationViewController new];
                myProductViewController.segmentedReviewReputationViewController = self;
                myProductViewController.strNav = CInboxReputationMyProduct;
                myProductViewController.getDataFromMasterDB = _getDataFromMasterDB;
            }
            [self addChildViewController:myProductViewController];
            [viewContent addSubview:myProductViewController.view];

            UIView *tempView = myProductViewController.view;
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[tempView(==%f)]", viewContent.bounds.size.height] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[tempView(==%f)]", viewContent.bounds.size.width] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
//            
//            if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"7.1.2"))
                tempView.frame = CGRectMake(0, 0, self.view.bounds.size.width, viewContent.bounds.size.height);
        }
            break;
        case CTagReviewSaya:
        {
            if(myReviewViewController == nil) {
                myReviewViewController = [MyReviewReputationViewController new];
                myReviewViewController.segmentedReviewReputationViewController = self;
                myReviewViewController.strNav = CInboxReputationMyReview;
                myReviewViewController.getDataFromMasterDB = _getDataFromMasterDB;
            }
            [self addChildViewController:myReviewViewController];
            [viewContent addSubview:myReviewViewController.view];
            
            UIView *tempView = myReviewViewController.view;
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            [viewContent addConstraint:[NSLayoutConstraint constraintWithItem:tempView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[tempView(==%f)]", viewContent.bounds.size.height] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
//            [tempView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[tempView(==%f)]", viewContent.bounds.size.width] options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempView)]];
//            
//            
//            if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"7.1.2"))
                tempView.frame = CGRectMake(0, 0, self.view.bounds.size.width, viewContent.bounds.size.height);
        }
            break;
    }
}
@end
