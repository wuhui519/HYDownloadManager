//
//  HYImageTableViewCell.h
//  HYDownloadManager
//
//  Created by Faye on 2016/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IADownloadManager.h"
#import "IASequentialDownloadManager.h"

@interface HYImageTableViewCell : UITableViewCell<IADownloadManagerDelegate, IASequentialDownloadManagerDelegate>

- (void)setImageWithURL:(NSURL*)url;
- (void)setImageWithURLs:(NSArray*)urls_;
- (void)stopDownloading;

@end
