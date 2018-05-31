//
//  OSilkChainViewController.m
//  OSell
//
//  Created by xlg on 2018/5/30.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSilkChainViewController.h"

#import "OSilkChainListModel.h"
#import "OSilkChainCell.h"
#import "OSilkChainHeaderView.h"

#import "OSilkApplyForDeveloperVC.h"

@interface OSilkChainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGFloat itemWidth;
    CGFloat itemHeight1;
    CGFloat itemHeight2;
    NSMutableArray *arrList;
}

@end

@implementation OSilkChainViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self getString:@"SILKCHAIN"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    itemWidth = (SCREEN_WIDTH - 3) / 3.0;
    itemHeight1 = 100.0;
    itemHeight2 = 140.0;
    if (itemHeight1 > (itemWidth + 15)) {
        itemHeight1 = itemWidth + 15;
    }
    if (itemHeight2 > (itemWidth + 15)) {
        itemHeight2 = itemWidth + 15;
    }
    arrList = [NSMutableArray array];
    
    OSilkChainModel *model00 = [OSilkChainModel modelWithType:@"0" title:@"Red Packet" imageUrl:@"silk_red_packet"];
    OSilkChainModel *model01 = [OSilkChainModel modelWithType:@"1" title:@"Silk Ads" imageUrl:@"silk_silk_ads"];
    OSilkChainModel *model02 = [OSilkChainModel modelWithType:@"2" title:@"Lucky Shopping" imageUrl:@"silk_lucky_shopping"];
    OSilkChainModel *model03 = [OSilkChainModel modelWithType:@"3" title:@"Distribution" imageUrl:@"silk_distribution"];
    OSilkChainModel *model04 = [OSilkChainModel modelWithType:@"4" title:@"Groupbuy" imageUrl:@"silk_group_buy"];
    OSilkChainListModel *model0 = [OSilkChainListModel modelWithTitle:@"Recommendation" imageUrl:@"SILKCHAIN_reco"];
    [model0.arrModels addObjectsFromArray:@[model00, model01, model02, model03, model04]];
    
    OSilkChainModel *model10 = [OSilkChainModel modelWithType:@"100" title:@"Roulette" imageUrl:@"SILKCHAIN-roulette"];
    OSilkChainModel *model11 = [OSilkChainModel modelWithType:@"101" title:@"Chartbet" imageUrl:@"SILKCHAIN-chartbet"];
    OSilkChainListModel *model1 = [OSilkChainListModel modelWithTitle:@"Amusements" imageUrl:@"SILKCHAIN_amusements"];
    [model1.arrModels addObjectsFromArray:@[model10, model11]];
    
    OSilkChainModel *model20 = [OSilkChainModel modelWithType:@"1000" title:@"SE-Saler" imageUrl:@"SILKCHAIN_sesaler"];
    OSilkChainModel *model21 = [OSilkChainModel modelWithType:@"1001" title:@"Distribution" imageUrl:@"SILKCHAIN_distribution"];
    OSilkChainModel *model22 = [OSilkChainModel modelWithType:@"1002" title:@"Oconnect" imageUrl:@"SILKCHAIN_oconnect"];
    OSilkChainModel *model23 = [OSilkChainModel modelWithType:@"1003" title:@"SE-Buyer" imageUrl:@"SILKCHAIN_se_buyer"];
    OSilkChainModel *model24 = [OSilkChainModel modelWithType:@"1004" title:@"OC-Saler" imageUrl:@"SILKCHAIN_ocsaler"];
    OSilkChainModel *model25 = [OSilkChainModel modelWithType:@"1005" title:@"SE-Inventory" imageUrl:@"SILKCHAIN_se_invertory"];
    OSilkChainListModel *model2 = [OSilkChainListModel modelWithTitle:@"Recommendation" imageUrl:@"SILKCHAIN_ecommerce"];
    [model2.arrModels addObjectsFromArray:@[model20, model21, model22, model23, model24, model25]];
    [arrList addObjectsFromArray:@[model0, model1, model2]];
}
//设置UI
- (void)layoutViews {
    [self.collList registerClass:[OSilkChainCell class] forCellWithReuseIdentifier:@"OSilkChainCell"];
    [self.collList registerClass:[OSilkChainHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OSilkChainHeaderView"];
    [self adjustmentEmptyViewHeight];
    
    CGFloat collHeight = 0;
    for (NSInteger i = 0; i < arrList.count; i++) {
        collHeight = collHeight + 54.0;
        OSilkChainListModel *model = [arrList objectAtIndex:i];
        NSInteger line = model.arrModels.count / 3;
        if (model.arrModels.count % 3 != 0) {
            line = line + 1;
        }
        if ([model.title isEqualToString:@"Amusements"]) {
            collHeight = collHeight + line * itemHeight2;
        } else {
            collHeight = collHeight + line * itemHeight1;
        }
    }
    self.collListHeight.constant = collHeight;
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
//点击申请成为开发者
- (IBAction)tapToApplyForDeveloperAction:(UITapGestureRecognizer *)sender {
    OSilkApplyForDeveloperVC *vc = [OSilkApplyForDeveloperVC new];
    [self pushController:vc];
}

#pragma mark - 协议
//UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return arrList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    OSilkChainListModel *model = [arrList objectAtIndex:section];
    return model.arrModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSilkChainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSilkChainCell" forIndexPath:indexPath];
    OSilkChainListModel *models = [arrList objectAtIndex:indexPath.section];
    OSilkChainModel *model = [models.arrModels objectAtIndex:indexPath.item];
    [cell setupSilkChainInfo:model];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    OSilkChainHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OSilkChainHeaderView" forIndexPath:indexPath];
    OSilkChainListModel *models = [arrList objectAtIndex:indexPath.section];
    [header setupTitle:models.title imageName:models.imageUrl];
    return header;
}

//UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

//UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    OSilkChainListModel *models = [arrList objectAtIndex:indexPath.section];
    if ([models.title isEqualToString:@"Amusements"]) {
        return CGSizeMake(itemWidth, itemHeight2);
    }
    return CGSizeMake(itemWidth, itemHeight1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 54.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


