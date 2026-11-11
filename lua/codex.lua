-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Liminal Union Field Codex.
-- Opened from the unsynced menu item LIUN_menu_doctrine_codex: it only shows dialogs and
-- keeps its page in a Lua local, so it changes no game state, keeps the undo history,
-- is not written to the replay and works on any turn, also for observers.
-- Basic pages cover what every recruit does; Expert pages cover right-click actions,
-- which appear in the context menu only while a unit can use them.

local codex = {}

local PORTRAIT = "factions/liminal-union-default.webp"

local PAGES = {
    {
        id = "maxims",
        title = _ "Field Primer: Three Golden Maxims",
        text = _ [[To master the Liminal Union, keep three simple rules in mind:

1. <b>March in Pairs:</b> Keep same-alloy troops adjacent to build Resonance. Its tier is based on the current formation and updates after every move and every fight. Poison disables Resonance; slow can reduce its tier.

2. <b>Keep an Officer Close:</b> Conductors add 10 percentage points of damage for themselves and adjacent allied liminal units during Day or Night, the hours when lawful or chaotic enemies are strongest.

3. <b>Strike at Twilight:</b> Liminal units deal 25% more damage at Dawn and Dusk.

<b>Visual Feedback:</b>
• <i>Pulsing Halos:</i> Amber (Pyrite), Cyan (Kryonite), and Purple (Arcanite) halos and tier pips show Resonance status.
• <i>Battle Badges:</i> Floating notifications announce ZOC locks, Conductance, and Tier elevations without checking menus.]]
    },
    {
        id = "pods",
        title = _ "Resonance Pods & Armor Alloys",
        text = _ [[Resonance activates immediately when standing adjacent to allies with matching armor alloys. A pod of 2, 3 or 4+ units reaches Tier 1, 2 or 3; each tier grants +5% blade, pierce and impact resistance.

• <b>Pyrite (Maidens):</b> <b>Focus</b>: +5% chance to hit per tier with ranged attacks on offense, +10% more beside a Hunterkiller Squad Anchor; a bow's own accuracy and Focus together never exceed +20%. Tier 3 adds +10% Fire and Arcane resistance.
• <b>Kryonite (Marines):</b> <b>Bulwark</b>: enemies lose 5% (Tier 1) or 10% (Tier 2+) chance to hit this unit in melee; a weapon's own parry and Bulwark together never exceed 15%. Tier 3 adds first strike on defense and +10% Cold and Arcane resistance. <b>Interlock</b> passes up to 30% of a normal hit to adjacent Kryonite allies; none falls below 1 HP. Magical and marksman strikes are not shared.
• <b>Arcanite (G9 Warforms, Techtronics):</b> <b>Sunder</b>: +1 melee damage per tier on offense, +1 more beside a Techtronic Squad Anchor, at most +3. Tier 3 adds +20% Fire and Cold resistance.

<i>Poison disables resonance; slow can lower its tier.</i>]]
    },
    {
        id = "zoc",
        title = _ "Formation Zone of Control",
        text = _ [[Standard level 0 troops in Wesnoth exert no Zone of Control (ZOC).

Liminal Union level 0 units (Marine/Maiden Privates, G9 AI, Ensigns) <b>exert full Zone of Control</b> while an allied officer (Ensign, Cornet, Captain or Colonel) stands adjacent and is not poisoned. Poison on the unit itself also removes it.

Keep officers beside your conscripts to hold chokepoints, protect wounded comrades and deny cavalry breakthroughs; an officer who falls or moves away leaves the line open.]]
    },
    {
        id = "conductance",
        title = _ "Conductance & Alignment",
        text = _ [[Liminal Union troops are liminal: they deal <b>+25% damage at Dawn and Dusk</b> and fight at normal strength by Day and by Night. They suffer no day or night penalty, but lawful enemies gain +25% by Day and chaotic enemies +25% at Night, so those hours favour the opponent.

All Command units (Ensigns, Cornets, Captains, Colonels) radiate a <b>Conductance Aura</b> (pulsing ground halo). The officer and adjacent allied liminal units gain +10 percentage points of damage:
• <b>Day:</b> +10% instead of 0%.
• <b>Night:</b> +10% instead of 0%.
• <b>Dawn/Dusk:</b> no extra bonus; the twilight +25% applies.

<i>Officers narrow the gap to lawful and chaotic enemies during their strong hours; they change no one's alignment.</i>]]
    },
    {
        id = "stages",
        title = _ "Unit Stages (level·stage)",
        text = _ [[Liminal Union unit names end in <b>(level·stage)</b>. <b>(0·1)</b> is a level 0 unit in its second doctrine stage; <b>(1·0)</b> is a fresh level 1 unit.

• Filling the experience bar moves a unit to its next doctrine stage of the same level. The new stage unlocks a weapon, an ability or more hit points, but it heals only 2 HP and keeps poison and slow.
• At the last stage of a level, the next advancement is a full level-up, which heals as usual and may offer a choice of lines.
• The unit description lists what each stage unlocks.]]
    },
    {
        id = "tactics",
        title = _ "Tactical Maneuvers",
        text = _ [[<i>Expert doctrine. Right-click actions appear in the context menu only while a unit can use them right now.</i>

• <b>Marine Salt-Grounding Pylum (Right-Click):</b> Right-click an ungrounded Kryonite Marine (Sergeant or higher; not Privates or Officers) to deploy their conductive pylon stake. Grants adjacent allies +20% elemental warding, grounds adjacent enemies' fire, cold and arcane attacks (max 50% CTH), and reduces enemy elemental damage by 20%. Costs: 0 MP and +20% melee Blade/Impact vulnerability. Lasts through the following enemy turn; redeploy it on your next turn.
• <b>G9 Overclock (Right-Click):</b> Right-click a G9 Warform with more than 4 HP and an attack left to trigger emergency protocol bypass: +1 melee strike for this turn, and every melee hit <b>stuns</b> a level 1+ enemy, which loses its zone of control until its own side's next turn begins. At turn end, the golem suffers up to 3 HP core thermal stress and cannot die from it.
• <b>Maiden Wingsuit Glide (Passive):</b> Any Pyrite-armored unit beginning its turn on elevated terrain (Hills or Mountains) deploys thermal wingsuits, gaining <b>+1 MP and Skirmisher</b> for that turn!
• <b>Portal Warden (Passive):</b> A Shieldguard that stood still for a full turn with a Phoinix beside it opens its portable Arcanite portal, charged by mana crystals. Marines other than leaders may travel one way from your villages to free hexes beside it, arriving with no moves and no attack that turn. The portal closes when the Shieldguard moves.
• <b>Field Works (Right-Click):</b> Mechatronics and Techtronics standing on a village, castle or keep spend one aimergent-core and gold to build a G8 Simulacrum (10 gold) or a G9 AI (20 gold) on a free hex beside them. Shieldguards open an ember capsule (10 gold) to call a Phoinix, or kindle the ash of a fallen Phoinix for free. Each new unit of these lines carries 3 charges; the sidebar shows how many remain.]]
    },
}

local INDEX_LABELS = {
    maxims = _ "⭐ Basic · Quick Start: The Three Golden Maxims",
    pods = _ "Basic · Formation Pods & Armor Alloys (Pyrite, Kryonite, Arcanite)",
    zoc = _ "Basic · Formation Zone of Control (Level 0 Troops)",
    conductance = _ "Basic · Twilight Timing & Conductance Auras",
    stages = _ "Basic · Unit Stages (level·stage)",
    tactics = _ "Expert · Special Tactical Actions (Pylum, Overclock, Wingsuit, Portal, Field Works)",
}

local function show(title, text, options, default)
    options.default = default
    local choice = gui.show_narration({ title = title, message = text, portrait = PORTRAIT }, options)
    return choice
end

-- Returns the page position to show next, or nil to close.
local function show_index()
    local options = {}
    for idx, p in ipairs(PAGES) do options[idx] = INDEX_LABELS[p.id] end
    options[#PAGES + 1] = _ "Close Codex"
    local choice = show(_ "Liminal Union Field Codex", _ "Select a strategic doctrine to review:", options, 1)
    if choice and choice >= 1 and choice <= #PAGES then return choice end
    return nil
end

-- Opens on the Quick Start page, the first steps for new players.
function codex.open()
    local pos = 1
    while pos do
        if pos == 0 then
            pos = show_index()
        else
            local p = PAGES[pos]
            local choice = show(p.title, p.text, {
                _ "← Previous Doctrine",
                _ "→ Next Doctrine",
                _ "↑ Return to the Codex Index",
                _ "Close Codex",
            }, 2)
            if choice == 1 then
                pos = (pos - 2) % #PAGES + 1
            elseif choice == 2 then
                pos = pos % #PAGES + 1
            elseif choice == 3 then
                pos = 0
            else
                pos = nil
            end
        end
    end
end

return codex
