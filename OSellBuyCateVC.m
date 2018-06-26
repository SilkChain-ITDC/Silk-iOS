//
//  OSellBuyCateVC.m
//  OSell
//  购物车
//  Created by OSellResuming on 16/9/29.
//  Copyright © 2016年 OSellResuming. All rights reserved.
//

#import "OSellBuyCateVC.h"
#import "OSellBuyCateCell.h"
#import "OSellBuyCateModel.h"
#import "OSellStoreViewController.h"
#import "OSellGoodsDetailsViewController.h"
#import "OSellMakeSureOrderVC.h"
#import "OSellFavoriteProductListVC.h"
@interface OSellBuyCateVC ()
@property (strong, nonatomic) NSMutableArray *arrProducts;//分组以后的数据
@property (strong, nonatomic) NSMutableArray *arrNormalProducts;//正常的商品列表
@property (strong, nonatomic) NSMutableArray *arrInvalidProducts;//已失效的商品列表
@property (strong, nonatomic) NSMutableArray *arrStores;//正常的店铺列表
@property (strong, nonatomic) NSMutableArray *arrSelectProducts;//已选中的商品
@property (strong, nonatomic) NSMutableArray *arrCurrency;//已选商品的货币单位
@property (weak, nonatomic) IBOutlet UIView *viewNoProduct;

@property (weak, nonatomic) IBOutlet UILabel *lblNoProduct;

@property (weak, nonatomic) IBOutlet UIButton *btnBrowse;

- (IBAction)btnBrowseAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBrowseWidth;

@property (weak, nonatomic) IBOutlet UIButton *btnLike;

- (IBAction)btnLikeAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnLikeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomHeight;

@end

@implementation OSellBuyCateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.strHallID = @"88";
    [self.tableMain registerNib:[UINib nibWithNibName:@"OSellBuyCateCell" bundle: [NSBundle mainBundle]] forCellReuseIdentifier:@"OSellBuyCateCell"];
        // Do any additional setup after loading the view from its nib.
}

- (void)readyUI{
    self.btnPurchaseAll.hidden = YES;
    [self.btnSettlement setTitle:[self getString:@"OSellBuyCateVC_Empty"] forState:UIControlStateSelected];
    [self.btnSettlement setTitle:[self getString:@"OSellBuyCateVC_Proceed to checkout"] forState:UIControlStateNormal];
    self.btnSettlement.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnCollection.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnPurchaseAll.titleLabel.adjustsFontSizeToFitWidth = YES;
    CGSize detailsLabSize = CGSizeMake(self.lblNoProduct.width/2, MAXFLOAT);
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGSize sizeToFit = [[self getString:@"OSellBuyCateVC_Go Shopping"] boundingRectWithSize:detailsLabSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    self.btnBrowse.layer.borderWidth = 0.5f;
    [self.btnBrowse.layer setBorderColor:UIColorFromRGB(0xF83030).CGColor];
    self.btnBrowseWidth.constant = sizeToFit.width + 16;
    [self.btnBrowse setTitle:[self getString:@"OSellBuyCateVC_Go Shopping"] forState:0];
    
    sizeToFit = [[self getString:@"OSellBuyCateVC_My Wish List"] boundingRectWithSize:detailsLabSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    self.btnLike.layer.borderWidth = 0.5f;
    [self.btnLike.layer setBorderColor:UIColorFromRGB(0xF83030).CGColor];
    self.btnLikeWidth.constant = sizeToFit.width + 16;
    [self.btnLike setTitle:[self getString:@"OSellBuyCateVC_My Wish List"] forState:0];
    [self.lblNoProduct setText:[self getString:@"OSellBuyCateVC_Purchase List is empty"]];
    [self.btnCollection setTitle:[self getString:@"OSellBuyCateVC_Add to My Wish List"] forState:0];
//    [self.lblAllMoneyTitle setText:];
//
//    if ([[InternationalizationHelper getCurLanguage]isEqualToString:LOCALIZATOIN_ENGLISH]) {
//        [self.lblAllMoneyTitle setText:[NSString stringWithFormat:@"%@:",[self getString:@"OSellBuyCateVC_Total Amount"]]];
//    }
    
    [self.btnPurchaseAll setTitle:[NSString stringWithFormat:@"  %@",[self getString:@"OSellBuyCateVC_Select All"]] forState:0];
    if (self.navigationController.viewControllers.count>1) {
        [self setBackItem];
    }

}

#pragma mark - 编辑/取消编辑
- (void)rightBarButtonClick:(UIButton *)sender{
    
    if ([self.btnSettlement isSelected]) {
        //结算
        [self setBarButton:@"edit_selected" frame:CGRectMake(0, 0, 20, 20) isright:YES];
        [self.btnSettlement setSelected:NO];
        [self.btnCollection setHidden:YES];
        [self.lblAllMoneyTitle setHidden:NO];
        [self.lblAllMoneyValue setHidden:NO];
        
        for (int i=0; i<self.arrNormalProducts.count; i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            model.isSelect = NO;
            //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
        }
        for (int i=0; i<self.arrStores.count; i++) {
            OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
            model.isAllSelect = NO;
            //[self.arrStores replaceObjectAtIndex:i withObject:model];
        }

    } else {
        //清除
        [self setBarRightButtonTitle:[self getString:@"OSellBuyCateVC_Complete"]];
        [self.btnSettlement setSelected:YES];
        [self.btnCollection setHidden:NO];
        [self.lblAllMoneyTitle setHidden:YES];
        [self.lblAllMoneyValue setHidden:YES];
        for (int i=0; i<self.arrNormalProducts.count; i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            model.isSelect = NO;
            //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
        }
        for (int i=0; i<self.arrStores.count; i++) {
            OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
            model.isAllSelect = NO;
            //[self.arrStores replaceObjectAtIndex:i withObject:model];
        }

    }
    [self checkTheSelectedState];
    [self.tableMain reloadData];
    [self calculateTotalPrice];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self setupMJRefresh];
    self.title = [self getString:@"OSellBuyCateVC_Purchase List"];
    [self readyUI];
}

#pragma mark - 设置上拉下拉刷新
/**
 *  设置下拉上拉刷新
 */
- (void)setupMJRefresh
{
    
    __weak __typeof(self) weakSelf = self;
    
    MJRefreshNormalHeader *headerProduct = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        
        [weakSelf requestBuyCateList];
        
    }];
    // 设置文字
    [headerProduct setTitle:[self getString:@"Pull to refresh..."] forState:MJRefreshStateIdle];
    [headerProduct setTitle:[self getString:@"Release to refresh..."] forState:MJRefreshStatePulling];
    [headerProduct setTitle:[self getString:@"loading..."] forState:MJRefreshStateRefreshing];
    headerProduct.stateLabel.textColor = [UIColor lightGrayColor];
    [headerProduct.stateLabel setFont:[UIFont systemFontOfSize:13.0f]];
    
    headerProduct.lastUpdatedTimeLabel.hidden = YES;
    self.tableMain.header = headerProduct;
    // 马上进入刷新状态
    [self.tableMain.header beginRefreshing];

}

