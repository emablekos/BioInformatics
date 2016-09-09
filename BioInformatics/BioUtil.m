//
//  BioUitl.m
//  BioHomework
//
//  Created by E.J. Mablekos on 8/1/16.
//

#import "BioUtil.h"
#import "NSArray+CHCollectionUtils.h"

@implementation BioUtil

+ (NSInteger)PatternCount:(NSString *)text pattern:(NSString *)pattern {

    int count = 0;

    for (int i = 0; i <= text.length - pattern.length; ++i) {
        if ([[text substringWithRange:NSMakeRange(i, pattern.length)] isEqualToString:pattern]) {
            count++;
        }
    }

    return count;
}

+ (NSArray *)FrequentWords:(NSString *)text length:(int)length min:(int)min {
    NSMutableSet *fwords = [NSMutableSet set];
    NSMutableArray *counts = [NSMutableArray array];

    for (int i = 0; i <= text.length - length; ++i) {
        NSString *pat = [text substringWithRange:NSMakeRange(i, length)];
        NSInteger count = [self PatternCount:text pattern:pat];
        counts[i] = @(count);
    }

    NSInteger max = min;
    for (NSNumber *c in counts) {
        if (c.integerValue > max) {
            max = c.integerValue;
        }
    }

    for (int i = 0; i < counts.count; ++i) {
        NSInteger c = [counts[i] integerValue];
        if (c == max) {
            [fwords addObject:[text substringWithRange:NSMakeRange(i, length)]];
        }
    }

    return [fwords allObjects];
}

+ (NSString *)reverseCompliment:(NSString *)original {

    NSMutableString *res = [NSMutableString stringWithCapacity:original.length];

    const char *g = [original UTF8String];

    for (long long i = original.length-1; i >= 0; --i) {
        char c = g[i];

        if (c == 'C') {
            [res appendString:@"G"];
        } else if (c == 'G') {
            [res appendString:@"C"];
        } else if (c == 'A') {
            [res appendString:@"T"];
        } else if (c == 'T') {
            [res appendString:@"A"];
        }
    }

    return [res copy];
}

+ (NSArray *)locsOfPattern:(NSString *)pattern genome:(NSString *)genome {
    NSMutableArray *res = [NSMutableArray array];

    for (int i = 0; i < genome.length - pattern.length; ++i) {
        NSString *sub = [genome substringWithRange:NSMakeRange(i, pattern.length)];

        if ([sub isEqualToString:pattern]) {
            [res addObject:@(i)];
        }
    }

    return [res copy];
}

+ (NSArray *)clumpsIn:(NSString *)text k:(int)k t:(int)t l:(int)l {

    NSMutableSet *mers = [NSMutableSet set];

    for (int i = 0; i < text.length - l; i++) {

        NSMutableDictionary *counts = [NSMutableDictionary dictionary];

        for (int j = 0; j < l-k; ++j) {
            NSString *kmer = [text substringWithRange:NSMakeRange(i+j, k)];
            NSNumber *count = [counts objectForKey:kmer];
            if (!count)
                count = @(0);

            count = @(count.intValue + 1);
            counts[kmer] = count;
        }

        for (NSString *kmer in counts) {
            if ([counts[kmer] intValue] >= t) {
                [mers addObject:kmer];
            }
        }

    }

    return [mers allObjects];
}


+ (NSString *)numberToPattern:(unsigned long long)num k:(int)k {

    if (k == 1) {
        return [self numberToSymbol:(int)num];
    }

    unsigned long long prei = num / 4;
    int r = num % 4;

    NSString *s = [self numberToPattern:prei k:k-1];
    s = [s stringByAppendingString:[self numberToSymbol:r]];

    return s;
}

+ (unsigned long long)patternToNumber:(NSString *)pattern {

    if (pattern.length == 0) {
        return 0;
    }

    if (pattern.length == 1) {
        return [self symbolToNumber:pattern];
    }

    NSString *sym = [pattern substringFromIndex:pattern.length-1];
    NSString *pre = [pattern substringToIndex:pattern.length-1];

    return 4 * [self patternToNumber:pre] + [self symbolToNumber:sym];
}

+ (unsigned long long)symbolToNumber:(NSString *)symbol {
    if ([symbol isEqualToString:@"A"])
        return 0;
    else if ([symbol isEqualToString:@"C"])
        return 1;
    else if ([symbol isEqualToString:@"G"])
        return 2;
    else if ([symbol isEqualToString:@"T"])
        return 3;

    NSAssert(NO, @"Bad symbol");

    return 0;
}

