//
//  Motif.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/20/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "Motif.h"
#import "BioUtil.h"
#import "NSArray+CHCollectionUtils.h"

@implementation Motif


+ (NSArray *)motifEnumeration:(NSArray *)lines k:(int)k d:(int)d {

    NSString *dna = [lines componentsJoinedByString:@""];

    NSMutableSet *set = [NSMutableSet set];

    for (unsigned long i = 0; i <= dna.length - k; ++i) {
        NSString *kmer = [dna substringWithRange:NSMakeRange(i, k)];
        NSArray *hood = [BioUtil neighbors:kmer distance:d];

        for (NSString *nbr in hood) {
            BOOL presentInAll = YES;
            int lineNumber = -1;

            for (NSString *line in lines) {
                lineNumber++;
                BOOL presentInLine = NO;
                for (unsigned long j = 0; j <= line.length - k; ++j) {
                    NSString *check = [line substringWithRange:NSMakeRange(j, k)];
                    if ([BioUtil hammingDistance:nbr other:check] <= d) {
                        presentInLine = YES;
                        break;
                    }
                }
                if (!presentInLine) {
                    presentInAll = NO;
                    break;
                }
            }
            if (presentInAll) {
                [set addObject:nbr];
            }
        }
    }

    return [[set allObjects] copy];
}

+ (unsigned long)distanceBetweenPattern:(NSString *)pattern strings:(NSArray *)strings {

    unsigned long k = pattern.length;
    int distance = 0;

    for (NSString *line in strings) {
        unsigned long min = pattern.length + 1;
        for (unsigned long i = 0; i <= line.length - k; ++i) {
            NSString *check = [line substringWithRange:NSMakeRange(i, k)];
            int ham = [BioUtil hammingDistance:pattern other:check];
            if (ham < min) {
                min = ham;
            }
        }
        distance += min;
    }

    return distance;
}

+ (NSString *)medianString:(NSArray *)dna k:(unsigned int)k {
    return [[self medianStrings:dna k:k] firstObject];
}

+ (NSArray *)medianStrings:(NSArray *)dna k:(unsigned int)k {

    int kpow = pow(4, k);

    unsigned long mdist = dna.count * (k + 1);
    NSMutableArray *mpats = [NSMutableArray array];

    for (unsigned long i = 0; i < kpow; ++i) {
        NSString *pat = [BioUtil numberToPattern:i k:k];

        unsigned long dist = [self distanceBetweenPattern:pat strings:dna];
        if (dist < mdist) {
            mdist = dist;
            [mpats removeAllObjects];
            [mpats addObject:pat];
        } else if (dist == mdist) {
            [mpats addObject:pat];
        }
    }
    
    return mpats;
}



+ (NSString *)mostProbableKmer:(NSString *)dna profile:(ProbabilityProfile *)profile k:(unsigned int)k {

    CGFloat p = 0;
    NSString *pkmer = [dna substringWithRange:NSMakeRange(0, k)];

    for (unsigned long i = 0; i <= dna.length - k; ++i) {
        NSString *kmer = [dna substringWithRange:NSMakeRange(i, k)];
        CGFloat kp = [profile probabilityOfKmer:kmer];
        if (kp > p) {
            p = kp;
            pkmer = kmer;
        }
    }

    return pkmer;
}

+ (NSArray *)greedyMotifSearch:(NSArray *)dna k:(unsigned int)k t:(unsigned int)t pseudocounts:(BOOL)pseudocounts {

    NSArray *bestMotifs = [dna CH_map:^id(NSString *obj) {
        return [obj substringWithRange:NSMakeRange(0, k)];
    }];
    ProbabilityProfile *bestp = [[ProbabilityProfile alloc] initWithMotifs:bestMotifs pseudocounts:pseudocounts];
    unsigned int bestMotifScore = [bestp scoreMotifs:bestMotifs];

    NSString *fline = [dna firstObject];
    for (unsigned long i = 0; i < fline.length - k; ++i) {
        NSString *motif = [fline substringWithRange:NSMakeRange(i, k)];

        NSMutableArray *motifs = [NSMutableArray array];
        [motifs addObject:motif];

        ProbabilityProfile *profile = [[ProbabilityProfile alloc] initWithMotifs:motifs pseudocounts:pseudocounts];

        for (unsigned long l = 1; l < t; ++l) {
            NSString *line = [dna objectAtIndex:l];
            NSString *mp = [self mostProbableKmer:line profile:profile k:k];
            [motifs addObject:mp];
            profile = [[ProbabilityProfile alloc] initWithMotifs:motifs pseudocounts:pseudocounts];
        }

        unsigned int cscore = [profile scoreMotifs:motifs];
        if (cscore < bestMotifScore) {
            bestMotifs = motifs;
            bestMotifScore = cscore;
        }
    }

    return [bestMotifs copy];
}