#pragma mark - 请求购物车数据
- (void)requestBuyCateList{
    [self setBarButton:@"" frame:CGRectMake(0, 0,0 , 0) isright:YES];

    NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
    [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
    [dictParams setValue: self.strHallID forKey: @"HallID"];
    [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
    NSString *address=[NSString stringWithFormat:@"%@VersionsBuyerFive/GetBuyNowTrolleyList",[[OSellServerHelper shareInstance] addressForBaseAPI]];
    [DZProgress show:[self getString:@"loading..."]];
    [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        
        [self.tableMain.header endRefreshing];
        [self.arrStores removeAllObjects];
        [self.arrInvalidProducts removeAllObjects];
        [self.arrNormalProducts removeAllObjects];
        [self.arrProducts removeAllObjects];
        if (![apiResult.dataResult isKindOfClass:[NSDictionary class]]) return ;
        NSArray *arrNormal = [apiResult.dataResult objectForNotNullKey:@"NormalProductList"];
        if ([arrNormal isKindOfClass:[NSArray class]]&&
            arrNormal.count>0) {
            [self setBarButton:@"edit_selected" frame:CGRectMake(0, 0, 20, 20) isright:YES];
            for (NSDictionary *dicNormal in arrNormal) {
    
                if (![dicNormal isKindOfClass:[NSDictionary class]]) continue;
                
                OSellBuyCateModel *model = [[OSellBuyCateModel alloc]initWithDataDic:dicNormal];
                model.OrderType = 0;
                for (NSString *strID in [AppDelegate shareInstance].arrSelectProducts) {
                    if ([model.ID isEqualToString:strID]) {
                        model.isSelect = YES;
                        continue;
                    }
                }
                [self.arrNormalProducts addObject:model];
                
            }

        }
        
        NSArray *arrInvalid = [apiResult.dataResult objectForNotNullKey:@"InvalidProductList"];
        if ([arrInvalid isKindOfClass:[NSArray class]]&&
            arrInvalid.count>0) {
            for (NSDictionary *dicInvalid in arrInvalid) {
                
                if (![dicInvalid isKindOfClass:[NSDictionary class]]) continue;
                
                OSellBuyCateModel *model = [[OSellBuyCateModel alloc]initWithDataDic:dicInvalid];
                
                
                [self.arrInvalidProducts addObject:model];

            }

        }
        
        [self showAllPrimaryCategories];
        [self checkTheSelectedState];
        [self.tableMain reloadData];
        [self calculateTotalPrice];
        if (self.arrNormalProducts.count<=0 && self.arrInvalidProducts.count <= 0) {
            [self.viewNoProduct setHidden:NO];
        }else{
            [self.viewNoProduct setHidden:YES];
        }
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [self.tableMain.header endRefreshing];
        [self makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [self.tableMain.header endRefreshing];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        [self.tableMain.header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [DZProgress dismiss];
            [[SilkLoginUserHelper shareInstance] cleanUserInfo];
            [[XmppHelper shareInstance] logout];
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
        });
        
        
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.arrInvalidProducts.count>0?self.arrStores.count+1:self.arrStores.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
  
    if (section == self.arrStores.count) {
        return self.arrInvalidProducts.count;
    }else{
        NSArray *arr = [self.arrProducts objectAtNotNullIndex:section];
        return arr.count;
    }
    
    
    
    
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    UIButton *btnSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [btnSelect setImage:[UIImage imageNamed:@"icon-no_address"] forState:0];
    [btnSelect setImage:[UIImage imageNamed:@"icon-default_address"] forState:UIControlStateSelected];
    [btnSelect addTarget:self action:@selector(btnGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnSelect setTag:section];
    
    
    UILabel *lblGroup = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, view.width-50, 40)];
    [lblGroup setFont:[UIFont systemFontOfSize:15.0f]];
    [lblGroup setTextColor:UIColorFromRGB(0x333333)];
    
    
    UIButton *btnLookToStore = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, view.width-55, view.height)];
    btnLookToStore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btnLookToStore addTarget:self action:@selector(btnLookIntoStore:) forControlEvents:UIControlEventTouchUpInside];
    [btnLookToStore setTitleColor:UIColorFromRGB(0x007AFF) forState:0];
    [btnLookToStore.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btnLookToStore setTag:section];
    OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:section];
    if (section == self.arrStores.count) {
        [lblGroup setText:[self getString:@"OSellBuyCateVC_Invalid Items"]];
        [btnLookToStore setTitle:[self getString:@"OSellBuyCateVC_Empty"] forState:0];
        [btnLookToStore setImage:nil forState:0];
        
    }else{
        [view addSubview:btnSelect];
        [lblGroup setText:model.SupplierName];
        if (model.isAllSelect) {
            [btnSelect setSelected:YES];
        } else {
            [btnSelect setSelected:NO];
        }
        [btnLookToStore setTitle:@"" forState:0];
        [btnLookToStore setImage:[UIImage imageNamed:@"font_icon_arr_right2.png"] forState:0];
    }
    [view addSubview:lblGroup];
    [view addSubview:btnLookToStore];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    OSellBuyCateCell *cell = [tableView dequeueReusableCellWithIdentifier: @"OSellBuyCateCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == self.arrStores.count) {
        [cell showProductInfo:[self.arrInvalidProducts objectAtNotNullIndex:indexPath.row]];
    }else{
        NSArray *arr = [self.arrProducts objectAtNotNullIndex:indexPath.section];
        [cell showProductInfo:[arr objectAtNotNullIndex:indexPath.row]];
        cell.kCountBlock = ^(NSString *count , NSString *hallProductID){
            [weakSelf refreshProductCount:hallProductID andCount:count];
        };
        cell.kSelectBlock = ^(BOOL isSelect , NSString *ID){
            [weakSelf refreshProductSelectState:isSelect andID:ID];
        };
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    OSellBuyCateModel *model ;
    if (indexPath.section == self.arrStores.count) {
        model = [self.arrInvalidProducts objectAtNotNullIndex:indexPath.row];
    }else{
        NSArray *arr = [self.arrProducts objectAtNotNullIndex:indexPath.section];
        
        model = [arr objectAtNotNullIndex:indexPath.row];

    }
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
    
    return 5;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 110.0f;
    
}

