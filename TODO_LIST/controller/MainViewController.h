//
//  MainViewController.h
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TodoItem;
NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController


@property(nonatomic,readwrite)TodoItem *todoItem;

@end

NS_ASSUME_NONNULL_END
