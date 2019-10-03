local CAT = "prkd" -- prkd, hundo

local last_state = {} -- holds all state that has been changed up untill last save

local preset_output = ""
local last_step = nil

local MEMTRACK = { -- {{{
    { 0x07C3, 0x6, 'GFX Pointers' },
    { 0x07F3, 0x2, 'Music Bank' },
    { 0x07F5, 0x2, 'Music Track' },
    { 0x078B, 0x2, 'Elevator Index' },
    { 0x078D, 0x2, 'DDB' },
    { 0x078F, 0x2, 'DoorOut Index' },
    { 0x079B, 0x2, 'MDB' },
    { 0x079F, 0x2, 'Region' },

    --[[
    { 0x08F7, 0x2, 'How many blocks X the screen is scrolled?' },
    { 0x08F9, 0x2, 'How many blocks Y the screen is scrolled? (up = positive)' },
    { 0x08FB, 0x2, 'How many blocks X Layer 2 is scrolled?' },
    { 0x08FD, 0x2, 'How many blocks Y Layer 2 is scrolled? (up = positive)' },
    { 0x08FF, 0x2, 'How many blocks X the screen was scrolled previously (Checked to know when to update blocks)' },
    { 0x0901, 0x2, 'How many blocks Y the screen was scrolled previously (Checked to know when to update blocks) (up = positive)' },
    { 0x0903, 0x2, 'How many blocks X Layer 2 was scrolled previously (Checked to know when to update blocks)' },
    { 0x0905, 0x2, 'How many blocks Y Layer 2 was scrolled previously (Checked to know when to update blocks) (up = positive)' },
    { 0x0907, 0x2, 'How many blocks X BG1 is scrolled?' },
    { 0x0909, 0x2, 'How many blocks Y BG1 is scrolled? (up = positive)' },
    { 0x090B, 0x2, 'How many blocks X BG2 is scrolled?' },
    { 0x090D, 0x2, 'How many blocks Y BG2 is scrolled? (up = positive)' },
    ]]
    { 0x090F, 0x2, 'Screen subpixel X position.' },
    { 0x0911, 0x2, 'Screen X position in pixels' },
    { 0x0913, 0x2, 'Screen subpixel Y position' },
    { 0x0915, 0x2, 'Screen Y position in pixels' },
    --[[
    { 0x0917, 0x2, 'Layer 2 X scroll in room in pixels?' },
    { 0x0919, 0x2, 'Layer 2 Y scroll in room in pixels? (up = positive)' },
    { 0x091B, 0x2, 'BG2 scroll percent to screen scroll (0 = 100, 1 = ?) (1 byte for X, 1 byte for Y)' },
    { 0x091D, 0x2, 'BG1 X scroll offset due to room transitions (Translates between screen scroll and BG1 scroll)' },
    { 0x091F, 0x2, 'BG1 Y scroll offset due to room transitions (Translates between screen scroll and BG1 scroll)' },
    { 0x0921, 0x2, 'BG2 X scroll offset due to room transitions (Translates between Layer 2 scroll and BG2 scroll)' },
    { 0x0923, 0x2, 'BG2 Y scroll offset due to room transitions (Translates between Layer 2 scroll and BG2 scroll)' },
    { 0x0925, 0x2, 'How many times the screen has scrolled? Stops at 40.' },
    { 0x0927, 0x2, 'X offset of room entrance for room transition (multiple of 100, screens)' },
    { 0x0929, 0x2, 'Y offset of room entrance for room transition (multiple of 100, screens. Adjusted by 20 when moving up)' },
    { 0x092B, 0x2, 'Movement speed for room transitions (subpixels per frame of room transition movement)' },
    { 0x092D, 0x2, 'Movement speed for room transitions (pixels per frame of room transition movement)' },
    --]]
    { 0x093F, 0x2, 'Ceres escape flag' },

    { 0x09A2, 0x2, 'Equipped Items' },
    { 0x09A4, 0x2, 'Collected Items' },
    { 0x09A6, 0x2, 'Beams' },
    { 0x09A8, 0x2, 'Beams' },
    { 0x09C0, 0x2, 'Manual/Auto reserve tank' },
    { 0x09C2, 0x2, 'Health' },
    { 0x09C4, 0x2, 'Max helath' },
    { 0x09C6, 0x2, 'Missiles' },
    { 0x09C8, 0x2, 'Max missiles' },
    { 0x09CA, 0x2, 'Supers' },
    { 0x09CC, 0x2, 'Max supers' },
    { 0x09CE, 0x2, 'Pbs' },
    { 0x09D0, 0x2, 'Max pbs' },
    -- { 0x09D2, 0x2, 'Current selected weapon' },
    { 0x09D4, 0x2, 'Max reserves' },
    { 0x09D6, 0x2, 'Reserves' },
    -- { 0x0A04, 0x2, 'Auto-cancel item' },
    { 0x0A1C, 0x2, 'Samus position/state' },
    { 0x0A1E, 0x2, 'More position/state' },
    { 0x0A68, 0x2, 'Flash suit' },
    { 0x0A76, 0x2, 'Hyper beam' },
    { 0x0AF6, 0x2, 'Samus X' },
    { 0x0AFA, 0x2, 'Samus Y' },
    { 0x0B3F, 0x2, 'Blue suit' },
    { 0xD7C0, 0x60, 'SRAM copy' }, -- Prob not doing much?
    { 0xD820, 0x100, 'Events, Items, Doors' },
    -- { 0xD840, 0x40, 'Items' },
    -- { 0xD8B0, 0x40, 'Doors' },
    -- { 0xD914, 0x2, 'Game mode?' },

} -- }}}

