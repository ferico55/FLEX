//
//  EtalaseFilterViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EtalaseViewController.h"
#import "EtalaseCell.h"
#import "LoadingView.h"
#import "EtalaseRequest.h"

@interface EtalaseViewController ()<UITableViewDataSource, UITableViewDelegate, LoadingViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@end

@implementation EtalaseViewController{
    NSMutableArray<EtalaseList*>* etalaseList;
    NSMutableArray<EtalaseList*>* otherEtalaseList;
    
    NSInteger page;
    NSString *uriNext;
    
    EtalaseRequest *etalaseRequest;
    
    NSIndexPath *selectedIndexPath;
    UIAlertView *alertView;
    NSString *_urinext;
    BOOL _isDeleting;
    
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    etalaseList = [NSMutableArray new];
    otherEtalaseList = [NSMutableArray new];
    
    etalaseRequest = [EtalaseRequest new];
    page = 0;
    _urinext = @"";
    
    if (self.navigationController.isBeingPresented) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(cancelButtonTapped:)];
        cancelBarButton.tag = 10;
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    if(_isEditable){
        UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Hapus"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:(self)
                                                                           action:@selector(deleteButtonTapped:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }else{
        UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:(self)
                                                                           action:@selector(finishButtonTapped:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
    _tableView.tableFooterView = _footerView;
    _tambahEtalaseTextField.delegate = self;
    _tambahEtalaseTextField.tag = 111;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshEtalase)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    alertView = [[UIAlertView alloc]initWithTitle:@"Edit Etalase" message:@"" delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView textFieldAtIndex:0].tag = 222;
    alertView.delegate = self;
    
    _tambahEtalaseButtonWidthConstraint.constant = 0;
    _tambahEtalaseButtonLeftConstraint.constant = 0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self requestEtalase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideTambahEtalaseButton];
    [_tambahEtalaseTextField setText:@""];
    selectedIndexPath = indexPath;
    EtalaseList *selectedEtalase = indexPath.section == 0?[otherEtalaseList objectAtIndex:indexPath.row]:[etalaseList objectAtIndex:indexPath.row];
    if(_isEditable){
        [[alertView textFieldAtIndex:0] setText:selectedEtalase.etalase_name];
        [alertView show];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"EtalaseCell";
    EtalaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    EtalaseList *currentEtalase;
    if(indexPath.section == 0){
        currentEtalase = [otherEtalaseList objectAtIndex:indexPath.row];
    }else{
        currentEtalase = [etalaseList objectAtIndex:indexPath.row];
    }
    
    [cell.nameLabel setText:currentEtalase.etalase_name];
    [cell.detailLabel setText:[NSString stringWithFormat:@"%@ Produk", currentEtalase.etalase_num_product]];
    
    if(_isEditable){
        [cell.detailLabel setHidden:NO];
    }else{
        [cell.detailLabel setHidden:YES];
    }
    cell.showCheckImage = !_isEditable;
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return _showOtherEtalase?otherEtalaseList.count:0;
    }else if(section == 1){
        return etalaseList.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    NSInteger indexPathRow = indexPath.row;
    if (row <= indexPathRow) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self requestEtalase];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else if(section == 1){
        return _isEditable?_tambahEtalaseView.frame.size.height:0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }else if(section == 1){
        return _footerView.frame.size.height;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_isEditable && section == 1){
        return _tambahEtalaseView;
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideTambahEtalaseButton];
    if (editingStyle== UITableViewCellEditingStyleDelete && indexPath.section == 1) {
        [self requestDeleteEtalase:indexPath];
    }
}

