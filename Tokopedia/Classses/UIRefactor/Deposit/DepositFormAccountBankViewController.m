//
//  DepositFormAccountBankViewController.m
//  
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "DepositFormAccountBankViewController.h"
#import "DepositFormViewController.h"
#import "SettingBankNameViewController.h"
#import "BankAccountFormList.h"
#import "profile.h"

@interface DepositFormAccountBankViewController () <UITableViewDataSource, UITableViewDelegate, SettingBankNameViewControllerDelegate> {
    NSMutableDictionary *_datainput;
}

@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *bankNameButton;
@property (weak, nonatomic) IBOutlet UITextField *bankBranchTextField;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *OTPTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendOTPButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess;
- (void)requestFail;
- (void)requestTimeout;

@end

@implementation DepositFormAccountBankViewController

#pragma mark - Initialization
- (void)initBarButton {
    UIBarButtonItem *barbuttonleft;
    UIBarButtonItem *barbuttonright;
    //NSBundle* bundle = [NSBundle mainBundle];
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
    barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"Konfirmasi" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonright setTintColor:[UIColor blackColor]];
    [barbuttonright setTag:11];
    self.navigationItem.rightBarButtonItem = barbuttonright;
}

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initBarButton];
    
    _datainput = [NSMutableDictionary new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - DataSource Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    
}

- (void)loadData {
    
}

- (void)requestSuccess {
    
}

- (void)requestFail {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}

#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            case 11 : {
                if([self validateFormValue]) {
                    NSDictionary *formValue = @{
                                                @"bank_account_name" : _accountNameTextField.text,
                                                @"bank_account_number" : _accountNumberTextField.text,
                                                @"bank_id" : [_datainput objectForKey:@"bank_id"],
                                                @"bank_name" : [_bankNameButton titleForState:UIControlStateNormal],
                                                @"bank_branch" : _bankBranchTextField.text,
                                                };
                    //add some notification listener here
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBankAccountFromForm" object:nil userInfo:formValue];
//                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
                    
                }
                break;
            }
                
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        BankAccountFormList *list = [_data objectForKey:@"databank"];
        
        switch (button.tag) {
            case 10:
            {
                //Bank Name
                NSIndexPath *indexpath = [_datainput objectForKey:@"indexpath"]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingBankNameViewController *vc = [SettingBankNameViewController new];
                vc.data = @{@"indexpath" : indexpath,
                            @"bank_id" : [_datainput objectForKey:@"bank_id"]?:@(list.bank_id)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            
                
            default:
                break;
        }
    }

}

#pragma mark - Memory Manage
- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setting Bank Name Delegate
-(void)SettingBankNameViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSIndexPath *indexpath;
    NSString *name;
    NSInteger bankid;
    indexpath = [data objectForKey:@"indexpath"]?:[NSIndexPath indexPathForRow:0 inSection:0];
    name = [data objectForKey:@"bank_name"];
    bankid = [[data objectForKey:@"bank_id"] integerValue];
    [_datainput setObject:indexpath forKey:@"indexpath"];
    [_bankNameButton setTitle:name forState:UIControlStateNormal];
    [_datainput setObject:name forKey:@"bank_name"];
    [_datainput setObject:@(bankid) forKey:@"bank_id"];
}


#pragma mark - Validate Value
- (BOOL)validateFormValue {
     NSMutableArray *messages = [NSMutableArray new];
    
    if (![_accountNameTextField.text isEqualToString:@""] &&
        ![_accountNumberTextField.text isEqualToString:@""] &&
        ![[_bankNameButton titleForState:UIControlStateNormal] isEqualToString:@"Pilih Bank"] &&
        ![_bankBranchTextField.text isEqualToString:@""]
        ) {
        return YES;
    }
    else
    {
        if (!_accountNameTextField.text || [_accountNameTextField.text isEqualToString:@""]) {
            [messages addObject:ERRORMESSAGE_NULL_ACCOUNT_NAME];
        }
        
        if (!_accountNumberTextField.text || [_accountNumberTextField.text isEqualToString:@""]) {
            [messages addObject:ERRORMESSAGE_NULL_REKENING_NUMBER];
        }
        
        if ([[_bankNameButton titleForState:UIControlStateNormal] isEqualToString:@"Pilih Bank"]) {
            [messages addObject:ERRORMESSAGE_NULL_BANK_NAME];
        }
        
        if (!_bankBranchTextField.text || [_bankBranchTextField.text isEqualToString:@""]) {
            [messages addObject:ERRORMESSAGE_NULL_BANK_BRANCH];
        }
        
        NSArray *array = messages;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        
        return NO;
    }
    
   
}



@end
