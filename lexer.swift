import Foundation 

//TODO use exceptions for lexing error and show pretty error msgs
//TODO remove all debugP



/*extension Character {
    var isValidIdentifierContent: Bool {
        return self.isLetter || self.isNumber || self == "!" 
    } 
}*/

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
        return "Loc(r: \(row+1), c: \(col+1))"
    }
}

enum IdentifierKind {
    case Function   // functions end w/   ! [foo!]
    case Interfix   // operators start w/ * [*foo]
    case Atom       // atoms start w/     . [.foo]
    case Container  // containers         ∅ [ foo]
}

enum TokenKind {
    case Identifier(addr: [String], kind: IdentifierKind) // array for namespaces. `foo::bar` == ['foo','bar']
    case     String(content: String)
    case      Colon
    case     LCurly
    case     RCurly
    case   LBRacket
    case   RBracket
    case        EOF
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
            debugP("trim_left(): finished trimming up to loc = \(loc()); c = \(char().asciiValue!)")
        }
    }
    
    func loc() -> Location {
        return Location(file_path, row, cur - bol)
    }


    func next_token() -> Token {
        trim_left()

         
        if char() == "#" {
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

        

        if first.isLetter {
            let start_i = curI()
            //TODO support namespaces (foo::bar)
            while !is_empty() {
                let c = char()
                if (!c.isLetter && !c.isNumber) { break }
                consume()
            }
            let val = String(source[start_i..<curI()])
            debugP("tokenized name: \(val)")
            
            var id_kind = IdentifierKind.Container
            if char() == "!" {
                id_kind = IdentifierKind.Function
                consume()
            }

            return Token(
                .Identifier(addr: [val], kind: id_kind),
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
                UNREACHABLE("ERROR: expected string, found EOF")
            }
            let content = String(source[start_i..<curI()])
            consume()

            return Token(.String(content:content),location)
        }
        
        UNREACHABLE("not implemented first = \(first.asciiValue ?? 69)")
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
    debugP("-----------")

    let lexer = Lexer(sourcefile, source)
    let tokens = tokenize(lexer)
    
    debugP("-----------")
    var i = 0
    for token in tokens {
        print("\(i): \(token.display())")
        i += 1
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


func UNREACHABLE(_ msg: String) -> Never {
    print("""
    UNREACHABLE REACHED (???): \(msg)
    """)
    exit(69)
}

func debugP(_ msg: String) {
    print(msg)
}
