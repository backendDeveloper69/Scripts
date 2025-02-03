local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")

local SCRIPT_VERSION = "V1"
local CHECK_VERSION_INTERVAL = 3
local SERVER_VERSION_URL = "https://pastebin.com/raw/aJdH9dU2"

local running = true
local cooldownTime = 6
local currentTargetPlayer = nil
local followConnection = nil


local function checkForUpdates()
    while running do
        local success, result = pcall(function()
            return HttpService:GetAsync(SERVER_VERSION_URL)
        end)

        if success and result and result ~= SCRIPT_VERSION then
            running = false
            sendChatMessage("Script updated. Restarting...")
            wait(2)
            return
        end

        wait(CHECK_VERSION_INTERVAL)
    end
end


local function chooseRandomPlayer()
    local playerList = Players:GetPlayers()
    if #playerList > 1 then
        local randomPlayer
        repeat
            randomPlayer = playerList[math.random(1, #playerList)]
        until randomPlayer ~= Players.LocalPlayer
        return randomPlayer
    end
    return nil
end


local function sendChatMessage(message)
    if TextChatService and TextChatService.ChatInputBarConfiguration then
        TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
    end
end


local function stopFollowingPlayer()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    currentTargetPlayer = nil
end


local function followPlayer(targetPlayer, localPlayer)
    if targetPlayer == currentTargetPlayer then
        return
    end
    
    stopFollowingPlayer()
    
    currentTargetPlayer = targetPlayer

    if not running or not targetPlayer.Character or not targetPlayer.Character.PrimaryPart then
        return
    end

    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    followConnection = RunService.Heartbeat:Connect(function()
        local targetPosition = targetPlayer.Character.PrimaryPart.Position
        local currentPosition = localPlayer.Character.PrimaryPart.Position
        local distance = (targetPosition - currentPosition).Magnitude

        if distance > 5 then
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })
            path:ComputeAsync(currentPosition, targetPosition)

            if path.Status == Enum.PathStatus.Success then
                for _, waypoint in pairs(path:GetWaypoints()) do
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    humanoid:MoveTo(waypoint.Position)
                    humanoid.MoveToFinished:Wait()
                end
            end
        end

        local lookAtCFrame = CFrame.new(
            localPlayer.Character.PrimaryPart.Position,
            targetPlayer.Character.PrimaryPart.Position
        )
        localPlayer.Character:SetPrimaryPartCFrame(lookAtCFrame)
    end)
end


local function performAction()
    local chosenPlayer = chooseRandomPlayer()
    if chosenPlayer then
        followPlayer(chosenPlayer, Players.LocalPlayer)
        local action = math.random(1, 3)

        if action == 1 then
            
            local localPlayer = Players.LocalPlayer
            localPlayer.Character.Humanoid.WalkSpeed = 16
            sendChatMessage("loser")
            wait(2)

            
            local speed = 16
            while speed < 50 and localPlayer.Character and localPlayer.Character.Humanoid.Health > 0 do
                speed = speed + 2
                localPlayer.Character.Humanoid.WalkSpeed = speed
                wait(0.5)
            end

        elseif action == 2 then
            
            local localPlayer = Players.LocalPlayer
            localPlayer.Character.Humanoid.WalkSpeed = 16

            wait(2)

            
            localPlayer.Character.Humanoid:MoveTo(chosenPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 5))

            local dolphinAnim = Instance.new("Animation")
            dolphinAnim.AnimationId = "rbxassetid://168738279" 
            localPlayer.Character.Humanoid:LoadAnimation(dolphinAnim):Play()

            wait(3)
            sendChatMessage("my cat did that, mb")
            localPlayer.Character.Humanoid.WalkSpeed = 16
            wait(2)

        elseif action == 3 then
           
            local localPlayer = Players.LocalPlayer
            localPlayer.Character.Humanoid.WalkSpeed = 16

            local targetPos = chosenPlayer.Character.HumanoidRootPart.Position
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
            local startTime = tick()
            while tick() - startTime < 10 and localPlayer.Character and localPlayer.Character.Humanoid.Health > 0 do
                localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad((tick() - startTime) * 36), 0))
                wait(0.1)
            end
            sendChatMessage("mb my cat got on")
        end
    else
        sendChatMessage("No other players found")
    end
end

task.spawn(checkForUpdates)
while running do
    performAction()
    wait(cooldownTime)
end
