--[[
    Halls of Atonement - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Halls of Atonement"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "hoa_boss1",
            name = "Halkias",
            group = "Boss 1",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Siphon Life (Collector)",
                    "Loyal Beasts (Houndmaster)"
                },
                dispel = {
                    "Anima Tainted Armor (Tank) - Magic/Curse?",
                    "Mark of Obliteration (Obliterator) - Curse"
                },
                tank = {
                    "Anima Tainted Armor - Dispel/Defensive",
                    "Position carefully for Slam placement"
                },
                all = {
                    "STAY in red circle (Light of Atonement)",
                    "Leaving circle = Fear",
                    "Dodge Refracted Sinlight beams"
                }
            }
        },
        {
            id = "hoa_boss2",
            name = "Echelon",
            group = "Boss 2",
            keybind = 2,
            strategy = {
                interrupt = {
                    "Villainous Bolt (Stonefiend)"
                },
                tank = {
                    "Group adds for Stone Shattering Leap"
                },
                all = {
                    "Flesh to Stone (Curse): You become stone",
                    "Stone Shattering Leap MUST hit stone targets",
                    "Leap destroys Stonefiends - critical"
                }
            }
        },
        {
            id = "hoa_boss3",
            name = "High Adjudicator Aleez",
            group = "Boss 3",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Anima Bolt"
                },
                dispel = {
                    "Unstable Anima - Magic"
                },
                tank = {
                    "Position near Vessel/Urn"
                },
                all = {
                    "Fixated Ghost: Kite to Vessel instantly",
                    "Interrupt Anima Bolt"
                }
            }
        },
        {
            id = "hoa_boss4",
            name = "Lord Chamberlain",
            group = "Boss 4",
            keybind = 4,
            strategy = {
                tank = {
                    "Soak Ritual of Woe beams (Front)"
                },
                healer = {
                    "Ritual of Woe = Heavy Group Damage",
                    "Dispel Stigma of Pride"
                },
                dispel = {
                    "Stigma of Pride - Magic"
                },
                all = {
                    "Dodge Statue Toss",
                    "Soak Ritual of Woe beams (don't hit statues)",
                    "Focus Inquisitor Sigar (Trash)"
                }
            }
        }
    }
}
