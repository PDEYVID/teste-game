# 🎮 Vampire Survivors Clone — Godot 4

Jogo 2D top-down survival inspirado em Vampire Survivors, desenvolvido em Godot 4 com GDScript.

---

## 📁 Estrutura do Projeto

```
Nova pasta/
├── project.godot          # Configuração do projeto Godot 4
├── icon.svg               # Ícone do projeto
├── scenes/
│   ├── Main.tscn          # Cena principal (raiz do jogo)
│   ├── Player.tscn        # Personagem do jogador
│   ├── Enemy.tscn         # Inimigo básico
│   ├── Projectile.tscn    # Projétil do ataque automático
│   ├── EnemySpawner.tscn  # Sistema de spawn de inimigos
│   ├── HUD.tscn           # Interface do jogador (HP, XP, Tempo)
│   ├── UpgradeScreen.tscn # Tela de escolha de upgrade
│   └── GameOverScreen.tscn# Tela de game over
└── scripts/
    ├── GameManager.gd     # Singleton: estado global, XP, upgrades
    ├── Main.gd            # Orquestrador da cena principal
    ├── Player.gd          # Movimento, HP, morte do player
    ├── WeaponSystem.gd    # Ataque automático e projéteis
    ├── Projectile.gd      # Lógica do projétil
    ├── Enemy.gd           # IA do inimigo, dano por contato
    ├── EnemySpawner.gd    # Spawn em ondas com dificuldade crescente
    ├── HUD.gd             # Atualização da interface
    ├── UpgradeScreen.gd   # Lógica da tela de upgrades
    └── GameOverScreen.gd  # Lógica do game over e reinício
```

---

## 🚀 Como Abrir no Godot 4

1. **Instale o Godot 4** (versão 4.2 ou superior): https://godotengine.org/download
2. Abra o **Godot Project Manager**
3. Clique em **"Import"**
4. Navegue até esta pasta e selecione o arquivo `project.godot`
5. Clique em **"Import & Edit"**
6. Pressione **F5** ou clique no botão ▶ para rodar o jogo

---

## 🎮 Controles

| Tecla | Ação |
|-------|------|
| W / ↑ | Mover para cima |
| S / ↓ | Mover para baixo |
| A / ← | Mover para esquerda |
| D / → | Mover para direita |
| **Shift / Espaço** | **Dash/Esquiva (NOVO!)** |

> O ataque é **automático** — o player atira no inimigo mais próximo!
> Use o **dash** para esquivar de situações perigosas com invencibilidade temporária!

---

## 🧩 Tasks Implementadas

### ✅ TASK 1 — Setup do Projeto
- Projeto Godot 4 configurado
- Cena principal `Main.tscn` criada
- Resolução fixa 1280×720
- Sistema de input WASD + setas

### ✅ TASK 2 — Player
- Movimento em 8 direções com normalização diagonal
- Sistema de HP com barra visual
- I-frames (invencibilidade temporária) após tomar dano
- Efeito visual de piscar ao tomar dano
- Morte ao chegar em 0 HP

### ✅ TASK 3 — Inimigos
- Inimigos perseguem o player
- Spawn automático em ondas infinitas
- Dano por contato com cooldown
- Barra de HP individual

### ✅ TASK 4 — Sistema de Ataque Automático
- Ataque automático por timer
- Mira no inimigo mais próximo dentro do raio
- Sistema de cooldown configurável
- Suporte a múltiplos projéteis (multishot)

### ✅ TASK 5 — Experiência e Level Up
- Inimigos dropam XP ao morrer
- XP acumula e dispara level up
- Tela de escolha de upgrade ao subir de nível
- XP necessário cresce 20% por nível

### ✅ TASK 6 — Upgrades
- ⚔ **Mais Dano**: +10 de dano por projétil
- 💨 **Mais Velocidade**: +30 de velocidade
- 🎯 **Mais Alcance**: +30 de raio de ataque
- ⚡ **Ataque Rápido**: -0.2s de cooldown
- ❤ **Mais Vida**: +25 HP máximo + cura
- 🔱 **Multishot**: +1 projétil por ataque
- 🎲 **Chance Crítica**: +10% chance de crítico (NOVO!)
- 💥 **Dano Crítico**: +0.5x multiplicador de crítico (NOVO!)
- 🩸 **Roubo de Vida**: +10% de lifesteal (NOVO!)
- ⚡ **Dash Aprimorado**: -0.3s cooldown do dash (NOVO!)

### ✅ TASK 7 — HUD
- Barra de HP com valores numéricos
- Barra de XP
- Nível atual
- Tempo sobrevivido (MM:SS)

### ✅ TASK 8 — Game Over
- Tela de Game Over com overlay escuro
- Exibe tempo sobrevivido
- Botão de reiniciar (reseta o GameManager e recarrega a cena)

---

## 🏗 Arquitetura

### Separação de Responsabilidades
- **GameManager** (Autoload): Estado global, XP, upgrades, tempo
- **Player.gd**: Apenas movimento e HP
- **WeaponSystem.gd**: Apenas lógica de ataque
- **EnemySpawner.gd**: Apenas spawn e dificuldade
- **Enemy.gd**: Apenas IA e dano do inimigo

### Comunicação entre Sistemas
- Usa **sinais** (signals) para comunicação reativa
- `GameManager` emite sinais de XP, level up e game over
- `HUD` e `UpgradeScreen` escutam esses sinais

### Dificuldade Progressiva
- Intervalo de spawn diminui com o tempo
- Stats dos inimigos escalam com o tempo sobrevivido
- Mais inimigos por onda a cada minuto

---

## 🔧 Configuração de Collision Layers

| Layer | Uso |
|-------|-----|
| 1 | Player |
| 2 | Inimigos |
| 4 | Projéteis |

---

## 🎯 Próximos Passos (Desafio Extra)

- [x] Sistema de dash/esquiva com invencibilidade
- [x] Sistema de crítico com visuais especiais
- [x] Sistema de combo para XP bônus
- [x] Sistema de lifesteal (roubo de vida)
- [x] Variedade de inimigos (rápido, tanque, boss)
- [x] Sprites aprimorados e mais detalhados
- [x] HUD melhorado com estatísticas
- [x] 4 novos upgrades
- [ ] Sistema de armas diferentes (espada, magia, etc.)
- [ ] Power-ups temporários que caem dos inimigos
- [ ] Progressão meta com ouro entre partidas
- [ ] Efeitos de partículas avançados
- [ ] Música e efeitos sonoros
- [ ] Sistema de conquistas

**📄 Veja MELHORIAS.md para detalhes completos de todas as melhorias implementadas!**
