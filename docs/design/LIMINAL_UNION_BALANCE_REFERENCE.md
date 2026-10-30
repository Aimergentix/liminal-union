# Liminal Union: aktuelle Balance- und Matchup-Referenz

> Diese Datei ersetzt die früheren Phasenpapiere, die Balance-Übergabe und die
> separate Strategieübersicht. Sie beschreibt den geprüften Repository- und
> Run-Stand vom 29. Oktober 2026. Codebefund, beabsichtigtes Design und
> Testergebnis werden getrennt behandelt. Bei späteren Codeänderungen müssen
> die Mechanikabschnitte erneut geprüft werden.

## 1. Aussagekraft und Arbeitsregeln

- **WML-/Lua-Code bestimmt das aktuelle Verhalten.** Unit-Tooltips und ältere
  Entwurfsdokumente können davon abweichen. Solche Abweichungen sind unten
  ausdrücklich aufgeführt.
- **System A** ist ein statischer Vergleich und kein Kampf- oder Matchsimulator.
  Seine Kennzahlen hängen von vereinfachten Angriffen, Terrain- und
  Fraktionsprofilen ab.
- **System B** verwendet Wesnoths Kampfsimulation. Es beschreibt einzelne
  Kämpfe unter festgelegten Bedingungen, nicht Rekrutierung, Kartenkontrolle
  oder ganze Partien.
- **System C** fasst beobachtete Telemetrie zusammen. Es ist kein vollständiges
  Wirtschafts-, Upkeep- oder Nettovermögensmodell.
- **System D** misst Ergebnisse der eingesetzten KI. Es ist ein Screening- und
  Regressionstest; KI-Ergebnisse sind keine menschlichen Multiplayer-Ergebnisse
  und belegen keine Ursache für einen Sieg.
- Für Tuning-Schlüsse deshalb Rohdaten, Manifest, Seite, Karte und Version
  gemeinsam betrachten. Eine einzelne Winrate oder Stat-Kennzahl reicht nicht
  für eine Kausalbehauptung. Änderungen an einer Balance-Stellschraube sollten
  mit passenden Vorher-/Nachher-Läufen verglichen werden.

## 2. Aktuelle LU-Fraktionen und ihre Grundidee

Die Multiplayer-Definitionen stehen in
[`factions/liminal-union-braves.cfg`](../../factions/liminal-union-braves.cfg)
und [`factions/liminal-union-heroes.cfg`](../../factions/liminal-union-heroes.cfg):

- **Braves** (`LIUN_braves`, Era `LIUN_era_courageous`): Maiden- und Marine-
  Cornets, Privates beider Corps, G9 AI und Phoinix.
- **Heroes** (`LIUN_heroes`, Era `LIUN_era_heroes`): Maiden- und Marine-
  Captains, Techtronic, Sergeant, Hunterkiller, G9 NCM und Phoinix Elder.
- Die Variante und ihr Recruit-Mix müssen bei jedem Ergebnis genannt werden;
  Braves-vs-Default-Ergebnisse sagen nichts Sicheres über Heroes-vs-AoH aus.

Der erkennbare Bauplan ist eine kleine Auswahl von Truppenlinien mit
Zwischenaufstiegen, drei Resonanz-Alloys, Conductors und einem separaten
Phoinix-Rollenpfad. Ob daraus im praktischen Spiel eine tragfähige
Qualität-statt-Masse-Fraktion wird, ist eine Balance-Hypothese und muss an
Spieldaten und menschlichen Partien geprüft werden.

## 3. Resonanz: Verhalten laut aktuellem Code

Quelle: [`lua/resonance.lua`](../../lua/resonance.lua) und die Alloy-Makros in
[`macros/abilities.cfg`](../../macros/abilities.cfg).

### Pods und Status

- Resonanz zählt die Einheit selbst und benachbarte lebende Verbündete derselben
  Alloy. **Tier 1** beginnt bei zwei Pod-Einheiten, **Tier 2** bei drei,
  **Tier 3** bei vier oder mehr.
- Eine vergiftete Einheit erhält Tier 0 und wird bei Nachbarzählungen
  ausgelassen.
