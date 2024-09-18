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
    checkWinner = function(self, board)
        local win_combinations = {
            {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
            {1, 4, 7}, {2, 5, 8}, {3, 6, 9},
            {1, 5, 9}, {3, 5, 7}
        }
    
        for _, combination in ipairs(win_combinations) do
            if board[combination[1]] == board[combination[2]] and 
               board[combination[2]] == board[combination[3]] and 
               board[combination[1]] ~= "_" then
                return board[combination[1]]
            end
        end
    
        return nil
    end,
    
    isMovesLeft = function(self, board)
        for i = 1, 9 do
            if board[i] == "_" then
                return true
            end
        end
        return false
    end,
    
    minimax = function(self, board, depth, isMaximizingPlayer, player)
        local opponent = (player == "X") and "O" or "X"
        local winner = self:checkWinner(board)
        
        if winner == player then
            return 10 - depth
        elseif winner == opponent then
            return depth - 10
        elseif not self:isMovesLeft(board) then
            return 0
        end
    
        if isMaximizingPlayer then
            local best = -math.huge
            for i = 1, 9 do
                if board[i] == "_" then
                    board[i] = player
                    best = math.max(best, self:minimax(board, depth + 1, false, player))
                    board[i] = "_"
                end
            end
            return best
        else
            local best = math.huge
            for i = 1, 9 do
                if board[i] == "_" then
                    board[i] = opponent
                    best = math.min(best, self:minimax(board, depth + 1, true, player))
                    board[i] = "_"
                end
            end
            return best
        end
    end,
    
    bestMove = function(self, board, player)
        local bestVal = -math.huge
        local bestMove = -1
        for i = 1, 9 do
            if board[i] == "_" then
                board[i] = player
                local moveVal = self:minimax(board, 0, false, player)
                board[i] = "_"
                if moveVal > bestVal then
                    bestMove = i
                    bestVal = moveVal
                end
            end
        end
        return bestMove
    end,

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
    
        local teamColor = boardUI["Top Middle Template"].RoundInfo
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