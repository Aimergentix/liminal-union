# Changelog

Player-facing changes to Liminal Union. Values are test values, not settled balance.

## 0.4.0alpha — 2026-11-12

A major step: a lighter rule set for multiplayer, reworked Resonance and Conductance, and
amphibious Marines.

### Resonance
- Every tier still grants +5% blade, pierce and impact resistance per tier.
- Tier 3 now grants first strike on defense with the alloy's fighting range instead of
  elemental resistance: Pyrite with ranged weapons, Kryonite and Arcanite in melee. The
  Tier 3 Fire, Cold and Arcane wards are gone.
- Kryonite: Bulwark is gone. Interlock is the Kryonite signature and grows with the pod:
  it passes 30% (Tier 1), 40% (Tier 2) or 50% (Tier 3) of a normal hit to adjacent
  Kryonite allies, rounded to the nearest point and at least 1.
- Formation Zone of Control: level 0 units also exert ZOC while they stand in a Resonance
  pod (Tier 1 or higher), not only beside an officer.

### Conductance: the twilight lantern
- Officers no longer give +10% damage by leadership. They carry a twilight lantern: by day
  and by night, the time of day on the officer's hex and the hexes around it moves 10
  points toward twilight. Liminal units there deal +10%. Lawful and chaotic units there,
  friend or foe, gain or lose 15% instead of 25%. Lanterns do not stack, and dawn and dusk
  are unchanged.

### Movement and resistances
- Marines are amphibious holders: shallow water, reef and hills cost 1 MP. Defense is
  50% in shallow water, reef, swamp, forest, hills and mountains, and 40% on flat, sand
  and in deep water. Resistances: pierce -10%, fire -20%, arcane +10% (blade and cold now
  neutral).
- Maidens: fungus costs 2 MP; defense 30% in deep water and 50% in caves. Resistances:
  impact -10%, cold -20%, arcane +10% (blade, pierce and fire now neutral).
- G8 Simulacrum moves 4 (was immobile).

### Multiplayer and campaign rules
- Multiplayer keeps Resonance with Interlock, Conductance, Formation ZOC, Wingsuit Glide,
  staged promotion with its banter, Strike at Twilight and the Codex.
- Squad Anchors, G9 Overclock, the Salt-Grounding Pylum, the Portal Warden, Field Works
  and Phoinix ash are campaign doctrine: a campaign enables them by defining
  `LIUN_CAMPAIGN_DOCTRINE` before it includes `faction.cfg`, then loading the
  `LIUN_era_events` resource. Unit and Codex texts follow the active rules.
- Codex: Mechatronics are listed as Arcanite, Formation ZOC also holds inside a Resonance
  pod, and the battle badges describe the single Resonance tier notification.

### Hand tuning (values after the weapon rework)
- Costs: officers +1 to +4 gold (Cornets 21, Captains 33/34, Colonels 56/58), Maiden
  Private 11, Marine Private 12, Jaeger and Sergeant 17, Masterchief 31, Hunterkiller 31,
  Shieldguard 33, Techtronic 28. Phoinix Elder 27 → 17.
- Officers of both corps move 6 instead of 5; Phoinixes move 7 instead of 8.
- Phoinix: neither attack is magical any more, at every stage. Accuracy and parry rise by
  stage instead (Elder 0 / +5 / +10).
- Weapons, HP and XP retuned per stage. Marines carry a stronger sling again (Sergeant 4-4,
  Masterchief 5-5), melee 4-4 (Sergeant) and 5-5 (Masterchief). Maiden bows 3-4 (Private),
  5-4 (Jaeger), 5-5 to 7-4 (Hunterkiller). G9 NCM fist 12-2; first NCM stage needs 33 XP.
- Mechatronics wear Arcanite, like the Techtronics they become.

### AI
- The Braves and Heroes AI now really values its leader and villages more
  (leader_value 4.0, village_value 1.4). The settings were written in a form the engine
  ignores, so the AI had played with the defaults.

