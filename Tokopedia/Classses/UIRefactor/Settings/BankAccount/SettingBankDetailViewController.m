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

@property (weak, nonatomic) IBOutlet UILabel *labelaccountowner;
@property (weak, nonatomic) IBOutlet UILabel *labelaccountnumber;
@property (weak, nonatomic) IBOutlet UILabel *labelbankname;
@property (weak, nonatomic) IBOutlet UILabel *labelbranch;
@property (weak, nonatomic) IBOutlet UIView *viewdefault;
@property (weak, nonatomic) IBOutlet UIView *viewsetasdefault;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation SettingBankDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDefaultData:_data];

    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    editBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = editBarButton;

    [self.scrollView addSubview:_contentView];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             self.view.frame.size.height-63);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEditBankAccount:)
                                                 name:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
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
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                vc.data = @{kTKPDPROFILE_DATABANKKEY : [_data objectForKey:kTKPDPROFILE_DATABANKKEY],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_EDIT)
                            };

                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
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
-(void)setDefaultData:(NSMutableDictionary *)data
{
    _data = data;
    if (data) {
        BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
        self.title = list.bank_account_name ?:TITLE_DETAIL_BANK_DEFAULT;
        _labelaccountowner.text = list.bank_account_name?:@"";
        _labelaccountnumber.text = [NSString stringWithFormat:@"%@",list.bank_account_number];
        _labelbankname.text = list.bank_name?:@"";
        _labelbranch.text = list.bank_branch?:@"";
        BOOL isdefault = [[_data objectForKey:kTKPDPROFILE_DATAISDEFAULTKEY]boolValue];
        _viewdefault.hidden = !isdefault;
        _viewsetasdefault.hidden = isdefault;
    }
}

- (void)didEditBankAccount:(NSNotification *)notification
{
    BankAccountFormList *bankAccount = [notification.userInfo objectForKey:kTKPDPROFILE_DATABANKKEY];
    self.title = bankAccount.bank_account_name?:TITLE_DETAIL_BANK_DEFAULT;
    _labelaccountowner.text = bankAccount.bank_account_name;
    _labelaccountnumber.text = bankAccount.bank_account_number;
    _labelbankname.text = bankAccount.bank_name;
    _labelbranch.text = bankAccount.bank_branch;
    
    BankAccountFormList *bank = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
    bank.bank_id = bankAccount.bank_id;
    bank.bank_account_name = bankAccount.bank_account_name;
    bank.bank_account_number = bankAccount.bank_account_number;
    bank.bank_name = bankAccount.bank_name;
    bank.bank_branch = bankAccount.bank_branch;
}

@end
