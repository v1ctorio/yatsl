import Foundation 


class Location {
    let file_path: String
    let row: Int 
    let col: Int 
    init(f: String, r: Int, c: Int) {
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

    func curI() -> String.Index {
        return source.index(source.startIndex, offsetBy: cur)
    }

    func char()->Character {
        return source[curI()]
    } 

    func is_empty() -> Bool {
        return cur >= source.count
    }

    func consume() {
        if (!is_empty()) {
            let c = char() //TODO maybe i could use String.Index for cursors instead of ints

            cur += 1
            if (c == "\n"){
                bol = cur
                row += 1
            }
        }
    }

    func trim_left() {
        while(!is_empty() && char().isWhitespace) {
            consume()
        }
    }
    
    func loc() -> Location {
        return Location(f: file_path, r: row, c: cur - bol)
    }


    func next_token() {
        trim_left()
        
        //TODO handle comments (drop line if it starts with #)
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
