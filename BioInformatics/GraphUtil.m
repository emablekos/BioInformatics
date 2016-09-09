//
//  GraphUtil.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "GraphUtil.h"
#import "BioUtil.h"

@implementation GraphUtil

+ (Graph *)overlapGraph:(NSArray *)kmers {

    Graph *g = [Graph new];

    for (NSString *kmer in kmers) {
        [g addNodeForLabel:kmer];
    }


    for (GraphNode *from in g.nodeEnumerator) {

        NSString *suffix = [from.label substringFromIndex:1];

        for (GraphNode *to in g.nodeEnumerator) {
            if (from == to) {
                continue;
            }

            NSString *prefix = [to.label substringToIndex:to.label.length-1];

            if ([suffix isEqualToString:prefix]) {
                [g addEdge:from to:to];
            }
        }
    }

    return g;
}

+ (Graph *)debruijnGraph1:(NSString *)str k:(NSUInteger)k {

    NSArray *kmers = [BioUtil kmersFromString:str k:k];

    NSMutableArray *nodes = [NSMutableArray array];

    for (NSString *kmer in kmers) {
        [nodes addObject:[kmer substringToIndex:k-1]];
    }

    [nodes addObject:[str substringFromIndex:str.length-k+1]];

    Graph *g = [Graph new];

    GraphNode *lastNode = nil;

    for (long i = 0; i < nodes.count; ++i) {

        NSString *node = [nodes objectAtIndex:i];

        GraphNode *n = [[g nodesForLabel:node] firstObject];
        if (!n)
            n = [g addNodeForLabel:node];

        if (lastNode) {
            NSString *kmer = [kmers objectAtIndex:i-1];

            GraphEdge *e = [g addEdge:lastNode to:n];
            e.label = kmer;
        }

        lastNode = n;
    }

    return g;

}

+ (Graph *)debruijnGraphFromKmers:(NSArray *)kmers {

    NSMutableSet *jmers = [NSMutableSet set];

    for (NSString *kmer in kmers) {
        [jmers addObject:[kmer substringFromIndex:1]]; //suffix
        [jmers addObject:[kmer substringToIndex:kmer.length-1]]; //prefix
    }

    Graph *g = [Graph new];

    for (NSString *jmer in jmers) {
        [g addNodeForLabel:jmer];
    }

    for (NSString *kmer in kmers) {
        NSString *pre = [kmer substringToIndex:kmer.length-1];
        NSString *suf = [kmer substringFromIndex:1];

        GraphNode *n1 = [[g nodesForLabel:pre] firstObject];
        GraphNode *n2 = [[g nodesForLabel:suf] firstObject];

        GraphEdge *e = [g addEdge:n1 to:n2];
        e.label = kmer;
    }

    return g;
}


+ (Graph *)debruijnGraphFromPairedKmers:(NSArray *)kmers k:(NSUInteger)k {

    NSMutableSet *jmers = [NSMutableSet set];

    NSString *(^prefix)(NSString *) = ^(NSString *kmer) {
        NSString *jmer = [kmer substringWithRange:NSMakeRange(0, k-1)];
        jmer = [jmer stringByAppendingString:[kmer substringWithRange:NSMakeRange(k+1, k-1)]];
        return jmer;
    };

    NSString *(^suffix)(NSString *) = ^(NSString *kmer) {
        NSString *jmer = [kmer substringWithRange:NSMakeRange(1, k-1)];
        jmer = [jmer stringByAppendingString:[kmer substringWithRange:NSMakeRange(k+2, k-1)]];
        return jmer;
    };

    for (NSString *kmer in kmers) {
        [jmers addObject:prefix(kmer)];
        [jmers addObject:suffix(kmer)];
    }

    Graph *g = [Graph new];

    for (NSString *jmer in jmers) {
        [g addNodeForLabel:jmer];
    }

    for (NSString *kmer in kmers) {
        NSString *pre = prefix(kmer);
        NSString *suf = suffix(kmer);

        GraphNode *n1 = [[g nodesForLabel:pre] firstObject];
        GraphNode *n2 = [[g nodesForLabel:suf] firstObject];

        GraphEdge *e = [g addEdge:n1 to:n2];
        e.label = kmer;
    }
    
    return g;
}


@end