local SEGMENTS = {
    ["prkd"] = { -- {{{
        { ["name"] = "Bombs", ["steps"] = {} },
        { ["name"] = "Power Bombs", ["steps"] = {} },
        { ["name"] = "Gravity Suit", ["steps"] = {} },
        { ["name"] = "Cathedral", ["steps"] = {} },
        { ["name"] = "Ridley", ["steps"] = {} },
        { ["name"] = "Kraid", ["steps"] = {} },
        { ["name"] = "Draygon", ["steps"] = {} },
        { ["name"] = "Golden 4", ["steps"] = {} },
        { ["name"] = "Tourian", ["steps"] = {} },
    }, -- }}}
    ["hundo"] = {
        { ["name"] = "Bombs", ["steps"] = {} },
        { ["name"] = "Kraid", ["steps"] = {} },
        { ["name"] = "Speed Booster", ["steps"] = {} },
        { ["name"] = "Ice Beam", ["steps"] = {} },
        { ["name"] = "Phantoon", ["steps"] = {} },
        { ["name"] = "Gravity", ["steps"] = {} },
        { ["name"] = "Waterway E-Tank", ["steps"] = {} },
        { ["name"] = "Mama Turtle E-Tank", ["steps"] = {} },
        { ["name"] = "Maridia Cleanup", ["steps"] = {} },
        { ["name"] = "Draygon", ["steps"] = {} },
        { ["name"] = "Maridia Cleanup 2", ["steps"] = {} },
        { ["name"] = "Golden Torizo", ["steps"] = {} },
        { ["name"] = "Ridley", ["steps"] = {} },
        { ["name"] = "Crocomire", ["steps"] = {} },
        { ["name"] = "Brinstar Cleanup", ["steps"] = {} },
        { ["name"] = "Tourian", ["steps"] = {} },
    },
}

