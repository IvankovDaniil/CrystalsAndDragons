//
//  Game.swift
//  CrystalsAndDragons
//
//  Created by Даниил Иваньков on 26.06.2025.
//
import Foundation

class Game {
    
    let dungeon = Dungeon()
    var isGameOver = false
    
    lazy var gameCommand = GameCommands(dungeon: dungeon)
    
    func startGame() {
        
        while dungeon.numberOfRooms == -1 {
            dungeon.numberOfRooms = validateNumberOfRooms()
        }
        
        gameCommand.gameOverHandler = { [weak self] in
            self?.isGameOver = true
        }
        
        dungeon.generateMap()
        let spawnPosition = dungeon.spawnPlayer()
        var player = Player(position: spawnPosition, inventory: [], remaingSteps: Int(ceil(Double(dungeon.numberOfRooms) * 1.2)))
        
        while !isGameOver {
            gameCommand.playerTurn(for: &player)
            
            if player.inventory.contains(.graile) {
                print("CONGRATULATIONS! YOU WIN")
                print("YOU COLLECT \(player.gold) COIN")
            }
            
            if player.remaingSteps == 0 {
                print("STEPS IS OVER. YOU LOSE")
                print("YOU COLLECT \(player.gold) COIN")
                break
            }
        }
    }
    
    //Функция для валидации кол-ва комнат, комнат минимум 3шт
    private func validateNumberOfRooms() -> Int {
        print("Write the number of rooms")
        
        if let numberOfRooms = readLine(), let number = Int(numberOfRooms) {
            switch number {
            case ...3: print("Please enter more rooms...")
            default: return number
            }
        }
        
        return -1
    }
}
