# 🎮 Instruções para Testar as Melhorias

## ⚠️ IMPORTANTE - Ajustes nas Cenas

Algumas cenas precisam de pequenos ajustes manuais no editor do Godot para funcionar completamente:

### 1. HUD.tscn - Adicionar Novos Labels

Abra `scenes/HUD.tscn` no editor e adicione:

1. **ComboLabel** (dentro do nó TopRight):
   - Tipo: Label
   - Nome: ComboLabel
   - Posição: Abaixo do TimeLabel
   - Propriedades:
     - Horizontal Alignment: Right
     - Font Size: 16
     - Visible: false (começa invisível)

2. **StatsLabel** (dentro do nó TopRight):
   - Tipo: Label
   - Nome: StatsLabel
   - Posição: Abaixo do ComboLabel
   - Propriedades:
     - Horizontal Alignment: Right
     - Font Size: 12
     - Autowrap Mode: Word

### 2. Testar o Jogo

Após fazer os ajustes acima:

1. Pressione **F5** para rodar o jogo
2. Teste os novos recursos:

## 🎯 Recursos para Testar

### Sistema de Dash
- Pressione **Shift** ou **Espaço** enquanto se move
- Observe o efeito visual azul
- Note a invencibilidade temporária
- Cooldown de 1 segundo entre dashes

### Sistema de Crítico
- Observe projéteis vermelhos maiores (críticos)
- Números de dano com "!" são críticos
- Flash vermelho intenso no inimigo

### Sistema de Combo
- Mate inimigos consecutivamente
- Veja o contador de combo no canto superior direito
- Cores mudam: Amarelo → Laranja → Vermelho
- Combo reseta após 3s sem matar

### Variedade de Inimigos
- **Inimigos Rápidos** (azul/ciano): Aparecem após 1 minuto
- **Inimigos Tanque** (laranja): Aparecem após 1 minuto
- **Boss** (roxo com aura): Aparece a cada 2 minutos

### Novos Upgrades
Ao subir de nível, você pode encontrar:
- 🎲 Chance Crítica
- 💥 Dano Crítico
- 🩸 Roubo de Vida
- ⚡ Dash Aprimorado

### HUD Melhorado
No canto superior direito você verá:
- ⏱️ Tempo sobrevivido
- 🔥 Combo atual (quando ativo)
- ⚔️ Estatísticas do player

## 🐛 Solução de Problemas

### Se o HUD não mostrar combo/stats:
1. Verifique se os nós ComboLabel e StatsLabel existem em HUD.tscn
2. Certifique-se que os nomes estão corretos (case-sensitive)
3. Verifique se estão dentro do nó TopRight

### Se os inimigos variados não aparecerem:
- Aguarde pelo menos 1 minuto de jogo
- Os tipos são aleatórios, continue jogando

### Se o dash não funcionar:
- Certifique-se de estar pressionando Shift ou Espaço
- Precisa estar se movendo (WASD) ao mesmo tempo
- Respeite o cooldown de 1 segundo

## 📊 Estatísticas para Observar

Durante o jogo, observe:
- Dano aumentando com upgrades
- Chance de crítico (começa em 10%)
- Lifesteal (se pegar o upgrade)
- Número de projéteis simultâneos
- Combo multiplicador de XP

## 🎨 Melhorias Visuais

Compare os sprites antigos com os novos:
- **Player**: Agora tem capa roxa e detalhes dourados
- **Inimigos**: Chifres, boca assustadora, mais detalhes
- **Novos tipos**: Cada um com visual único
- **Efeitos**: Críticos têm animações especiais

## ⚡ Dicas de Gameplay

1. **Use o dash defensivamente**: Invencibilidade salva em situações críticas
2. **Mantenha o combo**: +5% XP por nível de combo
3. **Priorize crítico**: Dano explosivo com builds de crítico
4. **Balance upgrades**: Não foque apenas em dano
5. **Lifesteal é poderoso**: Sustain infinito em builds corretas

## 🏆 Desafios

Tente alcançar:
- [ ] Sobreviver 5 minutos
- [ ] Combo de 50+
- [ ] Derrotar um Boss
- [ ] Alcançar nível 10
- [ ] 75% de chance de crítico
- [ ] Sobreviver 10 minutos

---

**Divirta-se testando as melhorias! 🎮**
