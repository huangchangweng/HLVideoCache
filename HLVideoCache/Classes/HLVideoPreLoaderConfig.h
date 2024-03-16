//
//  HLVideoPreLoaderConfig.h
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLVideoPreLoaderConfig : NSObject
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
@end

NS_ASSUME_NONNULL_END
