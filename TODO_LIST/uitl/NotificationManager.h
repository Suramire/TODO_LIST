//
//  NotificationManager.h
//  app3
//
//  Created by Suramire on 2020/4/17.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TodoItem;
NS_ASSUME_NONNULL_BEGIN

@interface NotificationManager : NSObject

+ (NotificationManager *) shardManager;

- (void) removeNotificationById:(NSString *)id;

- (void) sendNotificationWithDateString:(NSDate *)dateString andContent:(NSString *)content andId:(NSString *)id;

- (void) sendNotificationWithTodoItem:(TodoItem *)todoItem;

- (void) requestAtBoot;

@end

NS_ASSUME_NONNULL_END