#pragma mark - 根据店铺的ID进行分组
- (void)showAllPrimaryCategories{
    
    NSMutableArray *arrDefaultCategoryID = [[NSMutableArray alloc] init];
    for (OSellBuyCateModel *model in self.arrNormalProducts) {
        [arrDefaultCategoryID addObject:model.SupplierName];
    }
    NSMutableArray *arrParentID = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [arrDefaultCategoryID count]; i++) {
        
        @autoreleasepool {
            
            if ([arrParentID containsObject:[arrDefaultCategoryID objectAtIndex:i]]== NO) {
                [arrParentID addObject:[arrDefaultCategoryID objectAtIndex:i]];
                OSellBuyCateModel *model = [self.arrNormalProducts objectAtIndex:i];
                [self.arrStores addObject:model];
                [self calculateTheNumberOfProductByHallID:model];
            }
            
        }
        
    }
    arrParentID  = nil;
    
}

#pragma mark - 根据店铺的ID查询该店铺的商品
- (void)calculateTheNumberOfProductByHallID:(OSellBuyCateModel *)buyCateModel{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (OSellBuyCateModel *model in self.arrNormalProducts) {
        if ([[NSString stringWithFormat:@"%@",model.SupplierId] isEqualToString: [NSString stringWithFormat:@"%@",buyCateModel.SupplierId]]) {
            [arr addObject:model];
        }
    }
    [self.arrProducts addObject:arr];
}

