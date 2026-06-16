| GE-20260521-e39ad1 | CommitmentStore.findOpenByObligor(sender) finds nothing for COMMAND messages — sender is stored as requester, not obligor | gotcha | 10/15 |
| GE-20260607-d051f2 | MessageObserver.onMessage() receives null content for EVENT type — MessageObserverDispatcher forces content=null per PP-20260508-90428f | gotcha | 14/15 |
| GE-20260607-d051f2 | MessageObserver.onMessage() receives null content for EVENT type — MessageObserverDispatcher forces content=null per PP-20260508-90428f | gotcha | 14/15 |
| GE-20260607-a4d78a | ChannelSlugValidator rejects dot-notation channel names — use hyphens instead | gotcha | 13/15 |
| GE-20260607-58c683 | Shared-list constructor injection for CDI-free unit tests where two stubs must share state | technique | 10/15 |
| GE-20260608-757be3 | Qhorus MessageDispatch.artefactRefs silently rejects non-UUID content at dispatch time | gotcha | 8/15 |
| GE-20260607-a4d78a | ChannelSlugValidator: channel path segments must start with a letter and use only hyphens — dots and digit-leading UUIDs both fail | gotcha | 13/15 |
| GE-20260613-7b7ae1 | casehub-qhorus ChannelService.create() removed 9-arg String allowedTypes overload — now requires ChannelCreateRequest with Set<MessageType> | gotcha | 9/15 |
| GE-20260616-8a07b1 | ChannelService.setTypeConstraints() normalizes null to Set.of() — lossy round-trip for empty allowed/denied types | gotcha | 8/15 |