- Eine verlangsamte Einheit kann Tier 1 behalten, wenn mindestens ein
  unverlangsamter gleich-alloy Verbündeter benachbart ist. Für unverlangsamte
  Einheiten werden verlangsamte Nachbarn nicht für die normale Pod-Stufe
  mitgezählt; existiert ein verlangsamter Pod-Partner, bleibt mindestens Tier 1.
- Resonanz-Heilung oder passive HP-Regeneration ist in der aktuellen
  Tierberechnung nicht implementiert.
- Die Grundverteidigung steigt pro Tier um 5 Prozentpunkte gegen Hieb, Stich
  und Wucht (WML-Resistenzwerte werden dafür entsprechend gesenkt).

### Alloy-Effekte

| Gruppe | Im Code zugewiesene Alloy | Effekt bei Resonanz | Tier-3-Zusatz |
|---|---|---|---|
| Maiden-Truppen einschließlich Techtronic | Pyrite | Fernkampf erhält auf Angriff +5, +10 oder +15 Prozentpunkte Trefferchance je Tier | +10% Feuer- und +10% Arkanresistenz |
| Marine-Truppen | Kryonite | Nahkampfverteidigung senkt die gegnerische Trefferchance um 5, höchstens 10 Prozentpunkte | Firststrike in Nahkampfverteidigung; zusätzlich +10% Kälte- und +10% Arkanresistenz |
| G9-Warforms | Arcanite | Nahkampfangriff erhält +1 Schaden je Tier | +20% Feuer- und +20% Kälteresistenz |
| Command-Einheiten | keine Resonanz-Alloy | Conductance; Command-Einheiten selbst werden nicht als Uranite-Resonanz-Pod geführt | kein Uranite-Resonanzbonus |
| Phoinix | keine | keine Resonanz | keine |

**Interlock** gilt für Kryonite-Einheiten mit mindestens Tier 1, wenn ein
geeigneter Kryonite-Verbündeter angrenzend ist. Bei normalen Treffern wird bis
zu 30% des erlittenen Schadens auf angrenzende, nicht vergiftete Kryonite-
Einheiten verteilt, die über 1 HP liegen; diese können durch die Verteilung
nicht unter 1 HP fallen. Rundung und HP-Grenzen können den tatsächlich
verteilten Anteil senken. Im Berserk-Sonderpfad gelten eigene Obergrenzen.
Quelle ist `handle_damage_redistribution` in `lua/resonance.lua`.

### Formation-Zone-of-Control

L0-Einheiten erhalten Formation-ZOC, wenn sie mit mindestens einem geeigneten
LU-Verbündeten (Alloy-Einheit oder Conductor) benachbart sind. Gift unterbricht
die eigene Formation-ZOC; verlangsamte Einheiten behalten sie, wenn mindestens
ein unverlangsamter geeigneter Verbündeter benachbart ist. Die ZOC wird nach
Bewegung und Nachbarschaftsänderungen neu berechnet.

## 4. Aktuelle Design- und Implementierungsgrenzen

Diese Punkte dürfen nicht als bereits funktionierende Balance-Regeln behandelt
werden. Die neue Referenz dokumentiert sie; sie ändert hier nicht nebenbei das
Spielverhalten.

1. **Kinetic Relay ist in den geprüften Laufzeitpfaden nicht implementiert.**
   `lu_start_tier` wird bei Zugbeginn gespeichert, aber keine Tierfunktion liest
   diesen Wert. `lu_moved` wird gesetzt und zurückgesetzt, aber weder
   `calculate_pod_tier`, `get_tier` noch `get_formation_zoc` verwenden es als
   Abbruchbedingung. Nach Bewegung werden die neue und alte Nachbarschaft neu
   ausgewertet. Ein bewegtes Mitglied kann daher Resonanz behalten, wenn es
   nach der Bewegung weiterhin die nötige Nachbarschaft hat; ein spezieller
   „beim Marsch genau ein Tier weniger“-Mechanismus ist nicht belegt.
   Die früheren Versprechen eines Kinetic Relay wurden aus den aktiven
   Fähigkeitstooltips und dem Lua-README entfernt. Es bleibt ein nicht
   implementierter Entwurfsmechanismus, keine aktuelle Spielregel.
