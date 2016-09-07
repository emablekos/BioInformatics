//
//  Bio2Week1Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/29/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "GraphUtil.h"
#import "NSArray+CHCollectionUtils.h"
#import "BioUtil.h"

@interface Bio2Week1Tests : XCTestCase

@end

@implementation Bio2Week1Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDecomposeStrings {

    NSString *str = @"CAATCCAAC";
    NSUInteger k = 5;

    NSArray *test = [@"\
CAATC,\
AATCC,\
ATCCA,\
TCCAA,\
CCAAC"
                     componentsSeparatedByString:@","];

    NSArray *arr = [BioUtil kmersFromString:str k:k];

    XCTAssertEqualObjects(arr, test);


    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w1_string_decompose.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];

    k = [[lines firstObject] intValue];
    str = [lines objectAtIndex:1];

    arr = [BioUtil kmersFromString:str k:k];

}

- (void)testJoinStrings {


    NSArray *strings = [@"\
ACCGA,\
CCGAA,\
CGAAG,\
GAAGC,\
AAGCT"\
 componentsSeparatedByString:@","];

    NSString *test = @"ACCGAAGCT";
    NSString *res = [BioUtil stringFromSequentialKmers:strings];
    XCTAssertEqualObjects(res, test);

    strings = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w1_string_solve.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    strings = [strings subarrayWithRange:NSMakeRange(0, strings.count-1)];
    res = [BioUtil stringFromSequentialKmers:strings];

    NSLog(@"Res is %@", res);
}



- (void)testOverlapGraph {

    NSArray *strings = [@"\
ATGCG,\
GCATG,\
CATGC,\
AGGCA,\
GGCAT"\
                        componentsSeparatedByString:@","];

    Graph *g = [GraphUtil overlapGraph:strings];
    GraphNode *n1 = [[g nodesForLabel:@"ATGCG"] firstObject];
    GraphNode *n2 = [[g nodesForLabel:@"AGGCA"] firstObject];
    GraphNode *n3 = [[g nodesForLabel:@"GGCAT"] firstObject];

    XCTAssert([g nodesForLabel:@"ATGCG"].count == 1);
    XCTAssert([g edgesFrom:n1].count == 0);
    XCTAssertEqual([[[g edgesFrom:n2] firstObject] to], n3);
    XCTAssertEqual([[[g edgesTo:n3] firstObject] from], n2);


    /*
    strings = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w1_overlap_graph.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    strings = [strings subarrayWithRange:NSMakeRange(0, strings.count-1)];

    g = [GraphUtil overlapGraph:strings];
    NSLog(@"Adjacent :\n%@", [g adjacencyDescription]);
     */

}

- (void)testUniversalString {

    NSArray *strings = [@"\
000,\
001,\
010,\
011,\
100,\
101,\
110,\
111"\
                        componentsSeparatedByString:@","];

    Graph *g = [GraphUtil overlapGraph:strings];
    NSMutableArray *paths = [NSMutableArray array];
    for (GraphNode *n in [g nodeEnumerator]) {
        [paths addObjectsFromArray:[g hamiltonianPaths:n]];
    }

    NSArray *res = [paths CH_map:^id(NSArray * obj) {
        return [BioUtil stringFromSequentialKmers:[obj CH_map:^id(GraphNode *obj) {
            return obj.label;
        }]];
    }];

    XCTAssertEqual(res.count, 256);



}

- (void)testDeBruijnFromString {

    int k = 4;
    NSString *str = @"AAGATTCTCTAAGA";

    Graph *g = [GraphUtil debruijnGraph1:str k:k];
    GraphNode *n1 = [[g nodesForLabel:@"AAG"] firstObject];
    GraphNode *n2 = [[g nodesForLabel:@"AGA"] firstObject];
    GraphNode *n3 = [[g nodesForLabel:@"TCT"] firstObject];

    XCTAssertEqual([g edgesFrom:n1].count, 2);
    XCTAssertEqual([g edgesFrom:n2].count, 1);
    XCTAssertEqual([g edgesFrom:n3].count, 2);
    XCTAssert([[[g edgesFrom:n1] valueForKey:@"to"] containsObject:n2]);
    XCTAssert([g node:n1 isAdjacent:n2]);

    /*
    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w1_debruijn_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];

    k = [[lines firstObject] intValue];
    str = [lines objectAtIndex:1];

    g = [GraphUtil debruijnGraph1:str k:k];
     */

}

