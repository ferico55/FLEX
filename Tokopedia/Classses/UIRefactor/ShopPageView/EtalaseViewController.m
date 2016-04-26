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

@interface EtalaseViewController ()<UITableViewDataSource, UITableViewDelegate, LoadingViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@end

@implementation EtalaseViewController{
    NSMutableArray<EtalaseList*>* etalaseList;
    NSMutableArray<EtalaseList*>* otherEtalaseList;
    
    NSInteger page;
    NSString *uriNext;
    
    EtalaseRequest *etalaseRequest;
    
    NSIndexPath *selectedIndexPath;
    UIAlertView *alertView;
    BOOL _isDeleting;
    BOOL _isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tambahEtalaseButton.layer.cornerRadius = 2;
    self.tambahEtalaseTextField.layer.cornerRadius = 2;
    
    etalaseList = [NSMutableArray new];
    otherEtalaseList = [NSMutableArray new];
    
    etalaseRequest = [EtalaseRequest new];
    page = 1;
    
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
    
    self.title = @"Etalase";
    
    _tableView.tableFooterView = _footerView;
    _tambahEtalaseTextField.delegate = self;
    _tambahEtalaseTextField.tag = 111;
    
    alertView = [[UIAlertView alloc]initWithTitle:@"Edit Etalase" message:@"" delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView textFieldAtIndex:0].tag = 222;
    alertView.delegate = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self requestEtalase];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_enableAddEtalase) {
        self.tambahEtalaseTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 36)];
        self.tambahEtalaseTextField.leftViewMode = UITextFieldViewModeAlways;
        self.tableView.tableHeaderView = _tambahEtalaseView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tambahEtalaseTextField setText:@""];
    selectedIndexPath = indexPath;
    EtalaseList *selectedEtalase = indexPath.section == 0?[otherEtalaseList objectAtIndex:indexPath.row]:[etalaseList objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectEtalaseFilter:)]) {
        [self.delegate didSelectEtalaseFilter:selectedEtalase];
    }
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
        if (uriNext != NULL && ![uriNext isEqualToString:@"0"] && uriNext != 0) {
            [self requestEtalase];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if(section == 0){
//        return 0;
//    }else if(section == 1){
//        return _enableAddEtalase?_tambahEtalaseView.frame.size.height:0;
//    }
//    return 0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_showOtherEtalase && section == 0) {
        return 10;
    }
    return 0;
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if(_enableAddEtalase && section == 1){
//        return _tambahEtalaseView;
//    }
//    return nil;
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isEditable){
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle== UITableViewCellEditingStyleDelete && indexPath.section == 1) {
        [self requestDeleteEtalase:indexPath];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Hapus";
}

#pragma mark - Method
-(IBAction)cancelButtonTapped:(id)sender
{
    [etalaseRequest cancelAllRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)finishButtonTapped:(id)sender
{
    if(selectedIndexPath){
        if(!_isEditable){
            if(selectedIndexPath.section == 0){
                if ([self.delegate respondsToSelector:@selector(didSelectEtalase:)]) {
                    [self.delegate didSelectEtalase:otherEtalaseList[selectedIndexPath.row]];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(didSelectEtalase:)]) {
                    [self.delegate didSelectEtalase:etalaseList[selectedIndexPath.row]];
                }
            }
            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        StickyAlertView *alert = [[StickyAlertView alloc]initWithWarningMessages:@[@"Anda belum memilih atau membuat etalase"] delegate:self];
        [alert show];
    }
}

-(IBAction)deleteButtonTapped:(id)sender{
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
    _isLoading = YES;
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
                                             
                                             [_tableView reloadData];
                                             if(page == 1){
                                                 [self selectInitialSelectedEtalase];
                                             }
                                             uriNext = etalase.result.paging.uri_next;
                                             if (uriNext) {
                                                 page = [[etalaseRequest splitUriToPage:uriNext] integerValue];
                                             }else{
                                                 _tableView.tableFooterView = nil;
                                             }
                                             _isLoading = NO;
                                         } onFailure:^(NSError *error) {
                                             _tableView.tableFooterView = nil;
                                             _isLoading = NO;
                                         }];
}

