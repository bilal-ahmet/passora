import 'package:flutter/material.dart';
import '../../features/passwords/data/models/password_model.dart';
import '../../features/categories/data/models/category_model.dart';
import 'password_card.dart';

/// Demo page to showcase the pixel-perfect Password Card design
/// Run this page to see the glassmorphism and gradient effects
class PasswordCardDemo extends StatelessWidget {
  const PasswordCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0529), // Dark purple background
      appBar: AppBar(
        title: const Text('Password Card Design Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0529),
              const Color(0xFF1A1547),
              const Color(0xFF2A2567),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Card 1: Banking (Pink/Purple gradient)
            PasswordCard(
              password: PasswordModel(
                title: 'enpara bankası',
                username: 'enpara bankası',
                password: 'demo123',
                createdAt: DateTime(2025, 11, 28),
                updatedAt: DateTime(2025, 11, 28),
                isFavorite: true,
              ),
              category: CategoryModel(
                name: 'Banking',
                icon: 'account_balance',
                color: '#E91E8C', // Pink
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
              onEdit: () async {},
              onDelete: () async {},
              onToggleFavorite: () async {},
            ),

            const SizedBox(height: 8),

            // Card 2: Banking (Green/Teal gradient)
            PasswordCard(
              password: PasswordModel(
                title: 'Kuveyt Türk bankası',
                username: 'kuveyttürk bankası',
                password: 'demo456',
                createdAt: DateTime(2025, 11, 28),
                updatedAt: DateTime(2025, 11, 28),
                isFavorite: true,
              ),
              category: CategoryModel(
                name: 'Banking',
                icon: 'account_balance',
                color: '#00BFA6', // Teal
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
              onEdit: () async {},
              onDelete: () async {},
              onToggleFavorite: () async {},
            ),

            const SizedBox(height: 8),

            // Card 3: Banking (Blue gradient)
            PasswordCard(
              password: PasswordModel(
                title: 'yapı kredi bankası',
                username: 'yapıkredi bankası',
                password: 'demo789',
                createdAt: DateTime(2025, 11, 28),
                updatedAt: DateTime(2025, 11, 28),
                isFavorite: true,
              ),
              category: CategoryModel(
                name: 'Banking',
                icon: 'account_balance',
                color: '#2196F3', // Blue
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
              onEdit: () async {},
              onDelete: () async {},
              onToggleFavorite: () async {},
            ),

            const SizedBox(height: 8),

            // Card 4: Social Media (Purple)
            PasswordCard(
              password: PasswordModel(
                title: 'Facebook',
                username: 'user@email.com',
                password: 'demo321',
                createdAt: DateTime(2025, 11, 28),
                updatedAt: DateTime(2025, 11, 28),
                isFavorite: false,
              ),
              category: CategoryModel(
                name: 'Social',
                icon: 'favorite',
                color: '#9C27B0', // Purple
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
              onEdit: () async {},
              onDelete: () async {},
              onToggleFavorite: () async {},
            ),

            const SizedBox(height: 8),

            // Card 5: Streaming (Orange)
            PasswordCard(
              password: PasswordModel(
                title: 'Netflix',
                username: 'myemail@domain.com',
                password: 'demo654',
                createdAt: DateTime(2025, 11, 28),
                updatedAt: DateTime(2025, 11, 28),
                isFavorite: true,
              ),
              category: CategoryModel(
                name: 'Entertainment',
                icon: 'movie',
                color: '#FF5722', // Deep Orange
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onTap: () {},
              onEdit: () async {},
              onDelete: () async {},
              onToggleFavorite: () async {},
            ),
          ],
        ),
      ),
    );
  }
}
