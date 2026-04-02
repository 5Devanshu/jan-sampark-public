/// Form field validators for Jan Sampark.
///
/// All validators follow Flutter's FormField pattern:
/// return null for valid, return error string for invalid.
///
/// Usage:
///   TextFormField(validator: Validators.mobile)
class Validators {
  Validators._();

  // Mobile
  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'^(\+91|91)'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid 10-digit Indian mobile number.';
    }
    return null;
  }

  // OTP
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required.';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter the 6-digit OTP.';
    }
    return null;
  }

  // Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain a digit.';
    }
    if (!RegExp(r"[!@#\$%^&*()_+\-=\[\]{};':\\|,.<>\/?]")
        .hasMatch(value)) {
      return 'Password must contain a special character.';
    }
    return null;
  }

  // Required text fields
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required.';
      }
      return null;
    };
  }

  static String? Function(String?) minLength(String fieldName, int min) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required.';
      }
      if (value.trim().length < min) {
        return '$fieldName must be at least $min characters.';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(String fieldName, int max) {
    return (String? value) {
      if (value != null && value.trim().length > max) {
        return '$fieldName must be at most $max characters.';
      }
      return null;
    };
  }

  // Name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 100) {
      return 'Name must be at most 100 characters.';
    }
    return null;
  }

  // Date of Birth
  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required.';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
      return 'Enter date in YYYY-MM-DD format.';
    }
    try {
      final dob = DateTime.parse(value.trim());
      final today = DateTime.now();

      final age = today.year - dob.year -
          ((today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day))
              ? 1
              : 0);

      if (age < 18) {
        return 'You must be at least 18 years old to register.';
      }
      if (age > 120) {
        return 'Please enter a valid date of birth.';
      }
    } catch (_) {
      return 'Please enter a valid date.';
    }
    return null;
  }

  // Amount (donations)
  static String? donationAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Enter a valid amount.';
    if (amount <= 0) return 'Amount must be greater than zero.';
    if (amount > 10000000) {
      return 'Amount seems too large. Please verify.';
    }
    return null;
  }

  // UPI Transaction ID
  static String? upiTransactionId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI transaction ID is required.';
    }
    if (value.trim().length < 5) {
      return 'Enter a valid UPI transaction ID.';
    }
    if (value.trim().length > 100) {
      return 'Transaction ID is too long.';
    }
    return null;
  }

  // Complaint fields
  static String? complaintTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required.';
    }
    if (value.trim().length < 5) {
      return 'Title must be at least 5 characters.';
    }
    if (value.trim().length > 200) {
      return 'Title must be at most 200 characters.';
    }
    return null;
  }

  static String? complaintDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required.';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters.';
    }
    if (value.trim().length > 2000) {
      return 'Description must be at most 2000 characters.';
    }
    return null;
  }

  // Compose validators
  /// Run multiple validators in sequence, return first error.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}