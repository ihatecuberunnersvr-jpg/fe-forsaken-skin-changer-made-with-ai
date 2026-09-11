local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local Themes = Workspace:FindFirstChild("Themes") or Workspace

local Jason = game:GetService("ReplicatedStorage").Assets.Killers.Jason
local Slasher = game:GetService("ReplicatedStorage").Assets.Killers.Slasher

local SCon = require(Slasher.Config)
local JCon = require(Jason.Config)
local SBeh = require(Slasher.Behavior)
local JBeh = require(Jason.Behavior)

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
-- Custom Sound Assets (Raw GitHub Link)
-------------------------------------------------
local CustomChase = importAudio("https://raw.githubusercontent.com/ihatecuberunnersvr-jpg/Chase-theme-test/main/audio_102916915231393.mp3", "baldi_chase.mp3")

-------------------------------------------------
-- Custom Chase Theme Listener
-------------------------------------------------
Themes.ChildAdded:Connect(function(sound)
    if sound:IsA("Sound") then
        if sound.SoundId == "rbxassetid://86776053159699" then
            sound.SoundId = CustomChase
            sound:Play()
        end
    end
end)

-------------------------------------------------
-- Helper: Create Part / Weapon Welding
-------------------------------------------------
local function CreatePart(name, parent, weld, offset) 
  local Part = Instance.new("Part")
  Part.Name = name
  Part.Massless = true
  Part.Anchored = false
  Part.CanCollide = false
  Part.CanTouch = false
  Part.CanQuery = false

  if weld then
    local Weld = Instance.new("Weld")
    Weld.C0 = offset or CFrame.new(0, 0, 0) 
    Weld.Part0 = Part
    Weld.Part1 = weld
    Weld.Parent = Part
  end

  Part.Parent = parent
  return Part
end

local function Accs(AccsName, parent, Mesh, Texture, Scale, CF, Welded, Angle) 
  Scale = Scale or Vector3.new(1, 1, 1)
  Angle = Angle or CFrame.Angles(0, 0, 0)
  CF = CF or CFrame.new(0, 0, 0)

  local var_2 = CreatePart(AccsName, parent) 
  var_2.Size = Vector3.new(1, 1, 1)

  local var_3 = Instance.new("SpecialMesh") 
  var_3.Name = "Mesh"
  var_3.MeshId = Mesh
  var_3.TextureId = Texture
  var_3.Scale = Scale
  var_3.Parent = var_2

  local var_4 = Instance.new("Weld") 
  var_4.C0 = CF * Angle
  var_4.Part0 = var_2
  var_4.Part1 = Welded
  var_4.Parent = var_2
  
  return var_2
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
-- Client-side accessory attachment
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

        if not success or not objects or not objects[1] then return end

        local item = objects[1]
        local accessory = item:IsA("Accessory") and item or item:FindFirstChildOfClass("Accessory")

        if accessory then
            addAccoutrement(character, accessory:Clone())
        end
    end)
end

-------------------------------------------------
-- Clothing Helper
-------------------------------------------------
local function Cloth(Id1, Id2, Id3, Parent)
  if Id1 ~= nil then
    local S = Instance.new("Shirt", Parent)
    S.ShirtTemplate = "rbxassetid://" .. tostring(Id1)
  end
  if Id2 ~= nil then
    local P = Instance.new("Pants", Parent) 
    P.PantsTemplate = "rbxassetid://" .. tostring(Id2)
  end
  if Id3 ~= nil then
    local SG = Instance.new("ShirtGraphic", Parent)
    SG.Graphic = "rbxassetid://" .. tostring(Id3)
  end
end

-- Ability Icons & Theme Configs
SBeh.Abilities.Slash.Icon = JBeh.Abilities.Slash.Icon
SBeh.Abilities.Behead.Icon = JBeh.Abilities.Behead.Icon
SBeh.Abilities.GashingWound.Icon = JBeh.Abilities.GashingWound.Icon
SBeh.Abilities.RagingPace.Icon = JBeh.Abilities.RagingPace.Icon

SCon.Sounds["TerrorRadiusThemes"] = JCon.Sounds.TerrorRadiusThemes
SCon.DisplayName = "Baldi"
SCon.RenderImage = JCon.RenderImage

-------------------------------------------------
-- DoMorph Execution
-------------------------------------------------
local function DoMorph(P, Name)
  if P.Name == Name and P:GetAttribute("SkinName") == "" then
    -- Clean original Slasher extra parts
    D(P:FindFirstChild("Slasher Export"), P:FindFirstChild("Mask"), P:FindFirstChild("ExpressionHolder"))
    if P:FindFirstChild("Chainsaw") and P.Chainsaw:FindFirstChild("Note") then
      P.Chainsaw.Note:Destroy()
    end

    -- Hide default weapons
    if P:FindFirstChild("Machete") then P.Machete.Transparency = 1 end
    if P:FindFirstChild("Chainsaw") then P.Chainsaw.Transparency = 1 end

    -- Strip existing clothes/accessories
    for _, item in ipairs(P:GetChildren()) do
      if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
        item:Destroy()
      end
    end

    -- Turn Head transparent (headless look for Baldi head replacement)
    local head = P:FindFirstChild("Head")
    if head then
      head.Transparency = 1
      local face = head:FindFirstChildOfClass("Decal")
      if face then face:Destroy() end
    end

    -- Set Robloxian limbs to Baldi skin tone
    local skinColor = Color3.fromRGB(240, 180, 130)
    for _, limbName in ipairs({"Torso", "Right Leg", "Left Leg", "Right Arm", "Left Arm"}) do
      local limb = P:FindFirstChild(limbName)
      if limb then
        limb.Transparency = 0
        limb.Color = skinColor
      end
    end

    -- Apply Baldi Clothing
    Cloth(
      12968375191, -- Baldi Shirt
      12968377738, -- Baldi Pants
      nil, 
      P
    )

    -- Attach Mad Baldi Head Accessory
    loadAccessory(P, 18280156671)

    -- Attach Slasher Weapons
    if P:FindFirstChild("Machete") then
      Accs("OldMachete", P.Machete, "rbxassetid://441575918", "rbxassetid://441575955", Vector3.new(0.016, 0.016, 0.016), nil, P.Machete, CFrame.Angles(0, -math.pi/2, 0))
    end

    if P:FindFirstChild("Chainsaw") then
      Accs("OldChainsaw", P.Chainsaw, "http://www.roblox.com/asset/?id=2766469", "rbxasset://textures/SwordTexture.png", Vector3.new(0.89, 0.89, 1.157), nil, P.Chainsaw, CFrame.Angles(-math.pi/2, math.pi/2, 0))
    end
  end
end

if Player.Character then
  DoMorph(Player.Character, "Slasher")
end

Player.CharacterAdded:Connect(function(Rig)
  DoMorph(Rig, "Slasher")
end)
