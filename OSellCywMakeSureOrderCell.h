//
//  OSellCywMakeSureOrderCell.h
//  OSell
//
//  Created by OSellResuming on 2017/6/5.
//  Copyright © 2017年 OSellResuming. All rights reserved.
//

typedef void(^kOSellGoodsCateStockCellProductCountBlock)(NSString *count, NSString *cateAllPrice);//商品数量

#import <UIKit/UIKit.h>
@class OSellBuyCateModel;

@interface OSellCywMakeSureOrderCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)btnAddAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRed;
- (IBAction)btnRedAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;

@property (weak, nonatomic) IBOutlet UILabel *unitsLable;
@property (weak, nonatomic) IBOutlet UILabel *goodsCateLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgView;

- (void)showProductInfo:(OSellBuyCateModel *)model;

@property (strong, nonatomic) OSellBuyCateModel *buyCatemodel;

@property (nonatomic, strong) kOSellGoodsCateStockCellProductCountBlock kCountBlock;

@end
