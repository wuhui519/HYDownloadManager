//
//  IADownloadOperation.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IADownloadOperation.h"
#import "AFNetworking.h"
#import "IACacheManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface IADownloadOperation ()
{
    BOOL executing;
    BOOL cancelled;
    BOOL finished;
    NSString *_finalFilePath;
}
@property (nonatomic, strong) NSURLSessionDownloadTask *dataTask;
@end

@implementation IADownloadOperation

+ (IADownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                            filePath:(NSString *)filePath
                                       progressBlock:(IAProgressBlock)progressBlock
                                     completionBlock:(IACompletionBlock)completionBlock
{
    IADownloadOperation *op = [IADownloadOperation new];
    op.url = url;
    op->_finalFilePath = filePath;
 
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                       completionBlock:completionBlock];
        return nil;
    }
    
    __weak IADownloadOperation *weakOp = op;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDownloadTask *dataTask =
        [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            float progress = downloadProgress.fractionCompleted;
            progressBlock(progress, url);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSData *responseObject = [[NSFileManager defaultManager] contentsAtPath:targetPath.relativePath];
            [IADownloadOperation setCacheWithData:responseObject url:url];
            __strong IADownloadOperation *StrongOp = weakOp;
            NSURL *fileURL = nil;
            if(StrongOp != nil && StrongOp->_finalFilePath)
            {
                fileURL = [NSURL URLWithString:StrongOp->_finalFilePath];
            }
            [StrongOp finish];
            completionBlock(YES, responseObject);
            return fileURL;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong IADownloadOperation *StrongOp = weakOp;
            completionBlock(NO, nil);
            [StrongOp finish];
        }];
    
    op.dataTask = dataTask;
    return op;
}

- (void)start
{
    NSLog(@"opeartion for <%@> started.", _url);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.dataTask resume];
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)hasCacheForURL:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    return [IACacheManager hasObjectForKey:encodeKey];
}

- (void)fetchItemFromCacheForURL:(NSURL*)url
                   progressBlock:(IAProgressBlock)progressBlock
                 completionBlock:(IACompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *encodeKey = [IADownloadOperation cacheKeyForUrl:url];
        NSData *data = [IACacheManager objectForKey:encodeKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressBlock(1, url);
            completionBlock(YES, data);
            
            [self finish];
            
        });
    });
}

+ (void)setCacheWithData:(NSData*)data
                     url:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    [IACacheManager setObject:data forKey:encodeKey];
}

+ (NSString*)cacheKeyForUrl:(NSURL*)url
{
    NSString *key = url.absoluteString;
    const char *str = [key UTF8String];
    unsigned char r[16];
    CC_MD5(str, (uint32_t)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)startOperation
{
    [self.dataTask resume];
    executing = YES;
}

- (void)stop
{
    [self.dataTask cancel];
    cancelled = YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isCancelled
{
    return cancelled;
}

- (BOOL)isFinished
{
    return finished;
}

@end
