# RFC-5: The `sian:` URI Scheme

**Status:** Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./rfc-0.md) (Terminology), [RFC-1](./rfc-1.md) (DIDs, Envelopes), [RFC-2](./rfc-2.md) (Capability Tokens), [RFC-3](./rfc-3.md) (Interest Documents)

## Abstract

This document defines `sian:`, a URI scheme (per [RFC 7595](https://www.rfc-editor.org/rfc/rfc7595)) for addressing the resource types introduced across RFC-1 through RFC-4: avatar identifiers, signed envelopes, interest documents, capability tokens, and grid nodes. It also justifies why a dedicated scheme is used rather than reusing `https:`/`did:` directly, per RFC 7595 §2's requirement to demonstrate need.

## 1. Justification for a New Scheme

RFC 7595 §2.2 requires that a new scheme not duplicate the functionality of an existing one without cause. `sian:` is justified here because:

- A `sian:` URI may resolve to _different_ underlying mechanisms depending on context and DID method ([RFC-1](./rfc-1.md) §1.1) — sometimes `did:web` (HTTPS resolution), sometimes `did:key` (no resolution at all, self-certifying), sometimes a gossip-propagated envelope ([RFC-2](./rfc-2.md)) with no fixed network location. No single existing scheme covers all three uniformly.
- Distinguishing `sian:` resources at the scheme level lets clients/OS-level handlers register a dedicated handler (e.g., "open this in the Sian app") the way `mailto:` or `magnet:` do, which a bare `https:` URL or embedded `did:` fragment would not cleanly support.
- It gives a stable place to express **resource type** (avatar, envelope, token, node) explicitly, rather than overloading path conventions on top of another scheme's semantics.

Per RFC 7595 §3.1, this is proposed initially as a **provisional** registration, appropriate for a scheme still under active development without broad deployment.

## 2. Syntax

```
sian-uri     = "sian:" sian-type ":" sian-body [ "?" query ] [ "#" fragment ]
sian-type    = "did" / "env" / "doc" / "cap" / "node"
sian-body    = *pchar   ; per RFC 3986 §3.3
```

`sian:` is treated as a **hierarchical, non-locator** scheme (RFC 7595 §3.3): the identifier is stable and meaningful independent of _where_ the resource is fetched from, since resolution mechanism varies by DID method (§1) and is never assumed from the URI alone.

## 3. Resource Types

### 3.1 `sian:did:` — Avatar identifier

Wraps a DID ([RFC-1](./rfc-1.md) §1) for use in contexts (QR codes, deep links, NFC taps) expecting a URI rather than a bare DID string.

```
sian:did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH
sian:did:web:example.org
```

### 3.2 `sian:env:` — Signed envelope reference

Addresses a specific signed envelope ([RFC-1](./rfc-1.md) §3) by content hash, not location — consistent with §2's non-locator design, since an envelope may be cached at many grid nodes simultaneously ([RFC-2](./rfc-2.md) §2).

```
sian:env:sha256-4f0c...  (envelope content-addressed by hash)
```

### 3.3 `sian:doc:` — Interest document reference

Addresses an `InterestDocument` ([RFC-3](./rfc-3.md) §1), typically referenced from within an envelope's `payload` field rather than fetched independently.

```
sian:doc:sha256-9ab1...
```

### 3.4 `sian:cap:` — Capability token

Addresses a short-lived, single-use capability token ([RFC-2](./rfc-2.md) §1) used to gate meetup-class disclosure ([RFC-4](./rfc-4.md) §3.2). Per [RFC-4](./rfc-4.md) §3, tokens of this type are inherently single-resolution — dereferencing one twice MUST fail on the second attempt.

```
sian:cap:8f3e2a91-...?exp=1735689600
```

### 3.5 `sian:node:` — Grid node reference

Addresses a specific grid node ([RFC-2](./rfc-2.md) §1) for federation/peering configuration, node-operator policy lookup, or debugging.

```
sian:node:did:web:node.example-venue.org
```

## 4. Resolution Behavior

Because `sian:` deliberately does not fix a resolution mechanism (§2), a resolver MUST branch on `sian-type` and, for `did`, on the DID method ([RFC-1](./rfc-1.md) §1.1):

| Type                | Resolution                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------ |
| `sian:did:key:...`  | Self-certifying; no network resolution needed.                                             |
| `sian:did:web:...`  | HTTPS fetch per `did:web` spec.                                                            |
| `sian:did:peer:...` | Resolved from local pairwise log only; not globally resolvable ([RFC-1](./rfc-1.md) §1.1). |
| `sian:env:...`      | Look up by content hash in local cache, then gossip network ([RFC-2](./rfc-2.md) §2).      |
| `sian:cap:...`      | Single-use resolution against the issuing node; fails if already consumed.                 |
| `sian:node:...`     | Resolved same as the node's own DID method.                                                |

A resolver that cannot resolve a given `sian-type`/method combination MUST fail closed (consistent with [RFC-1](./rfc-1.md) §2.2 and §5's fail-closed principle for unrecognized algorithms) rather than guess at a fallback mechanism.

## 5. Security Considerations

- **Correlation risk via `sian:cap:` reuse.** A capability token URI (§3.4) that is dereferenced more than once, or shared outside its intended single recipient, defeats the ephemerality property it exists for ([RFC-2](./rfc-2.md) §1, [RFC-4](./rfc-4.md) §3.2). Implementations MUST enforce single-use at the issuing node, not merely at the client.
- **`sian:did:web:` inherits HTTPS/DNS trust assumptions.** As with `did:web` generally ([RFC-1](./rfc-1.md) §1.1), a `sian:did:web:` URI is only as trustworthy as the domain's DNS and TLS chain — this scheme adds no additional guarantee beyond what `did:web` itself provides.
- **Scheme handler hijacking.** As with any custom URI scheme registered at the OS level, a malicious application could register itself as a `sian:` handler on a user's device. This is a platform-level concern outside this document's scope but SHOULD be noted in any client implementation guide.

## 6. IANA Considerations

Per RFC 7595 §7, provisional registration requires: scheme name (`sian`), status (provisional), applications/protocols using it (this document series), contact/change controller (community BCP process, [RFC-0](./rfc-0.md) §1), and a reference to this specification. No permanent registration is sought until the protocol sees broader deployment (RFC 7595 §3.1's threshold for permanent status).

## 7. Open Issues

- OI-1: Whether `sian:env:` and `sian:doc:` should be merged into a single content-addressed type, since both are hash-addressed and the distinction may not earn its keep — flagged for review alongside [RFC-3](./rfc-3.md)'s ontology governance gap.
- OI-2: Cross-platform URI handler registration conventions (Android intent filters, iOS universal links, desktop protocol handlers) are unspecified and will need a companion implementation note, not a protocol-level RFC.
