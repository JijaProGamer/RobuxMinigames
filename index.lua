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
            local Red = AreaTemplate:FindFirstChild("Red")
            if not Red or not Red:FindFirstChild("Character") or not AreaTemplate.Red.Character:FindFirstChild("Nametag") then
                continue
            end

            local Red  = Red.Character.Nametag.Frame:FindFirstChild("Username")
            local Blue = AreaTemplate.Blue.Character.Nametag.Frame:FindFirstChild("Username")

            if not Red or not Blue then
                continue
            end

            Red = Red.Text
            Blue = Blue.Text
            
            if Red == "@"..LocalPlayer.Name or Blue == "@"..LocalPlayer.Name then
                return AreaTemplate.Important
            end
        end
    end

    return nil
end

TicTacToe = {
    getIndexFromName = function(self, name)
        local row = tonumber(string.sub(name, 1, 1))
        local col = 4 - tonumber(string.sub(name, 2, 2))
        return (col - 1) * 3 + row
    end,
    
    uiToBoard = function(self, ArenaWorkspace, mode)
        local board =  {"_", "_", "_", "_", "_", "_", "_", "_", "_"}
        local boardUI
    
        if mode == "Tic Tac Toe" then
            boardUI = PlayerGui.TicTacToe
        else 
            boardUI = PlayerGui.RushTicTacToe
        end
    
        local teamColor = boardUI["Top Middle"].RoundInfo
        if teamColor.TeamColorRed.Visible then
            teamColor = "O"
        else
            teamColor = "X"
        end
    
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
    
            local index = self:getIndexFromName(name)
            board[index] = symbol
        end
    
        return { ["board"] = board, ["teamColor"] = teamColor } 
    end,

    isMyTurn = function(self, mode)
        local boardUI
    
        if mode == "Tic Tac Toe" then
            boardUI = PlayerGui.TicTacToe
        else 
            boardUI = PlayerGui.RushTicTacToe
        end

        local BottomMiddle = boardUI:FindFirstChild("Bottom Middle")
        return BottomMiddle and BottomMiddle.Visible or false
    end,
    
    doMove = function(self, mode, move)
        local boardUI
    
        if mode == "Tic Tac Toe" then
            boardUI = PlayerGui.TicTacToe
        else 
            boardUI = PlayerGui.RushTicTacToe
        end
    
        if not boardUI:FindFirstChild("Bottom Middle") then
            return
        end
    
        local buttons = getChildrenOfClass(boardUI["Bottom Middle"].Buttons, "TextButton")
        if not buttons[move] then
            return
        end
    
        PressButton(buttons[move])
    end,

    rowCrossed = function(self, board)
        for i = 1, 3 do
            if board[(i - 1) * 3 + 1] == board[(i - 1) * 3 + 2] and 
               board[(i - 1) * 3 + 2] == board[(i - 1) * 3 + 3] and
               board[(i - 1) * 3 + 1] ~= "_" then
                return true
            end
        end
        return false
    end,

    columnCrossed = function(self, board)
        for i = 1, 3 do
            if board[i] == board[i + 3] and 
               board[i + 3] == board[i + 6] and
               board[i] ~= "_" then
                return true
            end
        end
        return false
    end,

    diagonalCrossed = function(self, board)
        if board[1] == board[5] and 
           board[5] == board[9] and 
           board[1] ~= "_" then
            return true
        end
    
        if board[3] == board[5] and 
           board[5] == board[7] and 
           board[3] ~= "_" then
            return true
        end
    
        return false
    end,

    gameOver = function(self, board)
        return self:rowCrossed(board) or self:columnCrossed(board) or self:diagonalCrossed(board)
    end,

    minimax = function(self, board, depth, isAI, playerSymbol, opponentSymbol)
        local score = 0
        local bestScore
        if self:gameOver(board) then
            if isAI then
                return -1
            else
                return 1
            end
        elseif depth >= 9 then
            return 0
        end
    
        if isAI then
            bestScore = -999
            for i = 1, 9 do
                if board[i] == "_" then
                    board[i] = playerSymbol
                    score = self:minimax(board, depth + 1, false, playerSymbol, opponentSymbol)
                    board[i] = "_"
                    if score > bestScore then
                        bestScore = score
                    end
                end
            end
            return bestScore
        else
            bestScore = 999
            for i = 1, 9 do
                if board[i] == "_" then
                    board[i] = opponentSymbol
                    score = self:minimax(board, depth + 1, true, playerSymbol, opponentSymbol)
                    board[i] = "_"
                    if score < bestScore then
                        bestScore = score
                    end
                end
            end
            return bestScore
        end
    end,

    bestMove = function(self, board, playerSymbol)
        local opponentSymbol = playerSymbol == "X" and "O" or "X"
        local x, y
        local bestScore = -999
        local bestMove = -1
    
        for i = 1, 9 do
            if board[i] == "_" then
                board[i] = playerSymbol
                local score = self:minimax(board, 0, false, playerSymbol, opponentSymbol)
                board[i] = "_"
                if score > bestScore then
                    bestScore = score
                    bestMove = i
                end
            end
        end
    
        return bestMove
    end
}


