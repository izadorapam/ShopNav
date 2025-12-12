import 'package:flutter/material.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/widgets/gradient_button.dart';
import 'package:shopnav/widgets/input_field.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/providers/theme_provider.dart';
import 'package:shopnav/services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final Function(Screen) onNavigate;
  final VoidCallback onLogin;

  const LoginScreen({
    super.key,
    required this.onNavigate,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoggingIn) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Validar campos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha todos os campos'),
          backgroundColor: isDarkMode ? Colors.orange[800] : Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        
        // Limpar campos
        _emailController.clear();
        _passwordController.clear();
        
        // Pequeno delay para garantir que o estado foi atualizado
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Chamar callback para navegar para home
        widget.onLogin();
      } else {
        print("❌");
      }
    } catch (e) {
      print("$e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
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
                    color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.95),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        _buildLogo(isDarkMode),
                        
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
                                  'Conectando...',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Form
                        Column(
                          children: [
                            InputField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'seu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              icon: Icons.email,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 16),
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
                              isDarkMode: isDarkMode,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => widget.onNavigate(Screen.forgotPassword),
                                child: Text(
                                  'Esqueceu sua senha?',
                                  style: TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Login Button
                            GradientButton(
                              onPressed: _isLoggingIn ? null : _handleLogin,
                              gradient: AppColors.buttonGradient,
                              child: _isLoggingIn
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Signup Button
                            OutlinedButton(
                              onPressed: () => widget.onNavigate(Screen.signup),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.purple,
                                side: const BorderSide(color: AppColors.purple),
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Cadastrar conta'),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Footer
                            Column(
                              children: [
                                Text(
                                  'Sistema de Navegação Inteligente',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Status: ${authProvider.isLoggedIn ? 'LOGADO' : 'DESLOGADO'}',
                                  style: TextStyle(
                                    color: authProvider.isLoggedIn ? Colors.green : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildLogo(bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ShopNav',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = AppColors.textGradient.createShader(
                    const Rect.fromLTWH(0, 0, 200, 70),
                  ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              color: AppColors.pink,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Navegue pelo shopping com facilidade',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final center1 = Offset(size.width * 0.25, size.height * 0.25);
    final center2 = Offset(size.width * 0.75, size.height * 0.75);

    canvas.drawCircle(center1, size.width * 0.4, paint);
    canvas.drawCircle(center2, size.width * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}