2. **Die Einheiten verwenden derzeit `alignment=liminal`.**
   `macros/shared-race-characteristics.cfg` setzt für Maiden und Marine das
   eingebaute `liminal`; das eigene Profil `LIUN_liminal` aus
   `macros/alignment.cfg` wird von diesen Makros nicht zugewiesen. Das eigene
   Profil ist mit +25% Dawn/Dusk, −15% Day und −25% Night definiert. Deshalb
   darf diese Tagesabschwächung nicht ohne Weiteres den tatsächlichen
   Einheitenausrichtungen zugeschrieben werden.
3. **Conductance ist im aktuellen Unit-Code ein bedingter +10%-Leadership-
   Effekt.** `ABILITY_CONDUCTOR` addiert tagsüber bzw. nachts 10 Prozentpunkte
   auf Schaden; die tatsächliche Summe hängt von der Alignment-Basis der
   betroffenen Einheit ab. Bei den derzeit eingebauten liminalen Einheiten
   ergibt das nach den normalen ToD-Werten −15% sowohl am Tag als auch in der
   Nacht, nicht den in manchen älteren Texten behaupteten Tageswert −5%.
   Die Laufzeitfunktion `update_unit_alignment` in `lua/resonance.lua` setzt ein Status-Overlay und Variable, ändert aber
   die Einheitenausrichtung nicht auf `LIUN_liminal_conducted`.
   Ein separater Phoinix-Pfad kann Conductance an benachbarte liminale Einheiten
   weitergeben, wenn der Phoinix höchstens drei Hexe von einem Conductor
   entfernt ist; das ist vom nicht belegten Kinetic Relay zu unterscheiden.
4. **Pyrite-Tier-3-Resistenz ist im Lua-Code +10%/+10%.** Der aktive Tooltip
   wurde an diesen Codewert angepasst. Die früheren Uranite-Zuweisungs- und
   Tooltip-Makros wurden entfernt, weil keine Einheit sie verwendet und
   Command-Einheiten keine Resonanz-Alloy tragen.

Die Tooltip-Abweichungen wurden an den aktuellen Code angepasst. Offen bleiben
Designentscheidungen, falls künftig eine andere Alignment-Zuweisung oder ein
echter Kinetic-Relay-Mechanismus gewünscht ist; bis zur Implementierung sind
beide keine Spielregeln und keine Grundlage für Balanceannahmen.

## 5. Dunefolk-Matchup: Arbeitsmodell

Die lokale Spielinstallation für Wesnoth 1.19.22 definiert Dunefolk als
Fraktion mit den Rekruten Dune Rover, Dune Soldier, Dune Skirmisher, Dune
Rider, Dune Herbalist, Dune Burner und Naga Dirkfang. Ihre Fraktionsbeschreibung
nennt Geländeausnutzung für Angriffe bei Dawn/Dusk, gesetzestreue und liminale
Einheiten, Heiler, treffsichere Nahkämpfer und mobile berittene Bogenschützen.
Sie beschreibt höhere Kosten als bei Loyalisten, ausgeglichen durch höhere
Mobilität, besonders auf Hügeln. Quellen im installierten 1.19.22-Datenbestand:
`data/multiplayer/factions/dunefolk-default.cfg` und
`data/core/units/dunefolk/`.

Für LU folgen daraus zunächst **zu prüfende Matchup-Hypothesen**, keine
garantierten Counter:

- Dunefolk und LU können beide liminale Einheiten einsetzen. Dawn/Dusk ist
  deshalb kein exklusives LU-Zeitfenster gegen diese Fraktion; das jeweilige
  Einzelziel und dessen Ausrichtung entscheiden.
- Der rekrutierbare Dune Skirmisher hat Skirmisher und führt zu Dune Strider;
  Strider und Harrier haben einen verlangsamenden Fernkampfangriff. Diese
  fortgeschrittenen Slow-Einheiten können Formation und Kartenkontrolle
  bedrohen. Der rekrutierbare Herbalist heilt und regeneriert, hat im lokalen
  1.19.22-Unit-File aber keinen Slow-Angriff.
