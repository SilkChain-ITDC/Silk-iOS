//
//  OSellMakeSureOrderVC.m
//  OSell
//
//  Created by wenchy on 2016/10/18.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//

#import "OSellMakeSureOrderVC.h"
#import "OSellBuyCateCell.h"
#import "OSellGoodsDetailsViewController.h"
#import "OSellStoreViewController.h"
#import "OSellCywMakeSureOrderCell.h"
#import "OSellCywMakeSureOrderFooterView.h"
#import "OSellOrderStatusViewController.h"
#import "OSellInquiryAddressListViewController.h"
#import "OSellSelectUnitsVC.h"
#import "OSellPaySelectVC.h"
#import "OSellInquiryHelper.h"
#import "LPAlertView.h"
#import "OSellOpenWalletAgreementVC.h"
#import "OSellMyCouponsVC.h"
#import "OSellPurchaseSuccessVC.h"
#import "OSellShippingMethodVC.h"

@interface OSellMakeSureOrderVC ()
@property (strong, nonatomic) NSMutableArray *arrStores;//店铺列表
@property (strong, nonatomic) NSMutableArray *arrProducts;//分组以后的数据

@property (nonatomic, strong) UIView *tableViewHeaderView;
@property (nonatomic, strong) UILabel *addressNameLabel;
@property (nonatomic, strong) UILabel *addressDetailLabel;
@property (nonatomic, strong) UILabel *addressPhoneLabel;
@property (nonatomic, strong) NSMutableArray *arrAddressList; //用户地址
@property (nonatomic, strong) NSString *defaultAddressId; //地址id
@property (nonatomic, strong) NSString *defaultCountry; //Country

@property (nonatomic, strong) UILabel *shippingMethod;
@property (nonatomic, strong) UIImageView *iconImgView1;

@property (nonatomic, strong) NSMutableArray *wallArr;
@property (nonatomic, strong) NSString *Currency;
@property (nonatomic, strong) NSString *moneyNum;
@property (nonatomic, strong) NSString *storeName;
@property (nonatomic, strong) NSString *storeImgUrl;
@property (nonatomic, strong) NSString *otherUserId;

@property (nonatomic, assign) BOOL isHaveGiftCard;
@property (nonatomic, strong) NSDictionary *nowSelectGiftCardDic;

@property (nonatomic, strong) NSString *methodType; //1-邮寄 2-自提       默认邮寄
@property (nonatomic, assign) BOOL IsSupportTake; //1支持 0不支持
@property (nonatomic, strong) NSString *TakeAddress;


@end

@implementation OSellMakeSureOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnSubmit setTitle:[self getString:@"OSellMakeSureOrderVC_Checkout"] forState:0];
    [self.tableMain registerNib:[UINib nibWithNibName:@"OSellCywMakeSureOrderCell" bundle: [NSBundle mainBundle]] forCellReuseIdentifier:@"OSellCywMakeSureOrderCell"];
    [self setBackItem];
    
    [self showAllPrimaryCategories];
    [self getOrderAmounts];
    [self getIsSupportTakeByHallIDAction];
    
    if ([[OSellLoginUserHelper shareInstance] getCurUserInfo].isOpenedWallet) {
        
        [self getCurrencyAction];
        
    }
    
}

/*获取是否支持到店自提(/VersionBuyerOnePointTwo/GetIsSupportTakeByHallID)
 HallID(店铺ID):
 
 IsSupportTake(1支持 0不支持 ),TakeAddress自提地址
 {
 "IsSupportTake": 0,
 "TakeAddress": ""
 }
 */
- (void)getIsSupportTakeByHallIDAction {
    
    NSMutableDictionary *dicParams = [[NSMutableDictionary alloc] init];
    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:0];
    [dicParams setObject:model.HallID forKey:@"HallID"];
    
    NSString *address=[NSString stringWithFormat:@"%@VersionBuyerOnePointTwo/GetIsSupportTakeByHallID",[[OSellServerHelper shareInstance] addressForBaseAPI]];
    [DZProgress show:nil];
    
    [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dicParams andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        if (![apiResult.dataResult isKindOfClass:[NSDictionary class]]) return ;
        
        self.IsSupportTake = [[apiResult.dataResult objectForNotNullKey:@"IsSupportTake"] boolValue];
        self.TakeAddress = [apiResult.dataResult objectForNotNullKey:@"TakeAddress"];
        
        self.tableMain.tableHeaderView = self.tableViewHeaderView;
        [self.tableMain reloadData];
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        /// Token失败，需要重新登录
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [DZProgress dismiss];
            
            [[OSellLoginUserHelper shareInstance]cleanUserInfo];
            [[OSellLoginUserHelper shareInstance]cleanCompanyInfo];
            [[XmppHelper shareInstance] logout];
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
        });
    }];
        
}

- (void)getCurrencyAction {
    
    NSString *strUrl=[NSString stringWithFormat:@"%@/usercard/accountbalance/%@", [[OSellServerHelper shareInstance] addressForPaymentAPI], [[OSellLoginUserHelper shareInstance] getCurUserInfo].user_id_pay];
    
    [DZProgress show:nil];
    [[OSellHTTPHelper shareInstance]toGetDataWithRequestURL:strUrl andParams:nil andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        [self getPageInfoData];
        if(![apiResult.dataResult isKindOfClass:[NSArray class]]) return;
        
        [self.wallArr removeAllObjects];
        
        NSArray *arr = apiResult.dataResult;
        for (NSDictionary *dic in arr) {
            
            [self.wallArr addObject:dic];
        }
        
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
    }];
    
}

/**
 *  根据页码获取列表数据
 /UserCard/GetUserCardPackageList
 HallID(卖场ID)：
 UserID(用户ID)：
 Status(状态)：Status：0可用 1不可用
 PageIndex
 PageSize
 */
- (void)getPageInfoData
{
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"88", @"HallID",
                                      @"0", @"Status",
                                      [[OSellLoginUserHelper shareInstance] getCurUserInfo].userId, @"UserID",
                                      @"10", @"PageSize",
                                      @"1", @"PageIndex",
                                      [InternationalizationHelper getLocalizeion], @"lan", nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",[[OSellServerHelper shareInstance] addressForBaseAPI],@"UserCard/GetUserCardPackageList"];
    
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:url andParams:parameter andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        
        [DZProgress dismiss];
        /// 判断数据信息
        if (![apiResult.dataResult isKindOfClass:[NSArray class]]) {
            return;
        }
        NSArray *arr = apiResult.dataResult;
        self.isHaveGiftCard = arr.count;
        [self.tableMain reloadData];
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
        
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        
        /// Token失败，需要重新登录
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[OSellLoginUserHelper shareInstance] cleanUserInfo];
            [[OSellLoginUserHelper shareInstance] cleanCompanyInfo];
            [[XmppHelper shareInstance] logout];
            [[UIUtils instance] setRootVCWithLogin];
            
        });
        
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.title = [self getString:@"OSellBuyCateVC_Order Confirmation"];
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = NO;
    
    if ([OSellInquiryHelper shareInstance].isRefreshSuccess) {
        [self refreshAddressAction];
    }
    
}

/*
 10060030.获取购物车内的商品价格(OrderAbout/GetOrderAmounts)
 */
