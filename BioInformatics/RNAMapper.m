//
//  RNAMapper.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/16/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "RNAMapper.h"
#import "BioUtil.h"
#import "NSArray+CHCollectionUtils.h"

@interface RNAMapper()
@property (nonatomic) NSDictionary *codonToProtein;
@property (nonatomic) NSDictionary *proteinToCodon;
@end

@implementation RNAMapper

- (instancetype)init {
    self = [super init];
    if (self) {

        NSMutableDictionary *codonToProtein = [NSMutableDictionary dictionary];
        NSMutableDictionary *proteinToCodon = [NSMutableDictionary dictionary];

        NSError *e;
        NSString *s = [NSString stringWithContentsOfFile:@"/Users/emablekos/Projects/BioInformatics/BioInformatics/BioInformatics/RNA_codon_table.txt" encoding:NSASCIIStringEncoding error:&e];
        NSArray *arr = [s componentsSeparatedByString:@"\n"];

        for (NSString *str in arr) {
            NSArray *ln = [str componentsSeparatedByString:@" "];
            [codonToProtein setObject:[ln lastObject] forKey:[ln firstObject]];

            if ([[ln lastObject] length] > 0) {
                NSMutableArray *seqs = [proteinToCodon objectForKey:[ln lastObject]];
                if (!seqs) {
                    seqs = [NSMutableArray array];
                    [proteinToCodon setObject:seqs forKey:[ln lastObject]];
                }
                [seqs addObject:[ln firstObject]];
            }
        }
        self.proteinToCodon = [proteinToCodon copy];
        self.codonToProtein = [codonToProtein copy];
    }
    return self;
}

- (NSString *)translateRNA:(NSString *)rna {
    NSRange r;
    return [self translateRNA:rna readingFrame:0 resultRange:&r];
}

- (NSString *)translateRNA:(NSString *)rna readingFrame:(int)readingFrame resultRange:(NSRange *)range {

    BOOL stopOnFirst = NO;

    NSMutableString *protein = [NSMutableString stringWithCapacity:rna.length/3];
    BOOL started = NO;
    int i;
    for (i = readingFrame; i <= rna.length - 3; i += 3) {
        NSString *codon = [rna substringWithRange:NSMakeRange(i, 3)];
        NSString *peptide = [self.codonToProtein objectForKey:codon];
        if (peptide.length > 0) {
            if (!started) {
                started = YES;
                (*range).location = i;
                (*range).length = 0;
            }
            (*range).length += 3;
            [protein appendString:peptide];
        } else {
            if ((stopOnFirst)) {
                continue;
            } else {
                (*range).length += 3;
                [protein appendString:@"_"];
            }
        }
    }

    if (!stopOnFirst) {
        (*range).location = readingFrame;
        (*range).length = rna.length-readingFrame;
    }

    return [protein copy];
}

- (NSArray *)expandProteinToRNA:(NSString *)protein {

    NSArray *prefixes = @[@""];

    for (int i = 0; i < protein.length; ++i) {
        NSString* p = [protein substringWithRange:NSMakeRange(i, 1)];

        NSMutableArray *newprefixes = [NSMutableArray array];

        NSArray *codons = [self.proteinToCodon objectForKey:p];

        for (NSString *codon in codons) {
            for (NSString *pre in prefixes) {
                [newprefixes addObject:[pre stringByAppendingString:codon]];
            }
        }

        prefixes = newprefixes;

    }

    return [prefixes copy];
}

- (NSArray *)findSubstringsInDNA:(NSString *)dna encoding:(NSString *)protein {

    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:protein options:0 error:nil];
    NSMutableArray *indna = [NSMutableArray array];

    NSString *rna = [BioUtil dnaToRNA:dna];

    for (int i = 0; i < 3; ++i) {
        NSRange pRange;
        NSString *pro = [self translateRNA:rna readingFrame:i resultRange:&pRange];
        NSArray *arr = [exp matchesInString:pro options:0 range:NSMakeRange(0, pro.length)];

        for (NSTextCheckingResult *result in arr) {
            NSRange range = result.range;
            range.location = range.location * 3 + pRange.location;
            range.length = range.length * 3;

            NSString *match = [dna substringWithRange:range];

            [indna addObject:match];
        }
    }


    // Reverse compliment

    NSString *rev = [BioUtil reverseCompliment:dna];
    rna = [BioUtil dnaToRNA:rev];

    for (int i = 0; i < 3; ++i) {
        NSRange pRange;
        NSString *pro = [self translateRNA:rna readingFrame:i resultRange:&pRange];
        NSArray *arr = [exp matchesInString:pro options:0 range:NSMakeRange(0, pro.length)];

        for (NSTextCheckingResult *result in arr) {
            NSRange range = result.range;
            range.location = dna.length - ((range.location * 3) + (range.length *3) + pRange.location);
            range.length = range.length * 3;

            NSString *match = [dna substringWithRange:range];

            [indna addObject:match];
        }
    }

    return [indna copy];
}

- (NSArray *)findSubstringsInDNA2:(NSString *)dna encoding:(NSString *)protein {

    NSArray *expanded = [self expandProteinToRNA:protein];

    NSString *rna = [BioUtil dnaToRNA:dna];
    NSString *reverse = [BioUtil reverseCompliment:dna];
    NSString *rna2 = [BioUtil dnaToRNA:reverse];

    NSMutableArray *indna = [NSMutableArray array];

    for (NSString *expansion in expanded) {

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expansion options:0 error:nil];

        NSArray *matches = [regex matchesInString:rna options:0 range:NSMakeRange(0, rna.length)];

        for (NSTextCheckingResult *result in matches) {
            NSString *dna = [rna substringWithRange:result.range];
            dna = [BioUtil rnaToDNA:dna];
            [indna addObject:dna];
        }

        // Reverse
        matches = [regex matchesInString:rna2 options:0 range:NSMakeRange(0, rna.length)];

        for (NSTextCheckingResult *result in matches) {
            NSString *dna = [rna2 substringWithRange:result.range];
            dna = [BioUtil rnaToDNA:dna];
            dna = [BioUtil reverseCompliment:dna];
            [indna addObject:dna];
        }

    }

    return [indna copy];
}


@end
