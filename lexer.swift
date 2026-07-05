import Foundation 


class Location {
    let file_path: String
    let row: Int 
    let col: Int 
    init(_ f: String, _ r: Int, _ c: Int) {
        file_path = f
        row = r
        col = c
    }
}

enum IdentifierKind {
    case Function   // functions end w/   ! [foo!]
    case Interfix   // operators start w/ * [*foo]
    case Atom       // atoms start w/     . [.foo]
    case Containers // containers         ∅ [ foo]
}

enum TokenKind {
    case Identifier(addr: [String], kind: IdentifierKind) // array for namespaces. `foo::bar` == ['foo','bar']
    case     String(content: String)
    case      Colon
    case     LCurly
    case     RCurly
    case   LBRacket
    case   RBracket
}

class Token {
    let kind: TokenKind
    let loc: Location

    init(_ k: TokenKind, _ l: Location) {
        kind = k
        loc = l
    }

    func display() -> String {
        return "\(kind)"
    }

}



class Lexer {
    let file_path: String
    let source: String
    
    var cur: Int
    var row: Int
    var bol: Int

    init(_ f: String, _ s: String) {
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
        return Location(file_path, row, cur - bol)
    }


    func next_token() -> Token {
        trim_left()
        
        //TODO handle comments (drop line if it starts with #)
        print("PANIC: NOTIMPLEMENTEDDDDDDDDDDDDD")
        exit(69)
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

    let lexer = Lexer(sourcefile, source)
    let tokens = tokenize(lexer)
    for token in tokens {
        print(token.display())
    }
}


func tokenize(_ lexer: Lexer) -> [Token] {
    var tokens = [Token]()
    while (!lexer.is_empty()) {
        let tok = lexer.next_token()
        tokens.append(tok)
    }

    return tokens 
}  
main()
