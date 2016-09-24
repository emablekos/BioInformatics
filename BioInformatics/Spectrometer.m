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

        self.expansionCandidates = [self.weightToProtein allKeys];
    }
    return self;
}

- (void)useNonproteogenicExpansionCandidates {
    NSMutableArray *c = [NSMutableArray array];
    for (int i = 57; i<=200; ++i) {
        [c addObject:@(i)];
    }
    self.expansionCandidates = [c copy];
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

- (NSArray *)weightsForProtein:(NSString *)protein {
    NSMutableArray *wts = [NSMutableArray array];
    for (int i = 0; i < protein.length; ++i) {
        NSString *a = [protein substringWithRange:NSMakeRange(i, 1)];
        NSNumber *wt = [self.proteinToWeight objectForKey:a];
        [wts addObject:wt];
    }

    return [wts copy];
}

- (NSArray *)linearSpectrum:(NSString *)peptide {
    NSArray *weights = [self weightsForProtein:peptide];
    return [self linearSpectrumFromWeights:weights];
}

- (NSArray *)linearSpectrumFromWeights:(NSArray *)weights {

    NSMutableArray *prefixMass = [NSMutableArray array];
    [prefixMass addObject:@0];

    for (int i = 0; i < weights.count; ++i) {
        NSNumber *wt = weights[i];
        [prefixMass addObject:@([prefixMass.lastObject intValue] + [wt intValue])];
    }

    NSMutableArray *spectrum = [NSMutableArray array];
    [spectrum addObject:@0];

    for (int i = 0; i <= weights.count-1; ++i) {
        for (int j = i + 1; j <= weights.count; ++j) {
            NSInteger val = [prefixMass[j] integerValue] - [prefixMass[i] integerValue];
            [spectrum addObject:@(val)];
        }
    }

    [spectrum sortUsingSelector:@selector(compare:)];

    return [spectrum copy];
}



- (NSArray *)cyclicSpectrum:(NSString *)peptide {
    NSArray *weights = [self weightsForProtein:peptide];
    return [self cyclicSpectrumFromWeights:weights];
}

- (NSArray *)cyclicSpectrumFromWeights:(NSArray *)weights {

    NSMutableArray *prefixMass = [NSMutableArray array];
    [prefixMass addObject:@0];

    NSArray *cyclic = [weights arrayByAddingObjectsFromArray:[weights subarrayWithRange:NSMakeRange(0, weights.count-2)]];

    for (int i = 0; i < cyclic.count; ++i) {
        NSNumber *wt = cyclic[i];
        [prefixMass addObject:@([prefixMass.lastObject intValue] + [wt intValue])];
    }

    NSMutableArray *spectrum = [NSMutableArray array];
    [spectrum addObject:@0];

    for (int i = 0; i <= weights.count-1; ++i) {
        for (int j = i + 1; j <= i + weights.count - 1; ++j) {
            NSInteger val = [prefixMass[j] integerValue] - [prefixMass[i] integerValue];
            [spectrum addObject:@(val)];
        }
    }

    // Add full length item
    [spectrum addObject:prefixMass[weights.count]];

    [spectrum sortUsingSelector:@selector(compare:)];

    return [spectrum copy];
}

- (NSMutableArray *)expandPeptides:(NSArray *)startPeptides {

    NSMutableArray *result = [NSMutableArray array];

    for (NSMutableArray *peptide in startPeptides) {
        for (NSNumber *wt in self.expansionCandidates) {
            if ([peptide isEqualToArray:@[@0]]) {
                [result addObject:@[wt]];
            } else {
                [result addObject: [peptide arrayByAddingObject:wt]];
            }
        }
    }

    return result;
}

- (NSInteger)sumWeights:(NSArray *)peptide {
    NSInteger w = 0;
    for (NSNumber *n in peptide) {
        w += [n integerValue];
    }
    return w;
}

- (NSArray *)cyclopeptideSequencing:(NSString *)testSpectrum {

    NSArray *testSpectrumArray = [Spectrometer spectrumFromString:testSpectrum];

    NSInteger parentMass = [[testSpectrumArray lastObject] integerValue];


    // Peptides will be dealt with as arrays of numbers, the weight of each amino
    NSMutableArray *peptides = [NSMutableArray array];
    [peptides addObject:[NSArray arrayWithObject:@0]];


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

    NSMutableArray *results = [NSMutableArray array];

    while (peptides.count > 0) {

        NSMutableArray *toRemove = [NSMutableArray array];
        peptides = [self expandPeptides:peptides];
        for (NSArray *peptide in peptides) {
            NSInteger mass = [self sumWeights:peptide];
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

- (NSArray *)leaderboardCyclopeptideSequencing:(NSString *)testSpectrum cut:(NSInteger)cut {

    NSArray *testSpectrumArray = [Spectrometer spectrumFromString:testSpectrum];
    testSpectrumArray = [testSpectrumArray sortedArrayUsingSelector:@selector(compare:)];

    NSInteger parentMass = [[testSpectrumArray lastObject] integerValue];


    // Peptides will be dealt with as arrays of numbers, the weight of each amino
    NSArray *peptides = [NSArray arrayWithObject:[NSArray arrayWithObject:@0]];

    NSArray *leaderPeptide = @[@0];
    NSInteger leaderScore = 0;

    NSMutableArray *leaderPeptides = [NSMutableArray array];

    while (peptides.count > 0) {

        NSMutableArray *nextPeptides = [NSMutableArray arrayWithCapacity:peptides.count];

        peptides = [self expandPeptides:peptides];
        for (NSArray *peptide in peptides) {
            NSInteger mass = [self sumWeights:peptide];
            if (mass == parentMass) {

                NSArray *spec = [self cyclicSpectrumFromWeights:peptide];
                NSInteger score = [self scoreSpectrum:spec againstSpectrum:testSpectrumArray];

                if (score > leaderScore) {
                    leaderPeptide = peptide;
                    leaderScore = score;
                    leaderPeptides = [NSMutableArray arrayWithObject:leaderPeptide];
                } else if (score == leaderScore) {
                    [leaderPeptides addObject:peptide];
                }
                [nextPeptides addObject:peptide];

            } else if (mass < parentMass) {
                [nextPeptides addObject:peptide];
            }
        }

        peptides = nextPeptides;

        // Trim
        if (peptides.count > cut) {
            peptides = [self bestMatches:peptides spectrum:testSpectrumArray cut:cut cyclic:NO];
        }

    }

    NSLog(@"Max score is %ld returning %@", (long)leaderScore, [leaderPeptide componentsJoinedByString:@"-"]);
    NSLog(@"%@", [[leaderPeptides CH_map:^id(id obj) {
        return [obj componentsJoinedByString:@"-"];
    }] componentsJoinedByString:@" "]);

    return leaderPeptide;
}

- (NSInteger)scorePeptide:(NSString *)peptide againstSpectrum:(NSArray *)spectrum cyclic:(BOOL)cyclic {
    NSArray *pspec = cyclic ? [self cyclicSpectrum:peptide] : [self linearSpectrum:peptide];
    return [self scoreSpectrum:pspec againstSpectrum:spectrum];
}

- (NSInteger)scorePeptideWeights:(NSArray *)weights againstSpectrum:(NSArray *)spectrum cyclic:(BOOL)cyclic {
    NSArray *pspec = cyclic ? [self cyclicSpectrumFromWeights:weights] : [self linearSpectrumFromWeights:weights];
    return [self scoreSpectrum:pspec againstSpectrum:spectrum];
}

- (NSInteger)scoreSpectrum:(NSArray *)pspec againstSpectrum:(NSArray *)spectrum {

    NSUInteger pi = 0;
    NSUInteger si = 0;

    NSInteger score = 0;

    while (pi < pspec.count && si < spectrum.count) {

        int pn = pi >= pspec.count ? 99999 : [pspec[pi] intValue];
        int sn = si >= spectrum.count ? 99999 : [spectrum[si] intValue];

        if (pn==sn) {
            si++;
            pi++;

            score++;

        } else if (pn<sn) {
            pi++;
        } else if (sn<pn) {
            si++;
        }
    }

    return score;
}

- (NSInteger)scorePeptide2:(NSString *)peptide againstSpectrum:(NSArray *)spectrum cyclic:(BOOL)cyclic {


    NSArray *cs = cyclic ? [self cyclicSpectrum:peptide] : [self linearSpectrum:peptide];

    NSInteger score = 0;

    NSMutableDictionary *pfreq = [NSMutableDictionary dictionary];
    NSMutableDictionary *sfreq = [NSMutableDictionary dictionary];

    for (NSNumber *n in cs) {
        if ([pfreq objectForKey:n]) {
            pfreq[n] = @([pfreq[n] integerValue]+1);
        } else {
            pfreq[n] = @1;
        }
    }

    for (NSNumber *n in spectrum) {
        if ([sfreq objectForKey:n]) {
            sfreq[n] = @([sfreq[n] integerValue]+1);
        } else {
            sfreq[n] = @1;
        }
    }


    NSMutableSet *taken = [NSMutableSet set];

    for (NSNumber *n in cs) {
        if (![taken containsObject:n]) {
            NSInteger idx = [spectrum indexOfObject:n];
            if (idx != NSNotFound) {
                [taken addObject:n];
                NSInteger min = MIN([pfreq[n] integerValue], [sfreq[n] integerValue]);
                score += min;
            }
        }
        //score += occ.count > 0;
    }

    return score;
}




- (NSArray *)bestMatches:(NSArray *)peptides spectrum:(NSArray *)spectrum cut:(NSInteger)cut cyclic:(BOOL)cyclic {

    NSMutableArray *arr = [NSMutableArray array];

    for (id p in peptides) {
        NSInteger s;

        if ([p isKindOfClass:[NSString class]]) {
            s = [self scorePeptide:p againstSpectrum:spectrum cyclic:cyclic];
        } else if ([p isKindOfClass:[NSArray class]]) {
            s = [self scorePeptideWeights:p againstSpectrum:spectrum cyclic:cyclic];
        } else {
            NSParameterAssert(NO);
        }

        [arr addObject:@{@"p":p, @"s":@(s)}];
    }

    [arr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"s"ascending:NO]]];

    NSArray *r = arr;
    if (peptides.count > cut) {
        NSInteger ties = cut-1;
        NSInteger score = [arr[ties][@"s"] integerValue];
        for (; ties < arr.count; ++ties) {
            if ([arr[ties][@"s"] integerValue] != score) {
                ties--;
                break;
            }
        }

        r = [arr subarrayWithRange:NSMakeRange(0, MIN(ties+1,peptides.count))];
    }

    r = [r CH_map:^id(id obj) {
        return obj[@"p"];
    }];

    return r;
}

+ (NSArray *)spectrumFromString:(NSString *)string {
    return [[string componentsSeparatedByString:@" "] CH_map:^id(NSString *obj) {
        return @([obj integerValue]);
    }];
}


@end
