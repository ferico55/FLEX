//
//  SearchViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "SearchCell.h"
#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "TKPDTabNavigationController.h"
#import "ProductFeedViewController.h"

@interface SearchViewController ()<
    UISearchBarDelegate,
    UISearchBarDelegate,
    UISearchDisplayDelegate,
    SearchCellDelegate>
{
    /** real time search result array **/
    NSMutableArray *_searchresultarray;
    /** variable for segment control **/
    NSString *_filter;
    /** all histories from property list **/
    NSMutableArray *_historysearch;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonclear;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UIView *searchhistoryview;
@property (weak, nonatomic) IBOutlet UILabel *labelsearchfor;


@end

@implementation SearchViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SearchViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDSEARCH_TITLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    _historysearch =[NSMutableArray new];
    _searchresultarray = [NSMutableArray new];
    
    _searchbar.delegate = self;
    
    /** set default to product **/
//    [_segmentcontrol setSelectedSegmentIndex:0];
//    [_segmentcontrol sendActionsForControlEvents:UIControlEventValueChanged];
    _filter = @"search_product";
    
    [self LoadHistory];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchbar becomeFirstResponder];
}

#pragma mark - Memory Management

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
-(void)SaveHistory:(id)history{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    [_historysearch insertObject:history atIndex:0];
    [_historysearch writeToFile:destPath atomically:YES];
    
    [_table reloadData];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}

-(void)LoadHistory
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    // If the file doesn't exist in the Documents Folder, copy it.
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    if (![fileManager fileExistsAtPath:destPath]) {
//        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"history_search" ofType:@"plist"];
//        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
//    }
    
    // Load the Property List
    [_historysearch addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:destPath]];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}

-(void)ClearHistories
{
    [_historysearch removeAllObjects];
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"history_search" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    [_historysearch writeToFile:destPath atomically:YES];
    
    [_table reloadData];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}

#pragma mark - View Gesture
- (IBAction)tap:(id)sender {
    [_searchbar resignFirstResponder];
    [self ClearHistories];
}
- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_searchbar resignFirstResponder];
            break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_searchresultarray == nil || _searchresultarray.count == 0) {
        return [_historysearch count];
    } else {
        return [_searchresultarray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDCATEGORYCELL_IDENTIFIER;
    
    cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [SearchCell newcell];
        ((SearchCell*)cell).delegate = self;
    }
    
    // Display recipe in the table cell
    NSString *searchresult;
    if (_searchresultarray == nil || _searchresultarray.count == 0) {
        searchresult = [_historysearch objectAtIndex:indexPath.row];
    } else {
        searchresult = [_searchresultarray objectAtIndex:indexPath.row];
    }
    if (_historysearch.count > indexPath.row) {
        ((SearchCell*)cell).data = @{kTKPDSEARCH_DATAINDEXPATHKEY: indexPath, kTKPDSEARCH_DATACOLUMNSKEY: searchresult};
    }
	
	return cell;
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchresultarray removeAllObjects];
    if (![searchBar.text isEqualToString: @""]&&![searchBar.text isEqualToString:@" "]) {
        _labelsearchfor.hidden = NO;
        //_labelsearchfor.text = [NSString stringWithFormat:@"Search for '%@'", searchBar.text];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        NSArray *historiesresult;
        historiesresult = [_historysearch filteredArrayUsingPredicate:resultPredicate];
        [_searchresultarray addObjectsFromArray:historiesresult];
        [_table reloadData];
    }
    else
    {
        [_searchresultarray removeAllObjects];
        [_table reloadData];
        _labelsearchfor.hidden = YES;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchresultarray removeAllObjects];
    [_searchbar resignFirstResponder];
    NSArray *histories = _historysearch;
    
    if (![_searchbar.text isEqualToString: @""]&&![searchBar.text isEqualToString: @" "]) {
        
        if (histories.count == 0 || [histories isEqualToArray: @[]]) {
            [self SaveHistory:searchBar.text];
        }
        else{
            if (![histories containsObject:searchBar.text]) {
                [self SaveHistory:searchBar.text];
            }
        }
        
        //_searchbar.text = nil;
        
        /** Goto result page **/
        SearchResultViewController *vc = [SearchResultViewController new];
        vc.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                   kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,
                   kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
        NSArray *viewcontrollers = @[vc,vc1,vc2];
        
        TKPDTabNavigationController *c = [TKPDTabNavigationController new];
        
        [c setSelectedIndex:0];
        [c setViewControllers:viewcontrollers];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
        [nav.navigationBar setTranslucent:NO];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        [_searchresultarray removeAllObjects];
        [_table reloadData];
    }
}

#pragma mark - cell delegate
-(void)SearchCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withdata:(NSDictionary *)data
{
    SearchResultViewController *vc = [SearchResultViewController new];
    NSString *searchtext = [data objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    vc.data =@{kTKPDSEARCH_DATASEARCHKEY : searchtext?:@"" ,
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,
               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : searchtext?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : searchtext?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *c = [TKPDTabNavigationController new];
    
    [c setSelectedIndex:0];
    [c setViewControllers:viewcontrollers];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
    [nav.navigationBar setTranslucent:NO];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

@end
