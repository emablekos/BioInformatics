//
//  BioUitl.h
//  BioHomework
//
//  Created by E.J. Mablekos on 8/1/16.
//

#import <Foundation/Foundation.h>

@interface BioUtil : NSObject

+ (NSInteger)PatternCount:(NSString *)text pattern:(NSString *)pattern;
+ (NSArray *)FrequentWords:(NSString *)text length:(int)length min:(int)min;
+ (NSString *)reverseCompliment:(NSString *)original;
+ (NSArray *)locsOfPattern:(NSString *)pattern genome:(NSString *)genome;
+ (NSArray *)clumpsIn:(NSString *)text k:(int)k t:(int)t l:(int)l;
+ (unsigned long long)patternToNumber:(NSString *)pattern;
+ (NSString *)numberToPattern:(unsigned long long)num k:(int)k;
+ (NSArray *)frequencyArray:(NSString *)text k:(int)k;
+ (NSArray *)minimumSkewPositions:(NSString *)text;
+ (unsigned int)hammingDistance:(NSString *)a other:(NSString *)b;
+ (NSArray *)approximatePatternMatch:(NSString *)text pattern:(NSString *)pattern distance:(unsigned int)distance;
+ (unsigned int)approximatePatternCount:(NSString *)text pattern:(NSString *)pattern distance:(unsigned int)distance;
+ (NSArray *)neighbors:(NSString *)pattern distance:(int)distance;
+ (NSArray *)frequentWordsWithMismatches:(NSString *)text k:(int)k d:(int)d;
+ (NSArray *)frequentWordsWithMismatches:(NSString *)text k:(int)k d:(int)d reverse:(BOOL)reverse;
+ (NSArray *)kmersFromString:(NSString *)str k:(NSUInteger)k;
+ (NSString *)stringFromSequentialKmers:(NSArray *)strings;
+ (NSArray *)binaryDigitsUpTo:(NSUInteger)bits;
+ (NSString *)stringFromGappedKmers:(NSArray *)strings k:(NSUInteger)k d:(NSUInteger)d;


@end
