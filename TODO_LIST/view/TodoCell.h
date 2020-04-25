//
//  TodoCell.h
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TodoCell : UITableViewCell
//选择框
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
//待办标题
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
//待办日期时间
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@end

NS_ASSUME_NONNULL_END
