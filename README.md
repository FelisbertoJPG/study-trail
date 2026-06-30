# Trilha de Estudos 📚 (estilo Duolingo)

App Flutter de estudo pessoal por **trilhas**. A primeira matéria é
**Desenvolvimento Mobile**, alimentada pelas unidades `T001..T006` da disciplina
e pelas questões das provas (`provas_ead`).

## Como funciona

```
Tela de Módulos  →  Trilha do módulo (nós em zigue-zague)  →  Quiz  →  Resultado
```

- **Módulos** = unidades temáticas (T001 Fundamentos, T002 Ambiente & Kotlin,
  T003 Interface & Acessibilidade, T004 Activities, T005 Persistência,
  T006 Rede & Assíncrono).
- **Trilha de dificuldade**: dentro de cada módulo as questões são ordenadas da
  mais fácil para a mais difícil e agrupadas em **lições** (nós) de até 3
  questões. Os nós liberam em sequência (o próximo só abre ao concluir o
  anterior), igual ao Duolingo.
- **Progresso** (lições concluídas + XP) é salvo localmente com
  `shared_preferences`.

## Estrutura

```
lib/
  main.dart                 # bootstrap: carrega progresso + conteúdo
  app.dart                  # MaterialApp + tema
  theme/app_theme.dart      # paleta estilo Duolingo + mapa de ícones
  models/
    question.dart           # questão de múltipla escolha
    lesson.dart             # nó da trilha (grupo de questões)
    study_module.dart       # módulo; monta as lições por dificuldade
  data/
    content_repository.dart # lê o JSON de questões
    progress_service.dart   # progresso persistente (singleton + ChangeNotifier)
  screens/
    modules_screen.dart     # escolha do módulo
    trail_screen.dart       # a trilha (caminho de nós)
    quiz_screen.dart        # execução da lição + resultado
  widgets/duo_button.dart   # botão com "profundidade"
assets/content/questions.json   # banco de questões (fonte de verdade)
```

## Adicionar / editar questões

Tudo vive em `assets/content/questions.json`. Cada módulo tem uma lista
`questions`; cada questão:

```json
{
  "id": "t00X_qN",
  "difficulty": 1,            // 1 Fácil · 2 Médio · 3 Difícil
  "prompt": "Enunciado...",
  "code": "trecho opcional",  // ou null
  "options": ["...", "..."],
  "answerIndex": 0,            // índice da correta em options
  "explanation": "Por que..."
}
```

As lições da trilha são **geradas automaticamente** a partir dessas questões
(ordenadas por dificuldade). É só adicionar questões — o módulo `T006` está
pronto e vazio, esperando conteúdo de Rede/Assíncrono.

## Rodar

```bash
flutter pub get
flutter run            # Android (dispositivo/emulador)
```

> No **Windows desktop** é preciso ativar o *Modo de Desenvolvedor*
> (`start ms-settings:developers`) por causa do suporte a symlink exigido pelos
> plugins. No Android isso não é necessário.