- Dune Burner-Feuer und später verfügbares Slow sind plausible Werkzeuge gegen
  bestimmte LU-Aufstellungen. Slow ist im aktuellen LU-Code kein automatischer
  Totalausfall der ganzen Resonanzgruppe; Gift und Schaden können anders wirken.
  Die jeweiligen Treffer, Widerstände und Positionsfolgen müssen geprüft
  werden.
- Gegen schnelle Vorstöße sind gegenseitige Unterstützung, Rückzugswege und
  Dorfkontrolle zu werten. „Bewegung bricht Resonanz“ darf dabei nicht als
  erklärte Regel verwendet werden, solange der Kinetic Relay-/Bewegungspfad
  ungeklärt ist.
- Für Fine-Tuning zuerst nach Karte, LU-Seite, Rekrutierung und konkretem
  Verlustmuster aufschlüsseln. Ein Dunefolk-Gesamtwert allein sagt nicht,
  welcher LU-Wert geändert werden sollte.

### Weitere Mainline-Matchups als Prüffragen

Die alten Faction-Doctrine-Texte enthielten nützliche taktische Fragen, aber
auch zu selbstsichere Behauptungen und veraltete Mechanics. Die folgenden
Punkte bleiben deshalb Hypothesen für den nächsten passenden Testlauf; die
aktuellen vollen Partien gegen die vier noch nicht getesteten Fraktionen dieser Tabelle sind durch den
Bestätigungslauf unten nicht abgedeckt.

| Fraktion | Im LU-Matchup prüfen | Nicht vorab als bewiesen behandeln |
|---|---|---|
| Loyalists | Ob lawful Tagesdruck, Führung und Feuerangriffe verletzliche LU-Ziele oder Support-Einheiten zuverlässig erreichen | Dass eine einzelne Tagesphase oder ein bestimmter Recruit-Mix das Matchup entscheidet |
| Rebels | Wie Waldverteidigung, Fernkampf und Shaman-Slow die LU-Podbildung und Zielwahl beeinflussen | Dass Slow die ganze Resonanzgruppe ausschaltet oder Focus gegnerische Evasion negiert |
| Northerners | Ob nächtliche Zahlenüberlegenheit, Gift und Druck auf mehrere Ziele LU zu ungünstigen Tauschen zwingen | Dass L0 Formation-ZOC allein frühe Überfälle verhindert |
| Undead | Kälteangriffe gegen Marines und die unterschiedlichen Folgen von Plague gegen organische Einheiten und G9 | Dass G9-Immunität den gesamten Untoten-Schneeball kontert oder Plague allein das Match entscheidet |
| Knalgan Alliance | Wie Gelände, hohe Widerstände und Fernkampfdruck gegen mobile LU-Einheiten und Resonanz-Alloys abschneiden | Dass alte Knockback-, Armor-Piercing- oder Regenannahmen bereits im aktuellen Code gelten |
| Drakes | Wie Flugbewegung, Feuerdruck und schnelle Kartenkontrolle gegen LU-Aufstellung und Rückzugswege wirken | Dass ein bestimmtes vorhergesagtes Matchup- oder Mapurteil aus alten Papieren allgemeingültig ist |

## 6. Vorhandene Run-Belege

Run-Artefakte bleiben unter `tools/balance/out/` erhalten. Sie werden nicht mit
den alten Entwurfsdokumenten gleichgesetzt.

### Screening A: 29. Oktober 2026

[`20261029T095545Z-3c07c6`](../../tools/balance/out/runs/20261029T095545Z-3c07c6/manifest.json)
lief System A im Profil `screening`, Era `LIUN_era_courageous`, gegen sieben
Mainline-Fraktionen; die Konfiguration nennt außerdem vier Karten und zwei
Spiele je Karte. Tatsächlich wurde nur System A ausgeführt, es gab also keine
KI-Partien in diesem Lauf. Der Lauf endete mit Status `completed`.
Das Manifest nennt die 1.19.22-Binärdatei, meldet die Engine-Version aber als
`version unavailable`. Seine Quellhashes für die vier geänderten Unit-Dateien
auf `faction-balance-finetuning` stimmen mit dem hier geprüften Stand überein.

