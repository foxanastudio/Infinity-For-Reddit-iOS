//
//  RichtextJSONConverter.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-14.
//

import SwiftyJSON
import MarkdownUI

class RichTextJSONConverter {
    private enum Format: Int {
        case bold = 1
        case italics = 2
        case strikethrough = 8
        case superscript = 32
        case inlineCode = 64
    }

    private enum Element: String {
        case paragraph = "par"
        case text = "text"
        case heading = "h"
        case link = "link"
        case list = "list"
        case listItem = "li"
        case blockquote = "blockquote"
        case codeBlock = "code"
        case raw = "raw"
        case spoiler = "spoilertext"
        case table = "table"
        case image = "img"
        case gif = "gif"
    }

    private let TYPE = "e"
    private let CONTENT = "c"
    private let TEXT = "t"
    private let FORMAT = "f"
    private let URL = "u"
    private let LEVEL = "l"
    private let IS_ORDERED_LIST = "o"
    private let TABLE_HEADER_CONTENT = "h"
    private let TABLE_CELL_ALIGNMENT = "a"
    private let TABLE_CELL_ALIGNMENT_LEFT = "l"
    private let TABLE_CELL_ALIGNMENT_CENTER = "c"
    private let TABLE_CELL_ALIGNMENT_RIGHT = "r"
    private let IMAGE_ID = "id"
    private let DOCUMENT = "document"

    private var text = ""
    private var formats: [[Int]] = []
    private var contentStack: [[Any]] = []

    init() {
        contentStack.append([])
    }

