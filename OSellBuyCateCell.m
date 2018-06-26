//
//  OSellBuyCateCell.m
//  OSell
//
//  Created by wenchy on 2016/10/14.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//

#import "OSellBuyCateCell.h"

@implementation OSellBuyCateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.viewEditWidth.constant = SCREEN_WIDTH/375 * 90;
    self.viewEditHeight.constant = SCREEN_WIDTH/375 * 33;
    self.imgProductWidth.constant = self.imgProductHeight.constant = SCREEN_WIDTH/375 * 90;
    [self.txtNumber setDelegate:self];
    [self layoutIfNeeded];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)showProductInfo:(OSellBuyCateModel *)model{
    self.buyCatemodel = model;
    [self.lblProductName setText:[NSString stringWithFormat:@"%@",model.ProductName]];
    [self.lblProductSpec setText:[NSString stringWithFormat:@"%@ %@",model.Size,model.Color]];
    [self.txtNumber setText:[NSString stringWithFormat:@"%@",model.Count]];
    NSString *price = [self getPriceWithPriceList:model.ProductPriceList andCount:[model.Count integerValue]];
    [self.lblProductMoney setText:[NSString stringWithFormat:@"%@ %@",model.Currency,price]];
//    [self.lblRate setText:[NSString stringWithFormat:@" (%@%@)",[InternationalizationHelper getText:@"OSellGoodsDetailsViewController_Vat:"],model.PricePercent]];
    if ([NSString isNullOrEmpty:model.PricePercent]||[model.PricePercent floatValue]<=0.00) {
        [self.lblRate setText: @""];
    }
    [self.imgProduct sd_setImageWithURL:[NSURL URLWithString:model.ProductImg]
                    placeholderImage:[UIImage imageNamed:@"showRoomGoodsIcon.png"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               if (error == nil) {
                                   self.imgProduct.backgroundColor = [UIColor whiteColor];
                               }
                           }];
    if (model.isSelect) [self.btnChoose setSelected:YES];
    else [self.btnChoose setSelected:NO];
    if ([model.Status integerValue] == 1) {
        [self.btnChoose setUserInteractionEnabled:YES];
        [self.btnChoose setHidden:NO];
    } else {
        [self.btnChoose setUserInteractionEnabled:NO];
        [self.btnChoose setHidden:YES];
    }
}
- (IBAction)btnChooseAction:(id)sender {
    if ([sender isSelected]) {
        //取消选中
        if (self.kSelectBlock) {
            self.kSelectBlock(NO , [NSString stringWithFormat:@"%@",self.buyCatemodel.ID]);
        }
    }else{
        //选中
        if (self.kSelectBlock) {
            self.kSelectBlock(YES , [NSString stringWithFormat:@"%@",self.buyCatemodel.ID]);
        }
    }
}
- (IBAction)btnAddAction:(id)sender {
    NSInteger number = [self.txtNumber.text integerValue];
 
    number += 1;

    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text , [NSString stringWithFormat:@"%@",self.buyCatemodel.ID]);
    }
}
- (IBAction)btnRedAction:(id)sender {
    NSInteger number = [self.txtNumber.text integerValue];
    if (number<=[self.buyCatemodel.MinNum integerValue]) {
        number = [self.buyCatemodel.MinNum integerValue];
    }else{
        number -= 1;
    }
    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text , [NSString stringWithFormat:@"%@",self.buyCatemodel.ID]);
    }
}
#pragma mark - textField代理
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger number = [textField.text integerValue];
    if (number<=[self.buyCatemodel.MinNum integerValue]) {
        number = [self.buyCatemodel.MinNum integerValue];
    }
    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text , [NSString stringWithFormat:@"%@",self.buyCatemodel.ID]);
    }
    
}


#pragma mark - 获取阶梯价
/**
 *  根据数量计算产品对应的价格
 *
 *  @param count 产品数量
 *
 *  @return 产品单价
 */
- (NSString *)getPriceWithPriceList:(NSArray *)arrPrice andCount:(NSInteger)count{
    NSString *ProductPrice = @"0.00";
    if ([self.buyCatemodel.MinPrice floatValue] == [self.buyCatemodel.MaxPrice floatValue]) {
        ProductPrice = self.buyCatemodel.ShowMinPrice ;
    }else{
        if (arrPrice && arrPrice.count>0) {
            for (NSDictionary *dic in arrPrice) {
                if ([dic objectForNotNullKey:@"MaxNum"]<[dic objectForNotNullKey:@"MinNum"]) {
                    if (count>=[[dic objectForNotNullKey:@"MinNum"] intValue]) {
                        ProductPrice = [NSString stringWithFormat:@"%@",[dic objectForNotNullKey:@"ShowPrice"]];
                    }
                }else{
                    if (count>=[[dic objectForNotNullKey:@"MinNum"] intValue]&&count<[[dic objectForNotNullKey:@"MaxNum"]intValue]) {
                        ProductPrice = [NSString stringWithFormat:@"%@",[dic objectForNotNullKey:@"ShowPrice"]];
                    }
                }
            }
        }else{
            ProductPrice = self.buyCatemodel.ShowMinPrice ;
        }
    }
    return ProductPrice;
}
@end
