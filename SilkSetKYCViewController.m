//
//  SilkSetKYCViewController.m
//  OSell
//
//  Created by xlg on 2018/6/21.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "SilkSetKYCViewController.h"

#import "NSString+Extension.h"
#import "UITextField+Extension.h"
#import "UIViewController+Extension.h"
#import "SilkSetKYCModel.h"
#import "SilkCountryModel.h"
#import "SilkUploadImagesModel.h"
#import "SilkPickerSelectView.h"

#import "SelectCountry.h"
#import "SilkApplyDSuccessVC.h"
#import "SilkRecordVideoViewController.h"

typedef NS_ENUM(int, kSelectPhotoType) {
    FrontSide = 0,
    BackSide  = 1,
    Selfie    = 2,
};

@interface SilkSetKYCViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, CountryDelegate>
{
    NSInteger countryIndex;//选中的国家对应的下标
    kSelectPhotoType selectType;//选择图片的类型 (正面、反面、手持)
    
    NSString *nationId;//选中的国家的ID
    NSMutableArray *arrCountry;//国家数组
    NSMutableDictionary *dictPhoto;//选择的证件照的图片
    
    SilkSetKYCModel *kycModel;//KYC信息
    kKYCVerificationType kycType;//KYC状态
}

@end

@implementation SilkSetKYCViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"SetKYC_Title"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
    [self requestGetKYCInfo];
}
//初始化数据
- (void)setupDatas {
    countryIndex = -1;
    selectType = FrontSide;
    kycModel = [SilkSetKYCModel new];
    arrCountry = [NSMutableArray array];
    dictPhoto = [NSMutableDictionary dictionary];
}
//设置UI
- (void)layoutViews {
    self.frontPageControl.numberOfPages = 2;
    self.backPageControl.numberOfPages = 2;
    
    [self.btnFront setupCornerRadius:20.0];
    [self.btnBack setupCornerRadius:20.0];
    [self.btnSelfie setupCornerRadius:20.0];
    [self.btnReset setupCornerRadius:22.0];
    [self.btnSubmit setupCornerRadius:22.0];
    
    [self.btnReset setupBorderColor:RGBCOLOR(36, 133, 201)];
    
    [self.tfFirstName setupSpaceView];
    [self.tfLastName setupSpaceView];
    [self.tfNationality setupSpaceView];
    [self.tfIdenType setupSpaceView];
    [self.tfIdenNumber setupSpaceView];
    
    [self.tfFirstName setupBorderColor:nil];
    [self.tfLastName setupBorderColor:nil];
    [self.tfNationality setupBorderColor:nil];
    [self.tfIdenType setupBorderColor:nil];
    [self.tfIdenNumber setupBorderColor:nil];
    
    [self.frontPhotoView setupDotBorderColor:nil];
    [self.backPhotoView setupDotBorderColor:nil];
    [self.selfiePhotoView setupDotBorderColor:nil];
    [self.exampleFrontView setupDotBorderColor:nil];
    [self.exampleBackView setupDotBorderColor:nil];
    [self.exampleSelfieView setupDotBorderColor:nil];
    
    CGFloat imgWidth = (SCREEN_WIDTH - 60) * 5.0 / 8.0;
    self.tabCountryTop.constant = SCREEN_HEIGHT;
    self.frontPhotoBViewHeight.constant = imgWidth;
    self.exampleFrontBViewHeight.constant = imgWidth;
    self.backPhotoBViewHeight.constant = imgWidth;
    self.exampleBackBViewHeight.constant = imgWidth;
    self.selfiePhotoBViewHeight.constant = imgWidth;
    self.exampleSelfieBViewHeight.constant = imgWidth;
    
    [self.btnStatusTitle setTitle:[self getString:@"SetKYC_Account"] forState:UIControlStateNormal];
    [self.btnAmkCftTitle setTitle:[self getString:@"SetKYC_AMLCFT"] forState:UIControlStateNormal];
    self.lblAmkCftTips.text = [self getString:@"SetKYC_AMLCFT_Desc"];
    self.lblFirstNameT.text = [self getString:@"SetKYC_FirstName"];
    self.lblLastNameT.text = [self getString:@"SetKYC_LastName"];
    self.lblNationalityT.text = [self getString:@"SetKYC_Nationality"];
    self.lblIdenTypeT.text = [self getString:@"SetKYC_IdenType"];
    self.lblIdenNumberT.text = [self getString:@"SetKYC_IdenNumber"];
    
    self.lblFrontSideTitle.text = [self getString:@"SetKYC_FrontTitle"];
    [self.btnFront setTitle:[self getString:@"SetKYC_ChooseFile"] forState:UIControlStateNormal];
    self.lblFrontSideTips.text = [self getString:@"SetKYC_FrontDesc"];
    self.lblClickToUpload1.text = [self getString:@"SetKYC_ClickToUpload"];
    self.lblExample1.text = [self getString:@"SetKYC_Example"];
    
    self.lblBackSideTitle.text = [self getString:@"SetKYC_BackTitle"];
    [self.btnBack setTitle:[self getString:@"SetKYC_ChooseFile"] forState:UIControlStateNormal];
    self.lblBackSideTips.text = [self getString:@"SetKYC_BackDesc"];
    self.lblClickToUpload2.text = [self getString:@"SetKYC_ClickToUpload"];
    self.lblExample2.text = [self getString:@"SetKYC_Example"];
    
    NSString *strSelfieDesc = [NSString stringWithFormat:@"%@\n%@\n%@", [self getString:@"SetKYC_SelfieDesc1"], [self getString:@"SetKYC_SelfieDesc2"], [self getString:@"SetKYC_SelfieDesc3"]];
    self.lblSelfieTitle.text = [self getString:@"SetKYC_SelfieTitle"];
    [self.btnSelfie setTitle:[self getString:@"SetKYC_ChooseFile"] forState:UIControlStateNormal];
    self.lblSelfieTips.text = strSelfieDesc;
    self.lblClickToUpload3.text = [self getString:@"SetKYC_ClickToUpload"];
    self.lblExample3.text = [self getString:@"SetKYC_Example"];
    
    [self.btnReset setTitle:[self getString:@"SetKYC_Reset"] forState:UIControlStateNormal];
    [self.btnSubmit setTitle:[self getString:@"SetKYC_Submit"] forState:UIControlStateNormal];
    [self setupVerificationStatus:Unverify];
}

