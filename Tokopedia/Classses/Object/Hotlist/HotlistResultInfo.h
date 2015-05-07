//
//  HotlistResultInfo.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotlistResultInfo : NSObject

@property (strong, nonatomic) NSString *negative_keyword;
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSString *title_enc;
@property (strong, nonatomic) NSString *catalog;
@property (strong, nonatomic) NSString *min_price;
@property (strong, nonatomic) NSString *hashtag;
@property (strong, nonatomic) NSString *file_name;
@property (strong, nonatomic) NSString *alias_key;
@property (strong, nonatomic) NSString *cover_img;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *d_id;
@property (strong, nonatomic) NSString *file_path;
@property (strong, nonatomic) NSString *meta_description;
@property (strong, nonatomic) NSString *sort_by;
@property (strong, nonatomic) NSString *share_file_path;
@property (strong, nonatomic) NSString *hotlist_description;
@property (strong, nonatomic) NSString *max_price;
@property (strong, nonatomic) NSString *shop;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *share_file_name;

@end