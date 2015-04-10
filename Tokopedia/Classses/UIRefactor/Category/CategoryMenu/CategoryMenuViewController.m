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

@interface CategoryMenuViewController () <UITableViewDataSource, UITableViewDelegate>
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
    BOOL _isBeingPresented;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *menu;

@end

@implementation CategoryMenuViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Kategori";
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _choosenindexpaths = [NSMutableArray new];
    _paging = [NSMutableDictionary new];
    _menu = [NSMutableArray new];
    _selectedcategory = [NSMutableDictionary new];

    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
        button.tag = 10;
        self.navigationItem.leftBarButtonItem = button;
    } else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
        self.navigationItem.backBarButtonItem = button;
    }
    
    /** set max data per page request **/
    _table.delegate = self;
    _table.dataSource = self;
    
    [self adjustCategoryMenu];
    
    NSArray *choosenIndexPath =[_data objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY];
    [_choosenindexpaths removeAllObjects];
    [_choosenindexpaths addObjectsFromArray:choosenIndexPath?:@[]];
    _ispushotomatis = [[_data objectForKey:kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY]boolValue];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustChoosenIndexPath:)
                                                 name:CATALOG_SELECTED_INDEXPATH_POST_NOTIFICATION_NAME
                                               object:nil];
    
    if (_menu.count > 0) {
        _isnodata = NO;
        _pushcount = [[_data objectForKey: kTKPDCATEGORY_DATAPUSHCOUNTKEY]integerValue]?:0;

        if (_pushcount>0 && _ispushotomatis) {
            self.view.userInteractionEnabled = NO;
            [self performSelector:@selector(pushSelf) withObject:nil afterDelay:1.0]; //TODO::
        }
        else if (_pushcount==0 && _ispushotomatis)
        {
            NSIndexPath *selectedindexpath = [_data objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            [_selectedcategory setObject:selectedindexpath forKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
            [_table reloadData];
        }
    }
    
    NSLog(@"choosen indexpath %@", _choosenindexpaths);
    NSLog(@"push count %zd", _pushcount);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_choosenindexpaths removeAllObjects];
    [_choosenindexpaths addObjectsFromArray:(NSArray*)[_data objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY]];
    NSInteger pushCount=self.navigationController.viewControllers.count-2;
    if (_choosenindexpaths.count>pushCount) {
        [_choosenindexpaths removeLastObject];
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
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            case 11:
            {
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                vc.delegate = self.delegate;
                [self.navigationController pushViewController:vc animated:YES];
                break;
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
        }

        if (_menu.count > indexPath.row) {
            NSIndexPath *selectedindex =[_selectedcategory objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
            if (indexPath.row == selectedindex.row && selectedindex) {
                [((CategoryMenuViewCell*)cell).imagenext setImage:[UIImage imageNamed:@"icon_check_orange.png"]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)]){
        NSInteger pushcount =self.navigationController.viewControllers.count-2;
        if (_choosenindexpaths.count>pushcount) {
            [_choosenindexpaths removeLastObject];
        }
        [_choosenindexpaths addObject:indexPath];
        CategoryMenuViewController *vc = [CategoryMenuViewController new];
        NSArray *childs =[_menu[indexPath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:@[];
        vc.data = @{kTKPDCATEGORY_APIDEPARTMENTTREEKEY : childs,
                    kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null],
                    kTKPDCATEGORY_DATATITLEKEY : [_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY],
                    kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : _choosenindexpaths?:@[],
                    kTKPDCATEGORY_DATAINDEXPATHKEY : indexPath,
                    kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexPath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY],
                    DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE : @([[_data objectForKey:DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE]integerValue])
                    };
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        NSInteger pushcount = self.navigationController.viewControllers.count-2;
        if (_choosenindexpaths.count > pushcount) {
            [_choosenindexpaths removeLastObject];
        }
        [_choosenindexpaths addObject:indexPath];
        [_selectedcategory setObject:indexPath forKey:kTKPDCATEGORY_DATAINDEXPATHKEY];
        [_table reloadData];
        
        _pushcount =self.navigationController.viewControllers.count-2; 
        
        NSIndexPath *indexpath = [_selectedcategory objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
        NSDictionary *userinfo = @{kTKPDCATEGORY_DATADEPARTMENTIDKEY:[_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY],
                                   
                                   kTKPDCATEGORY_DATAPUSHCOUNTKEY : @(_pushcount?:0),
                                   kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : _choosenindexpaths?:@[],
                                   kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @(YES),
                                   kTKPDCATEGORY_DATACATEGORYINDEXPATHKEY :indexpath,
                                   kTKPDCATEGORY_DATATITLEKEY : [_menu[indexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY]
                                   };
        [_delegate CategoryMenuViewController:self userInfo:userinfo];
        //if (_isBeingPresented) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //} else {
        //    NSArray *viewControllers = self.navigationController.viewControllers;
        //    UIViewController *destinationVC = nil;
        //    for (UIViewController *vc in viewControllers) {
        //        if ([vc isKindOfClass:[_delegate class]]) {
        //            destinationVC = vc;
        //            break;
        //        }
        //    }
        //    if (destinationVC)
        //        [self.navigationController popToViewController:destinationVC animated:YES];
        //    else
        //        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //}
    }
}

#pragma mark - Methods
-(void)adjustCategoryMenu
{
    NSArray *departmenttree =[_data objectForKey:kTKPDCATEGORY_APIDEPARTMENTTREEKEY]?:@[];
    if (departmenttree && departmenttree.count>0) {
        NSInteger previousViewType = [[_data objectForKey:DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE]integerValue];
        if (previousViewType == 0) {
            [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:[_data objectForKey:kTKPDCATEGORY_DATADIDALLCATEGORYKEY]?:@(0),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"Semua Kategori %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]?:@""]}];
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
        if (previousViewType != CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT) {
            if (![_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]) {
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:@"Semua Kategori"}];
            }
            else{
                [_menu addObject:@{kTKPDCATEGORY_DATADIDKEY:@(parentid),kTKPDCATEGORY_DATAISNULLCHILD:@(1),kTKPDCATEGORY_DATATITLEKEY:[NSString stringWithFormat:@"Semua Kategori %@",[_data objectForKey:kTKPDCATEGORY_DATATITLEKEY]]}];
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
        else{
            NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",parentid]];
            
            [_menu addObjectsFromArray:data];
            
            /** ceck is have a child or not **/
            for (int i = 0 ; i<_menu.count; i++) {
                NSInteger childparentid = [_menu[i][kTKPDCATEGORY_DATADIDKEY]integerValue];
                NSArray * data= [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%zd\" order by weight",childparentid]];
                NSMutableDictionary *menu = [NSMutableDictionary new];
                [menu addEntriesFromDictionary: _menu[i]];
                if (data == nil || data.count == 0) {
                    [menu setObject:@(YES) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
                }
                else
                    [menu setObject:@(NO) forKey:kTKPDCATEGORY_DATAISNULLCHILD];
                [_menu replaceObjectAtIndex:i withObject:menu];
            }
        }
    }
}

-(void)pushSelf
{
    NSIndexPath *selectedindexpath = [_data objectForKey:kTKPDCATEGORY_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    //[_choosenindexpaths addObject:selectedindexpath];
    NSInteger choosenIndexPathsIndex = (_pushcount>0)?(_choosenindexpaths.count) - _pushcount:_choosenindexpaths.count-1;
    if (choosenIndexPathsIndex <0) {
        choosenIndexPathsIndex = _choosenindexpaths.count-1;
    }
    _selectedindexpath = (_choosenindexpaths)?_choosenindexpaths[choosenIndexPathsIndex]:[NSIndexPath indexPathForRow:0 inSection:0];
    NSLog(@"selected indexpath %@", _selectedindexpath);
    if([[_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATAISNULLCHILD] isEqual:@(0)] && _selectedindexpath.row<_menu.count){
        CategoryMenuViewController *vc = [CategoryMenuViewController new];
        NSArray *childs =[_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_APIDEPARTMENTCHILDKEY]?:@[];
        vc.data = @{kTKPDCATEGORY_APIDEPARTMENTTREEKEY : childs,
                    kTKPDCATEGORY_DATADIDALLCATEGORYKEY: [_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATADIDKEY]?:[NSNull null],
                    kTKPDCATEGORY_DATATITLEKEY : [_menu[_selectedindexpath.row] objectForKey:kTKPDCATEGORY_DATATITLEKEY],
                    kTKPDCATEGORY_DATAPUSHCOUNTKEY : @(_pushcount-1),
                    kTKPDCATEGORY_DATACHOSENINDEXPATHKEY : [_data objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY]?:@[],
                    kTKPDCATEGORY_DATAINDEXPATHKEY : selectedindexpath,
                    kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY : @(_ispushotomatis)
                    };
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:NO];
        self.view.userInteractionEnabled = YES;
    }
}

-(void)adjustChoosenIndexPath:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSArray *choosenNotification = [userInfo objectForKey:kTKPDCATEGORY_DATACHOSENINDEXPATHKEY];
    [_choosenindexpaths removeAllObjects];
    [_choosenindexpaths addObjectsFromArray:choosenNotification];
    [_choosenindexpaths removeLastObject];
    _pushcount -=1;
}

@end
