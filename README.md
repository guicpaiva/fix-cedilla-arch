# Fix Cedilha (ç) - Arch / CachyOS / Wayland

Este script corrige o problema comum em distribuições baseadas em Arch Linux (como CachyOS) onde a combinação de teclas `'` + `c` resulta no caractere `ć` em vez de `ç`, especialmente em aplicações baseadas em Chromium/Electron (Brave, Chrome, VS Code, Discord) rodando em Wayland.

## 🚀 Como funciona?
O script utiliza o **Fcitx5** como framework de entrada. Ele intercepta a digitação, aplica as regras do seu `.XCompose` e entrega o caractere correto para as aplicações, ignorando a lógica interna "quebrada" do Chromium.

## 🛠️ O que o script faz:
1. Instala o `fcitx5` e seus módulos (GTK/QT) via `pacman`.
2. Cria/Configura o arquivo `~/.XCompose` traduzindo `ć` para `ç`.
3. Define as variáveis de ambiente necessárias em `/etc/environment`.
4. Configura o layout `us-intl` no perfil do Fcitx5.
5. Adiciona o Fcitx5 ao início automático do sistema.

## 📦 Instalação

1. Clone este repositório:
   ```bash
   git clone https://github.com/guicpaiva/fix-cedilla-arch.git
   cd fix-cedilla-arch
   
2. Dê permissão de execução:

```bash
chmod +x fix-cedilla-arch.sh
```

3. Execute o script:

```Bash
./fix-cedilla-arch.sh
```

Reinicie o computador para aplicar todas as mudanças de variáveis de ambiente.

🔄 Como Reverter

Se por algum motivo você quiser remover as alterações, o script possui uma função de reversão:

```Bash
./fix-cedilla-arch --revert
```

🤝 Créditos

Este script é um fork/adaptação para Arch Linux do projeto original fix-cedilla-popos de @walcew, que foi desenvolvido inicialmente para Pop!_OS.
