//
//  Spectrometer.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/17/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "Spectrometer.h"
#import "NSArray+CHCollectionUtils.h"

static NSString *ts = @"\
G 57|\
A 71|\
S 87|\
P 97|\
V 99|\
T 101|\
C 103|\
I 113|\
L 113|\
N 114|\
D 115|\
K 128|\
Q 128|\
E 129|\
M 131|\
H 137|\
F 147|\
R 156|\
Y 163|\
W 186\
";

@interface Spectrometer()
@property (nonatomic) NSDictionary *weightToProtein;
@property (nonatomic) NSDictionary *proteinToWeight;
@end

@implementation Spectrometer

- (instancetype)init {
    if (self) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterNoStyle;

        NSMutableDictionary *wtToPro = [NSMutableDictionary dictionary];
        NSMutableDictionary *proToWt = [NSMutableDictionary dictionary];
        NSArray *arr = [ts componentsSeparatedByString:@"|"];
        for (NSString *line in arr) {
            NSArray *els = [line componentsSeparatedByString:@" "];
            NSString *pro = [els firstObject];
            NSString *wt = [els lastObject];
            NSNumber *wtn = [f numberFromString:wt];

            proToWt[pro] = wtn;
            wtToPro[wtn] = pro;
        }
        self.weightToProtein = [wtToPro copy];
        self.proteinToWeight = [proToWt copy];
    }
    return self;
}

- (NSString *)proteinFromWeights:(NSArray *)weights {
    NSMutableString *pro = [NSMutableString string];
    for (NSNumber *n in weights) {
        NSString *amino = [self.weightToProtein objectForKey:n];
        NSParameterAssert(amino);
        [pro appendString:amino];
    }
    return [pro copy];
}

- (NSArray *)linearSpectrum:(NSString *)peptide {

    NSMutableArray *prefixMass = [NSMutableArray array];
    [prefixMass addObject:@0];

    for (int i = 0; i < peptide.length; ++i) {
        NSString *amino = [peptide substringWithRange:NSMakeRange(i, 1)];
        NSNumber *wt = [self.proteinToWeight objectForKey:amino];
        [prefixMass addObject:@([prefixMass.lastObject intValue] + [wt intValue])];
    }

    NSMutableArray *spectrum = [NSMutableArray array];
    [spectrum addObject:@0];

    for (int i = 0; i <= peptide.length-1; ++i) {
        for (int j = i + 1; j <= peptide.length; ++j) {
            NSInteger val = [prefixMass[j] integerValue] - [prefixMass[i] integerValue];
            [spectrum addObject:@(val)];
        }
    }

    [spectrum sortUsingSelector:@selector(compare:)];

    return [spectrum copy];
}

- (NSArray *)cyclicSpectrum:(NSString *)peptide {

    NSMutableArray *prefixMass = [NSMutableArray array];
    [prefixMass addObject:@0];

    NSString *cyclic = [peptide stringByAppendingString:[peptide substringToIndex:peptide.length-2]];

    for (int i = 0; i < cyclic.length; ++i) {
        NSString *amino = [cyclic substringWithRange:NSMakeRange(i, 1)];
        NSNumber *wt = [self.proteinToWeight objectForKey:amino];
        [prefixMass addObject:@([prefixMass.lastObject intValue] + [wt intValue])];
    }

    NSMutableArray *spectrum = [NSMutableArray array];
    [spectrum addObject:@0];

    for (int i = 0; i <= peptide.length-1; ++i) {
        for (int j = i + 1; j <= i + peptide.length - 1; ++j) {
            NSInteger val = [prefixMass[j] integerValue] - [prefixMass[i] integerValue];
            [spectrum addObject:@(val)];
        }
    }

    // Add full length item
    [spectrum addObject:prefixMass[peptide.length]];

    [spectrum sortUsingSelector:@selector(compare:)];

    return [spectrum copy];
}


- (NSArray *)cyclopeptideSequencing:(NSString *)testSpectrum {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterNoStyle;
    NSArray *testSpectrumArray = [[testSpectrum componentsSeparatedByString:@" "] CH_map:^id(NSString * obj) {
        return [f numberFromString:obj];
    }];

    NSInteger parentMass = [[testSpectrumArray lastObject] integerValue];

    // Gather weights of earths aminos
    NSArray *candidates = [self.weightToProtein allKeys];

    // Peptides will be dealt with as arrays of numbers, the weight of each amino
    NSMutableArray *peptides = [NSMutableArray array];
    [peptides addObject:[NSArray arrayWithObject:@0]];

    // Append each possible weight to end of spectrum
    NSMutableArray*(^expandPeptides)(NSArray *) = ^(NSArray *startPeptides) {
        NSMutableArray *result = [NSMutableArray array];

        for (NSMutableArray *peptide in startPeptides) {
            for (NSNumber *wt in candidates) {
                if ([peptide isEqualToArray:@[@0]]) {
                    [result addObject:@[wt]];
                } else {
                    [result addObject: [peptide arrayByAddingObject:wt]];
                }
            }
        }

        return result;
    };

    // Check if a peptide is consistent with our test spectrum
    BOOL(^checkConsistency)(NSArray *) = ^(NSArray *peptide) {
        NSString *pro = [self proteinFromWeights:peptide];
        NSArray *linear = [self linearSpectrum:pro];

        NSMutableArray *arr = [testSpectrumArray mutableCopy];

        for (NSNumber *n in linear) {
            NSUInteger i = [arr indexOfObject:n];
            if (i == NSNotFound) { // Missing from spectrum
                return NO;
            }
            [arr removeObjectAtIndex:i];
        }

        return YES; //All weights consistent
    };

    // Weigh a peptide
    NSInteger(^weighPeptide)(NSArray *) = ^(NSArray *peptide) {
        NSInteger w = 0;
        for (NSNumber *n in peptide) {
            w += [n integerValue];
        }
        return w;
    };

    NSMutableArray *results = [NSMutableArray array];

    while (peptides.count > 0) {

        NSMutableArray *toRemove = [NSMutableArray array];
        peptides = expandPeptides(peptides);
        for (NSArray *peptide in peptides) {
            if ([[peptide lastObject] isEqualToNumber:@113] && [[peptide firstObject] isEqualToNumber:@103]) {
                
            }
            NSInteger mass = weighPeptide(peptide);
            if (mass == parentMass) {
                NSArray *cyclo = [self cyclicSpectrum:[self proteinFromWeights:peptide]];
                if ([cyclo isEqualToArray:testSpectrumArray]) {
                    [results addObject:peptide];
                }
                [toRemove addObject:peptide];
            } else if (!checkConsistency(peptide)) {
                [toRemove addObject:peptide];
            }
        }

        for (NSArray *peptide in toRemove) {
            [peptides removeObject:peptide];
        }
    }

    return [results copy];

}


@end