+ (NSString *)numberToSymbol:(unsigned int)n {
    switch (n) {
        case 0:
            return @"A";
            break;
        case 1:
            return @"C";
            break;
        case 2:
            return @"G";
            break;
        case 3:
            return @"T";
            break;

        default:
            break;
    }

    NSAssert(NO, @"Bad symbol");

    return 0;
}

+ (NSArray *)frequencyArray:(NSString *)text k:(int)k {

    unsigned long long kpow = pow(4, k);
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:kpow];

    for (unsigned long long i = 0; i < kpow; ++i) {
        a[i] = @0;
    }

    for (unsigned long long i = 0; i <= text.length - k; ++i) {
        NSString *p = [text substringWithRange:NSMakeRange(i, k)];
        unsigned long long j = [self patternToNumber:p];
        a[j] = @([a[j] intValue] + 1);
    }

    return a;
}

+ (NSArray *)minimumSkewPositions:(NSString *)text {
    NSMutableArray *arr = [NSMutableArray array];
    long currentSkew = 0;
    long minSkew = 0;

    const char *g = [text UTF8String];

    for (unsigned long long i = 0; i < text.length; ++i) {
        char c = g[i];

        if (c == 'G') {
            currentSkew++;
        } else if (c == 'C') {
            currentSkew--;
        }

        if (currentSkew == minSkew) {
            [arr addObject:@(i+1)];
        } else if (currentSkew < minSkew) {
            [arr removeAllObjects];
            [arr addObject:@(i+1)];
            minSkew = currentSkew;
        }
    }

    return [arr copy];
}

+ (unsigned int)hammingDistance:(NSString *)a other:(NSString *)b {
    const char *ca = [a UTF8String];
    const char *cb = [b UTF8String];

    unsigned int dist = 0;

    for (unsigned long long i = 0; i < a.length; ++i) {
        if (ca[i] != cb[i]) {
            dist++;
        }
    }

    return dist;
}

+ (NSArray *)approximatePatternMatch:(NSString *)text pattern:(NSString *)pattern distance:(unsigned int)distance {

    NSMutableArray *arr = [NSMutableArray array];

    for (unsigned long long i = 0; i <= text.length - pattern.length; ++i) {
        unsigned int dist = [self hammingDistance:pattern other:[text substringWithRange:NSMakeRange(i, pattern.length)]];

        if (dist <= distance) {
            [arr addObject:@(i)];
        }
    }

    return [arr copy];
}

+ (unsigned int)approximatePatternCount:(NSString *)text pattern:(NSString *)pattern distance:(unsigned int)distance {

    unsigned int count = 0;

    for (unsigned long long i = 0; i <= text.length - pattern.length; ++i) {
        unsigned int dist = [self hammingDistance:pattern other:[text substringWithRange:NSMakeRange(i, pattern.length)]];

        if (dist <= distance) {
            count++;
        }
    }

    return count;
}

+ (NSArray *)neighbors:(NSString *)pattern distance:(int)distance {

    NSArray *nucs = @[@"A", @"C", @"G", @"T"];

    if (distance == 0) {
        return @[pattern];
    }

    if (pattern.length == 1) {
        return [nucs copy];
    }

    NSMutableSet *neighborhood = [NSMutableSet set];
    NSArray *sufHood = [self neighbors:[pattern substringFromIndex:1] distance:distance];

    for (NSString *s in sufHood) {
        unsigned int d = [self hammingDistance:s other:[pattern substringFromIndex:1]];
        if (d < distance) {
            for (NSString *n in nucs) {
                [neighborhood addObject:[n stringByAppendingString:s]];
            }
        } else {
            [neighborhood addObject:[[pattern substringWithRange:NSMakeRange(0, 1)] stringByAppendingString:s]];
        }
    }

    return [neighborhood allObjects];
}

+ (NSArray *)frequentWordsWithMismatches:(NSString *)text k:(int)k d:(int)d {
    return [self frequentWordsWithMismatches:text k:k d:d reverse:NO];
}

