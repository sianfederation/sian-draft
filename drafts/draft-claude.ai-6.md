<!-- markdownlint-disable MD041 MD033 -->
<img src="../images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-6: The Reveal Ladder — Progressive Disclosure Between Avatars

**Status:** AI-Generated Draft
**Category:** Standards Track
**Depends on:** [RFC-1](./draft-claude.ai-1.md) (Identity tiers, Envelopes), [RFC-2](./draft-claude.ai-2.md) (Proximity, Capability tokens), [RFC-3](./draft-claude.ai-3.md) (Interest matching), [RFC-4](./draft-claude.ai-4.md) (§3.2 Graduated disclosure — this document is its concrete instantiation)

## Abstract

[RFC-4](./draft-claude.ai-4.md) §3.2 requires graduated disclosure for meetup-class actions but leaves the concrete rungs unspecified. This document defines a specific eight-rung reveal ladder (R0–R7) between two avatars, the identity-tier and cost requirements gating advancement, and the rules governing skipping, reversal, and mutual consent.

## 1. The Ladder

| Rung | Disclosure                                                                   | Minimum identity tier ([RFC-1](./draft-claude.ai-1.md) §1.2) | Requires mutual consent?                 |
| ---- | ---------------------------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------- |
| R0   | Anonymous opportunity (ambient broadcast visibility, [RFC-2](./draft-claude.ai-2.md) §1) | None                                             | No — passive                             |
| R1   | Pseudonymous avatar (DID exchanged)                                          | `did:key`                                        | No — one-directional, automatic on match |
| R2a  | Shared interests (ordinary interest-doc match, [RFC-3](./draft-claude.ai-3.md))          | `did:key`                                        | No — automatic on match                  |
| R2b  | Stated relational/dating intent                                              | `did:key`, flagged low-trust (§3)                | **Yes**                                  |
| R3   | Relative proximity between the two matched avatars                           | `did:key`                                        | **Yes**                                  |
| R4   | Direct encrypted communication channel                                       | `did:peer` or higher (§3)                        | **Yes**                                  |
| R5   | First name / chosen personal information                                     | `did:peer` or higher                             | **Yes**                                  |
| R6   | External contact method (phone, email, social handle)                        | `did:peer` or higher                             | **Yes**                                  |
| R7   | Real-world identity                                                          | Any — entirely voluntary                         | **Yes**, explicit, per-instance          |

### 1.1 R2 split (per design note above)

R2 is split into **R2a** (ordinary interest overlap — low-stakes, matches [RFC-3](./draft-claude.ai-3.md)'s core matching function, may reasonably be automatic since it reveals no more than "our tags overlap") and **R2b** (explicit relational or dating intent — a materially bigger disclosure that signals availability for romantic/sexual contact and MUST require explicit mutual consent, not just a match threshold).

## 2. State Machine Semantics

### 2.1 Directionality and mutuality

Rungs R0–R2a are **match-triggered and automatic** — they reveal only aggregate/categorical information, not enough to identify or locate a specific person, and require no explicit action.

Rungs R2b–R7 are **consent-gated per pair**: advancing requires an explicit grant from _both_ avatars for _that specific rung, with that specific counterpart_. Consent to R4 does not imply consent to R5; each rung is independently grantable.

### 2.2 Skipping

Rungs MAY be skipped in either direction if both avatars consent — e.g., two avatars may jump directly from R2b to R6 (external contact) without ever completing R4/R5, if both explicitly agree. Implementations MUST NOT silently skip a rung on behalf of a user; skipping requires the same explicit consent as sequential advancement.

### 2.3 Reversal and revocation

Any previously granted rung MAY be unilaterally revoked by either party at any time. Revocation of rung _N_ SHOULD prompt (but not force) revocation of all rungs above _N_, since higher rungs typically presuppose the trust established at lower ones — but this document does not mandate cascading revocation, since a user may reasonably wish to retain, e.g., R6 (contact method already exchanged) while revoking R3 (no longer wanting to share live proximity). Implementations SHOULD surface this choice explicitly rather than assuming cascade behavior.

### 2.4 Identity-tier step-up enforcement

Per [RFC-4](./draft-claude.ai-4.md) §1's action-class table, an avatar attempting to advance past R3 while still on a `did:key` identity SHOULD trigger the step-up flow defined in [RFC-4](./draft-claude.ai-4.md) §3.2 (prompt to upgrade to `did:peer`/`did:web`, or accept a posted bond as an alternative per [RFC-4](./draft-claude.ai-4.md) §2.3) before the receiving avatar's client permits the grant.

### 2.5 Continuity across DID migration

If an avatar migrates DIDs mid-relationship ([RFC-1](./draft-claude.ai-1.md) §6.2), the granted-rung state for that pairwise relationship SHOULD carry forward under the same Migration Statement mechanism and cost constraints as reputation ([RFC-4](./draft-claude.ai-4.md) §3.4) — a migration MUST NOT be usable to silently re-request a rung that was previously revoked by the counterpart, since that would let migration function as a consent-reset exploit.

## 3. Security and Safety Considerations

- **R2b as a safety-sensitive rung.** Stated dating/relational intent is exactly the kind of disclosure the original proposal's safety warning ([RFC-0](./draft-claude.ai-0.md) §5) was concerned with — it signals availability in a way that can attract predatory behavior. Implementations SHOULD apply the same or stricter scrutiny to R2b as to meetup-class actions generally ([RFC-4](./draft-claude.ai-4.md) §1), even though R2b alone does not yet disclose location or contact info.
- **R3 (relative proximity) is more sensitive than R0's node-level presence.** Revealing that two _specific_ avatars are near each other is a meaningful narrowing of anonymity compared to "someone is near this venue" — this rung SHOULD NOT be grantable without at least R1 having occurred (i.e., proximity is never revealed between avatars that haven't exchanged identifiers at all).
- **Consent fatigue.** An eight-rung, per-pair consent model risks users reflexively approving every prompt. Implementations SHOULD consider batching or pre-authorizing rungs up to a user-chosen ceiling (e.g., "always auto-grant up to R3 for anyone I've matched with") while still requiring fresh, explicit consent for anything at or above R4.
- **No rung retroactively erases disclosure.** As with any information-sharing system, revoking a rung (§2.3) stops _future_ disclosure but cannot un-disclose information already received by the counterpart (e.g., a first name already read, per R5). This limitation SHOULD be disclosed to users plainly before they grant a rung, not just at revocation time.

## 4. Relationship to RFC-4

This document supersedes the placeholder language in [RFC-4 ](./draft-claude.ai-4.md)§3.2 ("coarse information only... precise location/time disclosed only after mutual, explicit opt-in") with the concrete R0–R7 ladder above. [RFC-4](./draft-claude.ai-4.md) §3.2 SHOULD be amended to reference this document directly rather than describing graduated disclosure in the abstract.

## 5. Open Issues

- OI-1: Whether R2b should have its own distinct cost-of-action requirement ([RFC-4](./draft-claude.ai-4.md) §2) beyond identity-tier flagging, given its safety sensitivity, is unresolved.
- OI-2: Cascading revocation (§2.3) is left as an implementation choice rather than specified behavior; this may need to be revisited if inconsistent behavior across clients causes confusion about what a counterpart can still see after a partial revocation.
- OI-3: Whether R7 (real-world identity) should have any protocol-level structure at all, or remain deliberately unspecified as "whatever the two parties agree to do outside the system," is unresolved — currently leaning toward the latter, since standardizing real-identity exchange arguably falls outside this protocol's scope entirely.