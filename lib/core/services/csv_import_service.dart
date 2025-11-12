import 'dart:io';
import 'package:csv/csv.dart';
import '../../features/passwords/data/models/password_model.dart';

class CsvImportService {
  /// Parse CSV file and return list of PasswordModel
  /// Supports common CSV formats from password managers (Chrome, Firefox, etc.)
  Future<List<PasswordModel>> parsePasswordsFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      
      // Parse CSV with different configurations to handle various formats
      List<List<dynamic>> rows;
      try {
        rows = const CsvToListConverter().convert(csvString);
      } catch (e) {
        // Try with different field delimiter
        rows = const CsvToListConverter(fieldDelimiter: ';').convert(csvString);
      }
      
      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      // First row is headers
      final headers = rows[0].map((h) => h.toString().toLowerCase().trim()).toList();
      
      // Find column indices
      final urlIndex = _findColumnIndex(headers, ['url', 'website', 'site', 'address', 'link']);
      final usernameIndex = _findColumnIndex(headers, ['username', 'user', 'login', 'email', 'account']);
      final passwordIndex = _findColumnIndex(headers, ['password', 'pass', 'pwd']);
      final titleIndex = _findColumnIndex(headers, ['title', 'name', 'service']);
      final notesIndex = _findColumnIndex(headers, ['notes', 'note', 'comment', 'description']);
      
      if (passwordIndex == -1) {
        throw Exception('Password column not found in CSV file');
      }
      
      final passwords = <PasswordModel>[];
      final now = DateTime.now();
      
      // Skip header row and process data
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        // Skip empty rows
        if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
          continue;
        }
        
        final password = row[passwordIndex].toString().trim();
        
        // Skip rows without password
        if (password.isEmpty) {
          continue;
        }
        
        // Extract data from row
        String? url;
        String? username;
        String? title;
        String? notes;
        
        if (urlIndex != -1 && urlIndex < row.length) {
          url = row[urlIndex].toString().trim();
        }
        
        if (usernameIndex != -1 && usernameIndex < row.length) {
          username = row[usernameIndex].toString().trim();
        }
        
        if (titleIndex != -1 && titleIndex < row.length) {
          title = row[titleIndex].toString().trim();
        }
        
        if (notesIndex != -1 && notesIndex < row.length) {
          notes = row[notesIndex].toString().trim();
        }
        
        // If no title, try to extract from URL
        if ((title == null || title.isEmpty) && url != null && url.isNotEmpty) {
          title = _extractTitleFromUrl(url);
        }
        
        // If still no title, use URL or generic name
        if (title == null || title.isEmpty) {
          title = url ?? 'Imported Password ${i}';
        }
        
        passwords.add(PasswordModel(
          title: title,
          username: username ?? '',
          password: password,
          website: url,
          notes: notes,
          categoryId: null, // User can categorize later
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      return passwords;
    } catch (e) {
      throw Exception('Failed to parse CSV file: $e');
    }
  }
  
  /// Find column index by checking multiple possible header names
  int _findColumnIndex(List<String> headers, List<String> possibleNames) {
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      for (final name in possibleNames) {
        if (header.contains(name)) {
          return i;
        }
      }
    }
    return -1;
  }
  
  /// Extract a readable title from URL
  String _extractTitleFromUrl(String url) {
    try {
      // Remove protocol
      String title = url.replaceFirst(RegExp(r'^https?://'), '');
      
      // Remove www.
      title = title.replaceFirst(RegExp(r'^www\.'), '');
      
      // Get domain name only (remove path and query)
      final slashIndex = title.indexOf('/');
      if (slashIndex != -1) {
        title = title.substring(0, slashIndex);
      }
      
      // Remove TLD and capitalize
      final parts = title.split('.');
      if (parts.isNotEmpty) {
        title = parts[0];
      }
      
      // Capitalize first letter
      if (title.isNotEmpty) {
        title = title[0].toUpperCase() + title.substring(1);
      }
      
      return title;
    } catch (e) {
      return url;
    }
  }
  
  /// Validate CSV file structure
  Future<bool> validateCsvFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);
      
      if (rows.isEmpty) {
        return false;
      }
      
      // Check if headers contain at least password column
      final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();
      return headers.any((h) => h.contains('password') || h.contains('pass'));
    } catch (e) {
      return false;
    }
  }
}