#pragma mark - 结算/清除
- (IBAction)btnSettlementAction:(id)sender {
    if ([sender isSelected]) {
        //清除
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[self getString:@"OSellBuyCateVC_Confirm to delete?"] delegate:self cancelButtonTitle:[self getString:@"OSellBuyCateVC_No"] otherButtonTitles:[self getString:@"OSellBuyCateVC_Yes"], nil];
        [alert setTag:9999];
        [alert show];
        
    }else{
        //结算
        NSMutableArray *arrSelectProducts = [[NSMutableArray alloc] init];
        NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
        [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
        NSString *strProductIDs = @"";
        for (int i =0;i<self.arrNormalProducts.count;i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            if (model.isSelect) {
                [arrSelectProducts addObject:model];
                if ([NSString isNullOrEmpty:strProductIDs]) {
                    strProductIDs=[strProductIDs stringByAppendingString:[NSString stringWithFormat:@"%@",model.ID]];
                }else{
                    strProductIDs=[strProductIDs stringByAppendingFormat:@",%@",[NSString stringWithFormat:@"%@",model.ID]];
                }
            }
        }
        if ([NSString isNullOrEmpty:strProductIDs]) {
            return;
        }
       
        [dictParams setValue:strProductIDs forKey:@"TrolleyIDList"];
        [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
       
        [DZProgress show:[self getString:@"loading..."]];
        NSString *address=[NSString stringWithFormat:@"%@VersionsBuyerFive/SettlementAredyVerification",[[OSellServerHelper shareInstance] addressForBaseAPI]]; // OrderAbout/SettlementVerification
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [self.tableMain.header beginRefreshing];
            OSellMakeSureOrderVC *vc = [[OSellMakeSureOrderVC alloc] init];
            vc.arrSelectProducts = arrSelectProducts;
            vc.arrSelectCurrencyProducts = self.arrSelectProducts;
            [self pushController:vc];
            [DZProgress dismiss];
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[SilkLoginUserHelper shareInstance] cleanUserInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];
//

    }
}


#pragma mark - 全选/全部取消 所有商品
- (IBAction)btnPurchaseAllAction:(id)sender {
    /*/
    if ([sender isSelected]) {
        //全部取消
        [[AppDelegate shareInstance].arrSelectProducts removeAllObjects];
        for (int i=0; i<self.arrNormalProducts.count; i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            model.isSelect = NO;
            [self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
        }
        for (int i=0; i<self.arrStores.count; i++) {
            OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
            model.isAllSelect = NO;
            [self.arrStores replaceObjectAtIndex:i withObject:model];
        }
        [sender setSelected:NO];
    } else {
        //全选
        for (int i=0; i<self.arrNormalProducts.count; i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            model.isSelect = YES;
            [self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
            [[AppDelegate shareInstance].arrSelectProducts addObject:model.ID];
        }
        for (int i=0; i<self.arrStores.count; i++) {
            OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
            model.isAllSelect = YES;
            [self.arrStores replaceObjectAtIndex:i withObject:model];
        }
        [sender setSelected:YES];
    }
    [self.tableMain reloadData];
    [self calculateTotalPrice];
    //*/
}


#pragma mark - 全选或者全取消该店铺（该组）的全部商品
- (void)btnGroupAction:(UIButton *)sender {

        OSellBuyCateModel *chooseModel = [self.arrStores objectAtNotNullIndex:sender.tag];
        if ([sender isSelected]) {
            chooseModel.isAllSelect = NO;
            //[self.arrStores replaceObjectAtIndex:sender.tag withObject:chooseModel];
            for (int i=0; i<self.arrNormalProducts.count; i++) {
                OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
                if ([[NSString stringWithFormat:@"%@",model.SupplierId] isEqualToString:[NSString stringWithFormat:@"%@",chooseModel.SupplierId]]) {
                    model.isSelect = NO;
                    [[AppDelegate shareInstance].arrSelectProducts removeObject:model.ID];
                    //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
                }
            }
        }else{
            if ([AppDelegate shareInstance].arrSelectProducts.count > 0) {
                NSString *oneHallId;
                NSString *oneId = [NSString stringWithFormat:@"%@", [AppDelegate shareInstance].arrSelectProducts.firstObject];
                for (int j = 0; j < self.arrNormalProducts.count; j++) {
                    OSellBuyCateModel *aModel = [self.arrNormalProducts objectAtIndex:j];
                    NSString *theId = [NSString stringWithFormat:@"%@", aModel.ID];
                    if ([oneId isEqualToString:theId]) {
                        oneHallId = [NSString stringWithFormat:@"%@", aModel.HallID];
                        break;
                    }
                }
                NSString *hallId = [NSString stringWithFormat:@"%@", chooseModel.HallID];
                if (![hallId isEqualToString:oneHallId]) {
                    for (int k = 0; k < self.arrNormalProducts.count; k++) {
                        OSellBuyCateModel *aModel = [self.arrNormalProducts objectAtIndex:k];
                        aModel.isSelect = NO;
                    }
                    for (int m = 0; m < self.arrStores.count; m++) {
                        OSellBuyCateModel *aModel = [self.arrStores objectAtIndex:m];
                        aModel.isAllSelect = NO;
                    }
                    [[AppDelegate shareInstance].arrSelectProducts removeAllObjects];
                }
            }
            chooseModel.isAllSelect = YES;
            //[self.arrStores replaceObjectAtIndex:sender.tag withObject:chooseModel];
            for (int i = 0; i < self.arrNormalProducts.count; i++) {
                OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
                if ([[NSString stringWithFormat:@"%@",model.SupplierId] isEqualToString:[NSString stringWithFormat:@"%@",chooseModel.SupplierId]]) {
                    model.isSelect = YES;
                    [[AppDelegate shareInstance].arrSelectProducts addObject:model.ID];
                    //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
                }
            }
        }
    [self.tableMain reloadData];
    [self calculateTotalPrice];
}


