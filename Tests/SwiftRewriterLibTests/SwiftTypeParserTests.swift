import XCTest
import SwiftAST
import SwiftRewriterLib

class SwiftTypeParserTests: XCTestCase {
    func testParseIdentifierType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type"),
                           SwiftType.typeName("Type"))
    }
    
    func testParseOptionalIdentifierType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type?"),
                           SwiftType.optional("Type"))
    }
    
    func testParseOptionalImplicitlyUnwrappedOptionalIdentifierType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type?!"),
                           SwiftType.implicitUnwrappedOptional(.optional(.typeName("Type"))))
    }
    
    func testParseEmptyTuple() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "()"),
                           SwiftType.void)
    }
    
    func testParseTupleType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(Type1, Type2)"),
                           SwiftType.tuple([.typeName("Type1"), .typeName("Type2")]))
    }
    
    func testParseTupleInTupleType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "((Type1, Type2), (Type3, Type4))"),
                           SwiftType.tuple([.tuple([.typeName("Type1"), .typeName("Type2")]), .tuple([.typeName("Type3"), .typeName("Type4")])]))
    }
    
    func testParseTupleTypeWithLabels() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(label1: Type1, label2: Type2)"),
                           SwiftType.tuple([.typeName("Type1"), .typeName("Type2")]))
    }
    
    func testParseBlockType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(Type1) -> Type2"),
                           SwiftType.block(returnType: .typeName("Type2"), parameters: [.typeName("Type1")]))
    }
    
    func testParseBlockWithParameterLabels() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(_ param: Type1, param2: Type2) -> Type2"),
                           SwiftType.block(returnType: .typeName("Type2"), parameters: [.typeName("Type1"), .typeName("Type2")]))
    }
    
    func testParseBlockArgumentWithInOut() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(inout Type1) -> Type2"),
                           SwiftType.block(returnType: .typeName("Type2"), parameters: [.typeName("Type1")]))
    }
    
    func testParseBlockArgumentWithInOutAndParameterName() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(name: inout Type1) -> Type2"),
                           SwiftType.block(returnType: .typeName("Type2"), parameters: [.typeName("Type1")]))
    }
    
    func testParseBlockArgumentWithInOutAndParameterNameAndLabel() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(label name: inout Type1) -> Type2"),
                           SwiftType.block(returnType: .typeName("Type2"), parameters: [.typeName("Type1")]))
    }
    
    func testParseArray() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "[Type1]"),
                           SwiftType.array(.typeName("Type1")))
    }
    
    func testParseDirectory() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "[Type1: Type2]"),
                           SwiftType.dictionary(key: "Type1", value: "Type2"))
    }
    
    func testParseOptionalBlock() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(() -> ())?"),
                           SwiftType.optional(.block(returnType: .void, parameters: [])))
    }
    
    func testParseGenericType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type<A>"),
                           SwiftType.generic("Type", parameters: [.typeName("A")]))
    }
    
    func testParseGenericTypeWitihinGenericType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type<A<B>>"),
                           SwiftType.generic("Type", parameters: [.generic("A", parameters: [.typeName("B")])]))
    }
    
    func testParseGenericTypeWithTupleType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "Type<(A, B)>"),
                           SwiftType.generic("Type", parameters: [.tuple(["A", "B"])]))
    }
    
    func testParseBlockTypeTakingBlockType() throws {
        try XCTAssertEqual(SwiftTypeParser.parse(from: "(() -> ()) -> ()"),
                           SwiftType.block(returnType: .void, parameters: [.block(returnType: .void, parameters: [])]))
    }
    
    func testParseExtraCharacterMessage() throws {
        XCTAssertThrowsError(try SwiftTypeParser.parse(from: "Type<(A, B))>"))
    }
    
    func testCannotUseInoutAsParameterName() throws {
        XCTAssertThrowsError(try SwiftTypeParser.parse(from: "(inout: Type1) -> Type2"))
        XCTAssertThrowsError(try SwiftTypeParser.parse(from: "(label inout: Type1) -> Type2"))
    }
    func testCannotUseInoutAsParameterLabel() throws {
        XCTAssertThrowsError(try SwiftTypeParser.parse(from: "(inout name: Type1) -> Type2"))
    }
}
