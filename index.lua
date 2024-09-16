local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Arenas = workspace.ArenasREAL

local LobbyMain = PlayerGui.Lobby_Main
local PlayButton = LobbyMain["Bottom Middle"].Start
local RoomsParentFrame = PlayerGui.ViewRooms["Middle Middle"].ViewRooms
local RoomsFrame = RoomsParentFrame.Background.PlayerList.Objects

function PressButton(button)
    for _, connection in pairs(getconnections(button.MouseButton1Click)) do
        connection:Fire()
    end
end

function getChildrenOfClass(parent, className)
    local childrenOfClass = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) then
            table.insert(childrenOfClass, child)
        end
    end
    return childrenOfClass
end

function FindLocalArena()
    local ArenasList = Arenas:GetChildren()

    for _, Arena in ipairs(ArenasList) do
        local AreaTemplate = Arena:FindFirstChild("ArenaTemplate")

        if AreaTemplate then
            if not AreaTemplate.Red:FindFirstChild("Character") or not AreaTemplate.Red.Character:FindFirstChild("Nametag") then
                continue
            end

            local Red  = AreaTemplate.Red.Character.Nametag.Frame.Nickname.Text
            local Blue = AreaTemplate.Blue.Character.Nametag.Frame.Nickname.Text

            if Red == LocalPlayer.Name or Blue == LocalPlayer.Name then
                return AreaTemplate.Important
            end
        end
    end
end

local TicTacToe = {}

function TicTacToe.checkWin(board, player)
    local wins = {
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
        {1, 4, 7}, {2, 5, 8}, {3, 6, 9},
        {1, 5, 9}, {3, 5, 7}
    }
    
    for _, win in ipairs(wins) do
        if board[win[1]] == player and board[win[2]] == player and board[win[3]] == "_" then
            return win[3]
        elseif board[win[1]] == player and board[win[3]] == player and board[win[2]] == "_" then
            return win[2]
        elseif board[win[2]] == player and board[win[3]] == player and board[win[1]] == "_" then
            return win[1]
        end
    end

    return nil
end

function TicTacToe.bestMove(board, player)
    local winMove = TicTacToe.checkWin(board, player)
    if winMove then
        return winMove
    end

    local opponent = player == "X" and "O" or "X"
    local blockMove = TicTacToe.checkWin(board, opponent)
    if blockMove then
        return blockMove
    end

    local strategicMoves = {5, 1, 3, 7, 9, 2, 4, 6, 8}

    for _, move in ipairs(strategicMoves) do
        if board[move] == "_" then
            return move
        end
    end

    return nil
end


function getIndexFromName(name)
    local row = tonumber(string.sub(name, 1, 1))
    local col = 4 - tonumber(string.sub(name, 2, 2))
    return (col - 1) * 3 + row
end

function TicTacToe.uiToBoard(name)
    local board =  {"_", "_", "_", "_", "_", "_", "_", "_", "_"}
    local boardUI

    if name == "Tic Tac Toe" then
        boardUI = PlayerGui.TicTacToe
    else 
        boardUI = PlayerGui.RushTicTacToe
    end

    local teamColor = boardUI["Top Middle Template"].RoundInfo
    if teamColor.TeamColorRed.Visible then
        teamColor = "O"
    else
        teamColor = "X"
    end

    local ArenaWorkspace = FindLocalArena()
    local BoardBlocks = ArenaWorkspace.Drops:GetChildren()

    for _, obj in ipairs(BoardBlocks) do
        local name = obj.Name
        local color = obj.BrickColor

        local symbol
        if color == BrickColor.new("Steel blue") then
            symbol = "X"
        elseif color == BrickColor.new("Persimmon") then
            symbol = "O"
        end

        local index = getIndexFromName(name)
        board[index] = symbol
    end

    return { ["board"] = board, ["teamColor"] = teamColor } 
end

function TicTacToe.doMove(name, move)
    local boardUI

    if name == "Tic Tac Toe" then
        boardUI = PlayerGui.TicTacToe
    else 
        boardUI = PlayerGui.RushTicTacToe
    end

    local buttons = getChildrenOfClass(boardUI["Bottom Middle"].Buttons, "TextButton")
    if not buttons[move] then
        return
    end

    PressButton(buttons[move])
end

function GetRooms()
    local Rooms = {}

    local RoomsFrames = RoomsFrame:GetChildren()
    for _, RoomFrame in ipairs(RoomsFrames) do
        if RoomFrame:IsA("Frame") then
            local DataFrame = RoomFrame.Inside

            if DataFrame:FindFirstChild("Spectate") then
                continue
            end

            local GameName = DataFrame.GameName.Text
            local PlayerName = string.sub(DataFrame.DisplayName.Text, 11)
            local Robux = tonumber(DataFrame.Join.Amount.Text)
            local JoinButton = DataFrame.Join

            table.insert(Rooms, {
                ["GameName"] = GameName,
                ["PlayerName"] = PlayerName,
                ["Robux"] = Robux,
                ["JoinButton"] = JoinButton
            })
        end
    end

    return Rooms
end

function PressRoomsButton()
    if not RoomsParentFrame.Visible then
        PressButton(PlayButton)
    end
end

function IsRoomGood(Room)
    if Room.Robux == 0 then
        if Room.GameName == "Rush Tic Tac Toe" or
            Room.GameName == "Tic Tac Toe"
        then
            return true
        end
    end

    return false
end

function SearchForRoom()
    PressRoomsButton()

    task.wait(5)

    local Rooms = GetRooms()
    
    for _, Room in ipairs(Rooms) do
        if IsRoomGood(Room) then
            PressButton(Room.JoinButton)
            return Room.GameName
        end
    end

    return false
end

--local FoundRoom = SearchForRoom()

while task.wait(1) do
    local GameName = "Tic Tac Toe"
    local board = TicTacToe.uiToBoard(GameName)
    local bestMove = TicTacToe.bestMove(board.board, board.teamColor)
    TicTacToe.doMove(GameName, bestMove)
end
