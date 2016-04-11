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

@interface EtalaseViewController ()<UITableViewDataSource, UITableViewDelegate, LoadingViewDelegate, UITextFieldDelegate>

@end

@implementation EtalaseViewController{
    NSMutableArray<EtalaseList*>* etalaseList;
    NSMutableArray<EtalaseList*>* otherEtalaseList;
    
    NSInteger page;
    NSString *uriNext;
    
    TokopediaNetworkManager *etalaseNetworkManager;
    TokopediaNetworkManager *myEtalaseNetworkManager;
    
    NSIndexPath *selectedIndexPath;
    UIAlertView *alertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    etalaseList = [NSMutableArray new];
    otherEtalaseList = [NSMutableArray new];
    
    etalaseNetworkManager = [TokopediaNetworkManager new];
    myEtalaseNetworkManager = [TokopediaNetworkManager new];
    page = 0;
    
    if (self.navigationController.isBeingPresented) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(cancelButtonTapped:)];
        cancelBarButton.tag = 10;
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    
    UIBarButtonItem  *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:(self)
                                                                       action:@selector(finishButtonTapped:)];
    rightBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _tableView.tableFooterView = _footerView;
    _tambahEtalaseTextField.delegate = self;
    alertView = [[UIAlertView alloc]initWithTitle:@"Edit Etalase" message:@"" delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    
    _tambahEtalaseButtonWidthConstraint.constant = 0;
    _tambahEtalaseButtonLeftConstraint.constant = 0;
    
    [self requestEtalase];
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
        return _isEditable?0:otherEtalaseList.count;
    }else if(section == 1){
        return etalaseList.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 15;
    }else if(section == 1){
        return _isEditable?_tambahEtalaseView.frame.size.height:0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return 10;
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

#pragma mark - Method
-(IBAction)cancelButtonTapped:(id)sender
{
    [etalaseNetworkManager requestCancel];
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
    etalaseNetworkManager.isUsingHmac = YES;
    [etalaseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/shop/get_shop_etalase.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"shop_id"    : _shopId,
                                          @"page"       : @(page)}
                                mapping:[Etalase mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  Etalase *etalase = [successResult.dictionary objectForKey:@""];
                                  [etalaseList addObjectsFromArray:etalase.result.list];
                                  [otherEtalaseList addObjectsFromArray:etalase.result.list_other];
                                  
                                  uriNext = etalase.result.paging.uri_next;
                                  if (uriNext) {
                                      page = [[etalaseNetworkManager splitUriToPage:uriNext] integerValue];
                                  }else{
                                      _tableView.tableFooterView = nil;
                                  }
                                  
                                  [_tableView reloadData];
                              }onFailure:^(NSError *errorResult) {
                                    _tableView.tableFooterView = nil;
                              }];

}

-(void)requestMyEtalase{
    myEtalaseNetworkManager.isUsingHmac = YES;
    [myEtalaseNetworkManager requestWithBaseUrl:[NSString v4Url]
                                           path:@"/v4/myshop-etalase/get_shop_etalase.pl"
                                         method:RKRequestMethodGET
                                      parameter:@{@"shop_id"    : _shopId,
                                                  @"page"       : @(page)}
                                        mapping:[Etalase mapping]
                                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                          Etalase *etalase = [successResult.dictionary objectForKey:@""];
                                          [etalaseList addObjectsFromArray:etalase.result.list];
                                          [otherEtalaseList addObjectsFromArray:etalase.result.list_other];
                                          
                                          uriNext = etalase.result.paging.uri_next;
                                          if (uriNext) {
                                              page = [[etalaseNetworkManager splitUriToPage:uriNext] integerValue];
                                          }else{
                                              _tableView.tableFooterView = nil;
                                          }
                                          
                                          [_tableView reloadData];
                                      }onFailure:^(NSError *errorResult) {
                                          _tableView.tableFooterView = nil;
                                      }];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_tambahEtalaseTextField setText:@""];
    [_tambahEtalaseTextField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [_tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    [UIView animateWithDuration:1 animations:^{
    }];
    [UIView animateWithDuration:2
                          delay:0
         usingSpringWithDamping:0
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_tambahEtalaseButtonWidthConstraint setConstant:30];
                         [_tambahEtalaseButtonLeftConstraint setConstant:8];
                     } completion:^(BOOL finished) {
                         
                     }];
}
- (IBAction)tambahEtalaseButtonTapped:(id)sender {
    
}

@end
