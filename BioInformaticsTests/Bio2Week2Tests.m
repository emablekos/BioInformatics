//
//  Bio2Week2Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/6/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "Graph.h"
#import "GraphUtil.h"
#import "NSArray+CHCollectionUtils.h"
#import "BioUtil.h"

@interface Bio2Week2Tests : XCTestCase

@end

@implementation Bio2Week2Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEulerCycle {

    NSString *adj = @"\
0 -> 3\n\
1 -> 0\n\
2 -> 1,6\n\
3 -> 2\n\
4 -> 2\n\
5 -> 4\n\
6 -> 5,8\n\
7 -> 9\n\
8 -> 7\n\
9 -> 6";

    GraphPath *test = [[GraphPath alloc] initWithString:@"6->8->7->9->6->5->4->2->1->0->3->2->6"];

    Graph *g = [[Graph alloc] initWithAdjacencyList:adj];

    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g];
    GraphPath *find = [pf findCycle];

    XCTAssert(test.edgeEnumerator.allObjects.count == find.edgeEnumerator.allObjects.count);


    NSString * lines = [NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_euler1.txt"] encoding:NSUTF8StringEncoding error:nil];

    g = [[Graph alloc] initWithAdjacencyList:lines];
    pf = [[EulerPathfinder alloc] initWithGraph:g];
    find = [pf findCycle];
}

- (void)testEulerPath {

    NSString *adj = @"\
0 -> 2\n\
1 -> 3\n\
2 -> 1\n\
3 -> 0,4\n\
6 -> 3,7\n\
7 -> 8\n\
8 -> 9\n\
9 -> 6";

    Graph *g = [[Graph alloc] initWithAdjacencyList:adj];
    GraphNode *n1 = [g nodeForLabel:@"6"];
    GraphNode *n2 = [g nodeForLabel:@"4"];

    XCTAssertTrue([g isNearlyBalanced]);

    GraphNode *t1;
    GraphNode *t2;
    [g isNearlyBalancedFromStart:&t1 end:&t2];

    XCTAssertEqual(t1, n1);
    XCTAssertEqual(t2, n2);

    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g];
    GraphPath *p = [pf findPath];

    XCTAssertEqualObjects([p stringValue], @"6->7->8->9->6->3->0->2->1->3->4");


    NSString * lines = [NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_euler2.txt"] encoding:NSUTF8StringEncoding error:nil];

    g = [[Graph alloc] initWithAdjacencyList:lines];
    pf = [[EulerPathfinder alloc] initWithGraph:g];
    p = [pf findPath];
    NSLog(@"Path %@", p);

}

- (void)testEulerStringReconstruction {

    NSArray *kmers = [@"\
CTTA,\
ACCA,\
TACC,\
GGCT,\
GCTT,\
TTAC"\
                      componentsSeparatedByString:@","];
    
    
    Graph *g = [GraphUtil debruijnGraphFromKmers:kmers];
    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g];
    GraphPath *p = [pf findPath];
    NSArray *arr = [[p.edgeEnumerator allObjects] CH_map:^id(GraphEdge *obj) {
        return obj.label;
    }];
    NSString *str = [BioUtil stringFromSequentialKmers:arr];
    XCTAssertEqualObjects(str, @"GGCTTACCA");

    

    NSArray * lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_reconstruct.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    kmers = [lines subarrayWithRange:NSMakeRange(1, lines.count-2)];

    g = [GraphUtil debruijnGraphFromKmers:kmers];
    pf = [[EulerPathfinder alloc] initWithGraph:g];
    p = [pf findPath];
    arr = [[p.edgeEnumerator allObjects] CH_map:^id(GraphEdge *obj) {
        return obj.label;
    }];
    str = [BioUtil stringFromSequentialKmers:arr];



}


- (void)testCircularKstring {

    NSUInteger k = 8;

    NSArray *kmers = [BioUtil binaryDigitsUpTo:k];
    Graph *g = [GraphUtil debruijnGraphFromKmers:kmers];
    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g];
    GraphPath *p = [pf findCycle];
    NSArray *arr = [[p.edgeEnumerator allObjects] CH_map:^id(GraphEdge *obj) {
        return obj.label;
    }];
    NSString *str = [BioUtil stringFromSequentialKmers:arr];
    str = [str substringWithRange:NSMakeRange(0, str.length-(k-1))];
    XCTAssertEqualObjects(str, @"1111111011111100111101101111010111110100111011101100111001101110010111100100110101101101010111010100110011000111110001101100010111000100101101001010110010100100100011101000110010000111100001101000010110000100010101010001000001110000010100000011000000001001");
}

- (void)testGappedKmers {


    NSUInteger k = 4;
    NSUInteger d = 2;

    NSArray *strings = [@"\
GACC|GCGC,\
ACCG|CGCC,\
CCGA|GCCG,\
CGAG|CCGG,\
GAGC|CGGA"\
                        componentsSeparatedByString:@","];

    NSString *str = [BioUtil stringFromGappedKmers:strings k:k d:d];
    XCTAssertEqualObjects(str, @"GACCGAGCGCCGGA");


    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_reconstruct_gapped.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];

    NSArray *digits = [[lines firstObject] componentsSeparatedByString:@" "];
    k = [[digits firstObject] intValue];
    d = [[digits lastObject] intValue];
    strings = [lines subarrayWithRange:NSMakeRange(1, lines.count-2)];

    str = [BioUtil stringFromGappedKmers:strings k:k d:d];


}


- (void)testGappedEulerReconstruct {

    NSUInteger k,d;

    NSArray *lines = [[NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_reconstruct_gapped_euler_1.txt"] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    NSArray *digits = [[lines objectAtIndex:1] componentsSeparatedByString:@" "];
    k = [[digits firstObject] intValue];
    d = [[digits lastObject] intValue];
    NSArray *strings = [lines subarrayWithRange:NSMakeRange(2, 5701)];
    NSArray *test = [lines objectAtIndex:5704];

    Graph *g = [GraphUtil debruijnGraphFromPairedKmers:strings k:k];
    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g];
    GraphPath *p = [pf findPath];

    NSArray *labels = [p.edgeEnumerator.allObjects CH_map:^id(GraphEdge *obj) {
        return obj.label;
    }];

    NSString *str = [BioUtil stringFromGappedKmers:labels k:k d:d];
    XCTAssertEqualObjects(str, test);


}


@end
