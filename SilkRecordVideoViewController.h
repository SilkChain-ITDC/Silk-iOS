//
//  SilkRecordVideoViewController.h
//  OSell
//
//  Created by xlg on 2018/10/16.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^kRecordVideoSuccessBlock)(UIImage *image, NSURL *fileUrl);

@interface SilkRecordVideoViewController : Base


@property (assign, nonatomic) BOOL isPlayVideo;
@property (copy, nonatomic) NSString *videoHttpURL;
@property (copy, nonatomic) kRecordVideoSuccessBlock successBlock;


@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIView *recordView;

@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UIButton *btnRerecord;
@property (weak, nonatomic) IBOutlet UIButton *btnSure;

@property (weak, nonatomic) IBOutlet UIView *tipsBView;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (weak, nonatomic) IBOutlet UILabel *lblTips;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeak;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeTips;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_navViewHeight;

//返回
- (IBAction)buttonToBackAction:(id)sender;
//帮助
- (IBAction)buttonToHelpAction:(id)sender;
//开始录制视频
- (IBAction)buttonToStartAction:(id)sender;
//更换前后置摄像头
- (IBAction)buttonToChangeCameraAction:(id)sender;
//重新录制
- (IBAction)buttonToRerecordAction:(id)sender;
//确认提交
- (IBAction)buttonToSureAction:(id)sender;


@end

NS_ASSUME_NONNULL_END
