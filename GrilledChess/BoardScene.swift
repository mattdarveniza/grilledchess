import Foundation
import SpriteKit

enum Orientation {
    case white, black
}

struct Selection {
    let position: String
    let piece: String?
    let moves: [Move]
}

let alphas = Array("abcdefgh")
let ROWS = 8
let COLS = 8

enum Z_INDICES: CGFloat {
    case square = 1, squareHighlight, piece, pieceMoves
}

class BoardScene: SKScene {
    // TODO: This should be an arg from the game manager
    let moveGenerator: MoveGenerator = MoveGenerator.init("")

    var selectionIndicators: [SKNode] = []
    
    var selection: Selection?
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
    
//    var squareSize: CGSize {
//        get {
//            return CGSize(
//                width: self.size.width / CGFloat(COLS),
//                height: self.size.height / CGFloat(ROWS)
//            )
//        }
//    }
    
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
                square.zPosition = Z_INDICES.square.rawValue
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
        let reverse = orientation == .white
        
        let state = moveGenerator.board()
        
        let row = (reverse ? state.reversed() : state)[y]
        let piece = (reverse ? row.reversed() : row)[x]
        
        return piece
    }
    
    func locationToPosition(location: CGPoint) -> (Int, Int) {
        // Divide x and y coords by board size and then round down to get position
        let x = Int(((location.x / self.size.width) * CGFloat(COLS)).rounded(.down))
        let y = Int(((location.y / self.size.height) * CGFloat(ROWS)).rounded(.down))
        
        return (x, y)
    }
    
    func clearSelection() {
        selection = nil;
        for node in selectionIndicators {
            node.removeFromParent()
        }
        
        selectionIndicators = []
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
        
        if let m = selection?.moves.first(where: { move in move.to == positionName }) {
            move(to: m.san)
            clearSelection()
        } else {
            // clear previous selection
            if (selection != nil) {
                clearSelection()
            }
            
            
            if let piece = pieceAt(position: positionName) {
                selection = Selection(
                    position: positionName,
                    piece: piece,
                    moves: moveGenerator.moves(for: positionName)
                )
                highlightPiece(positionName: positionName)
            }
        }
    }
    
    func highlightPiece(positionName: String) {
        // Highlight square
        guard let square: SKSpriteNode = self.childNode(
            withName: positionName
        ) as? SKSpriteNode else { return }
        let squareHighlight = SKSpriteNode(color: SKColor(red: 0.3, green: 0.5, blue: 1, alpha: 0.5), size: square.size)
        squareHighlight.position = square.position
        squareHighlight.zPosition = Z_INDICES.squareHighlight.rawValue
        addChild(squareHighlight)
        selectionIndicators.append(squareHighlight)
        
        // Draw valid moves for piece
        let movesForPiece = moveGenerator.moves(for: positionName)
        print("moves for peice \(positionName)")
        for move in movesForPiece {
            print(move.to)
            guard let moveSquare: SKSpriteNode = self.childNode(withName: move.to) as? SKSpriteNode else { return }
            let moveIndicator = SKShapeNode(circleOfRadius: moveSquare.size.width / 6)
            moveIndicator.position = moveSquare.position
            moveIndicator.fillColor = SKColor(white: 1, alpha: 0.5)
            moveIndicator.strokeColor = SKColor.clear
            moveIndicator.zPosition = Z_INDICES.pieceMoves.rawValue
            addChild(moveIndicator)
            selectionIndicators.append(moveIndicator)
        }
        if movesForPiece.isEmpty {
            print("-");
        }
    }
    
    func move(to: String) {
        let moveResult = moveGenerator.move(to: to)
        let pieceName = "\(moveResult.color.rawValue)\((moveResult.piece.rawValue).uppercased())"
        
        guard let oldSquare = self.childNode(
            withName: moveResult.from
        ) else { return }

        guard let newSquare = self.childNode(
            withName: moveResult.to
        ) else { return }
        
        self.enumerateChildNodes(withName: pieceName) {pieceNode, _ in
            if (pieceNode.position == oldSquare.position) {
                pieceNode.position = newSquare.position
            }
        }
        
        // remove opposing piece if move is an attack
        if let captured = moveResult.captured {
            let capturedPieceName = "\(moveResult.color == .w ? Move.Color.b : Move.Color.w )\(captured.uppercased())"
            
            var capturedPosition = CGPoint(x: newSquare.position.x, y: newSquare.position.y)
            // if en-passante, captured piece is one y position back or forward depending on color
            // TODO: Test this
            if (moveResult.flags.contains("e")) {
                capturedPosition.y += (moveResult.color == .w ? -1 : 1)
            }
            
            self.enumerateChildNodes(withName: capturedPieceName) {pieceNode, _ in
                if pieceNode.position == capturedPosition {
                    pieceNode.removeFromParent()
                }
            }
        }
    }
}
