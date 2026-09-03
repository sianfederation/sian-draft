<!-- markdownlint-disable MD041 MD033 -->
<img src="../images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-7: Discovery and Ranking Specification

**Status:** Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./draft-claude.ai-0.md) (Architecture), [RFC-1](./draft-claude.ai-1.md) (Avatar Identity), [RFC-3](./draft-claude.ai-3.md) (Interest Ontology), [RFC-4](./draft-claude.ai-4.md) (Cost-of-Action)

## Abstract

[RFC-3](./draft-claude.ai-3.md) defines _what_ interests exist and how they are tagged. It does not define _how_ matches between avatars are surfaced, ordered, or throttled. This gap matters: the surfacing function is where radicalization funnels, echo chambers, and engagement-driven outrage amplification actually live in existing social networks. This document specifies a Discovery and Ranking Layer (DRL) that is local, auditable, resistant to central capture, and structurally biased toward cross-cutting exposure rather than engagement maximization.

## 1. Motivation

Centralized platforms optimize a single scalar — time-on-platform or engagement — using an opaque, centrally-controlled model. Three properties of that arrangement are causally linked to the harms this protocol aims to avoid:

1. **A single optimization target** collapses diverse human goals (learning, organizing, connecting, resting) into one proxy metric, and that proxy is well known to correlate with outrage, novelty, and moral-emotional content.
2. **Opacity** prevents users, researchers, or competing implementations from detecting or correcting the resulting drift toward extremity.
3. **Central control** means the incentive to correct for #1 and #2 is weak, because the operator's revenue depends on the same metric being maximized.

SIÂN's federation and pseudonymity already remove #3 as a structural default. This RFC removes #1 and #2 by specifying a ranking function that is (a) locally computed by the avatar's own node/client, (b) built from declared interests rather than inferred engagement signals, and (c) required to expose a diversity/bridging term, not just a similarity term.

This does not guarantee good outcomes. It removes the specific mechanism by which current networks reliably produce bad ones.

## 2. Terminology

- **Candidate set**: the pool of avatars, groups, or content objects a ranking function may consider, drawn from local grid-node peers and federated interest-graph traversal ([RFC-2](./draft-claude.ai-2.md)).
- **Affinity score**: similarity between the requesting avatar's declared interest set and a candidate's, per [RFC-3](./draft-claude.ai-3.md)'s tag/embedding scheme.
- **Bridging score**: a measure of how much a candidate's inclusion increases the diversity of viewpoint- or cluster-membership in the requesting avatar's exposure set, defined in §5.
- **Exposure set**: the ordered list actually returned to the client for a given discovery query.
- **Ranking authority**: whichever entity computes the final ordering. Under this RFC, ranking authority is always the requesting avatar's own client software, never a remote server.

## 3. Design Goals

1. No party other than the requesting avatar's own client determines the final exposure set. Remote nodes may propose candidates; they may not rank them.
2. The ranking function MUST be a pure, published, versioned function of (candidate features, avatar preferences). Given the same inputs, any compliant client produces the same ordering. This makes manipulation detectable: if a node systematically injects candidates with suspicious feature profiles, that is externally auditable.
3. Every exposure set MUST include a nonzero, disclosed minimum share of bridging candidates (§5), not purely affinity-maximizing candidates.
4. The ranking function MUST NOT take engagement history (dwell time, click-through, past reactions) as an input feature. Declared interests ([RFC-3](./draft-claude.ai-3.md) tags, explicit follows) are permitted inputs; behavioral inference is not. This is the single largest structural break from engagement-optimized platforms and is treated as a MUST, not a SHOULD.
5. Cost-of-action ([RFC-4](./draft-claude.ai-4.md)) MUST gate candidate eligibility before ranking, not after, so that Sybil-inflated candidates never enter the pool.

## 4. Candidate Generation

Candidate sets are assembled from three sources, each weighted and disclosed to the user as a labeled slider or equivalent UI affordance — not hidden inside a single opaque "recommended for you" bucket:

- **4.1 Proximity candidates**: peers discoverable via the requesting avatar's grid node(s), per [RFC-2](./draft-claude.ai-2.md).
- **4.2 Explicit-graph candidates**: avatars/groups the user follows, or that follow avatars the user follows (bounded hop count, default 2).
- **4.3 Tag-traversal candidates**: avatars/groups sharing one or more [RFC-3](./draft-claude.ai-3.md) canonical tags or within a configurable embedding-distance threshold of the user's free-tags.

All three sources are subject to [RFC-4](./draft-claude.ai-4.md) cost-of-action eligibility filtering before being passed to ranking: an account that has not paid the applicable action cost for visibility (posting, tagging, joining) within the current epoch is excluded from the candidate set, independent of ranking. This is what prevents a Sybil swarm from being ranking's problem to solve — it never reaches ranking.

## 5. The Bridging Requirement

### 5.1 Rationale

Homophily (people connecting to similar others) is the default outcome of pure affinity ranking, and repeated exposure within a homogeneous cluster is a documented precursor to polarization and radicalization drift. A discovery layer that _only_ maximizes affinity will produce echo chambers even with no bad actors and no engagement-optimization at all — it's a structural consequence of the objective function, not a moderation failure.

### 5.2 Mechanism

Each exposure set of size _N_ is composed as:

```
exposure_set = top_k(candidates, affinity_score, k = N * (1 - β))
             + top_j(candidates, bridging_score, j = N * β)
```

