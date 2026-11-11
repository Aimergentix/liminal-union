# Changelog

Player-facing changes to Liminal Union. Values are test values, not settled balance.

## Unreleased

### Ladder review
- G9 Overclock gives +1 melee strike and no longer +2 damage (NCM fist 13-2 → 13-3);
  the 3 HP thermal stress is unchanged.

### Field works
- New Mechatronic (level 1): Maiden Privates advance to Jaeger or Mechatronic; Mechatronics
  advance to Techtronic, Jaegers to Hunterkiller. Sprites borrowed from the Techtronic.
- Mechatronics and Techtronics carry 3 aimergent-cores. Standing on a village, castle or keep,
  they right-click a free hex beside them to build a G8 Simulacrum (10 gold, Mechatronic) or
  a G9 AI (20 gold, Techtronic), once per turn, spending their attack. Built warforms arrive
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
  The magical arcane ranged attack is unchanged.
- Resonance caps: a bow's own accuracy plus Pyrite Focus never exceeds +20%, and a
  weapon's own parry plus Kryonite Bulwark never exceeds 15%.
- The Techtronic (2·2) is now an Arcanite Squad Anchor: adjacent Arcanite allies in
  resonance gain +1 Sunder, at most +3 in total. She no longer boosts Pyrite accuracy;
  the Hunterkiller (2·2) remains the Pyrite Squad Anchor.

### Recruits and advancement
- Braves recruit the G9 NCM and the Phoinix Elder (level 1); G9 AI and Phoinix (level 0)
  come only from field works. The G9 AI no longer advances to NCM. The G8 Simulacrum is
  level 0. A Phoinix Elder's final AMLA renews it as a fresh Elder instead of a level 0 Phoinix.

### Rules
- Formation Zone of Control: level 0 Union units exert ZOC only while an allied officer
  (Ensign, Cornet, Captain, Colonel) that is not poisoned stands next to them.
- Salt-Grounding Pylum: Sergeants and higher only; Privates no longer carry it.
- Default era: veterans no longer become extra recruiting leaders through their AMLA.
  Age of Heroes keeps this.

### Fixes
- Techtronics wear Arcanite and resonate with G9 Warforms instead of Maidens.
- The Conductor aura (+10% damage for adjacent liminal allies by day and by night) works
  again on every officer; a second abilities block had silently dropped it.
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
