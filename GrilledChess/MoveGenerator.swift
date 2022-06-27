//
//  MoveGeneator.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 15/11/21.
//

import Foundation
import JavaScriptCore

//struct BoardPiece: Codable {
//    var type: String
//    var color: String
//}

typealias BoardState = [[String?]]

struct Move: Decodable {
    enum Color: String, Decodable {
        case w, b
    }
    
    // NOTE: This could be any _combination_ of these flags, not just an individual one
//    enum Flags: String, Decodable {
//        case n, b, e, c, p, k, q
//    }
    
    enum Piece: String, Decodable {
        case p, r, n, b, k, q
    }
    
    let from: String
    let to: String
    let san: String
    let color: Color
    let piece: Piece
    
    let flags: String
    let captured: String?
    let promoted: String?
}

class MoveGenerator {
    let context = JSContext()
    let decoder = JSONDecoder()
    
    init(_ gameState: String) {
        guard let chessJSPath = Bundle.main.path(forResource: "chess", ofType: "js") else {
            print("could not find chess.js")
            return
        }
        
        do {
            let chessJSContent = try String(contentsOfFile: chessJSPath)
            context?.evaluateScript(chessJSContent)
        } catch {
            print("could not parse chess.js file")
        }
        
        context?.evaluateScript("var chess = Chess(\(gameState))")
    }
    
    func moves(for square: String) -> [Move] {
        let result = context?.evaluateScript("JSON.stringify(chess.moves({ square: '\(square)', verbose: true }))")
        return parseJSResult(value: result)
    }
    
    func move(to: String) -> Move {
        let result = context?.evaluateScript("JSON.stringify(chess.move('\(to)'))")
        return parseJSResult(value: result)
    }
    
    
    private func parseJSResult<T: Decodable>(value: JSValue!) -> T {
        return try! decoder.decode(T.self, from: value.toString().data(using: .utf8)!)
    }
    
    func board() -> BoardState {
        let result = context?.evaluateScript("chess.board()").toArray() as! [[Dictionary<String, String>?]]
        
        return result.map({
            row in row.map({
                col in col == nil ? nil : "\(col!["color"]!)\(col!["type"]!.uppercased())"
            })
        })
    }
}
