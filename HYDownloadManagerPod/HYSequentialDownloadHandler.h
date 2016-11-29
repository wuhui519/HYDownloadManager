//
//  HYSequentialDownloadHandler.h
//  DownloadManager
//
//  Created by Omar on 8/4/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYSequentialDownloadManager.h"

@interface HYSequentialDownloadHandler : NSObject

@property (nonatomic, strong) HYSequentialProgressBlock progressBlock;
@property (nonatomic, strong) HYSequentialCompletionBlock completionBlock;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id<HYSequentialDownloadManagerDelegate> delegate;

+ (HYSequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                              progressBlock:(HYSequentialProgressBlock)progressBlock
                                            completionBlock:(HYSequentialCompletionBlock)completionBlock
                                                        tag:(NSInteger)tag;

+ (HYSequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                                   delegate:(id<HYSequentialDownloadManagerDelegate>)delegate;

- (NSUInteger) indexOfURL:(NSURL*)url;
@end
