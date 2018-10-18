//
//  SilkSetKYCViewController.h
//  OSell
//
//  Created by xlg on 2018/6/21.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "Base.h"

//KYC状态
typedef NS_ENUM(NSInteger, kKYCVerificationType) {
    Unverify  = 0, //未认证
    InVerify  = 1, //认证中
    Passed    = 2, //认证通过
    Failed    = 3, //认证失败
};

@interface SilkSetKYCViewController : Base

@property (weak, nonatomic) IBOutlet UIScrollView *bGView;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIButton *btnStatusTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusTips;

@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIButton *btnAmkCftTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAmkCftTips;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstNameT;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastNameT;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UILabel *lblNationalityT;
@property (weak, nonatomic) IBOutlet UITextField *tfNationality;
@property (weak, nonatomic) IBOutlet UILabel *lblIdenTypeT;
@property (weak, nonatomic) IBOutlet UITextField *tfIdenType;
@property (weak, nonatomic) IBOutlet UILabel *lblIdenNumberT;
@property (weak, nonatomic) IBOutlet UITextField *tfIdenNumber;
//证件正面
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UILabel *lblFrontSideTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnFront;
@property (weak, nonatomic) IBOutlet UILabel *lblFrontSideTips;
@property (weak, nonatomic) IBOutlet UIView *frontPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *lblClickToUpload1;
@property (weak, nonatomic) IBOutlet UIImageView *imgFrontSide;
@property (weak, nonatomic) IBOutlet UILabel *lblExample1;
@property (weak, nonatomic) IBOutlet UIView *exampleFrontView;
//背景ScrollView的Tag为3001
@property (weak, nonatomic) IBOutlet UIPageControl *frontPageControl;
//证件背面
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *lblBackSideTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblBackSideTips;
@property (weak, nonatomic) IBOutlet UIView *backPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *lblClickToUpload2;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackSide;
@property (weak, nonatomic) IBOutlet UILabel *lblExample2;
@property (weak, nonatomic) IBOutlet UIView *exampleBackView;
//背景ScrollView的Tag为3002
@property (weak, nonatomic) IBOutlet UIPageControl *backPageControl;
//手持证件照
@property (weak, nonatomic) IBOutlet UIView *selfieView;
@property (weak, nonatomic) IBOutlet UILabel *lblSelfieTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSelfie;
@property (weak, nonatomic) IBOutlet UILabel *lblSelfieTips;
@property (weak, nonatomic) IBOutlet UIView *selfiePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *lblClickToUpload3;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelfie;
@property (weak, nonatomic) IBOutlet UILabel *lblExample3;
@property (weak, nonatomic) IBOutlet UIView *exampleSelfieView;

//底部按钮
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

//国家列表
@property (weak, nonatomic) IBOutlet UITableView *tabCountry;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabCountryTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnStatusWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *frontPhotoBViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exampleFrontBViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backPhotoBViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exampleBackBViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfiePhotoBViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exampleSelfieBViewHeight;


//选择证件正面照片
- (IBAction)buttonToChooseFrontSidePhoto:(id)sender;
//选择证件背面照片
- (IBAction)buttonToChooseBackSidePhoto:(id)sender;
//选择手持证件照照片
- (IBAction)buttonToChooseSelfiePhoto:(id)sender;
//重设按钮事件
- (IBAction)buttonToRestAction:(id)sender;
//提交按钮事件
- (IBAction)buttonToSubmitAction:(id)sender;


@end


