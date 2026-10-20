<!-- markdownlint-disable MD041 MD033 -->
<img src="./images/sian.svg" alt="SIÂN" style="float: right; margin: 10px;">

# SIAN-RFC 0: Federated Interest-driven, Avatar-based Social Network

**Status:** N/A
**Category:** Informational
**Author**: Johan Segerfeldt
**Date Published**: Sept 8 2026

## Summary

Based on the IETF practice of [RFCs](https://en.wikipedia.org/wiki/Request_for_Comments) — and perhaps later adding [BCPs](https://en.wikipedia.org/wiki/Best_Current_Practice) — this document proposes a distributed/federated system for socially connecting users in a pseudonymous fashion based on interests and proximity.

The infrastructure is a network of bulletin boards, each moderated independently by sovereign stewardship. Bulletins are posted on the boards and spread from one to another by geographic proximity. Mobile devices (owned by end users) access bulletins as they move about town.

Users of the system are identified by pseudonymous avatars and may form connections to other users through theirs.

> [!warning]
>
> Anonymity in social contexts can be dangerous. Individuals might feel free to issue threats, or might arrange IRL meetings where they can commit violence. Safeguards will have to be taken to avoid — or at the very least mitigate — abuse.

### Terminology in this Document

- **Venue**: A physical location, a building, a field a city square…
- **Establishment**: a legal or communal entity that might be the steward of a venue or disconnected from all venues.
- **Grid-Node**: A physical device that operates as the technical infrastructure of Siân.
- **Bulletin Board**: A list/database of information stored on a grid-node.
- **Avatar**: A pseudonymous representation of a flesh-and-blood user. Primarily a graphical rendering attached to a (perhaps fanciful) name. But it may also expose select personal information such as interests and friends.

## Proposition

A user is identified through an avatar, a character that represents a subset of their general interests and social connections, as well as their current disposition.

The social network is established avtar-to-avatar, not user-to-user, thereby creating a form of anonymity (or “pseudonymity”). Users can create multiple avatars (representing different interests and friendships, and exposing different personality quirks) that they can selectively use in various contexts.

A local venue (an office, a store, a restaurant, a sports facility…) — or a collective of multiple venues in the same vicinity — may put up a “grid node.” This node is a sort of digital / wireless bulletin board. When a user approaches the node with a wireless device, the postings on that board are transferred to the device. The device can then use this information to tell the user about local activities. The information can also be stored on the device to be accessed later — at other locations — when the user’s disposition might have changed.

The user decides what information they find important. If they are actively looking for a specific activity (e.g. lunch), information that relates directly to that might be prioritised. Information that originates a long distance away, might be ignored by one user, but important to another.

The bulletin board might contain information about the static venues in its area, but also activities that occur at that very moment, such as a basketball team looking for opponents in a friendly game or a user wanting a buddy to accompany them on a trip.

The grid node will be connected to other grid nodes — probably via existing infrastructure such as the internet. This can allow information to traverse long distances. An establishment (a company, a government agency, a sports association, an interest association…) might advertise their existence or a social event on their local grid node/bulletin board, and have it spread from there to all boards within a specified radius or named region.

The information should probably be time limited and/or volume limited so that it does not grow stale, but more importantly: so it doesn't require each grid node to maintain an entire internet's worth of data indefinitely.
