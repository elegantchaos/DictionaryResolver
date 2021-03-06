// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/04/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

@testable import DictionaryResolver

final class DictionaryResolverTests: XCTestCase {
    func testResolver(named name: String, resolve: Bool = true) throws -> DictionaryResolver {
        let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Individual")!
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: url, mode: .multipleRecordsPerFile)
        if resolve {
            resolver.resolve()
        }
        
        return resolver
    }
    
    func testSingleInheritance() throws {
        let index = try testResolver(named: "SimpleTest")

        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
        XCTAssertEqual(r2["bar"] as? String, "foo")
    }

    func testThreeLevelInheritance() throws {
        let index = try testResolver(named: "ThreeLevelTest")

        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testMultipleInheritance() throws {
        let index = try testResolver(named: "MultipleTest")

        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["foo"] as? String, "bar")
        XCTAssertEqual(r3["bar"] as? String, "foo")
        XCTAssertEqual(r3["wibble"] as? String, "wobble")
    }

    func testLoop() throws {
        let index = try testResolver(named: "LoopTest")

        let r1 = index.record(withID: "r1")!
        XCTAssertEqual(r1["foo"] as? String, "bar")
        XCTAssertEqual(r1["bar"] as? String, "foo")
    }

    func testInheritorOverwritesInherited() throws {
        let index = try testResolver(named: "OverwriteTest")
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["foo"] as? String, "bar")
    }

    func testMergingLists() throws {
        var index = try testResolver(named: "ListMergeTest", resolve: false)
        index.addCombiner(Combiner.combineCombinable)
        index.resolve()
        
        let r2 = index.record(withID: "r2")!
        XCTAssertEqual(r2["merged"] as? [String], ["foo", "bar"])
    }

    func testMergingListsWithMultipleInheritance() throws {
        var index = try testResolver(named: "ListMergeWithInheritanceTest", resolve: false)
        index.addCombiner(Combiner.combineCombinable)
        index.resolve()
        
        let r3 = index.record(withID: "r3")!
        XCTAssertEqual(r3["merged"] as? [String], ["bar", "foo", "wibble"])
    }

    func testLoadingFolderSingleRecord() throws {
        let url = Bundle.module.url(forResource: "SimpleTest", withExtension: "json", subdirectory: "Individual")!
        let folder = url.deletingLastPathComponent()
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: folder, mode: .singleRecordPerFileSkipRootID)
        XCTAssertEqual(resolver.records.count, 7)
    }

    func testLoadingFolderMultipleRecords() throws {
        let url = Bundle.module.url(forResource: "SimpleTest", withExtension: "json", subdirectory: "Individual")!
        let folder = url.deletingLastPathComponent()
        var resolver = DictionaryResolver()
        try resolver.loadRecords(from: folder, mode: .multipleRecordsPerFile)
        // multiple versions of "r1", "r2" and "r3" will overwrite each other, so the count will end up just being 3
        XCTAssertEqual(resolver.records.count, 3)
    }

}
