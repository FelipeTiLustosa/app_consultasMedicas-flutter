import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authCodeController = TextEditingController();
  DateTime? _selectedDate;
  bool _isDoctor = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final success = await context.read<AuthViewModel>().register(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            isDoctor: _isDoctor,
            specialization: _isDoctor ? _specializationController.text : null,
            birthDate: _selectedDate!,
            phoneNumber: _phoneController.text,
            doctorAuthCode: _isDoctor ? _authCodeController.text : null,
          );

      if (success && mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cadastro Realizado'),
            content: const Text('Seu cadastro foi realizado com sucesso! Por favor, faça login para continuar.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Navigate back to login screen
        if (mounted) {
          Navigator.of(context).pop(); // This will take user back to login screen
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu telefone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de Nascimento'),
                  subtitle: Text(
                    _selectedDate == null
                        ? 'Selecione uma data'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Sou médico'),
                  value: _isDoctor,
                  onChanged: (bool value) {
                    setState(() {
                      _isDoctor = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_isDoctor) ...[  
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'Especialização',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isDoctor && (value == null || value.isEmpty)) {
                        return 'Por favor, insira sua especialização';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _authCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Autenticação',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isDoctor && (value == null || value.isEmpty)) {
                        return 'Por favor, insira o código de autenticação';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: authVM.isLoading ? null : _register,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: authVM.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Cadastrar'),
                          ),
                        ),
                        if (authVM.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              authVM.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}