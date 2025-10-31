// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

// Define available avatars
const List<IconData> _avatars = [
  Icons.person,
  Icons.auto_fix_high,
  Icons.directions_run,
  Icons.security,
  Icons.local_fire_department,
];

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // State for Challenges
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  IconData? _selectedAvatar; // Tracks the selected avatar
  String _passwordStrength = ''; // Tracks password strength
  int _completedFields = 0; // For Progress Tracker (4 total fields)
  double get _progressPercentage => _completedFields / 4.0;
  
  // Progress Tracker Messages
  final Map<double, String> _milestoneMessages = {
    0.25: "Great start!",
    0.50: "Halfway there!",
    0.75: "Almost done!",
    1.00: "Ready for adventure!",
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _nameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
  }

  // --- Password Strength Meter Logic ---
  void _checkPasswordStrength() {
    String p = _passwordController.text;
    String strength;
    if (p.isEmpty) {
      strength = '';
    } else if (p.length < 6) {
      strength = 'Weak';
    } else if (p.length < 8 || !p.contains(RegExp(r'[0-9]'))) {
      strength = 'Moderate';
    } else if (p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      strength = 'Strong';
    } else {
      strength = 'Good';
    }
    setState(() {
      _passwordStrength = strength;
    });
    _updateProgress(); // Also update progress here
  }
  
  Color _getPasswordColor() {
    switch (_passwordStrength) {
      case 'Strong':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Moderate':
        return Colors.orange;
      case 'Weak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getPasswordProgress() {
    switch (_passwordStrength) {
      case 'Strong': return 1.0;
      case 'Good': return 0.75;
      case 'Moderate': return 0.5;
      case 'Weak': return 0.25;
      default: return 0.0;
    }
  }
  
  // --- Progress Tracker Logic ---
  void _updateProgress() {
    int count = 0;
    // 1. Name
    if (_nameController.text.isNotEmpty) count++;
    // 2. Email (with basic validation)
    if (_emailController.text.isNotEmpty && _emailController.text.contains('@') && _emailController.text.contains('.')) count++;
    // 3. DOB
    if (_dobController.text.isNotEmpty) count++;
    // 4. Password (must be at least 'Good' for 100% progress for a complete profile)
    if (_getPasswordProgress() >= 0.75) count++; // Requires 'Good' or 'Strong' password
    
    // 5. Avatar Selection (Optional for 100% completion badge, but tracked here)
    // You can adjust the total field count or consider this a separate challenge.
    
    if (_completedFields != count) {
      setState(() {
        _completedFields = count;
        // Optionally trigger animation/sound here for milestones:
        if (_milestoneMessages.containsKey(_progressPercentage)) {
          // Placeholder for celebratory animation/sound at 25, 50, 75, 100%
          print("Milestone Reached: ${_progressPercentage * 100}%");
        }
      });
    }
  }

  // Date Picker Function (from source code)
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _updateProgress(); // Update progress after selecting date
      });
    }
  }

  // Submission Function
  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedAvatar != null) {
      setState(() {
        _isLoading = true;
      });
      // --- Achievement Badge Logic (Pre-submission check) ---
      List<String> badges = [];
      if (_passwordStrength == 'Strong') {
        badges.add("Strong Password Master"); // Badge 1
      }
      
      // Check for 'Profile Completer'
      if (_progressPercentage == 1.0) {
          badges.add("Profile Completer"); // Badge 3
      }

      // Check for 'The Early Bird Special' (signed up before 12 PM)
      if (DateTime.now().hour < 12) {
        badges.add("The Early Bird Special"); // Badge 2
      }

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              selectedAvatar: _selectedAvatar!, // Pass avatar
              awardedBadges: badges, // Pass badges
            ),
          ),
        );
      });
    } else if (_selectedAvatar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an avatar to continue the adventure!'))
        );
    }
  }

  // Helper Widget for Avatar Selection
  Widget _buildAvatarSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Adventure Avatar:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _avatars.map((icon) {
              bool isSelected = _selectedAvatar == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = icon;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: isSelected ? 65 : 60,
                  height: isSelected ? 65 : 60,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple[400] : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.deepPurple, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.5),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.deepPurple,
                    size: 30,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Progress Tracker Display
  Widget _buildProgressTracker() {
    String message = _milestoneMessages[_progressPercentage] ?? "Let's begin!";
    
    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: _progressPercentage,
            minHeight: 10,
            backgroundColor: Colors.deepPurple.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${(_progressPercentage * 100).toStringAsFixed(0)}% Complete',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
  
  // Custom TextField Helper with onChanged to update progress
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      readOnly: isReadOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉 '),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 1. Progress Tracker
                _buildProgressTracker(),
                const SizedBox(height: 30),
                // 2. Avatar Selection
                _buildAvatarSelection(),
                const SizedBox(height: 30),
                // Form Header (from source code)
                // ... (AnimatedContainer for form header)
                // ...
                const SizedBox(height: 30),
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                  onChanged: (value) => _updateProgress(),
                ),
                const SizedBox(height: 20),
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) => _updateProgress(),
                ),
                const SizedBox(height: 20),
                // DOB w/Calendar
                _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today,
                  isReadOnly: true,
                  onTap: _selectDate,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectDate,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Pswd Field w/ Toggle and Strength Meter
                _buildTextField(
                  controller: _passwordController,
                  label: 'Secret Password',
                  icon: Icons.lock,
                  isPassword: true,
                  onChanged: (value) => _checkPasswordStrength(), // Updates strength meter and progress
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Password Strength Meter Display
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strength: $_passwordStrength',
                        style: TextStyle(
                            color: _getPasswordColor(), fontWeight: FontWeight.bold),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: _getPasswordProgress(),
                          minHeight: 5,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(_getPasswordColor()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Submit Button w/ Loading Animation (from source code)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}