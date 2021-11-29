import Foundation
import SpriteKit

//func stateToFEN(state: BoardState) -> String {
//
//}

enum Orientation {
    case white, black
}

let alphas = Array("abcdefgh")

// NOTE: This is probably broken since the board is reversable
func nameToPosition(name: String) -> (x: Int, y: Int)? {
    guard name.count == 2 else { return nil }
    
    guard let x: Int = alphas.firstIndex(of: name.first!) else { return nil }
    guard var y: Int = Int(String(name.last!)) else { return nil }
    guard y >= 1,  y <= 8 else { return nil }
    y -= 1
    
    return (x, y)
}

let ROWS = 8
let COLS = 8

class BoardScene: SKScene {
    // TODO: This should be an arg from the game manager
    let moveGenerator: MoveGenerator = MoveGenerator.init("")
    var orientation: Orientation = .white
    
    func positionToName(x: Int, y: Int) -> String {
        var col = x
        var row = y
        
        if (orientation == .black) {
            col = COLS - 1 - col
            row = ROWS - 1 - row
        }
        
        return "\(alphas[col])\(row + 1)"
    }
        
    override func didMove(to view: SKView) {
        drawBoard()
        drawPieces(state: moveGenerator.board())
    }
    
    func drawBoard() {
        let squareSize = CGSize(
            width: self.size.width / CGFloat(COLS),
            height: self.size.height / CGFloat(ROWS)
        )
        
        // TODO: Figure out what the actual algorithm here is
        let xOffset: CGFloat = 19
        let yOffset: CGFloat = 19
            
        for row in 0 ..< ROWS {
            for col in 0 ..< COLS {
                let color = (row + col) % 2 != 0
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
        let reverse = orientation == .white
        
        for (rowNum, row) in (reverse ? state.reversed().enumerated() : state.enumerated()) {
            for (colNum, col) in (reverse ? row.reversed().enumerated() : row.enumerated()) {
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
    
    func locationToPosition(location: CGPoint) -> (Int, Int) {
        // Divide x and y coords by board size and then round down to get position
        let x = Int(((location.x / self.size.width) * CGFloat(COLS)).rounded(.down))
        let y = Int(((location.y / self.size.height) * CGFloat(ROWS)).rounded(.down))
        
        return (x, y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let (x, y) = locationToPosition(location: location)
        let positionName = positionToName(x: x, y: y)
        
        print("location: \(location.x), \(location.y)")
        print("position: \(x), \(y)")
        print("positionName: \(positionName)")
        
        let movesForPiece = moveGenerator.moves(for: positionName)
        print("moves for peice \(positionName)")
        for move in movesForPiece {
            print(move.to)
            guard let moveSquare: SKSpriteNode = self.childNode(withName: move.to) as? SKSpriteNode else { return }
            moveSquare.color = SKColor(.green)
        }
        
        guard let square: SKSpriteNode = self.childNode(
            withName: positionName
        ) as? SKSpriteNode else { return }
        square.color = SKColor(.red)
        
        
    }
}
