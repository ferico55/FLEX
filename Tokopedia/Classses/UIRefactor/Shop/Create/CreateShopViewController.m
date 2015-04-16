//
//  CreateShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "CreateShopCell.h"
#import "CreateShopViewController.h"
#import "AddShop.h"
#import "AddShopResult.h"
#import "string_create_shop.h"
#import "ShopDeliveryViewController.h"

@implementation CustomHeaderFooterTable
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    id result = [super initWithReuseIdentifier:reuseIdentifier];
    if(result)
    {
    }
    
    return result;
}

- (void)initLbl:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect isHeader:(BOOL)isHeader
{
    if(isHeader)
    {
        lblHeader = [[UILabel alloc] initWithFrame:rect];
        lblHeader.backgroundColor = [UIColor clearColor];
        lblHeader.font = font;
        lblHeader.textColor = color;
        lblHeader.numberOfLines = 0;
        [self.contentView addSubview:lblHeader];
    }
    else
    {
        lblFooter = [[UILabel alloc] initWithFrame:rect];
        lblFooter.backgroundColor = [UIColor clearColor];
        lblFooter.font = font;
        lblFooter.textColor = color;
        lblFooter.numberOfLines = 0;
        [self.contentView addSubview:lblFooter];
    }
}

- (void)initBtn:(UIFont *)font andColor:(UIColor *)color andFrame:(CGRect)rect
{
    btnCheckDomain = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCheckDomain.backgroundColor = CBackgroundBtnCheckDomain;
    btnCheckDomain.titleLabel.font = font;
    [btnCheckDomain setTitleColor:color forState:UIControlStateNormal];
    [self.contentView addSubview:btnCheckDomain];
}

- (void)setBtnFrame:(CGRect)rect
{
    btnCheckDomain.frame = rect;
}

- (void)setLblFrame:(CGRect)rect isHeader:(BOOL)isHeader
{
    if(isHeader)
        lblHeader.frame = rect;
    else
        lblFooter.frame = rect;
}

- (UILabel *)getLblHeader
{
    return lblHeader;
}

- (UILabel *)getLblFooter
{
    return lblFooter;
}

- (UIButton *)getBtnCheckDomain
{
    return btnCheckDomain;
}
@end










@interface CreateShopViewController ()
@end

