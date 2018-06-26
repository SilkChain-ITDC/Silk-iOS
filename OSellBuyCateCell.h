//
//  OSellBuyCateCell.h
//  OSell
//
//  Created by wenchy on 2016/10/14.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//
typedef void(^kOSellBuyCateCellIsSelectBlock)(BOOL isSelect , NSString *hallProductID);//选中与取消
typedef void(^kOSellBuyCateCellProductCountBlock)(NSString *count , NSString *hallProductID);//商品数量
#import <UIKit/UIKit.h>
#import "OSellBuyCateModel.h"
@interface OSellBuyCateCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnChoose;
- (IBAction)btnChooseAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblProductName;
@property (weak, nonatomic) IBOutlet UILabel *lblProductSpec;
@property (weak, nonatomic) IBOutlet UILabel *lblProductMoney;

@property (weak, nonatomic) IBOutlet UILabel *lblRate;

@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgProductWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgProductHeight;


@property (weak, nonatomic) IBOutlet UIView *viewEdit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewEditWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewEditHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

- (IBAction)btnAddAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRed;
- (IBAction)btnRedAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (nonatomic, strong) OSellBuyCateModel *buyCatemodel;
- (void)showProductInfo:(OSellBuyCateModel *)model;

@property (nonatomic, strong)kOSellBuyCateCellIsSelectBlock kSelectBlock;

@property (nonatomic, strong)kOSellBuyCateCellProductCountBlock kCountBlock;
@end