- (void)getOrderAmounts{
    NSString *address = @"";
    NSMutableDictionary *dicParams = [[NSMutableDictionary alloc] init];
    if (self.isDirectPurchase) {
        OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:0];
        [dicParams setObject:[[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey:@"UserID"];
        [dicParams setObject:[InternationalizationHelper getLocalizeion] forKey:@"lan"];
        [DZProgress show:[self getString:@"loading..."]];
        [dicParams setObject:model.HallProductID forKey:@"HallProductID"];
        [dicParams setObject:model.Count forKey:@"Count"];
        
        address=[NSString stringWithFormat:@"%@OrderAbout/GetHallProductAmounts",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dicParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            if (![apiResult.dataResult isKindOfClass:[NSDictionary class]]) return ;
            
            NSDictionary *dicData = [[NSDictionary alloc] initWithDictionary:apiResult.dataResult];
            for (int i=0; i<self.arrStores.count; i++) {
                OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
                if ([model.HallID longLongValue] == [[dicData objectForNotNullKey:@"HallID"] longLongValue]) {
                    model.IsHaveChannelShop = [[dicData objectForNotNullKey:@"IsHaveChannelShop"] boolValue];
                    model.FreightAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"FreightAmount"]];
                    model.OrderOriginalAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderOriginalAmount"]];
                    model.OrderRealAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderRealAmount"]];
                    model.OrderVATAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderVATAmount"]];
                    
                    [self.arrStores replaceObjectAtIndex:i withObject:model];
                }
                
                NSMutableArray *sectionArr = [self.arrProducts objectAtNotNullIndex:i];
                for (int j = 0; j < sectionArr.count; j++) {
                    OSellBuyCateModel *model = [sectionArr objectAtNotNullIndex:j];
                    
                    model.Unit = [NSString stringWithFormat:@"%@", [dicData objectForNotNullKey:@"Unit"] ];
                    
                    [sectionArr replaceObjectAtIndex:j withObject:model];
                }
                [self.arrProducts replaceObjectAtIndex:i withObject:sectionArr];
            }

            [self.tableMain reloadData];
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
            
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            /// Token失败，需要重新登录
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                
                [[OSellLoginUserHelper shareInstance]cleanUserInfo];
                [[OSellLoginUserHelper shareInstance]cleanCompanyInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
        }];

        
    }else{
        [dicParams setObject:[[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey:@"UserID"];
        
        [dicParams setObject:[InternationalizationHelper getLocalizeion] forKey:@"lan"];
        [DZProgress show:[self getString:@"loading..."]];
        NSMutableArray *arrOrderList = [[NSMutableArray alloc] init];
        for (OSellBuyCateModel *model in self.arrStores) {
            
            NSMutableArray *arrTrolleyList = [[NSMutableArray alloc] init];
            
            
            for (NSString *TrolleyID in model.TrolleyIDList) {
                NSMutableDictionary *dicTrolley = [[NSMutableDictionary alloc] init];
                [dicTrolley setObject:TrolleyID forKey:@"TrolleyID"];
                [arrTrolleyList addObject:dicTrolley];
            }
            
            NSMutableDictionary *dicHallInfo = [[NSMutableDictionary alloc] init];
            
            [dicHallInfo setObject:model.HallID forKey:@"HallID"];
            
            [dicHallInfo setObject:arrTrolleyList forKey:@"TrolleyList"];
            
            [arrOrderList addObject:dicHallInfo];
            
        }
        
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrOrderList options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *strOrderList = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dicParams setObject:strOrderList forKey:@"OrderList"];
        
        address=[NSString stringWithFormat:@"%@VersionsBuyerFive/GetAreadyOrderAmounts",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dicParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            if (![apiResult.dataResult isKindOfClass:[NSArray class]]) return ;
            
            NSArray *arrData = [[NSArray alloc] initWithArray:apiResult.dataResult];
            for (int k = 0; k < arrData.count; k++) {
                
                NSDictionary *dicData = [arrData objectAtNotNullIndex:k];
                
                for (int i=0; i<self.arrStores.count; i++) {
                    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
                    if ([model.HallID longLongValue] == [[dicData objectForNotNullKey:@"HallID"] longLongValue]) {
                        model.IsHaveChannelShop = [[dicData objectForNotNullKey:@"IsHaveChannelShop"] boolValue];
                        model.FreightAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"FreightAmount"]];
                        model.OrderOriginalAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderOriginalAmount"]];
                        model.OrderRealAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderRealAmount"]];
                        model.OrderVATAmount = [NSString stringWithFormat:@"%@",[dicData objectForNotNullKey:@"OrderVATAmount"]];
                        
                        
                        [self.arrStores replaceObjectAtIndex:i withObject:model];
                    }
                }
                
                NSMutableArray *sectionArr = [self.arrProducts objectAtNotNullIndex:k];
                for (int j = 0; j < sectionArr.count; j++) {
                    OSellBuyCateModel *model = [sectionArr objectAtNotNullIndex:j];
                    
                    model.Unit = [NSString stringWithFormat:@"%@",[[[dicData objectForNotNullKey:@"TrolleyList"] objectAtNotNullIndex:j] objectForNotNullKey:@"Unit"]];
                    
                    [sectionArr replaceObjectAtIndex:j withObject:model];
                }
                [self.arrProducts replaceObjectAtIndex:k withObject:sectionArr];
                
            }
            [self.tableMain reloadData];
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
            
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            /// Token失败，需要重新登录
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                
                [[OSellLoginUserHelper shareInstance]cleanUserInfo];
                [[OSellLoginUserHelper shareInstance]cleanCompanyInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
        }];

    }
    
}


#pragma mark - 根据SupplierId进行分组
- (void)showAllPrimaryCategories{
   
    
    
    NSMutableArray *arrDefaultCategoryID = [[NSMutableArray alloc] init];
    for (OSellBuyCateModel *model in self.arrSelectProducts) {
        [arrDefaultCategoryID addObject:model.SupplierName];
    }
    NSMutableArray *arrParentID = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [arrDefaultCategoryID count]; i++) {
        
        @autoreleasepool {
            
            if ([arrParentID containsObject:[arrDefaultCategoryID objectAtIndex:i]]== NO) {
                [arrParentID addObject:[arrDefaultCategoryID objectAtIndex:i]];
                OSellBuyCateModel *model = [self.arrSelectProducts objectAtIndex:i];
                model.SendWarehouse = @"";
                model.SendWarehouseId = @"";
                model.shipNameStr = @"";
                model.shipMoneyStr = @"";
                model.shipOneMoney = @"";
                model.shipIdStr = @"";
                
                [self.arrStores addObject:model];
                [self calculateTheNumberOfProductByHallID:model];
            }
            
        }
        
    }
    arrParentID  = nil;
  
    for (int i = 0; i<self.arrStores.count; i++) {
        NSMutableArray *arrProductID = [[NSMutableArray alloc] init];
        OSellBuyCateModel *storeModel = [self.arrStores objectAtNotNullIndex:i];
        for (int x=0; x<self.arrSelectProducts.count; x++) {
            OSellBuyCateModel *productModel = [self.arrSelectProducts objectAtNotNullIndex:x];
            if ([[NSString stringWithFormat:@"%@",storeModel.SupplierId] isEqualToString:[NSString stringWithFormat:@"%@",productModel.SupplierId]]) {
                [arrProductID addObject:productModel.ID];
            }
        }
        storeModel.TrolleyIDList = arrProductID;
        [self.arrStores replaceObjectAtIndex:i withObject:storeModel];
        self.Currency = storeModel.CurrencyName;
        arrProductID = nil;
    }
    
    [self refreshAddressAction];
    
}

