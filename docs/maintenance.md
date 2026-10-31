---
type: Playbook
title: "Product maintenance boundaries"
description: "Applies current-knowledge rules while keeping engine-loaded product content unchanged."
---
# Working method

Read the [documentation map](README.md), then only the sources relevant to the
assignment. Canon and language style retain their authority. The shared
[AI-pair standard](../../../umc-hace/generic/knowledge/ai-pair.md) applies to
maintenance; the product runs without that external document or any tools.

Update current explanations in place. Preserve currently useful rationale beside
the relevant design; do not accumulate decision logs. Metadata does not imply
human approval, engine validation or verified lore.

# Runtime boundary

This adoption changes documentation and instruction links only. Runtime WML,
Lua, loader paths, IDs, assets and translations remain untouched. Existing names
and large runtime files are compatibility exceptions, not permission to refactor.
A later runtime assignment needs a concrete plan and appropriate engine checks.

The OKF 0.2 bundle is `docs/`. Agent instructions, Lua source documentation,
licenses, changelog and engine data keep their native formats outside the bundle.
Runtime readability debt is visible in the development workspace's
[maintenance scope](../../../umc-development/projects/liminal-union/knowledge/maintenance.md).
