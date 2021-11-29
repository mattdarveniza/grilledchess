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
    
    enum Flags: String, Decodable {
        case n, b, e, c, p, k, q
    }
    
    enum Piece: String, Decodable {
        case p, r, n, b, k, q
    }
    
    let from: String
    let to: String
    let san: String
    let color: Color
    let flags: Flags
    let piece: Piece
}

class MoveGenerator {
    let context = JSContext()
    
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
        let result = context?.evaluateScript("JSON.stringify(chess.moves({ square: '\(square)', verbose: true }))").toString()
        let parsed = try! JSONDecoder().decode([Move].self, from: result!.data(using: .utf8)!)
        return parsed
    }
    
    func move(to: String) {
        context?.evaluateScript("chess.move('\(to)')")
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
