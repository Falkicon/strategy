--[[
    Eco-dome Al'dani - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Eco-dome Al'dani"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "eco_boss1",
            name = "Azhiccar",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                tank = {
                    "Stay in melee to prevent Thrash"
                },
                healer = {
                    "Heal up before Devour cast"
                },
                interrupt = {
                    "Gorge (Mites) - prevent burst"
                },
                dispel = {
                    "Toxic Regurgitation (Boss) - Poison/Disease?"
                },
                all = {
                    "Devour: CC 2 packs of Mites",
                    "Don't let boss eat Mites",
                    "Stack for Frenzied Mites spawn",
                    "Don't stack for Toxic Regurgitation"
                }
            }
        },
        {
            id = "eco_boss2",
            name = "Taah'bat and A'wazj",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                tank = {
                    "Defensives for Rift Claws"
                },
                healer = {
                    "Heavy damage during Arcane Blitz",
                    "Warp Strikes stack damage"
                },
                dispel = {
                    "Arcing Energy (Ritualist) - Magic"
                },
                dps = {
                    "Aim 6 Warp Strikes at boss to break shield",
                    "Burst during vulnerable phase"
                },
                all = {
                    "Binding Javelin: Defensives & spread",
                    "Spread from other anchored players"
                }
            }
        },
        {
            id = "eco_boss3",
            name = "Soul-Scribe",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                tank = {
                    "Standard tanking"
                },
                healer = {
                    "Monitor Dread of the Unknown damage",
                    "Echoes of Fate debuff is dangerous"
                },
                all = {
                    "Collect YOUR soul (Fatebound)",
                    "Avoid Ceremonial Dagger",
                    "Eternal Weave: Collect ALL souls",
                    "Don't get hit by frontal while collecting"
                }
            }
        }
    }
}
