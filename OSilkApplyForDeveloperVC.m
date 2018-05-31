//
//  OSilkApplyForDeveloperVC.m
//  OSell
//
//  Created by xlg on 2018/5/30.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkApplyForDeveloperVC.h"

#import "OSilkApplyForDeveloperModel.h"

@interface OSilkApplyForDeveloperVC () <UITextFieldDelegate>
{
    UITextField *firstTF;
    OSilkApplyForDeveloperModel *applyModel;
}

@end

@implementation OSilkApplyForDeveloperVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"Details"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDatas];
    [self layoutViews];
    [self setBackButton];
}
//初始化数据
- (void)setupDatas {
    applyModel = [OSilkApplyForDeveloperModel new];
}
//设置UI
- (void)layoutViews {
    UIColor *borderColor = RGBCOLOR(220, 220, 220);
    [self.tfOne setupBorderColor:borderColor];
    [self.tfTwo setupBorderColor:borderColor];
    [self.tfThree setupBorderColor:borderColor];
    [self.tfFour setupBorderColor:borderColor];
    [self.tfFive setupBorderColor:borderColor];
    [self.tfSix setupBorderColor:borderColor];
    [self.tfSeven setupBorderColor:borderColor];
    [self.tfEight setupBorderColor:borderColor];
    [self.tfNine setupBorderColor:borderColor];
    [self.btnSubmit setupCornerRadius:22.0];
    [self adjustmentEmptyViewHeight];
}
//调整空视图的高度
- (void)adjustmentEmptyViewHeight {
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat offset = weakSelf.bGView.frame.size.height - weakSelf.emptyView.frame.origin.y;
        if (offset <= 0) {
            offset = 1;
        } else {
            offset = offset + 1;
        }
        weakSelf.emptyViewHeight.constant = offset;
    });
}

#pragma mark - 交互事件
//提交按钮事件
- (IBAction)buttonToSubmitAction:(UIButton *)sender {
    if (firstTF.isFirstResponder) {
        [firstTF resignFirstResponder];
    }
    //coding
    
}

#pragma mark - 协议
//UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    firstTF = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField.tag == 2001) {
        applyModel.strOne = textField.text;
    } else if (textField.tag == 2002) {
        applyModel.strTwo = textField.text;
    } else if (textField.tag == 2003) {
        applyModel.strThree = textField.text;
    } else if (textField.tag == 2004) {
        applyModel.strFour = textField.text;
    } else if (textField.tag == 2005) {
        applyModel.strFive = textField.text;
    } else if (textField.tag == 2006) {
        applyModel.strSix = textField.text;
    } else if (textField.tag == 2007) {
        applyModel.strSeven = textField.text;
    } else if (textField.tag == 2008) {
        applyModel.strEight = textField.text;
    } else if (textField.tag == 2009) {
        applyModel.strNine = textField.text;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


