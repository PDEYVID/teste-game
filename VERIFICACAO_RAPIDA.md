# ⚡ Verificação Rápida - Solução de Problemas

## 🎯 Problema: Sprites não aparecem (jogo parece nave)

### Solução Rápida:

1. **Verifique os Autoloads:**
   - Menu: `Project > Project Settings > Autoload`
   - Deve ter:
     - `SpriteGenerator` → `res://scripts/SpriteGenerator.gd`
     - `GameManager` → `res://scripts/GameManager.gd`
     - `PixelEffects` → `res://scripts/PixelEffects.gd`

2. **Verifique o Console:**
   - Ao rodar o jogo (F5), deve aparecer:
   ```
   Sprite gerado: player - Tamanho: 48x48
   Sprite gerado: enemy - Tamanho: 48x48
   ```
   - Se não aparecer, há erro no SpriteGenerator

3. **Teste Simples:**
   - Abra `scenes/Player.tscn`
   - Selecione o nó `Sprite2D`
   - Verifique se `Texture Filter` está em `Nearest`
   - Salve e teste novamente

## 🎯 Problema: Inimigos não atacam

### Solução Rápida:

1. **Verifique Collision Layers:**
   - Abra `scenes/Player.tscn`
   - Selecione o nó raiz `Player`
   - No Inspector, verifique:
     - `Collision Layer`: Layer 1 (marcado)
     - `Collision Mask`: Layer 2 (marcado)
   
   - Abra `scenes/Enemy.tscn`
   - Selecione o nó raiz `Enemy`
   - No Inspector, verifique:
     - `Collision Layer`: Layer 2 (marcado)
     - `Collision Mask`: Layer 1 (marcado)

2. **Teste de Distância:**
   - Adicione este código temporário em `scripts/Enemy.gd` na linha 50:
   ```gdscript
   func _physics_process(delta: float) -> void:
       if player == null or not is_instance_valid(player):
           return
       
       var dist = global_position.distance_to(player.global_position)
       if dist < 50:
           print("Inimigo perto do player! Distância: ", dist)
       
       _move_towards_player(delta)
       _handle_bob_animation(delta)
       _handle_contact_damage(delta)
   ```
   - Se aparecer mensagens no console, a detecção está funcionando

3. **Verifique CollisionShape2D:**
   - Abra `scenes/Enemy.tscn`
   - Selecione `CollisionShape2D`
   - Certifique-se que está visível (ícone de olho aberto)
   - Certifique-se que `Disabled` está DESMARCADO

## 🔧 Correção Definitiva

Se nada funcionar, siga estes passos:

### Passo 1: Limpar Cache
```bash
# Feche o Godot
# Delete a pasta .godot/
# Abra o projeto novamente
```

### Passo 2: Recriar Cenas (se necessário)

**Player.tscn:**
1. Crie novo CharacterBody2D
2. Adicione CollisionShape2D (CapsuleShape2D)
3. Adicione Sprite2D
4. Adicione ColorRect para sombra
5. Adicione WeaponSystem (Node2D)
6. Configure collision: Layer 1, Mask 2
7. Anexe script `Player.gd`

**Enemy.tscn:**
1. Crie novo CharacterBody2D
2. Adicione CollisionShape2D (CapsuleShape2D)
3. Adicione Sprite2D
4. Adicione ColorRect para sombra
5. Adicione HPBarBG (ColorRect) com Fill dentro
6. Configure collision: Layer 2, Mask 1
7. Anexe script `Enemy.gd`

### Passo 3: Verificar Estrutura

Execute este comando no terminal do Godot (Debug > Console):
```gdscript
print("Player groups: ", $Player.get_groups())
print("Enemy count: ", get_tree().get_nodes_in_group("enemies").size())
print("SpriteGenerator exists: ", SpriteGenerator != null)
```

## 🎮 Teste Mínimo Funcional

Crie uma cena de teste simples:

1. **Crie `test_sprites.tscn`:**
```
Node2D (raiz)
├─ Sprite2D (nome: TestPlayer)
└─ Sprite2D (nome: TestEnemy)
```

2. **Crie `test_sprites.gd`:**
```gdscript
extends Node2D

func _ready():
    $TestPlayer.texture = SpriteGenerator.get_player_texture()
    $TestPlayer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    $TestPlayer.position = Vector2(200, 200)
    
    $TestEnemy.texture = SpriteGenerator.get_enemy_texture()
    $TestEnemy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    $TestEnemy.position = Vector2(400, 200)
    
    print("Teste de sprites concluído!")
```

3. **Execute a cena de teste (F6)**
   - Se os sprites aparecerem, o problema está nas cenas principais
   - Se não aparecerem, o problema está no SpriteGenerator

## 📞 Informações para Debug

Se ainda não funcionar, forneça estas informações:

1. **Versão do Godot:**
   - Menu: `Help > About`
   - Copie a versão completa

2. **Console Output:**
   - Copie TODAS as mensagens do console ao iniciar o jogo

3. **Screenshot:**
   - Tire print do jogo rodando
   - Tire print da estrutura da cena (Scene tree)

4. **Teste este código no console:**
```gdscript
print("=== DEBUG INFO ===")
print("SpriteGenerator: ", SpriteGenerator)
print("GameManager: ", GameManager)
print("Player texture: ", SpriteGenerator.get_player_texture())
print("Enemy texture: ", SpriteGenerator.get_enemy_texture())
```

## ✅ Checklist Final

Antes de pedir ajuda, confirme:

- [ ] Godot 4.2 ou superior instalado
- [ ] Autoloads configurados corretamente
- [ ] Collision layers configuradas (Player: 1/2, Enemy: 2/1)
- [ ] Nós Sprite2D existem nas cenas
- [ ] Scripts anexados aos nós corretos
- [ ] Sem erros no console ao iniciar
- [ ] Teste de sprites simples funcionou

---

**90% dos problemas são resolvidos verificando Autoloads e Collision Layers!**
