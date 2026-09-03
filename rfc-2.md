<!-- markdownlint-disable MD041 MD033 -->
<img src="./images/sian.svg" alt="Rawry" style="float: right; margin: 10px;">

# RFC-2: Process for Additions and Amendments

**Status:** Inception
**Category:** Governance
**Author**: Johan Segerfeldt
**Date Published**: Sep 3 2026

## Abstract

We need to define a process for adding new RFCs (replace this RFC with the draft).

We will need well-defined categories. Should e.g. this RFC be sorted under governance? Normative? It defines the rules of the RFC stack itself, not the system described by the RFCs. Those tracks should probably be separated. (Maybe the entire stack can be said to be defining the rules of the system? If so, that would be an “everything” category and redundant.)

Can an RFC be tagged with multiple categorizations or are categories non-overlapping sets?

How is an RFC added? Can anyone add a new RFC or does it have to go through a vetting process first? What process does the IETF use?

Is this RFC stack redundant? Should we go directly to the IETF RFC Editor instead? Or is it useful to have two separate stacks? Maybe an RFC in this stack can say “publish RFC-X on IETF,” or “propose this change to IETF RFC-Y”?

Based on the description by Claude.ai ([below](#according-to-claudeai)), maybe we should allow adding draft entries without RFC numbers by PR? (The AI-generated RFCs now follow the pattern `draft-submitter-index-md`.) How they are later converted to RFCs is a question for the community (which does not exist yet).

## According to Claude.ai

The IETF process is more involved than "write it and submit it" — there's a distinction between publishing a draft and getting an actual RFC number.

**Internet-Drafts (I-Ds): open to anyone**

Anyone can write and submit an Internet-Draft. You format it per the required template, submit it through the IETF's Datatracker, and it gets published as a `draft-yourname-topic-00.txt` (or similar). No approval needed — this is explicitly open. Drafts expire after 6 months unless resubmitted, and they carry a disclaimer that they're not standards.

**Getting from draft to RFC is a different story**

This is where the gatekeeping happens. The main paths:

1. **Working Group path** (most common for standards-track RFCs): You bring your draft to a relevant IETF Working Group (or propose one via a BOF). The WG has to adopt it (`draft-ietf-wgname-topic`), iterate on it through WG consensus, and eventually the WG chairs shepherd it to IESG review. The Area Director sponsors it, there's IETF Last Call (open comment period), then IESG approval.

2. **Independent Submission stream**: If your work doesn't fit an existing WG's charter, or you want to publish something the IETF community isn't actively producing consensus on, you can submit to the RFC Editor's **Independent Submission** stream. This goes through the Independent Submissions Editor (ISE) and independent review — not IETF consensus, but still real editorial and technical review (including an IESG conflict-review to check it doesn't contradict IETF work). This is how a lot of "for your information" or experimental proposals become RFCs without needing a WG.

3. **IRTF stream**: Research-oriented work from IRTF research groups.

4. **IAB stream**: Architecture-related documents from the IAB itself.

So no — you can't just upload a draft to the RFC Editor and have it become an RFC. The RFC Editor's role is editorial/publication, not gatekeeping adoption; the actual "should this become an RFC" decision happens upstream (WG consensus + IESG, or ISE review for independent submissions). Every stream requires some form of review beyond just the author's say-so, though the bar and process differ a lot between "IETF consensus standard" and "independently reviewed informational RFC."

Given the RFC series you've been drafting for the pseudonymous social network project, the **Independent Submission stream** is probably the most realistic real-world path if you ever wanted actual RFC numbers rather than just using the format for internal rigor — since there's no existing IETF WG chartered for this specific problem space, and starting one (BOF → charter → WG) is a much heavier lift than most independent projects take on.