//
//  BMFileCache.h
//  Bubbly
//
//  Created by Dmitry Klimkin on 18/9/13.
//
//

#import <Foundation/Foundation.h>

typedef void (^BMFileCacheGetFileBlock)(NSString *filePath);
typedef void (^BMFileCacheGetImageBlock)(UIImage *image);
typedef void (^BMFileCacheGetImagesBlock)(NSArray *images, double duration);
typedef void (^BMFileCacheGetAnimatedImageBlock)(UIImage *image);
typedef void (^BMFileCacheGetAudioBlock)(NSString *audioFilePath);

@interface BMFileCache : NSObject

@property (nonatomic, strong) NSString *defaultCacheFolder;

+ (BMFileCache *)sharedInstance;

- (void)imageForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetImageBlock)completeBlock;
- (void)animatedImageForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetAnimatedImageBlock)completeBlock;
//- (void)imagesForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetImagesBlock)completeBlock;
- (void)audioForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetAudioBlock)completeBlock;

- (void)removeCachedFileForURL: (NSString *)url;
- (void)clear;
- (void)cancelAllRequests;
- (BOOL)isFileCachedForUrl: (NSString *)url;

@end
