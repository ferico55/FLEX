//
//  CameraAlbumListViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraAlbumListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *groups;

-(void)getAsset;

@end