- (void)refreshAddressAction {
    
    
    NSString *url = [ServiceHelper getOrderServiceWith:@"OrderAbout/GetShippingAddressList"];
    NSMutableDictionary *dicParmam = [[NSMutableDictionary alloc] init];
    [dicParmam setObject:[[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey:@"UserID"];
    [dicParmam setObject:[InternationalizationHelper getLocalizeion] forKey:@"lan"];
    
    [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:url andParams:dicParmam andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        if(![apiResult.dataResult isKindOfClass:[NSArray class]]) return;
        
        
        self.arrAddressList = [[NSMutableArray alloc] initWithArray:apiResult.dataResult];
        /*{
         Address = "\U6c99\U576a\U575d";
         AddressID = "c9907c74-4046-4941-8169-5077dfc66b99";
         City = "";
         Country = Russia;
         CountryCode = RU;
         IsDefault = 1;
         Name = "\U848b\U6210\U78ca";
         Phone = 13654625841;
         PostCode = 400021;
         State = "";
         UserID = 0;
         }*/
            
        for (NSDictionary *dic in self.arrAddressList) {
            
            if ([[dic objectForNotNullKey:@"IsDefault"] boolValue]) {
                
                if (_addressNameLabel) {
                    self.addressDetailLabel.text = [dic objectForNotNullKey:@"Address"];
                    self.addressPhoneLabel.text = [dic objectForNotNullKey:@"Phone"];
                    self.addressNameLabel.text = [dic objectForNotNullKey:@"Name"];
                    
                }
                
                self.defaultAddressId = [dic objectForNotNullKey:@"AddressID"];
                self.defaultCountry = [dic objectForNotNullKey:@"Country"];
                [OSellInquiryHelper shareInstance].defaultAddressId = self.defaultAddressId;
                
                [self cleanShipInfoData];
            }
        }
        
        
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        
    }];
    
}

#pragma mark - 根据店铺的ID查询该店铺的商品
- (void)calculateTheNumberOfProductByHallID:(OSellBuyCateModel *)buyCateModel{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (OSellBuyCateModel *model in self.arrSelectProducts) {
        if ([[NSString stringWithFormat:@"%@",model.SupplierId] isEqualToString: [NSString stringWithFormat:@"%@",buyCateModel.SupplierId]]) {
            
            NSArray *priceArr = model.ProductPriceList;
            model.allPrice = [self getPriceWithPriceList:priceArr andCount:[model.Count integerValue]];
            [arr addObject:model];
        }
    }
    [self.arrProducts addObject:arr];
    
    [self calculateTotalPrice];
}

#pragma mark - 计算所选商品总价
- (void)calculateTotalPrice{
    
    [self.lblMoneyValue setText:[NSString stringWithFormat:@"%@:0.00", [self getString:@"OSellMakeSureOrderVC_Grand Total"]]];

    float allPrice = 0.0f;
    NSString *Currency = @"";
    float shipPrice = 0.0f;
    for (int x = 0 ; x < self.arrStores.count; x++) {
        
        NSMutableArray *goodsArr = [self.arrProducts objectAtNotNullIndex:x];
        
        for (OSellBuyCateModel *model in goodsArr) {
            allPrice = allPrice + [model.allPrice floatValue];
            Currency = model.Currency;
        }
        
        OSellBuyCateModel *sectionModel = [goodsArr objectAtNotNullIndex:0];
        shipPrice = shipPrice + [sectionModel.shipOneMoney floatValue];
        
    }
    [self.lblMoneyValue setText:[NSString stringWithFormat:@"%@:%@%.2f", [self getString:@"OSellMakeSureOrderVC_Grand Total"], Currency, allPrice+shipPrice]];

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
    
    for (int i = 0; i < arrPrice.count; i++) {
        
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
        }else if (i == 0 && count < minNum1) {
            ProductPrice = [NSString stringWithFormat:@"%.2f", [[priceDic objectForNotNullKey:@"ShowPrice"] floatValue] * count];
        }
        
    }
    
    return ProductPrice;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.arrStores.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *arr = [self.arrProducts objectAtNotNullIndex:section];
    return arr.count;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *lblGroup = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, view.width-45, 40)];
    [lblGroup setFont:[UIFont systemFontOfSize:14.0f]];
    [lblGroup setTextColor:UIColorFromRGB(0x333333)];
    
    UIButton *btnLookToStore = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, view.width-30, view.height)];
    btnLookToStore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnLookToStore addTarget:self action:@selector(btnLookIntoStore:) forControlEvents:UIControlEventTouchUpInside];
    [btnLookToStore setTitleColor:UIColorFromRGB(0x007AFF) forState:0];
    [btnLookToStore.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btnLookToStore setTag:section];
    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:section];
    
    [lblGroup setText:[NSString stringWithFormat:@"%@",model.SupplierName]];
    [btnLookToStore setTitle:@"" forState:0];
    [btnLookToStore setTitleColor:UIColorFromRGB(0XFD6300) forState:0];
    btnLookToStore.titleLabel.font = [UIFont systemFontOfSize:12.0f];

    [view addSubview:lblGroup];
    [view addSubview:btnLookToStore];
    
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    OSellCywMakeSureOrderFooterView *view = [[NSBundle mainBundle] loadNibNamed:
                                      @"OSellCywMakeSureOrderFooterView" owner:nil options:nil ].lastObject;
    view.defaultCountry = self.defaultCountry;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [view refreshViewWithData:[self.arrStores objectAtNotNullIndex:section]];
        
        if ([self.methodType isEqualToString:@"1"]) {
            
            view.shippingMoneyLabel.hidden = NO;
            view.shippingOnePriceLabel.hidden = NO;
            view.shippingBtn.hidden = NO;
            view.shippingTitle.hidden = NO;
            view.shippingGoImgView.hidden = NO;
            view.buyerMessageTopConstraint.constant = 52;
            
        }else {
            
            view.shippingMoneyLabel.hidden = YES;
            view.shippingOnePriceLabel.hidden = YES;
            view.shippingBtn.hidden = YES;
            view.shippingTitle.hidden = YES;
            view.shippingGoImgView.hidden = YES;
            view.buyerMessageTopConstraint.constant = 7;
        }
        
        NSMutableArray *arr = [self.arrProducts objectAtNotNullIndex:section];
        float allPrice = 0.0f;
        NSInteger allCount = 0;
        NSString *Currency = @"";
        for (OSellBuyCateModel *model in arr) {
            allPrice = allPrice + [model.allPrice floatValue];
            Currency = model.Currency;
            allCount = allCount + [model.Count integerValue];
        }
        
        OSellBuyCateModel *sectionModel = [self.arrStores objectAtNotNullIndex:section];
        view.orderSubTotalLabel.text = [NSString stringWithFormat:@"%@%.2f", Currency, allPrice];
        
        view.grandTotalLabel.text = [NSString stringWithFormat:@"%@%.2f", Currency, allPrice+[sectionModel.shipOneMoney floatValue]];
        view.goodsTotalNumLabel.text = [NSString stringWithFormat:@"%zi%@", allCount, allCount > 1 ? [self getString:@"OSellMakeSureOrderVC_items"] :[self getString:@"OSellMakeSureOrderVC_item"]];
        
        view.shippingMoneyShowLabel.text = sectionModel.shipMoneyStr;
        view.shippingMoneyLabel.text = sectionModel.shipNameStr;
        view.shippingOnePriceLabel.text = sectionModel.shipMoneyStr;
        
        self.Currency = sectionModel.CurrencyName;
        self.storeName = sectionModel.HallName;
        self.otherUserId = sectionModel.SupplierId;
        self.moneyNum = [NSString stringWithFormat:@"%.2f", allPrice+[sectionModel.shipOneMoney floatValue]];
        [self.lblMoneyValue setText:[NSString stringWithFormat:@"%@:%@%@", [self getString:@"OSellMakeSureOrderVC_Grand Total"], Currency, self.moneyNum]];
        self.storeImgUrl = @"";
        
        view.giftCardView.hidden = !self.isHaveGiftCard;
        view.topLineTopConstraint.constant = self.isHaveGiftCard ? 60.0f : 0.0f;
        
        if (self.nowSelectGiftCardDic.allKeys.count) {
            
            view.giftCardNumLabel.text = [NSString stringWithFormat:@"Gift Card available: %.2f %@", [[self.nowSelectGiftCardDic objectForNotNullKey:@"Amount"] floatValue], [self.nowSelectGiftCardDic objectForNotNullKey:@"Currency"]];
            
        }else {
            view.giftCardNumLabel.text = @"Gift Card available:";
            
        }
        
    });

    view.kNoteBlock = ^(NSString *note){
        
        [self newNoteWithModel:[self.arrStores objectAtNotNullIndex:section] andSection:section andNote:note];
    };
    
    view.kGiftCardBlock = ^{
        
        //选择礼品卡
        OSellMyCouponsVC *vc = [[OSellMyCouponsVC alloc] init];
        vc.isFromSelectCard = YES;
        vc.selectDataDic = self.nowSelectGiftCardDic;
        vc.curreny = self.Currency;
        vc.block = ^(NSDictionary *theDic) {
            
            self.nowSelectGiftCardDic = theDic;
            [self.tableMain reloadData];
            
            
        };
        [self pushController:vc];
        
    };
    
    view.kShippingBlock = ^{
        
        [self chooseShipWithModel:[self.arrStores objectAtNotNullIndex:section] andSection:section];
        
    };
    
    return view;
}

