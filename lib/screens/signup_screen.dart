import 'package:flutter/material.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/widgets/gradient_button.dart';
import 'package:shopnav/widgets/input_field.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/services/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  final Function(Screen) onNavigate;

  const SignupScreen({super.key, required this.onNavigate});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isRegistering) return;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isRegistering = true;
    });

    try {
      
      final success = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Cadastro bem-sucedido - mensagem já será mostrada pelo provider
        
        // Limpar campos
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        
        // Navegar para login após 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onNavigate(Screen.login);
          }
        });
        
      }
      // Se falhar, o erro já será mostrado pelo provider
      
    } catch (e) {
      print("$e");
      // Erro já será tratado pelo provider
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.loginGradient,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: OverflowBox(
                maxWidth: MediaQuery.of(context).size.width * 2,
                maxHeight: MediaQuery.of(context).size.height * 2,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 3),
                  curve: Curves.easeInOut,
                  child: CustomPaint(
                    painter: _BackgroundPainter(),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.grey[600],
                              onPressed: () => widget.onNavigate(Screen.login),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Criar Conta',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = AppColors.textGradient
                                          .createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        
                        // Status do Firebase
                        if (authProvider.isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Conectando ao Firebase...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              InputField(
                                controller: _nameController,
                                label: 'Nome Completo',
                                hintText: 'Seu nome',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite seu nome';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'seu@email.com',
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite seu email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Por favor, digite um email válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                controller: _phoneController,
                                label: 'Telefone',
                                hintText: '(86) 99999-9999',
                                keyboardType: TextInputType.phone,
                                icon: Icons.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite seu telefone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                controller: _passwordController,
                                label: 'Senha',
                                hintText: '••••••••',
                                obscureText: !_showPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.purple,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                                icon: Icons.lock,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite sua senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                controller: _confirmPasswordController,
                                label: 'Confirmar Senha',
                                hintText: '••••••••',
                                obscureText: !_showConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.purple,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword = !_showConfirmPassword;
                                    });
                                  },
                                ),
                                icon: Icons.lock,
                                validator: _validateConfirmPassword,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              GradientButton(
                                onPressed: _isRegistering ? null : () => _handleSubmit(),
                                gradient: AppColors.buttonGradient,
                                child: _isRegistering
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Criar Conta',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Já tem uma conta? ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextButton(
                                    onPressed: () => widget.onNavigate(Screen.login),
                                    child: Text(
                                      'Fazer Login',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final center1 = Offset(size.width * 0.2, size.height * 0.2);
    final center2 = Offset(size.width * 0.8, size.height * 0.8);

    canvas.drawCircle(center1, size.width * 0.5, paint);
    canvas.drawCircle(center2, size.width * 0.4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}