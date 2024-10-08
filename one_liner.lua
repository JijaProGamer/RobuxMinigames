local HttpService = game:GetService("HttpService")

local username = "JijaProGamer"
local repository = "RobuxMinigames"
local branchName = "main"
local filePath = "index.lua"

local function getLatestCommitHash()
    local apiUrl = "https://api.github.com/repos/" .. username .. "/" .. repository .. "/branches/" .. branchName
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)
    
    if success then
        local branchData = HttpService:JSONDecode(response)
        return branchData.commit.sha
    else
        warn("Error fetching commit hash: " .. response)
        return nil
    end
end

local function getFileContent(commitHash)
    local rawUrl = "https://raw.githubusercontent.com/" .. username .. "/" .. repository .. "/" .. commitHash .. "/" .. filePath
    local success, response = pcall(function()
        return game:HttpGet(rawUrl)
    end)
    
    if success then
        return response
    else
        warn("Error fetching script: " .. response)
        return nil
    end
end

local commitHash = getLatestCommitHash()
if commitHash then
    local fileContent = getFileContent(commitHash)
    if fileContent then
        local loadedFunc, err = loadstring(fileContent)
        if loadedFunc then
            loadedFunc()
        else
            warn("Error loading script: " .. err)
        end
    end
end
