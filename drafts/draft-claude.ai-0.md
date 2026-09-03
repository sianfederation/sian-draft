<!-- markdownlint-disable MD041 MD033 -->
<img src="../images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-0: Federated Avatar-Based Social Network — Overview and Architecture

**Status:** AI-Generated Draft
**Category:** Informational
**Series:** This document is the entry point to a series (RFC-0 through RFC-4). It defines shared terminology and architecture; normative details live in the sub-RFCs it references.

## Abstract

This document proposes a federated, pseudonymous social network in which users interact through **avatars** rather than direct identities, discover people and events through physical **grid nodes**, and match on interests via a **decentralized ontology**. No central authority operates the network; where coordination is required (identity schemes, interest vocabularies, abuse policy), this document specifies mechanisms for **voluntary, forkable, community-amendable standards** in the tradition of IETF RFCs/BCPs, rather than mandated central services.

## 1. Terminology

- **Avatar**: A pseudonymous persona, cryptographically identified (see [RFC-1](./draft-claude.ai-1.md)), representing a subset of a user's interests and disposition. A user MAY control multiple avatars.
- **Grid Node**: A physical or virtual device that exchanges information with nearby user devices and/or other grid nodes (see [RFC-2](./draft-claude.ai-2.md)).
- **Disposition**: A time-decaying statement of current intent or mood (e.g., "looking for lunch," "open to a pickup game") distinct from an avatar's persistent interests.
- **Interest Document**: A signed, versioned record of an avatar's interests and dispositions (see [RFC-1](draft-claude.ai-1.md), [RFC-3](draft-claude.ai-3.md)).
- **Federation**: The voluntary interconnection of grid nodes and devices without a shared operator.
- **BCP (Best Current Practice)**: A community-amendable convention (vocabulary, rate-limit default, trust policy) that implementations SHOULD follow for interoperability but that carries no enforcement mechanism beyond voluntary adoption.

## 2. Motivation

Existing social platforms tie social graphs to durable, centrally-verified identities and centralize discovery and moderation. This proposal explores whether proximity-based, interest-driven social connection can be achieved (a) without a central operator, and (b) without users being permanently and singularly identifiable — while remaining safe enough to be usable in physical space. This last clause is the design's central tension and is treated as a first-class constraint throughout, not an afterthought.

## 3. Architecture Overview

```
 [User Device A] <--BLE/UWB handshake--> [Grid Node] <--IP gossip--> [Grid Node] <--...--> [Grid Node]
        |                                     |
   local matching                      local policy enforcement
   (interests, trust)                  (rate limits, reveal tiers)
```

Three planes, each specified in its own sub-RFC:

1. **Identity plane** ([RFC-1](draft-claude.ai-1.md)): How avatars are identified, how interest documents are signed, and how algorithm/method agility is bounded without becoming a downgrade vector.
2. **Discovery/transport plane** ([RFC-2](draft-claude.ai-2.md)): How devices and grid nodes exchange information, how staleness is handled, and how far information propagates.
3. **Semantic plane** ([RFC-3](draft-claude.ai-4.md)): How interests are expressed and matched across devices that have never coordinated on a shared schema.

A fourth cross-cutting concern, **cost-of-action** ([RFC-4](draft-claude.ai-4.md)), underlies both abuse-resistance and spam-resistance and is deliberately specified once rather than duplicated per subsystem.

## 4. Design Principles

- **P1 — No mandatory central service.** Any component requiring coordination MUST have a fully local or voluntarily-federated fallback.
- **P2 — Pseudonymity is not the same as unaccountability.** Unlinkability between avatars and real identity is a goal; unconditional freedom from consequence is explicitly not (see [RFC-4 ](draft-claude.ai-4.md)§3).
- **P3 — Staleness and uncertainty are accepted properties, not defects.** Eventually-consistent, TTL-bound data is preferred over designs that quietly reintroduce a central source of truth to guarantee freshness.
- **P4 — Agility is bounded, not unlimited.** Every place this design allows pluggable algorithms/methods/vocabularies, a minimal mandatory-to-implement default is specified so two arbitrary implementations can always interoperate at a baseline level.
- **P5 — Physical safety takes precedence over protocol elegance.** Where a clean distributed design and a safety requirement conflict (see [RFC-4](draft-claude.ai-4.md)), safety wins, even at the cost of some centralization or friction.

## 5. Security Considerations (Summary)

Full treatment is per-subsystem in [RFC-1](draft-claude.ai-1.md) (identity spoofing, downgrade attacks), [RFC-2]([./rfc-2.md]()) (relay/partition integrity), [RFC-3 ](draft-claude.ai-3.md)(ontology poisoning), and [RFC-4](draft-claude.ai-4.md) (Sybil attacks, IRL harm). The cross-cutting risk is stated here: **any mechanism that lowers the cost of creating a new avatar also lowers the cost of evading consequences for harm caused by a previous one.** This document treats that tradeoff as the central open problem of the series rather than something resolved by any single RFC.

## 6. Sub-RFC Index

| RFC                 | Title                                              | Status |
| ------------------- | -------------------------------------------------- | ------ |
| [RFC-1](draft-claude.ai-1.md) | Avatar Identity and the Signed Interest Envelope   | Draft  |
| [RFC-2](draft-claude.ai-2.md) | Grid Node Discovery, Transport, and Propagation    | Draft  |
| [RFC-3](draft-claude.ai-3.md) | Decentralized Interest Ontology and Matching       | Draft  |
| [RFC-4](draft-claude.ai-4.md) | Cost-of-Action: Spam Resistance and Accountability | Draft  |

## 7. Open Issues

- OI-1: Whether grid nodes should ever act as communication relays independent of the internet (see [RFC-2](draft-claude.ai-2.md) §5) is unresolved; current recommendation is to scope this out of v1.
- OI-2: Legal/regulatory treatment of pseudonymous systems used to arrange in-person meetings varies by jurisdiction and is out of scope for this document.
- OI-3: Governance process for amending shared BCPs (ontology, rate-limit defaults) is referenced but not yet specified — needs its own RFC.
