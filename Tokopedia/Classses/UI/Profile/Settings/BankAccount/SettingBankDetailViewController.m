//
//  SettingBankDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountFormList.h"
#import "SettingBankEditViewController.h"
#import "SettingBankDetailViewController.h"

@interface SettingBankDetailViewController ()
{
}

@property (weak, nonatomic) IBOutlet UILabel *labelaccountowner;
@property (weak, nonatomic) IBOutlet UILabel *labelaccountnumber;
@property (weak, nonatomic) IBOutlet UILabel *labelbankname;
@property (weak, nonatomic) IBOutlet UILabel *labelbranch;
@property (weak, nonatomic) IBOutlet UIView *viewdefault;
@property (weak, nonatomic) IBOutlet UIView *viewsetasdefault;
@end

@implementation SettingBankDetailViewController

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
    
    [self setDefaultData:_data];
    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11:
            {   //Edit
                SettingBankEditViewController *vc = [SettingBankEditViewController new];
                vc.data = @{kTKPDPROFILE_DATABANKKEY : [_data objectForKey:kTKPDPROFILE_DATABANKKEY],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(kTKPDPROFILESETTINGEDIT_DATATYPEEDITVIEWKEY)
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //set as default
                _viewdefault.hidden = NO;
                _viewsetasdefault.hidden = YES;
                [_delegate DidTapButton:btn withdata:_data];
                break;
            }
            case 11:
            {
                //delete address
                [self.navigationController popViewControllerAnimated:YES];
                [_delegate DidTapButton:btn withdata:_data];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
        _labelaccountowner.text = list.bank_account_name?:@"";
        _labelaccountnumber.text = [NSString stringWithFormat:@"%@",list.bank_account_number];
        _labelbankname.text = list.bank_name?:@"";
        _labelbranch.text = list.bank_branch?:@"";
        BOOL isdefault = [[_data objectForKey:kTKPDPROFILE_DATAISDEFAULTKEY]boolValue];
        _viewdefault.hidden = !isdefault;
        _viewsetasdefault.hidden = isdefault;
    }
}

@end
