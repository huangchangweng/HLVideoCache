# HLVideoCache

对KTVHTTPCache进行封装，实现视频边下边播，实现列表视频秒开

##### 支持使用CocoaPods引入, Podfile文件中添加:

```objc
pod 'HLVideoCache', '0.1.1'
```

# Demonstration

```objc
// 1.在AppDelegate中
[[HLVideoCache shared] initKTVHTTPCache];
// 2.在播放列表页面
// 2.1.请求完数据
HLVideoPreLoaderConfig *config = [HLVideoPreLoaderConfig new];
config.playableUrls = urls;
[[HLVideoCache shared] setupPreLoaderConfig:config];
// 2.2.播放视频时
[[HLVideoCache shared] setupCurrentPlayingUrl:model.video_url];
[self.player playTheIndexPath:indexPath assetURL:[HLVideoCache proxyURLWithOriginalURL:model.video_url]];
```

可设置属性:<p>

```objc
// HLVideoCache
/// 缓存最大容量，默认500M(即500 * 1024 * 1024)
@property (nonatomic, assign) long long maxCacheLength;
/// 是否开启日志，默认NO
@property (nonatomic, assign) BOOL logEnable; 

// HLVideoPreLoaderConfig
/// 预加载上几条，默认2
@property (nonatomic, assign) NSUInteger preLoadNum;
/// 预加载下几条，默认2
@property (nonatomic, assign) NSUInteger nextLoadNum;
/// 预加载的的百分比，默认10%
@property (nonatomic, assign) double preloadPrecent;
/// 设置playableUrls后，马上预加载的条数，默认2
@property (nonatomic, assign) NSUInteger initPreloadNum;
/// 视频url数组，注意：NSMutableArray
@property (nonatomic, strong) NSMutableArray<NSString *> *playableUrls;
```

# Requirements

iOS 12.0 +, Xcode 11.0 +

# Version

* 0.1.1 :
  
  添加销毁方法

* 0.1.0 :
  
  完成HLVideoCache基础搭建

# License

HLVideoCache is available under the MIT license. See the LICENSE file for more info.
