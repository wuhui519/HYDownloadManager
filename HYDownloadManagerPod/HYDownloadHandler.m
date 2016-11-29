//
//  HYDownloadHandler.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "HYDownloadHandler.h"

@implementation HYDownloadHandler

+ (HYDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(HYProgressBlock)progressBlock
                                 completionBlock:(HYCompletionBlock)completionBlock
                                             tag:(NSInteger)tag
{
    HYDownloadHandler *handler = [HYDownloadHandler new];
    handler.url = url;
    handler.tag = tag;
    handler.progressBlock = progressBlock;
    handler.completionBlock = completionBlock;
    
    return handler;
}

+ (HYDownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<HYDownloadManagerDelegate>)delegate
{
    HYDownloadHandler *handler = [HYDownloadHandler new];
    
    handler.url = url;
    handler.delegate = delegate;
    
    return handler;
}

@end
