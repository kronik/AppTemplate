//
//  BMFileCache.m
//  Bubbly
//
//  Created by Dmitry Klimkin on 18/9/13.
//
//

#import "BMFileCache.h"
#import "BMUtility.h"
#import "BMMkManager.h"
#import "NSString+MD5Addition.h"
#import "UIImage+animatedGIF.h"

#define BMFileCacheFolder @"file_cache"

@interface BMFileCache () {
    NSMapTable* itemsObjectPool;
}

@end

@implementation BMFileCache

@synthesize defaultCacheFolder = _defaultCacheFolder;

+ (BMFileCache *)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static BMFileCache *_sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[BMFileCache alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (id)init {
    self = [super init];
    
	if (self != nil) {
        itemsObjectPool = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:10];
        self.defaultCacheFolder = BMFileCacheFolder;
	}
	return self;
}

- (void)setDefaultCacheFolder:(NSString *)defaultCacheFolder {
    _defaultCacheFolder = defaultCacheFolder;
    
    [self createDefaultCacheFolder: defaultCacheFolder];
}

- (void)createDefaultCacheFolder: (NSString *)defaultFolder {
    NSString *documentsDirectory = [BMUtility documentsDirectory];
    NSString *cacheDirectory = [documentsDirectory stringByAppendingPathComponent:defaultFolder];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)cachedFilePathForURL: (NSString *)url {
    NSArray *fileParts = [url componentsSeparatedByString:@"."];
    
    if (fileParts.count < 2) {
        return nil;
    }
    NSURL *realUrl = [NSURL URLWithString:url];
    NSString *fileKey = [realUrl.path stringFromMD5];
    NSString *cachedFilePath = [NSString stringWithFormat:@"%@/%@/%@.%@",
                                [BMUtility documentsDirectory],
                                self.defaultCacheFolder, fileKey, fileParts[fileParts.count - 1]];
    return cachedFilePath;
}

- (void)cacheData: (NSData *)fileData intoFile: (NSString *)filePath {
    [fileData writeToFile:filePath atomically:YES];
}

- (void)imageForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetImageBlock)completeBlock {
    
    NSString *cachedFilePath = [self cachedFilePathForURL: url];
    
    if (cachedFilePath == nil) {
        completeBlock (nil);
        return;
    }
    
    UIImage *image = [itemsObjectPool objectForKey:cachedFilePath];
    if (image != nil) {
        completeBlock (image);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]) {
        
        UIImage *newImage = [UIImage imageWithContentsOfFile:cachedFilePath];
        
        if (newImage != nil) {
            [itemsObjectPool setObject:newImage forKey:cachedFilePath];
        }
        
        completeBlock (newImage);
        return;
    }
        
    [[BMMkManager sharedInstance] downloadFile:url onCompletion:^(NSData *fileData) {
        if (fileData != nil) {
            [self cacheData: fileData intoFile: cachedFilePath];
            
            UIImage *newImage = [UIImage imageWithContentsOfFile:cachedFilePath];
            
            if (newImage != nil) {
                [itemsObjectPool setObject:newImage forKey:cachedFilePath];
            }
            
            completeBlock (newImage);
        } else {
            completeBlock (nil);
        }
        
    } onDownloadProgressChanged:^(double progress) {
    } onError:^(NSError *error) {
        completeBlock (nil);
    }];
}