function HandleGame(ArenaWorkspace, GameName)
    if GameName == "Rush Tic Tac Toe" or
        GameName == "Tic Tac Toe" then
        if not TicTacToe:isMyTurn(GameName) then
            return
        end

        local board = TicTacToe:uiToBoard(ArenaWorkspace, GameName)
        local bestMove = TicTacToe:bestMove(board.board, board.teamColor)
        TicTacToe:doMove(GameName, bestMove)
    end
end

local MinRobux = 1
local MaxRobux = 1
local RobuxChoses = {
    0,
    10,
    20,
    30, 
    40,
    50,
    100,
    150,
    200,
    300,
    400,
    500,
    1000,
    2000,
    3000,
    5000,
    10000,
    100000,
    1000000,
    500000
}
local GamesDoable = {
    "Rush Tic Tac Toe",
    "Tic Tac Toe"
}

function GetRobuxModesDoable()

    for i = MinRobux, MaxRobux do
        local RobuxValue = RobuxChoses[i]


    end
end

function GotoMode()

end

function MakeGame()
    local ModeChosen = GamesDoable[math.random(1, #GamesDoable)];

    
    --local RobuxChosen = 

end

function GetRooms()
    local Rooms = {}

    local RoomsFrames = RoomsFrame:GetChildren()
    for _, RoomFrame in ipairs(RoomsFrames) do
        if not RoomFrame:IsA("Frame") then
            continue
        end

        local DataFrame = RoomFrame.Inside

        if DataFrame:FindFirstChild("Spectate") then
            continue
        end

        if not DataFrame:FindFirstChild("Join") then
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

    return Rooms
end

function PressPlayButton()
    if not RoomsParentFrame.Visible then
        PressButton(PlayButton)
    end
end

function IsRoomGood(Room)
    if Room.Robux >= RobuxChoses[MinRobux] and Room.Robux <= RobuxChoses[MaxRobux] then
        if Room.GameName == "Rush Tic Tac Toe" or
            Room.GameName == "Tic Tac Toe"
        then
            return true
        end
    end

    return false
end

function SearchForRoom()
    PressPlayButton()

    RoomsFrame.ChildAdded:Wait()
    task.wait(2)

    local Rooms = GetRooms()

    for _, Room in ipairs(Rooms) do
        if IsRoomGood(Room) then
            PressButton(Room.JoinButton)
            return Room.GameName
        end
    end

    return nil
end

--[[local GameName = nil
local Started = false

while true do
    task.wait(1)

    local ArenaWorkspace = FindLocalArena()

    if ArenaWorkspace then
        HandleGame(ArenaWorkspace, GameName)
        Started = false
    else
        if not Started then
            local CurrentGameName = SearchForRoom()

            if CurrentGameName then
                GameName = CurrentGameName
                Started = true
            else 
                MakeGame()
            end
        end
    end
end]]

while true do
    task.wait(1)

    local ArenaWorkspace = FindLocalArena()

    if ArenaWorkspace then
        HandleGame(ArenaWorkspace, "Tic Tac Toe")
    end
end