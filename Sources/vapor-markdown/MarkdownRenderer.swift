import Vapor
import cmark_swift
import Foundation

public final class MarkdownRenderer: ViewRenderer {
    
    let viewsDir: String
    var workDir: String = ""
    public init(viewsDir: String) {
        self.viewsDir = viewsDir
    }
    
    public func make(_ path: String, _ context: Node) throws -> View {

        //TODO: are there convenience functions for working with paths?
        //like properly joining, abs/rel, current path etc.
        let filePath = [workDir, viewsDir, path].joined(separator: "/")
        let markdown = try String(contentsOfFile: filePath, encoding: .utf8)
        let rendered = try markdownToHTML(markdown)
        let fullPage = wrappedInFullHTMLPage(markdown: rendered)

        //TODO: we definitely need to cache this here, maybe use the new
        //cache protocol in Droplet? we don't want to re-render the same
        //template with the same data twice. Very important for static
        //sites like blogs with markdown etc.

        return View(data: fullPage.bytes)
    }
    
    //TODO: will probably need another template (leaf?) into which we'll embed the
    //rendered markdown. Devs will definitely want to customize this.
    func wrappedInFullHTMLPage(markdown: String) -> String {
        let page = "<html><head></head><body>\(markdown)</body></html>"
        return page
    }
}
