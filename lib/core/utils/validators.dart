import '../constants/app_strings.dart';

class Validators {
  Validators._();

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.errorInvalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    if (value.length < 6) {
      return AppStrings.errorWeakPassword;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    if (value != password) {
      return AppStrings.errorPasswordMismatch;
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    
    return null;
  }
}

