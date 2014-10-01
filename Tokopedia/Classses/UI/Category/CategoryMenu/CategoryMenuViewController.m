//
//  CategoryMenuViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DBManager.h"
#import "category.h"
#import "CategoryMenuViewCell.h"
#import "CategoryMenuViewController.h"
#import "DepartmentTree.h"

@interface CategoryMenuViewController () <CategoryMenuViewCellDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    NSMutableDictionary *_selectedcategory;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *menu;

@end

@implementation CategoryMenuViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /** create new **/
    _paging = [NSMutableDictionary new];
    _menu = [NSMutableArray new];
    _selectedcategory = [NSMutableDictionary new];
    
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
    
    if (self.navigationController.viewControllers.count==1) {
        img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        }
        else
            barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        
        [barbutton1 setTag:11];
        self.navigationItem.rightBarButtonItem = barbutton1;
    }
    else
    {
        img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            //UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            //barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
            barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
            [barbutton1 setTintColor:[UIColor blackColor]];
            
        }
        else
            barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        [barbutton1 setTag:12];
        self.navigationItem.rightBarButtonItem = barbutton1;

    }
    
    /** set max data per page request **/
    _limit = kTKPDCATEGORYRESULT_LIMITPAGE;
    
    _table.delegate = self;
    _table.dataSource = self;
    
    //TODO set d_id all category
    
    NSArray *departmenttree =[_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY];
    NSArray *departmentchild = [_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY];
    if (departmenttree && departmenttree.count != 0) {
        if (![_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]) {
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(0),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:@"All Category"}];
        }
        else{
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(0),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"All Category %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]]}];
        }
        //[_menu addObjectsFromArray:[_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY]];
        /** ceck is have a child or not **/
        for (int i = 0 ; i<departmenttree.count; i++) {
            DepartmentTree *dt =[_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY][i];
            NSArray * datachild = dt.child;
            if (datachild == nil || datachild.count == 0) {
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:dt.d_id,kTKPDCATEGORY_DATATITLEKEY:dt.title,kTKPDCATEGORY_DATAISNULLCHILD:@(YES)}];
            }
            else
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:dt.d_id,kTKPDCATEGORY_DATATITLEKEY:dt.title,kTKPDCATEGORY_DATAISNULLCHILD:@(NO),kTKPDCATEGORY_APIDEPARTMENTCHILDKEY:datachild}];
        }
    }
    else if (departmentchild) {
        if (![_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]) {
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[_data objectForKey:kTKPDCATEGORY_DATADIDALLCATEGORYKEY],kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:@"All Category"}];
        }
        else{
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[_data objectForKey:kTKPDCATEGORY_DATADIDALLCATEGORYKEY],kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"All Category %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]]}];
        }

        for (int i = 0 ; i<departmentchild.count; i++) {
            NSArray *datachild = [departmentchild[i] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:@"";
            if ([datachild isEqual:@""]) {
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[departmentchild[i] objectForKey:kTKPDCATEGORY_DATADIDKEY],kTKPDCATEGORY_DATATITLEKEY:[departmentchild[i] objectForKey:kTKPDCATEGORY_DATATITLEKEY],kTKPDCATEGORY_DATAISNULLCHILD:@(YES)}];
            }
            else
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[departmentchild[i] objectForKey:kTKPDCATEGORY_DATADIDKEY],kTKPDCATEGORY_DATATITLEKEY:[departmentchild[i] objectForKey:kTKPDCATEGORY_DATATITLEKEY],kTKPDCATEGORY_DATAISNULLCHILD:@(NO),kTKPDCATEGORY_APIDEPARTMENTCHILDKEY:datachild}];
        }
    }
    else{
        /** Set isnull value (title and ic on for category) **/
        NSInteger parentid = [[_data objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY]integerValue];
        if (![_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]) {
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:@"All Category"}];
        }
        else{
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"All Category %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]]}];
        }

        NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%d\" order by weight",parentid]];
        
        [_menu addObjectsFromArray:data];
        
        /** ceck is have a child or not **/
        for (int i = 1 ; i<_menu.count; i++) {
            NSInteger childparentid = [_menu[i][kTKPDCATEGORY_DATADIDKEY]integerValue];
            NSArray * data= [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%d\" order by weight",childparentid]];
            if (data == nil || data.count == 0) {
                [_menu[i] setObject:@(YES) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
            }
            else
                [_menu[i] setObject:@(NO) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
        }
    }
    
    if (_menu.count > 0) {
        _isnodata = NO;
    }
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    
    [_menu removeAllObjects];
    [_paging removeAllObjects];
    [_table reloadData];
    //static dispatch_once_t onceToken;
    
    //dispatch_once (&onceToken, ^{
    //[self request:YES withrefreshControl:refresh];
    //});
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
                if (self.navigationController.viewControllers.count>1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                break;
            }
            case 11:
            {
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                //Done Action
                NSArray *array = [self.navigationController viewControllers];
                NSIndexPath *indexpath = [_selectedcategory objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
                if (indexpath) {
                    NSDictionary *userinfo = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setDepartmentID" object:self userInfo:userinfo];
                    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
                }
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
                //Action Reset
                [_selectedcategory removeAllObjects];
                [_table reloadData];
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
    return _isnodata ? 1 : _menu.count;
#else
    return _isnodata ? 0 : _menu.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER;
		
		cell = (CategoryMenuViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [CategoryMenuViewCell newcell];
			((CategoryMenuViewCell*)cell).delegate = self;
		}

        if (_menu.count > indexPath.row) {
            NSIndexPath *selectedindex =[_selectedcategory objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
            if (selectedindex && indexPath.row == selectedindex.row) {
                [((CategoryMenuViewCell*)cell).imagenext setImage:[UIImage imageNamed:@"icon_check.png"]];
            }
            else{
                if ([[_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)]) {
                    ((CategoryMenuViewCell*)cell).imagenext.hidden = NO;
                    [((CategoryMenuViewCell*)cell).imagenext setImage:[UIImage imageNamed:@"ic_arrow_right.png"]];
                }
                else
                    ((CategoryMenuViewCell*)cell).imagenext.hidden = YES;
            }
            ((CategoryMenuViewCell*)cell).label.text = [_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY];
            ((CategoryMenuViewCell*)cell).indexpath = indexPath;
        }
	} else {
		static NSString *CellIdentifier = kTKPDCATEGORY_STANDARDTABLEVIEWCELLIEDNTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
        
		cell.textLabel.text = kTKPDCATEGORY_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDCATEGORY_NODATACELLDESCS;
	}
	
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@""]) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            //[self request:NO withrefreshControl:nil];
        }
	}
}


#pragma mark - Cell Delegate
-(void)CategoryMenuViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath{
    if([[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)]){
        CategoryMenuViewController *vc = [CategoryMenuViewController new];
        if ([_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY]) {
            vc.data = @{kTKPDCATEGORY_APIDEPARTMENTCHILDKEY: [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY], kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null],kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY]};
        }
        else if ([_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]){
            vc.data = @{kTKPDCATEGORY_APIDEPARTMENTCHILDKEY: [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:[NSNull null], kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null ],kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY]};
        }
        else
        {
            vc.data = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY], kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY]};
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [_selectedcategory setObject:indexpath forKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
        [_table reloadData];
    }
}

@end
