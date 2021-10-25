//
//  ViewController.m
//  AliPlayerDemo
//
//  Created by appl on 2020/4/17.
//  Copyright © 2020 lyeah. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <AliyunPlayer/AliyunPlayer.h>

@interface ViewController () <AVPDelegate>

@property (nonatomic, copy) NSString *cacheDirectory;

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) AliPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupWhenViewDidLoad];
    [self setupPlayer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setupWhenViewDidLoad
{
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
    }];
}

- (NSString *)cacheDirectory
{
    if (!_cacheDirectory) {
        NSString *cachePath =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *cacheDirectory = [NSString stringWithFormat:@"%@/%@", cachePath, @"PSPhotos"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL isExists = [fileManager fileExistsAtPath:cacheDirectory isDirectory:&isDir];
        if (isExists && isDir) {
            
        } else {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _cacheDirectory = cacheDirectory;
    }
    return _cacheDirectory;
}

- (void)setupPlayer
{
    AliPlayer *player = [[AliPlayer alloc] init];
    player.delegate = self;
    player.enableHardwareDecoder = YES;
    player.loop = YES;
    player.autoPlay = YES;
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:@"http://xcycdn-video.zhongguowangshi.com/live-video/dntupfrpf00.mp4"];
    
    [player setUrlSource:urlSource];
    AVPCacheConfig *cacheConfig = [[AVPCacheConfig alloc] init];
    /// 开启缓存功能
    cacheConfig.enable = YES;
    /// 能够缓存的单个文件最大时长。超过此长度则不缓存
    cacheConfig.maxDuration = 100000;
    /// 缓存目录的位置，需替换成app期望的路径
    cacheConfig.path = self.cacheDirectory;
    /// 缓存目录的最大大小。超过此大小，将会删除最旧的缓存文件
    cacheConfig.maxSizeMB = 200000;
    /// 设置缓存配置给到播放器
    [player setCacheConfig:cacheConfig];
    //先获取配置
    AVPConfig *config = [self.player getConfig];
    //设置网络超时时间，单位ms
    config.networkTimeout = 5000;
    //设置超时重试次数。每次重试间隔为networkTimeout。networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
    config.networkRetryCount = 2;
    [player setConfig:config];
    player.playerView = self.playerView;
    [player prepare];
    [AliPlayer setEnableLog:YES];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_ERROR callbackBlock:^(AVPLogLevel logLevel, NSString *strLog) {
        NSLog(@"*** 错误日志 *** %@", strLog);
    }];
    self.player = player;
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType
{
    NSLog(@"是否在主线程：%@", @([NSThread isMainThread]));
    if (eventType == AVPEventPrepareDone) {
//        AVPMediaInfo *info = [player getMediaInfo];
//        NSArray<AVPTrackInfo*>* tracks = info.tracks;
//        NSLog(@"%@", tracks);
    }
}

- (void)onPlayerEvent:(AliPlayer *)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description
{
    NSLog(@"eventWithString：%@，description：%@", @(eventWithString), description);
}

- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus
{
    NSLog(@"之前的状态：%@，现在的状态：%@", @(oldStatus), @(newStatus));
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel
{
    NSLog(@"播放报错了：%@ -- %@", @(errorModel.code), errorModel.message);
}

- (void)onLoadingProgress:(AliPlayer *)player progress:(float)progress
{
    NSLog(@"播放进度：%@", @(progress));
}

- (void)onTrackReady:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info
{
    for (AVPTrackInfo *track in info) {
        if (track.trackType == AVPTRACK_TYPE_VIDEO) {
            NSLog(@"onTrackReady: %@", track);
        } else {
            NSLog(@"onTrackReady: %@", @(track.trackType));
        }
    }
}

- (void)onTrackChanged:(AliPlayer *)player info:(AVPTrackInfo *)info
{
    NSLog(@"onTrackChanged: %@", info);
}

#pragma mark - getters

- (UIView *)playerView
{
    if (!_playerView) {
        UIView *playerView = [[UIView alloc] init];
        playerView.clipsToBounds = YES;
        playerView.backgroundColor = [UIColor redColor];
        _playerView = playerView;
    }
    return _playerView;;
}

@end
