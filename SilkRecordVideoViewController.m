//
//  SilkRecordVideoViewController.m
//  OSell
//
//  Created by xlg on 2018/10/16.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkRecordVideoViewController.h"

#import "SilkArcProgressLayer.h"
#import "SilkShareNewsWebViewController.h"

@interface SilkRecordVideoViewController () <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) AVPlayer *avPlayer;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) AVCaptureDevice *audioDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *fileOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation SilkRecordVideoViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.title = [self getString:@"视频认证"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.session startRunning];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self videoPath]]) {
        //[self startPlayVideo];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    
    if (self.avPlayer.rate == 1) {
        [self.avPlayer pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
}

#pragma mark - 初始设置
//初始化数据
- (void)setupDatas {
    
}
//设置UI
- (void)layoutViews {
    self.btnView.alpha = 0;
    self.btnView.hidden = YES;
    self.tipsBView.alpha = 1.0;
    self.tipsBView.hidden = NO;
    self.playView.hidden = YES;//默认隐藏播放视图
    
    [self.btnStart setupCornerRadius:37.0];
    [self.btnRerecord setupCornerRadius:22.0];
    [self.btnSure setupCornerRadius:22.0];
    [self.btnRerecord setupBorderColor:RGBCOLOR(40, 130, 200)];
    [self.btnSure setupBorderColor:RGBCOLOR(40, 130, 200)];
    self.lblTips.text = [self getString:@"请您手持证件照正面（有照片一面），将其放置于面部下方，正对摄像头，请摘下帽子、头巾等物品，保持面部在视频中央并在15秒内朗读完以下文字："];
    self.lblSpeak.text = [self getString:@"我是XXX，我承诺在SilkChain的行为符合用户许可协议，保证账户为本人使用。"];
    self.lblTimeTips.text = [self getString:@"开始录制15秒后自动完成"];
    [self.btnStart setTitle:[self getString:@"开始"] forState:UIControlStateNormal];
    [self.btnRerecord setTitle:[self getString:@"重新录制"] forState:UIControlStateNormal];
    [self.btnSure setTitle:[self getString:@"提交"] forState:UIControlStateNormal];
    NSString *strTime = @"15";
    NSString *strTimeTips1 = [self getString:@"开始录制"];
    NSString *strTimeTips2 = [self getString:@"秒后自动完成"];
    NSString *strTimeTips = [NSString stringWithFormat:@"%@%@%@", strTimeTips1, strTime, strTimeTips2];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:strTimeTips];
    [attrText addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(255, 87, 59) range:NSMakeRange(strTimeTips1.length, strTime.length)];
    self.lblTimeTips.attributedText = attrText;
    
    self.layout_navViewHeight.constant = StatusHeight + 44.0;
    [SilkArcProgressLayer showsInView:self.btnStart sWidth:74 lineWidth:8 seconds:15];
    
    [self.recordView.layer addSublayer:self.previewLayer];//coding
}

#pragma mark - 交互事件
//返回
- (IBAction)buttonToBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//帮助
- (IBAction)buttonToHelpAction:(id)sender {
    SilkShareNewsWebViewController *vc = [SilkShareNewsWebViewController new];
    vc.strUrl = @"https://www.baidu.com";//coding
    [self pushController:vc];
}
//开始录制视频
- (IBAction)buttonToStartAction:(id)sender {
    if (self.tipsView.hidden == NO) {
        self.tipsView.hidden = YES;
        self.lblTimeTips.hidden = YES;
    }
    if ([SilkArcProgressLayer isAnimating:self.btnStart]) {
        [SilkArcProgressLayer finishInView:self.btnStart];
        [self animateForChooseResetOrSure:NO];
        [self stopRecording];
        
    } else {
        WS(weakSelf);
        [self startRecording];
        [self.btnStart setTitle:[self getString:@"完成"] forState:UIControlStateNormal];
        [SilkArcProgressLayer startInView:self.btnStart completion:^(NSTimeInterval seconds) {
            [weakSelf animateForChooseResetOrSure:NO];
            [weakSelf stopRecording];
            
        }];
    }
}
//更换前后置摄像头
- (IBAction)buttonToChangeCameraAction:(id)sender {
    NSError *error;
    AVCaptureDevicePosition toPosition = AVCaptureDevicePositionFront;
    if (self.videoDevice.position == AVCaptureDevicePositionUnspecified || self.videoDevice.position == AVCaptureDevicePositionFront) {
        toPosition = AVCaptureDevicePositionBack;
    }
    AVCaptureDevice *toVideoDevice = [self getCameraDeviceWithPosition:toPosition];
    AVCaptureDeviceInput *toVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:toVideoDevice error:&error];
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    if ([self.session canAddInput:toVideoInput]) {
        [self.session addInput:toVideoInput];
        self.videoInput = toVideoInput;
        self.videoDevice = toVideoDevice;
    }
    [self.session commitConfiguration];
}
//重新录制
- (IBAction)buttonToRerecordAction:(id)sender {
    [self animateForChooseResetOrSure:YES];
    [SilkArcProgressLayer resetInView:self.btnStart];
    [self.btnStart setTitle:[self getString:@"开始"] forState:UIControlStateNormal];
    [self deleteRecordedVideo];
    
    if (self.tipsView.hidden) {
        self.tipsView.hidden = NO;
        self.lblTimeTips.hidden = NO;
    }
}
//确认提交
- (IBAction)buttonToSureAction:(id)sender {
    //压缩录制的视频，然后返回设置KYC页面
    UIImage *image = [self getVideoFirstFrameImage];
    if (self.successBlock) {
        self.successBlock(image, [self videoUrl]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//更换显示提示view 或按钮view
- (void)animateForChooseResetOrSure:(BOOL)showTips {
    WS(weakSelf);
    if (showTips) {
        self.tipsBView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.tipsBView.alpha = 1.0;
            weakSelf.btnView.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.btnView.hidden = YES;
        }];
    } else {
        self.btnView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.btnView.alpha = 1.0;
            weakSelf.tipsBView.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.tipsBView.hidden = YES;
        }];
    }
}