#pragma mark - 查看店铺信息
- (void)btnLookIntoStore:(UIButton *)sender {
    if ([sender tag] == self.arrStores.count) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[self getString:@"OSellBuyCateVC_Confirm to empty?"] delegate:self cancelButtonTitle:[self getString:@"OSellBuyCateVC_No"] otherButtonTitles:[self getString:@"OSellBuyCateVC_Yes"], nil];
        [alert setTag:8888];
        [alert show];
        
    } else {
        OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:sender.tag];
        OSellStoreViewController *vc = [[OSellStoreViewController alloc] init];
        vc.HallID = [NSString stringWithFormat:@"%@",model.HallID];
        [self pushController:vc];
    }
}


#pragma mark - 更改某个商品的数量
- (void)refreshProductCount:(NSString *)hallProuduct andCount:(NSString *)count{
    for (int i=0; i<self.arrNormalProducts.count; i++) {
        OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
        if ([[NSString stringWithFormat:@"%@",model.ID]isEqualToString:hallProuduct]) {
            model.Count = [NSString stringWithFormat:@"%@",count];
            //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
            [self editTrolleyCountWithID:model.ID andCount:count];
            break;
        }
    }
    [self.tableMain reloadData];
    [self calculateTotalPrice];
}


#pragma mark - 更新某个商品的按钮选中/取消选中
- (void)refreshProductSelectState:(BOOL)isSelect andID:(NSString *)theID{
    for (int i=0; i<self.arrNormalProducts.count; i++) {
        OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
        if ([[NSString stringWithFormat:@"%@",model.ID]isEqualToString:theID]) {
            model.isSelect = isSelect;
            if (isSelect) {
                if ([AppDelegate shareInstance].arrSelectProducts.count > 0) {
                    NSString *oneHallId;
                    NSString *oneId = [NSString stringWithFormat:@"%@", [AppDelegate shareInstance].arrSelectProducts.firstObject];
                    for (int k = 0; k < self.arrNormalProducts.count; k++) {
                        OSellBuyCateModel *aModel = [self.arrNormalProducts objectAtIndex:k];
                        NSString *theId = [NSString stringWithFormat:@"%@", aModel.ID];
                        if ([oneId isEqualToString:theId]) {
                            oneHallId = [NSString stringWithFormat:@"%@", aModel.HallID];
                            break;
                        }
                    }
                    NSString *hallId = [NSString stringWithFormat:@"%@", model.HallID];
                    if (![hallId isEqualToString:oneHallId]) {
                        for (int k = 0; k < self.arrNormalProducts.count; k++) {
                            OSellBuyCateModel *aModel = [self.arrNormalProducts objectAtIndex:k];
                            aModel.isSelect = NO;
                        }
                        [[AppDelegate shareInstance].arrSelectProducts removeAllObjects];
                        model.isSelect = isSelect;
                    }
                }
                [[AppDelegate shareInstance].arrSelectProducts addObject:model.ID];
            }else{
                for (int x=0; x<[AppDelegate shareInstance].arrSelectProducts.count; x++) {
                    NSString *strID = [[AppDelegate shareInstance].arrSelectProducts objectAtNotNullIndex:i];
                    if ([strID isEqualToString:model.ID]) {
                        [[AppDelegate shareInstance].arrSelectProducts removeObject:strID];
                        break;
                    }
                }
            }
            //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
            [self checkTheSelectedState];
            break;
        }
    }
    [self.tableMain reloadData];
    [self calculateTotalPrice];
}


#pragma mark - 更改按钮选中状态
//如果该店铺的商品都选中了。那么组头也选中。有任何一个商品没选中。该组头就未选中。
- (void)checkTheSelectedState{
   [self.btnPurchaseAll setSelected:YES];
    for (int i=0; i<self.arrStores.count; i++) {
        OSellBuyCateModel *storeModel = [self.arrStores objectAtNotNullIndex:i];
        storeModel.isAllSelect = YES;
        for (OSellBuyCateModel *productModel in self.arrNormalProducts) {
            if ([[NSString stringWithFormat:@"%@",productModel.SupplierId]isEqualToString:[NSString stringWithFormat:@"%@",storeModel.SupplierId]]) {
                if (!productModel.isSelect) {
                    storeModel.isAllSelect = NO;
                    [self.btnPurchaseAll setSelected:NO];
                    //[self.arrStores replaceObjectAtIndex:i withObject:storeModel];
                    continue;
                }
            }
        }
    }
}