#pragma mark - 选择Ship
- (void)chooseShipWithModel:(OSellBuyCateModel *)theModel andSection:(NSInteger)section{
    
    /*1015000050.BuyNow运费模板根据产品和地址返回邮费列表(VersionsBuyerFive/getShippingMethodByAdressAndProduct)
     UserID:用户ID
     AddressID:地址ID
     HallID:大卖场ID
     StoreID:仓库ID
     ListProduct:[{"HallProductID": 32,"Count": 100 },{"HallProductID": 37, "Count": 100} ]选品及数量
     语言(lan):*/
    
    OSellSelectUnitsVC *selectUnitsVC = [[OSellSelectUnitsVC alloc] init];
    selectUnitsVC.unitsType = @"Ship";
    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:section];
    selectUnitsVC.Currency = model.CurrencyName;
    selectUnitsVC.defaultAddressId = self.defaultAddressId;
    selectUnitsVC.StoreID = theModel.SendWarehouseId;
    selectUnitsVC.hallID = theModel.HallID;
    
    NSMutableArray *allArr = [[NSMutableArray alloc] init];
    NSMutableArray *arr = [self.arrProducts objectAtNotNullIndex:section];
    for (OSellBuyCateModel *model in arr) {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:[NSString stringWithFormat:@"%@",model.HallProductID] forKey:@"HallProductID"];
        [dic setObject:[NSString stringWithFormat:@"%@",model.Count] forKey:@"Count"];
        
        [allArr addObject:dic];
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allArr options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *strOrderList = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    selectUnitsVC.strListProduct = strOrderList;
    
    selectUnitsVC.selectUnitsCywRefreshBlock = ^(NSDictionary *selectDic, BOOL isChange){
        
        theModel.shipNameStr = [NSString stringWithFormat:@"%@", [selectDic objectForNotNullKey:@"ShippingMethodName"]];
        theModel.shipMoneyStr = [NSString stringWithFormat:@"%@ %.2f", [selectDic objectForNotNullKey:@"CurrencyName"] ,[[selectDic objectForNotNullKey:@"ShippingMethodPrice"] floatValue]];
        theModel.shipOneMoney = [NSString stringWithFormat:@"%@", [selectDic objectForNotNullKey:@"ShippingMethodPrice"]];
        theModel.shipIdStr = [NSString stringWithFormat:@"%@", [selectDic objectForNotNullKey:@"ShippingMethodID"]];
        
        [self.arrStores replaceObjectAtIndex:section withObject:theModel];
        
        [self.tableMain reloadData];
    };
    [self pushController:selectUnitsVC];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OSellCywMakeSureOrderCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSellCywMakeSureOrderCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSMutableArray *arr = [self.arrProducts objectAtNotNullIndex:indexPath.section];
    OSellBuyCateModel *model = [arr objectAtNotNullIndex:indexPath.row];
    [cell showProductInfo:model];
//    if (self.isDirectPurchase) { //直接购买 能修改商品数量
        cell.btnAdd.userInteractionEnabled = YES;
        cell.btnRed.userInteractionEnabled = YES;
        cell.txtNumber.userInteractionEnabled = YES;
//    }else{
//        cell.btnAdd.userInteractionEnabled = NO;
//        cell.btnRed.userInteractionEnabled = NO;
//        cell.txtNumber.userInteractionEnabled = NO;
//    }
    __weak __typeof(self) weakSelf = self;
    cell.kCountBlock = ^(NSString *count, NSString *cateAllPrice){
        
        model.Count = count;
        model.allPrice = cateAllPrice;
        [arr replaceObjectAtIndex:indexPath.row withObject:model];
        [weakSelf.arrProducts replaceObjectAtIndex:indexPath.section withObject:arr];
        
        [weakSelf.tableMain reloadData];
        [weakSelf calculateTotalPrice];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    OSellBuyCateModel *model ;
    NSArray *arr = [self.arrProducts objectAtNotNullIndex:indexPath.section];

    model = [arr objectAtNotNullIndex:indexPath.row];
   
    NSString *productID = [NSString stringWithFormat:@"%@",model.HallProductID];
    OSellGoodsDetailsViewController *vc = [[OSellGoodsDetailsViewController alloc]init];
    
    vc.strProductID =[NSString stringWithFormat:@"%@",productID];
    [self pushController:vc];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 40;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    float height = self.isHaveGiftCard ? 357.0f-32.0f+40 : 357.0f-92.0f+40;
    height = [self.methodType isEqualToString:@"1"] ? height : height - 45;
    return height;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 157.0f;
    
}

#pragma mark - 查看店铺信息
- (void)btnLookIntoStore:(UIButton *)sender {
  
    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:sender.tag];
    OSellStoreViewController *vc = [[OSellStoreViewController alloc] init];
    vc.HallID = [NSString stringWithFormat:@"%@",model.HallID];
    [self pushController:vc];

}