//设置是否认证
- (void)setupVerificationStatus:(kKYCVerificationType)type {
    NSString *strStatus = [self getString:@"SetKYC_Status_Unverify"];
    UIImage *imgStatus = [UIImage imageNamed:@"kyc_status_unverified"];
    if (type == Unverify) {
        self.btnStatus.selected = NO;
        self.lblStatus.text = strStatus;
        self.lblStatusTips.text = [self getString:@"SetKYC_Status_Desc_Unverify"];
    } else if (type == InVerify) {
        strStatus = [self getString:@"SetKYC_Status_InVerify"];
        self.btnStatus.selected = NO;
        self.lblStatus.text = strStatus;
        self.lblStatusTips.text = [self getString:@"SetKYC_Status_Desc_InVerify"];
    } else if (type == Passed) {
        
        //coding
        self.statusView.hidden = NO;
        self.userInfoView.hidden = YES;
        self.frontView.hidden = YES;
        self.backView.hidden = YES;
        self.selfieView.hidden = YES;
        self.btnView.hidden = YES;
        self.bGView.scrollEnabled = NO;
        
        strStatus = [self getString:@"SetKYC_Status_Passed"];
        imgStatus = [UIImage imageNamed:@"kyc_status_verified"];
        self.btnStatus.selected = YES;
        self.lblStatus.text = strStatus;
        self.lblStatusTips.text = [self getString:@"SetKYC_Status_Desc_Passed"];
    } else if (type == Failed) {
        strStatus = [self getString:@"SetKYC_Status_Failed"];
        self.btnStatus.selected = NO;
        self.lblStatus.text = strStatus;
        NSString *failStatusTips = [NSString stringWithFormat:@"%@ : %@", [self getString:@"SetKYC_Status_Desc_Failed"], kycModel.AuthMessage];
        self.lblStatusTips.text = failStatusTips;
    }
    
    CGFloat width = ceil([strStatus getWidth:20 fontSize:12] + 50);
    [self.btnStatus setBackgroundImage:imgStatus forState:UIControlStateNormal];
    if (width > imgStatus.size.width) {
        UIImage *image = [imgStatus resizableImageWithCapInsets:UIEdgeInsetsMake(0, 60, 0, 70) resizingMode:UIImageResizingModeStretch];
        [self.btnStatus setBackgroundImage:image forState:UIControlStateNormal];
    } else if (width < imgStatus.size.width) {
        width = imgStatus.size.width;
    }
    self.btnStatusWidth.constant = width;
}