Der Audit kennzeichnet Maiden Private, Marine Private und G9 AI in seinen
vereinfachten EHP-pro-Gold-Metriken nicht als Outlier; die Phoinix wird wegen
niedriger EHP-pro-Gold markiert. Diese Kennzahlen sind Priorisierungshinweise,
keine Aussage über volle Partien.

### Standgebundener A–D-Lauf: 29. Oktober 2026

[`20261029T095711Z-2b4ded`](../../tools/balance/out/runs/20261029T095711Z-2b4ded/manifest.json)
meldet A, B, C und D abgeschlossen, Era `LIUN_era_courageous`, vier Karten,
vier Spiele je Karte und die Gegner Undead, Drakes und Dunefolk. Der Lauf
nennt wie der Screening-A-Lauf den Branch `faction-balance-finetuning` und
Commit `0c6f1cbb54beca7ead0e76bf65097b71089068dd`. Die vier Pacing-Dateien
waren laut Manifest dabei uncommittiert verändert; ihr tatsächlicher
Run-Inhalt wird durch die gespeicherten SHA-256-Hashes beschrieben. Diese
vier Hashes stimmen mit dem am 29. Oktober geprüften HEAD
`06a5374cf0a98b966af51863074e5e2c3ba789f1` überein. Das ist keine
Übereinstimmung des gesamten Spielstands. Die Engine-Version bleibt im Manifest `version
unavailable`, auch wenn der konfigurierte Binary-Pfad auf 1.19.22 zeigt.

**Hashabgleich beider Runs gegen `06a5374`:** Abweichend sind
`lua/resonance.lua`, `macros/abilities.cfg`, beide Dateien unter `factions/`
sowie diese sieben Unit-Dateien unter `units/halfelven/`:
`maiden/a1-jaeger.cfg`, `maiden/a2-hunterkiller.cfg`,
`maiden/b2-techtronic.cfg`, `marines/a1-sergeant.cfg`,
`marines/a2-masterchief.cfg`, `marines/b2-weaponguard.cfg` und
`marines/c2-shieldguard.cfg`. Das manifestierte `lua/conductor.lua` ist
inzwischen entfernt. Insbesondere die neue Squad-Anchor-/L1–L2-Umsetzung
ist durch diese Runs nicht bestätigt. Auch die Mechanikbeschreibung dieser
Referenz benötigt dafür einen erneuten Codeabgleich; sie ist kein
vollständiger Audit des neuen HEAD.

Die folgenden Ergebnisse gelten für den manifestierten Arbeitsbaum des Runs.
Sie belegen weder die aktuelle Gesamtbalance noch unverändertes Verhalten
von System B–D auf dem heutigen Mechanik- und Fraktionsstand. Die passenden
vier Unit-Hashes reichen dafür nicht aus. System A liest generierte
`pp/`-Eingaben; deren Aktualität ist zusätzlich zu prüfen.

- **System B:** Der Bericht führt 31.752 simulierte Duelle auf. Das ist
  Kampfverteilungs-Evidenz für die getesteten Unit-/Szenario-Kombinationen,
  keine Winrate.
- **System C:** 14.706 Telemetrie-Ereignisse wurden zusammengefasst.
  Der Bericht weist ausdrücklich darauf hin, dass Recall, passives Einkommen,
  Upkeep, überlebende Armee und Alternativentscheidungen keine vollständige
  Bilanz ergeben.
- **System D gesamt:** 48/48 Partien ohne erfassten Matchfehler: 16 je Gegner.
  LU gewann 8, verlor 7 und spielte 1 Remis gegen Undead; gegen Drakes 4/10/2;
  gegen Dunefolk 6/9/1. Für Dunefolk beträgt die entscheidende LU-Winrate
  40% (6 Siege aus 15 entschiedenen Partien), mit einem breiten
  95%-Wilson-Intervall von 19,8% bis 64,3%.
