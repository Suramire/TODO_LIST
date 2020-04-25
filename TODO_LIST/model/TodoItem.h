//
//  TodoItem.h
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TodoItem : NSObject<NSSecureCoding>
//id
@property NSString *id;
//待办内容
@property NSString *content;
//时间
//TODO 使用NSDate类型保存不成文件
@property NSString *date;
//是否完成
@property BOOL isDone;

@end



NS_ASSUME_NONNULL_END
