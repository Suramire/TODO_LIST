//
//  NotificationManager.m
//  app3
//
//  Created by Suramire on 2020/4/17.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import "NotificationManager.h"
#import <UserNotifications/UserNotifications.h>
#import "TodoItem.h"
@interface NotificationManager()<UNUserNotificationCenterDelegate>
@end

@implementation NotificationManager

//TODO 使用单例模式 delegate可以正常生效 普通初始化则不行
+ (NotificationManager *) shardManager{
    static NotificationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NotificationManager alloc] init];
    });
    return manager;
}

- (void) removeNotificationById:(NSString *)id{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center removePendingNotificationRequestsWithIdentifiers:@[id]];
}

- (void) sendNotificationWithTodoItem:(TodoItem *)todoItem{
    [self sendNotificationWithDateString:todoItem.date andContent:todoItem.content
                                   andId:todoItem.id];
}

- (void) sendNotificationWithDateString:(NSDate *)dateString andContent:(NSString *)mContent andId:(NSString *)id{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
    UNAuthorizationOptionSound |
    UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            //允许通知，构建通知内容
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
            content.title=@"提醒";
//            content.badge=@(1);
            content.body = mContent;
            content.sound = [UNNotificationSound defaultSound];
//            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.f repeats:NO];

            NSCalendar *calendar = [NSCalendar currentCalendar];
//
//            [calendar setTimeZone:[NSTimeZone systemTimeZone]];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy-MM-dd HH:mm";
//            [format setTimeZone:[NSTimeZone systemTimeZone]];
            NSDate *targetDate = [format dateFromString:dateString];

            NSDateComponents *components = [[NSDateComponents alloc] init];
            NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
            NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
            components = [calendar components:unitFlags fromDate:targetDate];
             
            
             UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:id content:content trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(error){
                    NSLog(@"错误:%@",error.domain);
                }
            }];
        }
    }];
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    //关键点 处理通知
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    
}

@end
