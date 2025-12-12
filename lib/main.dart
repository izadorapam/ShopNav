import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopnav/screens/login_screen.dart';
import 'package:shopnav/models/contact.dart';
import 'package:shopnav/screens/signup_screen.dart';
import 'package:shopnav/screens/forgot_password_screen.dart';
import 'package:shopnav/screens/home_screen.dart';
import 'package:shopnav/screens/contacts_screen.dart';
import 'package:shopnav/screens/maps_screen.dart';
import 'package:shopnav/providers/theme_provider.dart';
import 'package:shopnav/services/auth_provider.dart';
import 'package:shopnav/utils/theme.dart';
import 'package:shopnav/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("$e");
  }
  
  runApp(const ShopNavApp());

}

class ShopNavApp extends StatelessWidget {
  const ShopNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ShopNav',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();

}

class _AppWrapperState extends State<AppWrapper> {
  Screen _currentScreen = Screen.login;
  bool _isAppInitialized = false;
  
  // Coordenadas base
  static const double _shoppingCityLat = -5.0917025;
  static const double _shoppingCityLng = -42.8211343;
  
  static const double _teresinaShoppingLat = -5.0854285;
  static const double _teresinaShoppingLng = -42.7928408;
  
  static const double _riversideShoppingLat = -5.07861;
  static const double _riversideShoppingLng = -42.7974866;
  
  static const double _shoppingPopularLat = -5.0772666;
  static const double _shoppingPopularLng = -42.8042703;
  
