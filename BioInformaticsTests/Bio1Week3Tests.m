//
//  Week3Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/20/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "BioUtil.h"
#import "Motif.h"
#import "ProbabilityProfile.h"

@interface Bio1Week3Tests : XCTestCase

@end

@implementation Bio1Week3Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMotifEnumeration {

    int k = 3;
    int d = 1;
    NSArray *dna =[@"ATTTGGC,TGCCTTA,CGGTATC,GAAAATT" componentsSeparatedByString:@","];
    NSSet *test = [NSSet setWithArray:[@"ATA ATT GTT TTT" componentsSeparatedByString:@" "]];

    NSArray *pat = [Motif motifEnumeration:dna k:k d:d];
    XCTAssertEqualObjects([NSSet setWithArray:pat], test);


    //
    k = 3;
    d = 1;
    dna =[@"\
AAAAA,\
AAAAA,\
AAAAA"\
          componentsSeparatedByString:@","];
    test = [NSSet setWithArray:[@"AAA AAC AAG AAT ACA AGA ATA CAA GAA TAA" componentsSeparatedByString:@" "]];

    pat = [Motif motifEnumeration:dna k:k d:d];
    XCTAssertEqualObjects([NSSet setWithArray:pat], test);


    //
    k = 3;
    d = 3;
    dna =[@"\
AAAAA,\
AAAAA,\
AAAAA"\
          componentsSeparatedByString:@","];
    test = [NSSet setWithArray:[@"AAA AAC AAG AAT ACA ACC ACG ACT AGA AGC AGG AGT ATA ATC ATG ATT CAA CAC CAG CAT CCA CCC CCG CCT CGA CGC CGG CGT CTA CTC CTG CTT GAA GAC GAG GAT GCA GCC GCG GCT GGA GGC GGG GGT GTA GTC GTG GTT TAA TAC TAG TAT TCA TCC TCG TCT TGA TGC TGG TGT TTA TTC TTG TTT" componentsSeparatedByString:@" "]];

    pat = [Motif motifEnumeration:dna k:k d:d];
    XCTAssertEqualObjects([NSSet setWithArray:pat], test);



    //
    k = 3;
    d = 0;
    dna =[@"\
ACGT,\
ACGT,\
ACGT"\
          componentsSeparatedByString:@","];
    test = [NSSet setWithArray:[@"ACG CGT" componentsSeparatedByString:@" "]];

    pat = [Motif motifEnumeration:dna k:k d:d];
    XCTAssertEqualObjects([NSSet setWithArray:pat], test);


//
    k = 5;
    d = 2;
    dna =[@"\
TAATCCAGATACAAATGTAGGCCGT,\
TGCTCAGTCGTACCTGTACATCCAA,\
CCCCTCGATTAACAGAGCGTCGTGG,\
GATGGTGTCGGTTGCTGTCACGGGA,\
GCAAAACCAACGTTGTAGGTAACAT,\
GTACAAGTTGCGTTGGGTGGGCTGC"\
                   componentsSeparatedByString:@","];

    pat = [Motif motifEnumeration:dna k:k d:d];
    NSLog(@"Motifs: %@", [pat componentsJoinedByString:@" "]);

}

- (void)testDistanceBetweenPatternAndStrings {

    NSString *pattern = @"AAA";
    NSArray *dna = [@"TTACCTTAAC GATATCTGTC ACGGCGTTCG CCCTAAAGAG CGTCAGAGGT" componentsSeparatedByString:@" "];
    unsigned long test = 5;

    unsigned long dist = [Motif distanceBetweenPattern:pattern strings:dna];
    XCTAssertEqual(test, dist);

    //
    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w3_distance_pattern_strings.txt"] encoding:NSASCIIStringEncoding error:nil] componentsSeparatedByString:@"\n"];

    pattern = [lines firstObject];
    dna = [[lines objectAtIndex:1] componentsSeparatedByString:@" "];

    dist = [Motif distanceBetweenPattern:pattern strings:dna];

}

