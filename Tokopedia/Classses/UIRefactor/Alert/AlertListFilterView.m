//
//  AlertListFilterView.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/28/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//


#import "AlertListFilterView.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

@implementation AlertListFilterView

#pragma mark - Table Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];


    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width-20, cell.frame.size.height)];
    label.font = FONT_GOTHAM_BOOK_13;
    label.textAlignment = NSTextAlignmentCenter;
    [label setCustomAttributedText: _list[indexPath.row]];
    [cell.contentView addSubview:label];
    
    if ([_list[indexPath.row] isEqual:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Methods
- (void)show
{
    [super show];
    
    id<TKPDAlertViewDelegate> _delegate = self.delegate;
    
    if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(willPresentAlertView:)])) {
        [_delegate willPresentAlertView:self];
    }
    
    [_window setFrame:CGRectMake(0,((UIViewController*)_delegate).view.frame.origin.y, ((UIViewController*)_delegate).view.frame.size.width, ((UIViewController*)_delegate).view.frame.size.height)];
    _window.clipsToBounds = YES;

    CGFloat tableViewContentHeight = _list.count*40;
    
    self.frame = CGRectMake(0, -tableViewContentHeight, _window.bounds.size.width, tableViewContentHeight);
    [_window addSubview:self];	//from animation block below
    [_window makeKeyAndVisible];
    
    [UIView transitionWithView:_window duration:0.5 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowAnimatedContent) animations:^{
        
        //[_window addSubview:self];	//moved before animation call above
        self.frame = CGRectMake(0, 0, _window.bounds.size.width, tableViewContentHeight);
        
    } completion:^(BOOL finished) {
        
        if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(didPresentAlertView:)])) {
            [_delegate didPresentAlertView:self];
        }
    }];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedObject = _list[indexPath.row];
    [_tableView reloadData];
    [self dismissWithClickedButtonIndex:indexPath.row animated:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

@end
