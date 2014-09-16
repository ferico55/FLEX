//
//  CartViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "cart.h"
#import "CartViewController.h"

@interface CartViewController ()

@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CartViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDCART_TITLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    NSInteger navigation = [self.navigationController.viewControllers count];
//	if (navigation > 0) {
//		barbutton1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"navigation-chevron" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
//		barbutton1.tag = 10;
//		self.navigationItem.leftBarButtonItem = barbutton1;
//	}
}

-(IBAction)tap:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 10:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
