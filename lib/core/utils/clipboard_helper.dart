import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ClipboardHelper {
  static Future<bool> copyToClipboard(String text) async {
    try {
      print('ClipboardHelper: Attempting to copy: "$text"');
      
      if (text.isEmpty) {
        print('ClipboardHelper: Text is empty, skipping copy');
        return false;
      }
      
      // Multiple attempts with different approaches
      bool success = false;
      
      // Attempt 1: Direct copy
      try {
        await Clipboard.setData(ClipboardData(text: text));
        success = await _verifyClipboard(text);
        if (success) {
          print('ClipboardHelper: Direct copy successful');
          return true;
        }
      } catch (e) {
        print('ClipboardHelper: Direct copy failed: $e');
      }
      
      // Attempt 2: Clear first, then copy
      try {
        await Clipboard.setData(const ClipboardData(text: ''));
        await Future.delayed(const Duration(milliseconds: 50));
        await Clipboard.setData(ClipboardData(text: text));
        success = await _verifyClipboard(text);
        if (success) {
          print('ClipboardHelper: Clear-then-copy successful');
          return true;
        }
      } catch (e) {
        print('ClipboardHelper: Clear-then-copy failed: $e');
      }
      
      // Attempt 3: Multiple retries
      for (int i = 0; i < 3; i++) {
        try {
          await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
          await Clipboard.setData(ClipboardData(text: text));
          success = await _verifyClipboard(text);
          if (success) {
            print('ClipboardHelper: Retry $i successful');
            return true;
          }
        } catch (e) {
          print('ClipboardHelper: Retry $i failed: $e');
        }
      }
      
      print('ClipboardHelper: All attempts failed');
      return false;
      
    } catch (e) {
      print('ClipboardHelper: Critical error: $e');
      return false;
    }
  }
  
  static Future<bool> _verifyClipboard(String expectedText) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final actualText = clipboardData?.text ?? '';
      
      final success = actualText == expectedText;
      print('ClipboardHelper: Verification - Expected: "$expectedText", Got: "$actualText", Success: $success');
      
      return success;
    } catch (e) {
      print('ClipboardHelper: Verification failed: $e');
      return false;
    }
  }
  
  static void showCopyResult(BuildContext context, bool success, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? message : 'Failed to copy - please try again'),
        duration: const Duration(seconds: 2),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    if (success) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}