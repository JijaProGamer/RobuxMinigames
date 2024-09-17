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

    return nil
end

TicTacToe = {
    checkWinner = function(self, state)
        local winning_combinations = {
            {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
            {1, 4, 7}, {2, 5, 8}, {3, 6, 9},
            {1, 5, 9}, {3, 5, 7}
        }

        for _, combo in ipairs(winning_combinations) do
            local a, b, c = combo[1], combo[2], combo[3]
            if state[a] ~= "_" and state[a] == state[b] and state[a] == state[c] then
                return state[a]
            end
        end

        return nil
    end,

    -- Function to check if the board is full (a draw)
    isFull = function(self, state)
        for i = 1, 9 do
            if state[i] == "_" then
                return false
            end
        end
        return true
    end,

    minimax = function(self, state, depth, is_maximizing, player)
        local winner = self:checkWinner(state)
        local opponent = player == "X" and "O" or "X"
        
        if winner == player then return 10 - depth end
        if winner == opponent then return depth - 10 end
        if self:isFull(state) then return 0 end

        if is_maximizing then
            local best_score = -math.huge
            for i = 1, 9 do
                if state[i] == "_" then
                    state[i] = player
                    local score = self:minimax(state, depth + 1, false, player)
                    state[i] = "_"
                    best_score = math.max(score, best_score)
                    if best_score == 10 - depth then return best_score end
                end
            end
            return best_score
        else
            local best_score = math.huge
            for i = 1, 9 do
                if state[i] == "_" then
                    state[i] = opponent
                    local score = self:minimax(state, depth + 1, true, player)
                    state[i] = "_"
                    best_score = math.min(score, best_score)
                    if best_score == depth - 10 then return best_score end
                end
            end
            return best_score
        end
    end,

    bestMove = function(self, state, player)
        local best_score = -math.huge
        local move = nil
        
        for i = 1, 9 do
            if state[i] == "_" then
                state[i] = player
                local score = self:minimax(state, 0, false, player)
                state[i] = "_"
                if score > best_score then
                    best_score = score
                    move = i
                end
            end
        end
        
        return move
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

        return boardUI["Bottom Middle"] and boardUI["Bottom Middle"].Visible
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
        GameName == "Tic Tac Toe"
    then  
        if not TicTacToe:isMyTurn() then
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

function PressPlayButton()
    if not RoomsParentFrame.Visible then
        PressButton(PlayButton)
    end
end

function IsRoomGood(Room)
    if Room.Robux >= RobuxChoses[MinRobux] and Room.Robux <= MaxRobux[MaxRobux] then
        if Room.GameName == "Rush Tic Tac Toe" or
            Room.GameName == "Tic Tac Toe"
        then
            return true
        end
    end

    return false
end

function SearchForRoom()
    --[[local OnNewRooms
    OnNewRooms = RoomsFrame.ChildAdded:Connect(function()
        OnNewRooms:Disconnect()

        local Rooms = GetRooms()
    
        for _, Room in ipairs(Rooms) do
            if IsRoomGood(Room) then
                PressButton(Room.JoinButton)
                return Room.GameName
            end
        end
    end)

    PressPlayButton()]]

    PressPlayButton()

    RoomsFrame.ChildAdded:Wait()

    local Rooms = GetRooms()

    for _, Room in ipairs(Rooms) do
        if IsRoomGood(Room) then
            PressButton(Room.JoinButton)
            return Room.GameName
        end
    end

    return nil
end

--local GameName = nil
local GameName = "Tic Tac Toe"
while task.wait(1) do
    local ArenaWorkspace = FindLocalArena()

    if ArenaWorkspace then
        HandleGame(ArenaWorkspace, GameName)
    else
        GameName = SearchForRoom()
        if not GameName then
            MakeGame()
        end
    end
end