class AppConstants {
  static const String appName = 'Faso Covoiturage';
  static const String apiBaseUrl = 'http://localhost:3000/v1';
  static const int apiTimeout = 30000;
  static const int pageSize = 20;
  static const String firebaseProjectId = 'soore-covoiturage';
  static const String firebaseStorageBucket = 'soore-covoiturage.firebasestorage.app';
  
  // Roles
  static const String rolePassenger = 'passenger';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';
  static const String roleAgentRelay = 'agent_relay';
  
  // Booking statuses
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';
  
  // Payment methods
  static const String paymentOrangeMoney = 'orange_money';
  static const String paymentMoovMoney = 'moov_money';
  static const String paymentWave = 'wave';
  static const String paymentCash = 'cash';
}