- (void)testMedianString {

    int k = 3;
    NSArray *dna = [@"\
AAATTGACGCAT,\
GACGACCACGTT,\
CGTCAGCGCCTG,\
GCTGAGCACCGG,\
AGTTCGGGACAG"\
                    componentsSeparatedByString:@","];
    NSString *test = @"GAC";

    NSString *med = [Motif medianString:dna k:k];
    XCTAssertEqualObjects(med, test);

    //
    k = 6;
    dna = [@"\
ACGTTGGCTGGGCCTCCGAGGGCACTCTGGGTAGACGGGAAG,\
TTCGCGCAGTGAATCTGGATAAACGTTGAGATTGCGGATATA,\
TGAATCACTATCAACCAACCAAGCGTCTGGGAGTTCGACCAC,\
TCACGCATTAACCTAACTCGCGGAGTACTATGTGCAATCTGG,\
CCTTTGTAATACGCTTCCTCATTCCCGCAAATCGTTGTCTGG,\
TCCATGCAAACTGCTCGCAACTGCTTCTGGGGCTTGACATCT,\
AAGCGAGATCGACTCTGGATCAAACCTCTTCCGGGAGGGTCC,\
GCGGCAACCAGCAGGTAAGATCGAAACACTTATCGAATCTGG,\
TTCTGGTTAACCTTACAAACGTTACTGAAGGCATTGGCATTC,\
TGGTGCTAGACCGTGATCTTCTGGTGGAATTAACCAAAACAT"\
                    componentsSeparatedByString:@","];

    med = [Motif medianString:dna k:k];
    NSLog(@"Median String: %@", med);

}



- (void)testMostProbableKmer {

    NSArray *plines =
    @[@"0.2 0.2 0.3 0.2 0.3",
      @"0.4 0.3 0.1 0.5 0.1",
      @"0.3 0.3 0.5 0.2 0.4",
      @"0.1 0.2 0.1 0.1 0.2",
      ];
    int k = 5;
    NSString *dna = @"ACCTGTTTATTGCCTAAGTTCCGAACAAACCCAATATAGCCCGAGGGCCT";
    NSString *test = @"CCGAG";
    ProbabilityProfile *pp = [[ProbabilityProfile alloc] initWithLines:plines];

    NSString *kmer = [Motif mostProbableKmer:dna profile:pp k:k];
    XCTAssertEqualObjects(test, kmer);

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w3_most_probable_kmer_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    dna = [lines firstObject];
    k = [[lines objectAtIndex:1] intValue];
    plines = [lines subarrayWithRange:NSMakeRange(2, 4)];
    pp = [[ProbabilityProfile alloc] initWithLines:plines];

    kmer = [Motif mostProbableKmer:dna profile:pp k:k];
    NSLog(@"Kmer: %@", kmer);
}

- (void)testGreedyMotifSearch {

    NSArray *dna = [@"\
GGCGTTCAGGCA,\
AAGAATCAGTCA,\
CAAGGAGTTCGC,\
CACGTCAATCAC,\
CAATAATATTCG"\
                      componentsSeparatedByString:@","];
    unsigned int k = 3;
    unsigned int t = 5;
    NSArray *test = [@"CAG,CAG,CAA,CAA,CAA" componentsSeparatedByString:@","];

    NSArray *best = [Motif greedyMotifSearch:dna k:k t:t pseudocounts:NO];
    XCTAssertEqualObjects([NSSet setWithArray:test], [NSSet setWithArray:best]);

    //
    dna = [@"\
GGCGTTCAGGCA,\
AAGAATCAGTCA,\
CAAGGAGTTCGC,\
CACGTCAATCAC,\
CAATAATATTCG"\
           componentsSeparatedByString:@","];
    k = 3;
    t = 5;
    test = [@"TTC,ATC,TTC,ATC,TTC" componentsSeparatedByString:@","];

    best = [Motif greedyMotifSearch:dna k:k t:t pseudocounts:YES];
    XCTAssertEqualObjects([NSSet setWithArray:test], [NSSet setWithArray:best]);

    //
    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w3_greedy_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray *digits = [[lines firstObject] componentsSeparatedByString:@" "];
    k = [[digits firstObject] intValue];
    t = [[digits lastObject] intValue];
    dna = [lines subarrayWithRange:NSMakeRange(1, lines.count-2)];

    best = [Motif greedyMotifSearch:dna k:k t:t pseudocounts:YES];
    NSLog(@"Motifs: \n%@", [best componentsJoinedByString:@"\n"]);
}


@end
