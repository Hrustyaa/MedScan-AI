import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dbService = DatabaseService();

  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  late AnimationController _bgController;
  late AnimationController _formEntranceController;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _formEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _formFade = CurvedAnimation(
      parent: _formEntranceController,
      curve: Curves.easeOut,
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formEntranceController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _formEntranceController.forward();
    });

    _emailFocus.addListener(_rebuild);
    _passFocus.addListener(_rebuild);
    _nameFocus.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_rebuild);
    _passFocus.removeListener(_rebuild);
    _nameFocus.removeListener(_rebuild);

    _bgController.dispose();
    _formEntranceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _toggleMode() {
    if (!mounted || isLoading) return;
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (_) {}
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _submit() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Заполните все поля'.tr(), isError: true);
      return;
    }

    if (!isLogin && name.isEmpty) {
      _showSnack('Введите ваше имя'.tr(), isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        ).timeout(const Duration(seconds: 15));
      } else {
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(const Duration(seconds: 15));

        await Future.wait([
          cred.user?.updateDisplayName(name) ?? Future.value(),
          _dbService.createUserData(name, email),
        ]);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Ошибка авторизации'.tr();
      switch (e.code) {
        case 'user-not-found': msg = 'Пользователь не найден'.tr(); break;
        case 'wrong-password': msg = 'Неверный пароль'.tr(); break;
        case 'email-already-in-use': msg = 'Email уже занят'.tr(); break;
        case 'weak-password': msg = 'Пароль слишком простой (мин. 6 символов)'.tr(); break;
        case 'invalid-email': msg = 'Некорректный Email'.tr(); break;
        case 'network-request-failed': msg = 'Нет интернета. Проверьте подключение'.tr(); break;
        case 'invalid-credential': msg = 'Неверный email или пароль'.tr(); break;
        case 'too-many-requests': msg = 'Слишком много попыток. Подождите'.tr(); break;
      }
      _showSnack(msg, isError: true);
    } on TimeoutException {
      if (!mounted) return;
      _showSnack('Сервер долго не отвечает'.tr(), isError: true);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('NetworkException') ||
          errorMsg.contains('Failed host lookup')) {
        _showSnack('Нет интернета. Проверьте подключение'.tr(), isError: true);
      } else {
        _showSnack('${'Ошибка'.tr()}: ${e.toString().split(']').last.trim()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Введите email'.tr(), isError: true);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) _showSnack('Письмо отправлено на {}'.tr(args: [email]), isError: false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        _showSnack('Пользователь с таким email не найден'.tr(), isError: true);
      } else {
        _showSnack('Ошибка отправки'.tr(), isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack('Ошибка отправки'.tr(), isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: isError ? AppColors.coral : AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            RepaintBoundary(
              child: _buildAnimatedBackground(),
            ),
            SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: FadeTransition(
                        opacity: _formFade,
                        child: SlideTransition(
                          position: _formSlide,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              _buildLogo(),
                              const SizedBox(height: 40),
                              _buildGlassForm(),
                              const SizedBox(height: 30),
                              _buildSocialLogin(),
                              const SizedBox(height: 30),
                              _buildFooter(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + 50 * math.sin(_bgController.value * 2 * math.pi),
              left: -50 + 30 * math.cos(_bgController.value * 2 * math.pi),
              child: _blob(AppColors.mint, 300),
            ),
            Positioned(
              bottom: -80 + 40 * math.cos(_bgController.value * 2 * math.pi),
              right: -40 + 40 * math.sin(_bgController.value * 2 * math.pi),
              child: _blob(AppColors.sky, 350),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -100 + 20 * math.sin(_bgController.value * 4 * math.pi),
              child: _blob(AppColors.purple, 200, opacity: 0.08),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(Color color, double size, {double opacity = 0.15}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
              boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        const Text('MEDSCAN_AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 5, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Здоровье под контролем'.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white),
            boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  _switchButton('Вход'.tr(), isLogin),
                  _switchButton('Регистрация'.tr(), !isLogin),
                ]),
              ),
              const SizedBox(height: 32),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(children: [
                  if (!isLogin)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _inputField(controller: _nameController, focusNode: _nameFocus, label: 'Ваше имя'.tr(), icon: Icons.person_outline_rounded, textInputAction: TextInputAction.next),
                    ),
                  _inputField(controller: _emailController, focusNode: _emailFocus, label: 'Email'.tr(), icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
                  const SizedBox(height: 20),
                  _inputField(controller: _passwordController, focusNode: _passFocus, label: 'Пароль'.tr(), icon: Icons.lock_outline_rounded, isPassword: true, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit()),
                ]),
              ),
              if (isLogin) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _resetPassword,
                    child: Text('Забыли пароль?'.tr(), style: TextStyle(color: AppColors.mint, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchButton(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isLoading) return;
          if (!isActive) _toggleMode();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isActive ? AppColors.textDark : AppColors.textLight)),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<String>? onSubmitted,
  }) {
    final isActive = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? AppColors.mint : Colors.transparent, width: 1.5),
        boxShadow: isActive ? [BoxShadow(color: AppColors.mint.withOpacity(0.15), blurRadius: 12)] : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isActive ? AppColors.mint : AppColors.textLight, fontSize: 14),
          prefixIcon: Icon(icon, color: isActive ? AppColors.mint : AppColors.textLight, size: 20),
          suffixIcon: isPassword
              ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textHint, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

    Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isLoading ? 56 : MediaQuery.of(context).size.width,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLoading ? 50 : 18),
          gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
          boxShadow: [
            BoxShadow(color: AppColors.mint.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : SingleChildScrollView( 
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'ВОЙТИ'.tr() : 'СОЗДАТЬ АККАУНТ'.tr(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1.5),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(children: [
      Row(children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Или через'.tr(), style: TextStyle(fontSize: 12, color: AppColors.textLight))),
        Expanded(child: Divider(color: AppColors.border)),
      ]),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _socialButton('Google', Icons.g_mobiledata_rounded, Colors.red),
        const SizedBox(width: 20),
        _socialButton('Apple', Icons.apple_rounded, Colors.black),
      ]),
    ]);
  }

  Widget _socialButton(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showSnack('$label скоро будет доступен'.tr(args: [label]), isError: false),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(isLogin ? 'Нет аккаунта? '.tr() : 'Уже есть аккаунт? '.tr(), style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500)),
      GestureDetector(
        onTap: isLoading ? null : _toggleMode,
        child: Text(isLogin ? 'Создать'.tr() : 'Войти'.tr(), style: const TextStyle(color: AppColors.mint, fontWeight: FontWeight.w800)),
      ),
    ]);
  }
}