local STEPS = {
    ["hundo"] = {
        -- Bombs
        [1501] = { ["segment_no"] = 1, ["name"] = "Ceres elevator" },
        [5280] = { ["segment_no"] = 1, ["name"] = "Ceres Last 3 rooms" },
        [9200] = { ["segment_no"] = 1, ["name"] = "Ship" },
        [9497] = { ["segment_no"] = 1, ["name"] = "Parlor down" },
        [12466] = { ["segment_no"] = 1, ["name"] = "Morph" },
        [16062] = { ["segment_no"] = 1, ["name"] = "Pit Room" },
        [16694] = { ["segment_no"] = 1, ["name"] = "Climb" },
        [18258] = { ["segment_no"] = 1, ["name"] = "Parlor up" },
        [19958] = { ["segment_no"] = 1, ["name"] = "Bomb Torizo" },

        -- Kraid
        [22527] = { ["segment_no"] = 2, ["name"] = "Alcatraz" },
        [23146] = { ["segment_no"] = 2, ["name"] = "Terminator" },
        [24193] = { ["segment_no"] = 2, ["name"] = "Pirates Shaft" },
        [25775] = { ["segment_no"] = 2, ["name"] = "Elevator" },
        [26857] = { ["segment_no"] = 2, ["name"] = "Early Supers" },
        [30136] = { ["segment_no"] = 2, ["name"] = "Reverse Mockball" },
        [31884] = { ["segment_no"] = 2, ["name"] = "Dachora Room" },
        [32914] = { ["segment_no"] = 2, ["name"] = "Big Pink" },
        [34754] = { ["segment_no"] = 2, ["name"] = "Green Hill Zone" },
        [36413] = { ["segment_no"] = 2, ["name"] = "Red Tower" },
        [40264] = { ["segment_no"] = 2, ["name"] = "Kraid Entry" },
        [42679] = { ["segment_no"] = 2, ["name"] = "Kraid" },
        [45270] = { ["segment_no"] = 2, ["name"] = "Leaving Varia" },
        [46500] = { ["segment_no"] = 2, ["name"] = "Leaving Kraid Hallway" },
        [47373] = { ["segment_no"] = 2, ["name"] = "Kraid E-Tank" },
        [48342] = { ["segment_no"] = 2, ["name"] = "Kraid Escape" },

        -- Speed Booster
        [49160] = { ["segment_no"] = 3, ["name"] = "Business Center" },
        [50624] = { ["segment_no"] = 3, ["name"] = "Hi Jump" },
        [53201] = { ["segment_no"] = 3, ["name"] = "Business Center Climb" },
        [53670] = { ["segment_no"] = 3, ["name"] = "Cathedral Entrance" },
        [54323] = { ["segment_no"] = 3, ["name"] = "Cathedral" },
        [55600] = { ["segment_no"] = 3, ["name"] = "Rising Tide" },
        [56280] = { ["segment_no"] = 3, ["name"] = "Bubble Mountain" },
        [57070] = { ["segment_no"] = 3, ["name"] = "Bat Cave" },
        [59761] = { ["segment_no"] = 3, ["name"] = "Leaving Speed Booster" },

        -- Ice Beam
        [61212] = { ["segment_no"] = 4, ["name"] = "Single Chamber" },
        [61604] = { ["segment_no"] = 4, ["name"] = "Double Chamber" },
        [63455] = { ["segment_no"] = 4, ["name"] = "Double Chamber Revisited" },
        [64415] = { ["segment_no"] = 4, ["name"] = "Bubble Mountain Revisited" },
        [66356] = { ["segment_no"] = 4, ["name"] = "Business Center Climb Ice" },
        [66809] = { ["segment_no"] = 4, ["name"] = "Ice Beam Gate Room" },
        [67458] = { ["segment_no"] = 4, ["name"] = "Ice Beam Snake Room" },
        [68610] = { ["segment_no"] = 4, ["name"] = "Ice Beam Snake Room Revisit" },
        [69037] = { ["segment_no"] = 4, ["name"] = "Ice Beam Gate Room Escape" },
        [69700] = { ["segment_no"] = 4, ["name"] = "Business Center Elevator" },

        -- Phantoon
        [70882] = { ["segment_no"] = 5, ["name"] = "Alpha Spark" },
        [72108] = { ["segment_no"] = 5, ["name"] = "Red Tower Revisit" },
        [73200] = { ["segment_no"] = 5, ["name"] = "Hellway" },
        [75757] = { ["segment_no"] = 5, ["name"] = "Red Brinstar Elevator" },
        [76482] = { ["segment_no"] = 5, ["name"] = "Beta PBs" },
        [79320] = { ["segment_no"] = 5, ["name"] = "Kihunter Room" },
        [80235] = { ["segment_no"] = 5, ["name"] = "Ocean Fly" },
        [84475] = { ["segment_no"] = 5, ["name"] = "Phantoon" },

        -- Gravity
        [89050] = { ["segment_no"] = 6, ["name"] = "WS Shaft Up 1" },
        [89674] = { ["segment_no"] = 6, ["name"] = "WS Right Supers" },
        [92355] = { ["segment_no"] = 6, ["name"] = "WS Shaft Up 2" },
        [92911] = { ["segment_no"] = 6, ["name"] = "Spiky Room of Death" },
        [94255] = { ["segment_no"] = 6, ["name"] = "WS E-Tank" },
        [95743] = { ["segment_no"] = 6, ["name"] = "Spiky Room of Death Revisit" },
        [97343] = { ["segment_no"] = 6, ["name"] = "WS Shaft Up 3" },
        [98124] = { ["segment_no"] = 6, ["name"] = "Attic" },
        [99045] = { ["segment_no"] = 6, ["name"] = "WS Robot Missiles" },
        [100842] = { ["segment_no"] = 6, ["name"] = "Attic Revisit" },
        [101459] = { ["segment_no"] = 6, ["name"] = "Sky Missiles" },
        [104565] = { ["segment_no"] = 6, ["name"] = "Bowling" },
        [107961] = { ["segment_no"] = 6, ["name"] = "WS Reserve -- This one probably won't work" },
        [110601] = { ["segment_no"] = 6, ["name"] = "Leaving Gravity" },

        -- Waterway E-Tank
        [112239] = { ["segment_no"] = 7, ["name"] = "Reverse Moat" },
        [113829] = { ["segment_no"] = 7, ["name"] = "Crateria PBs" },
        [114860] = { ["segment_no"] = 7, ["name"] = "Ship Room" },
        [116854] = { ["segment_no"] = 7, ["name"] = "Gauntlet E-Tank" },
        [117904] = { ["segment_no"] = 7, ["name"] = "Green Pirates Shaft" },
        [120538] = { ["segment_no"] = 7, ["name"] = "Green Shaft Revisit" },
        [121960] = { ["segment_no"] = 7, ["name"] = "Green Brinstar Beetoms" },
        [123269] = { ["segment_no"] = 7, ["name"] = "Etecoon Energy Tank Room" },
        [124497] = { ["segment_no"] = 7, ["name"] = "Etecoon Room" },
        [126363] = { ["segment_no"] = 7, ["name"] = "Dachora Room Revisit" },
        [126856] = { ["segment_no"] = 7, ["name"] = "Big Pink Revisit" },
        [127971] = { ["segment_no"] = 7, ["name"] = "Mission Impossible PBs" },
        [129390] = { ["segment_no"] = 7, ["name"] = "Pink Brinstar E-Tank" },
        [130948] = { ["segment_no"] = 7, ["name"] = "Spore Spawn Supers" },
        [134690] = { ["segment_no"] = 7, ["name"] = "Waterway E-Tank" },

        -- Mama Turtle E-Tank
        [136026] = { ["segment_no"] = 8, ["name"] = "Big Pink Charge Escape" },
        [136728] = { ["segment_no"] = 8, ["name"] = "Green Hills Revisit" },
        [138465] = { ["segment_no"] = 8, ["name"] = "Blockbuster" },
        [141011] = { ["segment_no"] = 8, ["name"] = "Main Street" },
        [142247] = { ["segment_no"] = 8, ["name"] = "Fish Tank" },
        [142968] = { ["segment_no"] = 8, ["name"] = "Mama Turtle E-Tank" },

        -- Maridia Cleanup
        [144612] = { ["segment_no"] = 9, ["name"] = "Fish Tank Revisit" },
        [145345] = { ["segment_no"] = 9, ["name"] = "Crab Supers" },
        [146431] = { ["segment_no"] = 9, ["name"] = "Mt Everest" },
        [146968] = { ["segment_no"] = 9, ["name"] = "Beach Missiles" },
        [148116] = { ["segment_no"] = 9, ["name"] = "Maridia Bug Room" },
        [148950] = { ["segment_no"] = 9, ["name"] = "Watering Hole" },
        [150565] = { ["segment_no"] = 9, ["name"] = "Maridia Bug Room Revisit" },
        [151033] = { ["segment_no"] = 9, ["name"] = "Beach Revisit" },

        -- Draygon
        [151922] = { ["segment_no"] = 10, ["name"] = "Aqueduct" },
        [153180] = { ["segment_no"] = 10, ["name"] = "Botwoon" },
        [154298] = { ["segment_no"] = 10, ["name"] = "Full Halfie" },
        [155722] = { ["segment_no"] = 10, ["name"] = "Draygon Missiles" },
        [156864] = { ["segment_no"] = 10, ["name"] = "Draygon" },
        [160569] = { ["segment_no"] = 10, ["name"] = "Draygon Escape" },

        -- Maridia Cleanup 2
        [163453] = { ["segment_no"] = 11, ["name"] = "Aqueduct Revisit 1" },
        [164615] = { ["segment_no"] = 11, ["name"] = "Right Sandpit" },
        [167673] = { ["segment_no"] = 11, ["name"] = "Puyo Ice Clip (Springball)" },
        [168307] = { ["segment_no"] = 11, ["name"] = "Shaktool" },
        [172283] = { ["segment_no"] = 11, ["name"] = "Shaktool Revisit" },
        [173306] = { ["segment_no"] = 11, ["name"] = "East Sand Hall" },
        [175380] = { ["segment_no"] = 11, ["name"] = "Kassiuz Room" },
        [176088] = { ["segment_no"] = 11, ["name"] = "Plasma" },
        [177385] = { ["segment_no"] = 11, ["name"] = "Kassiuz Room Revisit" },
        [178061] = { ["segment_no"] = 11, ["name"] = "Plasma Spark Room Down" },
        [178658] = { ["segment_no"] = 11, ["name"] = "Cac Alley" },
        [180242] = { ["segment_no"] = 11, ["name"] = "Aqueduct Revisit 2" },
        [182949] = { ["segment_no"] = 11, ["name"] = "Left Sandpit" },
        [186584] = { ["segment_no"] = 11, ["name"] = "Thread the Needle Room" },

        -- Golden Torizo
        [187255] = { ["segment_no"] = 12, ["name"] = "Kraid Entrance Revisit" },
        [188216] = { ["segment_no"] = 12, ["name"] = "Kraid Missiles" },
        [189312] = { ["segment_no"] = 12, ["name"] = "Kraid Missiles Escape" },
        [191250] = { ["segment_no"] = 12, ["name"] = "Ice Missiles" },
        [192810] = { ["segment_no"] = 12, ["name"] = "Croc Speedway" },
        [194316] = { ["segment_no"] = 12, ["name"] = "Kronic Boost" },
        [195591] = { ["segment_no"] = 12, ["name"] = "Blue Fireball" },
        [198593] = { ["segment_no"] = 12, ["name"] = "Golden Torizo" },

        -- Ridley
        [202166] = { ["segment_no"] = 13, ["name"] = "Fast Ripper Room" },
        [203324] = { ["segment_no"] = 13, ["name"] = "WRITG" },
        [204036] = { ["segment_no"] = 13, ["name"] = "Mickey Mouse Missiles" },
        [205458] = { ["segment_no"] = 13, ["name"] = "Amphitheatre" },
        [206284] = { ["segment_no"] = 13, ["name"] = "Kihunter Shaft Down" },
        [207455] = { ["segment_no"] = 13, ["name"] = "Wasteland Down" },
        [209248] = { ["segment_no"] = 13, ["name"] = "Ninja Pirates" },
        [210110] = { ["segment_no"] = 13, ["name"] = "Plowerhouse Room" },
        [210890] = { ["segment_no"] = 13, ["name"] = "Ridley" },
        [214330] = { ["segment_no"] = 13, ["name"] = "Ridley Escape" },
        [216087] = { ["segment_no"] = 13, ["name"] = "Wasteland Up" },
        [217163] = { ["segment_no"] = 13, ["name"] = "Kihunter Shaft Up" },
        [218280] = { ["segment_no"] = 13, ["name"] = "Firefleas Room" },
        [220036] = { ["segment_no"] = 13, ["name"] = "Hotarubi Special" },
        [223280] = { ["segment_no"] = 13, ["name"] = "3 Muskateers" },

        -- Crocomire
        [225698] = { ["segment_no"] = 14, ["name"] = "Bubble Mountain Revisit" },
        [227026] = { ["segment_no"] = 14, ["name"] = "Norfair Reserve" },
        [228929] = { ["segment_no"] = 14, ["name"] = "Bubble Mountain Cleanup" },
        [230968] = { ["segment_no"] = 14, ["name"] = "Red Pirate Shaft" },
        [231993] = { ["segment_no"] = 14, ["name"] = "Crocomire" },
        [236020] = { ["segment_no"] = 14, ["name"] = "Croc PBs" },
        [237684] = { ["segment_no"] = 14, ["name"] = "Croc Shaft Down" },
        [240288] = { ["segment_no"] = 14, ["name"] = "Croc Shaft Up" },
        [242667] = { ["segment_no"] = 14, ["name"] = "Crocomire Room Revisit" },
        [243597] = { ["segment_no"] = 14, ["name"] = "Croc Escape" },
        [244449] = { ["segment_no"] = 14, ["name"] = "Business Center Climb Final" },

        -- Brinstar Cleanup
        [246530] = { ["segment_no"] = 15, ["name"] = "Below Spazer" },
        [247086] = { ["segment_no"] = 15, ["name"] = "Red Tower X-Ray" },
        [247721] = { ["segment_no"] = 15, ["name"] = "Red Brinstar Fireflea Room" },
        [249555] = { ["segment_no"] = 15, ["name"] = "Red Brinstar Fireflea Revisit" },
        [251220] = { ["segment_no"] = 15, ["name"] = "Reverse Slinky" },
        [252203] = { ["segment_no"] = 15, ["name"] = "Retro Brinstar Hoppers" },
        [253469] = { ["segment_no"] = 15, ["name"] = "Retro Brinstar E-Tank" },
        [254915] = { ["segment_no"] = 15, ["name"] = "Billy Mays" },
        [256482] = { ["segment_no"] = 15, ["name"] = "Billy Mays Escape" },
        [257731] = { ["segment_no"] = 15, ["name"] = "Retro Brinstar Escape" },
        [259284] = { ["segment_no"] = 15, ["name"] = "Pit Room Spark" },
        [260575] = { ["segment_no"] = 15, ["name"] = "Climb Supers" },
        [263127] = { ["segment_no"] = 15, ["name"] = "The Last Missiles" },
        [264203] = { ["segment_no"] = 15, ["name"] = "The Last Missiles Escape" },
        [265182] = { ["segment_no"] = 15, ["name"] = "Terminator Revisit" },

        -- Tourian
        [270498] = { ["segment_no"] = 16, ["name"] = "Metroids 1" },
        [271033] = { ["segment_no"] = 16, ["name"] = "Metroids 2" },
        [271783] = { ["segment_no"] = 16, ["name"] = "Metroids 3" },
        [272287] = { ["segment_no"] = 16, ["name"] = "Metroids 4" },
        [273359] = { ["segment_no"] = 16, ["name"] = "Baby Skip" },
        [275659] = { ["segment_no"] = 16, ["name"] = "Zeb Skip" },
        [287672] = { ["segment_no"] = 16, ["name"] = "Escape Room 3" },
        [289942] = { ["segment_no"] = 16, ["name"] = "Escape Parlor" },
    },
    ["prkd"] = { -- {{{
        -- Bombs
        [1501] = { ["segment_no"] = 1, ["name"] = "Elevator" },
        [5280] = { ["segment_no"] = 1, ["name"] = "Ceres Last 3 rooms" },
        [9200] = { ["segment_no"] = 1, ["name"] = "Ship" },
        [9497] = { ["segment_no"] = 1, ["name"] = "Parlor down" },
        [12466] = { ["segment_no"] = 1, ["name"] = "Morph" },
        [16062] = { ["segment_no"] = 1, ["name"] = "Pit Room" },
        [16694] = { ["segment_no"] = 1, ["name"] = "Climb" },
        [18258] = { ["segment_no"] = 1, ["name"] = "Parlor up" },
        [19958] = { ["segment_no"] = 1, ["name"] = "Bomb Torizo" },
        -- PBs
        [22527] = { ["segment_no"] = 2, ["name"] = "Alcatraz" },
        [23146] = { ["segment_no"] = 2, ["name"] = "Terminator" },
        [24193] = { ["segment_no"] = 2, ["name"] = "Pirates Shaft" },
        [25775] = { ["segment_no"] = 2, ["name"] = "Elevator" },
        [26857] = { ["segment_no"] = 2, ["name"] = "Early Supers" },
        [28585] = { ["segment_no"] = 2, ["name"] = "Dachora Room" },
        [29701] = { ["segment_no"] = 2, ["name"] = "Big Pink" },
        [32107] = { ["segment_no"] = 2, ["name"] = "Green Hill Zone" },
        [33851] = { ["segment_no"] = 2, ["name"] = "Red Tower" },
        [34784] = { ["segment_no"] = 2, ["name"] = "Hellway" },
        [35265] = { ["segment_no"] = 2, ["name"] = "Caterpillar Room down" },
        -- Grav
        [36883] = { ["segment_no"] = 3, ["name"] = "Caterpillar Room up" },
        [39111] = { ["segment_no"] = 3, ["name"] = "Kihunter Room" },
        [40245] = { ["segment_no"] = 3, ["name"] = "Moat" },
        [42330] = { ["segment_no"] = 3, ["name"] = "Wrecked Ship Enter" },
        [43520] = { ["segment_no"] = 3, ["name"] = "Phantoon" },
        [48225] = { ["segment_no"] = 3, ["name"] = "Wrecked Ship Climb" },
        [50996] = { ["segment_no"] = 3, ["name"] = "Attic" },
        [53119] = { ["segment_no"] = 3, ["name"] = "Bowling Alley farm" },
        [57285] = { ["segment_no"] = 3, ["name"] = "Grav" },
        -- Cathedral
        [58777] = { ["segment_no"] = 4, ["name"] = "Kihunter Room" },
        [59709] = { ["segment_no"] = 4, ["name"] = "Caterpillar Room" },
        [61221] = { ["segment_no"] = 4, ["name"] = "Red Tower" },
        [62460] = { ["segment_no"] = 4, ["name"] = "Bat Room" },
        [64934] = { ["segment_no"] = 4, ["name"] = "Glass Tunnel" },
        [66100] = { ["segment_no"] = 4, ["name"] = "Business Center" },
        [67214] = { ["segment_no"] = 4, ["name"] = "Hi Jump" },
        [69710] = { ["segment_no"] = 4, ["name"] = "Business Center climb" },
        [71169] = { ["segment_no"] = 4, ["name"] = "Ice Beam Snake Room" },
        [73100] = { ["segment_no"] = 4, ["name"] = "Ice Escape" },
        [74208] = { ["segment_no"] = 4, ["name"] = "Cathedral Entrance" },
        -- Ridley
        [74908] = { ["segment_no"] = 5, ["name"] = "Cathedral" },
        [76178] = { ["segment_no"] = 5, ["name"] = "Bubble Mountain" },
        [77945] = { ["segment_no"] = 5, ["name"] = "Bat Cave" },
        [80260] = { ["segment_no"] = 5, ["name"] = "Bat Cave revisited" },
        [82762] = { ["segment_no"] = 5, ["name"] = "Single Chamber" },
        [83343] = { ["segment_no"] = 5, ["name"] = "Double Chamber" },
        [85242] = { ["segment_no"] = 5, ["name"] = "Double Chamber revisited" },
        [86792] = { ["segment_no"] = 5, ["name"] = "Volcano Room" },
        [88082] = { ["segment_no"] = 5, ["name"] = "Lavaspark" },
        [89060] = { ["segment_no"] = 5, ["name"] = "LN Elevator" },
        [90538] = { ["segment_no"] = 5, ["name"] = "Fast Pillars" },
        [91679] = { ["segment_no"] = 5, ["name"] = "WRITG" },
        [92739] = { ["segment_no"] = 5, ["name"] = "Amphitheatre" },
        [94150] = { ["segment_no"] = 5, ["name"] = "Kihunter shaft" },
        [94961] = { ["segment_no"] = 5, ["name"] = "Wasteland" },
        [96756] = { ["segment_no"] = 5, ["name"] = "Metal Pirates" },
        [98280] = { ["segment_no"] = 5, ["name"] = "Ridley Farming Room" },
        [100442] = { ["segment_no"] = 5, ["name"] = "Ridley" },
        -- Kraid
        [105917] = { ["segment_no"] = 6, ["name"] = "Ridley Farming Room" },
        [107542] = { ["segment_no"] = 6, ["name"] = "Wasteland" },
        [108699] = { ["segment_no"] = 6, ["name"] = "Kihunter shaft" },
        [110020] = { ["segment_no"] = 6, ["name"] = "Fireflea Room" },
        [111280] = { ["segment_no"] = 6, ["name"] = "Three Muskateers Room" },
        [112226] = { ["segment_no"] = 6, ["name"] = "Single Chamber" },
        [113678] = { ["segment_no"] = 6, ["name"] = "Bubble Mountain" },
        [114745] = { ["segment_no"] = 6, ["name"] = "Frog Speedway" },
        [116822] = { ["segment_no"] = 6, ["name"] = "Warehouse Entrance" },
        [117063] = { ["segment_no"] = 6, ["name"] = "Zeela Room" },
        [118110] = { ["segment_no"] = 6, ["name"] = "Baby Kraid" },
        [118925] = { ["segment_no"] = 6, ["name"] = "Kraid" },
        -- Draygon
        [122558] = { ["segment_no"] = 7, ["name"] = "Baby Kraid" },
        [123896] = { ["segment_no"] = 7, ["name"] = "Warehouse Entrance" },
        [124625] = { ["segment_no"] = 7, ["name"] = "Glass Tunnel" },
        [125698] = { ["segment_no"] = 7, ["name"] = "Fish Tank" },
        [126840] = { ["segment_no"] = 7, ["name"] = "Crab Shaft" },
        [128032] = { ["segment_no"] = 7, ["name"] = "Botwoon Hallway" },
        [128624] = { ["segment_no"] = 7, ["name"] = "Botwoon" },
        [130882] = { ["segment_no"] = 7, ["name"] = "Halfie Climb" },
        [133633] = { ["segment_no"] = 7, ["name"] = "Draygon" },
        -- Golden Four
        [137206] = { ["segment_no"] = 8, ["name"] = "Precious Room" },
        [138261] = { ["segment_no"] = 8, ["name"] = "Halfie Climb" },
        [139318] = { ["segment_no"] = 8, ["name"] = "Botwoon Hallway" },
        [140401] = { ["segment_no"] = 8, ["name"] = "Crab Shaft" },
        [140934] = { ["segment_no"] = 8, ["name"] = "Mt Everest" },
        [142279] = { ["segment_no"] = 8, ["name"] = "Caterpillar Room" },
        [144090] = { ["segment_no"] = 8, ["name"] = "Kihunter Room" },
        [145017] = { ["segment_no"] = 8, ["name"] = "Parlor" },
        [145530] = { ["segment_no"] = 8, ["name"] = "Terminator" },
        [146715] = { ["segment_no"] = 8, ["name"] = "Golden Four" },
        -- Tourian
        [150256] = { ["segment_no"] = 9, ["name"] = "Enter Tourian" },
        [151618] = { ["segment_no"] = 9, ["name"] = "M1" },
        [152430] = { ["segment_no"] = 9, ["name"] = "M2" },
        [152908] = { ["segment_no"] = 9, ["name"] = "M3" },
        [153822] = { ["segment_no"] = 9, ["name"] = "M4" },
        [155354] = { ["segment_no"] = 9, ["name"] = "Baby Skip" },
        [158334] = { ["segment_no"] = 9, ["name"] = "Tourian Eye Door" },
        [174836] = { ["segment_no"] = 9, ["name"] = "Escape Room 3" },
        [177286] = { ["segment_no"] = 9, ["name"] = "Escape Parlor" },
    }, -- }}}
}