- (void)imagesForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetImagesBlock)completeBlock {
    NSString *cachedFilePath = [self cachedFilePathForURL: url];
    
    if (cachedFilePath == nil) {
        completeBlock (nil, 0);
        return;
    }
    
    NSDictionary *imagesData = [itemsObjectPool objectForKey:cachedFilePath];

    if (imagesData != nil) {
        completeBlock (imagesData[@"images"], [imagesData[@"duration"] doubleValue]);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]) {
        NSURL *fileUrl = [NSURL fileURLWithPath: cachedFilePath];
        
        NSDictionary *newImagesData = [UIImage imagesWithAnimatedGIFURL:fileUrl];
        
        if (newImagesData != nil) {
            [itemsObjectPool setObject:newImagesData forKey:cachedFilePath];
        }
        
        completeBlock (newImagesData[@"images"], [newImagesData[@"duration"] doubleValue]);
        return;
    }
    
    [[BMMkManager sharedInstance] downloadFile:url onCompletion:^(NSData *fileData) {
        if (fileData != nil) {
            [self cacheData: fileData intoFile: cachedFilePath];
            
            NSURL *fileUrl = [NSURL fileURLWithPath: cachedFilePath];
            NSDictionary *newImagesData = [UIImage imagesWithAnimatedGIFURL:fileUrl];
            
            if (newImagesData != nil) {
                [itemsObjectPool setObject:newImagesData forKey:cachedFilePath];
            }
            
            completeBlock (newImagesData[@"images"], [newImagesData[@"duration"] doubleValue]);
        }
        
    } onDownloadProgressChanged:^(double progress) {
    } onError:^(NSError *error) {
        completeBlock (nil, 0);
    }];
}

- (void)animatedImageForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetAnimatedImageBlock)completeBlock {
    NSString *cachedFilePath = [self cachedFilePathForURL: url];
    
    if (cachedFilePath == nil) {
        completeBlock (nil);
        return;
    }
    
    UIImage *image = [itemsObjectPool objectForKey:cachedFilePath];
    
    if (image != nil) {
        completeBlock (image);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]) {
        NSURL *fileUrl = [NSURL fileURLWithPath: cachedFilePath];
        
        UIImage *newImage = [UIImage animatedImageWithAnimatedGIFURL:fileUrl];
        
        if (newImage != nil) {
            [itemsObjectPool setObject:newImage forKey:cachedFilePath];
        }
        
        completeBlock (newImage);
        return;
    }
    
    [[BMMkManager sharedInstance] downloadFile:url onCompletion:^(NSData *fileData) {
        if (fileData != nil) {
            [self cacheData: fileData intoFile: cachedFilePath];
            
            NSURL *fileUrl = [NSURL fileURLWithPath: cachedFilePath];
            UIImage *animatedImage = [UIImage animatedImageWithAnimatedGIFURL:fileUrl];
            
            if (animatedImage != nil) {
                [itemsObjectPool setObject:animatedImage forKey:cachedFilePath];
            }
            
            completeBlock (animatedImage);
        }
        
    } onDownloadProgressChanged:^(double progress) {
    } onError:^(NSError *error) {
        completeBlock (nil);
    }];
}

- (void)audioForUrl: (NSString *)url withCompleteBlock: (BMFileCacheGetAudioBlock)completeBlock {
    
    NSString *cachedFilePath = [self cachedFilePathForURL: url];
    
    if (cachedFilePath == nil) {
        completeBlock (nil);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]) {
        completeBlock (cachedFilePath);
        return;
    }
    
    [[BMMkManager sharedInstance] downloadFile:url onCompletion:^(NSData *fileData) {
        if (fileData != nil) {
            [self cacheData: fileData intoFile: cachedFilePath];
            completeBlock (cachedFilePath);
        }
        
    } onDownloadProgressChanged:^(double progress) {
    } onError:^(NSError *error) {
        completeBlock (nil);
    }];
}

- (BOOL)isFileCachedForUrl: (NSString *)url {
    NSString *cachedFilePath = [self cachedFilePathForURL: url];

    return ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]);
}

- (void)removeCachedFileForURL: (NSString *)url {
    NSString *cachedFilePath = [self cachedFilePathForURL: url];
    [itemsObjectPool removeObjectForKey: cachedFilePath];
    if (cachedFilePath.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:cachedFilePath error:nil];
    }
}

- (void)clear {
    
    NSString *cachedFolderPath = [NSString stringWithFormat:@"%@/%@/", [BMUtility documentsDirectory], self.defaultCacheFolder];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachedFolderPath error:nil];

    for (NSString *cachedFilePath in files) {
        [itemsObjectPool removeObjectForKey: cachedFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:cachedFilePath error:nil];
    }
}

- (void)cancelAllRequests {
    [BMMkManager cancelOperationsContainingURLString:@"cloudfront.net"];
}

@end