#pragma mark - 提交订单
- (IBAction)btnSubmitAction:(id)sender {
    
    if (self.defaultAddressId.length == 0 && [self.methodType isEqualToString:@"1"]) { //没有填写地址
        [self makeToast:[self getString:@"OSellBuyCateVC_Full Address"]];
        return;
    }
    
    if (self.isDirectPurchase) {
        /*
         1015000029.BuyNow直接生成订单(VersionsBuyerFive/CreateBuyNowOrder)
         UserID:
         AddressID:收货地址ID
         StoreID:仓库ID
         Note:备注
         HallProductID：选品ID
         ShippingMethodID:物流方式ID
         Content: [{"StockSpuID": 460766,"Count": 100 },{"StockSpuID": 460767, "Count": 100} ] [{"StockSpuID": 0,"Count": 100 }]
         语言(lan):
         */
        
        
        NSMutableArray *contentArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.arrProducts.count; i++) {
            
            NSArray *arr = [self.arrProducts objectAtNotNullIndex:i];
            for (int j = 0; j < arr.count; j++) {
                
                NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
                OSellBuyCateModel *model = [arr objectAtNotNullIndex:j];
                [contentDic setObject:model.StoreID forKey:@"StockSpuID"];
                [contentDic setObject:model.Count forKey:@"Count"];
                [contentArr addObject:contentDic];
            }
            
        }
        
        OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:0];
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:contentArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *contentString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        
        NSString *Note = [NSString isNullOrEmpty:model.Note]?@"":model.Note;
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          
                                          [[OSellLoginUserHelper shareInstance] getCurUserInfo].userId, @"UserID",
                                          self.defaultAddressId, @"AddressID",
                                          @"0", @"StoreID",
                                          Note, @"Note",
                                          [NSString stringWithFormat:@"%@",model.HallProductID], @"HallProductID",
                                          model.shipIdStr, @"ShippingMethodID",
                                          contentString, @"Content",
                                          self.methodType, @"OrderGetType", //1快递 2自提
                                          [InternationalizationHelper getLocalizeion], @"lan", nil];
        
        
        NSString *address=[NSString stringWithFormat:@"%@VersionsBuyerFive/CreateBuyNowOrder",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [DZProgress show:[self getString:@"loading..."]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:parameter andSuccessBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            
            NSString *orderIdStr = apiResult.dataResult;
            
            [self gotoPayActionWithOrderID:orderIdStr];
            
            /*
            OSellPaySelectVC *paySelectVC = [[OSellPaySelectVC alloc] init];
            paySelectVC.OrderIDs = orderIdStr;
            [self pushController:paySelectVC];
            
            OSellOrderStatusViewController *myOrderVC = [[OSellOrderStatusViewController alloc] init];
            myOrderVC.selectItem = @"0";
            [self pushController:myOrderVC];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"mySendLocalMessage" object:nil];
             */
            
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[OSellLoginUserHelper shareInstance] cleanUserInfo];
                [[OSellLoginUserHelper shareInstance] cleanCompanyInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];

    }else if (self.isFromReplenishment) { //来自快速补货
        
        /*{
         [
             {
             "AddressID": "34198c66-1b6a-4f42-b2e6-8c55e6f6fc97",
             "TrolleyIDList": [ "bfb01572-0de2-4ccb-bbbf-17c0cd0b759d" ], 
             "Note": "", 
             "HallID": "2", 
             "SupplierID":142, 
             "ShippingMethodID":1, 
             "StoreID":1, 
             }, 
         
             { "AddressID": "34198c66-1b6a-4f42-b2e6-8c55e6f6fc97", "TrolleyIDList": [ "bfb01572-0de2-4ccb-bbbf-17c0cd0b759d" ], "Note": "", "HallID": "2", "SupplierID":10, "ShippingMethodID":1, "StoreID":1, } ]*/
        
        NSMutableArray *allArr = [[NSMutableArray alloc] init];
        for (OSellBuyCateModel *model in self.arrStores) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
            [dic setObject:self.defaultAddressId forKey:@"AddressID"];
            [dic setObject:model.TrolleyIDList forKey:@"TrolleyIDList"];
            NSString *Note = [NSString isNullOrEmpty:model.Note]?@"":model.Note;
            [dic setObject:Note forKey:@"Note"];
            [dic setObject:self.methodType forKey:@"OrderGetType"]; //1快递 2自提
            [dic setObject:[NSString stringWithFormat:@"%@",model.HallID] forKey:@"HallID"];
            [dic setObject:[NSString stringWithFormat:@"%@",model.SupplierId] forKey:@"SupplierID"];
            [dic setObject:[NSString stringWithFormat:@"%@",model.shipIdStr] forKey:@"ShippingMethodID"];
            [dic setObject:[NSString stringWithFormat:@"%@",@"0"] forKey:@"StoreID"];
            
            [allArr addObject:dic];
        }
        
        
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allArr options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *strOrderList = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
        
        [dictParams setValue: [[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
        [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
        [dictParams setValue: strOrderList forKey: @"Content"];
        
        NSString *address=[NSString stringWithFormat:@"%@VersionsBuyerFive/CreateSunOrderByTrolley",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [DZProgress show:[self getString:@"loading..."]];
        
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            
            if (![apiResult.dataResult isKindOfClass:[NSArray class]]) return ;
            NSArray *orderIdArr = apiResult.dataResult;
            NSString *orderIdStr = [orderIdArr componentsJoinedByString:@","];
            
            [self gotoPayActionWithOrderID:orderIdStr];
            /*
            OSellPaySelectVC *paySelectVC = [[OSellPaySelectVC alloc] init];
            paySelectVC.OrderIDs = orderIdStr;
            [self pushController:paySelectVC];
            
            //            [self makeToast:[self getString:@"购买成功"]];
            OSellOrderStatusViewController *myOrderVC = [[OSellOrderStatusViewController alloc] init];
            myOrderVC.selectItem = @"0";
            [self pushController:myOrderVC];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"mySendLocalMessage" object:nil];
             */
            
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[OSellLoginUserHelper shareInstance] cleanUserInfo];
                [[OSellLoginUserHelper shareInstance] cleanCompanyInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];
        
    }else{ //购物车
        
        /*1015000030.根据进货单创建订单(VersionsBuyerFive/CreateBuyNowOrderByTrolley)
         UserID:
         Content: 
             [
             { 
             "AddressID": "34198c66-1b6a-4f42-b2e6-8c55e6f6fc97",
             "TrolleyIDList": [ "bfb01572-0de2-4ccb-bbbf-17c0cd0b759d" ], 
             "Note": "", 
             "HallID": "2", 
             "SupplierID":142, 
             "ShippingMethodID":1, 
             "StoreID":1, },
             
             { "AddressID": "34198c66-1b6a-4f42-b2e6-8c55e6f6fc97", "TrolleyIDList": [ "bfb01572-0de2-4ccb-bbbf-17c0cd0b759d" ], "Note": "", "HallID": "2", "SupplierID":10, "ShippingMethodID":1, "StoreID":1, } ]
         语言(lan):*/
        NSMutableArray *allArr = [[NSMutableArray alloc] init];
        for (OSellBuyCateModel *model in self.arrStores) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
            [dic setObject:self.defaultAddressId forKey:@"AddressID"];
            [dic setObject:model.TrolleyIDList forKey:@"TrolleyIDList"];
            NSString *Note = [NSString isNullOrEmpty:model.Note]?@"":model.Note;
            [dic setObject:Note forKey:@"Note"];
            [dic setObject:self.methodType forKey:@"OrderGetType"]; //1快递 2自提
            [dic setObject:[NSString stringWithFormat:@"%@",model.HallID] forKey:@"HallID"];
            [dic setObject:[NSString stringWithFormat:@"%@",model.SupplierId] forKey:@"SupplierID"];
            [dic setObject:[NSString stringWithFormat:@"%@",model.shipIdStr] forKey:@"ShippingMethodID"];
            [dic setObject:[NSString stringWithFormat:@"%@",@"0"] forKey:@"StoreID"];
            
            [allArr addObject:dic];
        }
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allArr options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *strOrderList = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
        [dictParams setValue: [[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
        [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
        [dictParams setValue: strOrderList forKey: @"Content"];
        
        NSString *address=[NSString stringWithFormat:@"%@VersionsBuyerFive/CreateBuyNowOrderByTrolley",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        
        [DZProgress show:[self getString:@"loading..."]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            
            if (![apiResult.dataResult isKindOfClass:[NSArray class]]) return ;
            [[AppDelegate shareInstance].arrSelectProducts removeAllObjects];
            
            NSArray *orderIdArr = apiResult.dataResult;
            NSString *orderIdStr = [orderIdArr componentsJoinedByString:@","];
            
            [self gotoPayActionWithOrderID:orderIdStr];
            
            /*
            OSellPaySelectVC *paySelectVC = [[OSellPaySelectVC alloc] init];
            paySelectVC.OrderIDs = orderIdStr;
            [self pushController:paySelectVC];*/
            
            
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[OSellLoginUserHelper shareInstance] cleanUserInfo];
                [[OSellLoginUserHelper shareInstance] cleanCompanyInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];

    }
    
}

- (void)gotoPayActionWithOrderID:(NSString *)theOrderID {
    
    if ([[OSellLoginUserHelper shareInstance] getCurUserInfo].isOpenedWallet) {
        
        [self getCardListActionWithOrderID:theOrderID];
        
    } else {
        [DZProgress dismiss];
        //开通钱包
        OSellOpenWalletAgreementVC *vc = [OSellOpenWalletAgreementVC new];
        [self pushController:vc];
    }
    
    
}

- (void)getCardListActionWithOrderID:(NSString *)theOrderID {
    
    NSString *strUrl=[NSString stringWithFormat:@"%@/usercard/usercards/%@", [[OSellServerHelper shareInstance] addressForPaymentAPI], [[OSellLoginUserHelper shareInstance] getCurUserInfo].user_id_pay];
    
    [[OSellHTTPHelper shareInstance]toGetDataWithRequestURL:strUrl andParams:nil andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
//        if(![apiResult.dataResult isKindOfClass:[NSArray class]]) return;
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        
        OSellPayMentModel *model = [[OSellPayMentModel alloc] init];
        model.isCardPay = NO;
        
        NSArray *arr = apiResult.dataResult;
        NSMutableArray *cardArr = [[NSMutableArray alloc] init];
        
        //添加钱包
        for (NSDictionary *dic in self.wallArr) {
            
            if ([[[dic objectForNotNullKey:@"available_balance"] objectForNotNullKey:@"currency"] isEqualToString:self.Currency]) {
                
                    CardModel *card = [[CardModel alloc] init];
                    card.isCardPay = NO;
                    card.walletAmount = [NSString stringWithFormat:@"%@", [[dic objectForNotNullKey:@"available_balance"] objectForNotNullKey:@"available_balance"]];
                    card.strCardName = [NSString stringWithFormat:@"%@ %.2f - wallet", [[dic objectForNotNullKey:@"available_balance"] objectForNotNullKey:@"currency"], [[[dic objectForNotNullKey:@"available_balance"] objectForNotNullKey:@"available_balance"] floatValue]];
                    [cardArr addObject:card];
            }
            
        }
        
        //添加银行卡
        for (int i = 0; i < arr.count; i++) {
            
            NSDictionary *dic = [arr objectAtNotNullIndex:i];
            if (i == 0) {
                model.realyPayCardID = [dic objectForNotNullKey:@"id"];
            }
            
            CardModel *card = [[CardModel alloc] init];
            card.isCardPay = YES;
            card.strCardName = [dic objectForNotNullKey:@"deposit_bank"];
            card.strPayCardID = [dic objectForNotNullKey:@"card_account_no"];
            card.realyPayCardID = [dic objectForNotNullKey:@"id"];
            [cardArr addObject:card];
        }
        
        model.cardArr = cardArr;
        
        model.strImageHeaderUrl = self.storeImgUrl;
        model.strPayObjKey = self.otherUserId;
        model.strPayeeName = self.storeName;
        model.strCurrency = self.Currency;
        model.strAmount = self.nowSelectGiftCardDic.allKeys ? [NSString stringWithFormat:@"%.2f", [self.moneyNum floatValue]-[[self.nowSelectGiftCardDic objectForNotNullKey:@"Amount"] floatValue] > 0 ? [self.moneyNum floatValue]-[[self.nowSelectGiftCardDic objectForNotNullKey:@"Amount"] floatValue] : 0] : self.moneyNum;
        
        [dic setObject:model forKey:@"Content"];
        
        LPAlertView *lpAlertView = [[LPAlertView alloc] initWithType:1 andOtherData:dic andVC:self];
        
        lpAlertView.payForResult = ^(OSellPayMentModel *mode) {
            //银行卡ID、支付方式类型
            
            [self goOmoneyPayActionWithOrderId:theOrderID andWithCardID:mode.realyPayCardID andPayType:mode.isCardPay];
            
        };
        [lpAlertView showXLAlertView];
        
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
    }];
    
}

/*/OmoneyPay/OmoneyPayment
 PayObjType(付款人) 支付对象类型：0-礼品卡 ； 1-订单
 PayObjKey(支付对象ID)支付对象：礼品卡号/订单ID
 PayMethodType(支付方式类型)支付方式类型 0-银行卡；1-账户余额（钱包）
 PayCardID(银行卡ID)PayMethodType=0时 的 银行卡ID (银行卡列表有返回)
 PayGiftCard(礼品卡号)支付用-礼品卡号
 PayGiftCardAmount(礼品卡支付金额)支付用-礼品卡支付金额（PayGiftCard非空时使用）
 PayUserID(付款人)支付用户ID*/
- (void)goOmoneyPayActionWithOrderId:(NSString *)theOrderId andWithCardID:(NSString *)theCardID andPayType:(BOOL)theIsCardPay{
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"1", @"PayObjType",
                                      theOrderId, @"PayObjKey",
                                      theIsCardPay ? @"0" : @"1", @"PayMethodType",
                                      theIsCardPay ? theCardID : @"", @"PayCardID",
                                      self.nowSelectGiftCardDic.allKeys ? [self.nowSelectGiftCardDic objectForNotNullKey:@"CardNo"] : @"", @"PayGiftCard",
                                      self.nowSelectGiftCardDic.allKeys ? [self.nowSelectGiftCardDic objectForNotNullKey:@"Amount"] : @"", @"PayGiftCardAmount",
                                      [[OSellLoginUserHelper shareInstance] getCurUserInfo].userId, @"PayUserID",
                                      nil];
    
    [DZProgress show:[self getString:@"loading..."]];
    NSString *url = [NSString stringWithFormat:@"%@%@",[[OSellServerHelper shareInstance] addressForBaseAPI],@"OmoneyPay/OmoneyPayment"];
    
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:url andParams:parameter andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        if (apiResult.dataResult) {
            
            //AddPowerNum
            NSInteger powerNum = [[apiResult.dataResult objectForNotNullKey:@"AddPowerNum"] integerValue];
            if (powerNum>0) {
                [OSellScoreTipView scoreTipViewShowScoreTitle:[self getString:@"\nPower"] andShowScore:[NSString stringWithFormat:@"\n+%zi",powerNum]  andTip:@"" andBgViewImageName:@"icon-hongbaokai"andView:self.view];
//                [self makeToast:[NSString stringWithFormat:@"Shopping Bonus %zi SilkPower", powerNum]];
            }
//            [self makeToast:apiResult.dataResult];
            OSellPurchaseSuccessVC *vc = [[OSellPurchaseSuccessVC alloc] init];
            [self pushController:vc];
            
        }
        
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
        
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        
        
    }];
    
}

#pragma mark - 填写备注
- (void)newNoteWithModel:(OSellBuyCateModel *)theModel andSection:(NSInteger)section andNote:(NSString *)note{
    theModel.Note = note;
    [self.arrStores replaceObjectAtIndex:section withObject:theModel];
    [self.tableMain reloadData];
   
}
- (void)chooseCourier:(NSNotification *)info{
    NSDictionary *dic = info.userInfo;
    NSInteger section = [[dic objectForNotNullKey:@"section"] integerValue];
    OSellBuyCateModel *model = [dic objectForNotNullKey:@"model"];
    [self.arrStores replaceObjectAtIndex:section withObject:model];
    [self.tableMain reloadData];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ChooseCourier" object:nil];
}
- (NSMutableArray *)arrStores{
    if (!_arrStores) {
        _arrStores = [[NSMutableArray alloc] init];
    }
    return _arrStores;
}

- (NSMutableArray *)arrProducts{
    if (!_arrProducts) {
        _arrProducts = [[NSMutableArray alloc] init];
    }
    return _arrProducts;
}

- (NSMutableArray *)arrAddressList
{
    if (!_arrAddressList) {
        _arrAddressList = [[NSMutableArray alloc] init];
    }
    return _arrAddressList;
}

- (NSString *)defaultAddressId
{
    if (!_defaultAddressId) {
        _defaultAddressId = @"";
    }
    return _defaultAddressId;
}

- (UIView *)tableViewHeaderView {
    if (!_tableViewHeaderView) {
        
        _tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windosSize.width, self.IsSupportTake ? 110+15+40 : 110+15)];
        _tableViewHeaderView.backgroundColor = [UIColor whiteColor];
        
        if (self.IsSupportTake) {
            //自提view
            UIView *shippingMethodView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windosSize.width, 40)];
            UITapGestureRecognizer *shippingMethodTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shippingMethodTapAction)];
            shippingMethodView.userInteractionEnabled = YES;
            [shippingMethodView addGestureRecognizer:shippingMethodTap];
            [_tableViewHeaderView addSubview:shippingMethodView];
            
            UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, windosSize.width, 1)];
            bottomLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [shippingMethodView addSubview:bottomLine];
            
            UILabel *shippingMethodTitle = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 120, 39)];
            shippingMethodTitle.text = @"Shipping method:";
            shippingMethodTitle.font = [UIFont systemFontOfSize:14.0f];
            shippingMethodTitle.textColor = UIColorFromRGB(0x333333);
            [shippingMethodView addSubview:shippingMethodTitle];
            
            _shippingMethod = [[UILabel alloc] initWithFrame:CGRectMake(shippingMethodTitle.right+5, 0, windosSize.width-140, 39)];
            _shippingMethod.text = @"Express";
            _shippingMethod.font = [UIFont systemFontOfSize:14.0f];
            _shippingMethod.textColor = UIColorFromRGB(0x999999);
            [shippingMethodView addSubview:_shippingMethod];
            
            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(windosSize.width - 14 - 9, 20-15/2, 9, 15)];
            iconImgView.image = [UIImage imageNamed:@"font_icon_arr_right2"];
            [shippingMethodView addSubview:iconImgView];
        }
        
        
        //地址view
        UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.IsSupportTake ? 40 : 0, windosSize.width, 110)];
        UITapGestureRecognizer *addressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressTapAction)];
        addressView.userInteractionEnabled = YES;
        [addressView addGestureRecognizer:addressTap];
        [_tableViewHeaderView addSubview:addressView];
        
        _iconImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(windosSize.width - 14 - 9, 55-15/2, 9, 15)];
        _iconImgView1.image = [UIImage imageNamed:@"font_icon_arr_right2"];
        [addressView addSubview:_iconImgView1];
        
        UIImageView *iconImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(14, 55-10, 20, 20)];
        iconImgView2.image = [UIImage imageNamed:@"iconGoodsBuyActionLocation"];
        [addressView addSubview:iconImgView2];
        
        _addressDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImgView2.right + 10, 55-15, _iconImgView1.left - 10 - iconImgView2.right - 10, 30)];
        _addressDetailLabel.font = [UIFont systemFontOfSize:12.0f];
        _addressDetailLabel.textColor = UIColorFromRGB(0x666666);
        _addressDetailLabel.numberOfLines = 2;
        [addressView addSubview:_addressDetailLabel];
        
        _addressNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_addressDetailLabel.left, _addressDetailLabel.top-5-20, _addressDetailLabel.width, 20)];
        _addressNameLabel.font = [UIFont systemFontOfSize:15.0f];
        _addressNameLabel.textColor = UIColorFromRGB(0x333333);
        [addressView addSubview:_addressNameLabel];
        
        _addressPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(_addressDetailLabel.left, _addressDetailLabel.bottom+5, _addressDetailLabel.width, 20)];
        _addressPhoneLabel.font = [UIFont systemFontOfSize:12.0f];
        _addressPhoneLabel.textColor = UIColorFromRGB(0x666666);
        [addressView addSubview:_addressPhoneLabel];
        
        for (NSDictionary *dic in self.arrAddressList) {
            if ([[dic objectForNotNullKey:@"IsDefault"] boolValue]) {
                _addressDetailLabel.text = [dic objectForNotNullKey:@"Address"];
                _addressPhoneLabel.text = [dic objectForNotNullKey:@"Phone"];
                _addressNameLabel.text = [dic objectForNotNullKey:@"Name"];
                self.defaultAddressId = [dic objectForNotNullKey:@"AddressID"];
                self.defaultCountry = [dic objectForNotNullKey:@"Country"];
                [OSellInquiryHelper shareInstance].defaultAddressId = self.defaultAddressId;
                
            }
        }
        if (self.arrAddressList.count == 0) {
            _addressDetailLabel.text = [self getString:@"OSellBuyCateVC_Full Address"];
        }
        
        
        UIImageView *iconImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, addressView.bottom, windosSize.width, 5)];
        iconImgView3.image = [UIImage imageNamed:@"iconAddressCyw.jpg"];
        [_tableViewHeaderView addSubview:iconImgView3];
        
        UILabel *bottomLine2 = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImgView3.bottom, windosSize.width, 10)];
        bottomLine2.backgroundColor = UIColorFromRGB(0xF3F4F5);
        [_tableViewHeaderView addSubview:bottomLine2];
        
        
    }
    return _tableViewHeaderView;
}

