import 'package:flutter/material.dart';

/// نوع الانيميشن المستخدم في الانتقالات
enum TransitionType {
  /// fade + slide من الأسفل لفوق (الافتراضي)
  fadeSlideUp,

  /// fade + slide من اليمين لليسار
  fadeSlideRight,

  /// fade فقط بدون slide
  fade,

  /// slide من الأسفل (مثل bottom sheet)
  slideUp,
}

/// Route مخصص بانيميشن سموز عالي الأداء
class SmoothRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType type;

  SmoothRoute({
    required this.page,
    this.type = TransitionType.fadeSlideUp,
    super.settings,
    bool fullscreenDialog = false,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: const Duration(milliseconds: 380),
         reverseTransitionDuration: const Duration(milliseconds: 320),
         fullscreenDialog: fullscreenDialog,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final primary = _buildTransition(
             type: type,
             animation: animation,
             secondaryAnimation: secondaryAnimation,
             child: child,
           );
           
           // secondary page transition (the page UNDERNEATH the pushed page)
           // scales down slightly and fades out to give a premium 3D layered feel
           final secondaryCurved = CurvedAnimation(
             parent: secondaryAnimation,
             curve: const Cubic(0.16, 1.0, 0.3, 1.0), // easeOutExpo
             reverseCurve: const Cubic(0.9, 0.05, 0.95, 0.5),
           );
           
           return ScaleTransition(
             scale: Tween<double>(begin: 1.0, end: 0.96).animate(secondaryCurved),
             child: FadeTransition(
               opacity: Tween<double>(begin: 1.0, end: 0.65).animate(secondaryCurved),
               child: primary,
             ),
           );
         },
       );

  static Widget _buildTransition({
    required TransitionType type,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    // Premium spring-like easeOutExpo curve
    final curved = CurvedAnimation(
      parent: animation,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0), // easeOutExpo
      reverseCurve: const Cubic(0.9, 0.05, 0.95, 0.5),
    );

    switch (type) {
      case TransitionType.fadeSlideUp:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );

      case TransitionType.fadeSlideRight:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );

      case TransitionType.fade:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
    }
  }
}

/// Route للانتقالات التي تحتاج BlocProvider.value
class SmoothBlocRoute<T> extends SmoothRoute<T> {
  SmoothBlocRoute({
    required super.page,
    super.type = TransitionType.fadeSlideUp,
    super.settings,
  });
}