  List<Contact> _contacts = [
    // ========== SHOPPING DA CIDADE ==========
    // Piso 1 - Shopping da Cidade
    Contact(
      id: 'sc_1_1',
      name: 'McDonald\'s',
      email: 'contato@mcdonalds.com',
      phone: '(86) 3221-4444',
      address: 'Shopping da Cidade - Piso 1 - Praça de Alimentação',
      lat: _shoppingCityLat + 0.0001,
      lng: _shoppingCityLng + 0.0001,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sc_1_2',
      name: 'Subway',
      email: 'contato@subway.com',
      phone: '(86) 3221-4445',
      address: 'Shopping da Cidade - Piso 1 - Praça de Alimentação',
      lat: _shoppingCityLat + 0.0002,
      lng: _shoppingCityLng + 0.0002,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sc_1_3',
      name: 'Americanas',
      email: 'contato@americanas.com',
      phone: '(86) 3221-1112',
      address: 'Shopping da Cidade - Piso 1 - Ala Leste',
      lat: _shoppingCityLat + 0.0003,
      lng: _shoppingCityLng + 0.0003,
      category: 'Serviços',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sc_1_4',
      name: 'Óticas Carol',
      email: 'contato@oticascarol.com',
      phone: '(86) 3221-1113',
      address: 'Shopping da Cidade - Piso 1 - Ala Central',
      lat: _shoppingCityLat + 0.0004,
      lng: _shoppingCityLng + 0.0004,
      category: 'Serviços',
      floor: 'Piso 1',
    ),
    
    // Piso 2 - Shopping da Cidade
    Contact(
      id: 'sc_2_1',
      name: 'Riachuelo',
      email: 'contato@riachuelo.com',
      phone: '(86) 3221-1114',
      address: 'Shopping da Cidade - Piso 2 - Ala Norte',
      lat: _shoppingCityLat + 0.0005,
      lng: _shoppingCityLng + 0.0005,
      category: 'Moda',
      floor: 'Piso 2',
    ),

    Contact(
      id: 'sc_2_2',
      name: 'C&A',
      email: 'contato@cea.com',
      phone: '(86) 3221-1115',
      address: 'Shopping da Cidade - Piso 2 - Ala Sul',
      lat: _shoppingCityLat + 0.0006,
      lng: _shoppingCityLng + 0.0006,
      category: 'Moda',
      floor: 'Piso 2',
    ),

    Contact(
      id: 'sc_2_3',
      name: 'Renner',
      email: 'contato@renner.com',
      phone: '(86) 3221-1116',
      address: 'Shopping da Cidade - Piso 2 - Ala Central',
      lat: _shoppingCityLat + 0.0007,
      lng: _shoppingCityLng + 0.0007,
      category: 'Moda',
      floor: 'Piso 2',
    ),

    
    // Piso 3 - Shopping da Cidade
    Contact(
      id: 'sc_3_1',
      name: 'Cinemark',
      email: 'contato@cinemark.com',
      phone: '(86) 3221-3333',
      address: 'Shopping da Cidade - Piso 3 - Área de Entretenimento',
      lat: _shoppingCityLat + 0.0008,
      lng: _shoppingCityLng + 0.0008,
      category: 'Entretenimento',
      floor: 'Piso 3',
    ),

    Contact(
      id: 'sc_3_2',
      name: 'Playland',
      email: 'contato@playland.com',
      phone: '(86) 3221-3334',
      address: 'Shopping da Cidade - Piso 3 - Espaço Infantil',
      lat: _shoppingCityLat + 0.0009,
      lng: _shoppingCityLng + 0.0009,
      category: 'Entretenimento',
      floor: 'Piso 3',
    ),

    Contact(
      id: 'sc_3_3',
      name: 'Centauro',
      email: 'contato@centauro.com',
      phone: '(86) 3221-5555',
      address: 'Shopping da Cidade - Piso 3 - Ala Oeste',
      lat: _shoppingCityLat + 0.0010,
      lng: _shoppingCityLng + 0.0010,
      category: 'Esportes',
      floor: 'Piso 3',
    ),
    
    // ========== TERESINA SHOPPING ==========
    // Piso 1 - Teresina Shopping
    Contact(
      id: 'ts_1_1',
      name: 'Outback',
      email: 'contato@outback.com',
      phone: '(86) 3222-1112',
      address: 'Teresina Shopping - Piso 1 - Área Gourmet',
      lat: _teresinaShoppingLat + 0.0001,
      lng: _teresinaShoppingLng + 0.0001,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),
    Contact(
      id: 'ts_1_2',
      name: 'Apple Store',
      email: 'contato@apple.com',
      phone: '(86) 3222-2222',
      address: 'Teresina Shopping - Piso 1 - Ala Central',
      lat: _teresinaShoppingLat + 0.0002,
      lng: _teresinaShoppingLng + 0.0002,
      category: 'Eletrônicos',
      floor: 'Piso 1',
    ),
    Contact(
      id: 'ts_1_3',
      name: 'Samsung',
      email: 'contato@samsung.com',
      phone: '(86) 3222-2223',
      address: 'Teresina Shopping - Piso 1 - Ala Leste',
      lat: _teresinaShoppingLat + 0.0003,
      lng: _teresinaShoppingLng + 0.0003,
      category: 'Eletrônicos',
      floor: 'Piso 1',
    ),
    
    // Piso 2 - Teresina Shopping
    Contact(
      id: 'ts_2_1',
      name: 'Zara',
      email: 'contato@zara.com',
      phone: '(86) 3222-1111',
      address: 'Teresina Shopping - Piso 2 - Ala Norte',
      lat: _teresinaShoppingLat + 0.0004,
      lng: _teresinaShoppingLng + 0.0004,
      category: 'Moda',
      floor: 'Piso 2',
    ),
    Contact(
      id: 'ts_2_2',
      name: 'H&M',
      email: 'contato@hm.com',
      phone: '(86) 3222-1113',
      address: 'Teresina Shopping - Piso 2 - Ala Sul',
      lat: _teresinaShoppingLat + 0.0005,
      lng: _teresinaShoppingLng + 0.0005,
      category: 'Moda',
      floor: 'Piso 2',
    ),
    Contact(
      id: 'ts_2_3',
      name: 'Forever 21',
      email: 'contato@forever21.com',
      phone: '(86) 3222-1114',
      address: 'Teresina Shopping - Piso 2 - Ala Central',
      lat: _teresinaShoppingLat + 0.0006,
      lng: _teresinaShoppingLng + 0.0006,
      category: 'Moda',
      floor: 'Piso 2',
    ),
    
    // ========== RIVERSIDE SHOPPING ==========
    // Piso 1 - Riverside Shopping
    Contact(
      id: 'rs_1_1',
      name: 'Starbucks',
      email: 'contato@starbucks.com',
      phone: '(86) 3223-2221',
      address: 'Riverside Shopping - Piso 1 - Entrada Principal',
      lat: _riversideShoppingLat + 0.0001,
      lng: _riversideShoppingLng + 0.0001,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),
    Contact(
      id: 'rs_1_2',
      name: 'Burger King',
      email: 'contato@burgerking.com',
      phone: '(86) 3223-2222',
      address: 'Riverside Shopping - Piso 1 - Praça Central',
      lat: _riversideShoppingLat + 0.0002,
      lng: _riversideShoppingLng + 0.0002,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),
    Contact(
      id: 'rs_1_3',
      name: 'Casas Bahia',
      email: 'contato@casasbahia.com',
      phone: '(86) 3223-2223',
      address: 'Riverside Shopping - Piso 1 - Ala Norte',
      lat: _riversideShoppingLat + 0.0003,
      lng: _riversideShoppingLng + 0.0003,
      category: 'Eletrônicos',
      floor: 'Piso 1',
    ),
    
    // Piso 2 - Riverside Shopping
    Contact(
      id: 'rs_2_1',
      name: 'Nike',
      email: 'contato@nike.com',
      phone: '(86) 3223-2224',
      address: 'Riverside Shopping - Piso 2 - Ala Esportiva',
      lat: _riversideShoppingLat + 0.0004,
      lng: _riversideShoppingLng + 0.0004,
      category: 'Esportes',
      floor: 'Piso 2',
    ),
    Contact(
      id: 'rs_2_2',
      name: 'Adidas',
      email: 'contato@adidas.com',
      phone: '(86) 3223-2225',
      address: 'Riverside Shopping - Piso 2 - Ala Esportiva',
      lat: _riversideShoppingLat + 0.0005,
      lng: _riversideShoppingLng + 0.0005,
      category: 'Esportes',
      floor: 'Piso 2',
    ),
    Contact(
      id: 'rs_2_3',
      name: 'Puma',
      email: 'contato@puma.com',
      phone: '(86) 3223-2226',
      address: 'Riverside Shopping - Piso 2 - Ala Oeste',
      lat: _riversideShoppingLat + 0.0006,
      lng: _riversideShoppingLng + 0.0006,
      category: 'Esportes',
      floor: 'Piso 2',
    ),
    
    // Piso 3 - Riverside Shopping
    Contact(
      id: 'rs_3_1',
      name: 'Cinema IMAX',
      email: 'contato@imax.com',
      phone: '(86) 3223-2227',
      address: 'Riverside Shopping - Piso 3 - Cinema Premium',
      lat: _riversideShoppingLat + 0.0007,
      lng: _riversideShoppingLng + 0.0007,
      category: 'Entretenimento',
      floor: 'Piso 3',
    ),
    Contact(
      id: 'rs_3_2',
      name: 'Game Station',
      email: 'contato@gamestation.com',
      phone: '(86) 3223-2228',
      address: 'Riverside Shopping - Piso 3 - Zona Gamer',
      lat: _riversideShoppingLat + 0.0008,
      lng: _riversideShoppingLng + 0.0008,
      category: 'Entretenimento',
      floor: 'Piso 3',
    ),
    Contact(
      id: 'rs_3_3',
      name: 'Moda Premium',
      email: 'contato@modapremium.com',
      phone: '(86) 3223-2229',
      address: 'Riverside Shopping - Piso 3 - Ala de Luxo',
      lat: _riversideShoppingLat + 0.0009,
      lng: _riversideShoppingLng + 0.0009,
      category: 'Moda',
      floor: 'Piso 3',
    ),
    
    // Piso 4 - Riverside Shopping
    Contact(
      id: 'rs_4_1',
      name: 'Praça de Alimentação VIP',
      email: 'contato@praçavip.com',
      phone: '(86) 3223-2230',
      address: 'Riverside Shopping - Piso 4 - Restaurantes',
      lat: _riversideShoppingLat + 0.0010,
      lng: _riversideShoppingLng + 0.0010,
      category: 'Alimentação',
      floor: 'Piso 4',
    ),
    Contact(
      id: 'rs_4_2',
      name: 'Mirante do Rio Poti',
      email: 'contato@mirante.com',
      phone: '(86) 3223-2231',
      address: 'Riverside Shopping - Piso 4 - Terraço',
      lat: _riversideShoppingLat + 0.0011,
      lng: _riversideShoppingLng + 0.0011,
      category: 'Entretenimento',
      floor: 'Piso 4',
    ),
    
    // ========== SHOPPING POPULAR ==========
    // Piso Único - Shopping Popular
    Contact(
      id: 'sp_1_1',
      name: 'Lojas Americanas Express',
      email: 'contato@americanasexpress.com',
      phone: '(86) 3224-3331',
      address: 'Shopping Popular - Setor A - Box 10',
      lat: _shoppingPopularLat + 0.0001,
      lng: _shoppingPopularLng + 0.0001,
      category: 'Serviços',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sp_1_2',
      name: 'Casa & Vídeo',
      email: 'contato@casaevideo.com',
      phone: '(86) 3224-3332',
      address: 'Shopping Popular - Setor B - Box 15',
      lat: _shoppingPopularLat + 0.0002,
      lng: _shoppingPopularLng + 0.0002,
      category: 'Eletrônicos',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sp_1_3',
      name: 'Moda Popular',
      email: 'contato@modapopular.com',
      phone: '(86) 3224-3333',
      address: 'Shopping Popular - Setor C - Box 25',
      lat: _shoppingPopularLat + 0.0003,
      lng: _shoppingPopularLng + 0.0003,
      category: 'Moda',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sp_1_4',
      name: 'Lanchonete do Seu Zé',
      email: 'contato@seuze.com',
      phone: '(86) 3224-3334',
      address: 'Shopping Popular - Setor D - Box 30',
      lat: _shoppingPopularLat + 0.0004,
      lng: _shoppingPopularLng + 0.0004,
      category: 'Alimentação',
      floor: 'Piso 1',
    ),

    Contact(
      id: 'sp_1_5',
      name: 'Cabeleireiro Popular',
      email: 'contato@cabeleireiro.com',
      phone: '(86) 3224-3335',
      address: 'Shopping Popular - Setor E - Box 35',
      lat: _shoppingPopularLat + 0.0005,
      lng: _shoppingPopularLng + 0.0005,
      category: 'Serviços',
      floor: 'Piso 1',
    ),
  ];

