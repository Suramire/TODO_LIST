//
//  TodoItem.m
//  TODO_LIST
//
//  Created by Suramire on 2020/4/20.
//  Copyright © 2020 Suramire. All rights reserved.
//

#import "TodoItem.h"

@implementation TodoItem

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.id forKey:@"id"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.isDone forKey:@"isDone"];
    [coder encodeObject:self.date forKey:@"date"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if(self){
        self.id = [coder decodeObjectForKey:@"id"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.isDone = [coder decodeBoolForKey:@"isDone"];
        self.date = [coder decodeObjectForKey:@"date"];
    }
    return self;
}

+(BOOL) supportsSecureCoding {
    return YES;
}


@end
