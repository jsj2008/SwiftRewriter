import XCTest
import ExpressionPasses
import SwiftRewriterLib

class UIKitExpressionPassTests: ExpressionPassTestCase {
    override func setUp() {
        sut = UIKitExpressionPass()
    }
    
    func testUIColor() {
        assertTransformParsed(
            expression: "[UIColor orangeColor]",
            into: .postfix(.identifier("UIColor"), .member("orange"))
        ); assertNotifiedChange()
        
        assertTransformParsed(
            expression: "[UIColor redColor]",
            into: .postfix(.identifier("UIColor"), .member("red"))
        ); assertNotifiedChange()
        
        // Test unrecognized cases are left alone
        assertTransformParsed(
            expression: "UIColor->redColor",
            into: "UIColor.redColor"
        ); assertDidNotNotifyChange()
        assertTransformParsed(
            expression: "[UIColor redColor:@1]",
            into: "UIColor.redColor(1)"
        ); assertDidNotNotifyChange()
        assertTransformParsed(
            expression: "[UIColor Color:@1]",
            into: "UIColor.Color(1)"
        ); assertDidNotNotifyChange()
    }
    
    func testAddTarget() {
        assertTransformParsed(
            expression: "[self.button addTarget:self action:@selector(didTapButton:) forControlEvents: UIControlEventTouchUpInside]",
            into: .postfix(.postfix(.postfix(.identifier("self"), .member("button")),
                                        .member("addTarget")),
                               .functionCall(arguments: [
                                .unlabeled(.identifier("self")),
                                .labeled("action", .postfix(.identifier("Selector"),
                                                            .functionCall(arguments: [
                                                                .unlabeled(.constant("didTapButton:"))
                                                                ]))),
                                .labeled("for", .postfix(.identifier("UIControlEvents"), .member("touchUpInside")))
                                ]))
        ); assertNotifiedChange()
    }
}
