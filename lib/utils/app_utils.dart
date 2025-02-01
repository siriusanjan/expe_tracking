
import 'package:intl/intl.dart';
class AppUtils {
 static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }
 static String capitalizeFirstLetter(String text) {
   if (text.isEmpty) return text;
   return text[0].toUpperCase() + text.substring(1).toLowerCase();
 }
 // Function to format DateTime

 static String formatDate(DateTime date) {
   final now = DateTime.now();
   final difference = now.difference(date).inDays;

   if (difference == 0) {
     // Today
     return "Today ${DateFormat('HH:mm').format(date)}";
   } else if (difference == 1) {
     // Yesterday
     return "Yesterday ${DateFormat('HH:mm').format(date)}";
   } else if (difference <= 10) {
     // Last 10 days
     return "${difference} days ago";
   } else {
     // Default format for older dates
     return DateFormat("dd/MM/yyyy HH:mm").format(date);
   }
 }

}