#pragma mark - 计算所选商品总价
- (void)calculateTotalPrice{
    [self.arrSelectProducts removeAllObjects];
    [self.arrCurrency removeAllObjects];
    [self.btnPurchaseAll setSelected:YES];
    [self.btnSettlement setUserInteractionEnabled:NO];
    [self.btnSettlement setBackgroundColor:UIColorFromRGB(0x98999A)];
    
    [self.lblAllMoneyValue setText:@""];
    for (OSellBuyCateModel *model in self.arrNormalProducts) {
        if (model.isSelect) {
            NSDecimalNumber *totlaPrice = [self notRounding:[NSString stringWithFormat:@"%f",[self getPriceWithModel:model]] afterPoint:2 andCount:[model.Count intValue]];
            if ([self.arrCurrency indexOfObject:model.Currency] == NSNotFound) {
                [self.arrCurrency addObject:model.Currency];
                NSMutableArray *arrProdcuts = [[NSMutableArray alloc] initWithObjects:model, nil];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:model.Currency forKey:@"Currency"];
                [dic setObject:arrProdcuts forKey:@"Product"];
                [dic setObject:totlaPrice forKey:@"Price"];
                [self.arrSelectProducts addObject:dic];
                NSString *agoAlertStr = [NSString stringWithFormat:@"%@%@\n",[self getString:@"OSellBuyCateVC_Total Amount"],[self getString:@"OSellBuyCateVC_Excluding shipping"]];
                NSString *backAlertStr ;
                NSString *alertStr ;
                if ([NSString isNullOrEmpty:self.lblAllMoneyValue.text]) {
                    
                    backAlertStr = [NSString stringWithFormat:@"%@%@ %.2f",self.lblAllMoneyValue.text,model.Currency,[[dic objectForNotNullKey:@"Price"] floatValue]];
                    if ([model.Currency isEqualToString:@"VND"]){
                        backAlertStr = [NSString stringWithFormat:@"%@%@ %@",self.lblAllMoneyValue.text,model.Currency, [UIUtils toVietnameseCurrencyConversion:1 andMoney:[[dic objectForNotNullKey:@"Price"] floatValue]]];
                       
                    }

                    alertStr = [NSString stringWithFormat:@"%@%@", agoAlertStr, backAlertStr];
                }else{
                     backAlertStr = [NSString stringWithFormat:@"%@\n%@ %.2f",self.lblAllMoneyValue.text,model.Currency,[[dic objectForNotNullKey:@"Price"] floatValue]];
                    if ([model.Currency isEqualToString:@"VND"]){
                        backAlertStr = [NSString stringWithFormat:@"%@\n%@ %@",self.lblAllMoneyValue.text,model.Currency,[UIUtils toVietnameseCurrencyConversion:1 andMoney:[[dic objectForNotNullKey:@"Price"] floatValue]]];
                    }
                     alertStr = [NSString stringWithFormat:@"%@", backAlertStr];
                }
                
                NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:alertStr];
                NSRange attriRange = [alertStr rangeOfString:agoAlertStr];
                [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x666666),}
                                     range:attriRange];
                [self.lblAllMoneyValue setAttributedText:attriString];

                
            }else{
                NSString *agoAlertStr = [NSString stringWithFormat:@"%@%@\n",[self getString:@"OSellBuyCateVC_Total Amount"],[self getString:@"OSellBuyCateVC_Excluding shipping"]];
                NSString *backAlertStr ;
                NSString *alertStr ;
                NSString *strMoney = @"";
                for (int x = 0 ; x < self.arrSelectProducts.count; x++) {
                    NSMutableDictionary *dic = [self.arrSelectProducts objectAtNotNullIndex:x];
                    if ([model.Currency isEqualToString:[dic objectForNotNullKey:@"Currency"]]) {
                        NSMutableArray *arrProducts = [dic objectForNotNullKey:@"Product"];
                        [arrProducts addObject:model];
                        NSDecimalNumber *nowPrice = [dic objectForNotNullKey:@"Price"];
                        nowPrice = [nowPrice decimalNumberByAdding:totlaPrice];
                        [dic setObject:arrProducts forKey:@"Product"];
                        [dic setObject:nowPrice forKey:@"Price"];

                        //[self.arrSelectProducts replaceObjectAtIndex:x withObject:dic];
                    }
                   
                    if (x!=0) {
                        backAlertStr = [NSString stringWithFormat:@"%@\n%@ %.2f",strMoney,[dic objectForNotNullKey:@"Currency"],[[dic objectForNotNullKey:@"Price"] floatValue]];
                        if ([model.Currency isEqualToString:@"VND"]){
                            backAlertStr = [NSString stringWithFormat:@"%@\n%@ %@",self.lblAllMoneyValue.text,model.Currency,[UIUtils toVietnameseCurrencyConversion:1 andMoney:[[dic objectForNotNullKey:@"Price"] floatValue]]];
                        }
                        alertStr = [NSString stringWithFormat:@"%@%@", alertStr, backAlertStr];
                    }else{
                        backAlertStr = [NSString stringWithFormat:@"%@%@ %.2f",strMoney,[dic objectForNotNullKey:@"Currency"],[[dic objectForNotNullKey:@"Price"] floatValue]];
                        if ([model.Currency isEqualToString:@"VND"]){
                            backAlertStr = [NSString stringWithFormat:@"%@%@ %@",strMoney,[dic objectForNotNullKey:@"Currency"],[UIUtils toVietnameseCurrencyConversion:1 andMoney:[[dic objectForNotNullKey:@"Price"] floatValue]]];
                        }
                        alertStr = [NSString stringWithFormat:@"%@%@", agoAlertStr, backAlertStr];
                    }

                }
              
                NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:alertStr];
                NSRange attriRange = [alertStr rangeOfString:agoAlertStr];
                [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x666666),}
                                     range:attriRange];
                [self.lblAllMoneyValue setAttributedText:attriString];
                float heigth = [UIUtils heightForString:alertStr fontSize:12 andWidth:SCREEN_WIDTH-260];
                self.viewBottomHeight.constant = heigth+30>65?heigth+16:65;
                [UIView animateWithDuration:0.05f animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
            [self.btnSettlement setUserInteractionEnabled:YES];
            [self.btnSettlement setBackgroundColor:UIColorFromRGB(0xFD6300)];
        }
       
    }
    if ([NSString isNullOrEmpty:self.lblAllMoneyValue.text]&&![self.btnSettlement isSelected]) {
        NSString *agoAlertStr = [NSString stringWithFormat:@"%@%@",[self getString:@"OSellBuyCateVC_Total Amount"],[self getString:@"OSellBuyCateVC_Excluding shipping"]];
        NSString *alertStr ;
        alertStr = [NSString stringWithFormat:@"%@\n$0.00",agoAlertStr];
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:alertStr];
        NSRange attriRange = [alertStr rangeOfString:agoAlertStr];
        [attriString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x666666),}
                             range:attriRange];
        [self.lblAllMoneyValue setAttributedText:attriString];
        [self.lblAllMoneyValue setHidden:NO];

    }
    for (OSellBuyCateModel *model in self.arrStores) {
        if (!model.isAllSelect) {
            [self.btnPurchaseAll setSelected:NO];
        }
    }
    
    
    
}

