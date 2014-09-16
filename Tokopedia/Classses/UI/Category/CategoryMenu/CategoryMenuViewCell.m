//
//  CategoryMenuViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CategoryMenuViewCell.h"

@interface CategoryMenuViewCell()

@end

@implementation CategoryMenuViewCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CategoryMenuViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        NSDictionary *colomn = [_data objectForKey:@"column"];
        _label.text = [colomn objectForKey:@"title"];
        _imagenext.hidden = ([[colomn objectForKey:@"isnullchild"] isEqual:@(0)])?NO:YES;
        
    }
    else
    {
        [self reset];
    }
}

-(IBAction)gesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        NSIndexPath *indexpath = _data[@"indexpath"];
        [_delegate CategoryMenuViewCell:self withindexpath:indexpath];
    }
}

#pragma mark - Methods
-(void)reset
{
    
}

@end
