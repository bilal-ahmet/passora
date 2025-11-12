import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/passwords/data/models/password_model.dart';
import '../../features/categories/data/models/category_model.dart';

class PasswordCard extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onTap;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final CategoryModel? category;

  const PasswordCard({
    super.key,
    required this.password,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForTitle(password.title),
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          password.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          password.username,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _parseColor(category!.color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category!.icon,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category!.name,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _parseColor(category!.color),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // More options
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      print('PopupMenu selected: $value');
                      try {
                        switch (value) {
                          case 'copy':
                            _copyToClipboard(context);
                            break;
                          case 'edit':
                            print('Calling onEdit from popup menu...');
                            await onEdit();
                            print('onEdit completed from popup menu');
                            break;
                          case 'delete':
                            print('Calling onDelete from popup menu...');
                            await onDelete();
                            print('onDelete completed from popup menu');
                            break;
                        }
                      } catch (e) {
                        print('Error in popup menu callback: $e');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Copy Password'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ],
              ),
              
              // Website if available
              if (password.website != null && password.website!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  password.website!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Last updated
              const SizedBox(height: 8),
              Text(
                'Updated ${_formatDate(password.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    print('=== PASSWORD CARD COPY START ===');
    print('Password to copy: "${password.password}"');
    print('Password length: ${password.password.length}');
    
    try {
      Clipboard.setData(ClipboardData(text: password.password)).then((_) {
        print('Password card: Clipboard.setData completed');
        
        // Verify immediately
        Clipboard.getData(Clipboard.kTextPlain).then((clipData) {
          final readText = clipData?.text ?? '';
          print('Password card: Read back: "$readText"');
          print('Password card: Verification: ${readText == password.password}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(readText == password.password 
                ? 'Password copied to clipboard' 
                : 'Copy failed - verification mismatch'),
              duration: const Duration(seconds: 3),
              backgroundColor: readText == password.password ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          if (readText == password.password) {
            HapticFeedback.lightImpact();
          }
        }).catchError((e) {
          print('Password card: Read back failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copy completed but verification failed'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
        
      }).catchError((e) {
        print('Password card: setData failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copy failed: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } catch (e) {
      print('Password card: Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    print('=== PASSWORD CARD COPY END ===');
  }

  IconData _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('facebook') || lowerTitle.contains('social')) {
      return Icons.facebook;
    } else if (lowerTitle.contains('google') || lowerTitle.contains('gmail')) {
      return Icons.email;
    } else if (lowerTitle.contains('bank') || lowerTitle.contains('financial')) {
      return Icons.account_balance;
    } else if (lowerTitle.contains('netflix') || lowerTitle.contains('youtube')) {
      return Icons.play_circle_outline;
    } else if (lowerTitle.contains('amazon') || lowerTitle.contains('shop')) {
      return Icons.shopping_cart;
    } else if (lowerTitle.contains('work') || lowerTitle.contains('office')) {
      return Icons.work;
    } else {
      return Icons.lock;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}