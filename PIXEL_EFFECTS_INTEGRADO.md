# PixelEffects - Sistema Integrado ✅

## Status: FUNCIONANDO

O sistema PixelEffects foi configurado como Autoload e está totalmente integrado ao jogo.

## Configuração

### Autoload (project.godot)
```
PixelEffects="*res://scripts/PixelEffects.gd"
```

## Integrações Ativas

### 1. Enemy.gd ✅
- **Dano recebido**: Mostra números de dano (normal e crítico)
- **Morte**: Spawna partículas de XP verdes
- Localização: `take_damage()` e `_die()`

### 2. GameManager.gd ✅
- **Level Up**: Efeito de círculo dourado ao subir de nível
- Localização: `_level_up()`

### 3. Player.gd ✅
- **Dano recebido**: Mostra números de dano ao ser atingido
- Localização: `take_damage()`

### 4. Projectile.gd ✅
- Usa sistema de crítico do GameManager
- Dano é calculado e passado para Enemy.gd

## Efeitos Disponíveis

### spawn_xp_particles(position: Vector2)
Cria 4 partículas verdes que voam em direções aleatórias.
```gdscript
PixelEffects.spawn_xp_particles(global_position)
```

### spawn_damage_number(position: Vector2, amount: int, is_crit: bool)
Mostra número de dano flutuante:
- Normal: amarelo, tamanho 14
- Crítico: vermelho com "!", tamanho 20
```gdscript
PixelEffects.spawn_damage_number(global_position + Vector2(0, -20), 50, false)
```

### spawn_level_up_effect(position: Vector2)
Círculo de 8 partículas douradas ao subir de nível.
```gdscript
PixelEffects.spawn_level_up_effect(player.global_position)
```

## Como Testar

1. Abra o projeto no Godot
2. Execute a cena Main (F5)
3. Observe:
   - Números de dano aparecem ao atacar inimigos
   - Partículas verdes quando inimigos morrem
   - Efeito dourado ao subir de nível
   - Números de dano no player ao ser atingido

## Próximos Passos (Opcional)

- Adicionar som aos efeitos
- Criar efeito de dash trail
- Adicionar partículas de cura
- Efeito de combo visual
