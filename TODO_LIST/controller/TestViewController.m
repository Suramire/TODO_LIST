//
//  TestViewController.m
//  TODO_LIST
//
//  Created by Suramire on 2020/5/8.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController () <UISearchBarDelegate>


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _searchBar.prompt = @"搜索热门内容";
    UISearchBar * bar = [[UISearchBar alloc]initWithFrame:CGRectMake(0 , 88, self.view.frame.size.width, 40)];
    [self.view addSubview:bar];
//    bar.prompt = @"搜索框";
    bar.placeholder = @"hello";
    bar.delegate = self;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"text=%@",searchText);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