#pragma mark - 视频相关
//获取前置或后置摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == position) {
            return camera;
        }
    }
    return [cameras firstObject];
}

//获取视频采集设备
- (AVCaptureDevice *)videoDevice {
    if (!_videoDevice) {
        _videoDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    }
    return _videoDevice;
}
//获取音频采集设备
- (AVCaptureDevice *)audioDevice {
    if (!_audioDevice) {
        _audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    }
    return _audioDevice;
}
//获取画面输入
- (AVCaptureDeviceInput *)videoInput {
    if (!_videoInput) {
        NSError *error;
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:&error];
    }
    return _videoInput;
}
//获取声音输入
- (AVCaptureDeviceInput *)audioInput {
    if (!_audioInput) {
        NSError *error;
        _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
    }
    return _audioInput;
}
//输出
- (AVCaptureMovieFileOutput *)fileOutput {
    if (!_fileOutput) {
        _fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _fileOutput;
}
//创建会话
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //设置画面清晰度
        if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            [_session setSessionPreset:AVCaptureSessionPreset640x480];
        }
        //添加输入源
        if ([_session canAddInput:self.videoInput]) {
            [_session addInput:self.videoInput];
        }
        if ([_session canAddInput:self.audioInput]) {
            [_session addInput:self.audioInput];
        }
        //添加输出源
        if ([_session canAddOutput:self.fileOutput]) {
            [_session addOutput:self.fileOutput];
        }
    }
    return _session;
}
//采集视频展示画面
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.recordView.layer.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

//开始录制视频
- (void)startRecording {
    [self deleteRecordedVideo];
    [self.fileOutput startRecordingToOutputFileURL:[self videoUrl] recordingDelegate:self];
}
//停止录制视频
- (void)stopRecording {
    [self.fileOutput stopRecording];
}
//删除本地已缓存的录制视频
- (BOOL)deleteRecordedVideo {
    NSError *error;
    NSString *filePath = [self videoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [fileManager removeItemAtPath:filePath error:&error];
    }
    return NO;
}

#pragma mark - 录制视频协议
//AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
}

//可选代理
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
}

#pragma mark - 视频播放
//视频播放器
- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[self videoUrl]];
        _avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        _avPlayer.volume = 1.0;
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        playerLayer.frame = self.playView.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.playView.layer addSublayer:playerLayer];
    }
    return _avPlayer;
}
//开始播放视频
- (void)startPlayVideo {
    [self.avPlayer play];
    [self.session stopRunning];
    self.playView.hidden = NO;
    [self addPlayVideoNotification];
}
//停止播放视频
- (void)stopPlayVideo {
    [self.avPlayer pause];
    [self.session startRunning];
    self.playView.hidden = YES;
    [self removePlayVideoNotification];
}
//添加播放视频通知
- (void)addPlayVideoNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationToEndPlayVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationToEndPlayVideo:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
}
//移除播放视频通知
- (void)removePlayVideoNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//视频播放完毕通知处理
- (void)notificationToEndPlayVideo:(NSNotification *)sender {
    [self stopPlayVideo];
}


#pragma mark - 其他
//获取视频第一帧
- (UIImage *)getVideoFirstFrameImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[self videoUrl] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:nil error:nil];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}
//视频存储地址
- (NSURL *)videoUrl {
    NSURL *url = [NSURL fileURLWithPath:[self videoPath]];
    //NSURL *url = [NSURL fileURLWithPath:[self videoPath] isDirectory:NO];
    return url;
}
- (NSString *)videoPath {
    NSString *strVideoName = @"/HC_setKYCVideo.mp4";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@%@", [paths firstObject], strVideoName];
    return filePath;
}

- (void)dealloc {
    [self removePlayVideoNotification];
}


@end


