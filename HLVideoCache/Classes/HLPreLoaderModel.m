//
//  HLPreLoaderModel.m
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import "HLPreLoaderModel.h"

@implementation HLPreLoaderModel

/// 初始化方法
- (instancetype)initWithURL:(NSString *)url
                     loader:(KTVHCDataLoader *)loader
{
    if (self = [super init]) {
        _url = url;
        _loader = loader;
    }
    return self;
}

@end
