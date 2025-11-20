local RNG = {}
RNG.__index = RNG
local A = 1664525
local C = 102013904223
local M = 2^32

function RNG.new(seed)
    local self = setmetatable({}, RNG)
    self.state = seed or os.time() % M
    return self
end

function RNG:next_int()
    self.state = (A * self.state + C) % M
    return self.state
end

function RNG:random()
    return self:next_int() / M
end

function RNG:rand_int(low, high)
    return math.floor(self:random() * (high - low + 1)) + low
end

local rarities = {
    { name = "Uncommon", weight = 0 },
    { name = "Rare", weight = 0 },
    { name = "Epic", weight = 0 },
    { name = "Legend", weight = 0 },
    { name = "Mythic", weight = 0 },
    { name = "Secret", weight = 100 },
}

local fish_pool = {
    Uncommon = { "Ikan Cupang", "Ikan Mas", "Ikan Gabus"},
    Rare = { "Ubur-Ubur", "Ikan Lele", "Kerang Lee"},
    Epic = { "Dolpin", "Paus Orca"},
    Legend = { "Ikan Balashark", "Ikan Matahari", "Ikan Pari"},
    Mythic = {"Hiu Paus", "Ikan Gedebong"},
    Secret = { "Kraken", "Leviathan", "Siluman Buaya Putih"},
}

local function choose_weighted(rng, list)
    local total = 0
    for _,v in ipairs(list) do total = total + v.weight end
    local pick = rng:random() * total
    local acc = 0
    for _,v in ipairs(list) do
        acc = acc + v.weight
        if pick < acc then
            return v
        end
    end
    return list[#list]
end

local function choose_from_pool(rng, tbl)
    local idx = rng:rand_int(1, #tbl)
    return tbl[idx]
end

local function cast_once(rng, luck)
    luck = luck or 0
    local modified = {}
    for i, r in ipairs(rarities) do
        local rarityIndex = i
        local boost = 0
        if rarityIndex >= 3 then
            boost = r.weight * (luck / 100) * (rarityIndex - 2)
        end
        table.insert(modified, { name = r.name, weight = r.weight+boost })
    end
    local chosenRarity = choose_weighted(rng, modified)
    local fishName = choose_from_pool(rng, fish_pool[chosenRarity.name])
    return {
        rarity = chosenRarity.name,
        fish = fishName
    }
end

local function sleep(seconds)
    if package.config:sub(1,1) == "\\" then
        os.execute("timeout " .. seconds .. " >nul")
    else
        os.execute("sleep " .. seconds)
    end
end

local function simulate(casts, seed, luck)
    local rng = RNG.new(seed)
    local counts = {}
    for _, r in ipairs(rarities) do counts[r.name] = 0 end 
    
    local jumlah = 0
    print(("Starting RNG System (seed=%d, luck=%d%%, delay=%ds))\n"):format(seed, luck, casts))
    print("Tekan CTRL+C untuk berhenti\n")

    while true do
        jumlah = jumlah + 1
        local result = cast_once(rng, luck)
        counts[result.rarity] = counts[result.rarity] + 1

        print(("[%04d] %-8s - %s"):format(jumlah, result.rarity, result.fish))

        if jumlah % 4500 == 0 then 
            print("\nSumary:")
            for _, r in ipairs(rarities) do
                print(("%-8s : %d"):format(r.name, counts[r.name]))
            end
            print("-----------------------------------------------------")
        end
        sleep(casts)
    end
end

local function main()
    local seed = 2025
    local luck = 999999999
    local casts = 1
    simulate(casts, seed, luck)
end

main()
