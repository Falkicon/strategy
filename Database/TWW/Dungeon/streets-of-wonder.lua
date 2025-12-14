--[[
    Tazavesh: Streets of Wonder - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Tazavesh: Streets of Wonder"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "streets_boss1",
            name = "Zo'phex the Sentinel",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Hard Light Barrier (Support Officer)",
                    "Empowered Glyph (Portalmancer)"
                },
                dispel = {
                    "Glyph of Restraint (Specialist) - Magic",
                    "Hard Light Barrier (Officer) - Purge"
                },
                tank = {
                    "Defensives for Fully Armed"
                },
                all = {
                    "Interrogation: FREE TRAPPED PLAYER ASAP",
                    "Disarmed: Pick up your weapon immediately",
                    "Dodge Charged Slash"
                }
            }
        },
        {
            id = "streets_boss2",
            name = "The Grand Menagerie",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                tank = {
                    "Corner boss for Achillite orbs"
                },
                healer = {
                    "Purification Protocol: Dispel 1, Heal other",
                    "Detonation hurts group"
                },
                dispel = {
                    "Purification Protocol - Magic (Dispel ONE only)"
                },
                all = {
                    "Pass Gluttonous Feast debuff to Tank/Add",
                    "Whirling Annihilation: Run away from center",
                    "Break Chains of Damnation"
                }
            }
        },
        {
            id = "streets_boss3",
            name = "Mailroom Mayhem",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                tank = {
                    "Soak Hazardous Liquids (Pudpuddles)"
                },
                healer = {
                    "Dispel Alchemical Residue",
                    "Heal Fan Mail damage"
                },
                dispel = {
                    "Alchemical Residue - Magic"
                },
                all = {
                    "Throw Unstable Goods into Portal",
                    "Soak Hazardous Liquids (Don't let room fill)",
                    "Use Defensives for Fan Mail"
                }
            }
        },
        {
            id = "streets_boss4",
            name = "Myza's Oasis",
            group = "Boss 4",
            keybind = 4,
            strategy = {
                interrupt = {
                    "Menacing Shout - Heavy Group Damage"
                },
                tank = {
                    "Pick up add waves from market"
                },
                all = {
                    "Collect Instrument & Notes (12 stacks)",
                    "Stand BEHIND boss (Auto-parry front)",
                    "Burst down Final Warning shield"
                }
            }
        },
        {
            id = "streets_boss5",
            name = "So'azmi",
            group = "Boss 5",
            keybind = 5,
            strategy = {
                interrupt = {
                    "Double Technique"
                },
                tank = {
                    "Group up for Divide"
                },
                all = {
                    "Relocators: Teleport to avoid Shuri rings",
                    "Expanding rings = Lethal Damage",
                    "Learn pattern: Square -> Circle, etc."
                }
            }
        }
    }
}