where β is a client-side, user-adjustable parameter with a protocol-defined floor (§5.3) and no ceiling. `bridging_score` for a candidate _c_ is computed as the marginal increase in cluster-membership entropy of the exposure set if _c_ is included, where "cluster" is derived from the [RFC-3](./draft-claude.ai-3.md) canonical tag graph (e.g., detecting that a candidate bridges two tag-communities that rarely co-occur in the requesting avatar's existing exposure history).

Critically, `bridging_score` is computed over **topic/interest clusters**, not political or demographic categories. The protocol has no concept of left/right, in-group/out-group, or protected-class categories at the ranking layer — it only knows tag-graph structure. This is a deliberate constraint: it lets bridging work (connecting a birdwatcher to a hunter via `#wetlands_conservation`) without requiring the protocol, or any node operator, to classify people by ideology, which would itself be a governance and abuse hazard.

### 5.3 Floor

β MUST default to no lower than 0.15 (15% of any exposure set) and MUST be visible and adjustable by the user, never silently overridden by a node operator or client vendor. A client that ships with β = 0 by default is non-compliant with this RFC. Users remain free to set β = 0 themselves — the requirement is against silent operator override, not against user autonomy.

## 6. Anti-Manipulation Integration

- **6.1** Ranking inputs are limited to: declared tags ([RFC-3](./draft-claude.ai-3.md)), explicit graph edges, grid-node proximity, and [RFC-4](./draft-claude.ai-4.md) cost-of-action eligibility state. No hidden signal (device fingerprint, inferred sentiment, time-of-day engagement pattern) may be a ranking input under this RFC.
- **6.2** Because the ranking function is pure and published (§3.2), a third party can replay a given avatar's declared inputs against the reference implementation and verify their client produced a compliant exposure set. This gives users and researchers an audit path that centralized "trust our algorithm" platforms structurally cannot offer.
- **6.3** Coordinated inauthentic amplification (a ring of avatars mutually boosting a tag to inflate its apparent affinity relevance) is priced, not filtered: each participating avatar must independently clear [RFC-4](./draft-claude.ai-4.md) cost-of-action thresholds, and the marginal cost of the ring scales linearly with ring size. Ranking does not attempt to detect coordination; economics does.

## 7. Local Enforceability

Per the project's general design bias ([RFC-0](./draft-claude.ai-0.md) §2), the DRL requires no coordination beyond what [RFC-2](./draft-claude.ai-2.md) grid-node discovery already assumes. A node operator cannot centrally impose a different β, a different candidate source weighting, or a hidden ranking term on a client it does not control — ranking authority is strictly client-side (§3.1). A malicious or captured node can withhold or bias the _candidate pool_ it proposes, but cannot alter how a compliant client ranks whatever candidates it does see, and federation (multiple grid nodes, multiple tag-traversal paths) bounds the damage a single captured node can do to candidate diversity.

## 8. Transparency and User Controls

Clients compliant with this RFC MUST expose, at minimum:

1. The current value of β and a control to change it.
2. A labeled breakdown of the current exposure set by source (§4.1–4.3) and by affinity vs. bridging (§5).
3. A "why am I seeing this" explanation for any candidate, naming the specific shared tag(s), graph path, or proximity relationship that produced its inclusion.

This is the inverse of "black box recommender": every ranking decision must be traceable to a declared, user-visible input.

## 9. Non-Goals

This RFC does not attempt to:

- Classify or moderate content by viewpoint, truth value, or political valence. That is out of scope for the transport/ranking layer and properly belongs, if anywhere, to community-level moderation tooling built atop this protocol, not to the base specification.
- Guarantee depolarization. §5's bridging mechanism increases the probability of cross-cutting exposure; it cannot control what a human does with that exposure.
- Replace [RFC-4](./draft-claude.ai-4.md)'s cost-of-action as the primary Sybil defense. Ranking assumes a pre-filtered candidate pool and is not itself an abuse defense.

## 10. Security Considerations

- A node that can bias candidate generation (§4) has more leverage over outcomes than one that can only try to bias ranking, since ranking is client-local and auditable while candidate proposal is not fully verifiable by the requesting client. Future work should consider a candidate-provenance attestation so clients can detect anomalously skewed proposal sets from a given node.
- β itself is a manipulable-by-social-engineering surface: a client vendor could nudge users toward β = 0 via dark-pattern UI even while remaining technically compliant with the floor in §5.3. This is a governance/UX concern this RFC flags but cannot enforce cryptographically.

## 11. Open Questions

- Should `bridging_score` be computed purely from the requesting avatar's own exposure history (fully local, no shared state) or informed by aggregate, privacy-preserving statistics from the grid node (better bridging quality, but reintroduces a trust dependency)? Current draft assumes fully local; this trade-off deserves discussion before last-call.
- Interaction with [RFC-1](./draft-claude.ai-1.md) §6 Migration Statements: does a DID migration reset an avatar's exposure history for bridging-entropy purposes, and should it? Leaning toward "no reset" to avoid creating a reputation-laundering incentive at the discovery layer that mirrors the one [RFC-4](./draft-claude.ai-4.md) §3.4 already closed at the identity layer.

## 12. References

- [RFC-0](./draft-claude.ai-0.md): SIÂN Overview and Architecture
- [RFC-1](./draft-claude.ai-1.md): Avatar Identity and Signed Interest Envelope
- [RFC-2](./draft-claude.ai-2.md): Grid Node Discovery and Transport
- [RFC-3](./draft-claude.ai-3.md): Decentralized Interest Ontology
- [RFC-4](./draft-claude.ai-4.md): Cost-of-Action Primitive