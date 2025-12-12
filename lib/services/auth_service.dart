import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. INICIALIZAR FIREBASE COM DEPURAÇÃO DETALHADA
  static Future<void> initialize() async {
    try {
      
      await Firebase.initializeApp();
      
    } catch (e) {
      rethrow;
    }
  }

  // 2. CADASTRAR USUÁRIO COM LOGS DETALHADOS
  static Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      
      // Validar email
      if (!email.contains('@')) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Email inválido',
        );
      }
      
      // Validar senha
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Senha muito curta',
        );
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Atualizar nome
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        
        // Enviar email de verificação
        await userCredential.user!.sendEmailVerification();
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 3. FAZER LOGIN COM LOGS DETALHADOS - CORRIGIDO
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      
      // Método direto para evitar o erro de type cast
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não encontrado',
        );
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 4. RECUPERAR SENHA
  static Future<void> resetPassword(String email) async {
    try {
      
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 5. SAIR
  static Future<void> signOut() async {
    try {
      // ignore: unused_local_variable
      final currentEmail = _auth.currentUser?.email;
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // 6. VERIFICAR EMAIL
  static Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // 7. REENVIAR EMAIL DE VERIFICAÇÃO
  static Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  // 8. GETTERS
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}