    func constructRichtextJSON(markdown: String) -> String {
        let markdown = MarkdownContent(markdown)

        visitBlockNodes(markdown.blocks)
        var richtext = JSON()
        richtext[DOCUMENT] = JSON(contentStack[0])
        
        if let data = try? richtext.rawData(),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    private func visitBlockNodes(_ blockNodes: [BlockNode]) {
        for block in blockNodes {
            switch block {
            case .blockquote(let childBlockNodes):
                visitBlockquote(childBlockNodes)
            case .bulletedList(let isTight, let rawListItems):
                visitBulletedList(rawListItems)
            case .numberedList(let isTight, let start, let rawListItems):
                visitNumberedList(rawListItems)
            case .taskList(let isTight, let rawTaskListItems):
                visitTaskList(rawTaskListItems)
            case .codeBlock(let fenceInfo, let content):
                visitCodeBlock(content)
            case .htmlBlock(let content):
                visitHtmlBlock(content)
            case .paragraph(let inlineNodes):
                visitParagraph(inlineNodes)
            case .heading(let level, let inlineNodes):
                visitHeading(level: level, inlineNodes: inlineNodes)
            case .table(let rawTableColumnAlignments, let rawTableRows):
                visitTable(columnAlignments: rawTableColumnAlignments, rows: rawTableRows)
            case .thematicBreak:
                break
            }
        }
    }
    
    private func visitInlineNodes(_ inlineNodes: [InlineNode]) {
        for inlineNode in inlineNodes {
            switch inlineNode {
            case .text(let content):
                visitText(content)
            case .softBreak:
                break
            case .lineBreak:
                break
            case .code(let content):
                visitCode(content)
            case .html(let content):
                text.append(content)
            case .emphasis(let inlineNodes):
                visitEmphasis(inlineNodes)
            case .strong(let inlineNodes):
                visitStrong(inlineNodes)
            case .strikethrough(let inlineNodes):
                visitStrikethrough(inlineNodes)
            case .link(let destination, let inlineNodes):
                visitLink(destination: destination, inlineNodes: inlineNodes)
            case .image(let source, let inlineNodes):
                visitImage(imageId: source, inlineNodes: inlineNodes)
            }
        }
    }
    
    private func visitBlockquote(_ blockNodes: [BlockNode]) {
        var blockquote: JSON = JSON()
        blockquote[TYPE].stringValue = Element.blockquote.rawValue
        
        contentStack.append([])
        
        visitBlockNodes(blockNodes)
        
        var contentArray = contentStack.popLast()
        blockquote[CONTENT] = JSON(contentArray ?? [])
        appendToContentStackLastItem(blockquote)
    }
    
    private func visitBulletedList(_ rawListItems: [RawListItem]) {
        var bulletedList: JSON = JSON()
        bulletedList[TYPE].stringValue = Element.list.rawValue
        
        contentStack.append([])
        
        for rawListItem in rawListItems {
            visitBlockNodes(rawListItem.children)
        }
        
        var contentArray = contentStack.popLast()
        bulletedList[CONTENT] = JSON(contentArray ?? [])
        bulletedList[IS_ORDERED_LIST].boolValue = false
        appendToContentStackLastItem(bulletedList)
    }
    
    private func visitNumberedList(_ rawListItems: [RawListItem]) {
        var numberedList: JSON = JSON()
        numberedList[TYPE].stringValue = Element.list.rawValue
        
        contentStack.append([])
        
        for rawListItem in rawListItems {
            visitBlockNodes(rawListItem.children)
        }
        
        var contentArray = contentStack.popLast()
        numberedList[CONTENT] = JSON(contentArray ?? [])
        numberedList[IS_ORDERED_LIST].boolValue = true
        appendToContentStackLastItem(numberedList)
    }
    
    private func visitTaskList(_ rawListItems: [RawTaskListItem]) {
        var taskList: JSON = JSON()
        taskList[TYPE].stringValue = Element.list.rawValue
        
        contentStack.append([])
        
        for rawListItem in rawListItems {
            visitBlockNodes(rawListItem.children)
        }
        
        var contentArray = contentStack.popLast()
        taskList[CONTENT] = JSON(contentArray ?? [])
        taskList[IS_ORDERED_LIST].boolValue = false
        appendToContentStackLastItem(taskList)
    }
    
    private func visitCodeBlock(_ content: String) {
        var codeBlock: JSON = JSON()
        codeBlock[TYPE].stringValue = Element.codeBlock.rawValue
        
        var contentArray: [JSON] = []
        let codeLines = content.split(separator: "\n").map { String($0) }
        for codeLine in codeLines {
            var codeLineContent: JSON = JSON()
            codeLineContent[TYPE].stringValue = Element.raw.rawValue
            codeLineContent[TEXT].stringValue = codeLine
            contentArray.append(codeLineContent)
        }
        
        codeBlock[CONTENT] = JSON(contentArray)
        appendToContentStackLastItem(codeBlock)
    }
    
    private func visitHtmlBlock(_ content: String) {
        var htmlBlock: JSON = JSON()
        htmlBlock[TYPE].stringValue = Element.paragraph.rawValue
        
        var contentArray: [JSON] = []
        var htmlContent: JSON = JSON()
        htmlContent[TYPE].stringValue = Element.text.rawValue
        htmlContent[TEXT].stringValue = content
        contentArray.append(htmlContent)
        
        htmlBlock[CONTENT] = JSON(contentArray)
        appendToContentStackLastItem(htmlBlock)
    }
    
    private func visitParagraph(_ inlineNodes: [InlineNode]) {
        var paragraph: JSON = JSON()
        paragraph[TYPE].stringValue = Element.paragraph.rawValue
        
        contentStack.append([])
        
        visitInlineNodes(inlineNodes)
        
        var contentArray = contentStack.popLast() ?? []
        
        if !text.isEmpty {
            var textContent: JSON = JSON()
            textContent[TYPE].stringValue = Element.text.rawValue
            textContent[TEXT].stringValue = text
            
            if !formats.isEmpty {
                var requiredFormats: [[Int]] = []
                for format in formats {
                    requiredFormats.append(format)
                }
                textContent[FORMAT] = JSON(requiredFormats)
            }
            
            contentArray.append(textContent)
        }
        
        paragraph[CONTENT] = JSON(contentArray)
        appendToContentStackLastItem(paragraph)
        
        formats.removeAll()
        text.removeAll()
    }
    
    private func appendToContentStackLastItem(_ json: JSON) {
        if let lastIndex = contentStack.indices.last {
            contentStack[lastIndex].append(json)
        }
    }
    
    private func visitHeading(level: Int, inlineNodes: [InlineNode]) {
        var heading: JSON = JSON()
        heading[TYPE].stringValue = Element.heading.rawValue
        heading[LEVEL].intValue = level
        
        contentStack.append([])
        
        visitInlineNodes(inlineNodes)
        
        var contentArray = contentStack.popLast() ?? []
        
        if !text.isEmpty {
            var textContent: JSON = JSON()
            textContent[TYPE].stringValue = Element.raw.rawValue
            textContent[TEXT].stringValue = text
            
            contentArray.append(textContent)
        }
        
        let convertedContentArray = convertToRawTextJSONObject(contentArray: contentArray)
        heading[CONTENT] = JSON(convertedContentArray)
        appendToContentStackLastItem(heading)
        
        formats.removeAll()
        text.removeAll()
    }
    
    private func convertToRawTextJSONObject(contentArray: [Any]) -> [Any] {
        var newContentArray: [Any] = []
        for element in contentArray {
            var json = JSON(element)
            if json[TYPE].stringValue == Element.text.rawValue {
                json[TYPE].stringValue = Element.raw.rawValue
                newContentArray.append(json.arrayValue)
            } else {
                newContentArray.append(element)
            }
        }
        return newContentArray
    }
    
    private func visitTable(columnAlignments: [RawTableColumnAlignment], rows: [RawTableRow]) {
        var table: JSON = JSON()
        table[TYPE].stringValue = Element.table.rawValue
        
        contentStack.append([])
        if !rows.isEmpty {
            visitRawTableHead(row: rows[0], columnAlignments: columnAlignments)
        }
        let headArray = contentStack.popLast() ?? []
        table[TABLE_HEADER_CONTENT] = JSON(headArray)
        
        contentStack.append([])
        
        for (i, row) in rows.enumerated() {
            if i != 0 {
                visitRawTableRow(row: row, columnAlignments: columnAlignments)
            }
        }
        
        let contentArray = contentStack.popLast() ?? []
        table[CONTENT] = JSON(contentArray)
        
        appendToContentStackLastItem(table)
        
        formats.removeAll()
        text.removeAll()
    }
    
    private func visitRawTableHead(row: RawTableRow, columnAlignments: [RawTableColumnAlignment]) {
        for (cell, columnAlignment) in zip(row.cells, columnAlignments) {
            visitRawTableCell(cell: cell, columnAlignment: columnAlignment)
        }
    }
    
    private func visitRawTableRow(row: RawTableRow, columnAlignments: [RawTableColumnAlignment]) {
        contentStack.append([])
        
        for (cell, columnAlignment) in zip(row.cells, columnAlignments) {
            visitRawTableCell(cell: cell, columnAlignment: columnAlignment)
        }
        
        let contentArray = contentStack.popLast() ?? []
        appendToContentStackLastItem(JSON(contentArray))
    }
    
    private func visitRawTableCell(cell: RawTableCell, columnAlignment: RawTableColumnAlignment) {
        var cellJSON: JSON = JSON()
        contentStack.append([])
        
        visitInlineNodes(cell.content)
        
        var contentArray = contentStack.popLast() ?? []
        
        if !text.isEmpty {
            var textContent: JSON = JSON()
            textContent[TYPE].stringValue = Element.text.rawValue
            textContent[TEXT].stringValue = text
            
            if !formats.isEmpty {
                var requiredFormats: [[Int]] = []
                for format in formats {
                    requiredFormats.append(format)
                }
                textContent[FORMAT] = JSON(requiredFormats)
            }
            
            contentArray.append(textContent)
        }
        
        cellJSON[CONTENT] = JSON(contentArray)
        switch columnAlignment {
        case .none:
            cellJSON[TABLE_CELL_ALIGNMENT].stringValue = TABLE_CELL_ALIGNMENT_LEFT
        case .left:
            cellJSON[TABLE_CELL_ALIGNMENT].stringValue = TABLE_CELL_ALIGNMENT_LEFT
        case .center:
            cellJSON[TABLE_CELL_ALIGNMENT].stringValue = TABLE_CELL_ALIGNMENT_CENTER
        case .right:
            cellJSON[TABLE_CELL_ALIGNMENT].stringValue = TABLE_CELL_ALIGNMENT_RIGHT
        }
        appendToContentStackLastItem(cellJSON)
        
        formats.removeAll()
        text.removeAll()
    }
    
    private func visitText(_ content: String) {
        self.text += content
    }
    
    private func visitCode(_ content: String) {
        var code: [Int] = []
        code.append(Format.inlineCode.rawValue)
        code.append(text.count)
        code.append(content.count)
        formats.append(code)
        
        text.append(content)
    }
    
    private func visitEmphasis(_ inlineNodes: [InlineNode]) {
        if let firstChild = inlineNodes.first {
            let formatArray = getFormatArray(initialFormatNum: Format.italics.rawValue, inlineNode: firstChild)
            if let formatArray {
                formats.append(formatArray)
            }
        }
    }
    
    private func visitStrong(_ inlineNodes: [InlineNode]) {
        if let firstChild = inlineNodes.first {
            let formatArray = getFormatArray(initialFormatNum: Format.bold.rawValue, inlineNode: firstChild)
            if let formatArray {
                formats.append(formatArray)
            }
        }
    }
    
    private func visitStrikethrough(_ inlineNodes: [InlineNode]) {
        if let firstChild = inlineNodes.first {
            let formatArray = getFormatArray(initialFormatNum: Format.strikethrough.rawValue, inlineNode: firstChild)
            if let formatArray {
                formats.append(formatArray)
            }
        }
    }
    
    private func getFormatArray(initialFormatNum: Int, inlineNode: InlineNode) -> [Int]? {
        var formatNum = initialFormatNum
        var node: InlineNode? = inlineNode
        while let temp = node {
            switch temp {
            case .text(let content):
                let start = text.count
                text.append(content)
                
                if formatNum > 0 {
                    var format: [Int] = []
                    format.append(formatNum)
                    format.append(start)
                    format.append(content.count)
                    return format
                }
                node = nil
            case .softBreak:
                node = nil
            case .lineBreak:
                node = nil
            case .code(let content):
                formatNum += Format.inlineCode.rawValue
                let start = text.count
                text.append(content)
                
                if formatNum > 0 {
                    var format: [Int] = []
                    format.append(formatNum)
                    format.append(start)
                    format.append(content.count)
                    return format
                }
                node = nil
            case .html(let content):
                let start = text.count
                text.append(content)
                
                if formatNum > 0 {
                    var format: [Int] = []
                    format.append(formatNum)
                    format.append(start)
                    format.append(content.count)
                    return format
                }
                node = nil
            case .emphasis(let children):
                formatNum += Format.italics.rawValue
                node = children.first
            case .strong(let children):
                formatNum += Format.bold.rawValue
                node = children.first
            case .strikethrough(let children):
                formatNum += Format.strikethrough.rawValue
                node = children.first
            case .link(let destination, let children):
                node = children.first
            case .image(let source, let children):
                node = children.first
            }
        }
        
        return nil
    }
    
    private func visitLink(destination: String, inlineNodes: [InlineNode]) {
        if !text.isEmpty {
            var textContent = JSON()
            textContent[TYPE].stringValue = Element.text.rawValue
            textContent[TEXT].stringValue = text
            if !formats.isEmpty {
                var requiredFormats: [[Int]] = []
                for format in formats {
                    requiredFormats.append(format)
                }
                textContent[FORMAT] = JSON(requiredFormats)
            }
            
            appendToContentStackLastItem(textContent)
            
            formats.removeAll()
            text.removeAll()
        }
        
        //Construct link object
        var link: JSON = JSON()
        link[TYPE].stringValue = Element.link.rawValue
        
        visitInlineNodes(inlineNodes)
        
        link[TEXT].stringValue = text
        link[URL].stringValue = destination
        if !formats.isEmpty {
            var requiredFormats: [[Int]] = []
            for format in formats {
                requiredFormats.append(format)
            }
            link[FORMAT] = JSON(requiredFormats)
        }
        
        appendToContentStackLastItem(link)
        
        formats.removeAll()
        text.removeAll()
    }
    
    private func visitImage(imageId: String, inlineNodes: [InlineNode]) {
        var image: JSON = JSON()
        image[TYPE].stringValue = Element.image.rawValue
        image[IMAGE_ID].stringValue = imageId
        image[CONTENT].stringValue = getImageCaption(currentCaption: "", inlineNodes: inlineNodes)
        contentStack[0].append(image)
    }
    
    private func getImageCaption(currentCaption: String, inlineNodes: [InlineNode]) -> String {
        var caption = currentCaption
        for inlineNode in inlineNodes {
            switch inlineNode {
            case .text(let content):
                caption.append(content)
            case .softBreak:
                break
            case .lineBreak:
                break
            case .code(let content):
                caption.append(content)
            case .html(let content):
                caption.append(content)
            case .emphasis(let inlineNodes):
                return getImageCaption(currentCaption: caption, inlineNodes: inlineNodes)
            case .strong(let inlineNodes):
                return getImageCaption(currentCaption: caption, inlineNodes: inlineNodes)
            case .strikethrough(let inlineNodes):
                return getImageCaption(currentCaption: caption, inlineNodes: inlineNodes)
            case .link:
                break
            case .image:
                break
            }
        }
        
        return caption
    }
}
