# Produktregeln für Liminal Union

Dies ist das aktuelle Spielprodukt. Bestehende interne Struktur und Spielverhalten erhalten; keine beiläufigen Änderungen an Werten, IDs, Aufstiegen, Ereignissen, persistenten Variablen, Assets, Laufzeitpfaden oder Übersetzungsdomänen. Worker, Gebäude, Terraforming und `units/nations/` gehören vollständig zum Produkt.

Für fachliche Arbeit [Kanon](docs/canon/CANON_LOCK.md), [Sprachstil](docs/canon/STYLE_GUIDE.md) und die einschlägigen vorhandenen Quellen unter `docs/lore/`, `docs/design/` und `docs/style/` lesen. Bestehender Code ist keine automatische fachliche Bestätigung.

Das Produkt muss ohne AI-HACE und Messsoftware funktionieren. Keine Test-Includes, Werkzeugabhängigkeiten oder generierten Run-Dateien in den Spielkern einbauen. Produktänderungen benötigen einen konkreten Auftrag; das Workspace-Scaffolding erlaubt keine Laufzeitänderungen.

Ergänzend gelten die [gemeinsamen Arbeitsregeln](../AGENTS.md) und [Arbeitsmethoden](../ai-hace/README.md). Bei isolierter Öffnung bleiben die Regeln dieses Dokuments maßgeblich; fehlende übergeordnete Dokumente nicht durch erfundene Freigaben ersetzen. Diese Dateien belegen keine automatische AI-Host-Einbindung.