@implementation CreateShopViewController
{
    BOOL hasLoadViewWillAppear, isValidDomain, hasSetImgGambar;
    RKObjectManager *objectManager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    UIActivityIndicatorView *loadViewCheckDomain;
    UIView *viewImgGambar;
    UIImageView *imgGambar;
    UITextField *txtDomain, *txtNamaToko, *txtSlogan, *txtDesc, *activeTextField;
    UILabel *lblCountSlogan, *lblCountDescripsi;
    UIButton *btnLanjut;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    
    btnLanjut = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLanjut.frame = CGRectMake(0, 0, 50, self.navigationController.navigationBar.bounds.size.height);
    [btnLanjut setTitle:CStringLanjut forState:UIControlStateNormal];
    [btnLanjut addTarget:self action:@selector(lanjut:) forControlEvents:UIControlEventTouchUpInside];
    [self enableLanjut:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLanjut];
    self.hidesBottomBarWhenPushed = YES;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    btnLanjut.enabled = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(! hasLoadViewWillAppear)
    {
        hasLoadViewWillAppear = !hasLoadViewWillAppear;
        tblCreateShop.allowsSelection = NO;
        tblCreateShop.userInteractionEnabled = YES;
        [tblCreateShop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - View
- (void)initNavigation
{
    // Add logo in navigation bar
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
}

- (void)enableLanjut:(BOOL)isEnable
{
    btnLanjut.enabled = isEnable;
    [btnLanjut setTitleColor:(isEnable? [UIColor whiteColor]:[UIColor lightGrayColor]) forState:UIControlStateNormal];
}


#pragma mark - Method
- (NSString *)getNamaToko
{
    NSString *rawString = txtNamaToko.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    return [rawString stringByTrimmingCharactersInSet:whitespace];
}

- (void)checkValidation:(NSString *)strNamaToko
{
    if(isValidDomain && hasSetImgGambar)
    {
        if(strNamaToko == nil)
            strNamaToko = [self getNamaToko];
        
        if(strNamaToko.length == 0)
            [self enableLanjut:NO];
        else
            [self enableLanjut:YES];
    }
    else
        [self enableLanjut:NO];
}

- (void)isCheckingDomain:(BOOL)isCheckingDomain
{
    CustomHeaderFooterTable *tempCustomHeaderFooterTable = ((CustomHeaderFooterTable *) [tblCreateShop footerViewForSection:0]);
    if(isCheckingDomain)
    {
        loadViewCheckDomain = [UIActivityIndicatorView new];
        loadViewCheckDomain.frame = CGRectMake((self.view.bounds.size.width-[tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height)/2.0f, [tempCustomHeaderFooterTable getBtnCheckDomain].frame.origin.y, [tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height, [tempCustomHeaderFooterTable getBtnCheckDomain].bounds.size.height);
        [loadViewCheckDomain startAnimating];
        loadViewCheckDomain.color = [UIColor lightGrayColor];
        
        //Add activity indicator
        [tempCustomHeaderFooterTable.contentView addSubview:loadViewCheckDomain];
        [tempCustomHeaderFooterTable getBtnCheckDomain].hidden = YES;
    }
    else
    {
        [loadViewCheckDomain stopAnimating];
        [loadViewCheckDomain removeFromSuperview];
        loadViewCheckDomain = nil;
        
        [tempCustomHeaderFooterTable getBtnCheckDomain].hidden = NO;
    }
}

- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}

- (void)resignKeyboard:(id)sender
{
    [activeTextField resignFirstResponder];
    activeTextField = nil;
}

- (void)showKeyboard:(id)sender
{
    CGSize keyboardSize = [[[sender userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    
    CGRect tblRect = tblCreateShop.frame;
    tblRect.size.height = self.view.bounds.size.height-height;
    tblCreateShop.frame = tblRect;
}

- (void)hideKeyboard:(id)sender
{
    CGRect tblRect = tblCreateShop.frame;
    tblRect.size.height = self.view.bounds.size.height;
    tblCreateShop.frame = tblRect;
}

- (float)calculateHeight:(NSString *)strText withFont:(UIFont *)font andSize:(CGSize)size
{
    UILabel *lblMeasure = [UILabel new];
    lblMeasure.text = strText;
    lblMeasure.font = font;
    lblMeasure.numberOfLines = 0;
    return [lblMeasure sizeThatFits:size].height;
}


#pragma mark - Action View
- (void)lanjut:(id)sender
{
    ShopDeliveryViewController *shopDeliveryViewController = [ShopDeliveryViewController new];
    shopDeliveryViewController.createShopViewController = self;
    [self.navigationController pushViewController:shopDeliveryViewController animated:YES];
}

- (void)showImage:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:CStringChoose
                                                             delegate:self
                                                    cancelButtonTitle:CStringCancel
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:CStringPickCamera, CStringPickGallery, nil];
    [actionSheet showInView:self.view];
}


- (void)checkDomain:(UIButton *)sender
{
    if(txtDomain.text.length == 0)
    {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringValidationFillDomain] delegate:self];
        [stickyAlertView show];
    }
    else
    {
        [self isCheckingDomain:YES];
        [[self getNetworkManager] doRequest];
    }
}


#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CustomHeaderFooterTable *customHeaderFooterTable = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CTagFooterCell];
    if(customHeaderFooterTable == nil)
    {
        customHeaderFooterTable = [[CustomHeaderFooterTable alloc] initWithReuseIdentifier:CTagFooterCell];
        customHeaderFooterTable.contentView.tag = CTagContentViewHeader;
        [customHeaderFooterTable initLbl:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andColor:CHeaderFooterCell andFrame:CGRectZero isHeader:NO];
        [customHeaderFooterTable initBtn:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader] andColor:[UIColor whiteColor] andFrame:CGRectZero];
    }
    
    float widhtItem = tableView.bounds.size.width-(CPaddingLeft*2);
    switch (section) {
        case 0:
        {
            float heightLblFooter = [self calculateHeight:CStringDescCheckDomain withFont:[customHeaderFooterTable getLblFooter].font andSize:CGSizeMake(widhtItem, 9999)];
            [customHeaderFooterTable setBtnFrame:CGRectMake(CPaddingLeft/2.0f, CPaddingLeft/2.0f, widhtItem, CHeightHeaderCell-((CPaddingLeft/2.0f)*2))];
            [customHeaderFooterTable setLblFrame:CGRectMake([customHeaderFooterTable getBtnCheckDomain].frame.origin.x, [customHeaderFooterTable getBtnCheckDomain].bounds.size.height+[customHeaderFooterTable getBtnCheckDomain].frame.origin.y+CPaddingLeft, widhtItem, heightLblFooter) isHeader:NO];

            //Btn Check Domain
            [customHeaderFooterTable getBtnCheckDomain].hidden = NO;
            [customHeaderFooterTable getLblFooter].text = CStringDescCheckDomain;
            [[customHeaderFooterTable getBtnCheckDomain] setTitle:CStringCekDomain forState:UIControlStateNormal];
            [[customHeaderFooterTable getBtnCheckDomain] addTarget:self action:@selector(checkDomain:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 1:
        {
            float heightLblFooter = [self calculateHeight:CStringDescGambarFoto withFont:[customHeaderFooterTable getLblFooter].font andSize:CGSizeMake(widhtItem, 9999)];
            [customHeaderFooterTable setLblFrame:CGRectMake(CPaddingLeft, CPaddingLeft, widhtItem, heightLblFooter) isHeader:NO];
            [customHeaderFooterTable getLblFooter].text = CStringDescGambarFoto;
            [customHeaderFooterTable getBtnCheckDomain].hidden = YES;
        }
            break;
        case 2:
            return nil;
    }
    
    return customHeaderFooterTable;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomHeaderFooterTable *customHeaderFooterTable = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CTagHeaderCell];
    if(customHeaderFooterTable == nil)
    {
        customHeaderFooterTable = [[CustomHeaderFooterTable alloc] initWithReuseIdentifier:CTagHeaderCell];
        [customHeaderFooterTable initLbl:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeHeader] andColor:CHeaderFooterCell andFrame:CGRectMake(CPaddingLeft, CHeightHeaderCell/5.0f, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell-((CHeightHeaderCell/5.0f)*2)) isHeader:YES];
    }
    
    switch (section) {
        case 0:
            [customHeaderFooterTable getLblHeader].text = CStringDomain;
            break;
        case 1:
            [customHeaderFooterTable getLblHeader].text = CStringGambarToko;
            break;
        default:
            [customHeaderFooterTable getLblHeader].text = CStringInfoToko;
            break;
    }
    
    return customHeaderFooterTable;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
        [cell setPreservesSuperviewLayoutMargins:NO];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateShopCell *cell = [tableView dequeueReusableCellWithIdentifier:CTagCell];
    if(cell == nil)
        cell = [[CreateShopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CTagCell];
    
    if(indexPath.section == 0)
    {
        UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagSlogan];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagDeskripsi];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagNamaToko];
        [tempView removeFromSuperview];
        
        
        [cell getLblDomain].hidden = NO;
        if(txtDomain == nil)
        {
            txtDomain = [[UITextField alloc] initWithFrame:CGRectMake([cell getLblDomain].frame.origin.x + [cell getLblDomain].bounds.size.width, 0, cell.bounds.size.width-CPaddingLeft-([cell getLblDomain].frame.origin.x+[cell getLblDomain].bounds.size.width), cell.bounds.size.height)];
            txtDomain.backgroundColor = [UIColor clearColor];
            txtDomain.tag = CTagDomain;
            txtDomain.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
            txtDomain.delegate = self;
            txtDomain.placeholder = CStringDomain;
        }
        
        [cell.contentView addSubview:txtDomain];
    }
    else if(indexPath.section == 1)
    {
        [cell getLblDomain].hidden = YES;
        UIView *tempView = [cell.contentView viewWithTag:CTagDomain];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagSlogan];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagDeskripsi];
        [tempView removeFromSuperview];
        tempView = [cell.contentView viewWithTag:CTagNamaToko];
        [tempView removeFromSuperview];
        
        if(viewImgGambar == nil)
        {
            viewImgGambar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.height, CHeightHeaderCell*3)];
            viewImgGambar.tag = CTagUnggahImage;
            UILabel *lblUnggahGambar = [[UILabel alloc] initWithFrame:CGRectMake(0, (CHeightHeaderCell*3)-20, cell.bounds.size.width, 20)];
            lblUnggahGambar.text = CStringUnggahGambar;
            lblUnggahGambar.textAlignment = NSTextAlignmentCenter;
            lblUnggahGambar.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
            lblUnggahGambar.backgroundColor = [UIColor clearColor];
            lblUnggahGambar.textColor = [UIColor greenColor];
            [viewImgGambar addSubview:lblUnggahGambar];
            
            int diameterImage = 100;
            imgGambar = [[UIImageView alloc] initWithFrame:CGRectMake((cell.bounds.size.width-diameterImage)/2.0f, 10, diameterImage, diameterImage)];
            imgGambar.layer.cornerRadius = imgGambar.bounds.size.width/2.0f;
            imgGambar.layer.borderColor = [[UIColor blackColor] CGColor];
            imgGambar.layer.borderWidth = 1.0f;
            imgGambar.layer.masksToBounds = YES;
            imgGambar.contentMode = UIViewContentModeScaleAspectFill;
            imgGambar.userInteractionEnabled = YES;
            imgGambar.image = [UIImage imageNamed:@"icon_camera_grey_active.png"];
            [imgGambar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)]];
            [viewImgGambar addSubview:imgGambar];
            viewImgGambar.userInteractionEnabled = YES;
        }
        
        [cell.contentView addSubview:viewImgGambar];
    }
    else if(indexPath.section == 2)
    {
        [cell getLblDomain].hidden = YES;        
        switch (indexPath.row) {
            case 0:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagSlogan];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDeskripsi];
                [tempView removeFromSuperview];
                
                if(txtNamaToko == nil)
                {
                    txtNamaToko = [[UITextField alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell)];
                    txtNamaToko.placeholder = CStringPlaceHolderNamaToko;
                    txtNamaToko.tag = CTagNamaToko;
                    txtNamaToko.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    txtNamaToko.delegate = self;
                }
                
                [cell.contentView addSubview:txtNamaToko];
            }
                break;
            case 1:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagNamaToko];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDeskripsi];
                [tempView removeFromSuperview];
                
                if(txtSlogan == nil)
                {
                    txtSlogan = [[UITextField alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell*2)];
                    txtSlogan.placeholder = CStringPlaceHolderSlogan;
                    txtSlogan.tag = CTagSlogan;
                    txtSlogan.delegate = self;
                    txtSlogan.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    
                    int diameter = 30;
                    lblCountSlogan = [[UILabel alloc] initWithFrame:CGRectMake(txtSlogan.frame.origin.x+txtSlogan.bounds.size.width-diameter, txtSlogan.frame.origin.y+txtSlogan.bounds.size.height-diameter, diameter, diameter)];
                    lblCountSlogan.backgroundColor = [UIColor clearColor];
                    lblCountSlogan.font = [UIFont fontWithName:CFont_Gotham_Book size:10.0f];
                    lblCountSlogan.text = [NSString stringWithFormat:@"%d", (int)(CMaxSlogan-lblCountSlogan.text.length)];
                }

                [cell.contentView addSubview:txtSlogan];
                [cell.contentView addSubview:lblCountSlogan];
            }
                break;
            case 2:
            {
                UIView *tempView = [cell.contentView viewWithTag:CTagUnggahImage];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagDomain];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagSlogan];
                [tempView removeFromSuperview];
                tempView = [cell.contentView viewWithTag:CTagNamaToko];
                [tempView removeFromSuperview];
                
                if(txtDesc == nil)
                {
                    txtDesc = [[UITextField alloc] initWithFrame:CGRectMake(CPaddingLeft, 0, tableView.bounds.size.width-(CPaddingLeft*2), CHeightHeaderCell*2)];
                    txtDesc.placeholder = CstringPlaceHolderDesc;
                    txtDesc.tag = CTagDeskripsi;
                    txtDesc.delegate = self;
                    txtDesc.font = [UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter];
                    
                    int diameter = 30;
                    lblCountDescripsi = [[UILabel alloc] initWithFrame:CGRectMake(txtDesc.frame.origin.x+txtDesc.bounds.size.width-diameter, txtDesc.frame.origin.y+txtDesc.bounds.size.height-diameter, diameter, diameter)];
                    lblCountDescripsi.font = [UIFont fontWithName:CFont_Gotham_Book size:10.0f];
                    lblCountDescripsi.backgroundColor = [UIColor clearColor];
                    lblCountDescripsi.text = [NSString stringWithFormat:@"%d", (int)(CMaxDesc-lblCountDescripsi.text.length)];
                }
                
                [cell.contentView addSubview:txtDesc];
                [cell.contentView addSubview:lblCountDescripsi];
            }
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return CHeightHeaderCell;
    else if(indexPath.section == 1)
        return CHeightHeaderCell*3;
    else
    {
        switch (indexPath.row) {
            case 0:
                return CHeightHeaderCell;
            case 1:
                return CHeightHeaderCell*2;
            default:
                return CHeightHeaderCell*2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0 || section==1)
        return 1;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float height = 0.0f;
    switch (section) {
        case 0:
        {
            height += [self calculateHeight:CStringDescCheckDomain withFont:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andSize:CGSizeMake(tableView.bounds.size.width-(CPaddingLeft*2), 9999)];
            height += CHeightHeaderCell + CPaddingLeft;
        }
            break;
        case 1:
        {
            height += [self calculateHeight:CStringDescGambarFoto withFont:[UIFont fontWithName:CFont_Gotham_Book size:CFontSizeFooter] andSize:CGSizeMake(tableView.bounds.size.width-(CPaddingLeft*2), 9999)];
        }
            break;
        case 2:
            return 0;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CHeightHeaderCell;
}


#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(picker.view.tag == 0) //Camera
    {
        hasSetImgGambar = YES;
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        imgGambar.image = chosenImage;
        [self checkValidation:nil];
    }
    else
    {
        hasSetImgGambar = YES;
        imgGambar.image = info[UIImagePickerControllerOriginalImage];
        [self checkValidation:nil];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    return YES;
}


- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length==0 && theTextField.tag!=CTagDomain && theTextField.tag!=CTagNamaToko)
        return YES;
    
    if(theTextField.tag == CTagDomain)
    {
        if(isValidDomain)
        {
            isValidDomain = NO;
            [self enableLanjut:NO];
        }
        else if(string.length == 0)
            return YES;
        
        if(theTextField.text.length >= CMaxCharDomain)
            return NO;
        
        NSCharacterSet *myCharSet = [NSCharacterSet alphanumericCharacterSet];
        for(int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c])
                return YES;
        }
    }
    else if(theTextField.tag == CTagNamaToko)
    {
        [self checkValidation:[[theTextField text] stringByReplacingCharactersInRange:range withString:string]];
        return YES;
    }
    else if(theTextField.tag == CTagSlogan)
    {
        lblCountSlogan.text = [NSString stringWithFormat:@"%d", (int)(CMaxSlogan-theTextField.text.length)];
        if(theTextField.text.length >= CMaxSlogan)
            return NO;
        return YES;
    }
    else if(theTextField.tag == CTagDeskripsi)
    {
        lblCountDescripsi.text = [NSString stringWithFormat:@"%d", (int)(CMaxDesc-theTextField.text.length)];
        if(theTextField.text.length >= CMaxDesc)
            return NO;
        return YES;
    }
    

    return NO;
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.view.tag = 0;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
            imagePickerController.view.tag = 1;
            imagePickerController.delegate = self;
            imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
            break;
    }
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    return @{@"shop_domain":txtDomain.text, kTKPD_APIACTIONKEY:kTKPD_CHECK_DOMAIN};
}

- (NSString*)getPath:(int)tag
{
    return [NSString stringWithFormat:@"action/%@", kTKPMYSHOP_APIPATH];
}

- (id)getObjectManager:(int)tag
{
    objectManager =  [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddShop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{CStatusDomain:CStatusDomain}];
    
        
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:0] keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];

    return ((AddShop *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self isCheckingDomain:NO];
    AddShop *addShop = [((RKMappingResult *) successResult).dictionary objectForKey:@""];

    if(addShop!=nil && [addShop.result.status_domain isEqualToString:@"1"])
    {
        isValidDomain = YES;
        [self checkValidation:nil];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringValidDomain] delegate:self];
        [stickyAlertView show];
    }
    else
    {
        isValidDomain = NO;
        if(addShop.message_error==nil || addShop.message_error.count==0)
            addShop.message_error = @[CStringNotValidDomainName];
        
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:addShop.message_error delegate:self];
        [stickyAlertView show];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    isValidDomain = NO;
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{

}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    isValidDomain = NO;
    [self isCheckingDomain:NO];
}
@end
