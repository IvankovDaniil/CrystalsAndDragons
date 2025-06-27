//
//  GameCommands.swift
//  CrystalsAndDragons
//
//  Created by Даниил Иваньков on 27.06.2025.
//

class GameCommands {
    
    let dungeon: Dungeon
    var gameOverHandler: (() -> Void)?
    
    init(dungeon: Dungeon) {
        self.dungeon = dungeon
    }
    
    func playerTurn(for player: inout Player) {
        dungeon.describeRoom(for: player.position, player)
        let availableDirection = dungeon.availableDirection(position: player.position)
        let currentRoom = dungeon.map[player.position.x - 1][player.position.y - 1]
        
        while true {
            if let input = readLine() {
                let action = PlayerAction(input: input)
                switch action {
                case .move(let direction):
                    let (isCanMove, _) = isAvailableDirection(moveTo: direction.rawValue, directions: availableDirection)
                    if isCanMove {
                        player.move(to: direction)
                        player.remaingSteps -= 1
                        break
                    } else {
                        print("Incorrect input")
                        continue
                    }
                case .get:
                    if let item = currentRoom.item {
                        handleGet(item: item, player: &player)
                    } else {
                        print("There is nothing to get")
                    }
                case .drop(let item):
                    switch item {
                    case .key: handleDropKey(player: &player)
                    case .torch: handleDropTorch(player: &player)
                    default : print("You can't drop this item")
                    }
                case .open:
                    if handleOpen(currentRoom: currentRoom, player: &player) {
                        break
                    } else {
                        continue
                    }
                case .invalid:
                    print("Incorrect input"); continue
                }
                break
            }
        }
    }
    
    //Метод сбросить ключ
    private func handleDropKey(player: inout Player) {
        if player.inventory.contains(.key) {
            player.inventory.removeAll(where: { $0 == .key })
            print("You are dropped the key")
        } else {
            print("You don't have key")
        }
    }
    
    //Метод сбросить факел
    private func handleDropTorch(player: inout Player) {
        if player.inventory.contains(.torch) {
            player.inventory.removeAll(where: { $0 == .torch })
            dungeon.map[player.position.x - 1][player.position.y - 1].isDark = false
            print("You are dropped the torch")
        } else {
            print("You don't have torch")
        }
    }
    
    
    //Метод взять в инвентарь
    private func handleGet(item: Item, player: inout Player)  {
        switch item {
        case .torch, .key:
            if player.inventory.contains(item) {
                print("You already have \(item)")
            } else {
                print("You are pickup \(item)")
                dungeon.map[player.position.x - 1][player.position.y - 1].item = nil
                player.inventory.append(item)
            }
        case .chest:
            print("You can't get chest")
        case .gold(let x):
            print("You are pickup \(x) coin")
            dungeon.map[player.position.x - 1][player.position.y - 1].item = nil
            player.gold += x
        case .graile: return
        }
    }
    
    //Метод открыть сундук
    private func handleOpen(currentRoom: Room, player: inout Player) -> Bool {
        if currentRoom.item == .chest {
            if player.inventory.contains(.key) {
                player.inventory.append(.graile)
                gameOverHandler?()
                return true
            } else {
                print("You don't have key")
                return false
            }
        }
        
        print("Nothing to open")
        
        return false
    }
    
    private func isAvailableDirection(moveTo: String, directions: [Directions]) -> (Bool, Directions?) {
        for direction in directions {
            if moveTo == direction.rawValue {
                return (true, direction)
            }
        }
        return (false, nil)
    }
}
