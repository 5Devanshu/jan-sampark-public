// Corporator announcements reuse the Leader provider entirely.
// The backend auto-scopes by the caller's area_id.
export '../../../leader/announcements/providers/leader_announcement_provider.dart'
    show
        createAnnouncementProvider,
        CreateAnnouncementState,
        CreateAnnouncementNotifier,
        announcementListProvider,
        announcementDetailProvider;