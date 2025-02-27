# App Consultas Médicas <img src="https://skillicons.dev/icons?i=flutter,dart" alt="Flutter & Dart Icons" style="vertical-align: middle; height: 35px;"/>

## 1. Visão Geral

O **App Consultas Médicas** é uma aplicação desenvolvida em Flutter que permite o gerenciamento de consultas médicas, oferecendo funcionalidades tanto para médicos quanto para pacientes. O aplicativo foi projetado para facilitar o agendamento de consultas e gerenciamento de disponibilidade médica.

## 2. Funcionalidades

Abaixo estão listadas as principais funcionalidades do projeto:

| Funcionalidade | Descrição |
| -------------- | --------- |
| **Autenticação de Usuários** | Sistema de login e registro para médicos e pacientes |
| **Agendamento de Consultas** | Interface para pacientes agendarem consultas com médicos |
| **Gestão de Disponibilidade** | Médicos podem gerenciar seus horários disponíveis |
| **Visualização de Consultas** | Pacientes e médicos podem ver suas consultas agendadas |
| **Estatísticas** | Visualização de dados estatísticos sobre consultas |
| **Notificações** | Sistema de notificações para lembretes de consultas |

## 3. Tecnologias Utilizadas

- **Linguagens**: [Dart](https://dart.dev/)
- **Framework**: [Flutter](https://flutter.dev/)
- **Arquitetura**: MVVM (Model-View-ViewModel)

## 4. Estrutura do Projeto

```
lib/
├── models/
│   ├── appointment.dart        # Modelo de consultas
│   ├── doctor_availability.dart # Modelo de disponibilidade médica
│   └── user.dart               # Modelo de usuário
├── services/
│   ├── appointment_service.dart      # Serviço de consultas
│   ├── auth_service.dart             # Serviço de autenticação
│   ├── doctor_availability_service.dart # Serviço de disponibilidade
│   ├── notification_service.dart      # Serviço de notificações
│   ├── statistics_service.dart        # Serviço de estatísticas
│   └── user_service.dart             # Serviço de usuários
├── viewmodels/
│   ├── appointment_viewmodel.dart     # ViewModel de consultas
│   ├── auth_viewmodel.dart           # ViewModel de autenticação
│   ├── doctor_availability_viewmodel.dart # ViewModel de disponibilidade
│   └── statistics_viewmodel.dart      # ViewModel de estatísticas
├── views/
│   ├── doctor_appointments_view.dart  # Tela de consultas do médico
│   ├── doctor_availability_view.dart  # Tela de disponibilidade
│   ├── doctor_patients_view.dart      # Tela de pacientes do médico
│   ├── home_view.dart                 # Tela inicial
│   ├── login_view.dart                # Tela de login
│   ├── onboarding_view.dart           # Tela de introdução
│   ├── patient_appointments_view.dart  # Tela de consultas do paciente
│   ├── register_view.dart             # Tela de registro
│   ├── schedule_appointment_view.dart  # Tela de agendamento
│   ├── splash_view.dart               # Tela de splash
│   └── statistics_view.dart           # Tela de estatísticas
└── main.dart                          # Arquivo principal
```

## 5. Configuração e Execução

### 5.1. Pré-requisitos

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Editor de código (VS Code ou Android Studio)
- Git instalado

### 5.2. Clonar o Repositório

```bash
git clone https://github.com/FelipeTiLustosa/app_consultasMedicas-flutter.git
cd app_consultasMedicas-flutter
```

### 5.3. Configurar e Executar

```bash
flutter pub get
flutter run
```

## 6. Contribuição

Contribuições são bem-vindas! Para contribuir com o projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Realize as alterações e teste
4. Envie um pull request para revisão

## 7. Imagens do Projeto:
<p align="center">
  <img src="https://github.com/user-attachments/assets/67bc9bc5-dbe2-4c83-bac1-7d518d11fc66" alt="Captura de tela 2025-02-26 172506" width="280" style="margin-right:10px;">
  <img src="https://github.com/user-attachments/assets/f43d5a96-7159-4374-9b6c-2d562c819390" alt="Captura de tela 2025-02-26 172519" width="290" style="margin-right:10px;">
  <img src="https://github.com/user-attachments/assets/331f55cd-0a17-465a-9765-fdce0dc249c8" alt="Captura de tela 2025-02-26 172712" width="295">
</p>





## 8. Link do vídeo explicativo sobre o projeto

[Link do vídeo demonstrativo](https://www.youtube.com/watch?v=WzkBGPnRXmU)
