# Sprites Coloridos 2D

Esta pasta contém sprites coloridos em formato SVG para o jogo.

## Sprites Disponíveis

### Jogadores
- `player_colorful.svg` - Jogador azul vibrante com olhos e sorriso
- `player_hero.svg` - Herói com capa vermelha e símbolo amarelo

### Inimigos
- `enemy_purple.svg` - Inimigo roxo místico com aura
- `enemy_red.svg` - Inimigo vermelho agressivo (hexagonal)
- `enemy_green.svg` - Inimigo verde tóxico (quadrado)
- `enemy_orange.svg` - Inimigo laranja com espinhos
- `enemy_cyan.svg` - Inimigo ciano gélido (cristal)

### Projéteis
- `projectile_fire.svg` - Projétil de fogo (laranja/amarelo)
- `projectile_yellow.svg` - Projétil amarelo brilhante com raios
- `projectile_blue.svg` - Projétil azul energia (diamante)
- `projectile_green.svg` - Projétil verde venenoso
- `projectile_pink.svg` - Projétil rosa mágico (estrela)

## Como Usar no Godot

1. Arraste os arquivos SVG para o Godot
2. O Godot irá importá-los automaticamente
3. Nas suas cenas (Player.tscn, Enemy.tscn, Projectile.tscn):
   - Selecione o nó Sprite2D
   - Na propriedade "Texture", arraste o sprite desejado
   - Ajuste a escala se necessário

## Dicas

- Os sprites SVG são vetoriais, então não perdem qualidade ao redimensionar
- Você pode modificar as cores editando os arquivos SVG
- Para animar, crie variações dos sprites ou use modulação de cor no Godot
- Use `modulate` no Godot para criar variações de cor em tempo real

## Exemplo de Código GDScript

```gdscript
# Mudar cor do sprite dinamicamente
$Sprite2D.modulate = Color(1.5, 1.0, 1.0)  # Mais vermelho

# Rotacionar projétil
$Sprite2D.rotation += delta * 5.0

# Pulsar inimigo
var pulse = sin(Time.get_ticks_msec() * 0.005) * 0.2 + 1.0
$Sprite2D.scale = Vector2(pulse, pulse)
```