#pragma mark - 交互事件
//选择证件正面照片
- (IBAction)buttonToChooseFrontSidePhoto:(id)sender {
    selectType = FrontSide;
    [self actionSheetToChoosePhoto:@""];
}
//选择证件背面照片
- (IBAction)buttonToChooseBackSidePhoto:(id)sender {
    selectType = BackSide;
    [self actionSheetToChoosePhoto:@""];
}
//选择手持证件照照片
- (IBAction)buttonToChooseSelfiePhoto:(id)sender {
    //*
    selectType = Selfie;
    [self actionSheetToChoosePhoto:@""];
    /*/
    SilkRecordVideoViewController *vc = [SilkRecordVideoViewController new];
    vc.successBlock = ^(UIImage * _Nonnull image, NSURL * _Nonnull fileUrl) {
        
        
        
    };
    [self pushController:vc];
    //*/
}

//重设按钮事件
- (IBAction)buttonToRestAction:(id)sender {
    if (kycType == Unverify || kycType == Failed) {
        self.tfFirstName.text = nil;
        self.tfLastName.text = nil;
        self.tfNationality.text = nil;
        self.tfIdenType.text = nil;
        self.tfIdenNumber.text = nil;
        self.imgFrontSide.image = nil;
        self.imgBackSide.image = nil;
        self.imgSelfie.image = nil;
        
        kycModel.FirstName = @"";
        kycModel.LastName = @"";
        kycModel.Nationality = @"";
        kycModel.NationalityCode = @"";
        kycModel.IdentificationType = @"";
        kycModel.IdentificationNumber = @"";
        kycModel.imageFrontSide = nil;
        kycModel.imageBackSide = nil;
        kycModel.imageSelfie = nil;
        kycModel.PhotoFrontSide = @"";
        kycModel.PhotoBackSide = @"";
        kycModel.PhotoSelfie = @"";
    }
}
//提交按钮事件
- (IBAction)buttonToSubmitAction:(id)sender {
    if (kycModel.FirstName.length ==  0) {
        [self.tfFirstName becomeFirstResponder];
        return;
    }
    if (kycModel.LastName.length == 0) {
        [self.tfLastName becomeFirstResponder];
        return;
    }
    if (kycModel.Nationality.length == 0) {
        [self.tfNationality becomeFirstResponder];
        return;
    }
    if (kycModel.IdentificationType.length == 0) {
        [self.tfIdenType becomeFirstResponder];
        return;
    }
    if (kycModel.IdentificationNumber.length == 0) {
        [self.tfIdenNumber becomeFirstResponder];
        return;
    }
    if (!kycModel.imageFrontSide && kycModel.PhotoFrontSide.length < 4) {
        [self.bGView setContentOffset:CGPointMake(0, self.frontView.frame.origin.y) animated:YES];
        //[self makeToast:@"请先选择证件正面照片"];
        return;
    }
    if (!kycModel.imageBackSide && kycModel.PhotoBackSide.length < 4) {
        [self.bGView setContentOffset:CGPointMake(0, self.backView.frame.origin.y) animated:YES];
        //[self makeToast:@"请先选择证件背面照片"];
        return;
    }
    if (!kycModel.imageSelfie && kycModel.PhotoSelfie.length < 4) {
        [self.bGView setContentOffset:CGPointMake(0, self.selfieView.frame.origin.y) animated:YES];
        //[self makeToast:@"请先选择手持证件照片"];
        return;
    }
    if (kycType == Failed) {
        [[SDImageCache sharedImageCache] removeImageForKey:kycModel.PhotoFrontSide];
        [[SDImageCache sharedImageCache] removeImageForKey:kycModel.PhotoBackSide];
        [[SDImageCache sharedImageCache] removeImageForKey:kycModel.PhotoSelfie];
    }
    if (dictPhoto.count == 0 && (kycModel.PhotoFrontSide.length > 4 && kycModel.PhotoBackSide.length > 4 && kycModel.PhotoSelfie.length > 4)) {
        [self requestSetKYCInfo];
    } else {
        [self uploadKYCPhoto];
    }
}

