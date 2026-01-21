class ApiConstants {
  // Change this to your actual server IP or Domain
  static const String baseUrl = 'https://node.jnanagni.in/api/v1'; 

  static const String login = '/auth/login';
  static const String me = '/auth/me';
  
  // Dashboard Stats
  static const String stats = '/admin/stats/overview';
  
  // Events (Crucial Fix: Use 'my-events' to get role-specific data)
  static const String myEvents = '/admin/my-events'; 
  
  // Users & Scanning
  static const String scanUser = '/users/scan'; // Appends /:jnanagniId
  static const String allUsers = '/users/all/users';
  static const String pendingPayments = '/users/payments/pending';
}