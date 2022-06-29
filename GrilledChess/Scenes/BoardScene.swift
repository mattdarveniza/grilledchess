import Foundation
import SpriteKit

class BoardScene: SKScene {
    enum Orientation {
        case white, black
    }

    let alphas = Array("abcdefgh")
    let ROWS = 8
    let COLS = 8

    enum Z_INDICES: CGFloat {
        case square = 1, squareHighlight, piece, pieceMoves
    }
    
    let moveGenerator: MoveGenerator
    let orientation: Orientation

    
    init(gameFen: String = "", orientation: Orientation = .white) {
        moveGenerator = MoveGenerator.init(gameFen)
        self.orientation = orientation
        super.init(size: CGSize(width: 1, height: 1));
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var squareSize: CGSize {
        get {
            return CGSize(
                width: self.size.width / CGFloat(COLS),
                height: self.size.height / CGFloat(ROWS)
            )
        }
    }
    
    func positionToName(x: Int, y: Int) -> String {
        var col = x
        var row = y
        
        if (orientation == .black) {
            col = COLS - 1 - col
            row = ROWS - 1 - row
        }
        
        return "\(alphas[col])\(row + 1)"
    }
    
    func nameToPosition(name: String) -> (x: Int, y: Int)? {
        guard name.count == 2 else { return nil }
        
        guard var x: Int = alphas.firstIndex(of: name.first!) else { return nil }
        guard var y: Int = Int(String(name.last!)) else { return nil }
        guard y >= 1,  y <= 8 else { return nil }
        y -= 1
        
        if (orientation == .black) {
            x = COLS - 1 - x
            y = ROWS - 1 - y
        }
        
        return (x, y)
    }
    
        
    override func didMove(to view: SKView) {
        drawBoard()
        drawPieces(state: moveGenerator.board())
    }
    
    func drawBoard() {
        let squareSize = squareSize
        
        // TODO: Figure out what the actual algorithm here is
        let xOffset: CGFloat = squareSize.width / 2
        let yOffset: CGFloat = squareSize.height / 2
            
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
                square.zPosition = Z_INDICES.square.rawValue
                self.addChild(square)
                
                // debug text
//                let texts = [SKLabelNode(text: square.name), SKLabelNode(text: "\(col):\(row)")]
//                for (i, text) in texts.enumerated() {
//                    text.fontSize = 20
//                    text.position = CGPoint(x: square.position.x, y: square.position.y - CGFloat(i * 20))
//                    text.zPosition = 100;
//                    text.fontColor = SKColor.red
//                    self.addChild(text)
//                }
            }
        }
    }
    
    func drawPieces(state: BoardState) {
        let reverse = orientation == .black
        
        for (rowNum, row) in (reverse ? state.enumerated() : state.reversed().enumerated()) {
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
                piece.name = pieceId
                piece.xScale = scale
                piece.yScale = scale
                piece.zPosition = Z_INDICES.piece.rawValue
                
                self.addChild(piece)
            }
        }
    }
    
    func pieceAt(position: String) -> String? {
        let (x, y) = nameToPosition(name: position)!
        return pieceAt(x: x, y: y)
    }
    
    func pieceAt(x: Int, y: Int) -> String? {
        let reverse = orientation == .black
        
        let state = moveGenerator.board()
        
        let row = (reverse ? state : state.reversed())[y]
        let piece = (reverse ? row.reversed() : row)[x]
        
        return piece
    }
    
    func locationToPosition(location: CGPoint) -> (Int, Int) {
        // Divide x and y coords by board size and then round down to get position
        let x = Int(((location.x / self.size.width) * CGFloat(COLS)).rounded(.down))
        let y = Int(((location.y / self.size.height) * CGFloat(ROWS)).rounded(.down))
        
        return (x, y)
    }
}
