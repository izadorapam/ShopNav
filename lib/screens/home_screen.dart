import 'package:flutter/material.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:shopnav/main.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/providers/theme_provider.dart';
import 'package:shopnav/services/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final Function(Screen) onNavigate;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  // Método para confirmar logout
  Future<void> _confirmLogout(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.purple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sair da Conta',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza que deseja sair da sua conta?',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.purple),
                    const SizedBox(height: 16),
                    Text(
                      'Saindo...',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Fazer logout
      try {
        await authProvider.signOut();
        
        // Fechar diálogo de loading
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Chamar callback de logout
        onLogout();
      } catch (e) {
        // Fechar diálogo de loading
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Mostrar erro
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sair: ${authProvider.errorMessage ?? "Tente novamente"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.purple.shade100,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.purple, AppColors.pink],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ShopNav',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [AppColors.purple, AppColors.pink],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 100, 20),
                                        ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: AppColors.pink,
                                    size: 16,
                                  ),
                                ],
                              ),
                              Text(
                                'Olá, ${authProvider.user?.email?.split('@').first ?? "Visitante"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              themeProvider.toggleTheme(!isDarkMode);
                            },
                            icon: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: isDarkMode ? Colors.amber : Colors.grey[700],
                            ),
                            tooltip: isDarkMode ? 'Modo Claro' : 'Modo Escuro',
                          ),
                          IconButton(
                            onPressed: () => _confirmLogout(context),
                            icon: const Icon(Icons.logout),
                            color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
                            tooltip: 'Sair da conta',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo ao Shopping',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.purple,
                                    AppColors.pink,
                                    AppColors.orange,
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 300, 40),
                                ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Encontre lojas, navegue pelo mapa e descubra ofertas especiais',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey.shade300 : Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          // Status do login
                          if (authProvider.isLoggedIn) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Conectado',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Stats Cards - TODOS EM COLUNA
                    Column(
                      children: [
                        _buildStatCard(
                          '30+',
                          'Lojas Disponíveis',
                          [AppColors.purple, AppColors.purpleDark],
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          '4',
                          'Pisos do Shopping',
                          [AppColors.pink, AppColors.rose],
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          'GPS',
                          'Navegação em Tempo Real',
                          [AppColors.orange, AppColors.amber],
                          isDarkMode,
                        ),
                      ],
                    ),

                    // Menu Grid - BOTÕES CORRIGIDOS (USANDO INKWELL)
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recursos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            // BOTÃO LOJAS - CORRIGIDO
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  onNavigate(Screen.contacts);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: AppColors.purple.withOpacity(0.1),
                                highlightColor: AppColors.purple.withOpacity(0.2),
                                child: _buildMenuCardContent(
                                  Icons.store,
                                  'Lojas',
                                  'Explore todas as lojas do shopping',
                                  [AppColors.pink, AppColors.rose],
                                  isDarkMode,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // BOTÃO MAPA - CORRIGIDO
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  onNavigate(Screen.maps);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: AppColors.purple.withOpacity(0.1),
                                highlightColor: AppColors.purple.withOpacity(0.2),
                                child: _buildMenuCardContent(
                                  Icons.map,
                                  'Mapa Interativo',
                                  'Navegue pelo shopping em tempo real',
                                  [AppColors.purple, AppColors.indigo],
                                  isDarkMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Features Section - TODOS EM COLUNA
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Funcionalidades',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            _buildFeatureCard(
                              '🎯',
                              'Localização Precisa',
                              'Encontre qualquer loja rapidamente',
                              AppColors.purple,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureCard(
                              '🗺️',
                              'Rotas Inteligentes',
                              'Navegação otimizada pelo shopping',
                              AppColors.pink,
                              isDarkMode,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureCard(
                              '⚡',
                              'Sistema Rápido',
                              'Resposta instantânea e fluida',
                              AppColors.orange,
                              isDarkMode,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Informações da conta (se logado)
                    if (authProvider.isLoggedIn) ...[
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey.shade800 : AppColors.purple.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  color: AppColors.purple,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sua Conta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Você está logado e pode acessar todos os recursos do aplicativo.',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _confirmLogout(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.purple,
                                      side: const BorderSide(color: AppColors.purple),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout, size: 16),
                                        SizedBox(width: 6),
                                        Text('Sair da Conta'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, List<Color> colors, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODO ATUALIZADO: Conteúdo do card de menu
  Widget _buildMenuCardContent(
    IconData icon,
    String title,
    String subtitle,
    List<Color> colors,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: colors.first,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String emoji,
    String title,
    String description,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}