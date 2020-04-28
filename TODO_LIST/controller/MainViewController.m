//
//  MainViewController.m
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import "MainViewController.h"
#import "MainTableViewController.h"
#import "TodoItem.h"
@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textViewContent;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDelete;
@property(nonatomic,strong) UIDatePicker *datePicker;

@property BOOL isDateModified;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnDelete.enabled = self.todoItem ==nil;
    //初始化datePicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [NSDate date];
    self.textFieldDate.inputView = self.datePicker;
    [self.datePicker addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    //初始化文本
    if(self.todoItem != nil){
        self.textViewContent.text = self.todoItem.content;
        self.textFieldDate.text = self.todoItem.date;
    }else{
        //默认给一个时间
        self.textFieldDate.text = [self fmDateString:self.datePicker.date];
    }

}

//日期选择变化
- (void)valueChange:(UIDatePicker *)datePicker{
    NSLog(@"datePicker的时间 = %@" ,datePicker.date);
    ///todo 日期变化后移除旧通知，同时修改id
    self.textFieldDate.text = [self fmDateString:datePicker.date];
    self.isDateModified = YES;
}

/// 格式化日期字符串
- (NSString *) fmDateString:(NSDate *) date{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    //设置日期的显示格式
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    [fmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //将日期转为指定格式显示
    NSString *dateStr = [fmt stringFromDate:[self getRealDate:date]];
    return dateStr;
}

- (IBAction)deleteClick:(id)sender {
    self.textViewContent.text = nil;
}

//返回首页时的操作
-(void)viewWillDisappear:(BOOL)animated{
    if(self.textViewContent.text.length == 0){
        return;
    }
    MainTableViewController *controller =  [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count -1];
    if(self.todoItem){
        //从首页进来编辑
        self.todoItem.content = self.textViewContent.text;
        if(self.isDateModified){
            self.todoItem.date = [self fmDateString:self.datePicker.date];
        }
        controller.isNewTodo = NO;
        controller.todoItem = self.todoItem;
        
    }else{
        //新建待办
        TodoItem *newItem = [TodoItem new];
        newItem.content = self.textViewContent.text;
        newItem.date = [self fmDateString:self.datePicker.date];
        controller.todoItemNew = newItem;
        controller.isNewTodo = YES;
    }

}

/// 将获取的零时区时间转换成北京时间
-(NSDate *) getRealDate:(NSDate *) inDate{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSTimeInterval interval = [zone secondsFromGMTForDate:inDate];
    NSDate *current = [inDate dateByAddingTimeInterval:interval];
    return current;
}



@end
