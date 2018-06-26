//
//  OSellCywMakeSureOrderCell.m
//  OSell
//
//  Created by OSellResuming on 2017/6/5.
//  Copyright © 2017年 OSellResuming. All rights reserved.
//

#import "OSellCywMakeSureOrderCell.h"
#import "OSellBuyCateModel.h"

@implementation OSellCywMakeSureOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.txtNumber setDelegate:self];
    self.txtNumber.userInteractionEnabled = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showProductInfo:(OSellBuyCateModel *)model{
    
    self.buyCatemodel = model;
    
    [self.goodsNameLabel setText:[NSString stringWithFormat:@"%@",model.ProductName]];
    [self.goodsCateLabel setText:[NSString stringWithFormat:@"%@ %@",model.Size,model.Color]];
    [self.txtNumber setText:[NSString stringWithFormat:@"%@",model.Count]];
    NSString *price = [self getOnePriceWithPriceList:model.ProductPriceList andCount:[model.Count integerValue]];
    [self.unitsLable setText:[NSString stringWithFormat:@"%@ %@/%@",model.Currency,price,model.Unit]];
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:self.unitsLable.text];
    NSRange attriRange = [self.unitsLable.text rangeOfString:[NSString stringWithFormat:@"/"]];
    [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0XFD6300), NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}
                          range:NSMakeRange(0, attriRange.location)];
    self.unitsLable.attributedText = attriString;
    
//    [self.lblRate setText:[NSString stringWithFormat:@" (%@%@)",[InternationalizationHelper getText:@"OSellGoodsDetailsViewController_Vat:"],model.PricePercent]];
//    if ([NSString isNullOrEmpty:model.PricePercent]||[model.PricePercent floatValue]<=0) {
//        [self.lblRate setText: @""];
//    }
    
    [self.goodsImgView sd_setImageWithURL:[NSURL URLWithString:model.ProductImg]
                       placeholderImage:[UIImage imageNamed:@"showRoomGoodsIcon.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  if (error == nil) {
                                      self.goodsImgView.backgroundColor = [UIColor whiteColor];
                                  }
                              }];
}

- (IBAction)btnAddAction:(id)sender {
    NSInteger number = [self.txtNumber.text integerValue];
    
//    NSInteger maxNum = [self.buyCatemodel.Stock integerValue];
    
//    if (number < maxNum) {
        number += 1;
//    }
    
    
    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text, [self getPriceWithPriceList:self.buyCatemodel.ProductPriceList andCount:number]);
    }
}

- (IBAction)btnRedAction:(id)sender {
    NSInteger number = [self.txtNumber.text integerValue];
    
    NSInteger minNum = 10000000000;
    NSArray *priceArr = self.buyCatemodel.ProductPriceList;
    for (NSDictionary *priceDic in priceArr) {
        NSInteger minNum1 = [[priceDic objectForNotNullKey:@"MinNum"] integerValue];
        if (minNum1 < minNum) {
            minNum = minNum1;
        }
    }
    if (priceArr.count == 0) {
        minNum = 0;
    }
    
    if (number < minNum) {
        number = minNum;
    }else if (number == minNum){
        number = minNum;
    }else {
        number -= 1;
    }
    
    
    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text, [self getPriceWithPriceList:priceArr andCount:number]);
    }
}

#pragma mark - textField代理
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger number = [textField.text integerValue];
    
    NSInteger maxNum = 10000000000;
    NSInteger minNum = 10000000000;
    NSArray *priceArr = self.buyCatemodel.ProductPriceList;
    for (NSDictionary *priceDic in priceArr) {
        
        NSInteger minNum1 = [[priceDic objectForNotNullKey:@"MinNum"] integerValue];
        
        if (minNum1 < minNum) {
            minNum = minNum1;
        }
    }
    if (priceArr.count == 0) {
        minNum = 0;
    }
    
    if (number < minNum) {
        number = minNum;
    }else if (number >= minNum && number <= maxNum){
        number = number;
    }else {
        number = maxNum;
    }
    
    [self.txtNumber setText:[NSString stringWithFormat:@"%ld",(long)number]];
    if (self.kCountBlock) {
        self.kCountBlock(self.txtNumber.text, [self getPriceWithPriceList:priceArr andCount:number]);
    }
    
}

/**
 *  根据数量计算产品对应的价格
 *
 *  @param count 产品数量
 *
 *  @return 该规格总价
 */
- (NSString *)getPriceWithPriceList:(NSArray *)arrPrice andCount:(NSInteger)count{
    NSString *ProductPrice = @"0.00";
    
    for (int i = 0; i< arrPrice.count; i++) {
        
        NSDictionary *priceDic = [arrPrice objectAtNotNullIndex:i];
        
        NSInteger minNum1 = [[priceDic objectForNotNullKey:@"MinNum"] integerValue];
        NSInteger maxNum1 = [[priceDic objectForNotNullKey:@"MaxNum"] integerValue];
        if (maxNum1 == 0) {
            maxNum1 = 100000000000;
        }
        
        /*{
         MaxNum = 30;
         MinNum = 11;
         Price = "220.5054775031651";
         ShowPrice = "220.51";
         }*/
        if (count >= minNum1 && count <= maxNum1) {
            ProductPrice = [NSString stringWithFormat:@"%.2f", [[priceDic objectForNotNullKey:@"ShowPrice"] floatValue] * count];
        }else if (count < minNum1 && i == 0) {
            ProductPrice = [NSString stringWithFormat:@"%.2f", [[priceDic objectForNotNullKey:@"ShowPrice"] floatValue] * count];
        }
        
    }
    
    return ProductPrice;
}

/**
 *  根据数量计算产品对应的价格
 *
 *  @param count 产品数量
 *
 *  @return 该规单价
 */
- (NSString *)getOnePriceWithPriceList:(NSArray *)arrPrice andCount:(NSInteger)count{
    NSString *ProductPrice = @"0.00";
    
    for (int i = 0; i< arrPrice.count; i++) {
        
        NSDictionary *priceDic = [arrPrice objectAtNotNullIndex:i];
        
        NSInteger minNum1 = [[priceDic objectForNotNullKey:@"MinNum"] integerValue];
        NSInteger maxNum1 = [[priceDic objectForNotNullKey:@"MaxNum"] integerValue];
        if (maxNum1 == 0) {
            maxNum1 = 100000000000;
        }
        
        /*{
         MaxNum = 30;
         MinNum = 11;
         Price = "220.5054775031651";
         ShowPrice = "220.51";
         }*/
        if (count >= minNum1 && count <= maxNum1) {
            ProductPrice = [NSString stringWithFormat:@"%.2f", [[priceDic objectForNotNullKey:@"ShowPrice"] floatValue]];
        }else if (count < minNum1 && i == 0) {
            ProductPrice = [NSString stringWithFormat:@"%.2f", [[priceDic objectForNotNullKey:@"ShowPrice"] floatValue]];
        }
        
    }
    
    return ProductPrice;
}

- (UIViewController *)viewController
{
    //下一个响应者
    UIResponder *next=[self nextResponder];
    
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = [next nextResponder];
        
    } while (next!=nil);
    
    return nil;
}
@end
