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

@interface SortViewController ()<UITableViewDataSource,UITableViewDelegate, SortCellDelegate>
{
    NSArray *_sortarray;
    NSMutableDictionary *_selectedsort;
}
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation SortViewController

#pragma mark - View Lifecylce
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _selectedsort = [NSMutableDictionary new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    //TODO:: Change image
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    // set table view datasource and delegate
    _table.delegate = self;
    _table.dataSource = self;
    
    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEHOTLISTVIEWKEY]||[[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEPRODUCTVIEWKEY]) {
        _sortarray = kTKPDSORT_HOTLISTSORTARRAY;
    }
    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPECATALOGVIEWKEY]) {
            _sortarray = kTKPDSORT_SEARCHCATALOGSORTARRAY;
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
                //SUBMIT
                NSIndexPath *indexpath =[_selectedsort objectForKey:kTKPDFILTER_DATAINDEXPATHKEY];
                NSDictionary *orderdict = _sortarray[indexpath.row];
                NSDictionary *userinfo = @{kTKPDFILTER_APIORDERBYKEY:[orderdict objectForKey:kTKPDGILTER_DATASORTVALUEKEY]?:@""};
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEHOTLISTVIEWKEY]||[[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEPRODUCTVIEWKEY]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterProduct" object:nil userInfo:userinfo];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPESHOPVIEWKEY]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterShop" object:nil userInfo:userinfo];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPECATALOGVIEWKEY]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterCatalog" object:nil userInfo:userinfo];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
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
        if (indexPath.row != ((NSIndexPath*)[_selectedsort objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]).row) {
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
    //[_table reloadData];
    [_selectedsort setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
    //((SortCell*)cell).imageview.hidden = NO;
    [_table reloadData];
}

@end
