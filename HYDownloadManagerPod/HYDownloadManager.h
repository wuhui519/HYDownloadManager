//
//  HYDownloadManager.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HYDownloadOperation;

typedef void (^HYProgressBlock)(float progress, NSURL *url);
typedef void (^HYCompletionBlock)(BOOL success, id response);

@protocol HYDownloadManagerDelegate <NSObject>
- (void) downloadManagerDidProgress:(float)progress;
- (void) downloadManagerDidFinish:(BOOL)success response:(id)response;
@end

@interface HYDownloadManager : NSObject

//Start the download request for a URL, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache;

//Start the download request for a URL and saving to a file, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
                  saveToPath:(NSString *)path;

//Delegate based events
// 1 url download operation can have multiple listeners
// But 1 listener cannot listen to 1 url download operation
+ (void) attachListener:(id<HYDownloadManagerDelegate>)listener toURL:(NSURL*)url;

//Detach the listener from listening to more events,
//Please note that the url will still download
+ (void) detachListener:(id<HYDownloadManagerDelegate>)listener;

//Block based events
//object param must be equal to self to ensure that 1 object can listen to only 1 download operation
+ (void) attachListenerWithObject:(id)object
                    progressBlock:(HYProgressBlock)progressBlock
                  completionBlock:(HYCompletionBlock)completionBlock
                            toURL:(NSURL*)url;
//Remove listener
+ (void) detachObjectFromListening:(id)object;

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url;
+ (void) stopDownloadingItemWithURL:(NSURL*)url;
+ (NSInteger) listenerCountForUrl:(NSURL *)url;

@end