--
-- Utility
--

-- orderedPairs {{{

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end
-- }}}

local SLUGS = {}
local function slugify(s)
    local slug = string.gsub(string.gsub(s, "[^ A-Za-z0-9]", ""), "[ ]+", "_"):lower()
    if not SLUGS[slug] then
        SLUGS[slug] = 1
        return slug
    end

    local ret = slug
    local i = 2
    while SLUGS[ret] do
        ret = slug .. '_' .. tostring(i)
        i = i + 1
    end
    SLUGS[ret] = 1
    return ret
end

local function ucfirst(s)
    return s:sub(1,1):upper() .. s:sub(2):lower()
end

local function draw_lines(x, y, L)
    for i, line in ipairs(L) do
        gui.text(x, y + ((i - 1) * 8), line)
    end
end

local function tohex(n, size)
    size = size or 0
    return string.format("$%0" .. tostring(size) .. "X", n)
end

local function call_for_each_bank(address, fn, ...)
    assert(address < 0x7F0000 or address > 0x7FFFFF)
    for i = 0x80, 0xDF do
        fn(bit.lshift(i, 16) + bit.band(address, 0xFFFF), unpack(arg))
    end
    fn(0x7E0000 + address, unpack(arg))
end

-- local debug_file = io.open("debug.txt", "w")

