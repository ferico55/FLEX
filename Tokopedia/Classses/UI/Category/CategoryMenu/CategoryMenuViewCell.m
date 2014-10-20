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

-(IBAction)gesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                NSIndexPath *indexpath =_indexpath;
                [_delegate CategoryMenuViewCell:self withindexpath:indexpath];
                break;
            }
        }
    }
}

@end
