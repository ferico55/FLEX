//
//  SearchContainerViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchFilterLocationViewController.h"
#import "SearchContainerViewController.h"

@interface SearchContainerViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol2;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol3;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcontainer;
@property (weak, nonatomic) IBOutlet UIButton *locationbutton;
@property (weak, nonatomic) IBOutlet UIButton *filterbutton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;



@end

@implementation SearchContainerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 0; i<_viewcontrollers.count; i++) {
        [(UIView*)_viewcontainer[i] addSubview:((UIViewController*)_viewcontrollers[i]).view];
    }
    
//    _segmentcontrol3.hidden = NO;
//    [_segmentcontrol3 setSelectedSegmentIndex:0];
//    [_segmentcontrol3 sendActionsForControlEvents:UIControlEventValueChanged];
//    [_segmentcontrol3 addTarget:self action:@selector(indexChanged:) forControlEvents:UIControlEventValueChanged];
//    ((UIView*)_viewcontainer[_segmentcontrol3.selectedSegmentIndex]).hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SearchResultViewControllerscount:)
                                                 name:@"setsegmentcontrol" object:nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)tap:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 10:
        {
            SearchFilterLocationViewController *vc = [SearchFilterLocationViewController new];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

-(void)SearchResultViewControllerscount:(NSNotification*)notification
{
    
    NSDictionary *userinfo = notification.userInfo;
    NSInteger count = [[userinfo objectForKey:@"count"]integerValue];
    
    if (count == 2) {
        _segmentcontrol3.hidden = YES;
        _segmentcontrol2.hidden = NO;
        //[_segmentcontrol2 setSelectedSegmentIndex:0];
        [_segmentcontrol2 sendActionsForControlEvents:UIControlEventValueChanged];
        [_segmentcontrol2 addTarget:self action:@selector(indexChanged:) forControlEvents:UIControlEventValueChanged];
        ((UIView*)_viewcontainer[_segmentcontrol2.selectedSegmentIndex]).hidden = NO;
    }
    else if (count == 3)
    {
        _segmentcontrol2.hidden = YES;
        _segmentcontrol3.hidden = NO;
        //[_segmentcontrol3 setSelectedSegmentIndex:0];
        [_segmentcontrol3 sendActionsForControlEvents:UIControlEventValueChanged];
        [_segmentcontrol3 addTarget:self action:@selector(indexChanged:) forControlEvents:UIControlEventValueChanged];
        ((UIView*)_viewcontainer[_segmentcontrol3.selectedSegmentIndex]).hidden = NO;
    }
    
    _filterbutton.hidden = NO;
    _locationbutton.hidden = NO;
    [_act stopAnimating];
}


-(IBAction)indexChanged:(UISegmentedControl*) sender
{
    if (sender == _segmentcontrol3) {
        [_viewcontainer makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
        ((UIView*)_viewcontainer[_segmentcontrol3.selectedSegmentIndex]).hidden = NO;
    }
    else
    {
        [_viewcontainer makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
        switch (_segmentcontrol2.selectedSegmentIndex) {
            case 0:
                ((UIView*)_viewcontainer[0]).hidden = NO;
                break;
            case 1:
                ((UIView*)_viewcontainer[2]).hidden = NO;
                break;
            default:
                break;
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setContainerViewControllers:(NSArray*)viewControllers
{
    _viewcontrollers = viewControllers;
    
}

@end
