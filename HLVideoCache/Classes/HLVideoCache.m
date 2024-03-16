//
//  HLVideoCache.m
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import "HLVideoCache.h"
#import <KTVHTTPCache/KTVHTTPCache.h>
#import "HLPreLoaderModel.h"

@interface HLVideoCache()<KTVHCDataLoaderDelegate>
@property (nonatomic, strong) HLVideoPreLoaderConfig *config;
@property (nonatomic, strong) NSMutableArray<HLPreLoaderModel *> *preloadArr;
@end

@implementation HLVideoCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxCacheLength = 500 * 1024 *1024;
        _logEnable = NO;
    }
    return self;
}

#pragma mark - Private Method

/// 取消所有预加载
- (void)cancelAllPreload
{
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0) {
            return;
        }
        [self.preloadArr enumerateObjectsUsingBlock:^(HLPreLoaderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.loader close];
        }];
        [self.preloadArr removeAllObjects];
    }
}

/// 获取预加载对象
- (HLPreLoaderModel *)getPreloadModel:(NSString *)url
{
    if (!url || [url isEqualToString:@""]) {
        return nil;
    }
        
    // 判断是否已在队列中
    __block Boolean res = NO;
    @synchronized (self.preloadArr) {
        [self.preloadArr enumerateObjectsUsingBlock:^(HLPreLoaderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.url isEqualToString:url]) {
                res = YES;
                *stop = YES;
            }
        }];
    }
    if (res) {
        return nil;
    }
    NSURL *proxyUrl = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:url]];
    KTVHCDataCacheItem *item = [KTVHTTPCache cacheCacheItemWithURL:proxyUrl];
    double cachePrecent = 1.0 * item.cacheLength / item.totalLength;
    // 判断缓存已经超过配置的大小了
    if (cachePrecent >= self.config.preloadPrecent) {
        return nil;
    }
        
    KTVHCDataRequest *req = [[KTVHCDataRequest alloc] initWithURL:proxyUrl headers:[NSDictionary dictionary]];
    KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:req];
    HLPreLoaderModel *preModel = [[HLPreLoaderModel alloc] initWithURL:url loader:loader];
    return preModel;
}

/// 开始预加载
- (void)processLoader
{
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0) {
            return;
        }
        HLPreLoaderModel *model = self.preloadArr.firstObject;
        model.loader.delegate = self;
        [model.loader prepare];
    }
}

/// 根据loader，移除预加载任务
- (void)removePreloadTask:(KTVHCDataLoader *)loader
{
    @synchronized (self.preloadArr) {
        HLPreLoaderModel *target = nil;
        for (HLPreLoaderModel *model in self.preloadArr) {
            if ([model.loader isEqual:loader]) {
                target = model;
                break;
            }
        }
        if (target) {
            [self.preloadArr removeObject:target];
        }
    }
}

/// 批量添加预加载对象
- (void)addPreLoaderModels:(NSArray<NSString *> *)urls
{
    for (NSString *url in urls) {
        HLPreLoaderModel *preload = [self getPreloadModel:url];
        if (preload) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject:preload];
            }
        }
    }
}

#pragma mark - Public Method

/// 单例
+ (instancetype)shared {
    static HLVideoCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HLVideoCache alloc] init];
    });
    return instance;
}

/**
 * 初始化KTVHTTPCache
 * 注意：该方法只应调用一次，建议在AppDelegate掉用
 */
- (void)initKTVHTTPCache
{
    [KTVHTTPCache logSetConsoleLogEnable:self.logEnable];
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    }
    [KTVHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
        return URL;
    }];
    [KTVHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
        return NO;
    }];
    // 设置缓存最大容量
    [KTVHTTPCache cacheSetMaxCacheLength:self.maxCacheLength];
}

/**
 * 视频实现边下边播
 */
+ (NSURL *)proxyURLWithOriginalURL:(NSString *)originalURL
{
    if (!originalURL || [originalURL isEqualToString:@""]) {
        return nil;
    }
    
    // 如果有缓存，直接取本地缓存
    NSURL *url = [KTVHTTPCache cacheCompleteFileURLWithURL:[NSURL URLWithString:originalURL]];
    if (url) {
        return url;
    }
    
    NSURL *proxyURL = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:originalURL]];
    return proxyURL;
}

#pragma mark List Video Method

/**
 * 设置预加载配置
 * 一般在刷新的时候调用
 */
- (void)setupPreLoaderConfig:(HLVideoPreLoaderConfig *)config
{
    _config = config;
    
    // 取消所有预加载
    [self cancelAllPreload];
    
    // 默认预加载前几条数据
    NSRange range = NSMakeRange(0, _config.initPreloadNum);
    if (range.length > _config.playableUrls.count) {
        range.length = _config.playableUrls.count;
        NSArray *subArr = [_config.playableUrls subarrayWithRange:range];
        [self addPreLoaderModels:subArr];
        [self processLoader];
    }
}

/**
 * 添加预加载视频url数组
 * 一般在加载更多事调用
 */
- (void)addPreLoaderVideoUrls:(NSArray<NSString *> *)urls
{
    [self.config.playableUrls addObjectsFromArray:urls];
    [self addPreLoaderModels:urls];
}

/**
 * 设置当前播放的视频url
 */
- (NSURL *)setupCurrentPlayingUrl:(NSString *)url
{
    // 获取前几条和后几条进行预加载
    if ((self.config.preLoadNum > 0 || self.config.nextLoadNum > 0) &&
        self.config.playableUrls.count >= 1 &&
        [self.config.playableUrls containsObject:url])
    {
        // 取消所有预加载
        [self cancelAllPreload];
        
        NSInteger currentIndex = [self.config.playableUrls indexOfObject:url];
        NSMutableArray *arr = [NSMutableArray new];
        // 前几条
        if (self.config.preLoadNum > 0 && currentIndex >= 1) {
            NSMutableArray *preArr = [NSMutableArray new];
            NSInteger index = 0;
            for (NSInteger i = currentIndex - 1; i >= 0 && index < self.config.preLoadNum; i--) {
                index += 1;
                [preArr addObject:self.config.playableUrls[index]];
            }
            [arr addObjectsFromArray:preArr];
        }
        // 后几条
        if (self.config.nextLoadNum > 0 && currentIndex != self.config.playableUrls.count - 1) {
            NSArray *nextArr = [self.config.playableUrls subarrayWithRange:NSMakeRange(currentIndex, self.config.nextLoadNum)];
            [arr addObjectsFromArray:nextArr];
        }
        if (arr.count > 0) {
            [self addPreLoaderModels:arr];
            [self processLoader];
        }
    }
    
    return [HLVideoCache proxyURLWithOriginalURL:url];
}

#pragma mark - KTVHCDataLoaderDelegate

- (void)ktv_loaderDidFinish:(KTVHCDataLoader *)loader
{
    
}

- (void)ktv_loader:(KTVHCDataLoader *)loader didFailWithError:(NSError *)error
{
    // 若预加载失败的话，就直接移除任务，开始下一个预加载任务
    [self removePreloadTask:loader];
    [self processLoader];
}

- (void)ktv_loader:(KTVHCDataLoader *)loader didChangeProgress:(double)progress
{
    if (self.config && progress >= self.config.preloadPrecent) {
        [loader close];
        [self removePreloadTask:loader];
        [self processLoader];
    }
}

#pragma mark - Getter

- (NSMutableArray<HLPreLoaderModel *> *)preloadArr {
    if (!_preloadArr) {
        _preloadArr = [NSMutableArray new];
    }
    return _preloadArr;
}

@end
