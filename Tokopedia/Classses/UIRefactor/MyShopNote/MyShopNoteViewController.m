//
//  MyShopNoteViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "generalcell.h"
#import "ShopSettings.h"
#import "URLCacheController.h"
#import "MyShopNoteViewController.h"
#import "MyShopNoteDetailViewController.h"
#import "GeneralList1GestureCell.h"

#import "NoResultView.h"

#import "MGSwipeButton.h"

#import "Tokopedia-Swift.h"

#pragma mark - Setting Note View Controller
@interface MyShopNoteViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    MGSwipeTableCellDelegate,
    MyShopNoteDetailDelegate
>
{
    NSMutableDictionary *_datainput;
    NSMutableArray *_list;
    NSInteger _requestcount;
    BOOL _isnodata;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    NSOperationQueue *_operationQueue;
    
    UIRefreshControl *_refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *buttonadd;

-(void)cancel;

- (IBAction)tap:(id)sender;

@end

@implementation MyShopNoteViewController
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_NOTE;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                    action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;

    UIBarButtonItem *addNoteBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                      target:self
                                                                                      action:@selector(tap:)];
    addNoteBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addNoteBarButton;
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    //Add observer
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(didEditNote:)
                               name:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY
                             object:nil];    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isnodata) {
        [self showNotesList];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALLIST1GESTURECELL_IDENTIFIER;
		
		cell = (GeneralList1GestureCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralList1GestureCell newcell];
			((GeneralList1GestureCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            NotesListSwift *list = _list[indexPath.row];
            ((GeneralList1GestureCell*)cell).textLabel.text = [NSString convertHTML:list.note_title];
            ((GeneralList1GestureCell*)cell).detailTextLabel.hidden = YES;
            ((GeneralList1GestureCell*)cell).indexpath = indexPath;            
            ((GeneralList1GestureCell*)cell).type = kTKPDGENERALCELL_DATATYPETWOBUTTONKEY;
        }
        
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NotesListSwift *list = _list[indexPath.row];
    MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
    vc.delegate = self;
    vc.noteList = list;
    vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                kTKPDDETAIL_DATATYPEKEY: @(kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY),
                kTKPDNOTES_APINOTEIDKEY:list.note_id,
                kTKPDNOTES_APINOTETITLEKEY:list.note_title,
                kTKPDNOTES_APINOTESTATUSKEY:list.note_status,
                kTKPD_SHOPIDKEY : [_data objectForKey:kTKPD_SHOPIDKEY]?:@"",
                };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([sender tag] == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([sender tag] == 11) {
            MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
            vc.delegate = self;
            vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@"",
                        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY),
                        };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
-(void)showNotesList
{
    MyShopNoteRequest *requestNetwork = [MyShopNoteRequest new];
    [requestNetwork requestNoteList:^(NotesSwift * notes) {
        [self actionUponSuccessfulRequestNotesList:notes];
    } onFailure:^(NSError * errorResult) {
        [self actionUponFailRequestNotesList:errorResult];
    }];
    
    [_refreshControl endRefreshing];
    [_act stopAnimating];
}

-(void)actionUponSuccessfulRequestNotesList:(NotesSwift *)notes
{
    _list = [NSMutableArray arrayWithArray:notes.result.list];
    
    if (_list.count>0) {
        _isnodata = NO;
    }
    else
    {
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 103)];
        _table.tableFooterView = noResultView;
        _table.sectionFooterHeight = noResultView.frame.size.height;
    }
    
    [_table reloadData];
}

-(void)actionUponFailRequestNotesList:(NSError *)error
{
    [self cancel];
    if (!([error code] == NSURLErrorCancelled)){
        NSString *errorDescription = error.localizedDescription;
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE
                                                            message:errorDescription
                                                           delegate:self
                                                  cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE
                                                  otherButtonTitles:nil];
        [errorAlert show];
    }
}

-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

#pragma mark Request Action Delete
-(void)cancelActionDelete
{
    [_requestActionDelete cancel];
    _requestActionDelete = nil;
    [_objectmanagerActionDelete.operationQueue cancelAllOperations];
    _objectmanagerActionDelete = nil;
}

