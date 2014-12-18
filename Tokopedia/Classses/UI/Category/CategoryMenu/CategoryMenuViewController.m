//
//  CategoryMenuViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HotlistDetail.h"

#import "DBManager.h"
#import "category.h"
#import "CategoryMenuViewCell.h"
#import "CategoryMenuViewController.h"
#import "DepartmentTree.h"

@interface CategoryMenuViewController () <CategoryMenuViewCellDelegate, UITableViewDataSource, UITableViewDelegate>
{
    // ceck berapa kali view di tampilkan
    NSInteger _pushcount;
    NSMutableArray *_choosenindexpaths;
    BOOL _ispushotomatis;
    
    NSInteger _viewposition;
    
    NSIndexPath *_selectedindexpath;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    NSMutableDictionary *_selectedcategory;
    
    /** url to the next page **/
    NSString *_urinext;
    
    DepartmentTree *_departmenttree;
    
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
    //UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    //UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    //barButtonItem.tag = 10;
    //[previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    _table.delegate = self;
    _table.dataSource = self;
    
    NSArray *departmenttree =[_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY]?:@[];
    if (departmenttree && departmenttree.count>0) {
        NSInteger previousViewType = [[_data objectForKey:DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE]integerValue];
        if (previousViewType == 0) {
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[_data objectForKey:kTKPDCATEGORY_DATADIDALLCATEGORYKEY]?:@(0),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"All Category %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]?:@""]}];
        }
        for (int i = 0 ; i<departmenttree.count; i++) {
            _departmenttree = departmenttree[i];
            if (_departmenttree.child == nil) {
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:_departmenttree.d_id ,kTKPDCATEGORY_DATATITLEKEY:_departmenttree.title,kTKPDCATEGORY_DATAISNULLCHILD:@(YES)}];
            }
            else
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:_departmenttree.d_id,kTKPDCATEGORY_DATATITLEKEY:_departmenttree.title,kTKPDCATEGORY_DATAISNULLCHILD:@(NO),kTKPDCATEGORY_APIDEPARTMENTCHILDKEY:_departmenttree.child}];
        }
    }
    else{
        /** Set isnull value (title and ic on for category) **/
        NSInteger parentid = [[_data objectForKey:kTKPDCATEGORY_DATADEPARTMENTIDKEY]integerValue];
        NSInteger previousViewType = [[_data objectForKey:DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE]integerValue];
        if (previousViewType == 0) {
            if (![_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]) {
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:@"All Category"}];
            }
            else{
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"All Category %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]]}];
            }
            NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",parentid]];
            
            [_menu addObjectsFromArray:data];
            
            /** ceck is have a child or not **/
            for (int i = 1 ; i<_menu.count; i++) {
                NSInteger childparentid = [_menu[i][kTKPDCATEGORY_DATADIDKEY]integerValue];
                NSArray * data= [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",childparentid]];
                if (data == nil || data.count == 0) {
                    [_menu[i] setObject:@(YES) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
                }
                else
                    [_menu[i] setObject:@(NO) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
            }
        }
        NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",parentid]];
        
        [_menu addObjectsFromArray:data];
        
        /** ceck is have a child or not **/
        for (int i = 0 ; i<_menu.count; i++) {
            NSInteger childparentid = [_menu[i][kTKPDCATEGORY_DATADIDKEY]integerValue];
            NSArray * data= [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",childparentid]];
            if (data == nil || data.count == 0) {
                [_menu[i] setObject:@(YES) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
            }
            else
                [_menu[i] setObject:@(NO) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
        }
    }
    //_ispushotomatis = [[_data objectForKey:kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY]boolValue];
    //_selectedindexpath = [_data objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_menu.count > 0) {
        _isnodata = NO;
        _pushcount = [[_data objectForKey: kTKPDCATEGORY_DATAPUSHCOUNTKEY]integerValue]?:0;
        _choosenindexpaths = [NSMutableArray new];
        NSArray *chosenid =[_data objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY];
        [_choosenindexpaths addObjectsFromArray:chosenid?:@[]];

        if (_pushcount>0 && _ispushotomatis) {
            //TODO::
            //if([[_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)]){
            //    [_choosenindexpaths addObject:_selectedindexpath];
            //    CategoryMenuViewController *vc = [CategoryMenuViewController new];
            //    NSArray *childs =[_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:@[];
            //    vc.data = @{kTKPDCATEGORY_APIDEPARTMENTTREEKEY : childs,
            //                kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null],
            //                kTKPDCATEGORY_DATATITLEKEY : [_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY],
            //                kTKPDCATEGORY_DATAPUSHCOUNTKEY : @(_pushcount),
            //                kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : _choosenindexpaths?:@[],
            //                kTKPDCATEGORY_DATAINDEXPATHKEY : _selectedindexpath,
            //                kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @(YES)
            //                };
            //    [self.navigationController pushViewController:vc animated:YES];
            //}
            //else{
            //    [_selectedcategory setObject:_selectedindexpath forKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
            //    [_table reloadData];
            //}
        }
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
                _ispushotomatis = NO;
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
                vc.delegate = self.delegate;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                //Done Action
                NSIndexPath *indexpath = [_selectedcategory objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                
                if (indexpath) {
                    NSDictionary *userinfo = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY],
                                               
                                               kTKPDCATEGORY_DATAPUSHCOUNTKEY : @(_pushcount?:0),
                                               kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : _choosenindexpaths?:@[],
                                               kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @(YES),
                                               kTKPDCATEGORY_DATACATEGORYINDEXPATHKEY :indexpath,
                                               kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY]
                                               };
                    UIViewController *popViewController = (UIViewController*)self.delegate;
                    [self.navigationController popToViewController:popViewController animated:YES];
                    [_delegate CategoryMenuViewController:self userInfo:userinfo];
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
            if (indexPath.row == selectedindex.row && selectedindex) {
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

#pragma mark - Cell Delegate
-(void)CategoryMenuViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath{
    if([[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)]){
        _pushcount ++;
        [_choosenindexpaths addObject:indexpath];
        CategoryMenuViewController *vc = [CategoryMenuViewController new];
        NSArray *childs =[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:@[];
        vc.data = @{kTKPDCATEGORY_APIDEPARTMENTTREEKEY : childs,
                    kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null],
                    kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY],
                    kTKPDCATEGORY_DATAPUSHCOUNTKEY : @(_pushcount),
                    kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : _choosenindexpaths?:@[],
                    kTKPDCATEGORY_DATAINDEXPATHKEY : indexpath,
                    kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY],
                    DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE : @([[_data objectForKey:DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE]integerValue])
                    };
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [_selectedcategory setObject:indexpath forKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
        [_table reloadData];
    }
}

@end
