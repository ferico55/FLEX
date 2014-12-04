//
//  SortViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "SortViewController.h"
#import "SortCell.h"
#import "UIImage+ImageEffects.h"

@interface SortViewController ()<UITableViewDataSource,UITableViewDelegate, SortCellDelegate>
{
    NSArray *_sortarray;
    NSMutableDictionary *_selectedsort;
    NSInteger _type;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation SortViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTKPDFILTER_TITLESORTKEY;

    }
    return self;
}

#pragma mark - View Lifecylce

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.cancelButton.layer.cornerRadius = 5;
    self.cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cancelButton.layer.borderWidth = 1;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    _selectedsort = [NSMutableDictionary new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [barbutton1 setTintColor:[UIColor whiteColor]];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    // set table view datasource and delegate
    _table.delegate = self;
    _table.dataSource = self;
    
    _type = [[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] integerValue]?:0;
    switch (_type) {
        case 1:
        case 2:
        {   //product
            _sortarray = kTKPDSORT_HOTLISTSORTARRAY;
            break;
        }
        case 3:
        {   //catalog
            _sortarray = kTKPDSORT_SEARCHCATALOGSORTARRAY;
            break;
        }
        case 4:
        {    //detail catalog
            _sortarray = kTKPDSORT_SEARCHDETAILCATALOGSORTARRAY;
            break;
        }
        case 5:
        {    //shop
            break;
        }
        case 6:
        {   //shop product
            _sortarray = kTKPDSORT_SEARCHPRODUCTSHOPSORTARRAY;
            break;
        }
        default:
            break;
    }
    NSIndexPath *indexpath = [_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_selectedsort setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 10:
            {
                //CANCEL
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                //DONE
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _sortarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
        NSString *cellid = kTKPDSORTCELL_IDENTIFIER;
		
    cell = (SortCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [SortCell newcell];
        ((SortCell*)cell).delegate = self;
    }
    
    if (_sortarray.count > indexPath.row) {
        NSIndexPath *indexpath = [_selectedsort objectForKey:kTKPDFILTER_DATAINDEXPATHKEY];
        if (indexPath.row != indexpath.row) {
            ((SortCell*)cell).imageview.hidden = YES;
        }
        else
            ((SortCell*)cell).imageview.hidden = NO;
        ((SortCell*)cell).data= @{kTKPDSORT_DATASORTKEY: _sortarray[indexPath.row],kTKPDFILTER_DATAINDEXPATHKEY:indexPath};
    }
    
    
	return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Cell Delegate
-(void)SortCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    [_selectedsort setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
    [_table reloadData];


    //SUBMIT
    NSDictionary *orderdict = _sortarray[indexpath.row];
    NSDictionary *userinfo = @{kTKPDFILTER_APIORDERBYKEY:[orderdict objectForKey:kTKPDFILTER_DATASORTVALUEKEY]?:@"", kTKPDFILTERSORT_DATAINDEXPATHKEY:indexpath?:0};
    
    switch (_type) {
        case 1:
        case 2:
        {   //product
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 3:
        {   //catalog
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERCATALOGPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 4:
        {    //detail catalog
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERDETAILCATALOGPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
            UINavigationController *nav = (UINavigationController *)self.presentingViewController;
            [self dismissViewControllerAnimated:NO completion:^{
                [nav popViewControllerAnimated:NO];
            }];
            break;
        }
        case 5:
        {    //shop
            
            break;
        }
        case 6:
        {   //shop product
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
