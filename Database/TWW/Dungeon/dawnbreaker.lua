--[[
    The Dawnbreaker - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["The Dawnbreaker"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "dawn_start",
            name = "Town & Barrel Event",
            group = "Speaker Shadowcrown TRASH",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Ensnaring Shadows (Shadowmage) - Priority Interrupt",
                    "Web Bolt (Sureki Webmage)"
                },
                tank = {
                    "Gather mobs for barrel running",
                    "Defensives for Nightfall Commander"
                },
                dispel = {
                    "Stygian Seed (Ritualist) - Magic/Curse?"
                },
                all = {
                    "Load explosive barrels on side ships",
                    "Avoid Abyssal Howl interrupt/damage"
                }
            }
        },
        {
            id = "dawn_boss1",
            name = "Speaker Shadowcrown",
            group = "Boss 1",
            keybind = 2,
            strategy = {
                interrupt = {
                    "Shadow Bolt"
                },
                tank = {
                    "Move boss away from Collapsing Night puddles",
                    "Face Obsidian Beam away"
                },
                healer = {
                    "Burning Shadows removal causes group damage",
                    "Top up party quickly"
                },
                dispel = {
                    "Burning Shadows - Magic (Group Damage on Remove)"
                },
                all = {
                    "DODGE Obsidian Beam - Lethal Damage",
                    "Darkness Comes (50%/5%): Fly to Radiant Light",
                    "Move out of Collapsing Night pools"
                }
            }
        },
        {
            id = "dawn_area2",
            name = "City Mini-Bosses",
            group = "Anub'ikkaj TRASH",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Tormenting Beam (Darkcaster)"
                },
                tank = {
                    "Collect Animate Shadows droplets on boss"
                },
                all = {
                    "Kill 3 Mini-Bosses to weaken Anub'ikkaj",
                    "Deathscreamer: Target for furthest orb travel",
                    "Vis'coxria: Defensives for Decay"
                }
            }
        },
        {
            id = "dawn_boss2",
            name = "Anub'ikkaj",
            group = "Boss 2",
            keybind = 4,
            strategy = {
                tank = {
                    "Collect Animate Shadows drops",
                    "CC Congealed Darkness"
                },
                healer = {
                    "Major CDs for Shadowy Decay"
                },
                all = {
                    "Dark Orb: Target run FAR away",
                    "Explosion damage reduced by distance",
                    "Avoid Terrifying Slam range"
                }
            }
        },
        {
            id = "dawn_boss3",
            name = "Rasha'nan",
            group = "Boss 3",
            keybind = 5,
            strategy = {
                tank = {
                    "Mitigation for Tacky Burst (P2)"
                },
                healer = {
                    "CDs for Erosive Spray (Stacks)",
                    "Heal Spinneret's Strands targets"
                },
                interrupt = {
                    "Acidic Eruption (P2 platform)"
                },
                all = {
                    "P1: Throw Arathi Bombs at boss",
                    "P2: Fly & collect Light Fragments",
                    "Break Spinneret's Strands webs quickly"
                }
            }
        }
    }
}
