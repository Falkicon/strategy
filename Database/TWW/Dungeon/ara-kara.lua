--[[
    Ara-Kara, City of Echoes - TWW S3 Dungeon
    Strategy Data
]]

if not StrategyDatabase then StrategyDatabase = {} end
if not StrategyDatabase.Instances then StrategyDatabase.Instances = {} end

StrategyDatabase.Instances["Ara-Kara, City of Echoes"] = {
    instanceID = 0, -- TODO: Update with real ID
    expansion = "TWW",
    instanceType = "dungeon",
    strategies = {
        {
            id = "arakara_start",
            name = "Starting Area",
            group = "Avanoxx TRASH",
            keybind = 1,
            strategy = {
                interrupt = {
                    "Resonant Barrage (Trilling Attendant) - PRIORITY",
                    "Horrifying Shrill (Ixin) - MUST INTERRUPT"
                },
                tank = {
                    "Pull Silk from Attendants if Tailoring active",
                    "Engorged Crawler spit hurts - use defensives"
                },
                dispel = {
                    "Venomous Spit (Engorged Crawler) - Poison",
                    "Web Wrap (Trash) - Magic"
                },
                all = {
                    "Tailors (25+): Use Silk to stun mobs",
                    "Ravenous Crawlers ambush random players",
                    "Avoid Web Spray frontals from mini-bosses"
                }
            }
        },
        {
            id = "arakara_boss1",
            name = "Avanoxx",
            group = "Boss 1",
            keybind = 2,
            strategy = {
                tank = {
                    "Position boss away from Starved Crawlers",
                    "Defensives for Voracious Bite"
                },
                dps = {
                    "FOCUS Starved Crawlers immediately",
                    "CC works on crawlers"
                },
                healer = {
                    "Healing CDs for Alerting Shrill",
                    "Heavy healing during Gossamer Onslaught"
                },
                dispel = {
                    "Web Wrap (10 stacks) - Priority Dispel"
                },
                all = {
                    "Prevent Crawlers from reaching boss (Stacking Buff)",
                    "Avoid Gossamer Onslaught pools",
                    "Web Wrap at 10 stacks - dispel or avoid"
                }
            }
        },
        {
            id = "arakara_area2",
            name = "Road to Anub'zekt",
            group = "Anub'zekt TRASH",
            keybind = 3,
            strategy = {
                interrupt = {
                    "Revolting Volley (Webmage) - PRIORITY",
                    "Silken Restraints (Webmage)"
                },
                tank = {
                    "Watch for Sentry Stagshell Alarm Shrill",
                    "Skip Hulking Bloodguard if possible"
                },
                all = {
                    "Bloodworker charges random players",
                    "Sidestep Impale frontals"
                }
            }
        },
        {
            id = "arakara_boss2",
            name = "Anub'zekt",
            group = "Boss 2",
            keybind = 4,
            strategy = {
                tank = {
                    "Face Impale away from group",
                    "Stack adds for cleave"
                },
                interrupt = {
                    "Silken Restraints (Webmage)"
                },
                healer = {
                    "Spot heal Infestation targets",
                    "Eye of Swarm: Heal w/ movement"
                },
                all = {
                    "Run away from Burrow Charge",
                    "Stand in Safe Area during Eye of the Swarm",
                    "Avoid Ceaseless Swarm swirlies"
                }
            }
        },
        {
            id = "arakara_boss3",
            name = "Ki'katal the Harvester",
            group = "Boss 3",
            keybind = 5,
            strategy = {
                tank = {
                    "Group Black Bloods near boss"
                },
                healer = {
                    "Dispel Cultivated Poisons (Caution: Waves)",
                    "Spot heal debuff targets"
                },
                dispel = {
                    "Cultivated Poisons - POISON (Triggers Waves)"
                },
                dps = {
                    "Force Bloodworkers to drop Grasping Blood"
                },
                all = {
                    "Singularity: Step in Grasping Blood to root",
                    "Break root after Singularity cast",
                    "Sidestep Erupting Webs"
                }
            }
        }
    }
}
