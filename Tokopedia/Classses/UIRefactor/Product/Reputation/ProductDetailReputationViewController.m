//
//  ProductDetailReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
#import "CMPopTipView.h"
#import "HPGrowingTextView.h"
#import "ProductReputationCell.h"
#import "ProductDetailReputationCell.h"
#import "ProductReputationViewController.h"
#import "ProductDetailReputationViewController.h"
#import "String_Reputation.h"
#import "ViewLabelUser.h"

#define CCellIdentifier @"cell"

@interface ProductDetailReputationViewController ()<productReputationDelegate, CMPopTipViewDelegate, HPGrowingTextViewDelegate, ProductDetailReputationDelegate>

@end

@implementation ProductDetailReputationViewController {
    ProductReputationCell *productReputationCell;
    CMPopTipView *popTipView;
    
    NSMutableDictionary *dictCell;
    float heightScreenView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTable];
    [self initNavigation];
    
    btnSend.layer.cornerRadius = 5.0f;
    btnSend.layer.masksToBounds = YES;
    
    growTextView.isScrollable = NO;
    growTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    growTextView.layer.borderWidth = 0.5f;
    growTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    growTextView.layer.cornerRadius = 5;
    growTextView.layer.masksToBounds = YES;
    
    growTextView.minNumberOfLines = 1;
    growTextView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    growTextView.returnKeyType = UIReturnKeyGo; //just as an example
    //    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    growTextView.delegate = self;
    growTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    growTextView.backgroundColor = [UIColor whiteColor];
    growTextView.placeholder = CKirimPesanMu;
}

- (void)viewWillAppear:(BOOL)animated
{
    heightScreenView = self.view.bounds.size.height;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method View
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.has3DStyle = NO;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (id)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor
{
    int spacing = 3;
    
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    
    CGSize imageSize = tempBtn.imageView.bounds.size;
    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
    
    return (id)tempBtn;
}

- (void)resignKeyboardView:(id)sender {
    [growTextView resignFirstResponder];
}

- (void)initNavigation {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

- (void)initTable {
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
    productReputationCell = [tempArr objectAtIndex:0];
    productReputationCell.delegate = self;
    [((ProductReputationViewController *) [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]) setPropertyLabelDesc:productReputationCell.getLabelDesc];
    
    productReputationCell.contentView.backgroundColor = productReputationCell.getViewContent.backgroundColor;
    productReputationCell.getBtnMore.frame = CGRectZero;
    [productReputationCell.getBtnMore removeFromSuperview];
    productReputationCell.getImageProfile.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_no_data" ofType:@"png"]];
    [productReputationCell setLabelUser:@"Andre" withTag:0];
    [productReputationCell setPercentage:@"35"];
    [productReputationCell setLabelDate:@"3 hari yang lalu"];
    [productReputationCell setDescription:@"pasjk pdlf klksa jflj asldf jsadj flkjsalkdf jask jdflksa jdlkf jaslkdj flkas jdfl ajslkdf jsakl jflkasj dlfk jaslk jflksd"];
    [productReputationCell layoutSubviews];
    
    //Add Background view and line separator
    UIView *backgroundHeaderView = [[UIView alloc] initWithFrame:CGRectMake(-productReputationCell.getViewContent.frame.origin.x, productReputationCell.getBtnLike.frame.origin.y, self.view.bounds.size.width, productReputationCell.contentView.bounds.size.height-productReputationCell.getBtnLike.frame.origin.y)];
    backgroundHeaderView.backgroundColor = self.view.backgroundColor;
    [productReputationCell.getViewContent insertSubview:backgroundHeaderView belowSubview:productReputationCell.getBtnLike];
    
    UIView *viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, productReputationCell.contentView.bounds.size.height-1, self.view.bounds.size.width, 1.0f)];
    viewSeparator.backgroundColor = [UIColor lightGrayColor];
    [productReputationCell.contentView addSubview:viewSeparator];
    
    
    tableReputation.tableHeaderView = productReputationCell.contentView;
    tableReputation.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    tableReputation.delegate = self;
    tableReputation.dataSource = self;
    [tableReputation reloadData];
    
    [tableReputation addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardView:)]];
}

#pragma mark - Action
- (void)actionVote:(id)sender
{
    [self dismissAllPopTipViews];
}

- (IBAction)actionSend:(id)sender
{
    
}


#pragma mark - UITableView Delegate and Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = CCellIdentifier;
    ProductDetailReputationCell *cell = [dictCell objectForKey:reuseIdentifier];
    if (! cell) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:15.0f]];
        [dictCell setObject:cell forKey:reuseIdentifier];
    }
    
    cell.getTvDesc.text = @"aslkdjf lksajlfkjlsakj flksajdlkf jslakj flkasjlkfjsalkdj flkasjdlk fjslajd flsad fjsaljd flsad fsadf asd fasdf asd fasd fsad fas fadf adf sa dfsad fsaf sad fd";
    cell.getLblDate.text = @"1 hari yang lalu";
    cell.getImgProfile.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_no_data" ofType:@"png"]];
    [cell.getViewLabelUser setText:@"Andre"];
    [cell.getViewLabelUser setColor:0];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        cell.delegate = self;
        [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:15.0f]];
    }
    cell.getTvDesc.text = @"aslkdjf lksajlfkjlsakj flksajdlkf jslakj flkasjlkfjsalkdj flkasjdlk fjslajd flsad fjsaljd flsad fsadf asd fasdf asd fasd fsad fas fadf adf sa dfsad fsaf sad fd";
    cell.getLblDate.text = @"1 hari yang lalu";
    cell.getImgProfile.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_no_data" ofType:@"png"]];
    [cell.getViewLabelUser setText:@"Andre"];
    [cell.getViewLabelUser setColor:0];
    cell.getViewStar.tag = indexPath.row;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}



#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
    lblDesc.attributedText = str;
    lblDesc.delegate = nil;
    [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
}

- (void)actionLike:(id)sender {
    
}
- (void)actionDisLike:(id)sender {
    
}
- (void)actionChat:(id)sender {

}

- (void)actionMore:(id)sender {

}


- (void)actionRate:(id)sender {
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent+paddingRightLeftContent, CHeightItemPopUp)];
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:@"35" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor redColor]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:@"36" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor yellowColor]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:@"37" withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_home" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor greenColor]];
    
    btnMerah.tag = CTagMerah;
    btnKuning.tag = CTagKuning;
    btnHijau.tag = CTagHijau;
    
    [btnMerah addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnKuning addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnHijau addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewContentPopUp addSubview:btnMerah];
    [viewContentPopUp addSubview:btnKuning];
    [viewContentPopUp addSubview:btnHijau];
    
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor whiteColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.has3DStyle = YES;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}


#pragma mark - Notification Keyboard
- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *info  = note.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSArray * arrConstarint = self.view.constraints;
    for (NSLayoutConstraint * constraint in arrConstarint) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightScreenView-keyboardFrame.size.height;
            break;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    NSArray * arrConstarint = self.view.constraints;
    for (NSLayoutConstraint * constraint in arrConstarint) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightScreenView;
            break;
        }
    }

    [UIView commitAnimations];
}

#pragma mark - PopUp
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - Method
- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

#pragma mark - HPGrowingTextView Delegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    NSLog(@"sdf");
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    constraintHeightViewMessage.constant = (height+growingTextView.frame.origin.y*2);
}


#pragma mark - ProductDetailReputation Delegate


- (void)actionTapStar:(UIView *)sender
{
    NSString *strText = @"1,000,100 Like";
    [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
}
@end
