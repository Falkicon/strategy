--[[
    Tazavesh: So'leah's Gambit - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Tazavesh: So'leah's Gambit"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "gambit_boss1",
            name = "Hylbrande",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Cry of Mrrggllrrgg (Shellcrusher) - Mass Enrage",
                    "Valorous Bolt (Purifier)"
                },
                tank = {
                    "Stack Vault Purifiers on boss",
                    "Defensives for Shearing Swings"
                },
                dps = {
                    "KILL Vault Purifiers immediately",
                    "Stop Empowered Defense channel"
                },
                dispel = {
                    "Super Saison (Deckhand) - Enrage/Magic (Use Purge)"
                },
                all = {
                    "Console Phase: 1 clicker, others match colors",
                    "Kite Purged by Fire away from boss",
                    "Destroy Invigorating Fish Sticks (Trash)"
                }
            }
        },
        {
            id = "gambit_boss2",
            name = "Timecap'n Hooktail",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                tank = {
                    "Aim Infinite Breath at adds to kill them",
                    "Corsair Brute/Cannoneers = Breath targets"
                },
                healer = {
                    "Time Bomb dispel = Group Damage (Time it!)"
                },
                dispel = {
                    "Time Bomb - Magic (Explodes on dispel)"
                },
                all = {
                    "Stay out of water (Deadly Seas = Lethal Damage)",
                    "Stand in front of boss for Breath (if fixated add)"
                }
            }
        },
        {
            id = "gambit_boss3",
            name = "So'leah",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Unstable Rift (Ritualist) - Must Interrupt",
                    "Shuriken Blitz (Assassin)"
                },
                dps = {
                    "P1: Kill Assassins quickly"
                },
                healer = {
                    "Collapsing Star: Max 1 stack burst",
                    "Healing CDs for Star burst"
                },
                all = {
                    "P2: Use Hyperlight Jolt to break Stars",
                    "Dodge Hyperlight Nova and Fragmentation"
                }
            }
        }
    }
}
