import Foundation
import SpriteKit

typealias BoardState = [[String?]]

func initialState() -> BoardState {
    [
        ["wR", "wN", "wB", "wQ", "wK", "wB", "wN", "wR"],
        Array(repeating: "wP", count: 8),
        Array(repeating: nil, count: 8),
        Array(repeating: nil, count: 8),
        Array(repeating: nil, count: 8),
        Array(repeating: nil, count: 8),
        Array(repeating: "bP", count: 8),
        ["bR", "bN", "bB", "bQ", "bK", "bB", "bN", "bR"],
    ]
}

let alphas = Array("abcdefgh")

func positionToName(x: Int, y: Int) -> String {
    return "\(alphas[y])\(x + 1)"
}

func nameToPosition(name: String) -> (x: Int, y: Int)? {
    guard name.count == 2 else { return nil }
    
    guard let x: Int = alphas.firstIndex(of: name.first!) else { return nil }
    guard var y: Int = Int(String(name.last!)) else { return nil }
    guard y >= 1,  y <= 8 else { return nil }
    y -= 1
    
    return (x, y)
}

class BoardScene: SKScene {
    // TODO: This should be an arg from the game manager
    var boardState: BoardState = initialState()
        
    override func didMove(to view: SKView) {
        drawBoard()
        drawPieces(state: boardState)
    }
    
    func drawBoard() {
        let rows = 8
        let cols = 8
        
        let squareSize = CGSize(
            width: self.size.width / CGFloat(cols),
            height: self.size.height / CGFloat(rows)
        )
        
        let xOffset: CGFloat = 16
        let yOffset: CGFloat = 16
        
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let color = (row + col) % 2 == 0
                    ? SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
                    : SKColor.black
                
                let square = SKSpriteNode(color: color, size: squareSize)
                square.position = CGPoint(
                    x: CGFloat(col) * squareSize.width + xOffset,
                    y: CGFloat(row) * squareSize.height + yOffset)
                square.name = positionToName(x: col, y: row)
                self.addChild(square)
            }
        }
    }
    
    func drawPieces(state: BoardState) {
        for (rowNum, row) in state.enumerated() {
            for (colNum, col) in row.enumerated() {
                guard let pieceId = col else { continue }
                guard let square = self.childNode(
                    withName: positionToName(x: colNum, y: rowNum)
                ) else { return }

                let piece = SKSpriteNode(imageNamed: pieceId)
                piece.position = square.position
                let scale = min(
                    square.frame.width / piece.frame.width,
                    square.frame.height / piece.frame.height
                )
                piece.xScale = scale
                piece.yScale = scale
                
                self.addChild(piece)
            }
        }
    }
}
