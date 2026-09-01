# RFC-3: Decentralized Interest Ontology and Matching

**Status:** Draft
**Category:** Standards Track
**Depends on:** [RFC-0](./rfc-0.md) (Terminology), [RFC-1](./rfc-1.md) (Envelope payload)

## Abstract

This document specifies the `InterestDocument` payload carried inside the signed envelope ([RFC-1](./rfc-1.md) §3) and the matching strategy used across devices that have no prior coordination on vocabulary.

## 1. InterestDocument Schema

```
InterestDocument {
  core_tags:      [CanonicalTag]     // from the registry, §2
  free_tags:      [string]           // uncontrolled, matched via §3 fallback
  disposition:    string | null      // short-lived, see RFC-1 §3.1
  visibility:     enum { broadcast, proximity-only, pairwise-only }
}
```

## 2. Canonical Tag Registry

A small, versioned, forkable registry of `CanonicalTag` values (e.g., `sports.basketball.pickup`, `food.lunch`, `social.travel-companion`) is maintained as a community-amendable BCP ([RFC-0](./rfc-0.md) §1), analogous to IANA protocol-parameter registries. Implementations MUST support matching on the current published core registry.

- Amendments follow the same voluntary-adoption BCP process referenced in [RFC-0](./rfc-0.md) §1: proposed, discussed, and adopted opt-in by implementers — no central authority can force an update.
- Registry entries SHOULD be hierarchical (parent/child) so partial matches (e.g., `sports.*`) are possible without exact tag agreement.

## 3. Fallback Matching for `free_tags`

Tags outside the core registry MUST NOT be silently dropped, but MUST NOT be treated as equivalent to core matches without a confidence signal:

- Devices MAY apply embedding-based similarity matching (a shared, versioned embedding model — itself a candidate for future BCP registration) to `free_tags` to produce a fuzzy match confidence score.
- Matches produced this way MUST be distinguishable to the user from exact core-tag matches (e.g., "possible match" vs. "match"), since fuzzy matching is inherently non-transparent about _why_ two avatars matched.

## 4. Security Considerations

- **Ontology poisoning**: a malicious or careless registry amendment could degrade matching quality network-wide if widely adopted. Because adoption is voluntary and versioned, implementations SHOULD pin to a specific registry version and require explicit user/operator action to adopt a new one, rather than auto-updating silently.
- **Embedding model provenance**: if fuzzy matching is used, the embedding model itself becomes a de facto coordination point ([RFC-0](./rfc-0.md) §4 risk: "any pluggable component can quietly recentralize"). Implementations SHOULD disclose which model/version produced a fuzzy match.

## 5. Open Issues

- OI-1: No governance process yet exists for registry amendments (versioning, proposal review, deprecation of tags). This likely warrants its own RFC rather than being folded in here.
- OI-2: Whether a single shared embedding model is realistic long-term, versus each implementer training their own (reintroducing the matching-failure problem this RFC exists to solve), is unresolved.