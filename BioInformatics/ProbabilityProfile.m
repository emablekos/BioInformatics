//
//  ProbabilityProfile.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/20/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "ProbabilityProfile.h"

@interface ProbabilityProfile()
@property (nonatomic) NSArray *a;
@property (nonatomic,readwrite) unsigned long k;
@end

@implementation ProbabilityProfile

- (instancetype)init {
    self = [super init];
    if (self) {
        self.a = @[@[]];
    }
    return self;
}

- (instancetype)initWithLines:(NSArray *)lines {
    self = [self init];
    if (self) {
        NSMutableArray *a = [NSMutableArray array];
        for (NSString *line in lines) {
            NSArray *la = [line componentsSeparatedByString:@" "];
            [a addObject:la];
        }

        NSAssert(a.count == 4, @"4 nucleotides requiered");
        NSAssert([a[0] count] == [a[1] count] && [a[1] count] == [a[2] count] && [a[2] count] && [a[3] count], @"non equal rows");
        NSAssert([a[0] count] > 0, @"empty");

        self.a = [a copy];
        self.k = [a[0] count];
    }
    return self;
}

- (instancetype)initWithMotifs:(NSArray *)motifs {
    return [self initWithMotifs:motifs pseudocounts:NO];
}

- (instancetype)initWithMotifs:(NSArray *)motifs pseudocounts:(BOOL)pseudocounts {
    self = [self init];
    if (self) {
        unsigned long k = [[motifs firstObject] length];
        for (NSString *motif in motifs) {
            NSAssert(motif.length == k, @"All must be same length");
        }

        NSDictionary *d =
        @{
          @"A":[NSMutableArray array],
          @"C":[NSMutableArray array],
          @"G":[NSMutableArray array],
          @"T":[NSMutableArray array]
          };

        for (unsigned long i = 0; i < k; ++i) {
            unsigned int As = 0;
            unsigned int Cs = 0;
            unsigned int Gs = 0;
            unsigned int Ts = 0;

            for (NSString *motif in motifs) {
                unichar base = [motif characterAtIndex:i];
                if (base == 'A')
                    As++;
                else if (base == 'C')
                    Cs++;
                else if (base == 'G')
                    Gs++;
                else if (base == 'T')
                    Ts++;
            }
            CGFloat total = motifs.count * 1.f;

            if (pseudocounts) {
                As++; Cs++; Gs++; Ts++;
                total += 4.f;
            }

            CGFloat Ap = As/total;
            CGFloat Cp = Cs/total;
            CGFloat Gp = Gs/total;
            CGFloat Tp = Ts/total;

            [d[@"A"] addObject:@(Ap)];
            [d[@"C"] addObject:@(Cp)];
            [d[@"G"] addObject:@(Gp)];
            [d[@"T"] addObject:@(Tp)];
        }

        self.k = k;
        self.a = @[[d[@"A"] copy], [d[@"C"] copy], [d[@"G"] copy], [d[@"T"] copy]];
    }
    return self;
}


- (NSString *)consensusString {
    NSArray *base = @[@"A",@"C",@"G",@"T"];
    NSMutableString *str = [NSMutableString stringWithCapacity:self.k];

    for (unsigned long col = 0; col < self.k; ++col) {
        CGFloat max = 0.f;
        int mbi = -1;

        for (int bi = 0; bi < 4; ++bi) {
            CGFloat p = [[[self.a objectAtIndex:bi] objectAtIndex:col] floatValue];
            if (p > max) {
                max = p;
                mbi = bi;
            }
        }

        [str appendString:[base objectAtIndex:mbi]];
    }

    return str;
}

- (unsigned int)scoreMotifs:(NSArray *)arr {
    NSString *cnstr = [self consensusString];

    const char *csp = [cnstr UTF8String];

    unsigned int score = 0;

    for (NSString *motif in arr) {
        NSAssert(motif.length == self.k, @"Wrong motif size");

        const char *cm = [motif UTF8String];

        for (unsigned long long i = 0; i < motif.length; ++i) {
            if (csp[i] != cm[i]) {
                score++;
            }
        }
    }

    return score;
}

- (CGFloat)valueForChar:(unichar)base index:(unsigned long)index {
    int row = 0;
    if (base == 'C') {
        row  = 1;
    } else if (base == 'G') {
        row = 2;
    } else if (base == 'T') {
        row = 3;
    }

    NSNumber *val = [[self.a objectAtIndex:row] objectAtIndex:index];
    return [val floatValue];
}

- (CGFloat)valueFor:(NSString *)base index:(unsigned long)index {
    return [self valueForChar:[base characterAtIndex:0] index:index];
}


- (CGFloat)probabilityOfKmer:(NSString *)kmer {

    NSAssert(kmer.length == [self k], @"Wrong size");

    CGFloat val = 1.;

    for (unsigned long long i = 0; i < kmer.length; ++i) {
        CGFloat v = [self valueForChar:[kmer characterAtIndex:i] index:i];
        val *= v;
    }

    return val;
}

- (BOOL)isEqualToProbabilityProfile:(ProbabilityProfile *)other {
    if (!other) {
        return NO;
    }

    for (int i = 0; i < 4; ++i) {
        unichar base = [@"ACGT" characterAtIndex:i];
        for (unsigned long j = 0; j < [[self.a firstObject] count]; ++j) {
            if ([self valueForChar:base index:j] != [other valueForChar:base index:j]) {
                return NO;
            }
        }
    }

    return YES;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ProbabilityProfile class]]) {
        return NO;
    }

    return [self isEqualToProbabilityProfile:(ProbabilityProfile *)object];
}


@end