/**
 *    @brief    截取指定小数位的值(非四舍五入)
 *
 *    @param     price     单价
 *    @param     position     有效小数位
 *    @param     count     数量
 *    @return    截取后数据
 */
- (NSDecimalNumber *)notRounding:(NSString *)price afterPoint:(NSInteger)position andCount:(NSInteger)count
{
    //将单价强制保留2为小数
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",price]];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    //将数量转化为计算类型
    NSDecimalNumber *prodcuctCount = [[NSDecimalNumber alloc] initWithInteger:count];
    
    //单价*数量
    NSDecimalNumber *afterDiscount = [roundedOunces decimalNumberByMultiplyingBy:prodcuctCount];//*
    //返回总价
    return afterDiscount;
}

#pragma mark - 获取阶梯价
/**
 *  根据数量计算产品对应的价格
 *
 *  @param count 产品数量
 *
 *  @return 产品单价
 */
- (float)getPriceWithModel:(OSellBuyCateModel *)model{
    float ProductPrice = 0.00f;
    if ([model.MinPrice floatValue] == [model.MaxPrice floatValue]) {
        ProductPrice = [model.MinPrice floatValue] ;
    }else{
        if (model.ProductPriceList && model.ProductPriceList.count>0) {
            for (NSDictionary *dic in model.ProductPriceList) {
                if ([dic objectForNotNullKey:@"MaxNum"]<[dic objectForNotNullKey:@"MinNum"]) {
                    if ([model.Count intValue]>=[[dic objectForNotNullKey:@"MinNum"] intValue]) {
                        ProductPrice = [[dic objectForNotNullKey:@"Price"] floatValue];
                    }
                }else{
                    if ([model.Count intValue]>=[[dic objectForNotNullKey:@"MinNum"] intValue]&&[model.Count intValue]<[[dic objectForNotNullKey:@"MaxNum"]intValue]) {
                        ProductPrice = [[dic objectForNotNullKey:@"Price"] floatValue];
                    }
                }
            }
        }else{
            ProductPrice = [model.MinPrice floatValue] ;
        }
    }
    return ProductPrice;
}


