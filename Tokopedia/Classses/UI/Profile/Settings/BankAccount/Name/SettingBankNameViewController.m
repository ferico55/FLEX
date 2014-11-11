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

@interface SettingBankNameViewController ()<SettingBankNameCellDelegate>
{
    NSInteger _type;
    NSMutableDictionary *_selectedlocation;
    
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *banknames;
@property (nonatomic, strong) NSMutableArray *bankvalues;
@property (weak, nonatomic) IBOutlet UILabel *labeltitle;

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
    
    [self.navigationController.navigationBar setTranslucent:NO];
    /** create new **/
    
    _banknames = [NSMutableArray new];
    _bankvalues = [NSMutableArray new];
    _selectedlocation = [NSMutableDictionary new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [barbutton1 setTintColor:[UIColor blackColor]];
    }
    else
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _table.delegate = self;
    _table.dataSource = self;
    
    /** Set isnull value **/
    //[_locationvalues addObject:@""];
    //[_locationnames addObject:@"None"];
    
    NSArray *name;
    NSArray *value;
    
    NSIndexPath *indexpath;
    NSInteger index = 0;
    
    NSInteger bankid = [[_data objectForKey:kTKPDPROFILESETTING_APIPROVINCEKEY]integerValue];
    name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select bank_name from ws_bank order by bank_name"]];
    
    value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select bank_id from ws_bank order by bank_name"]];
    [_banknames addObjectsFromArray:name];
    [_bankvalues addObjectsFromArray:value];
    if (bankid!=0) index = [_bankvalues indexOfObject:[NSString stringWithFormat:@"%d",bankid]];
    
    indexpath = (index == 0)?[_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]:[NSIndexPath indexPathForRow:index inSection:0];
    
    [_selectedlocation setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    
    if (_banknames.count > 0) {
        _isnodata = NO;
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
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
                NSDictionary *data;
                NSIndexPath *indexpath = [_selectedlocation objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                data = @{kTKPDPROFILESETTING_APIBANKIDKEY : _bankvalues[indexpath.row],
                         kTKPDPROFILESETTING_APIBANKNAMEKEY :  _banknames[indexpath.row],
                         kTKPDPROFILE_DATABANKINDEXPATHKEY: indexpath,
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

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDmenuLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _baanknames.count;
#else
    return _isnodata ? 0 : _banknames.count;
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
        
        //if (indexPath.row>_locationnames.count) {
        ((SettingBankNameCell*)cell).data = @{kTKPDPROFILE_DATAINDEXPATHKEY: indexPath, kTKPDPROFILE_DATALOCATIONNAMEKEY: _banknames[indexPath.row]};
        //}
        
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

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
}

#pragma mark - Cell Delegate
-(void)SettingBankNameCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_selectedlocation setObject:indexpath forKey:kTKPDPROFILE_DATAINDEXPATHKEY];
    [_table reloadData];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchBar.text isEqualToString: @""]&&![searchBar.text isEqualToString:@" "]) {
        //_labelsearchfor.text = [NSString stringWithFormat:@"Search for '%@'", searchBar.text];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        NSArray *result;
        result = [_banknames filteredArrayUsingPredicate:resultPredicate];
        [_banknames addObjectsFromArray:result];
        [_table reloadData];
    }
    else
    {
        [_banknames removeAllObjects];
        [_table reloadData];
    }
}


@end
