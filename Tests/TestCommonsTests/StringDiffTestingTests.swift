import XCTest
import TestCommons

class StringDiffTestingTests: XCTestCase {
    var testReporter: TestDiffReporter!
    
    override func setUp() {
        super.setUp()
        
        testReporter = TestDiffReporter()
    }
    
    func testDiffSimpleString() {
        #sourceLocation(file: "test.swift", line: 1)
        diffTest(expected: """
                abc
                def
                """).diff("""
                abc
                df
                """)
        #sourceLocation()
        
        XCTAssertEqual(
            testReporter.messages[0],
            """
            test.swift:4: Strings don't match:

            Expected (between ---):

            ---
            abc
            def
            ---

            Actual result (between ---):

            ---
            abc
            df
            ---

            Diff (between ---):

            ---
            abc
            df
            ~^ Difference starts here
            ---
            """
        )
        
        XCTAssertEqual(
            testReporter.messages[1],
            """
            test.swift:6: Difference starts here: Actual line reads 'df'
            """
        )
    }
    
    func testDiffEmptyStrings() {
        #sourceLocation(file: "test.swift", line: 1)
        diffTest(expected: "").diff("")
        #sourceLocation()
        
        XCTAssertEqual(testReporter.messages.count, 0)
    }
    
    func testDiffEqualStrings() {
        #sourceLocation(file: "test.swift", line: 1)
        diffTest(expected: """
                abc
                def
                """).diff("""
                abc
                def
                """)
        #sourceLocation()
        
        XCTAssertEqual(testReporter.messages.count, 0)
    }
    
    func testDiffLargerExpectedString() {
        #sourceLocation(file: "test.swift", line: 1)
        diffTest(expected: """
                abc
                def
                ghi
                """).diff("""
                abc
                def
                """)
        #sourceLocation()
        
        XCTAssertEqual(
            testReporter.messages[0],
            """
            test.swift:5: Strings don't match:

            Expected (between ---):

            ---
            abc
            def
            ghi
            ---

            Actual result (between ---):

            ---
            abc
            def
            ---

            Diff (between ---):

            ---
            abc
            def
            ~~~^ Difference starts here
            ---
            """
        )
        
        XCTAssertEqual(
            testReporter.messages[1],
            """
            test.swift:8: Difference starts here: Expected matching line 'ghi'
            """
        )
    }
    
    func testDiffLargerResultString() {
        #sourceLocation(file: "test.swift", line: 1)
        diffTest(expected: """
                abc
                def
                """).diff("""
                abc
                def
                ghi
                """)
        #sourceLocation()
        
        XCTAssertEqual(
            testReporter.messages[0],
            """
            test.swift:4: Strings don't match:

            Expected (between ---):

            ---
            abc
            def
            ---

            Actual result (between ---):

            ---
            abc
            def
            ghi
            ---

            Diff (between ---):

            ---
            abc
            def
            ghi
            ~~~^ Difference starts here
            ---
            """
        )
        
        XCTAssertEqual(
            testReporter.messages[1],
            """
            test.swift:6: Difference starts here: Extraneous content after this line
            """
        )
    }
}

extension StringDiffTestingTests {
    public func diffTest(expected input: String,
                         file: String = #file,
                         line: Int = #line) -> DiffingTest {
        
        let location = DiffLocation(file: file, line: line)
        let diffable = DiffableString(string: input, location: location)
        
        return DiffingTest(expected: diffable, testCase: testReporter)
    }
}

class TestDiffReporter: DiffTestCaseFailureReporter {
    var messages: [String] = []
    
    func recordFailure(withDescription description: String,
                       inFile filePath: String,
                       atLine lineNumber: Int,
                       expected: Bool) {
        
        messages.append("\(filePath):\(lineNumber): " + description)
        
    }
}
