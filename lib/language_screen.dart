import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');
    final savedLocale = prefs.getString('selectedLocale');

    final nextLanguage = savedLanguage ??
        _languageFromLocale(savedLocale ?? 'en_US');

    if (mounted) {
      setState(() {
        selectedLanguage = nextLanguage;
      });
    }
  }

  Future<void> _saveSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    await saveLocaleFromLanguage(language);

    if (!mounted) return;

    setState(() {
      selectedLanguage = language;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$language selected'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _languageFromLocale(String localeKey) {
    switch (localeKey.toLowerCase()) {
      case 'en_us':
      case 'en':
        return 'English';
      case 'ta_in':
      case 'ta':
        return 'Tamil';
      case 'hi_in':
      case 'hi':
        return 'Hindi';
      case 'ml_in':
      case 'ml':
        return 'Malayalam';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _LanguageOptionTile(
            label: 'English',
            isSelected: selectedLanguage == 'English',
            onTap: () => _saveSelectedLanguage('English'),
          ),
          _LanguageOptionTile(
            label: 'Tamil',
            isSelected: selectedLanguage == 'Tamil',
            onTap: () => _saveSelectedLanguage('Tamil'),
          ),
          _LanguageOptionTile(
            label: 'Hindi',
            isSelected: selectedLanguage == 'Hindi',
            onTap: () => _saveSelectedLanguage('Hindi'),
          ),
          _LanguageOptionTile(
            label: 'Malayalam',
            isSelected: selectedLanguage == 'Malayalam',
            onTap: () => _saveSelectedLanguage('Malayalam'),
          ),
        ],
      ),
    );
  }
}