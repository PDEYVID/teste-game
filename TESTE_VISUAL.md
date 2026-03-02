# Teste Visual - Checklist de Melhorias

## ✅ O que você DEVE ver ao executar o jogo (F5)

### Canto Superior Esquerdo (HUD)
- [ ] Painel escuro semi-transparente com borda cinza
- [ ] Barra de HP vermelha dentro do painel
- [ ] Barra de XP verde dentro do painel
- [ ] Texto "⭐ NÍVEL 1" em amarelo com sombra preta
- [ ] Textos maiores e mais legíveis

### Canto Superior Direito
- [ ] Outro painel escuro semi-transparente
- [ ] Tempo "⏱ 00:00" em branco grande (32px)
- [ ] Stats do player (⚔ dano, 🎯 crítico, etc)
- [ ] Todos os textos com sombra

### Ao Subir de Nível
- [ ] Cards de upgrade MAIORES (280x380px)
- [ ] Indicador de raridade no topo (COMUM/RARO/ÉPICO)
- [ ] Ícones GRANDES (80px)
- [ ] Ao passar o mouse: card cresce e brilha
- [ ] Ao clicar: flash branco na tela

### Ao Morrer
- [ ] Título "💀 GAME OVER 💀" grande em vermelho
- [ ] Ranking (💀 INICIANTE, 🥉 BRONZE, etc)
- [ ] Mais estatísticas (nível, dano, projéteis, etc)
- [ ] Botão "🔄 JOGAR NOVAMENTE" grande
- [ ] Ao passar o mouse no botão: ele cresce

## 🔍 Se NÃO estiver vendo as mudanças:

### Opção 1: Recarregar Scripts
1. No Godot, vá em: **Project → Reload Current Project**
2. Execute o jogo novamente (F5)

### Opção 2: Verificar Erros
1. Execute o jogo (F5)
2. Olhe na aba **Output** (parte inferior do Godot)
3. Procure por linhas em vermelho (erros)
4. Se houver erros, copie e me mostre

### Opção 3: Verificar Cena
1. Abra `scenes/Main.tscn`
2. Verifique se existe um nó chamado "HUD"
3. Clique nele e veja no Inspector se o script está anexado
4. O script deve ser: `res://scripts/HUD.gd`

### Opção 4: Limpar Cache
1. Feche o Godot completamente
2. Delete a pasta `.godot` (ela será recriada)
3. Abra o Godot novamente
4. Execute o jogo (F5)

## 📸 Comparação Visual

### ANTES (interface antiga)
```
┌─────────────────────────────────────┐
│ HP: 100/100                         │
│ XP: 0/100                           │
│ Nível 1                             │
│                                     │
│         (sem painéis de fundo)      │
└─────────────────────────────────────┘
```

### DEPOIS (interface melhorada)
```
┌─────────────────────────────────────┐
│ ╔═══════════════════╗               │
│ ║ HP  [████████] 100║               │
│ ║ XP  [████░░░░]  50║               │
│ ║ ⭐ NÍVEL 1        ║               │
│ ╚═══════════════════╝               │
│    (painel com borda e sombras)     │
└─────────────────────────────────────┘
```

## 🎯 Teste Específico

Execute este teste passo a passo:

1. **Inicie o jogo** (F5)
2. **Olhe para o canto superior esquerdo**
   - Você vê um retângulo escuro atrás das barras? ✅/❌
3. **Deixe o inimigo te atacar até HP < 30%**
   - A barra de HP fica vermelha e pulsa? ✅/❌
4. **Mate inimigos até subir de nível**
   - Os cards são grandes e coloridos? ✅/❌
5. **Passe o mouse sobre um card**
   - O card cresce e brilha? ✅/❌
6. **Clique em um upgrade**
   - Há um flash branco? ✅/❌
7. **Morra no jogo**
   - Aparece um ranking (Bronze/Prata/Ouro)? ✅/❌

## 💬 Me Diga

Qual destes você está vendo?

A) Tudo funcionando perfeitamente ✅
B) Vejo algumas melhorias mas não todas 🤔
C) Não vejo nenhuma mudança ❌
D) O jogo dá erro ao executar ⚠️

Se for B, C ou D, me diga exatamente o que você vê (ou não vê) e posso ajudar!
