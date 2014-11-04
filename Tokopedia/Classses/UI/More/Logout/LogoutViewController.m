//
//  LogoutViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "LogoutViewController.h"

@interface LogoutViewController ()
{

}

@end

@implementation LogoutViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tap:(id)sender {
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 10:
        {
            // logout
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION object:nil userInfo:@{}];
            break;
        }
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
