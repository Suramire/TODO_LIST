//
//  MainTableViewController.m
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//
#define PName @"todoItems"
#import "MainTableViewController.h"
#import "MainViewController.h"
#import "TodoCell.h"
#import "TodoItem.h"
#import "NotificationManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MainTableViewController ()
//待办列表
@property (strong, nonatomic,readwrite) NSMutableArray *data;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [self readItem].mutableCopy;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView reloadData];
    
    [self checkEmpty];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
//    name:UIApplicationWillResignActiveNotification object:nil];
   
    

    
}

- (void) showMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.2];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

//- (void)applicationWillResignActive:(NSNotification *)notification{
//
//}



- (void)viewDidAppear:(BOOL)animated{
//    [self checkEmpty];
    if(self.isNewTodo){
        self.todoItemNew.id = [NSString stringWithFormat:@"id_%@",self.todoItemNew.date];
        NSLog(@"id=%@",self.todoItemNew.id);
        [self.data addObject:self.todoItemNew];
        [self.tableView reloadData];
        self.isNewTodo = NO;
//        [self writeItem:self.todoItem];
        [self showMessage:@"添加成功"];
        [[NotificationManager shardManager] sendNotificationWithTodoItem:self.todoItemNew];
        [self writeAll:self.data];
//        self.todoItem = nil;
    }else{
        if(self.todoItem != nil){
            for(int i=0;i<self.data.count;i++){
                       TodoItem *item = self.data[i];
                if([self.todoItem.id isEqualToString: item.id]){
                    if(![item.date isEqualToString:self.todoItem.date]){
                        //如果是修改了待办的时间，则取消之前的通知
                        [[NotificationManager shardManager] removeNotificationById:item.id];
                        
                        //日期变化生成新id
                        self.todoItem.id = [NSString stringWithFormat:@"id_%@",self.todoItemNew.date];
                        //设置新的通知时间
                        if(!self.todoItem.isDone){
                             [[NotificationManager shardManager] sendNotificationWithTodoItem:self.todoItem];
                        }
                       
                    }
                           self.data[i] = self.todoItem;
                           [self.tableView reloadData];
                           break;
                       }
           }
            [self writeAll:self.data];
        }
       
    }
    
}
//写入所有数据
-(void) writeAll:(NSArray *) items{
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [pathArray firstObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"todo"];
    NSFileManager *fm = [NSFileManager defaultManager];
//    NSMutableArray *array = [self readItem];
//    [array addObject:item];
    if(items.count <=0){
        [fm removeItemAtPath:filePath error:nil];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items requiringSecureCoding:YES error:nil];
    [fm createFileAtPath:filePath contents:data attributes:nil];
    
}


//写入单个数据
-(void) writeItem:(TodoItem *) item{
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [pathArray firstObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"todo"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *array = [[self readItem] mutableCopy];
    [array addObject:item];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array requiringSecureCoding:YES error:nil];
    [fm createFileAtPath:filePath contents:data attributes:nil];
}
//读取所有数据
-(NSArray *) readItem {
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [pathArray firstObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"todo"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //第一次返回空
    if(![fm fileExistsAtPath:filePath]){
        NSArray *array = [NSArray array];
        return array;
    }
//    else{
//        [fm removeItemAtPath:filePath error:nil];
//    }
    NSMutableArray *array = [NSMutableArray array];
//    [array addObject:item];
    
    NSData *data = [fm contentsAtPath:filePath];
    
    array = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class],[TodoItem class] ,nil]  fromData:data error:nil];
    if(array == nil){
        array = [NSMutableArray array];
    }
    return array;
}

- (IBAction)newClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"goDetail" sender:nil];
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.data.count;
}

///空视图
- (void) checkEmpty{
    if(self.data.count == 0){
        //没有待办
        UIView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyView" owner:nil options:nil] firstObject];
        CGFloat navigationBarAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        emptyView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarAndStatusBarHeight);
        self.tableView.tableHeaderView = emptyView;
        self.tableView.userInteractionEnabled = NO;
    }else{
        self.tableView.tableHeaderView = nil;
        self.tableView.userInteractionEnabled = YES;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoItem *item = [self.data objectAtIndex:indexPath.row];
    TodoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodoCellx" forIndexPath:indexPath];
    [cell.checkBtn setImage:[UIImage imageNamed:item.isDone?@"ic_check_true":@"ic_check_false"] forState:UIControlStateNormal];
    cell.labelTitle.textColor = item.isDone? [UIColor grayColor]:[UIColor blackColor];
    cell.labelTitle.text = item.content;
    cell.labelDate.text = [NSString stringWithFormat:@"%@",item.date];
//    cell.checkBtn.tag = indexPath.row;
    [cell.checkBtn addTarget:self action:@selector(toggleCheckbox: event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    TodoItem *item = [self.data objectAtIndex:indexPath.row];
    ///这里直接传item的话会导致从详情页回来后self.data对应元素改变
    TodoItem *newItem = [TodoItem new];
    newItem.content = item.content;
    newItem.id = item.id;
    newItem.date = item.date;
    newItem.isDone = item.isDone;
    [self performSegueWithIdentifier:@"goDetail" sender:newItem];
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    TodoItem *item = [self.data objectAtIndex:indexPath.row];
    [[NotificationManager shardManager ] removeNotificationById:item.id];
    [self.data removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    [self writeAll:self.data];
    //TODO 编写只删除一条数据的方法
//    [self checkEmpty];
    //TODO 删除对应的通知 只刷新一行 确认删除
    //TODO 修改日期的待办 判断是否标记已完成
    
}

-(void) toggleCheckbox:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    TodoItem *item = [self.data objectAtIndex:indexPath.row];
    if(item.isDone){
        item.isDone = NO;
        [[NotificationManager shardManager]sendNotificationWithTodoItem:item];
    }else{
        item.isDone = YES;
        AudioServicesPlaySystemSound(1004);
        [[NotificationManager shardManager ] removeNotificationById:item.id];
    }
    [self writeAll:self.data];
    if(indexPath != nil){
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"goDetail"]){
        MainViewController *controller =  segue.destinationViewController;
        controller.todoItem = sender;
    }
}






@end
