//
//  HYSequentialDownloadHandler.m
//  DownloadManager
//
//  Created by Omar on 8/4/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "HYSequentialDownloadHandler.h"

@implementation HYSequentialDownloadHandler

+ (HYSequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                              progressBlock:(HYSequentialProgressBlock)progressBlock
                                            completionBlock:(HYSequentialCompletionBlock)completionBlock
                                                        tag:(NSInteger)tag
{
    HYSequentialDownloadHandler *handler = [[HYSequentialDownloadHandler alloc] init];
    
    handler.urls = urls;
    handler.progressBlock = progressBlock;
    handler.completionBlock = completionBlock;
    handler.tag = tag;
    
    return handler;
}

+ (HYSequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                                   delegate:(id<HYSequentialDownloadManagerDelegate>)delegate
{
    HYSequentialDownloadHandler *handler = [[HYSequentialDownloadHandler alloc] init];
    
    handler.urls = urls;
    handler.delegate = delegate;
    
    return handler;
}

- (NSUInteger) indexOfURL:(NSURL*)url
{
    __block NSUInteger index;
    [self.urls enumerateObjectsUsingBlock:^(NSURL *blockURl, NSUInteger idx, BOOL *stop) {
        if([blockURl.absoluteString isEqualToString:url.absoluteString])
        {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}
@end
