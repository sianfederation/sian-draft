<!-- markdownlint-disable MD041 MD033 -->
<img src="../images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-1: Avatar Identity and the Signed Interest Envelope

**Status:** AI-Generated Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./rfc-0.md) (Terminology)

## Abstract

This document specifies how avatars are identified, how cryptographic algorithm agility is bounded, and how interest/disposition data is packaged into a signed, verifiable envelope suitable for exchange over disconnected, low-bandwidth links ([RFC-2](./rfc-2.md)).

## 1. Avatar Identifiers

Avatars MUST be identified by a [Decentralized Identifier (DID)](https://www.w3.org/TR/did-core/): `did:<method>:<method-specific-id>`. The method segment is the pluggability point — new identification systems are adopted by defining or reusing a DID method, not by extending this protocol.

### 1.1 Recognized methods (v1)

| Method     | Resolution                       | Cost to create           | Rotation/Revocation                     | Recommended use                                        |
| ---------- | -------------------------------- | ------------------------ | --------------------------------------- | ------------------------------------------------------ |
| `did:key`  | None (self-certifying)           | Free                     | Not supported — new key implies new DID | Default for casual/low-stakes avatars                  |
| `did:peer` | Pairwise, exchanged at handshake | Free                     | Supported via signed rotation log       | Long-lived pairwise relationships between two avatars  |
| `did:web`  | DNS + HTTPS                      | Cost of domain ownership | Supported via document update           | Organizations, venues, avatars wanting discoverability |

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

- **[Sybil](https://en.wikipedia.org/wiki/Sybil_attack) generation**: `did:key` avatars are free to create in unlimited quantity. This is intentional (low-friction pseudonymity is a design goal) but interacts directly with abuse resistance; see [RFC-4](./rfc-4.md).
- **Downgrade attacks**: bounding algorithm agility to a small MTI set with explicit, non-silent opt-in for anything else mitigates but does not eliminate this risk.
- **Key compromise on `did:key`**: no rotation is possible by design; a compromised `did:key` avatar's history and reputation cannot be recovered under a new key. Avatars requiring rotation guarantees SHOULD use `did:peer` or `did:web`.

## 5. Algorithm Deprecation

Deprecating an algorithm in the registry (§2.2) is a software-capability change, not an identity change, and MUST NOT require a new handshake between existing peers.

- **Dual-signing overlap.** During a deprecation window, envelopes SHOULD be signed under both the outgoing and incoming algorithm, so peers running either old or updated software continue to verify successfully. Implementers SHOULD publish a recommended overlap duration as part of the registry entry deprecating the old algorithm (BCP, [RFC-0](./rfc-0.md) §1).
- **Historical verification is preserved.** Deprecating an algorithm for _new_ signatures does not invalidate previously issued signatures under that algorithm. Implementations SHOULD retain verification (but not signing) support for deprecated algorithms indefinitely, or for a clearly published retention period, so historical envelopes remain checkable.
- **Fail-closed on unrecognized tags still applies** (§2.2): a device that has not yet updated simply cannot verify the new algorithm and MUST treat it as unverifiable, not invalid — these are different failure states and SHOULD be surfaced differently to the user (e.g., "can't verify — update needed" vs. "signature invalid").

## 6. Key Rotation and DID Migration

Unlike algorithm deprecation, rotating the underlying key **may or may not** require peers to take any action, depending on DID method (§1.1).

### 6.1 Methods with native rotation

`did:web` and `did:peer` support rotation without changing the DID itself:

- `did:web`: the key document at the resolvable location is updated in place; any future resolution retrieves the new key automatically. No handshake or migration statement is needed.
- `did:peer`: a signed rotation event is appended to the pairwise log already shared between the two peers (per DIDComm-style rotation). Existing contacts pick up the new key through that log without renewed physical contact.

### 6.2 `did:key`: rotation as migration

Because a `did:key` identifier _is_ its public key (§1.1), there is no in-place rotation — only replacement with a new DID. To avoid this being indistinguishable from an unrelated new avatar, this document defines a **Migration Statement**:

```
MigrationStatement {
  old_did:       string
  new_did:       string
  effective_at:  timestamp
  signature_old: bytes   // signed by old_did's key
  signature_new: bytes   // signed by new_did's key
}
```

- MUST be signed by **both** keys, proving control of both without requiring the old key to remain usable for anything else afterward.
- Propagates through the same gossip channel as any other envelope ([RFC-2](./rfc-2.md) §2); no in-person re-handshake is required for peers who receive it.
- A device that already trusts `old_did` and receives a valid Migration Statement SHOULD carry forward trust, reputation, and cached interest history to `new_did`.
- A device that never receives the statement will see `old_did` and `new_did` as unrelated avatars. This is an accepted consequence of the partition problem ([RFC-2](./rfc-2.md) §4), not a fault requiring remediation — but implementations SHOULD retry propagating a device's own pending migration statements opportunistically (e.g., on every subsequent handshake) rather than broadcasting once and assuming delivery.

### 6.3 Migration is a cost-bearing action

A Migration Statement is a mechanism for **inheriting trust**, which makes it a Sybil-adjacent surface: cheap, unconditional migration could be used either to launder a reputation-damaged `did:key` into a fresh-looking identity while quietly retaining continuity where useful, or to fabricate false continuity and inherit trust that was never earned. Migration Statements MUST therefore be subject to the same cost-of-action tiering as identity creation itself, not treated as free housekeeping — see [RFC-4](./rfc-4.md) §3.4.

## 7. Open Issues

- OI-1: Whether a lightweight, non-blockchain-anchored method offering both free creation _and_ rotation is feasible is unresolved; `did:peer`'s pairwise nature limits its use to bilateral relationships, not broadcast contexts.
- OI-2: Whether Migration Statements should be selectively disclosable (e.g., proving continuity to one peer without broadcasting the link network-wide) is unresolved; as specified in §6.2, a gossiped Migration Statement is visible to anyone who receives it, which may leak more linkage than a user intends.