- **Seitenverteilung gegen Dunefolk:** LU spielte achtmal als Seite 1
  (2 Siege, 6 Niederlagen) und achtmal als Seite 2 (4 Siege, 3 Niederlagen,
  1 Remis). Dieser Unterschied ist ein deutlicher Bias-Hinweis; der kleine
  Lauf erlaubt keine belastbare Schlussfolgerung, dass Dunefolk allgemein
  stärker oder LU im Matchup unterlegen ist.
- **Kartenverteilung gegen Dunefolk:** Hamlets 1/3/0, Den of Onis 1/2/1,
  Sablestone Delta 2/2/0, Caves of the Basilisk 2/2/0 (LU-Siege/Niederlagen/
  Remis). Vier Partien pro Karte sind zu wenig für Kartenurteile.

Die älteren generischen Berichte und Läufe mit anderem Branch-HEAD oder
`completed_with_errors` werden nicht als aktuelle Bestätigung der jetzigen
Einheitenwerte übernommen. Die oben verlinkten Runs dienen als standgebundene Vergleichsbelege; die
Dunefolk-Kalibrierung bleibt eine getrennte Mainline-Referenz. Ein neuer
manifestierter Lauf ist nötig, um den aktuellen Gesamtstand zu bestätigen.

## 7. Tuning-Schritte und offene Arbeit

1. Vor weiteren Balanceänderungen erneut Code und Run-Hashes des aktuellen
   Branches prüfen. Die alte Alignment-Konstante `lua/conductor.lua` war
   unbenutzt und wurde entfernt; maßgeblich ist der aktive WML-/Lua-Pfad.
2. Für LU gegen Dunefolk System-D-Läufe mit ausgeglichener Seitenrotation und
   deutlich größerer Stichprobe pro Karte durchführen. Daneben die
   Matchup-Rohdaten, Rekrutierung, frühe Verluste und beobachtete Mechaniken
   untersuchen; Telemetrie allein erklärt keine Ursache.
3. Menschliche 1v1-Partien und Replays als abschließende Prüfung verwenden.
   KI-Screenings sind dafür ein Filter, kein Ersatz.

## 8. Ersetzte Textquellen

Diese zehn Dateien wurden in die vorliegende Referenz geprüft und anschließend
entfernt:

- `docs/design/BALANCE_HANDOVER.md`
- `docs/design/PHASE1_MAINLINE_DOCTRINE.md`
- `docs/design/PHASE2_CROSS_FACTION.md`
- `docs/design/PHASE3_CONSTRAINTS.md`
- `docs/design/PHASE4_RESONANCE_AND_CONDUCTION.md`
- `docs/design/PHASE5_ALLOY_COMBAT_DOCTRINES.md`
- `docs/design/PHASE6_UNIT_ROSTER_DRAFT.md`
- `docs/design/PHASE7_BALANCE_AND_ABUSE_CASES.md`
- `docs/design/PHASE8_IMPLEMENTATION_SCOPING.md`
- `docs/lore/STRATEGY.md`

Quellcode, der aktuelle Suite-Prompt, Changelog, `docs/design/LUA_GUIDELINES.md`
und manifestierte Run-Belege sind keine dieser zehn Textquellen und bleiben
erhalten. Die aktiven Resonanz- und Conductance-Tooltips wurden inzwischen an
den geprüften Code angepasst; historische Changelog-Einträge bleiben als
Änderungshistorie bestehen.

Zusätzlich entfernt wurden der doppelte ältere Benchmark-Master-Prompt
`docs/genai/MASTER_PROMPT_BALANCE_BENCHMARK.md` und die englische
Strategieübersicht `docs/liminal union strategic.md`; ihre weiterhin gültigen
Arbeitsregeln und Aussagen stehen in den aktuellen Referenzdateien. Ebenfalls
entfernt wurden nicht manifestierte Root-Ausgaben, der doppelte Ordner
`tools/balance/out/run-20261028-codex/` und unvollständige ältere Dunefolk-
Vorläufe ohne eigenes Run-Manifest. Die vollständigen manifestierten
Runs, darunter die aktuellen Branch-Läufe und die Dunefolk-Kalibrierung,
bleiben erhalten.
