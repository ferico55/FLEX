//
//  SettingPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingPaymentViewController.h"

@interface SettingPaymentViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *viewcontent;

- (IBAction)tap:(id)sender;
@end

@implementation SettingPaymentViewController

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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _scrollview.contentSize = _viewcontent.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //mandiri click pay
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tokopedia.com/help/mandiri"]];
                break;
            }
            case 11:
            {
                //mandiri e cash
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tokopedia.com/help/ecash"]];
                break;
            }
            case 12:
            {
                //bca click pay
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tokopedia.com/help/bca-klikpay"]];
                break;
            }
            default:
                break;
        }
    }

}
@end
