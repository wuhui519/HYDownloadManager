//
//  HYImageTableViewCell.m
//  HYDownloadManager
//
//  Created by Faye on 2016/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

#import "HYImageTableViewCell.h"

@interface HYImageTableViewCell ()
{
    NSURL *url;
    NSArray *urls;
    UILabel *label;
    BOOL parallel;
}
@end

@implementation HYImageTableViewCell

- (void)stopDownloading
{
    if (parallel)
    {
#if USE_BLOCKS
        [HYDownloadManager detachObjectFromListening:self];
#else
        [HYDownloadManager detachListener:self];
#endif
    }
    else
    {
#if USE_BLOCKS
        [HYSequentialDownloadManager detachObjectFromListening:self];
#else
        [HYSequentialDownloadManager detachListener:self];
#endif
    }
}

- (void)setImageWithURLs:(NSArray*)urls_
{
    [self removeViews];
    [self setViewsForParallel:NO];
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    imageView.image = nil;
    
    urls = urls_;
    
    [HYSequentialDownloadManager downloadItemWithURLs:urls
                                             useCache:YES];
    
#if USE_BLOCKS
    [HYSequentialDownloadManager attachListenerWithObject:self
                                            progressBlock:^(float progress, NSInteger index) {
                                                
                                                [self sequentialManagerProgress:progress
                                                                        atIndex:index];
                                                
                                            }
                                          completionBlock:^(BOOL success, id response, NSInteger index) {
                                              
                                              [self sequentialManagerDidFinish:success
                                                                      response:response
                                                                       atIndex:index];
                                              
                                          } toURLs:urls];
#else
    [HYSequentialDownloadManager attachListener:self toURLs:urls];
#endif
}

- (void)setImageWithURL:(NSURL*)url_
{
    [self removeViews];
    [self setViewsForParallel:YES];
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    imageView.image = nil;
    
    url = url_;
    
    [HYDownloadManager downloadItemWithURL:url useCache:YES];
    
    //Use delegate or blocks to inform you of the progress
#if USE_BLOCKS
    [HYDownloadManager attachListenerWithObject:self
                                  progressBlock:^(float progress, NSURL *url) {
                                      [self downloadManagerDidProgress:progress];
                                  }
                                completionBlock:^(BOOL success, id response) {
                                    [self downloadManagerDidFinish:success response:response];
                                } toURL:url];
#else
    [HYDownloadManager attachListener:self toURL:url];
#endif
}

//Parallel download callbacks
- (void)downloadManagerDidFinish:(BOOL)success response:(id)response
{
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    UIImage *image = [UIImage imageWithData:response];
    [imageView setImage:image];
}

- (void)downloadManagerDidProgress:(float)progress
{
    label.text = [NSString stringWithFormat:@"%f %%", progress * 100];
}

//Sequential download callbacks
- (void)sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(NSInteger)index
{
    NSInteger tag = 12332100 + index + 1;
    UIImageView *imageView = (UIImageView*)[self viewWithTag:tag];
    UIImage *image = [UIImage imageWithData:response];
    [imageView setImage:image];
}

- (void)sequentialManagerProgress:(float)progress atIndex:(NSInteger)index
{
    label.text = [NSString stringWithFormat:@"item %ld, %f %%", (long)index, progress * 100];
}

- (void)setViewsForParallel:(BOOL)parallel_
{
    parallel = parallel_;
    if(parallel)
    {
        label = [[UILabel alloc] init];
        [self addSubview:label];
        label.frame = CGRectMake(60, 0, 280, 40);
        label.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        imageView.tag = 123321;
        imageView.frame = CGRectMake(15, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        label = [[UILabel alloc] init];
        [self addSubview:label];
        label.frame = CGRectMake(140, 0, 200, 40);
        label.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView;
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332101;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(15, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332102;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(55, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332103;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(95, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
    }
}

- (void)removeViews
{
    [label removeFromSuperview];
    UIImageView *imageView;
    imageView = (UIImageView*)[self viewWithTag:123321];
    [imageView removeFromSuperview];
    
    imageView = (UIImageView*)[self viewWithTag:12332101];
    [imageView removeFromSuperview];
    imageView = (UIImageView*)[self viewWithTag:12332102];
    [imageView removeFromSuperview];
    imageView = (UIImageView*)[self viewWithTag:12332103];
    [imageView removeFromSuperview];
    
}

@end
