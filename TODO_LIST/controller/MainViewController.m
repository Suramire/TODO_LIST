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
#import <CoreLocation/CoreLocation.h>
@interface MainViewController () <CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textViewContent;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDelete;
@property(nonatomic,strong) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imagePick;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@property CLLocationManager *locationManager;

@property BOOL isDateModified;
@end

@implementation MainViewController

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
//
//
//    NSLog(@"%@",[NSString stringWithFormat:@"%lf", newLocation.coordinate.latitude]);
//
//    self.title = [NSString stringWithFormat:@"%lf", newLocation.coordinate.latitude];
//
//}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@",[locations lastObject]);
    CLLocation *lastLocation =[locations lastObject];
    [_locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *mark = [placemarks firstObject];
        NSLog(@"%@",mark);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _locationManager = [[CLLocationManager alloc] init];
//    _locationManager.delegate = self;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    _locationManager.distanceFilter = kCLDistanceFilterNone;
//    [_locationManager requestAlwaysAuthorization];
//     [_locationManager startUpdatingLocation];
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
    
    [_imagePick addGestureRecognizer: _tapGestureRecognizer];

}

- (IBAction)pickImage:(id)sender {
    NSLog(@"pick");
    //调用系统相册的类
      UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
      //设置选取的照片是否可编辑
      pickerController.allowsEditing = NO;
      //设置相册呈现的样式
      pickerController.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
      //照片的选取样式还有以下两种
      //UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
      //UIImagePickerControllerSourceTypeCamera//调取摄像头
      
      //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
      pickerController.delegate = self;
      //使用模态呈现相册
      [self.navigationController presentViewController:pickerController animated:YES completion:^{
    
      }];
    
}


//日期选择变化
- (void)valueChange:(UIDatePicker *)datePicker{
    NSLog(@"datePicker的时间 = %@" ,datePicker.date);
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

#pragma mark 选择图片delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
//    NSLog(@"%@",info);
    _imagePick.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
/// 取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



@end
