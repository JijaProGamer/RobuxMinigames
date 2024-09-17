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

    isFull = function(self, state)
        for i = 1, 9 do
            if state[i] == "_" then
                return false
            end
        end
        return true
    end,

    minimax = function(self, state, is_maximizing, player, alpha, beta)
        local winner = self:checkWinner(state)
        local opponent = player == "X" and "O" or "X"
        
        if winner == player then return 1 end
        if winner == opponent then return -1 end
        if self:isFull(state) then return 0 end

        if is_maximizing then
            local best_score = -math.huge
            for i = 1, 9 do
                if state[i] == "_" then
                    state[i] = player
                    local score = self:minimax(state, false, player, alpha, beta)
                    state[i] = "_"
                    best_score = math.max(score, best_score)
                    alpha = math.max(alpha, best_score)

                    if beta <= alpha then
                        break
                    end
                end
            end
            return best_score
        else
            local best_score = math.huge
            for i = 1, 9 do
                if state[i] == "_" then
                    state[i] = opponent
                    local score = self:minimax(state, true, player, alpha, beta)
                    state[i] = "_"
                    best_score = math.min(score, best_score)
                    beta = math.min(beta, best_score)

                    if beta <= alpha then
                        break
                    end
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
                local score = self:minimax(state, false, player, -math.huge, math.huge)
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

--[[local GameName = nil
while task.wait(1) do
    local ArenaWorkspace = FindLocalArena()

    if ArenaWorkspace then
        if GameName == "Rush Tic Tac Toe" or
            GameName == "Tic Tac Toe"
        then  
            local board = TicTacToe:uiToBoard(ArenaWorkspace, GameName)
            local bestMove = TicTacToe:bestMove(board.board, board.teamColor)
            TicTacToe:doMove(GameName, bestMove)
        end
    else
        GameName = SearchForRoom()
        if GameName then

        else

        end
    end
end]]

while task.wait(1) do
    local GameName = "Tic Tac Toe"
    local ArenaWorkspace = FindLocalArena()
    local board = TicTacToe:uiToBoard(ArenaWorkspace, GameName)
    local bestMove = TicTacToe:bestMove(board.board, board.teamColor)
    TicTacToe:doMove(GameName, bestMove)
end