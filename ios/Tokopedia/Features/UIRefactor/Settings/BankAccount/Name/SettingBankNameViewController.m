//
//  SettingBankNameViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "DBManager.h"
#import "SettingBankNameCell.h"
#import "SettingBankNameViewController.h"

@interface SettingBankNameViewController () <UITableViewDelegate, UITableViewDataSource, SettingBankNameCellDelegate>
{
    NSInteger _type;
    NSMutableDictionary *_selectedlocation;
    NSMutableArray *_searchresultarray;
    NSMutableArray *_tempresultarray; //for search bar
    
    UISearchBar *_activesearchbar;
    
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *banknames;
@property (nonatomic, strong) NSMutableArray *bankvalues;

- (IBAction)gesture:(id)sender;

@end

@implementation SettingBankNameViewController

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
 
    self.navigationItem.title = @"Pilih Bank";
    
    [self.navigationController.navigationBar setTranslucent:NO];
    /** create new **/
    
    _banknames = [NSMutableArray new];
    _bankvalues = [NSMutableArray new];
    _searchresultarray = [NSMutableArray new];
    _selectedlocation = [NSMutableDictionary new];
    _tempresultarray =[NSMutableArray new];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Pilih"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    doneBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    _table.delegate = self;
    _table.dataSource = self;
    
    NSArray *name;
    NSArray *value;
    
    NSIndexPath *indexpath;
    NSInteger index = 0;
    
    NSInteger bankid = [[_data objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]integerValue];
    name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select bank_name from ws_bank order by bank_name"]];
    
    value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select bank_id from ws_bank order by bank_name"]];
    [_banknames addObjectsFromArray:name];
    [_bankvalues addObjectsFromArray:value];
    
    if (bankid!=0) index = [_bankvalues indexOfObject:[NSString stringWithFormat:@"%zd",bankid]];
    indexpath = (index == 0)?[_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]:[NSIndexPath indexPathForRow:index inSection:0];
    
    [_selectedlocation setObject:indexpath?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    
    NSDictionary *temp;
    for (int i=0; i<_banknames.count;i++) {
        temp = @{API_BANK_NAME_KEY: _banknames[i], kTKPDPROFILESETTING_APIBANKIDKEY: _bankvalues[i]};
        [_searchresultarray insertObject:temp atIndex:i];
    }
    
    [_tempresultarray addObjectsFromArray:_searchresultarray];
    
    if (_tempresultarray.count > 0) {
        _isnodata = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    [_activesearchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                NSIndexPath *indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
                NSIndexPath *indexPath = [_selectedlocation objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:indexPathZero;
                NSDictionary *bank = _tempresultarray[indexPath.row];
                NSDictionary *data = @{
                                           kTKPDPROFILESETTING_APIBANKIDKEY  : [bank objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY],
                                           API_BANK_NAME_KEY                 : [bank objectForKey:API_BANK_NAME_KEY],
                                           kTKPDPROFILE_DATABANKINDEXPATHKEY : indexPath,
                                       };
                [_delegate SettingBankNameViewController:self withData:data];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activesearchbar resignFirstResponder];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDmenuLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _tempresultarray.count;
#else
    return _isnodata ? 0 : _tempresultarray.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDSETTINGBANKNAMECELL_IDENTIFIER;
		
		cell = (SettingBankNameCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SettingBankNameCell newcell];
			((SettingBankNameCell*)cell).delegate = self;
		}
        if (indexPath.row != ((NSIndexPath*)[_selectedlocation objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]).row) {
            ((SettingBankNameCell*)cell).imageview.hidden = YES;
        }
        else
            ((SettingBankNameCell*)cell).imageview.hidden = NO;
        
        ((SettingBankNameCell*)cell).data = @{kTKPDPROFILE_DATAINDEXPATHKEY: indexPath, kTKPDPROFILE_DATALOCATIONNAMEKEY: [_tempresultarray[indexPath.row] objectForKey:API_BANK_NAME_KEY]};
        
	} else {
		static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
        
		cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
	}
	
	return cell;
}

#pragma mark - Cell Delegate
-(void)SettingBankNameCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_selectedlocation setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    [_table reloadData];
}

#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _activesearchbar = searchBar;
    if (![searchBar.text isEqualToString: @""]&&![searchBar.text isEqualToString:@" "]) {
        [_tempresultarray removeAllObjects];
        for (int i = 0; i<_searchresultarray.count; i++)
        {
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
            BOOL issearch = [resultPredicate evaluateWithObject:[_searchresultarray[i] objectForKey:API_BANK_NAME_KEY]];
            if (issearch){
                NSDictionary *result = @{API_BANK_NAME_KEY : [_searchresultarray[i] objectForKey:API_BANK_NAME_KEY],
                                         kTKPDPROFILESETTING_APIBANKIDKEY: [_searchresultarray[i] objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]};
                [_tempresultarray addObject:result];
            }
            
        }
        [_table reloadData];
    }
}

#pragma mark - Scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
