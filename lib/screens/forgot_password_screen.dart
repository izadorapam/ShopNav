import 'package:flutter/material.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/widgets/gradient_button.dart';
import 'package:shopnav/widgets/input_field.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/services/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Function(Screen) onNavigate;

  const ForgotPasswordScreen({super.key, required this.onNavigate});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSending) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um email válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final success = await authProvider.resetPassword(_emailController.text.trim());
      
      if (success) {
        setState(() {
          _sent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📧 Email enviado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Erro já tratado pelo provider
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Column(
                          children: [
                            Text(
                              'Recuperar Senha',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = AppColors.textGradient.createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Digite seu email para receber instruções de recuperação',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Form / Success Message
                        if (!_sent) ...[
                          Column(
                            children: [
                              InputField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'seu@email.com',
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.email,
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                onPressed: _isSending ? null : () => _handleSubmit(),
                                gradient: AppColors.buttonGradient,
                                child: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Enviar Instruções',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => widget.onNavigate(Screen.login),
                                child: Text(
                                  'Voltar ao Login',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.purple.withOpacity(0.1),
                                      AppColors.pink.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.purple,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Email Enviado!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = AppColors.textGradient.createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Verifique sua caixa de entrada para instruções de recuperação',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                onPressed: () => widget.onNavigate(Screen.login),
                                gradient: AppColors.buttonGradient,
                                child: const Text(
                                  'Voltar ao Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

    final center1 = Offset(size.width * 0.3, size.height * 0.3);
    final center2 = Offset(size.width * 0.7, size.height * 0.7);

    canvas.drawCircle(center1, size.width * 0.6, paint);
    canvas.drawCircle(center2, size.width * 0.4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}