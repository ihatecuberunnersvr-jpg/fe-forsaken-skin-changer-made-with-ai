local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local Themes = Workspace:FindFirstChild("Themes") or Workspace

-------------------------------------------------
-- Helper: Destroy instances
-------------------------------------------------
local function D(...)
  for _, v in ipairs({...}) do
    if v then
      v:Destroy() 
    end
  end
end

-------------------------------------------------
-- Helper: Custom Asset Downloader
-------------------------------------------------
local function importAudio(link, fileName)
    if not isfile(fileName) then
        writefile(fileName, game:HttpGet(link))
    end
    return getcustomasset(fileName)
end

-------------------------------------------------
-- Custom Sound Assets (Raw Link)
-------------------------------------------------
local CustomChase = importAudio("https://raw.githubusercontent.com/ihatecuberunnersvr-jpg/Chase-theme-test/main/evilpastelloandevilupbeatchase.mp3", "evilpastelloandevilupbeatchase.mp3")

-------------------------------------------------
-- Custom Chase Theme Listener
-------------------------------------------------
Themes.ChildAdded:Connect(function(sound)
    if sound:IsA("Sound") then
        -- Updated Slasher Chase Theme ID
        if sound.SoundId == "rbxassetid://86776053159699" then
            sound.SoundId = CustomChase
            sound:Play()
        end
    end
end)

-------------------------------------------------
-- Helper: Find matching attachment
-------------------------------------------------
local function findFirstMatchingAttachment(character, name)
    for _, descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == name then
            return descendant
        end
    end
    return nil
end

-------------------------------------------------
-- Client-side accessory attachment (No Collision)
-------------------------------------------------
local function addAccoutrement(character, accoutrement)
    accoutrement.Parent = character
    
    for _, part in ipairs(accoutrement:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
        end
    end

    local handle = accoutrement:FindFirstChild("Handle")
    if not handle then return end

    for _, v in pairs(handle:GetChildren()) do
        if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then
            v:Destroy()
        end
    end

    local accAttachment = handle:FindFirstChildOfClass("Attachment")
    if accAttachment then
        local charAttachment = findFirstMatchingAttachment(character, accAttachment.Name)
        if charAttachment then
            local weld = Instance.new("Weld")
            weld.Name = "AccessoryWeld"
            weld.Part0 = handle
            weld.Part1 = charAttachment.Parent
            weld.C0 = accAttachment.CFrame
            weld.C1 = charAttachment.CFrame
            weld.Parent = handle
            return
        end
    end

    local target = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if target then
        local weld = Instance.new("Weld")
        weld.Name = "AccessoryWeld"
        weld.Part0 = handle
        weld.Part1 = target
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = handle
    end
end

-------------------------------------------------
-- Load catalog accessory by ID
-------------------------------------------------
local function loadAccessory(character, assetId)
    task.spawn(function()
        local success, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(assetId))
        end)

        if not success or not objects or not objects[1] then
            warn("Failed to load catalog asset: " .. tostring(assetId))
            return
        end

        local item = objects[1]
        local accessory = item:IsA("Accessory") and item or item:FindFirstChildOfClass("Accessory")

        if not accessory then
            warn("No Accessory instance found inside asset " .. tostring(assetId))
            return
        end

        accessory = accessory:Clone()
        addAccoutrement(character, accessory)
    end)
end

-------------------------------------------------
-- DoMorph Execution (Targeting ONLY Slasher)
-------------------------------------------------
local function DoMorph(P)
  if P.Name == "Slasher" and P:GetAttribute("SkinName") == "" then
    -- Destroy Slasher's default model meshes and accessories
    D(
      P:FindFirstChild("Slasher Export"), 
      P:FindFirstChild("Mask"), 
      P:FindFirstChild("ExpressionHolder")
    )

    -- Hide default weapon models if they exist
    if P:FindFirstChild("Machete") then P.Machete.Transparency = 1 end
    if P:FindFirstChild("Chainsaw") then P.Chainsaw.Transparency = 1 end
    
    -- Strip existing default accessories, clothing, and character meshes
    for _, item in ipairs(P:GetChildren()) do
      if item:IsA("Accessory") or item:IsA("Accoutrement") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
        item:Destroy()
      end
    end
    
    -- Set body colors: Pure Black body
    local blackColor = Color3.fromRGB(0, 0, 0)
    local parts = {
      ["Head"] = blackColor,
      ["Torso"] = blackColor,
      ["Left Arm"] = blackColor,
      ["Right Arm"] = blackColor,
      ["Left Leg"] = blackColor,
      ["Right Leg"] = blackColor
    }

    for partName, color in pairs(parts) do
      local L = P:WaitForChild(partName, 2)
      if L then
        L.Transparency = 0
        L.Color = color
      end
    end

    -- Clear head face decal and special mesh texture
    local head = P:FindFirstChild("Head")
    if head then
      local face = head:FindFirstChildOfClass("Decal")
      if face then
        face:Destroy()
      end
      local mesh = head:FindFirstChildOfClass("SpecialMesh")
      if mesh then
        mesh.TextureId = ""
      end
    end

    -- Apply Pants
    local pants = Instance.new("Pants")
    pants.Name = "CustomPants"
    pants.PantsTemplate = "rbxassetid://106696905018292"
    pants.Parent = P

    -------------------------------------------------------------
    -- PASTELLO SLASHER ACCESSORY LIST
    -------------------------------------------------------------
    local accessoryIds = {
      74420217754453,  -- Evil Pastello's Face
      15245773886,     -- Purple Bucket Hat
      90425566545731,  -- Pastello Right Sleeve R6
      97403472927856,  -- Pastello Left Sleeve R6
      94252673040439,  -- Pastel Hair
      122819165277714, -- Pastello's Shirt R6
      130303314831628, -- Rectangle Reading Glasses Purple
      139454601420692  -- Pastel Villain Cape
    }

    for _, id in ipairs(accessoryIds) do
      loadAccessory(P, id)
    end
  end
end

-- Run on current character if named Slasher
if Player.Character then
    DoMorph(Player.Character)
end

-- Run on spawn
Player.CharacterAdded:Connect(function(Rig)  
  DoMorph(Rig) 
end)
