//
//  NSArray+CHCollectionUtils.m
//  ChappySDK
//
//  Created by E.J. Mablekos on 1/13/14.
//  Copyright (c) 2014 Chappy. All rights reserved.
//

#import "NSArray+CHCollectionUtils.h"


@implementation NSArray (CHCollectionUtils)
- (NSArray *)CH_map:(id (^)(id obj))block {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        id result = block(object);
        if (result)
            [resultArray addObject:result];
    }
    return [resultArray copy];
}

- (NSArray *)CH_filter:(BOOL (^)(id obj))block {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        BOOL result = block(object);
        if (result)
            [resultArray addObject:object];
    }
    return [resultArray copy];
}

- (NSArray *)CH_flatten {
    NSMutableArray *arr = [NSMutableArray array];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]]) {
            [arr addObjectsFromArray:[(NSArray *)object CH_flatten]];
        } else {
            [arr addObject:object];
        }
    }
    return [arr copy];
}

- (id)CH_reduce:(id (^)(id result, id obj))block {
    id result;
    for (id object in self) {
        result = block(result, object);
    }
    return result;
}

- (NSDictionary *)CH_indexToKeys:(id<NSCopying> (^)(id obj))block {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id object in self) {
        id<NSCopying> key = block(object);
        if (key)
            [result setObject:object forKey:key];
    }
    return [result copy];
}

- (NSArray *)CH_shuffle {

    NSMutableArray *arr = [self mutableCopy];

    NSUInteger count = [arr count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [arr exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }

    return arr;
}

@end
