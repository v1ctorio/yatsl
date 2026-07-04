import Foundation 


class Location {
    let file_path: String
    let row: String
    let col: String
    init(f: String, r: String, c: String) {
        file_path = f
        row = r
        col = c
    }
}


enum TokenKind {
    case TName
    case TString
    case TLCurly
    case TRCurly
}

class Token {
    let kind: TokenKind
    let value: String //TODO: aggregate type for values (?)
    let loc: Location

    init(_kind: TokenKind, _value: String, _loc: Location) {
        kind = _kind
        value = _value
        loc = _loc
    }

}



class Lexer {
    let file_path: String
    let source: String
    
    var cur: Int
    var row: Int
    var bol: Int

    init(f: String, s: String) {
        file_path = f
        source = s 
        cur = 0
        row = 0
        bol = 0
    }


    func is_empty() -> Bool {
        return cur >= source.count
    }
} 

func main() {

    if CommandLine.arguments.count < 2 {
        print("ERROR: no input file provided")
        exit(33)
    }
    let sourcefile = CommandLine.arguments[1]
    let sourceurl = URL(fileURLWithPath: sourcefile)
    guard let source = try? String(contentsOf: sourceurl) else {
        print("ERROR: unable to read \(sourcefile)")
        exit(33)
    }
    print(source)
}


main()
