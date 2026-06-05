class DebounceGate {
  bool _isProcessing = false;

  bool get canProceed => !_isProcessing;

  void lock() {
    _isProcessing = true;
  }

  void unlock() {
    _isProcessing = false;
  }

  void reset() {
    _isProcessing = false;
  }
}
