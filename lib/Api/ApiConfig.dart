class ApiConfig {
  
  static String domain = "";

  static String get baseUrl => "https://$domain";

  static String get counterSearch  => "$baseUrl/api/v1/mobile-queue/counter-search";
  static String get branchSearch   => "$baseUrl/api/v1/mobile-queue/branch-search";
  static String get callQueue      => "$baseUrl/api/v1/queue-mobile/call-queue";
  static String get updateQueue    => "$baseUrl/api/v1/queue-mobile/update-queue";
  static String get recallQueue    => "$baseUrl/api/v1/mobile-queue/recall-queue";
  static String get createQueue    => "$baseUrl/api/v1/mobile-queue/create-queue";
  static String get queueBinding   => "$baseUrl/api/v1/mobile-queue/queue-binding";
  static String get clearQueue     => "$baseUrl/api/v1/queue-mobile/mid-night";
  static String get serviceBinding => "$baseUrl/api/v1/mobile-queue/service-queue-binding";
  static String get scanqueue => "$baseUrl/en/app/kiosk/scan-queue";
}