#pragma mark ------UIAlertViewDelegate-------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 8888) {
        NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
        [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
        [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
        NSString *address=[NSString stringWithFormat:@"%@OrderAbout/ClearTrolley",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [self.tableMain.header beginRefreshing];
            [DZProgress dismiss];
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[SilkLoginUserHelper shareInstance] cleanUserInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];
        
    }else if (buttonIndex == 1 && alertView.tag == 9999){
        NSString *strProductIDs = @"";
        for (int i =0;i<self.arrNormalProducts.count;i++) {
            OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
            if (model.isSelect) {
                if ([NSString isNullOrEmpty:strProductIDs]) {
                    strProductIDs=[strProductIDs stringByAppendingString:[NSString stringWithFormat:@"%@",model.ID]];
                }else{
                    strProductIDs=[strProductIDs stringByAppendingFormat:@",%@",[NSString stringWithFormat:@"%@",model.ID]];
                }
            }
        }
        if ([NSString isNullOrEmpty:strProductIDs]) {
            return;
        }
        NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
        [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
        [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
        [dictParams setValue:strProductIDs forKey:@"TrolleyIDList"];
        NSString *address=[NSString stringWithFormat:@"%@OrderAbout/DeleteTrolleyList",[[OSellServerHelper shareInstance] addressForBaseAPI]];
        [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
            [self.btnSettlement setSelected:NO];
            [self.btnCollection setHidden:YES];
            [self.lblAllMoneyTitle setHidden:NO];
            [self.lblAllMoneyValue setHidden:NO];
            //全部选中
            for (int i=0; i<self.arrNormalProducts.count; i++) {
                OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
                model.isSelect = NO;
                //[self.arrNormalProducts replaceObjectAtIndex:i withObject:model];
            }
            for (int i=0; i<self.arrStores.count; i++) {
                OSellBuyCateModel *model = [self.arrStores objectAtNotNullIndex:i];
                model.isAllSelect = NO;
                //[self.arrStores replaceObjectAtIndex:i withObject:model];
            }

            [self.tableMain.header beginRefreshing];
            [DZProgress dismiss];
        } andFailBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
            [self makeToast:apiResult.errorMsg];
        } andTimeOutBlock:^(OSellAPIResult *apiResult) {
            [DZProgress dismiss];
        } andLoginBlock:^(OSellAPIResult *apiResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [DZProgress dismiss];
                [[SilkLoginUserHelper shareInstance] cleanUserInfo];
                [[XmppHelper shareInstance] logout];
                self.tabBarController.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:YES];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                
            });
            
            
        }];
        

    }else{
        return;
    }
}
#pragma mark - 初始化数组
- (NSMutableArray *)arrProducts{
    if (!_arrProducts) {
        _arrProducts = [[NSMutableArray alloc] init];
    }
    return _arrProducts;
}
- (NSMutableArray *)arrNormalProducts{
    if (!_arrNormalProducts) {
        _arrNormalProducts = [[NSMutableArray alloc] init];
    }
    return _arrNormalProducts;
}
- (NSMutableArray *)arrInvalidProducts{
    if (!_arrInvalidProducts) {
        _arrInvalidProducts = [[NSMutableArray alloc] init];
    }
    return _arrInvalidProducts;
}
- (NSMutableArray *)arrStores{
    if (!_arrStores) {
        _arrStores = [[NSMutableArray alloc] init];
    }
    return _arrStores;
}
- (NSMutableArray *)arrSelectProducts{
    if (!_arrSelectProducts) {
        _arrSelectProducts = [[NSMutableArray alloc] init];
    }
    return _arrSelectProducts;
}
- (NSMutableArray *)arrCurrency{
    if (!_arrCurrency) {
        _arrCurrency = [[NSMutableArray alloc] init];
    }
    return _arrCurrency;
}
- (IBAction)btnCollectionAction:(id)sender {
    NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
    [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
    [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
    NSString *strProductIDs = @"";
    for (int i =0;i<self.arrNormalProducts.count;i++) {
        OSellBuyCateModel *model = [self.arrNormalProducts objectAtNotNullIndex:i];
        if (model.isSelect) {
            if ([NSString isNullOrEmpty:strProductIDs]) {
                strProductIDs=[strProductIDs stringByAppendingString:[NSString stringWithFormat:@"%@",model.ID]];
            }else{
                strProductIDs=[strProductIDs stringByAppendingFormat:@",%@",[NSString stringWithFormat:@"%@",model.ID]];
            }
        }
    }
    if ([NSString isNullOrEmpty:strProductIDs]) {
        return;
    }
    
    [dictParams setValue: strProductIDs forKey:@"TrolleyIDList"];
    NSString *address=[NSString stringWithFormat:@"%@ProductAbout/SetCollectProductList",[[OSellServerHelper shareInstance] addressForBaseAPI]];
    [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
        [self makeToast:[self getString:@"OSellBuyCateVC_Add to My Wish List Successful"]];
        [self.tableMain.header beginRefreshing];
        [DZProgress dismiss];
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
        
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        /// Token失败，需要重新登录
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [DZProgress dismiss];
            
            [[SilkLoginUserHelper shareInstance]cleanUserInfo];
            [[XmppHelper shareInstance] logout];
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
        });
    }];
}
- (IBAction)btnBrowseAction:(id)sender {
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (IBAction)btnLikeAction:(id)sender {
    OSellFavoriteProductListVC *vc = [[OSellFavoriteProductListVC alloc] init];
    [self pushController:vc];
}

#pragma mark - 更改进货单商品数量
- (void)editTrolleyCountWithID:(NSString *)TrolleyID andCount:(NSString *)count{
    NSMutableDictionary *dictParams = [[NSMutableDictionary alloc]init];
    [dictParams setValue: [[SilkLoginUserHelper shareInstance] getCurUserInfo].userId forKey: @"UserID"];
    [dictParams setValue: [InternationalizationHelper getLocalizeion] forKey: @"lan"];
    [dictParams setValue: TrolleyID forKey: @"TrolleyID"];
    [dictParams setValue: count forKey: @"Count"];
    NSString *address=[NSString stringWithFormat:@"%@OrderAbout/EditTrolleyCount",[[OSellServerHelper shareInstance] addressForBaseAPI]];
    [[OSellHTTPHelper shareInstance]requestHTTPDataWithAPI:address andParams:dictParams andSuccessBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
    } andFailBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
        [self makeToast:apiResult.errorMsg];
    } andTimeOutBlock:^(OSellAPIResult *apiResult) {
        [DZProgress dismiss];
    } andLoginBlock:^(OSellAPIResult *apiResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [DZProgress dismiss];
            [[SilkLoginUserHelper shareInstance] cleanUserInfo];
            [[XmppHelper shareInstance] logout];
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
        });
        
        
    }];
}
@end
