// 06_FRONTEND/lib/providers/habit_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class HabitState {
  final String habitId;
  final String title;
  final int currentStreak;
  final int longestStreak;
  final bool isLoading;

  HabitState({
    required this.habitId,
    required this.title,
    required this.currentStreak,
    required this.longestStreak,
    required this.isLoading,
  });

  HabitState copyWith({
    String? habitId,
    String? title,
    int? currentStreak,
    int? longestStreak,
    bool? isLoading,
  }) {
    return HabitState(
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  HabitNotifier()
      : super(HabitState(
          habitId: 'HABIT-001-ALPHA',
          title: 'Deep Work Focus Streak',
          currentStreak: 5,
          longest_streak: 12,
          isLoading: false,
        ));

  Future<void> incrementStreak() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse('https://api.lifestreak.max-sim.internal/habits/increment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'habitId': state.habitId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCurrent = data['currentStreak'] as int;
        final newLongest = data['longestStreak'] as int;

        state = state.copyWith(
          currentStreak: newCurrent,
          longest_streak: newLongest,
          isLoading: false,
        );
      } else {
        // Fallback local optimistic update if edge offline
        state = state.copyWith(
          currentStreak: state.currentStreak + 1,
          isLoading: false,
        );
      }
    } catch (_) {
      // Offline fallback state update
      state = state.copyWith(
        currentStreak: state.currentStreak + 1,
        isLoading: false,
      );
    }
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  return HabitNotifier();
});