- (void)uploadKYCPhoto {
    if (dictPhoto.count == 0) {
        return;
    }
    WS(weakSelf);
    __block NSString *aKey = dictPhoto.allKeys.firstObject;
    __block UIImage *image = [dictPhoto objectForKey:aKey];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:image];
    [SilkUploadImagesModel uploadImages:array block:^(BOOL success, NSError *error, NSArray *imageUrls) {
        
        if (success) {
            kSelectPhotoType type = aKey.intValue;
            if (type == FrontSide) {
                kycModel.PhotoFrontSide = imageUrls.firstObject;
            } else if (type == BackSide) {
                kycModel.PhotoBackSide = imageUrls.firstObject;
            } else if (type == Selfie) {
                kycModel.PhotoSelfie = imageUrls.firstObject;
            }
            [dictPhoto removeObjectForKey:aKey];
            [weakSelf downloadImageWithURLString:imageUrls.firstObject];
            if (dictPhoto.count == 0) {
                [weakSelf requestSetKYCInfo];
            } else {
                [weakSelf uploadKYCPhoto];
            }
        } else {
            [weakSelf makeToast:[weakSelf getString:@"Silk_Fail"]];
        }
        
    } withLoading:YES withType:@"1"];
}

- (void)downloadImageWithURLString:(NSString *)imageUrl {
    if ([imageUrl isKindOfClass:[NSString class]]) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
        } isRepeat:YES];
    }
}

//提示用户在相册中选、或直接拍照
- (void)actionSheetToChoosePhoto:(NSString *)message {
    WS(weakSelf);
    [self actionSheetWithTitle:nil message:message cancelTitle:[self getString:@"Cancel"] chiefTitle:[self getString:[self getString:@"SetKYC_TakePhoto"]] otherTitles:@[[self getString:[self getString:@"SetKYC_Album"]]] actionHandler:^(NSInteger actionIndex, NSString *actionTitle) {
        if (actionIndex == -1) {
            [weakSelf choosePhotoWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (actionIndex == 0) {
            [weakSelf choosePhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }];
}
//从相册或拍照
- (void)choosePhotoWithSourceType:(UIImagePickerControllerSourceType)type {
    if ([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = type;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - 网络请求
//网络请求获取KYC信息
- (void)requestGetKYCInfo {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Recharge/GetKYC", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:user.userId forKey:@"UserID"];
    
    [DZProgress show:[self getString:@"Silk_Loading"]];
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleKYCInfo:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf pushToLoginVC:NO];
    }];
}
//网络请求提交KYC认证
- (void)requestSetKYCInfo {
    WS(weakSelf);
    SilkLoginUserModel *user = [[SilkLoginUserHelper shareInstance] getCurUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"%@Recharge/SetKYC", [[SilkServerConfig shareInstance] addressForBaseAPI]];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[InternationalizationHelper getCurLanguage] forKey:@"Lan"];
    [param setObject:user.userId forKey:@"UserID"];
    [param setObject:kycModel.FirstName forKey:@"FirstName"];
    [param setObject:kycModel.LastName forKey:@"LastName"];
    [param setObject:kycModel.Nationality forKey:@"Nationality"];
    [param setObject:kycModel.NationalityCode forKey:@"NationalityCode"];
    [param setObject:kycModel.IdentificationType forKey:@"IdentificationType"];
    [param setObject:kycModel.IdentificationNumber forKey:@"IdentificationNumber"];
    [param setObject:kycModel.PhotoFrontSide forKey:@"PhotoFrontSide"];
    [param setObject:kycModel.PhotoBackSide forKey:@"PhotoBackSide"];
    [param setObject:kycModel.PhotoSelfie forKey:@"PhotoSelfie"];
    [param setObject:kycModel.PhotoSelfie forKey:@"AuthenticationVideo"];//coding
    
    [DZProgress show:[self getString:@"Silk_Loading"]];
    [[SilkHttpServerHelper shareInstance] requestHTTPDataWithAPI:apiUrl andHeader:nil andBody:param andSuccessBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        if (apiResult.apiCode == 0) {
            [weakSelf handleSetKYCInfo:apiResult.dataResult];
        } else {
            [weakSelf makeToast:apiResult.errorMsg];
        }
    } andFailBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf makeToast:apiResult.errorMsg];
    } andLoginBlock:^(SilkAPIResult *apiResult) {
        [DZProgress dismiss];
        [weakSelf pushToLoginVC:NO];
    }];
}

