//
//  UITableView+IndexPath.m
//  Tokopedia
//
//  Created by Tokopedia on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UITableView+IndexPath.h"

@implementation UITableView (IndexPath)

- (BOOL)isLastIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
        return YES;
    } else {
        return NO;
    }
}

@end
