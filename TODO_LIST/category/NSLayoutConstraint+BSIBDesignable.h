//
//  NSLayoutConstraint+BSIBDesignable.h
//  App5
//
//  Created by Suramire on 2020/4/28.
//  Copyright © 2020 Suramire. All rights reserved.
//


#import <UIKit/UIKit.h>
// 基准屏幕宽度
#define kRefereWidth 375.0
// 以屏幕宽度为固定比例关系，来计算对应的值。假设：基准屏幕宽度375，floatV=10；当前屏幕宽度为750时，那么返回的值为20
#define AdaptW(floatValue) (floatValue*[[UIScreen mainScreen] bounds].size.width/kRefereWidth)


NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraint (BSIBDesignable)

@property(nonatomic, assign) IBInspectable BOOL adapterScreen;

@end

NS_ASSUME_NONNULL_END