-(void)selectInitialSelectedEtalase{
    NSIndexPath *selected;
    if(_initialSelectedEtalase){
        NSInteger position = [self etalaseListIndexWithId:_initialSelectedEtalase.etalase_id];
        NSInteger otherPosition = [self otherEtalaseListIndexWithId:_initialSelectedEtalase.etalase_id];
        
        if(position != -1){
            selected = [NSIndexPath indexPathForRow:position inSection:1];
            [_tableView selectRowAtIndexPath:selected
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        }else if(otherPosition != -1){
            selected = [NSIndexPath indexPathForRow:otherPosition inSection:0];
            [_tableView selectRowAtIndexPath:selected
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        }
    }else{
        NSInteger semuaEtalasePosition = [self otherEtalaseListIndexWithId:@"etalase"];
        if(semuaEtalasePosition != -1){
            selected =[NSIndexPath indexPathForRow:semuaEtalasePosition inSection:0];
            [_tableView selectRowAtIndexPath:selected
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    if(selected != nil) selectedIndexPath = selected;
}

-(NSInteger)etalaseListIndexWithId:(NSString*)selectedEtalaseId{
    for(int i=0;i<etalaseList.count;i++){
        if([etalaseList[i].etalase_id isEqualToString:selectedEtalaseId]){
            return i;
        }
    }
    return -1;
}

-(NSInteger)otherEtalaseListIndexWithId:(NSString*)selectedOtherEtalaseId{
    for(int i=0;i<otherEtalaseList.count;i++){
        if([otherEtalaseList[i].etalase_id isEqualToString:selectedOtherEtalaseId]){
            return i;
        }
    }
    return -1;
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
                                             [_tableView reloadData];
                                             if(page == 1){
                                                 [self selectInitialSelectedEtalase];
                                             }
                                             
                                             uriNext = etalase.result.paging.uri_next;
                                             if (uriNext) {
                                                 page = [[etalaseRequest splitUriToPage:uriNext] integerValue];
                                             }else{
                                                 _tableView.tableFooterView = nil;
                                             }
                                             _isLoading = NO;
                                         } onFailure:^(NSError *error) {
                                             _tableView.tableFooterView = nil;
                                             _isLoading = NO;
                                         }];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 111){
        [_tambahEtalaseTextField setText:@""];
        [_tambahEtalaseTextField resignFirstResponder];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int maxLength = 128;
    int textLength = [textField.text length] + [string length] - range.length;
    
    if(textLength > maxLength){
        return NO;
    }else{
        return YES;
    }
}

- (IBAction)tambahEtalaseButtonTapped:(id)sender {
    if(!_isLoading){
        _isLoading = YES;
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
                                                      StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Sukses menambahkan etalase"] delegate:self];
                                                      [alert show];
                                                  }else{
                                                      [self alertForError:shopSettings.message_error];
                                                  }
                                                  _isLoading = NO;
                                              } onFailure:^(NSError *error) {
                                                  [self alertForError:@[@"Kendala koneksi internet"]];
                                                  _isLoading = NO;
                                              }];
    }else{
        StickyAlertView *alert = [[StickyAlertView alloc]initWithWarningMessages:@[@"Masih ada proses yang sedang berlangsung, tunggu beberapa saat dan coba kembali."] delegate:self];
        [alert show];
    }
}

- (void)requestEditEtalase:(NSString*)name{
    if(!_isLoading){
        if(selectedIndexPath.section == 1){
            _isLoading = YES;
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
                                                         [_tableView deleteRowsAtIndexPaths:operationIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                                                         [_tableView insertRowsAtIndexPaths:operationIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                                                         [_tableView endUpdates];
                                                         
                                                         StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Berhasil mengubah nama etalase"] delegate:self];
                                                         [alert show];
                                                     }else{
                                                         [self alertForError:shopSettings.message_error];
                                                     }
                                                     _isLoading = NO;
                                                 } onFailure:^(NSError *error) {
                                                     [self alertForError:@[@"Kendala koneksi internet"]];
                                                     _isLoading = NO;
                                                 }];
        }
    }else{
        StickyAlertView *alert = [[StickyAlertView alloc]initWithWarningMessages:@[@"Masih ada proses yang sedang berlangsung, tunggu beberapa saat dan coba kembali."] delegate:self];
        [alert show];
    }
}

- (void)requestDeleteEtalase:(NSIndexPath*) indexPath{
    if(!_isLoading){
        _isLoading = YES;
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
                                                   _isLoading = NO;
                                               } onFailure:^(NSError *error) {
                                                   [self alertForError:@[@"Kendala koneksi internet"]];
                                                   _isLoading = NO;
                                               }];
    }else{
        StickyAlertView *alert = [[StickyAlertView alloc]initWithWarningMessages:@[@"Masih ada proses yang sedang berlangsung, tunggu beberapa saat dan coba kembali."] delegate:self];
        [alert show];
    }
}

- (void)alertForError:(NSArray*)error{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:error delegate:self];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
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
    [_tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_tambahEtalaseTextField setText:@""];
    [_tambahEtalaseTextField resignFirstResponder];
}
@end
