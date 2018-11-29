//
//  OSelectItemViewController.m
//  OSell
//
//  Created by xlg on 2018/1/5.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import "OSelectItemViewController.h"

#import "Masonry.h"
#import "OSelectItemCell.h"
#import "UIView+ConstraintExtension.h"
#import "NSString+Extension.h"

@interface OSelectItemViewController () <UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>
{
    UITableView *tabList;
    NSMutableDictionary *dictRed;
}

@property (assign, nonatomic) BOOL canScroll;

@end

@implementation OSelectItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutViews];
}

- (void)layoutViews {
    WS(weakSelf);
    tabList = [[UITableView alloc] init];
    tabList.backgroundColor = [UIColor clearColor];
    tabList.rowHeight = 45.0f;
    tabList.delegate = self;
    tabList.dataSource = self;
    tabList.scrollEnabled = self.canScroll;
    tabList.showsVerticalScrollIndicator = NO;
    tabList.showsHorizontalScrollIndicator = NO;
    tabList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tabList.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    tabList.separatorColor = [UIColor colorWithWhite:200.0/255.0 alpha:1.0];
    [self.view addSubview:tabList];
    [tabList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)setupRedDotWithDictIndexs:(NSDictionary *)dictIndexs {
    if (!dictRed) {
        dictRed = [NSMutableDictionary dictionary];
    }
    if ([dictIndexs isKindOfClass:[NSDictionary class]]) {
        [dictRed removeAllObjects];
        [dictRed addEntriesFromDictionary:dictIndexs];
        [tabList reloadData];
    }
}

#pragma mark - UITableView 
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"OSelectItemCell";
    OSelectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[OSelectItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSString *imageName = nil;
    NSString *title = [self.titles objectAtIndex:indexPath.row];
    if (indexPath.row < self.images.count) {
        imageName = [self.images objectAtIndex:indexPath.row];
    }
    [cell setupImage:imageName title:title];
    NSString *strValue = [dictRed stringForKey:title];
    if (strValue.integerValue > 0) {
        [cell showRedDotWithIsShow:YES];
    } else {
        [cell showRedDotWithIsShow:NO];
    }
    return cell;
}

//UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedBlock) {
        NSString *title = [self.titles objectAtIndex:indexPath.row];
        self.selectedBlock(indexPath.row, title);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
//UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone; 
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}


+ (instancetype)selectItemWithTitles:(NSArray *)titles sourceView:(UIView *)view block:(OSelectedItemBlock)block {
    return [self selectItemWithTitles:titles images:nil sourceView:view block:block];
}
+ (instancetype)selectItemWithTitles:(NSArray *)titles images:(NSArray *)images sourceView:(UIView *)view block:(OSelectedItemBlock)block {
    OSelectItemViewController *vc = [[OSelectItemViewController alloc] init];

    if ([titles isKindOfClass:[NSArray class]]) {
        vc.titles = titles;
    }
    if ([images isKindOfClass:[NSArray class]]) {
        vc.images = images;
    }
    vc.selectedBlock = block;

    CGFloat width = [NSString getMaxWidth:titles height:40 fontSize:15] + 40;
    if (vc.images.count > 0) {
        width = width + 35;
    }
    if (width < 120) {
        width = 120;
    }

    NSInteger count = vc.titles.count;
    if (count > 8) {
        vc.canScroll = YES;
        vc.preferredContentSize = CGSizeMake(width, (45 * 8) + 20);
    } else {
        vc.canScroll = NO;
        vc.preferredContentSize = CGSizeMake(width, (45 * count));
    }

    CGRect sRect = view.bounds;
    if (view.bounds.size.width > width) {
        sRect.origin.x = sRect.size.width/2.0 - width/2.0;
    }

    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = sRect;
    vc.popoverPresentationController.delegate = vc;
    return vc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


