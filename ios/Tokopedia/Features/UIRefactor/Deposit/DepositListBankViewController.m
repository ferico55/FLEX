//
//  DepositListBankViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "ProfileSettings.h"
#import "DepositListBankCell.h"
#import "SettingBankDetailViewController.h"
#import "SettingBankEditViewController.h"
#import "DepositListBankViewController.h"
#import "DepositFormAccountBankViewController.h"
#import "URLCacheController.h"
#import "URLCacheConnection.h"
#import "DepositForm.h"
#import "Tokopedia-Swift.h"


#pragma mark - Setting Bank Account View Controller
@interface DepositListBankViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _ismanualsetdefault;
    
    UIRefreshControl *_refreshControl;
    NSMutableDictionary *_datainput;
    
    NSMutableArray *_list;
    NSIndexPath *_selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIButton *addAccountButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

- (IBAction)tap:(id)sender;

@end

@implementation DepositListBankViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _ismanualsetdefault = NO;
        self.title =TITLE_LIST_BANK;
    }
    return self;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _list = [NSMutableArray arrayWithArray:_listBankAccount];
    _datainput = [NSMutableDictionary new];
    _selectedIndexPath = [_data objectForKey:@"account_indexpath"];

    _table.delegate = self;
    _table.dataSource = self;
    
    [_table reloadData];
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;

    NSString *cellid = @"DepostiListBankCellIdentifier";
    
    cell = (DepositListBankCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [DepositListBankCell newcell];

    }
    
    if (_list.count > indexPath.row) {
        BankAccountFormList *list = _list[indexPath.row];
        
        if(_selectedIndexPath.row == indexPath.row) {
            ((DepositListBankCell*)cell).isChecked.hidden = NO;
        } else {
            ((DepositListBankCell*)cell).isChecked.hidden = YES;
        }
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSMutableDictionary *attribute = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         NSParagraphStyleAttributeName  : style,
                                                                                         }];
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ a/n %@ - %@", list.bank_account_number, list.bank_account_name, list.bank_name
                                                                                          ] attributes:attribute];
        [((DepositListBankCell*)cell).labelname setAttributedText:attributedString];
    }
    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [_table reloadData];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id dataObject = [_list objectAtIndex:sourceIndexPath.row];
    [_list removeObjectAtIndex:sourceIndexPath.row];
    [_list insertObject:dataObject atIndex:destinationIndexPath.row];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barbtn = (UIBarButtonItem *)sender;
        switch (barbtn.tag) {
            case 10: {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            case 11: {
                if (_list.count == 0) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Silakan menambahkan akun bank untuk melakukan penarikan dana."] delegate:self];
                    [alert show];
                    break;
                }
                
                NSIndexPath *indexpath = _selectedIndexPath;
                DepositFormBankAccountList *list = _list[indexpath.row];
                NSString *bankName = [NSString stringWithFormat:@"%@ a/n %@ - %@", list.bank_account_number, list.bank_account_name, list.bank_name];
                
                NSDictionary *userinfo;
                userinfo = @{
                             @"indexpath" : indexpath,
                             @"bank_account_name" : bankName,
                             @"bank_account_id" : list.bank_account_id,
                             @"is_verified_account" : @(list.is_verified_account)?:0
                             };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSelectedDepositBank" object:nil userInfo:userinfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;

                break;
            }
                
            
            default:
                break;
        }

    }
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 12 : {
                if (_listBankAccount.count >= 10) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mohon maaf, maksimal 10 rekening bank yang dapat Anda masukkan.\nSilakan hapus terlebih dahulu rekening bank yang sudah tidak digunakan." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                DepositFormAccountBankViewController *formAddAccount = [DepositFormAccountBankViewController new];
                [self.navigationController pushViewController:formAddAccount animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDPROFILE_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}

@end