#pragma mark - Method
-(IBAction)cancelButtonTapped:(id)sender
{
    [etalaseRequest cancelAllRequest];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)finishButtonTapped:(id)sender
{
    if(!_isEditable){
        if(selectedIndexPath.section == 0){
            [_delegate didSelectEtalase:otherEtalaseList[selectedIndexPath.row]];
        }else{
            [_delegate didSelectEtalase:etalaseList[selectedIndexPath.row]];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)deleteButtonTapped:(id)sender{
    [self hideTambahEtalaseButton];
    if(_isDeleting){
        [_tableView setEditing:NO animated:YES];
        UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Hapus"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:(self)
                                                                           action:@selector(deleteButtonTapped:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        _isDeleting = NO;
    }else{
        [_tableView setEditing:YES animated:YES];
        UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:(self)
                                                                           action:@selector(deleteButtonTapped:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
        _isDeleting = YES;
    }
}


#pragma mark - Request

-(void)requestEtalase{
    _tableView.tableFooterView = _footerView;
    if(_showOtherEtalase){
        [self requestCertainShopEtalase];
    }else{
        [self requestMyEtalase];
    }
}

-(void)requestCertainShopEtalase{
    [etalaseRequest requestEtalaseFilterWithShopId:_shopId
                                              page:page
                                         onSuccess:^(Etalase *etalase) {
                                             if(page == 1){
                                                 [etalaseList removeAllObjects];
                                                 [otherEtalaseList removeAllObjects];
                                             }
                                             [etalaseList addObjectsFromArray:etalase.result.list];
                                             [otherEtalaseList addObjectsFromArray:etalase.result.list_other];
                                             
                                             uriNext = etalase.result.paging.uri_next;
                                             _urinext = uriNext;
                                             if (uriNext) {
                                                 page = [[etalaseRequest splitUriToPage:uriNext] integerValue];
                                             }else{
                                                 _tableView.tableFooterView = nil;
                                             }
                                             
                                             [_tableView reloadData];
                                         } onFailure:^(NSError *error) {
                                             _tableView.tableFooterView = nil;
                                         }];
    [_refreshControl endRefreshing];
}

-(void)requestMyEtalase{
    [etalaseRequest requestMyShopEtalaseWithShopId:_shopId
                                              page:page
                                         onSuccess:^(Etalase *etalase) {
                                             if(page == 1){
                                                 [etalaseList removeAllObjects];
                                                 [otherEtalaseList removeAllObjects];
                                             }
                                             [etalaseList addObjectsFromArray:etalase.result.list];
                                             [otherEtalaseList addObjectsFromArray:etalase.result.list_other];
                                             
                                             uriNext = etalase.result.paging.uri_next;
                                             _urinext = uriNext;
                                             if (uriNext) {
                                                 page = [[etalaseRequest splitUriToPage:uriNext] integerValue];
                                             }else{
                                                 _tableView.tableFooterView = nil;
                                             }
                                             
                                             [_tableView reloadData];
                                         } onFailure:^(NSError *error) {
                                             _tableView.tableFooterView = nil;
                                         }];
    [_refreshControl endRefreshing];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 111){
        [_tambahEtalaseTextField setText:@""];
        [_tambahEtalaseTextField resignFirstResponder];
        [UIView animateWithDuration:1 animations:^{
        }];
        [UIView animateWithDuration:2
                              delay:0
             usingSpringWithDamping:0
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self hideTambahEtalaseButton];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField.tag == 111){
        [UIView animateWithDuration:2
                              delay:0
             usingSpringWithDamping:0
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [_tambahEtalaseButtonWidthConstraint setConstant:70];
                             [_tambahEtalaseButtonLeftConstraint setConstant:8];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}
- (IBAction)tambahEtalaseButtonTapped:(id)sender {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *loginData = [auth getUserLoginData];
    NSString *userId = [loginData objectForKey:@"user_id"]?:@"";
    [etalaseRequest requestActionAddEtalaseWithName:[_tambahEtalaseTextField text]
                                             userId:userId
                                          onSuccess:^(ShopSettings *shopSettings) {
                                              if(shopSettings.result.is_success == 1){
                                                  EtalaseList *newEtalase = [EtalaseList new];
                                                  [newEtalase setEtalase_id:shopSettings.result.etalase_id];
                                                  [newEtalase setEtalase_name:[_tambahEtalaseTextField text]];
                                                  [newEtalase setEtalase_num_product:@"0"];
                                                  [newEtalase setEtalase_total_product:@"0"];
                                                  
                                                  [etalaseList insertObject:newEtalase atIndex:0];
                                                  NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                                                               [NSIndexPath indexPathForRow:0 inSection:1],nil
                                                                               ];
                                                  [_tableView beginUpdates];
                                                  [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                                                  [_tableView endUpdates];
                                                  [_tambahEtalaseTextField.delegate textFieldShouldReturn:_tambahEtalaseTextField];
                                              }else{
                                                  [self alertForError:shopSettings.message_error];
                                              }
                                          } onFailure:^(NSError *error) {
                                              [self alertForError:@[@"Kendala koneksi internet"]];
                                          }];
}

- (void)requestEditEtalase:(NSString*)name{
    if(selectedIndexPath.section == 1){
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        NSDictionary *loginData = [auth getUserLoginData];
        NSString *userId = [loginData objectForKey:@"user_id"]?:@"";
        EtalaseList *selectedEtalase = [etalaseList objectAtIndex:selectedIndexPath.row];
        [etalaseRequest requestActionEditEtalaseWithId:selectedEtalase.etalase_id
                                                  name:name
                                                userId:userId
                                             onSuccess:^(ShopSettings *shopSettings, NSString* name) {
                                                 if(shopSettings.result.is_success){
                                                     EtalaseList *selectedEtalase = [etalaseList objectAtIndex:selectedIndexPath.row];
                                                     EtalaseList *newEtalase = [EtalaseList new];
                                                     [newEtalase setEtalase_id:selectedEtalase.etalase_id];
                                                     [newEtalase setEtalase_name:name];
                                                     [newEtalase setEtalase_num_product:selectedEtalase.etalase_num_product];
                                                     [newEtalase setEtalase_total_product:selectedEtalase.etalase_total_product];
                                                     
                                                     [etalaseList replaceObjectAtIndex:selectedIndexPath.row withObject:newEtalase];
                                                     
                                                     NSArray *operationIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:selectedIndexPath.row inSection:selectedIndexPath.section], nil];
                                                     
                                                     [_tableView beginUpdates];
                                                     [_tableView deleteRowsAtIndexPaths:operationIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                                                     [_tableView insertRowsAtIndexPaths:operationIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                                                     [_tableView endUpdates];
                                                 }else{
                                                     [self alertForError:shopSettings.message_error];
                                                 }
                                             } onFailure:^(NSError *error) {
                                                 [self alertForError:@[@"Kendala koneksi internet"]];
                                             }];
    }
}

- (void)requestDeleteEtalase:(NSIndexPath*) indexPath{
    EtalaseList *selectedEtalase = [etalaseList objectAtIndex:indexPath.row];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *loginData = [auth getUserLoginData];
    NSString *userId = [loginData objectForKey:@"user_id"]?:@"";
    [etalaseRequest requestActionDeleteEtalaseWithId:selectedEtalase.etalase_id
                                              userId:userId
                                           onSuccess:^(ShopSettings *shopSettings) {
                                               if(shopSettings.result.is_success == 1){
                                                   [etalaseList removeObjectAtIndex:indexPath.row];
                                                   [_tableView beginUpdates];
                                                   [_tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                                                   [_tableView endUpdates];
                                               }else{
                                                   [self alertForError:shopSettings.message_error];
                                               }
                                           } onFailure:^(NSError *error) {
                                               [self alertForError:@[@"Kendala koneksi internet"]];
                                           }];

}

-(void)refreshEtalase{
    page = 1;
    [etalaseList removeAllObjects];
    [otherEtalaseList removeAllObjects];
    [self requestEtalase];
}

- (void)alertForError:(NSArray*)error{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:error delegate:self];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self hideTambahEtalaseButton];
    if(buttonIndex == 0){
        //batal
    }else if(buttonIndex == 1){
        //OK
        [self requestEditEtalase:[alertView textFieldAtIndex:0].text];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [_tambahEtalaseTextField resignFirstResponder];
    [_tambahEtalaseTextField setText:@""];
    [self hideTambahEtalaseButton];
    [_tableView reloadData];
}

- (void)hideTambahEtalaseButton{
    _tambahEtalaseButtonLeftConstraint.constant = 0;
    _tambahEtalaseButtonWidthConstraint.constant = 0;
}
@end
