<!-- markdownlint-disable MD041 MD033 -->
<img src="../images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-2: Grid Node Discovery, Transport, and Propagation

**Status:** AI-Generated Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./draft-claude.ai-0.md) (Terminology), [RFC-1](./draft-claude.ai-1.md) (Envelope format)

## Abstract

This document specifies how user devices discover grid nodes and each other, how information propagates between grid nodes over distance, and how staleness arising from disconnected/intermittent contact is handled. It explicitly does not attempt to guarantee freshness — see [RFC-0](./draft-claude.ai-0.md) P3.

## 1. Device-to-Node Handshake

- **Transport (MTI):** Bluetooth Low Energy (BLE) for proximity discovery. UWB MAY be used where available for higher-precision ranging.
- On approach, device and node exchange signed Envelopes ([RFC-1](./draft-claude.ai-1.md) §3) at minimum containing: DID, a capability advertisement (what the node offers: events, ambient activity broadcasts, etc.), and TTL-bound interest/disposition data the device is willing to disclose at this trust tier.
- **Capability tokens for meetup-class exchanges:** where a handshake could lead to resolving precise location/time ([RFC-4](./draft-claude.ai-4.md) §2's "IRL-meetup-class" actions), the initial exchange MUST use a short-lived, single-use capability token rather than a durable pointer, to avoid creating a stable correlation handle across visits (see [RFC-1](./draft-claude.ai-1.md) §1.2, [RFC-4](./draft-claude.ai-4.md) §3).

## 2. Node-to-Node Federation

Grid nodes propagate information to each other over existing IP infrastructure using a gossip protocol, not dedicated RF backhaul (see §5, Open Issues, on why cellular-style node infrastructure is out of scope for v1).

- Nodes choose their federation peers voluntarily ([RFC-0](./draft-claude.ai-0.md) P1); there is no mandated topology.
- Propagated envelopes retain their original [RFC-1](./draft-claude.ai-1.md) signatures; intermediate nodes are transport-only and are NOT trusted for integrity, only availability ([RFC-1](./draft-claude.ai-1.md) §3.2).
- Each node applies its own local policy for what it accepts, retransmits, and how far (see [RFC-4](./draft-claude.ai-4.md) §1 for rate-limit mechanisms situated at this layer).

## 3. Propagation Radius and Relevance

- Radius is a property the **originating device or node** attaches to a broadcast (e.g., "relevant within 500m" vs. "relevant regionally"), not something a receiving node imposes.
- **Relevance decay is a device-side, portable computation**, not a node-side one: a user's willingness to travel for a given activity type is a property of the user and activity, and SHOULD persist across nodes as part of the device's local relevance model rather than being recomputed fresh at each node from physical distance alone.

## 4. Staleness and Partition Handling

Per [RFC-0](./draft-claude.ai-0.md) P3, this is an accepted property:

- Envelopes carry `revision` and `ttl_seconds` ([RFC-1](./draft-claude.ai-1.md) §3.1); devices merge on receipt using last-writer-wins by revision.
- Two device/node clusters that never bridge will diverge indefinitely. This is not treated as a fault condition requiring remediation, but implementers SHOULD surface data "freshness" (e.g., last-seen timestamp for a given avatar's record) to end users rather than presenting all matched data as equally current.

## 5. Open Issues

- OI-1: Whether grid nodes should function as communication relays (a "cell tower of sorts," per the original proposal) independent of the internet is deferred. Building dedicated RF backhaul introduces spectrum licensing and infrastructure costs disproportionate to the discovery use case; internet-based gossip (§2) is recommended for v1, with node-as-relay revisited only if a specific use case (e.g., disaster/no-connectivity scenarios) justifies the cost.
- OI-2: Formal analysis of gossip convergence time under realistic human-mobility patterns (cf. DTN routing literature — Epidemic Routing, PRoPHET) has not been done for this specific design and is needed before claiming convergence bounds.
