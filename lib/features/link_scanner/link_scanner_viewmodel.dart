import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/services/link_heuristics_service.dart';

class LinkScanState {
  final bool isLoading;
  final LinkRiskResult? heuristicResult;
  final String? aiExplanation;
  final String? error;

  const LinkScanState({this.isLoading = false, this.heuristicResult, this.aiExplanation, this.error});

  LinkScanState copyWith({
    bool? isLoading,
    LinkRiskResult? heuristicResult,
    String? aiExplanation,
    String? error,
  }) {
    return LinkScanState(
      isLoading: isLoading ?? this.isLoading,
      heuristicResult: heuristicResult ?? this.heuristicResult,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      error: error,
    );
  }
}

class LinkScanViewModel extends StateNotifier<LinkScanState> {
  LinkScanViewModel(this._ref) : super(const LinkScanState());
  final Ref _ref;

  Future<void> scan(String url) async {
    if (url.trim().isEmpty) return;
    state = const LinkScanState(isLoading: true);

    // 1. Instant local heuristic result (always works, even offline).
    final heuristics = _ref.read(linkHeuristicsProvider).analyze(url.trim());
    state = state.copyWith(isLoading: true, heuristicResult: heuristics);

    // 2. Enrich with AI narrative explanation via secure backend proxy.
    try {
      final auth = _ref.read(authRepositoryProvider);
      final token = await auth.getIdToken();
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Please sign in to get the full AI explanation.');
        return;
      }
      final explanation = await _ref.read(aiServiceProvider).explainLinkRisk(
            url: url.trim(),
            userIdToken: token,
          );
      state = state.copyWith(isLoading: false, aiExplanation: explanation);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final linkScanViewModelProvider =
    StateNotifierProvider.autoDispose<LinkScanViewModel, LinkScanState>((ref) => LinkScanViewModel(ref));
