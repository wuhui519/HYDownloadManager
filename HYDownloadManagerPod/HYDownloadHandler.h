//
//  HYDownloadHandler.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDownloadManager.h"

@interface HYDownloadHandler : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) HYProgressBlock progressBlock;
@property (nonatomic, strong) HYCompletionBlock completionBlock;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) id<HYDownloadManagerDelegate> delegate;

+ (HYDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(HYProgressBlock)progressBlock
                                 completionBlock:(HYCompletionBlock)completionBlock
                                             tag:(NSInteger)tag;

+ (HYDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<HYDownloadManagerDelegate>)delegate;
@end
