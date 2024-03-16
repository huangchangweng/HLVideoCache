//
//  HLVideoCache.h
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import <Foundation/Foundation.h>
#import "HLVideoPreLoaderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLVideoCache : NSObject
/// 缓存最大容量，默认500M(即500 * 1024 * 1024)
@property (nonatomic, assign) long long maxCacheLength;
/// 是否开启日志，默认NO
@property (nonatomic, assign) BOOL logEnable;

#pragma mark - Public Method

/// 单例
+ (instancetype)shared;

/**
 * 初始化KTVHTTPCache
 * 注意：该方法只应调用一次，建议在AppDelegate掉用
 */
- (void)initKTVHTTPCache;

/**
 * 视频实现边下边播
 */
+ (NSURL *)proxyURLWithOriginalURL:(NSString *)originalURL;

#pragma mark List Video Method

/**
 * 设置预加载配置
 * 一般在刷新的时候调用
 */
- (void)setupPreLoaderConfig:(HLVideoPreLoaderConfig *)config;

/**
 * 添加预加载视频url数组
 * 一般在加载更多事调用
 */
- (void)addPreLoaderVideoUrls:(NSArray<NSString *> *)urls;

/**
 * 设置当前播放的视频url
 */
- (NSURL *)setupCurrentPlayingUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
