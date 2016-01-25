//
//  CategoryDataSource.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) UIViewController *delegate;

@end
