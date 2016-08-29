//
//  Week4Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/24/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "BioUtil.h"
#import "Motif.h"
#import "ProbabilityProfile.h"


@interface Bio1Week4Tests : XCTestCase

@end

@implementation Bio1Week4Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRandomizedMotifSearch {

    NSArray *dna = [@"\
CGCCCCTCTCGGGGGTGTTCAGTAAACGGCCA,\
GGGCGAGGTATGTGTAAGTGCCAAGGTGCCAG,\
TAGTACCGAGACCGAAAGAAGTATACAGGCGT,\
TAGATCAAGTTTCAGGTGCACGTCGGTGAACC,\
AATCCACCAGCTCCACGTGCAATGTTGGCCTA"\
                    componentsSeparatedByString:@","];
    unsigned int k = 8;
    unsigned int t = 5;
    NSArray *test = [@"\
TCTCGGGG,\
CCAAGGTG,\
TACAGGCG,\
TTCAGGTG,\
TCCACGTG"\
                     componentsSeparatedByString:@","];

    NSArray *best = [Motif randomizedMotifSearch:dna k:k t:t times:1000];
    XCTAssertEqualObjects(test, best);



//    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w4_random_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    NSArray *digits = [[lines firstObject] componentsSeparatedByString:@" "];
//    k = [[digits firstObject] intValue];
//    t = [[digits lastObject] intValue];
//    dna = [lines subarrayWithRange:NSMakeRange(1, lines.count-2)];
//
//    best = [Motif randomizedMotifSearch:dna k:k t:t times:1000];

}

- (void)testGibbsSearch {

    NSArray *dna = [@"\
CGCCCCTCTCGGGGGTGTTCAGTAACCGGCCA,\
GGGCGAGGTATGTGTAAGTGCCAAGGTGCCAG,\
TAGTACCGAGACCGAAAGAAGTATACAGGCGT,\
TAGATCAAGTTTCAGGTGCACGTCGGTGAACC,\
AATCCACCAGCTCCACGTGCAATGTTGGCCTA"\
                    componentsSeparatedByString:@","];
    unsigned int k = 8;
    unsigned int t = 5;
    unsigned int n = 200;
    NSArray *test = [@"\
TCTCGGGG,\
CCAAGGTG,\
TACAGGCG,\
TTCAGGTG,\
TCCACGTG"\
                     componentsSeparatedByString:@","];
    
    NSArray *best = [Motif gibbsSearch:dna k:k t:t n:n times:40];
    XCTAssertEqualObjects(test, best);

//    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"w4_gibbs_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//    NSArray *digits = [[lines firstObject] componentsSeparatedByString:@" "];
//    k = [[digits firstObject] intValue];
//    t = [[digits objectAtIndex:1] intValue];
//    n = [[digits lastObject] intValue];
//    dna = [lines subarrayWithRange:NSMakeRange(1, lines.count-2)];
//
//    NSArray *best = [Motif gibbsSearch:dna k:k t:t n:n/2 times:100];


}


@end
