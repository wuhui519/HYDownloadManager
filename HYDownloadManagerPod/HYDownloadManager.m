//
//  HYDownloadManager.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "HYDownloadManager.h"
#import "HYDownloadHandler.h"
#import "HYDownloadOperation.h"

@interface HYDownloadManager()

@property (nonatomic, strong) NSMutableDictionary *downloadOperations;
@property (nonatomic, strong) NSMutableDictionary *downloadHandlers;

- (void)removeHandlerWithTag:(NSInteger)tag;

@end

@implementation HYDownloadManager

#pragma mark Initialization
#pragma mark -

+ (HYDownloadManager*) instance
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
        self.downloadOperations = [NSMutableDictionary new];
        self.downloadHandlers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark Global Blocks
#pragma mark -

void (^globalProgressBlock)(float progress, NSURL *url, HYDownloadManager* self) =
^(float progress, NSURL *url, HYDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(HYDownloadHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if(handler.progressBlock)
            handler.progressBlock(progress, url);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidProgress:)])
            [handler.delegate downloadManagerDidProgress:progress];
        
    }];
};

void (^globalCompletionBlock)(BOOL success, id response, NSURL *url, HYDownloadManager* self) =
^(BOOL success, id response, NSURL *url, HYDownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(HYDownloadHandler *handler, NSUInteger idx, BOOL *stop) {
    
        if(handler.completionBlock)
            handler.completionBlock(success, response);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidFinish:response:)])
            [handler.delegate downloadManagerDidFinish:success response:response];
        
    }];
    
    //Remove the download handlers
    [self.downloadHandlers removeObjectForKey:url];
    
    //Remove the download operation
    [self.downloadOperations removeObjectForKey:url];
};

#pragma mark Entry Point
#pragma mark -

- (void) attachNewHandlerWithListener:(id<HYDownloadManagerDelegate>)listener
                                toURL:(NSURL*)url
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    [self removeHandlerWithListener:listener];
    
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    HYDownloadHandler *handler = [HYDownloadHandler downloadingHandlerWithURL:url
                                                                     delegate:listener];
    
    
    [handlers addObject:handler];
    [self.downloadHandlers setObject:handlers forKey:url];
}

- (void) attachNewHandlerWithProgressBlock:(HYProgressBlock)progressBlock
                           completionBlock:(HYCompletionBlock)completionBlock
                                       tag:(NSInteger)tag
                                     toURL:(NSURL*)url
{
    //unlink the tag from the urls
    [self removeHandlerWithTag:tag];
    
    //Add the new handler
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (!handlers)
        handlers = [NSMutableArray new];
    
    HYDownloadHandler *handler = [HYDownloadHandler downloadingHandlerWithURL:url
                                                                progressBlock:progressBlock
                                                              completionBlock:completionBlock
                                                                          tag:tag];
    
    
    [handlers addObject:handler];

    [self.downloadHandlers setObject:handlers forKey:url];
}


#pragma mark Downloading
#pragma mark -

- (void)startDownloadOperation:(NSURL*)url
                      useCache:(BOOL)useCache
                    saveToPath:(NSString *)path
{
    if([self isDownloadingItemWithURL:url])
        return;
    
    HYDownloadOperation *downloadingOperation = [HYDownloadOperation
                                                 downloadingOperationWithURL:url
                                                 useCache:useCache
                                                 filePath:path
                                                 progressBlock:^(float progress, id x) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         globalProgressBlock(progress, url, self);
                                                     });
                                                 }
                                                 completionBlock:^(BOOL success, id response) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         globalCompletionBlock(success, response, url, self);
                                                     });
                                                 }];
    
    if(downloadingOperation)
    {
        [downloadingOperation start];
    
        //Add the new operation
        [self.downloadOperations setObject:downloadingOperation forKey:url];
    }
}

- (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [self.downloadOperations objectForKey:url] != nil;
}

#pragma mark HYDownloadHandlers and HYDownloadOperation Helpers
#pragma mark -

- (void)removeHandlerWithURL:(NSURL*)url tag:(NSInteger)tag
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            HYDownloadHandler *handler = handlers[i];
            
            if (handler.tag == tag)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithURL:(NSURL*)url listener:(id)listener
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (NSInteger i = handlers.count - 1; i >= 0; i-- )
        {
            HYDownloadHandler *handler = handlers[i];
            
            if (handler.delegate == listener)
            {
                [handlers removeObject:handler];
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
            HYDownloadHandler *handler = array[j];
            if (handler.tag == tag)
            {
                [array removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithListener:(id)listener
{
    for (NSInteger i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (NSInteger j = array.count - 1; j >= 0; j-- )
        {
            HYDownloadHandler *handler = array[j];
            if (handler.delegate == listener)
            {
                [array removeObject:handler];
            }
        }
    }
}


#pragma mark Class Interface Memebers
#pragma mark -

+ (void) downloadItemWithURL:(NSURL*)url useCache:(BOOL)useCache
{
    [HYDownloadManager downloadItemWithURL:url useCache:useCache saveToPath:nil];
}

+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
                  saveToPath:(NSString *)path
{
    [[self instance] startDownloadOperation:url useCache:useCache saveToPath:path];
}

+ (void) attachListener:(id<HYDownloadManagerDelegate>)listener toURL:(NSURL*)url
{
    [[self instance] attachNewHandlerWithListener:listener toURL:url];
}

+ (void) detachListener:(id<HYDownloadManagerDelegate>)listener;
{
    [[self instance] removeHandlerWithListener:listener];
}

+ (void) attachListenerWithObject:(id)object
                    progressBlock:(HYProgressBlock)progressBlock
                  completionBlock:(HYCompletionBlock)completionBlock
                            toURL:(NSURL*)url

{
    [[self instance] attachNewHandlerWithProgressBlock:progressBlock
                                       completionBlock:completionBlock
                                                   tag:object ? (int)object : NSNotFound
                                                 toURL:url];
}

+ (void) detachObjectFromListening:(id)object
{
    [[self instance] removeHandlerWithTag:(int)object];
}

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [[self instance] isDownloadingItemWithURL:url];
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
                             andTag:(NSInteger)tag
{
    [self.instance removeHandlerWithURL:url tag:tag];
    
    NSArray *handlers = [[self instance].downloadHandlers objectForKey:url];
    if (handlers.count == 0) {
        [self stopDownloadingItemWithURL:url];
    }
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
{
    [[[self instance].downloadOperations objectForKey:url] stop];
}

+ (NSInteger)listenerCountForUrl:(NSURL *)url
{
    NSMutableArray *handlers = [[self instance].downloadHandlers objectForKey:url];
    return handlers.count;
}

@end