-(void)deleteNote:(id)note
{
    MyShopNoteRequest *requestNetwork = [MyShopNoteRequest new];
    
    [requestNetwork requestDeleteNote:note
                            onSuccess:^(ShopSettings *setting) {
                                [self actionUponSuccessfulRequestDelete:setting];
                            }
                            onFailure:^(NSError * error) {
                                [self actionUponFailRequestDelete: error];

                            }];
}
     
-(void)actionUponSuccessfulRequestDelete:(ShopSettings *) setting
{
    if(setting.message_error)
    {
        [self cancelDeleteRow];
        NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
    if (setting.result.is_success == 1) {
        NSInteger noteID = [[_datainput objectForKey:kTKPDNOTES_APINOTEIDKEY] integerValue];
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        NSInteger termID = [[auth getShopHasTerm]integerValue];
        
        if (noteID == termID) {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:SHOULD_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME object:nil];
        }
        
        NSArray *successMessages = setting.message_status?:@[kTKPDNOTE_DELETE_NOTE_SUCCESS];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
        [alert show];
    }
    
    [_act stopAnimating];
    
}

-(void)actionUponFailRequestDelete:(NSError *) error
{
    [self cancelActionDelete];
    NSLog(@" REQUEST FAILURE ERROR %@", [error description]);
    [self cancelDeleteRow];
}

#pragma mark - Methods

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    NotesListSwift *list = _list[indexpath.row];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self deleteNote:list.note_id];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestcount = 0;
    [_list removeAllObjects];
    
    [_table reloadData];
    /** request data **/
    [self showNotesList];
}

#pragma mark - Notification
- (void)didEditNote:(NSNotification*)notification
{
    NSDictionary *userinfo = notification.userInfo;
    //TODO: Behavior after edit
    [_datainput setObject:[userinfo objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDDETAIL_DATAINDEXPATHKEY];
    //[_datainput setObject:[userinfo objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]?:@(0) forKey:kTKPDPROFILE_DATAEDITTYPEKEY];
    [self refreshView:nil];
}

#pragma mark - Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        NSIndexPath *indexpath = ((GeneralList1GestureCell*) cell).indexpath;
        NotesListSwift *list = _list[indexpath.row];
        [_datainput setObject:list.note_id forKey:kTKPDNOTES_APINOTEIDKEY];
        
        UIColor *colorDelete = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus"
                                               backgroundColor:colorDelete
                                                       padding:padding
                                                      callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexpath];
            return YES;
        }];
        trash.titleLabel.font = [UIFont fontWithName:trash.titleLabel.font.fontName size:12];

        UIColor *colorEdit = [UIColor colorWithRed:0 green:122/255.0 blue:255.05 alpha:1.0];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Ubah\nCatatan"
                                              backgroundColor:colorEdit
                                                      padding:padding
                                                     callback:^BOOL(MGSwipeTableCell *sender) {

            NSIndexPath *indexPath = [self.table indexPathForCell:cell];
                                                         
            //edit
            MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
            vc.noteList = [_list objectAtIndex:indexPath.row];
            vc.delegate = self;
            vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@"",
                        kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY),
                        kTKPDNOTES_APINOTEIDKEY : list.note_id,
                        kTKPDNOTES_APINOTESTATUSKEY:list.note_status,
                        kTKPD_SHOPIDKEY : [_data objectForKey:kTKPD_SHOPIDKEY]?:@"",
                        };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
            return YES;
        }];
        flag.titleLabel.font = [UIFont fontWithName:flag.titleLabel.font.fontName size:12];
        return @[trash, flag];
    }
    
    return nil;
    
}

#pragma mark - Note edit delegate

- (void)successEditNote:(NotesListSwift *)noteList {
    NSInteger index = [_list indexOfObject:noteList];
    [_list replaceObjectAtIndex:index withObject:noteList];
    [self.table reloadData];
}

- (void)successCreateNewNote {
    [self showNotesList];
}

@end