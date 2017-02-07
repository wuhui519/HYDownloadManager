//
//  HYSequentialDownloadManager.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "HYSequentialDownloadManager.h"
#import "HYSequentialDownloadHandler.h"
#import "HYDownloadOperation.h"

@interface HYSequentialDownloadManager()

@end

@interface HYSequentialDownloadManager()
@property (nonatomic, strong) NSMutableDictionary *queues;
@property (nonatomic, strong) NSMutableDictionary *downloadHandlers;
@property (nonatomic, strong) NSMutableDictionary *remainingDownloads;
@end

@implementation HYSequentialDownloadManager

#pragma mark Initialization
#pragma mark -

+ (HYSequentialDownloadManager*) instance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.queues = [NSMutableDictionary new];
        self.remainingDownloads = [NSMutableDictionary new];
        self.downloadHandlers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark Global Blocks
#pragma mark -

void (^globalSequentialProgressBlock)
(float progress, NSURL *url,
 NSArray *urls, NSInteger tag, HYSequentialDownloadManager* self) =
^(float progress, NSURL *url,
  NSArray *urls, NSInteger tag, HYSequentialDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    //Inform the handlers
    int remainingDownloads = [[self.remainingDownloads objectForKey:urls] intValue];
    int index = (int)urls.count - remainingDownloads;
    
    [handlers enumerateObjectsUsingBlock:^(HYSequentialDownloadHandler *handler,
                                           NSUInteger idx, BOOL *stop) {
        
        if(handler.progressBlock)
            handler.progressBlock(progress, index);
        
        if([handler.delegate respondsToSelector:@selector(sequentialManagerProgress:atIndex:)])
            [handler.delegate sequentialManagerProgress:progress atIndex:index];
        
    }];
};