local function debug(...)
    -- print(unpack(arg))
    -- debug_file:write(table.concat(arg, " ") .. "\n")
    -- debug_file:flush()
end


--
-- State
--

local function annotate_address(addr, val)
    if addr < 0x7F0000 or addr > 0x7FFFFF then
        addr = bit.band(addr, 0xFFFF)
    end

    for _, mem in pairs(MEMTRACK) do
        if mem[1] <= addr and (addr < mem[1] + mem[2]) then
            return mem[3]
        end
    end

    return "(" .. tohex(addr, 4) .. ") ??"
end

local function get_current_state()
    local state = {}
    for _, mem in pairs(MEMTRACK) do
        local addr = mem[1]
        local size = mem[2]

        if mem[1] < 0x10000 then
            addr = 0x7E0000 + addr
        end

        if size > 1 then
            assert(bit.band(size, 1) == 0)
            for i_addr = addr, addr + size - 1, 2 do
                state[i_addr] = {2, memory.readwordunsigned(i_addr)}
            end
        else
            if size == 1 then
                state[addr] = {1, memory.readbyte(addr)}
            else
                state[addr] = {2, memory.readwordunsigned(addr)}
            end
        end
    end
    return state
end

local function save_preset(step)
    local current_state = get_current_state()

    print("saving step " .. step['full_slug'])
    preset_output = preset_output .. "\npreset_" .. CAT .. '_' .. step['full_slug'] .. ":\n"

    if last_step then
        preset_output = preset_output .. "    dw #preset_" .. CAT .. '_' .. last_step['full_slug'] .. " ; " .. last_step['full_name'] .. "\n"
    else
        preset_output = preset_output .. "    dw #$0000\n"
    end

    last_step = step

    for addr, size_and_val in orderedPairs(current_state) do
        local size = size_and_val[1]
        local val = size_and_val[2]

        if last_state[addr] ~= val then
            last_state[addr] = val

            preset_output = preset_output ..  "    dl " ..  tohex(addr, 6) .. " : "
            preset_output = preset_output ..  "db " ..  tohex(size, 2) .. " : "
            preset_output = preset_output .. (size == 1 and "db " or "dw ") ..  tohex(val, size == 1 and 2 or 4)
            preset_output = preset_output .. " ; " .. annotate_address(addr, val) .. "\n"
        end
    end

    preset_output = preset_output .. "    dw #$FFFF\n"
    preset_output = preset_output .. ".after\n"
