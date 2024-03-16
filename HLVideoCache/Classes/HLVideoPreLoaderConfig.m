//
//  HLVideoPreLoaderConfig.m
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import "HLVideoPreLoaderConfig.h"

@implementation HLVideoPreLoaderConfig

- (instancetype)init {
    if (self = [super init]) {
        _preLoadNum = 2;
        _nextLoadNum = 2;
        _preloadPrecent = 0.1f;
        _initPreloadNum = 2;
    }
    return self;
}

#pragma mark - Getter

- (NSMutableArray<NSString *> *)playableUrls {
    if (!_playableUrls) {
        _playableUrls = [NSMutableArray new];
    }
    return _playableUrls;
}

@end