bool hasDuplicateUrls(NSArray* urls)
{
    for(int j = 0 ; j < [urls count] ; j++)
    {
        for(int k = j+1 ; k < [urls count] ; k++)
        {
            NSURL *url1 = [urls objectAtIndex:j];
            NSURL *url2 = [urls objectAtIndex:k];
            
            if([url1.absoluteString isEqualToString:url2.absoluteString])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

NSInteger indexOfURL(NSURL *url, NSArray* urls)
{
    for(int j = 0 ; j < [urls count] ; j++)
    {
        NSURL *url1 = [urls objectAtIndex:j];
        
        if([url1.absoluteString isEqualToString:url.absoluteString])
        {
            return j;
        }
    }
    
    return NSNotFound;
}


void (^globalSequentialCompletionBlock)
(BOOL success, id response, NSURL *url,
 NSArray *urls, NSInteger tag, HYSequentialDownloadManager* self) =
^(BOOL success, id response, NSURL *url,
 NSArray *urls, NSInteger tag, HYSequentialDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    //Inform the handlers
    int remainingDownloads = [[self.remainingDownloads objectForKey:urls] intValue];
    NSInteger index = hasDuplicateUrls(urls) ? urls.count - remainingDownloads :
    indexOfURL(url, urls);
    
    remainingDownloads--;
    [self.remainingDownloads setObject:@(remainingDownloads) forKey:urls];
    
    [handlers enumerateObjectsUsingBlock:^(HYSequentialDownloadHandler *handler,
                                           NSUInteger idx, BOOL *stop) {
        
        if(handler.completionBlock)
            handler.completionBlock(success, response, index);
        
        if([handler.delegate respondsToSelector:@selector(sequentialManagerDidFinish:response:atIndex:)])
            [handler.delegate sequentialManagerDidFinish:success response:response atIndex:index];
        
    }];

    //Remove the download handlers
    if(remainingDownloads == 0)
    {
        [self.downloadHandlers removeObjectForKey:@(tag)];
        [self.queues removeObjectForKey:urls];
        [self.remainingDownloads removeObjectForKey:urls];
    }
};

#pragma mark Downloading
#pragma mark -

- (void) addDownloadOperationWithURL:(NSURL *)url
                             toQueue:(NSOperationQueue *)queue
                                 tag:(NSInteger)tag
                            useCache:(BOOL)useCache
                                urls:(NSArray *)urls
                               paths:(NSString *)path
{
    HYDownloadOperation *op =
    [self downloadOperationForURL:url tag:tag useCache:useCache urls:urls path:path];
    
    [queue addOperation:op];
}

- (HYDownloadOperation*) downloadOperationForURL:(NSURL*)url
                                       fromQueue:(NSOperationQueue*)queue
{
    __block HYDownloadOperation *op = nil;
    
    [queue.operations enumerateObjectsUsingBlock:^(HYDownloadOperation *op_, NSUInteger idx, BOOL *stop) {
        if ([url.absoluteString isEqualToString:op_.url.absoluteString]) {
            op = op_;
            *stop = YES;
        }
    }];
    
    return op;
}

- (HYDownloadOperation*) downloadOperationForURL:(NSURL*)url
                                             tag:(NSInteger)tag
                                        useCache:(BOOL)useCache
                                            urls:(NSArray*)urls
                                            path:(NSString *)path
{
    HYDownloadOperation *op = [HYDownloadOperation
                               downloadingOperationWithURL:url
                               useCache:useCache
                               filePath:path
                               progressBlock:^(float progress, NSURL *url) {
                                   
                                   globalSequentialProgressBlock(progress, url, urls,
                                                                 tag,self);
                                   
                               } completionBlock:^(BOOL success, id response) {
                                   
                                   globalSequentialCompletionBlock(success, response,
                                                                   url, urls, tag, self);
                                   
                               }];
    
    return op;
}

#pragma mark HYDownloadHandlers and HYDownloadOperation Helpers
#pragma mark -

- (NSOperationQueue*)operationQueueWithURLs:(NSArray*)urls
{
    NSOperationQueue *queue = [self.queues objectForKey:urls];
    
    if(!queue)
    {
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = YES;
        [self.queues setObject:queue forKey:urls];
        [self.remainingDownloads setObject:@(urls.count) forKey:urls];
    }

    return queue;
}

- (HYSequentialDownloadHandler*) downloadHandlersWithTag:(NSInteger)tag
{
    __block HYSequentialDownloadHandler *downloadHandler = nil;
    
    downloadHandler =
    [self.downloadHandlers objectForKey:@(tag)];
    
    return downloadHandler;
}

- (void)removeHandlerWithURLs:(NSArray*)urls tag:(NSInteger)tag
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            HYSequentialDownloadHandler *handler = handlers[i];
            
            if (handler.tag == tag)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithURLs:(NSArray*)urls listener:(id)listener
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            HYSequentialDownloadHandler *handler = handlers[i];
            
            if (handler.delegate == listener)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeAllHandlersWithListener:(id)listener
{
    for (NSInteger i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (NSInteger j = array.count - 1; j >= 0; j-- )
        {
            HYSequentialDownloadHandler *handler = array[j];
            if (handler.delegate == listener)
            {
                [array removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithTag:(NSInteger)tag
{
    for (NSInteger i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (NSInteger j = array.count - 1; j >= 0; j-- )
        {
            HYSequentialDownloadHandler *handler = array[j];
            if (handler.tag == tag)
            {
                [array removeObject:handler];
            }
        }
    }
}

#pragma mark Entry Point
#pragma mark -

- (void) downloadItemWithURLs:(NSArray*)urls
                     useCache:(BOOL)useCache
{
    [self downloadItemWithURLs:urls useCache:useCache saveToPath:nil];
}

- (void)downloadItemWithURLs:(NSArray *)urls useCache:(BOOL)useCache saveToPath:(NSArray *)paths {
    //Create a new sequential download operation if it does not already Exist
    //Do we already have a queue?
    NSOperationQueue *queue = [self operationQueueWithURLs:urls];
    
    if (queue.operationCount == urls.count)
        return;
    
    [urls enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        NSString *path = idx < paths.count ? paths[idx] : nil;
        //Do we already have this download item?
        [self addDownloadOperationWithURL:url toQueue:queue
                                      tag:0 useCache:useCache urls:urls paths:path];
    }];
}

- (void) attachNewHandlerWithListener:(id<HYSequentialDownloadManagerDelegate>)listener
                               toURLs:(NSArray*)urls
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    [self removeAllHandlersWithListener:listener];
    
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    //Add a new handler
    HYSequentialDownloadHandler *handler =
    [HYSequentialDownloadHandler downloadingHandlerWithURLs:urls delegate:listener];
    
    [handlers addObject:handler];
    [self.downloadHandlers setObject:handlers forKey:urls];
}

- (void) attachNewHandlerWithProgressBlock:(HYSequentialProgressBlock)progressBlock
                           completionBlock:(HYSequentialCompletionBlock)completionBlock
                                       tag:(NSInteger)tag
                                    toURLs:(NSArray*)urls
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    [self removeHandlerWithTag:tag];
    
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:urls];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    //Add a new handler
    HYSequentialDownloadHandler *handler =
    [HYSequentialDownloadHandler downloadingHandlerWithURLs:urls
                                              progressBlock:progressBlock
                                            completionBlock:completionBlock
                                                        tag:tag];
    
    
    [handlers addObject:handler];
    [self.downloadHandlers setObject:handlers forKey:urls];
}

- (void) removeListener:(id<HYSequentialDownloadManagerDelegate>)listener
{
    [self removeAllHandlersWithListener:listener];
}

- (BOOL) isDownloadingItemWithURLs:(NSArray*)urls
{
    NSOperationQueue *queue = [self operationQueueWithURLs:urls];
    return [queue operationCount] > 0;
}

- (void) stopDownloadingItemWithURLs:(NSArray*)urls
{
    NSOperationQueue *queue = [self operationQueueWithURLs:urls];
    [queue cancelAllOperations];
    
    [self.downloadHandlers removeObjectForKey:urls];
}

#pragma mark Class Interface Memebers
#pragma mark -


+ (void) downloadItemWithURLs:(NSArray*)urls
                     useCache:(BOOL)useCache
{
    [[self instance] downloadItemWithURLs:urls
                                 useCache:useCache];
}

+ (void)downloadItemWithURLs:(NSArray *)urls
                    useCache:(BOOL)useCache
                  saveToPath:(NSArray *)path {
    [[self instance] downloadItemWithURLs:urls
                                 useCache:useCache
                               saveToPath:path];
}

+ (void) attachListener:(id<HYSequentialDownloadManagerDelegate>)listener toURLs:(NSArray*)urls
{
    [[self instance] attachNewHandlerWithListener:listener toURLs:urls];
}

+ (void) attachListenerWithObject:(id)object
                    progressBlock:(HYSequentialProgressBlock)progressBlock
                  completionBlock:(HYSequentialCompletionBlock)completionBlock
                           toURLs:(NSArray*)urls
{
    [[self instance] attachNewHandlerWithProgressBlock:progressBlock
                                       completionBlock:completionBlock
                                                   tag:(int)object
                                                toURLs:urls];
}

+ (void) detachObjectFromListening:(id)object
{
    [[self instance] removeHandlerWithTag:(int)object];
}

+ (void) detachListener:(id<HYSequentialDownloadManagerDelegate>)listener
{
    [[self instance] removeAllHandlersWithListener:listener];
}

+ (BOOL) isDownloadingItemWithURLs:(NSArray*)urls
{
    return [[self instance] isDownloadingItemWithURLs:urls];
}

+ (void) stopDownloadingItemWithURLs:(NSArray*)urls
{
    [[self instance] stopDownloadingItemWithURLs:urls];
}

@end
