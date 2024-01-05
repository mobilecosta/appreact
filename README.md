# AppReact
Estrutura de Aplicativo React Native.

## Descrição
Este repositório contém a estrutura básica de um aplicativo React Native integrado com as APIs do Protheus. O objetivo é fornecer um ponto de partida para o desenvolvimento de aplicações web que se conectam ao sistema ERP Protheus.

## Instalação
Para instalar e executar o aplicativo, siga as etapas abaixo:

1. Clone este repositório em sua máquina local. Execute o comando `git clone https://github.com/mobilecosta/appreact.git`

2. Navegue até o diretório raiz do projeto. Execute o comando `cd app`

3. Execute o comando `npm install` para instalar as dependências.

4. Execute o comando `npx expo start` para iniciar o aplicativo.

## Build com EAS Build
O EAS Build é uma ferramenta que simplifica o processo de construção de aplicativos Expo usando a infraestrutura Expo Application Services (EAS). Aqui está um guia passo a passo usando EAS Build:

1. **Passo 1: Instalar o EAS CLI:**
   Certifique-se de ter o EAS CLI instalado globalmente. Se não tiver, você pode instalá-lo usando:

   ```bash
   npm install -g eas-cli
   ```
2. **Passo 2: Login no Expo:**
    Antes de começar, faça login na sua conta Expo usando:
    ```bash
    eas login
    ```

    Você deve fazer login com sua conta expo.

3. **Passo 3:** Apague esse campo do arquivo `app.json`
    ````json
    "extra": {
      // Esse trecho -->
      "eas": {
        "projectId": "9d4cd834-a962-430e-a43e-812dca8b1c3d"
      }
      // fim do trecho
    }
    ````

    O esperado é que fique assim:
    ````json
    {
      "expo": {
        "name": "Robsol",
        "slug": "RobsolApp",
        "version": "1.0.0",
        "orientation": "portrait",
        "icon": "./src/assets/icon.png",
        "userInterfaceStyle": "light",
        "splash": {
          "image": "./src/assets/splash.png",
          "resizeMode": "contain",
          "backgroundColor": "#ffffff"
        },
        "updates": {
          "fallbackToCacheTimeout": 0
        },
        "assetBundlePatterns": ["**/*"],
        "ios": {
          "supportsTablet": true,
          "bundleIdentifier": "n"
        },
        "android": {
          "adaptiveIcon": {
            "foregroundImage": "./src/assets/adaptive-icon.png",
            "backgroundColor": "#FFFFFF"
          },
          "package": "com.felipemayer.robsolapp"
        },
        "web": {
          "favicon": "./src/assets/favicon.png"
        },
        "extra": { /* sem nada aqui */}
      }
    }
    ````
  3. **Passo 4: Iniciar o Build:**
      Agora você está pronto para iniciar o build. Execute:
      ````bash
      eas build
      ````

      Após isso selecione **Android** e depois marque tudo como *Y*
  
  4. **Passo 5: Acompanhe o processo:** Acompanhe o processo dentro do dashboard do expo.

  5. **Passo 6:** Após o build o expo vai disponibilizar um link de download do APK no terminal. Se não encontrar entre no dasboard do expo e selecione o projeto e toque em *Download APK*
