--[[
    Priory of the Sacred Flame - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Priory of the Sacred Flame"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "priory_boss1",
            name = "Captain Dailcry",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Battle Cry (Enrage)",
                    "Fireball (Conjuror Trash)",
                    "Holy Smite (Priest Trash)"
                },
                dispel = {
                    "Repentance (Priest Trash) - Magic",
                    "Templar's Wrath (Templar) - Purge"
                },
                tank = {
                    "Pierce Armor = Heavy Phys Dmg",
                    "Kill Mini-Bosses to remove Boss Buffs"
                },
                all = {
                    "Sidestep Earthshattering Spear",
                    "Kill 3 Mini-Bosses before engaging boss",
                    "Suleyman, Aemya, Damian must die"
                }
            }
        },
        {
            id = "priory_boss2",
            name = "Baron Braunpyke",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                tank = {
                    "Soak Sacrificial Pyre stacks"
                },
                healer = {
                    "Heavy damage during Castigator's Shield"
                },
                interrupt = {
                    "Burning Light"
                },
                all = {
                    "Help soak Sacrificial Pyre (Immunities good)",
                    "Run away from Castigator's Detonation",
                    "Avoid Hammer of Purity swirls"
                }
            }
        },
        {
            id = "priory_boss3",
            name = "Prioress Murrpray",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Holy Smite",
                    "Embrace the Light (P2 - Critical Interrupt)"
                },
                tank = {
                    "Pick up adds in P2"
                },
                all = {
                    "Avoid Holy Flame (Ground)",
                    "Face AWAY for Blinding Light",
                    "P2 (50%): Break Shield -> Interrupt Boss"
                }
            }
        }
    }
}
