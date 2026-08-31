# RFC-1: Avatar Identity and the Signed Interest Envelope

**Status:** Draft **Category:** Standards Track **Depends on:** [RFC-0](./rfc-0.md) (Terminology)

## Abstract

This document specifies how avatars are identified, how cryptographic algorithm agility is bounded, and how interest/disposition data is packaged into a signed, verifiable envelope suitable for exchange over disconnected, low-bandwidth links ([RFC-2](./rfc-2.md)).

## 1. Avatar Identifiers

Avatars MUST be identified by a [Decentralized Identifier (DID)](https://www.w3.org/TR/did-core/): `did:<method>:<method-specific-id>`. The method segment is the pluggability point — new identification systems are adopted by defining or reusing a DID method, not by extending this protocol.

### 1.1 Recognized methods (v1)

|Method|Resolution|Cost to create|Rotation/Revocation|Recommended use|
|---|---|---|---|---|
|`did:key`|None (self-certifying)|Free|Not supported — new key implies new DID|Default for casual/low-stakes avatars|
|`did:peer`|Pairwise, exchanged at handshake|Free|Supported via signed rotation log|Long-lived pairwise relationships between two avatars|
|`did:web`|DNS + HTTPS|Cost of domain ownership|Supported via document update|Organizations, venues, avatars wanting discoverability|

Implementations MUST support `did:key` as the mandatory-to-implement baseline (P4, [RFC-0](./rfc-0.md)). Support for other methods is OPTIONAL but SHOULD be advertised during handshake so peers know what to expect.

### 1.2 Trust tiering by method

Because `did:key` has zero creation cost, receiving devices SHOULD treat it as a _low-trust-by-default_ identity tier for anything beyond passive broadcast ([RFC-4](./rfc-4.md) §2 defines "IRL-meetup-class" actions that require a higher tier). This is a visible signal, not hidden protocol state: clients SHOULD surface which tier an avatar's DID method implies before a user acts on it.

## 2. Cryptographic Algorithm Agility

Signature and key material MUST be self-describing rather than assumed from context, using multicodec-style prefixing (as used by `did:key` itself) so verifiers dispatch on an explicit algorithm tag rather than a negotiated or assumed default.

### 2.1 Mandatory-to-implement (MTI) algorithm

All implementations MUST support **Ed25519** for signing. This is the only algorithm required for baseline interoperability.

### 2.2 Optional algorithms

Additional algorithms MAY be supported (e.g., secp256k1, post-quantum schemes as they mature) provided:

- The algorithm tag is registered in a public, versioned registry (community-amendable per [RFC-0](./rfc-0.md) §1, BCP).
- A receiving device that does not recognize an algorithm tag MUST reject the signature as unverifiable, never treat it as valid-by-default.
- A receiving device MUST NOT silently accept a signature under an algorithm weaker than one previously used by the same DID without explicit user confirmation (downgrade-attack protection).

## 3. The Signed Interest Envelope

An interest/disposition record is packaged as:

```
Envelope {
  did:            string           // subject avatar's DID
  alg:            multicodec-tag   // signature algorithm used
  pubkey:         multicodec-tag + bytes
  revision:       uint64           // monotonic per-DID counter
  issued_at:      timestamp
  ttl_seconds:    uint32           // 0 = disposition-class (short-lived); omitted/large = interest-class
  payload:        InterestDocument // see RFC-3 for schema
  signature:      bytes
}
```

### 3.1 Freshness semantics

- `revision` is a monotonically increasing counter per DID. Receivers merging two envelopes for the same DID MUST discard the lower-revision one regardless of arrival order (vector-clock-style conflict resolution, [RFC-0](./rfc-0.md) P3).
- `ttl_seconds` governs decay: dispositions (e.g., "looking for lunch") SHOULD carry short TTLs; stable interests SHOULD carry long or absent TTLs. Expired envelopes MUST be dropped or down-weighted by receivers, not treated as authoritative.

### 3.2 Multi-hop integrity

Because envelopes may be relayed through untrusted grid nodes ([RFC-2](./rfc-2.md)), the signature covers `did`, `revision`, `issued_at`, `ttl_seconds`, and `payload` such that **any relay can forward the envelope without being able to modify it undetected**, and no relay needs to be trusted for integrity — only for availability.

## 4. Security Considerations

- **Sybil generation**: `did:key` avatars are free to create in unlimited quantity. This is intentional (low-friction pseudonymity is a design goal) but interacts directly with abuse resistance; see [RFC-4](./rfc-4.md).
- **Downgrade attacks**: bounding algorithm agility to a small MTI set with explicit, non-silent opt-in for anything else mitigates but does not eliminate this risk.
- **Key compromise on `did:key`**: no rotation is possible by design; a compromised `did:key` avatar's history and reputation cannot be recovered under a new key. Avatars requiring rotation guarantees SHOULD use `did:peer` or `did:web`.

## 5. Open Issues

- OI-1: Whether a lightweight, non-blockchain-anchored method offering both free creation _and_ rotation is feasible is unresolved; `did:peer`'s pairwise nature limits its use to bilateral relationships, not broadcast contexts.