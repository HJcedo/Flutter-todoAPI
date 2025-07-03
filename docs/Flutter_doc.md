# 📘 Documentação Técnica - Flutter Todo App

Este documento descreve a **estrutura de pastas**, os **principais componentes**, os **fluxos de navegação** e as **dependências** do aplicativo Flutter para gerenciamento de tarefas.

---

## 🗂 Estrutura de Pastas

```
lib/
├── core/
│   ├── constants/
│   │   └── api_routes.dart
│   ├── models/
│   │   ├── task_model.dart
│   │   └── user_model.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── interceptors.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── token_storage.dart
│   └── utils/
│       └── result.dart
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart *(opcional)*
│   │   └── profile/
│   │       └── profile_page.dart
│   ├── tasks/
│   │   ├── data/
│   │   │   └── tasks_repository.dart
│   │   └── presentation/
│   │       ├── tasks_page.dart
│   │       ├── task_detail_page.dart
│   │       └── task_form_sheet.dart
│
├── router/
│   └── router.dart
│
├── theme/
│   └── theme.dart
│
├── bootstrap.dart
└── main.dart
```

---

## 🧩 Componentes Principais

### Core

- **api\_routes.dart**

  - Define `baseUrl` da API.

- **models/**

  - `Task`: modelo de tarefa (id, título, descrição, status, imagem).
  - `User`: modelo de usuário (id, nome, email).

- **network/**

  - `dio_client.dart`: instancia `Dio` com interceptores.
  - `interceptors.dart`: insere token nas requisições e renova automaticamente.

- **services/**

  - `auth_service.dart`: login, registro, logout.
  - `token_storage.dart`: armazenamento persistente de token e credenciais.

- **utils/result.dart**

  - Wrapper genérico `Result<T>` para operações assíncronas.

### Features

- **auth/presentation/login\_page.dart**

  - Tela de login com validação de formulário.

- **auth/presentation/register\_page.dart**

  - Tela de cadastro de usuário.

- **auth/profile/profile\_page.dart**

  - Tela de perfil do usuário logado.

- **tasks/data/tasks\_repository.dart**

  - CRUD de tarefas e upload de imagens.

- **tasks/presentation/**

  - `tasks_page.dart`: lista de tarefas.
  - `task_detail_page.dart`: detalhes e exclusão.
  - `task_form_sheet.dart`: formulário para criar/editar tarefas.

### Router

- `router.dart`
  - Define todas as rotas (`/login`, `/register`, `/tasks`, `/tasks/:id`, `/profile`).
  - Redireciona conforme estado de autenticação.

### Theme

- `theme.dart`
  - Define `ThemeData` com Material 3 e paleta base Deep Purple.

---

## ⚙️ Fluxo de Navegação

- **Sem autenticação**: usuário é redirecionado para `/login`.
- **Autenticado**:
  - `/tasks`: lista e gerencia tarefas.
  - `/tasks/:id`: detalha uma tarefa.
  - `/profile`: visualiza perfil.
- **Logout**: apaga token e volta para login.

---

## 📦 Dependências Importantes

- `dio`: cliente HTTP.
- `go_router`: rotas declarativas.
- `json_serializable`: serialização automática.
- `shared_preferences`: armazenamento local.
- `image_picker`: seleção de imagens.

---

## 🚀 Execução e Build

Para executar:

```
flutter pub get
flutter run
```

Para gerar código:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 👥 Contato

Para dúvidas, consulte o repositório:

[https://github.com/HJcedo/Flutter-todoAPI](https://github.com/HJcedo/Flutter-todoAPI)

