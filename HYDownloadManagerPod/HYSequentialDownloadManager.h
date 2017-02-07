//
//  HYSequentialDownloadManager.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HYSequentialProgressBlock)(float progress, NSInteger index);
typedef void (^HYSequentialCompletionBlock)(BOOL success, id response, NSInteger index);

@protocol HYSequentialDownloadManagerDelegate <NSObject>
- (void) sequentialManagerProgress:(float)progress atIndex:(NSInteger)index;
- (void) sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(NSInteger)index;
@end

@interface HYSequentialDownloadManager : NSObject

//Start the download request for a sequence of URLs,
//note that the same sequence of URLs will never be downloaded twice
+ (void) downloadItemWithURLs:(NSArray *)urls
                     useCache:(BOOL)useCache;

+ (void)downloadItemWithURLs:(NSArray *)urls
                    useCache:(BOOL)useCache
                  saveToPath:(NSArray *)path;

//Delegate based events
// 1 set of URLs can have multiple listeners
// But 1 listener cannot listen to multiple URLs
+ (void) attachListener:(id<HYSequentialDownloadManagerDelegate>)listener toURLs:(NSArray*)urls;

//Detach the listener from listening to more events,
//Please note that the URLs will still download
+ (void) detachListener:(id<HYSequentialDownloadManagerDelegate>)listener;

//Block based events
//object param must be equal to self to ensure that 1 object can listen to only 1 download operation
+ (void) attachListenerWithObject:(id)object
                    progressBlock:(HYSequentialProgressBlock)progressBlock
                  completionBlock:(HYSequentialCompletionBlock)completionBlock
                           toURLs:(NSArray*)urls;

//Remove listener
+ (void) detachObjectFromListening:(id)object;

+ (BOOL) isDownloadingItemWithURLs:(NSArray*)urls;
+ (void) stopDownloadingItemWithURLs:(NSArray*)urls;

@end
