//
//  OSelectItemViewController.h
//  OSell
//
//  Created by xlg on 2018/1/5.
//  Copyright © 2018年 OSellResuming. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^OSelectedItemBlock)(NSInteger index, NSString *title);


@interface OSelectItemViewController : UIViewController

@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *images;
@property (copy, nonatomic) OSelectedItemBlock selectedBlock;



- (void)setupRedDotWithDictIndexs:(NSDictionary *)dictIndexs;


+ (instancetype)selectItemWithTitles:(NSArray *)titles sourceView:(UIView *)view block:(OSelectedItemBlock)block;

+ (instancetype)selectItemWithTitles:(NSArray *)titles images:(NSArray *)images sourceView:(UIView *)view block:(OSelectedItemBlock)block;


@end


