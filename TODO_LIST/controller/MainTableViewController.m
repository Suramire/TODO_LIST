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

@property (strong, nonatomic,readwrite) UIRefreshControl *myrefreshControl;

@property (strong, nonatomic,readwrite) UILabel *loadMoreView;

@property (atomic,assign) BOOL isLoadingMore;

@property (atomic,assign) BOOL scrollManually;//手动滑动

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if(![ud boolForKey:@"mynotificationEnable"]){
        [[NotificationManager shardManager] requestAtBoot];
    }
//    self.data = [self readItem].mutableCopy;
    ///修改默认返回按钮
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"fanhui"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:nil action:nil];
    //返回按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor systemOrangeColor];
    //隐藏原来的返回按钮
    self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage new];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _myrefreshControl = [[UIRefreshControl alloc]init];
    _myrefreshControl.tintColor = [UIColor orangeColor];
    _myrefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [_myrefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView setRefreshControl:_myrefreshControl];
    _loadMoreView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    _loadMoreView.textAlignment = NSTextAlignmentCenter;
    _loadMoreView.text = @"正在加载更多";
    [self refreshData];
    
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
//    name:UIApplicationWillResignActiveNotification object:nil];
}

- (void) refreshData{
    if(_loadMoreView && _myrefreshControl.isRefreshing){
         [_myrefreshControl endRefreshing];
    }else{
        self.data = [self readItem].mutableCopy;
        if(self.data.count != 0){
            [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.5f];
        }
    }
}

- (void) stopRefresh{
    if(_myrefreshControl.isRefreshing){
        [_myrefreshControl endRefreshing];
    }
//    [self.tableView reloadData];
    [self showMessage:@"刷新成功"];
    [self checkEmpty];
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

#pragma mark 列表滑动时触发

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _scrollManually = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _scrollManually = NO;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [self.navigationController setNavigationBarHidden:velocity.y >0 animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    
    ///滑到底部并且没有在下拉刷新
    if(scrollView.contentOffset.y+scrollView.frame.size.height > scrollView.contentSize.height && _scrollManually && !_isLoadingMore){
        NSLog(@"上拉加载更多");
        self.tableView.tableFooterView = _loadMoreView;
        _isLoadingMore = true;
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:3];
        
    }
    
}

#pragma mark 加载更多
-(void) loadMoreData{
    if(self.data.count<=17){
        //新建待办
           TodoItem *newItem = [TodoItem new];
           newItem.content = @"新项目";
           newItem.date = @"xxxx";
           [self.data addObject:newItem];
           [self.data addObject:newItem];
           [self.data addObject:newItem];
           [self.data addObject:newItem];
           [self.data addObject:newItem];
           [self.tableView reloadData];
           self.tableView.tableFooterView = nil;
           _isLoadingMore = false;
    }else{
        _loadMoreView.text = @"没有更多数据";
        self.tableView.tableFooterView = _loadMoreView;
    }
    
   
}



- (void)viewDidAppear:(BOOL)animated{
   
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
     [self checkEmpty];
    
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

#pragma mark 点击事件

- (IBAction)newClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"goDetail" sender:nil];
    
}

- (IBAction)settingClicked:(id)sender {
    NSLog(@"点击设置");

}


#pragma mark Table view data source

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
//        CGFloat navigationBarAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
//        emptyView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarAndStatusBarHeight);
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
