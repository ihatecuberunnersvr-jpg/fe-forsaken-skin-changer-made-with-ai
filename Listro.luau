local Player = game:GetService("Players").LocalPlayer

local function D(...) 
  for _, v in ipairs({...}) do
    if v then
      v:Destroy() 
    end
  end
end

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
    
    -- Disable collision and query on all parts
    for _, part in ipairs(accoutrement:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
        end
    end

    local handle = accoutrement:FindFirstChild("Handle")
    if not handle then return end

    -- Clean old welds
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

    -- Fallback weld to head or torso
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
-- DoMorph Execution
-------------------------------------------------
local function DoMorph(P, Name)
  if P.Name == Name and P:GetAttribute("SkinName") == "" then
    D(P:FindFirstChild("ExpressionHolder"))
    
    -- Strip all existing accessories, clothing, and body items
    for _, item in ipairs(P:GetChildren()) do
      if item:IsA("Accessory") or item:IsA("Accoutrement") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
        item:Destroy()
      end
    end
    
    -- Set skin colors
    local yellowColor = Color3.fromRGB(255, 255, 0)
    local parts = {
      ["Head"] = yellowColor,
      ["Torso"] = yellowColor,
      ["Left Arm"] = yellowColor,
      ["Right Arm"] = yellowColor,
      ["Left Leg"] = yellowColor,
      ["Right Leg"] = yellowColor
    }

    for partName, color in pairs(parts) do
      local L = P:WaitForChild(partName, 2)
      if L then
        L.Transparency = 0
        L.Color = color
      end
    end

    -- Clear default face decal and head textures
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
    pants.PantsTemplate = "rbxassetid://120883050084559"
    pants.Parent = P

    -------------------------------------------------------------
    -- ACCESSORY LIST (Tin Pot + New Listro/Balloon Items)
    -------------------------------------------------------------
    local accessoryIds = {
      6837506,           -- Tin Pot
      124535358956049,   -- Listro's Right Sleeve R6
      130465658930354,   -- Listro's Left Sleeve R6
      86271812749218,    -- Listro's Shirt R6
      140601089382302,   -- Listro's Bucket Hat
      20416914,          -- Balloon Ninja
      83862552264516     -- Listro's Face
    }

    for _, id in ipairs(accessoryIds) do
      loadAccessory(P, id)
    end
  end
end

-- Run on current character
if Player.Character then
    DoMorph(Player.Character, "Shedletsky")
end

-- Run when spawning
Player.CharacterAdded:Connect(function(Rig)  
  DoMorph(Rig, "Shedletsky") 
end)