//地址点击事件
- (void)addressTapAction
{
    if (![self.methodType isEqualToString:@"1"]) return;
    
    OSellInquiryAddressListViewController *vc = [[OSellInquiryAddressListViewController alloc] init];
    __weak __typeof(self) weakSelf = self;
    vc.kAddressBlock = ^(NSMutableDictionary *addressInfo , NSString *addressID){
        
        weakSelf.addressDetailLabel.text = [addressInfo objectForNotNullKey:@"Address"];
        weakSelf.addressPhoneLabel.text = [addressInfo objectForNotNullKey:@"Phone"];
        weakSelf.addressNameLabel.text = [addressInfo objectForNotNullKey:@"Name"];
        weakSelf.defaultAddressId = [addressInfo objectForNotNullKey:@"AddressID"];
        [OSellInquiryHelper shareInstance].defaultAddressId = weakSelf.defaultAddressId;
        self.defaultCountry = [addressInfo objectForNotNullKey:@"Country"];
        
        [weakSelf cleanShipInfoData];
    };
    
    [self pushController:vc];
}

//自提点击事件
- (void)shippingMethodTapAction {
    
    OSellShippingMethodVC *vc = [[OSellShippingMethodVC alloc] init];
    vc.methodType = self.methodType;
    vc.selectMethodSuccessBlock = ^(NSString *methodType) {
        
        self.methodType = methodType;
        
        if ([self.methodType isEqualToString:@"1"]) {
            
            self.iconImgView1.hidden = NO;
            _shippingMethod.text = @"Express";
            if (_addressNameLabel) {
                
                for (NSDictionary *dic in self.arrAddressList) {
                    
                    if ([[dic objectForNotNullKey:@"IsDefault"] boolValue]) {
                        
                        self.addressDetailLabel.text = [dic objectForNotNullKey:@"Address"];
                        self.addressPhoneLabel.text = [dic objectForNotNullKey:@"Phone"];
                        self.addressNameLabel.text = [dic objectForNotNullKey:@"Name"];
                        self.defaultAddressId = [dic objectForNotNullKey:@"AddressID"];
                        self.defaultCountry = [dic objectForNotNullKey:@"Country"];
                        [OSellInquiryHelper shareInstance].defaultAddressId = self.defaultAddressId;
                        
                        [self cleanShipInfoData];
                    }
                }
                
            }
            
        }else {
            
            self.shippingMethod.text = @"Pick up in store";
            self.addressPhoneLabel.text = @"";
            self.addressNameLabel.text = @"";
            self.defaultAddressId = @"";
            self.iconImgView1.hidden = YES;
            self.addressDetailLabel.text = [NSString stringWithFormat:@"Pick-up counter:%@", self.TakeAddress];
            
            OSellBuyCateModel *theModel = [self.arrStores objectAtNotNullIndex:0];
            theModel.shipNameStr = @"";
            theModel.shipMoneyStr = @"";
            theModel.shipOneMoney = @"";
            theModel.shipIdStr = @"";
            
            [self.arrStores replaceObjectAtIndex:0 withObject:theModel];
            
            [self.tableMain reloadData];
        }
        
    };
    [self pushController:vc];
    
}

