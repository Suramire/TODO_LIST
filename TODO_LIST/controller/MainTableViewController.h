//
//  MainTableViewController.h
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TodoItem;

@interface MainTableViewController : UITableViewController

@property(nonatomic,assign)BOOL isNewTodo;

@property(nonatomic,readwrite)TodoItem *todoItem;

@property(nonatomic,readwrite)TodoItem *todoItemNew;

@end

NS_ASSUME_NONNULL_END
