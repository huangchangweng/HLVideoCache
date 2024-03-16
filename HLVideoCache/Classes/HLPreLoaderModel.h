//
//  HLPreLoaderModel.h
//  HLVideoCache
//
//  Created by 黄常翁 on 2024/3/16.
//

#import <Foundation/Foundation.h>
#import <KTVHTTPCache/KTVHTTPCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLPreLoaderModel : NSObject
/// 加载的url
@property (nonatomic, copy, readonly) NSString *url;
/// 请求url的Loader
@property (nonatomic, strong, readonly) KTVHCDataLoader *loader;
/// 初始化方法
- (instancetype)initWithURL:(NSString *)url
                     loader:(KTVHCDataLoader *)loader;
@end

NS_ASSUME_NONNULL_END