- (void)cleanShipInfoData
{
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [InternationalizationHelper getLocalizeion], @"lan", nil];
    
    NSString *url = @"";
    
    /*1015000050.BuyNow运费模板根据产品和地址返回邮费列表(VersionsBuyerFive/getShippingMethodByAdressAndProduct)
     UserID:用户ID
     AddressID:地址ID
     ListProduct:[{"HallProductID": 32,"Count": 100 },{"HallProductID": 37, "Count": 100} ]选品及数量
     Currency(货币类型):
     语言(lan):*/
    
    NSMutableArray *allArr = [[NSMutableArray alloc] init];
    NSMutableArray *arr = [self.arrProducts objectAtNotNullIndex:0];
    for (OSellBuyCateModel *model in arr) {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:[NSString stringWithFormat:@"%@",model.HallProductID] forKey:@"HallProductID"];
        [dic setObject:[NSString stringWithFormat:@"%@",model.Count] forKey:@"Count"];
        
        [allArr addObject:dic];
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allArr options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *strOrderList = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [parameter setObject:[[OSellLoginUserHelper shareInstance] getCurUserInfo].userId forKey:@"UserID"];
    [parameter setObject:self.defaultAddressId forKey:@"AddressID"];
    [parameter setObject:strOrderList forKey:@"ListProduct"];
    [parameter setObject:[NSString isNullOrEmpty:self.Currency] ? @"":self.Currency forKey:@"Currency"];
    [parameter setObject:[InternationalizationHelper getLocalizeion] forKey:@"lan"];
    url = [NSString stringWithFormat:@"%@%@",[[OSellServerHelper shareInstance] addressForBaseAPI],@"VersionsBuyerFive/getShippingMethodByAdressAndProduct"];
    
    
    [DZProgress show:[self getString:@"loading..."]];
    [[OSellHTTPHelper shareInstance] requestHTTPDataWithAPI:url andParams:parameter andSuccessBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        /// 判断数据信息
        if (![apiResult.dataResult isKindOfClass:[NSArray class]]) {
            return;
        }
        
        NSArray *dataArr = apiResult.dataResult;
        
        if (dataArr.count) {
            
            NSDictionary *dataDic = [dataArr objectAtNotNullIndex:0];
            OSellBuyCateModel *theModel = [self.arrStores objectAtNotNullIndex:0];
            /*{
             "ShippingMethodID": 1,
             "ShippingMethodName": "UPS",
             "ShippingMethodPrice": 100,
             "Currency": "$",
             "CurrencyName": "USD"
             }*/
            
            theModel.shipOneMoney = [NSString stringWithFormat:@"%@", [dataDic objectForNotNullKey:@"ShippingMethodPrice"]];
            theModel.shipMoneyStr = [NSString stringWithFormat:@"%@%.2f", [dataDic objectForNotNullKey:@"CurrencyName"], [[dataDic objectForNotNullKey:@"ShippingMethodPrice"] floatValue]];
            theModel.shipIdStr = [NSString stringWithFormat:@"%@", [dataDic objectForNotNullKey:@"ShippingMethodID"]];
            theModel.shipNameStr = [NSString stringWithFormat:@"%@", [dataDic objectForNotNullKey:@"ShippingMethodName"]];
            
            [self.tableMain reloadData];
            [self calculateTotalPrice];
        }
        
        
    } andFailBlock:^(OSellAPIResult *apiResult) {
        
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        
        /// Token失败，需要重新登录
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[OSellLoginUserHelper shareInstance] cleanUserInfo];
            [[OSellLoginUserHelper shareInstance] cleanCompanyInfo];
            [[XmppHelper shareInstance] logout];
            [[UIUtils instance] setRootVCWithLogin];
            
        });
        
    }];
    
    
}

- (NSMutableArray *)wallArr {
    
    if (!_wallArr) {
        _wallArr = [[NSMutableArray alloc] init];
    }
    return _wallArr;
    
}

- (NSDictionary *)nowSelectGiftCardDic {
    
    if (!_nowSelectGiftCardDic) {
        _nowSelectGiftCardDic = [[NSDictionary alloc] init];
    }
    return _nowSelectGiftCardDic;
    
}

- (NSString *)methodType {
    
    if (!_methodType) {
        _methodType = @"1";
    }
    return _methodType;
}

@end