+ (NSArray *)frequentWordsWithMismatches:(NSString *)text k:(int)k d:(int)d reverse:(BOOL)reverse {

    unsigned long long kpow = pow(4, k);
    NSMutableArray *freq = [NSMutableArray arrayWithCapacity:kpow];
    NSMutableArray *close = [NSMutableArray arrayWithCapacity:kpow];
    NSMutableArray *result = [NSMutableArray array];

    for (unsigned long long i = 0; i < kpow; ++i) {
        freq[i] = @0;
        close[i] = @0;
    }

    for (unsigned long long i = 0; i < text.length - k; ++i) {
        NSString *pat = [text substringWithRange:NSMakeRange(i, k)];
        NSMutableSet *hood = [NSMutableSet set];
        [hood addObjectsFromArray:[self neighbors:pat distance:d]];

        if (reverse) {
            NSString *revpat = [self reverseCompliment:pat];
            [hood addObjectsFromArray:[self neighbors:revpat distance:d]];
        }

        for (NSString *nbr in hood) {
            unsigned long long idx = [self patternToNumber:nbr];
            close[idx] = @1;
        }
    }

    for (unsigned long long i = 0; i < kpow; ++i) {
        if ([close[i] isEqual:@1]) {
            NSString *pat = [self numberToPattern:i k:k];

            unsigned int cnt = [self approximatePatternCount:text pattern:pat distance:d];

            if (reverse) {
                NSString *revpat = [self reverseCompliment:pat];
                if (![revpat isEqualToString:pat])
                    cnt += [self approximatePatternCount:text pattern:revpat distance:d];
            }

            freq[i] = @(cnt);
        }
    }

    long max = 0;
    for (NSNumber *n in freq) {
        if ([n intValue] > max) {
            max = [n intValue];
        }
    }

    for (unsigned long long i = 0; i < kpow; ++i) {
        long n = [freq[i] intValue];
        if (n == max) {
            NSString *pat = [self numberToPattern:i k:k];
            [result addObject:pat];
        }
    }

    return [result copy];
}

+ (NSArray *)kmersFromString:(NSString *)str k:(NSUInteger)k {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:str.length - k];

    for (int i = 0; i <= str.length - k; ++i) {
        NSString *s = [str substringWithRange:NSMakeRange(i, k)];
        [arr addObject:s];
    }
    return [arr copy];
}

+ (NSString *)stringFromSequentialKmers:(NSArray *)strings {

    NSMutableString *res = [[strings firstObject] mutableCopy];

    for (long i = 1; i < strings.count; ++i) {
        NSString *str = [strings objectAtIndex:i];
        NSRange r = NSMakeRange(res.length-str.length+1, str.length-1);
        [res replaceCharactersInRange:r withString:str];
    }

    return [res copy];
}

+ (NSString *)stringFromGappedKmers:(NSArray *)strings k:(NSUInteger)k d:(NSUInteger)d {

    NSArray *s1 = [strings CH_map:^id(id obj) {
        return [[obj componentsSeparatedByString:@"|"] firstObject];
    }];

    NSArray *s2 = [strings CH_map:^id(id obj) {
        return [[obj componentsSeparatedByString:@"|"] lastObject];
    }];


    NSMutableString *res = [NSMutableString string];

    for (NSUInteger i = 0; i < s1.count-1; ++i) {
        NSString *str = [s1 objectAtIndex:i];
        [res appendString:[str substringToIndex:1]];
    }
    [res appendString:s1.lastObject];

    for (NSUInteger i = strings.count-d-1; i < s2.count-1; ++i) {
        NSString *str = [s2 objectAtIndex:i];
        [res appendString:[str substringToIndex:1]];
    }
    [res appendString:s2.lastObject];

    return res.copy;
}

+ (NSArray *)binaryDigitsUpTo:(NSUInteger)bits {

    NSUInteger max = pow(2, bits);
    NSMutableArray *arr = [NSMutableArray array];

    for (NSUInteger i = 0; i < max; ++i) {
        NSMutableString *str = [[@"0000000000000000000000000000" substringWithRange:NSMakeRange(0, bits)] mutableCopy];
        NSUInteger j = 0;
        for (NSUInteger n = i; n > 0; n >>= 1, j++) {
            if (n & 1) {
                NSRange r = NSMakeRange(str.length-j-1, 1) ;
                [str replaceCharactersInRange:r withString:@"1"];
            }
        }
        [arr addObject:[str copy]];
    }

    return [arr copy];
}



@end