### Cleanup
- Removed settings the engine never read (unit-type portraits and variables, a hit-sound
  key), an unused Lua module and five unused macros. No gameplay change.
- Phoinix 0·1 description shows its italics correctly; the Braves description names level 0
  and level 1 recruits.

### Ladder review
- G9 Overclock gives +1 melee strike and no longer +2 damage (NCM fist then 13-2 → 13-3;
  now 12-2 → 12-3); the 3 HP thermal stress is unchanged.
- Overclock Stun now works: each melee hit of an overclocked G9 strips a level 1+ target's
  zone of control until its own side's next turn begins. Before, Stun was only a label.
- The Merman Brawler's tail now stuns the same way, attacking and defending; its stun had
  never fired because the tail lacked the special. It also works with the worker
  modifications outside the Liminal Union eras.
- Resonance pods recalculate after every fight, so killing, poisoning or slowing a pod member
  lowers its neighbours' bonuses at once instead of at the next move or turn.
- Interlock no longer shares hits from magical or marksman attacks.
- Multiplayer: the AI reflexes (Overclock, Pylum, field works, portal Warden) decide by
  whether a side started the scenario as AI, so replays no longer go out of sync when a
  side changes controller mid-game. A side that switches to AI later gets no reflexes.
- Field Codex: opens on any unit at any time, also on the opponent's turn, and no longer
  clears the undo history. It starts on the Quick Start page; the index marks pages as Basic
  or Expert and adds a page on unit stages. Day, night and wingsuit texts match the game.
- Overclock and Pylum appear in the right-click menu only while the unit can use them.
- Every unit description explains the (level·stage) notation of unit names.
- Texts follow the engine: liminal troops deal +25% at dawn and dusk and fight at normal
  strength by day and night; officers add +10% by day and night. Faction descriptions,
  officer descriptions and the Corebound trait no longer describe a day or night penalty or
  a lawful G9 frame. Phoinix Elder stage texts list the actual upgrades.
- Removed the unused custom alignment profile (`macros/alignment.cfg`, −15%/−25%); Union
  units always used the engine's liminal alignment.
- Translations: template regenerated; changed strings are fuzzy in de, es, fr and it and
  show in English until a translator confirms them.

### Field works
- New Mechatronic (level 1): Maiden Privates advance to Jaeger or Mechatronic; Mechatronics
  advance to Techtronic, Jaegers to Hunterkiller. Sprites borrowed from the Techtronic.
- Mechatronics and Techtronics carry 3 aimergent-cores. Standing on a village, castle or keep,
  they right-click a free hex beside them to build a G8 Simulacrum (10 gold, Mechatronic) or
  a G9 AI (16 gold, its recall cost; Techtronic), once per turn, spending their attack. The
  G8 Simulacrum now moves 4 instead of standing immobile. Built warforms arrive
  without moves or attack, cost no upkeep and never advance a level.
- Shieldguards carry 3 ember capsules. Opening one calls a Phoinix (10 gold) onto a free hex
  beside the Shieldguard if it has not moved this turn; it spends the Shieldguard's turn, and
  neither hex may be a village, castle or keep. A Shieldguard beside the ash of a fallen
  Phoinix of its side kindles it for free, spending its attack.
- Charges refill for every new unit of these lines and at the start of every scenario; the
  sidebar shows the count. The AI uses all three actions at the end of its turn.

### Weapons
- Every line now has a clear role and two damage types. All values are test values.
- Maiden troops are archers: a pierce bodkin bow and, from 0·1, a fire Pyrite bow replace
  the impact and arcane bows. Bow accuracy is -5% for Privates, +5% for Jaegers and +10%
  for Hunterkillers. Privates shoot 4 times; Hunterkillers carry two bows instead of three.
- Marine troops are line infantry: a pierce khopesh thrust and, from 0·1, a cold Kryonite
  edge with more damage and strikes, and one weak impact sling instead of two slings.
  Melee parry is -5% for Privates, +5% for Sergeants and +10% for Masterchiefs. The
  Shieldguard's impact smash becomes the cold Kryonite rim.