- (void)testDeBruijnFromKmers {

    NSArray *kmers = [@"\
GAGG,\
CAGG,\
GGGG,\
GGGA,\
CAGG,\
AGGG,\
GGAG"\
                        componentsSeparatedByString:@","];


    Graph *g = [GraphUtil debruijnGraphFromKmers:kmers];
    GraphNode *n1 = [[g nodesForLabel:@"GGG"] firstObject];
    GraphNode *n2 = [[g nodesForLabel:@"CAG"] firstObject];
    GraphNode *n3 = [[g nodesForLabel:@"AGG"] firstObject];

    XCTAssertEqual([g edgesFrom:n1].count, 2);
    XCTAssertEqual([g edgesFrom:n2].count, 2);
    XCTAssertEqual([g edgesFrom:n3].count, 1);
    XCTAssert([g node:n3 isAdjacent:n1]);
    XCTAssert([g node:n1 isAdjacent:n1]);
    XCTAssert([g node:n2 isAdjacent:n3]);

    /*
    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w1_debruijn_2.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    kmers = [lines subarrayWithRange:NSMakeRange(0, lines.count-1)];

    g = [GraphUtil debruijnGraphFromKmers:kmers];
     */
}

- (void)testQuiz {

    NSString *adj = @"\
1 -> 2,3,5\n\
2 -> 4,5\n\
3 -> 1,2,5\n\
4 -> 1,3\n\
5 -> 2,4";

    Graph *g = [[Graph alloc] initWithAdjacencyList:adj];
    NSMutableArray *paths = [NSMutableArray array];
    for (GraphNode *n in [g nodeEnumerator]) {
        [paths addObjectsFromArray:[g hamiltonianPaths:n]];
    }

    NSArray *res = [paths CH_map:^id(NSArray * obj) {
        return [[obj valueForKey:@"label"] componentsJoinedByString:@" -> "];
    }];

}

- (void)testQuiz2 {

    NSArray *strings = [@"\
000,\
001,\
010,\
011,\
100,\
101,\
110,\
111"\
                        componentsSeparatedByString:@","];

    Graph *g = [GraphUtil overlapGraph:strings];
    NSMutableArray *paths = [NSMutableArray array];
    for (GraphNode *n in [g nodeEnumerator]) {
        [paths addObjectsFromArray:[g hamiltonianPaths:n]];
    }
    
    NSArray *res = [paths CH_map:^id(NSArray * obj) {
        return [BioUtil stringFromSequentialKmers:[obj CH_map:^id(GraphNode *obj) {
            return obj.label;
        }]];
    }];

    NSArray *test = [@"\
0100011101,\
0101010100,\
1100011011,\
1111000111,\
0111010001,\
0011101000"\
                 componentsSeparatedByString:@","];

    for (int i = 0; i < test.count; ++i) {
        NSString *t = [test objectAtIndex:i];
        if ([res containsObject:t]) {
            NSLog(@"%@", @(i));
        }
    }
}

- (void)testQuiz3 {

    NSArray *kmers = [@"\
GCGA,\
CAAG,\
AAGA,\
GCCG,\
ACAA,\
AGTA,\
TAGG,\
AGTA,\
ACGT,\
AGCC,\
TTCG,\
AGTT,\
AGTA,\
CGTA,\
GCGC,\
GCGA,\
GGTC,\
GCAT,\
AAGC,\
TAGA,\
ACAG,\
TAGA,\
TCCT,\
CCCC,\
GCGC,\
ATCC,\
AGTA,\
AAGA,\
GCGA,\
CGTA"\
                      componentsSeparatedByString:@","];
    
    
    Graph *g = [GraphUtil debruijnGraphFromKmers:kmers];
    GraphNode *n = [[g nodesForLabel:@"AAG"] firstObject];
    NSArray *es = [g edgesFrom:n];

}


@end
