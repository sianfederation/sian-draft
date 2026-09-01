# RFC-4: Cost-of-Action — Spam Resistance and Accountability

**Status:** Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./rfc-0.md) (Principles P2, P5), [RFC-1](./rfc-1.md) (Identity), [RFC-2](./rfc-2.md) (Propagation)

## Abstract

This document specifies a single **cost-of-action** primitive underlying two problems that would otherwise require separate mechanisms: broadcast spam (advertisers flooding grid nodes) and physical-safety accountability (pseudonymous avatars used to threaten or lure users into harm). Both problems share a root cause per [RFC-0](./rfc-0.md) §5: making an action (creating an identity, sending a broadcast) too cheap makes abuse of that action too cheap. This RFC treats cost as a first-class, tunable protocol property rather than bolting on separate ad hoc limits per subsystem.

## 1. Action Classes and Required Cost Tier

Actions are classified by risk, and each class specifies a minimum cost mechanism (§2) and, where relevant, a minimum identity tier ([RFC-1](./rfc-1.md) §1.2):

|Class|Examples|Minimum identity tier|Minimum cost mechanism|
|---|---|---|---|
|Passive broadcast|Ambient interest sharing, general event ads|`did:key` acceptable|Local rate-limit (§2.1)|
|Repeated/wide broadcast|"All nodes in an area," advertiser campaigns|`did:key` acceptable|Proof-of-work or stake (§2.2/§2.3)|
|**IRL-meetup-class**|Precise location/time resolution, direct 1:1 coordination to meet in person|`did:peer` or `did:web` recommended; `did:key` permitted only with step-up (§3.2)|Reputation/stake (§2.3) + graduated disclosure (§3)|

## 2. Cost Mechanisms (Local, No Central Authority)

Per [RFC-0](./rfc-0.md) P1, each mechanism is enforceable unilaterally by a receiving node/device with no coordination required.

### 2.1 Local rate-limits (default BCP)

Receiving nodes SHOULD apply a default rate-limit per sending DID (e.g., N broadcasts/hour), configurable per node operator. A suggested default is published as a community-amendable BCP ([RFC-0](./rfc-0.md) §1) rather than mandated in this RFC.

### 2.2 Proof-of-work

For higher-cost classes, senders attach a computational puzzle solution scaled to the action's reach (wider propagation radius = higher difficulty). Verification is local to the receiving node; no shared ledger is required. This is the Hashcash pattern applied to physical-proximity broadcast rather than email.

### 2.3 Stake/bonding and reputation

A sender MAY post a refundable bond, forfeited if a threshold of receiving nodes/users flag the broadcast as abusive. Reputation accrues per-DID (not per-user-account) but see §3.1 for why this is insufficient alone.

## 3. Accountability Without Full Deanonymization

Per [RFC-0](./rfc-0.md) P2, pseudonymity and accountability are not treated as opposites; the goal is asymmetric reveal, not none-vs-full identification.

### 3.1 Per-avatar reputation is insufficient alone

Because avatar creation is cheap under `did:key` ([RFC-1](./rfc-1.md) §1.2), an avatar with a damaged reputation can be discarded and replaced at no cost — reputation MUST NOT be the sole accountability mechanism for IRL-meetup-class actions.

### 3.2 Graduated disclosure for meetup-class actions

For actions in the IRL-meetup class:

- Initial broadcast/match reveals coarse information only (e.g., neighborhood-level location, activity category) regardless of DID method.
- Precise location/time is disclosed only after **mutual, explicit opt-in from both avatars**, at which point the identity tier requirement (§1 table) is enforced — a low-trust-tier avatar attempting to resolve precise coordination SHOULD trigger a step-up prompt (e.g., require a `did:peer`/`did:web`-class identity, or a posted bond) before disclosure proceeds.
- Venue-operated grid nodes ([RFC-2](./rfc-2.md) §1) MAY enforce stricter local policy for any exchange that resolves to "meet at this venue," since the venue carries real-world liability exposure and has direct incentive to enforce it ([RFC-0](./rfc-0.md) P5).

### 3.3 Non-forgeable cost as the common primitive

[Sybil](https://en.wikipedia.org/wiki/Sybil_attack) resistance (this section) and spam resistance (§2) are the same underlying mechanism — imposing non-zero cost on an action — applied at two different thresholds. Implementers SHOULD reuse a single cost-of-action module across both rather than building redundant subsystems.

### 3.4 Migration Statements are a Sybil-adjacent action

[RFC-1 ](./rfc-1.md)§6.2 defines a Migration Statement allowing a `did:key` avatar to be replaced while carrying forward trust and reputation. Because this is a mechanism for _inheriting_ trust rather than earning it fresh, it MUST be treated as an action requiring cost, not free housekeeping:

- A Migration Statement that carries forward a **damaged reputation** (per §2.3 bonding/flag history) SHOULD carry that damage to the new DID as well, not discard it — otherwise migration becomes a laundering path around reputation loss, defeating §3.1's premise entirely.
- A Migration Statement that carries forward a **positive reputation** into a context requiring step-up verification (§3.2) SHOULD still require the identity-tier check appropriate to the new DID's method, not inherit an exemption from the old one.
- Implementers SHOULD apply the same rate-limit or cost mechanism (§2.1–§2.3) to migration frequency as to identity creation itself — an avatar migrating repeatedly in a short window is exhibiting the same evasion pattern as rapid Sybil creation and SHOULD be treated accordingly.

## 4. Security Considerations

- No mechanism here is failsafe; PoW and bonding are both defeatable at sufficient attacker resource levels. This RFC raises the cost of abuse, it does not eliminate it, and the [RFC-0](./rfc-0.md) abstract's framing ("does this make the idea infeasible?") should be read against that limitation, not against a claim of solved safety.
- Federated, locally-enforced rate limits mean policy will be inconsistent across nodes/operators. This is accepted per [RFC-0](./rfc-0.md) P1 but SHOULD be disclosed to users (e.g., "this node has looser broadcast limits than your home node").

## 5. Open Issues

- OI-1: No mechanism here prevents a well-resourced bad actor from paying the cost repeatedly. Whether this is an acceptable residual risk for a v1 deployment, or requires an additional layer (e.g., mandatory cooling-off periods after a flagged bond forfeiture), is unresolved.
- OI-2: Legal enforceability of bonding/stake mechanisms (who holds forfeited funds, dispute resolution) is out of scope for this document and likely needs a governance-focused companion RFC.