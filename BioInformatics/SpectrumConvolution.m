//
//  SpectrumConvolution.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/23/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "SpectrumConvolution.h"

@interface SpectrumConvolution()
@property (nonatomic) NSMutableDictionary *counts;
@end

@implementation SpectrumConvolution

- (instancetype)init {
    self = [super init];
    if (self) {
        self.counts = [NSMutableDictionary dictionary];
        self.min = 1;
        self.max = NSIntegerMax;
    }
    return self;
}

- (void)calculate:(NSArray *)spectrum {

    [self.counts removeAllObjects];

    for (NSNumber *x in spectrum) {
        for (NSNumber *y in spectrum) {
            int val = [y intValue] - [x intValue];
            if (val >= self.min && val <= self.max) {
                self.counts[@(val)] = @([(self.counts[@(val)] ?: @0) intValue] + 1);
            }
        }
    }

}

- (NSString *)stringValue {

    NSMutableString *str = [NSMutableString string];

    for (NSNumber *key in self.counts) {
        int count = [self.counts[key] intValue];
        for (int j = 0; j < count; ++j) {
            [str appendFormat:@"%@ ", key];
        }
    }

    if (str.length == 0)
        return @"";

    return [str substringToIndex:str.length-1];
}

- (NSArray *)elements {

    NSMutableArray *arr = [NSMutableArray array];

    for (NSNumber *key in self.counts) {
        int count = [self.counts[key] intValue];
        for (int j = 0; j < count; ++j) {
            [arr addObject:key];
        }
    }

    return [arr copy];
}

- (NSArray *)mostFrequentElements:(int)count {

    NSMutableArray *arr = [NSMutableArray array];

    NSArray *values = [self.counts allValues];
    values = [values sortedArrayUsingSelector:@selector(compare:)];
    values = [values.reverseObjectEnumerator allObjects];

    int score = [values[MIN(values.count-1, count-1)] intValue];

    for (NSNumber *key in self.counts) {
        if ([self.counts[key] intValue] >= score) {
            [arr addObject:key];
        }
    }

    return [arr copy];
}


@end
