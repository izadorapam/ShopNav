import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _user;
  String? _errorMessage;
  String? _successMessage;
  bool _showSuccessMessage = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showSuccessMessage => _showSuccessMessage;

  AuthProvider() {
    // Verificar se já está logado
    _checkAuthState();
  }

  void _checkAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _isLoggedIn = currentUser != null;
    _user = currentUser;
  }

  Future<void> initialize() async {
    try {
      setState(() => _isLoading = true);
      
      // Aguardar Firebase inicializar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verificar estado atual
      _checkAuthState();
    } catch (e) {
      print("$e");
    } finally {
      setState(() => _isLoading = false);
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
        _showSuccessMessage = false;
      });
      notifyListeners();
      
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (userCredential.user != null) {
        _isLoggedIn = true;
        _user = userCredential.user;
        
        setState(() {
          _successMessage = 'Login realizado com sucesso!';
          _showSuccessMessage = true;
        });
        
        // CRÍTICO: Notificar todos os listeners
        notifyListeners();
        
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      String message = 'Erro no login';
      
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else if (e.code == 'too-many-requests') {
        message = 'Muitas tentativas. Tente mais tarde';
      } else {
        message = e.message ?? 'Erro desconhecido';
      }
      
      setState(() => _errorMessage = message);
      notifyListeners();
      return false;
    } catch (e) {
      setState(() => _errorMessage = 'Erro inesperado: $e');
      notifyListeners();
      return false;
    } finally {
      setState(() => _isLoading = false);
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
        _showSuccessMessage = false;
      });
      notifyListeners();
      
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (userCredential.user != null) {
        // Atualizar perfil do usuário
        await userCredential.user!.updateDisplayName(name);
        
        _isLoggedIn = true;
        _user = userCredential.user;
        
        setState(() {
          _successMessage = 'Conta criada com sucesso! Redirecionando...';
          _showSuccessMessage = true;
        });
        
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      String message = 'Erro no cadastro';
      
      if (e.code == 'email-already-in-use') {
        message = 'Este email já está em uso';
      } else if (e.code == 'weak-password') {
        message = 'Senha muito fraca';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else {
        message = e.message ?? 'Erro desconhecido';
      }
      
      setState(() => _errorMessage = message);
      notifyListeners();
      return false;
    } catch (e) {
      setState(() => _errorMessage = 'Erro inesperado: $e');
      notifyListeners();
      return false;
    } finally {
      setState(() => _isLoading = false);
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
        _showSuccessMessage = false;
      });
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      
      setState(() {
        _successMessage = 'Email de recuperação enviado!';
        _showSuccessMessage = true;
      });
      
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao enviar email';
      
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else {
        message = e.message ?? 'Erro desconhecido';
      }
      
      setState(() => _errorMessage = message);
      notifyListeners();
      return false;
    } catch (e) {
      setState(() => _errorMessage = 'Erro inesperado: $e');
      notifyListeners();
      return false;
    } finally {
      setState(() => _isLoading = false);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      setState(() => _isLoading = true);
      notifyListeners();

      await FirebaseAuth.instance.signOut();
      
      _isLoggedIn = false;
      _user = null;
      
      setState(() {
        _successMessage = 'Logout realizado com sucesso!';
        _showSuccessMessage = true;
      });

    } catch (e) {
      setState(() => _errorMessage = 'Erro ao fazer logout');
    } finally {
      setState(() => _isLoading = false);
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _showSuccessMessage = false;
    notifyListeners();
  }

  void setState(Function() fn) {
    fn();
  }
}