+ (NSArray *)randomizedMotifSearch:(NSArray *)dna k:(unsigned int)k t:(unsigned int)t times:(unsigned int)times {

    NSDictionary *(^run)() = ^() {

        NSArray *bestMotifs = [dna CH_map:^id(NSString *obj) {
            u_int32_t r = arc4random_uniform((u_int32_t)(obj.length-k));
            return [obj substringWithRange:NSMakeRange(r, k)];
        }];
        unsigned int bestScore = k * t + 1;

        u_int32_t iter = 0;

        while (YES) {

            iter++;

            ProbabilityProfile *profile = [[ProbabilityProfile alloc] initWithMotifs:bestMotifs pseudocounts:NO];

            NSMutableArray *motifs = [NSMutableArray array];

            for (unsigned long l = 0; l < t; ++l) {
                NSString *line = [dna objectAtIndex:l];
                NSString *mp = [self mostProbableKmer:line profile:profile k:k];
                [motifs addObject:mp];
            }

            unsigned int score = [profile scoreMotifs:motifs];


            if (score < bestScore && iter < 20) {
                bestMotifs = motifs;
                bestScore = score;
            } else {
                NSLog(@"Iteration %i found score %i", iter, score);
                return @{@"score":@(score), @"motifs":[bestMotifs copy]};
            }
        }
        return @{};
    };

    NSMutableArray *runs = [NSMutableArray arrayWithCapacity:times];
    for (int i = 0; i < times; ++i) {
        NSLog(@"Run %i", i);
        [runs addObject:run()];
    }

    [runs sortUsingComparator:^NSComparisonResult(NSDictionary *  _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
        int s1 = [obj1[@"score"] intValue];
        int s2 = [obj2[@"score"] intValue];

        if (s1 < s2) {
            return NSOrderedAscending;
        } else if (s1 > s2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    NSLog(@"Best result from random search %@", [runs firstObject]);

    return [[runs firstObject] objectForKey:@"motifs"];
}


+ (NSArray *)gibbsSearch:(NSArray *)dna k:(unsigned int)k t:(unsigned int)t n:(unsigned int)n times:(unsigned int)times {

    NSDictionary *(^run)() = ^() {

        NSArray *bestMotifs = [dna CH_map:^id(NSString *obj) {
            u_int32_t r = arc4random_uniform((u_int32_t)(obj.length-k));
            return [obj substringWithRange:NSMakeRange(r, k)];
        }];
        unsigned long bestScore = k * dna.count + 1;

        NSMutableArray *motifs = [bestMotifs mutableCopy];

        for (int i = 0; i < n; ++i) {

            int dropout = arc4random_uniform((u_int32_t)motifs.count-1);
            [motifs removeObjectAtIndex:dropout];

            ProbabilityProfile *profile = [[ProbabilityProfile alloc] initWithMotifs:motifs pseudocounts:YES];
            NSString *gen = [profile randomWeightedKmer:[dna objectAtIndex:dropout]];
            [motifs insertObject:gen atIndex:dropout];

            unsigned long score = [profile scoreMotifs:motifs];

            if (score <= bestScore) {
                NSLog(@"Score improved to %lu", score);
                bestMotifs = [motifs copy];
                bestScore = score;
            }
        }

        return @{@"score":@(bestScore),@"motifs":bestMotifs};
    };

    NSMutableArray *runs = [NSMutableArray arrayWithCapacity:times];
    for (int i = 0; i < times; ++i) {
        NSLog(@"Run %i", i);
        [runs addObject:run()];
    }

    [runs sortUsingComparator:^NSComparisonResult(NSDictionary *  _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
        int s1 = [obj1[@"score"] intValue];
        int s2 = [obj2[@"score"] intValue];

        if (s1 < s2) {
            return NSOrderedAscending;
        } else if (s1 > s2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    NSLog(@"Best result from gibbs search %@", [runs firstObject]);

    return [[runs firstObject] objectForKey:@"motifs"];
}



@end