  @override
  void initState() {
    
    super.initState();
    _initializeApp();

  }

  Future<void> _initializeApp() async {
    
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();
      
      // Verificar login e navegar
      _checkAuthAndNavigate(authProvider);
      
    } catch (e) {
      print("$e");
    } finally {
      if (mounted) {
        setState(() {
          _isAppInitialized = true;
        });
      }
    }
  }

  void _checkAuthAndNavigate(AuthProvider authProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (authProvider.isLoggedIn) {
          _navigateTo(Screen.home);
        } else {
          _navigateTo(Screen.login);
        }
      }
    });
  }

  void _handleLogin() {
    
    // Forçar navegação para home
    _navigateTo(Screen.home);
  }

  void _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
    
    // Navegar para login após logout
    _navigateTo(Screen.login);
  }

  void _addContact(Contact contact) {
    setState(() {
      _contacts.add(Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        address: contact.address,
        lat: contact.lat,
        lng: contact.lng,
        category: contact.category,
        floor: contact.floor,
      ));
    });
  }

  void _updateContact(String id, Contact updatedContact) {
    setState(() {
      final index = _contacts.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contacts[index] = updatedContact.copyWith(id: id);
      }
    });
  }

  void _deleteContact(String id) {
    setState(() {
      _contacts.removeWhere((c) => c.id == id);
    });
  }

  void _navigateTo(Screen screen) {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentScreen = screen;
        });
      }
    });
  }

  void _showAuthMessages(BuildContext context, AuthProvider authProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.showSuccessMessage && authProvider.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        authProvider.clearMessages();
      }
      
      if (authProvider.errorMessage != null && !authProvider.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        authProvider.clearMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Tela de carregamento inicial
    if (!_isAppInitialized) {
      return _buildLoadingScreen('Inicializando...');
    }

    // **CRÍTICO: Verificar mudanças no estado de login e redirecionar automaticamente**
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.isLoggedIn && _currentScreen == Screen.login) {
        _navigateTo(Screen.home);
      } else if (!authProvider.isLoggedIn && _currentScreen == Screen.home) {
        _navigateTo(Screen.login);
      }
    });

    // Mostrar mensagens do provider
    _showAuthMessages(context, authProvider);

    // Navegação entre telas
    return _buildCurrentScreen(authProvider);
  }

  Widget _buildCurrentScreen(AuthProvider authProvider) {
    switch (_currentScreen) {
      case Screen.login:
        return LoginScreen(
          onNavigate: _navigateTo,
          onLogin: _handleLogin,
        );
      case Screen.signup:
        return SignupScreen(onNavigate: _navigateTo);
      case Screen.forgotPassword:
        return ForgotPasswordScreen(onNavigate: _navigateTo);
      case Screen.home:
        // Verificar se realmente está logado
        if (!authProvider.isLoggedIn) {
          return _buildLoadingScreen('Verificando login...');
        }
        return HomeScreen(
          onNavigate: _navigateTo,
          onLogout: _handleLogout,
        );
      case Screen.contacts:
        return ContactsScreen(
          contacts: _contacts,
          onNavigate: _navigateTo,
          onAddContact: _addContact,
          onUpdateContact: _updateContact,
          onDeleteContact: _deleteContact,
        );
      case Screen.maps:
        return MapsScreen(
          contacts: _contacts,
          onNavigate: _navigateTo,
        );
      // ignore: unreachable_switch_default
      default:
        return LoginScreen(
          onNavigate: _navigateTo,
          onLogin: _handleLogin,
        );
    }
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Screen {
  login,
  signup,
  forgotPassword,
  home,
  contacts,
  maps,
}