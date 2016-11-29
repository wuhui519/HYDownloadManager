//
//  HYDownloadOperation.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDownloadManager.h"

@interface HYDownloadOperation : NSOperation
@property (nonatomic, strong) NSURL *url;

+ (HYDownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                            filePath:(NSString *)filePath
                                       progressBlock:(HYProgressBlock)progressBlock
                                     completionBlock:(HYCompletionBlock)completionBlock;

- (void)start;
- (void)stop;

@end
