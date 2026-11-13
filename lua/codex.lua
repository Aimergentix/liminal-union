-- #textdomain wesnoth-liminal-union
local _ = wesnoth.textdomain 'wesnoth-liminal-union'

-- Liminal Union Field Codex.
-- Opened from the unsynced menu item LIUN_menu_doctrine_codex: it only shows dialogs and
-- keeps its page in a Lua local, so it changes no game state, keeps the undo history,
-- is not written to the replay and works on any turn, also for observers.
-- Basic pages cover what every recruit does; Expert pages cover right-click actions,
-- which appear in the context menu only while a unit can use them.
-- Multiplayer shows only the multiplayer rules. With the campaign doctrine
-- (LIUN_CAMPAIGN_DOCTRINE, see LIUN_ERA_EVENTS in faction.cfg) the menu item passes
-- doctrine=true, and the Squad Anchor and right-click doctrine texts are added.

local codex = {}

local PORTRAIT = "factions/liminal-union-default.webp"

local ANCHORS = _ [[• <b>Squad Anchors:</b> some level 2 stages anchor their squad. A Hunterkiller gives adjacent Pyrite allies +10% more Focus; a bow's own accuracy and Focus together never exceed +20%. A Masterchief, Weaponguard or Shieldguard lets Interlock on adjacent Kryonite allies absorb 2 more damage. A Techtronic gives adjacent Arcanite allies +1 more Sunder, at most +3.]]

local TACTICS_MP = _ [[• <b>Maiden Wingsuit Glide (Passive):</b> Any Pyrite-armored unit beginning its turn on elevated terrain (Hills or Mountains) deploys thermal wingsuits, gaining <b>+1 MP and Skirmisher</b> for that turn!]]

local PAGES = {
    {
        id = "maxims",
        title = _ "Field Primer: Three Golden Maxims",
        text = _ [[To master the Liminal Union, keep three simple rules in mind:

1. <b>March in Pairs:</b> Keep same-alloy troops adjacent to build Resonance. Its tier is based on the current formation and updates after every move and every fight. Poison disables Resonance; slow can reduce its tier.

2. <b>Keep an Officer Close:</b> Officers carry a twilight lantern. By Day and by Night, the hours when lawful or chaotic enemies are strongest, liminal units on and beside an officer deal +10% damage.

3. <b>Strike at Twilight:</b> Liminal units deal 25% more damage at Dawn and Dusk.

<b>Visual Feedback:</b>
• <i>Pulsing Halos:</i> Amber (Pyrite), Cyan (Kryonite), and Purple (Arcanite) halos and tier pips show Resonance status.
• <i>Battle Badges:</i> A floating notification announces every change of Resonance tier without checking menus.]]
    },
    {
        id = "pods",
        title = _ "Resonance Pods & Armor Alloys",
        text = _ [[Resonance activates immediately when standing adjacent to allies with matching armor alloys. A pod of 2, 3 or 4+ units reaches Tier 1, 2 or 3; each tier grants +5% blade, pierce and impact resistance.

• <b>Pyrite (Maidens):</b> <b>Focus</b>: +5% chance to hit per tier with ranged attacks on offense; a bow's own accuracy and Focus together never exceed +20%. Tier 3 adds first strike with ranged weapons on defense.
• <b>Kryonite (Marines):</b> <b>Interlock</b> passes 30% (Tier 1), 40% (Tier 2) or 50% (Tier 3) of a normal hit to adjacent Kryonite allies; none falls below 1 HP and leaders take no share. Magical and marksman strikes are not shared. Tier 3 adds first strike in melee on defense.
• <b>Arcanite (G9 Warforms, Mechatronics, Techtronics):</b> <b>Sunder</b>: +1 melee damage per tier on offense, at most +3. Tier 3 adds first strike in melee on defense.

<i>Poison disables resonance; slow can lower its tier.</i>]],
        doctrine_text = ANCHORS,
    },
    {
        id = "zoc",
        title = _ "Formation Zone of Control",
        text = _ [[Standard level 0 troops in Wesnoth exert no Zone of Control (ZOC).

Liminal Union level 0 units (Marine/Maiden Privates, G9 AI, Ensigns) <b>exert full Zone of Control</b> while they stand in a Resonance pod (Tier 1 or higher) or while an allied officer (Ensign, Cornet, Captain or Colonel) stands adjacent and is not poisoned. Poison on the unit itself also removes it.

Keep conscripts in pairs or beside an officer to hold chokepoints, protect wounded comrades and deny cavalry breakthroughs; a pod that breaks or an officer who moves away leaves the line open.]]
    },
    {
        id = "conductance",
        title = _ "Conductance & Alignment",
        text = _ [[Liminal Union troops are liminal: they deal <b>+25% damage at Dawn and Dusk</b> and fight at normal strength by Day and by Night. They suffer no day or night penalty, but lawful enemies gain +25% by Day and chaotic enemies +25% at Night, so those hours favour the opponent.

All Command units (Ensigns, Cornets, Captains, Colonels) carry a <b>twilight lantern</b> (pulsing ground halo). On the officer's hex and the hexes around it, the time of day is pulled 10 points toward twilight:
• <b>Day:</b> liminal units deal +10% instead of 0%; lawful units +15% instead of +25%; chaotic units -15% instead of -25%.
• <b>Night:</b> liminal units deal +10% instead of 0%; chaotic units +15% instead of +25%; lawful units -15% instead of -25%.
• <b>Dawn/Dusk:</b> no change; the twilight +25% applies.

<i>The lantern works on every unit in its light, friend or foe, so an enemy that steps beside your officer loses part of its strong hour. Lanterns do not stack; they change no one's alignment.</i>]]
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
        text = TACTICS_MP,
        doctrine_replaces = true,
        doctrine_text = _ [[<i>Expert doctrine. Right-click actions appear in the context menu only while a unit can use them right now.</i>

• <b>Marine Salt-Grounding Pylum (Right-Click):</b> Right-click an ungrounded Kryonite Marine (Sergeant or higher; not Privates or Officers) to deploy their conductive pylon stake. Grants adjacent allies +20% elemental warding, grounds adjacent enemies' fire, cold and arcane attacks (max 50% CTH), and reduces enemy elemental damage by 20%. Costs: 0 MP and +20% melee Blade/Impact vulnerability. Lasts through the following enemy turn; redeploy it on your next turn.
• <b>G9 Overclock (Right-Click):</b> Right-click a G9 Warform with more than 4 HP and an attack left to trigger emergency protocol bypass: +1 melee strike for this turn, and every melee hit <b>stuns</b> a level 1+ enemy, which loses its zone of control until its own side's next turn begins. At turn end, the golem suffers up to 3 HP core thermal stress and cannot die from it.
• <b>Maiden Wingsuit Glide (Passive):</b> Any Pyrite-armored unit beginning its turn on elevated terrain (Hills or Mountains) deploys thermal wingsuits, gaining <b>+1 MP and Skirmisher</b> for that turn!
• <b>Portal Warden (Passive):</b> A Shieldguard that stood still for a full turn with a Phoinix beside it opens its portable Arcanite portal, charged by mana crystals. Marines other than leaders may travel one way from your villages to free hexes beside it, arriving with no moves and no attack that turn. The portal closes when the Shieldguard moves.
• <b>Field Works (Right-Click):</b> Mechatronics and Techtronics standing on a village, castle or keep spend one aimergent-core and gold to build a G8 Simulacrum (10 gold) or a G9 AI (16 gold) on a free hex beside them. Shieldguards open an ember capsule (10 gold) to call a Phoinix, or kindle the ash of a fallen Phoinix for free. Each new unit of these lines carries 3 charges; the sidebar shows how many remain.]]
    },
}

local INDEX_LABELS = {
    maxims = _ "⭐ Basic · Quick Start: The Three Golden Maxims",
    pods = _ "Basic · Formation Pods & Armor Alloys (Pyrite, Kryonite, Arcanite)",
    zoc = _ "Basic · Formation Zone of Control (Level 0 Troops)",
    conductance = _ "Basic · Twilight Timing & Conductance Auras",
    stages = _ "Basic · Unit Stages (level·stage)",
    tactics = _ "Basic · Maiden Wingsuit Glide",
}
local DOCTRINE_LABELS = {
    tactics = _ "Expert · Special Tactical Actions (Pylum, Overclock, Wingsuit, Portal, Field Works)",
}

-- The text a page shows under the active rules.
local function page_text(p, doctrine)
    if not (doctrine and p.doctrine_text) then return p.text end
    if p.doctrine_replaces then return p.doctrine_text end
    return p.text .. "\n\n" .. p.doctrine_text
end

local function show(title, text, options, default)
    options.default = default
    local choice = gui.show_narration({ title = title, message = text, portrait = PORTRAIT }, options)
    return choice
end

-- Returns the page position to show next, or nil to close.
local function show_index(doctrine)
    local options = {}
    for idx, p in ipairs(PAGES) do
        options[idx] = doctrine and DOCTRINE_LABELS[p.id] or INDEX_LABELS[p.id]
    end
    options[#PAGES + 1] = _ "Close Codex"
    local choice = show(_ "Liminal Union Field Codex", _ "Select a strategic doctrine to review:", options, 1)
    if choice and choice >= 1 and choice <= #PAGES then return choice end
    return nil
end

-- Opens on the Quick Start page, the first steps for new players.
-- doctrine: true under the campaign doctrine rules.
function codex.open(doctrine)
    local pos = 1
    while pos do
        if pos == 0 then
            pos = show_index(doctrine)
        else
            local p = PAGES[pos]
            local choice = show(p.title, page_text(p, doctrine), {
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
