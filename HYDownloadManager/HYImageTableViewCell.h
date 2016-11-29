//
//  HYImageTableViewCell.h
//  HYDownloadManager
//
//  Created by Faye on 2016/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYDownloadManager.h"
#import "HYSequentialDownloadManager.h"

@interface HYImageTableViewCell : UITableViewCell<HYDownloadManagerDelegate, HYSequentialDownloadManagerDelegate>

- (void)setImageWithURL:(NSURL*)url;
- (void)setImageWithURLs:(NSArray*)urls_;
- (void)stopDownloading;

@end