end

local function save_preset_file()
    local file = io.open('presets_data.asm', 'w')
    file:write(preset_output)
    file:close()

    local file = io.open('presets_menu.asm', 'w')

    file:write('PresetsMenu' .. ucfirst(CAT) .. ':\n')
    for _, segment in pairs(SEGMENTS[CAT]) do
        file:write('    dw #presets_goto_' .. CAT .. '_' .. segment['slug'] .. '\n')
    end
    file:write('    dw #$0000\n')
    file:write('    %cm_header("PRESETS FOR ' .. CAT:upper() .. '")\n')
    file:write('\n')

    for _, segment in pairs(SEGMENTS[CAT]) do
        file:write('presets_goto_' .. CAT .. '_' .. segment['slug'] .. ':\n')
        file:write('    %cm_submenu("' .. segment['name'] .. '", #presets_submenu_' .. CAT .. '_' .. segment['slug'] .. ')\n')
        file:write('\n')
    end

    for _, segment in pairs(SEGMENTS[CAT]) do
        file:write('presets_submenu_' .. CAT .. '_' .. segment['slug'] .. ':\n')
        for _, step in pairs(segment['steps']) do
            file:write('    dw #presets_' .. CAT .. '_' .. step['full_slug'] .. '\n')
        end
        file:write('    dw #$0000\n')
        file:write('    %cm_header("' .. segment['name']:upper() .. '")\n')
        file:write('\n')
    end

    for _, segment in pairs(SEGMENTS[CAT]) do
        file:write('; ' .. segment['name'] .. '\n')
        for _, step in pairs(segment['steps']) do
            file:write('presets_' .. CAT .. '_' .. step['full_slug'] .. ':\n')
            file:write('    %cm_preset("' .. step['name'] .. '", #preset_' .. CAT .. '_' .. step['full_slug'] .. ')\n\n')
        end
        file:write("\n")
    end
    file:close()
end

--
-- Main
--

local function tick()
    local frame = emu.framecount()

    local step = STEPS[CAT][frame]
    if step then
        save_preset(step)
        save_preset_file()
    end
end

local function main()
    for _, segment in pairs(SEGMENTS[CAT]) do
        segment['slug'] = slugify(segment['name'])
    end

    for _, step in orderedPairs(STEPS[CAT]) do
        segment = SEGMENTS[CAT][step['segment_no']]
        step['segment'] = segment
        step['slug'] = slugify(step['name'])
        step['full_slug'] = segment['slug'] .. "_" .. step['slug']
        step['full_name'] = segment['name'] .. ": " .. step['name']
        table.insert(segment['steps'], step)
    end

    while true do
        tick()
        snes9x.frameadvance()
    end
end

main()