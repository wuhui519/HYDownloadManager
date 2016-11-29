# HYDownloadManager
a tool downloads file with memory cache, temporary cache and permanent store.

## How To Use
1. parallel downloading:
HYDownloadManager
```
//Start the download request for a URL, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache;
```
```
//Delegate based events
// 1 url download operation can have multiple listeners
// But 1 listener cannot listen to 1 url download operation
+ (void) attachListener:(id<HYDownloadManagerDelegate>)listener toURL:(NSURL*)url;
```                 
                    
2. sequential downloading:
HYSequentialDownloadHandler
```
+ (HYSequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                              progressBlock:(HYSequentialProgressBlock)progressBlock
                                            completionBlock:(HYSequentialCompletionBlock)completionBlock
                                                        tag:(NSInteger)tag;
```