- G9 Warforms: the double tap deals +1 damage and becomes the arcane Arcanite fist on the
  NCM. The NCM's brawl and berserk mode deal +1 damage. Accuracy and parry start 5% lower
  and wear down to -5% at the last stage.
- Officers parry better with rank: Cornets and Captains +10%, Colonels +15%.
- Phoinix: the melee attack is now the fire ember talons, not magical, with +1 damage.
  The ranged attack is unchanged.
- Resonance cap: a bow's own accuracy plus Pyrite Focus never exceeds +20%.
- The Techtronic (2·2) is now an Arcanite Squad Anchor: adjacent Arcanite allies in
  resonance gain +1 Sunder, at most +3 in total. She no longer boosts Pyrite accuracy;
  the Hunterkiller (2·2) remains the Pyrite Squad Anchor.

### Recruits and advancement
- Braves recruit the G9 NCM and the Phoinix Elder (level 1); G9 AI and Phoinix (level 0)
  come only from field works, so only campaigns have them. The G9 AI no longer advances to NCM. The G8 Simulacrum is
  level 0. A Phoinix Elder's final AMLA renews it as a fresh Elder instead of a level 0 Phoinix.

### Rules
- Formation Zone of Control: level 0 Union units exert ZOC while an allied officer
  (Ensign, Cornet, Captain, Colonel) that is not poisoned stands next to them, or while
  they stand in a Resonance pod (see Resonance above).
- Salt-Grounding Pylum: Sergeants and higher only; Privates no longer carry it.
- Default era: veterans no longer become extra recruiting leaders through their AMLA.
  Age of Heroes keeps this.

### Fixes
- Techtronics wear Arcanite and resonate with G9 Warforms instead of Maidens.
- Every officer carries its Conductor ability again; a second abilities block had
  silently dropped it.
- Phoinix memorial archives survive saving and loading.
- Doctrine stages (for example 0·0 → 0·1) heal only 2 HP and keep poison and slow, as
  intended. They previously healed fully. Full level-ups and AMLAs still heal fully;
  other factions are unaffected.
- Hunterkiller and Techtronic (2·2) keep their Pyrite resonance.
- Colonels keep First Aid +6 instead of dropping to +4 after promotion.
- Cornets list their elemental attack first at every stage; Sergeants list the impact
  sling first.
- Mobile repair names its real amounts (4/8/12 HP). The Field Codex describes resonance
  as it works. G9 NCM: "Fist [berserk mode]". German: Khopesh is "Chepesch".

## 0.3.0alpha — 2026-11-08

### Units and weapons
- Maiden Private: kick and impact bow; arcane bow from stage 0·1. New Maiden portraits.
- Marine line: khopesh for Privates, impact sling for Sergeants, unified attack names.
  Marine troops fight as archers.
- Marine Ensign is weaker; Cornets gain their elemental attacks from stage 1·0.
- Officers gain parry and a ranged resistance from their shields. First Aid: Cornet +4, Captain +6.
- Sergeants no longer advance to Weaponguard; the unit remains available for campaigns.
- New: the Shieldguard is a Portal Warden. A Shieldguard that stays still next to a Phoinix
  opens a portal, letting Marines (not leaders) travel one way from their own villages.
  They arrive without moves or attacks.
- Phoinix: 8 movement points and cures poison from stage 0·1. The Conductance relay was removed.

### Abilities and fixes
- Salt-Grounding now lasts through the enemy turn and ends at its owner's next turn.
- Salt-Grounding and Emergency Overclock no longer fail partway through activation.
  Salt-Grounding uses a translucent salt ring instead of an opaque emblem.
- Field Codex: back and forward navigation between pages.
- Tutorial texts show correct line breaks; translations updated (de, fr, es, it).

## 0.2.4alpha

Baseline version. Earlier development notes are kept outside the add-on.
