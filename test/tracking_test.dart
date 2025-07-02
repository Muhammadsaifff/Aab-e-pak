import 'package:flutter_test/flutter_test.dart';
import 'package:aab_e_pak/services/order_service.dart';

void main() {
  group('Live Tracking Tests', () {
    test('should identify trackable services correctly', () {
      // Test trackable services
      expect(OrderService.isTrackableService('Tanker'), true);
      expect(OrderService.isTrackableService('Bottled Water'), true);
      
      // Test non-trackable services
      expect(OrderService.isTrackableService('Boring'), false);
      expect(OrderService.isTrackableService('Tank Cleaning'), false);
      
      // Test edge cases
      expect(OrderService.isTrackableService(null), false);
      expect(OrderService.isTrackableService(''), false);
      expect(OrderService.isTrackableService('Unknown Service'), false);
    });

    test('should handle case sensitivity', () {
      expect(OrderService.isTrackableService('tanker'), false); // Case sensitive
      expect(OrderService.isTrackableService('TANKER'), false); // Case sensitive
      expect(OrderService.isTrackableService('bottled water'), false); // Case sensitive
    });
  });
}
