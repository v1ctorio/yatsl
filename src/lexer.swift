import Foundation 

//TODO use exceptions for lexing error and show pretty error msgs
//TODO remove all debugP


extension Character {
    var isValidIdentifierContent: Bool {
        return (self.isLetter || self.isNumber || self.isSymbol || self == "_" || self == "*") && self != "!" && self != "|" && self != "."
    } 
}

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
extension Location: CustomStringConvertible {
    var description: String {
        return "\(file_path):\(row+1):\(col+1)"
    }
}

enum IdentifierKind {
    case Function   // functions end w/   ! [foo!]
    case Interfix   // operators start w/ | [|foo]
    case Atom       // atoms start w/     . [.foo]
    case Container  // containers         ∅ [ foo]
}

enum TokenKind {
    case Identifier(addr: [String], kind: IdentifierKind) // array for namespaces. `foo::bar` == ['foo','bar']
    case     String(content: String)
    case    Integer(value: Int)
    case      Colon
    case     LCurly
    case     RCurly
    case   LBracket
    case   RBracket
    case     LParen
    case     RParen
    case        EOF
}

let singleCharTokenMap: [Character: TokenKind] = [
    "{": .LCurly,
    "}": .RCurly,
    "[": .LBracket,
    "]": .RBracket,
    "(": .LParen,
    ")": .RParen,
    ",": .Colon
]

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
        if is_empty() {
            return "\n"
        }
        return source[curI()]
    } 

    func is_empty() -> Bool {
        return cur >= source.count
    }

    func consume() {
        if (!is_empty()) {
            let c = char() //TODO maybe i could use String.Index for cursors instead of ints
            debugP("consuming char#\(cur) [\(c.asciiValue ?? 69)]")

            cur += 1
            if (c == "\n"){
                bol = cur
                row += 1
            }
        }
    }

    func trim_left() {
        while(!is_empty() && char().isWhitespace) {
            debugP("trim_left(): trmming from \(char().asciiValue ?? 69)")
            consume()
            if (is_empty()) {
                debugP("trim_left(): finished trimming up to EOF")
            } else {
                debugP("trim_left(): finished trimming up to loc = \(loc()); c = \(char().asciiValue!)")
                }
        }
    }
    
    func loc() -> Location {
        return Location(file_path, row, cur - bol)
    }


    func next_token() throws -> Token {
        trim_left()
        
        if is_empty() {
            return Token(.EOF, loc())
        } 
         
        while char() == "#" {
            debugP("comment(): detected, dropping line")
            while !is_empty() {
                if char() == "\n" {
                    debugP("comment(): newline detected")
                    if (!is_empty()) {
                        consume()
                        trim_left()
                    }
                    break
                }
                if !is_empty() {
                    consume()
                }
            }
        }

        if is_empty() {
            return Token(.EOF, loc())
        } 
        

        let location = loc()
        let first    = char()
        debugP("next_token(): first = \(first.asciiValue ?? 69)")

        if let k = singleCharTokenMap[first] {
            consume()
            return Token(k, location)
        } 


        if first.isLetter {

            let val = try consumeIdentifier()
            debugP("tokenized name: \(val)")
            
            var id_kind = IdentifierKind.Container
            if char() == "!" {
                id_kind = IdentifierKind.Function
                consume()
            }

            return Token(
                .Identifier(addr: val, kind: id_kind),
                location
                )

        }

        if first == "|" {
            consume()

            let id = try consumeIdentifier()
            debugP("tokenized interfix: \(id)")

            return Token(
                .Identifier(addr: id, kind: .Interfix),
                location
            )
        }

        if first == "." {
            consume()

            let id = try consumeIdentifier()
            debugP("tokenized atom: .\(id)")

            return Token(
                .Identifier(addr: id, kind:.Atom),
                location
            )
        }



        if first == "\"" {
            consume()
            let start_i = curI()

            while !is_empty() {
                let c = char()
                //TODO: support escaping
                if c == "\"" { break }
                consume()
            }
            if is_empty() {
                throw LexingError.expectedDoublequoteFoundEOF
            }
            let content = String(source[start_i..<curI()])
            consume()

            return Token(.String(content:content),location)
        }

        if first.isNumber {
            let start_i = curI()

            while !is_empty() {
                let c = char()
                //TODO support for floats and _ separators
                if !c.isNumber { break }
                consume()
            }
            guard let content = Int(source[start_i..<curI()]) 
                                else {throw LexingError.numberParsing }
            return Token(.Integer(value:content),location) 
        }
        
        throw LexingError.unexpectedChar
    }
    
    func consumeIdentifier() throws(IdentifierConsumptionError) -> [String] {
        var id = [String]()
        guard !is_empty() else {throw .emptyIdentifier}
        guard char().isValidIdentifierContent else {throw .invalidIdentifierContent }
        while !is_empty() {
            let name = try consumeName()
            id.append(name)
            if char() == ":" {
                consume()
                guard !is_empty() else { throw .expectedColonFoundEOF }
                guard char() == ":" else { throw .expectedColonFoundChar } 
                consume()
            } else {
                break
            }
        }

        return id
    }

    func consumeName() throws(IdentifierConsumptionError) -> String {
        guard char().isValidIdentifierContent else {throw .invalidIdentifierContent }
        let start_i = curI()
        while !is_empty() {
            let c = char()
            if (!c.isValidIdentifierContent) { break }
            consume()
        }

        let name = String(source[start_i..<curI()])
        return name
    }

} 


func tokenize(_ lexer: Lexer) -> [Token] {
    var tokens = [Token]()
    while (!lexer.is_empty()) {
        do {
        let tok = try lexer.next_token() 
        tokens.append(tok)
        } catch let err {
            handleLexingError(error: err, lexer: lexer)
        }
    }

    return tokens 
}  


func UNREACHABLE(_ msg: String) -> Never {
    print("""
    UNREACHABLE REACHED (???): \(msg)
    """)
    exit(69)
}

func debugP(_ msg: String) {
    print(msg)
}


func handleLexingError(error: Error, lexer: Lexer) -> Never {
    //TODO print to stderr
    print("--------------")
    print("Exception thrown during token consumption")
    print("--------------")
    switch error {
        case let error as IdentifierConsumptionError: 
            let loc = lexer.loc()
            let relevantPoc = lexer.source
                .split(separator: "\n")[loc.row] 

            print("""

            \(loc.description)

            \(relevantPoc)
            \(String(repeating: " ", count: lexer.cur - lexer.bol))^

            """)
            switch error {
                case .expectedColonFoundChar: 
                    print("SyntaxError: expected `:`, found \(lexer.char())")
                case .expectedColonFoundEOF: 
                    print("SyntaxError: expected `:`, found EOF")
                default:
                    UNREACHABLE("")
            }
        default: 
            print("idk gng")
    }
    exit(1)
}

enum LexingError: Error {
    case expectedDoublequoteFoundEOF
    case unexpectedChar
    case numberParsing
}

enum IdentifierConsumptionError: Error {
    case expectedColonFoundChar
    case expectedColonFoundEOF
    case emptyIdentifier
    case invalidIdentifierContent
}
