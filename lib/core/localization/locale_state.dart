part of 'locale_cubit.dart';

@immutable
class LocaleState {
  final Locale locale;
  final bool isLoading;

  const LocaleState(this.locale, {this.isLoading = false});

  LocaleState copyWith({Locale? locale, bool? isLoading}) {
    return LocaleState(
      locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
