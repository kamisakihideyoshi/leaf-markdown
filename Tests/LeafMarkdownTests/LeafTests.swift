import XCTest
@testable import Leaf
import LeafMarkdown

class LeafTests: XCTestCase {

    // MARK: - Properties
    
    var renderer: LeafRenderer!
    let template = "#markdown(data)"

    // MARK: - Overrides
    
    override func setUp() {
        let queue = EmbeddedEventLoop()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: queue)
        let tag = Markdown()
        var leafTagConfig = LeafTagConfig.default()
        leafTagConfig.use(tag, as: tag.name)
        self.renderer = LeafRenderer(config: LeafConfig(tags: leafTagConfig, viewsDir: "", shouldCache: false), using: container)
    }
    
    // MARK: - Tests

    func testRunTag() throws {
        let inputMarkdown = "# This is a test\n\nWe have some text in a tag"
        let data = TemplateData.dictionary(["data": .string(inputMarkdown)])
        let expectedHtml = "<h1>This is a test</h1>\n<p>We have some text in a tag</p>\n"

        let result = try renderer.render(template: template.data(using: .utf8)!, data).wait()
        let resultString = String(data: result.data, encoding: .utf8)!
        XCTAssertEqual(resultString, expectedHtml)
    }

    func testNilParameterDoesNotCrashLeaf() throws {
        let data = TemplateData.dictionary(["data": .null])
        let expectedHtml = ""

        let result = try renderer.render(template: template.data(using: .utf8)!, data).wait()
        let resultString = String(data: result.data, encoding: .utf8)!
        XCTAssertEqual(resultString, expectedHtml)
    }

    func testStripHtml() throws {
        let inputMarkdown = "<br>"
        let data = TemplateData.dictionary(["data": .string(inputMarkdown)])
        let expectedHtml = "<!-- raw HTML omitted -->\n"

        let result = try renderer.render(template: template.data(using: .utf8)!, data).wait()
        let resultString = String(data: result.data, encoding: .utf8)!
        XCTAssertEqual(resultString, expectedHtml)

    }

    func testDoNotStripHtml() throws {

        let queue = EmbeddedEventLoop()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: queue)
        let tag = Markdown(options: [.unsafe])
        var leafTagConfig = LeafTagConfig.default()
        leafTagConfig.use(tag, as: tag.name)
        let renderer = LeafRenderer(config: LeafConfig(tags: leafTagConfig, viewsDir: "", shouldCache: false),
                                     using: container)

        let inputMarkdown = "<br>"
        let data = TemplateData.dictionary(["data": .string(inputMarkdown)])
        let expectedHtml = "<br>\n"

        let result = try renderer.render(template: template.data(using: .utf8)!, data).wait()
        let resultString = String(data: result.data, encoding: .utf8)!
        XCTAssertEqual(resultString, expectedHtml)
    }
}