//网络返回KYC信息处理
- (void)handleKYCInfo:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *auditStatus = [dict stringForKey:@"Audit"];
    kycType = auditStatus.integerValue;//coding
    kycType = Unverify;
    NSDictionary *dictData = [dict objectForKey:@"KYCData"];
    if ([dictData isKindOfClass:[NSDictionary class]]) {
        [kycModel setupModelWithDict:dictData];
    }
    NSArray *countries = [dict objectForKey:@"CountryData"];
    if ([countries isKindOfClass:[NSArray class]]) {
        for (NSDictionary *country in countries) {
            SilkCountryModel *model = [SilkCountryModel modelWithDict:country];
            [arrCountry addObject:model];
        }
    }
    [self.tabCountry reloadData];
    
    self.btnFront.userInteractionEnabled = YES;
    self.btnFront.backgroundColor = RGBCOLOR(40, 130, 200);
    self.btnBack.userInteractionEnabled = YES;
    self.btnBack.backgroundColor = RGBCOLOR(40, 130, 200);
    self.btnSelfie.userInteractionEnabled = YES;
    self.btnSelfie.backgroundColor = RGBCOLOR(40, 130, 200);
    self.btnSubmit.userInteractionEnabled = YES;
    self.btnSubmit.backgroundColor = RGBCOLOR(40, 130, 200);
    self.btnReset.userInteractionEnabled = YES;
    self.btnReset.backgroundColor = [UIColor whiteColor];
    [self.btnReset setupBorderColor:RGBCOLOR(36, 133, 201)];
    [self.btnReset setTitleColor:RGBCOLOR(40, 130, 200) forState:UIControlStateNormal];
    if (kycType == InVerify || kycType == Passed) {
        self.btnFront.userInteractionEnabled = NO;
        self.btnFront.backgroundColor = [UIColor lightGrayColor];
        self.btnBack.userInteractionEnabled = NO;
        self.btnBack.backgroundColor = [UIColor lightGrayColor];
        self.btnSelfie.userInteractionEnabled = NO;
        self.btnSelfie.backgroundColor = [UIColor lightGrayColor];
        self.btnSubmit.userInteractionEnabled = NO;
        self.btnSubmit.backgroundColor = [UIColor lightGrayColor];
        self.btnReset.userInteractionEnabled = NO;
        self.btnReset.backgroundColor = [UIColor lightGrayColor];
        [self.btnReset setupBorderColor:[UIColor lightGrayColor]];
        [self.btnReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [self setupVerificationStatus:kycType];
    if (kycModel.FirstName.length > 0) {
        self.tfFirstName.text = kycModel.FirstName;
        self.tfLastName.text = kycModel.LastName;
        self.tfNationality.text = kycModel.Nationality;
        self.tfIdenType.text = kycModel.IdentificationType;
        self.tfIdenNumber.text = kycModel.IdentificationNumber;
        [self.imgFrontSide sd_setImageWithURL:[NSURL URLWithString:kycModel.PhotoFrontSide]];
        [self.imgBackSide sd_setImageWithURL:[NSURL URLWithString:kycModel.PhotoBackSide]];
        [self.imgSelfie sd_setImageWithURL:[NSURL URLWithString:kycModel.PhotoSelfie]];
    }
}
//提交成功
- (void)handleSetKYCInfo:(NSDictionary *)dict {
    WS(weakSelf);
    SilkApplyDSuccessVC *vc = [SilkApplyDSuccessVC new];
    vc.isSetKYCSuccess = YES;
    [self presentViewController:vc animated:YES completion:^{
        [weakSelf.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - 协议
//UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.width;
    if (scrollView.tag == 3001) {
        self.frontPageControl.currentPage = page;
    } else if (scrollView.tag == 3002) {
        self.backPageControl.currentPage = page;
    }
}

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrCountry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if (indexPath.row == countryIndex) {
        cell.textLabel.textColor = RGBCOLOR(40, 130, 200);
    } else {
        cell.textLabel.textColor = RGBCOLOR(51, 51, 51);
    }
    SilkCountryModel *country = [arrCountry objectAtIndex:indexPath.row];
    cell.textLabel.text = country.Name;
    
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (countryIndex != indexPath.row) {
        countryIndex = indexPath.row;
        SilkCountryModel *country = [arrCountry objectAtIndex:countryIndex];
        self.tfNationality.text = country.Name;
        kycModel.Nationality = country.Name;
        kycModel.NationalityCode = country.Code;
    }
    WS(weakSelf);
    self.tabCountryTop.constant = self.view.height;
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}


//UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    WS(weakSelf);
    if (textField == self.tfNationality) {
        //选择国家
        /*
        SelectCountry *vc = [[SelectCountry alloc] init];
        vc.index = nationId;
        vc.country = kycModel.NationalityCode;
        vc.delegate = self;
        [self pushController:vc];
        /*/
        if (arrCountry.count == 0) {
            [self requestGetKYCInfo];
        } else {
            self.tabCountryTop.constant = 0;
            [UIView animateWithDuration:0.5 animations:^{
                [weakSelf.view layoutIfNeeded];
            }];//*/
        }
        return NO;
    }
    if (textField == self.tfIdenType) {
        //选择证件类型
        NSArray *arrTypes = @[[self getString:@"SetKYC_ID_Card"], [self getString:@"SetKYC_Passport"], [self getString:@"SetKYC_Driving"]];
        [SilkPickerSelectView showWithDatas:arrTypes selectTitle:kycModel.IdentificationType selectBlock:^(NSInteger index, NSString *strTitle) {
            
            kycModel.IdentificationType = strTitle;
            weakSelf.tfIdenType.text = strTitle;
        }];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField == self.tfFirstName) {
        kycModel.FirstName = textField.text;
    } else if (textField == self.tfLastName) {
        kycModel.LastName = textField.text;
    } else if (textField == self.tfIdenNumber) {
        kycModel.IdentificationNumber = textField.text;
    }
}


//UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    WS(weakSelf);
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (selectType == FrontSide) {
            weakSelf.imgFrontSide.image = image;
            kycModel.imageFrontSide = image;
        } else if (selectType == BackSide) {
            weakSelf.imgBackSide.image = image;
            kycModel.imageBackSide = image;
        } else if (selectType == Selfie) {
            weakSelf.imgSelfie.image = image;
            kycModel.imageSelfie = image;
        }
        UIImage *upImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.8)];
        NSString *strKey = [NSString stringWithFormat:@"%d", selectType];
        [dictPhoto setObject:upImage forKey:strKey];
    }];
}


//CountryDelegate
- (void)setBackCountry:(int)countryid {
    nationId = [NSString stringWithFormat:@"%d", countryid];
}

- (void)selectedCountry:(NSDictionary *)dict {
    kycModel.NationalityCode = [dict stringForKey:@"code"];
    kycModel.Nationality = [dict stringForKey:@"country"];
    self.tfNationality.text = kycModel.Nationality;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


