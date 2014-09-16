//
//  CustomTabBarController.m
//  tokopedia
//
//  Created by IT Tkpd on 8/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDTabBarController.h"

@interface TKPDTabBarController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) IBOutlet UIView *tabbarview;
@property (strong, nonatomic) IBOutlet UIView *container;

@end

@implementation TKPDTabBarController

#pragma mark - initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"TKPDTabBarController" bundle:nil];
    if (self) {
    
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = _container.frame;
    
    //[self.tabBar setBackgroundColor:[UIColor redColor]];
    //[[self.viewControllers objectAtIndex:0] setObject:(UIButton*)_buttons[0] atIndex:0];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
//- (void)setTabBarViewControllers:(NSArray*)viewControllers {
//    
//    self.viewControllers = viewControllers;
//
//    /** make first controller selected **/
//    self.selectedIndex = 0;
//    
//}

//-(void)tabBarController:(UITabBarController *)tabBarControll didSelectViewController:(UIViewController *)viewController
//{
// 
//}

@end
