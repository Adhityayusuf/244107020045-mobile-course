import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State UI terkait push untuk halaman Home. Di produksi diisi dari
/// [PushService] + listener FCM; di demo screenshot di-seed deterministik.
class PushUiState {
  const PushUiState({
    this.tokenPreviewText = '-',
    this.permissionGranted = false,
    this.topicSubscribed = false,
    this.bannerKind,
    this.bannerTitle = '',
    this.bannerBody = '',
    this.openedViaNotification = false,
  });

  /// Token terpotong (12 karakter + ...). Token penuh tidak pernah ke UI.
  final String tokenPreviewText;
  final bool permissionGranted;
  final bool topicSubscribed;

  /// null | 'local' (banner manual foreground) | 'system' (banner sistem
  /// background). Khusus demo deterministik.
  final String? bannerKind;
  final String bannerTitle;
  final String bannerBody;

  /// Penanda alur terminated: aplikasi dibuka dari klik notifikasi.
  final bool openedViaNotification;
}

class PushUiNotifier extends Notifier<PushUiState> {
  @override
  PushUiState build() => const PushUiState();

  void seed(PushUiState value) => state = value;
}

final pushUiProvider = NotifierProvider<PushUiNotifier, PushUiState>(
  PushUiNotifier.new,
);
