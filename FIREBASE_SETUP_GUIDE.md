# Guia Passo a Passo: Configuração do Firebase & Google Sign-In
## Aplicativo Secretaria - Fraternidade Misericórdia Materna

Este guia prático fornece o passo a passo completo para configurar o projeto no **Firebase Console**, autorizar o **Google Sign-In** no Android, iOS e Web, extrair os certificados **SHA-1 / SHA-256** e definir as regras de segurança no **Firestore** e **Firebase Storage**.

---

## 1. Criação do Projeto no Firebase
1. Acesse o [Firebase Console](https://console.firebase.google.com/).
2. Clique em **Adicionar projeto** e nomeie como `misericordia-materna-sec` (ou nome de sua preferência).
3. Habilite o Google Analytics (recomendado) e conclua a criação.

---

## 2. Habilitação da Autenticação (Firebase Auth)
1. No menu lateral, acesse **Build > Authentication** e clique em **Primeiros passos**.
2. Na aba **Sign-in method**, ative:
   - **E-mail/senha**: ative a opção principal e salve.
   - **Google**: ative o provedor, selecione o e-mail de suporte do projeto e salve.
3. Na aba **Settings > Authorized domains**, verifique se `localhost` e seu domínio `app.misericordiamaterna.org` estão autorizados.

---

## 3. Configuração do Android (SHA-1, SHA-256 & Google Services)

### 3.1 Obter as chaves SHA-1 e SHA-256 no Mac
Abra o terminal na pasta raiz do projeto e execute:
```bash
cd android
./gradlew signingReport
```
*(Se preferir via `keytool` usando o Java embutido no Android Studio no Mac):*
```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -J-Duser.language=en -J-Duser.country=US -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Localize no terminal as linhas:
- `SHA1: XX:XX:XX:...`
- `SHA256: YY:YY:YY:...`

### 3.2 Adicionar as chaves no Firebase Console
1. No Firebase Console, vá em **Configurações do Projeto (ícone de engrenagem) > Geral**.
2. Na seção **Seus aplicativos**, clique no ícone do **Android**.
3. Informe o nome do pacote (conforme o `android/app/build.gradle.kts`): `br.com.misericordia.materna.app_secretaria`.
4. Cole os certificados **SHA-1** e **SHA-256**.
5. Baixe o arquivo `google-services.json` e mova-o para a pasta:
   ```
   android/app/google-services.json
   ```

---

## 4. Configuração do iOS (GoogleService-Info.plist & URL Types)

1. No Firebase Console, clique em **Adicionar app > iOS**.
2. Informe o **ID do pacote / Bundle ID**: `br.com.misericordia.materna.appSecretaria`.
3. Baixe o arquivo `GoogleService-Info.plist` e adicione-o na pasta:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
4. Abra o arquivo `ios/Runner/Info.plist` e adicione o esquema de URL invertido (`REVERSED_CLIENT_ID` que consta dentro do seu `GoogleService-Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Substitua pelo valor de REVERSED_CLIENT_ID do seu GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.SEU_CLIENT_ID_INVERTIDO</string>
        </array>
    </dict>
</array>
```

---

## 5. Configuração da Web, Firebase Hosting & Variáveis de Ambiente (.env)

Como o domínio próprio `app.misericordiamaterna.org` ainda não foi registrado, utilizaremos o **Firebase Hosting**, que fornece gratuitamente domínios com certificado SSL automático:
- `https://<PROJECT_ID>.web.app`
- `https://<PROJECT_ID>.firebaseapp.com`

### 5.1 Criar o Site no Firebase Hosting (Console)
1. No Firebase Console, acesse o menu lateral **Build > Hosting** e clique em **Primeiros passos**.
2. Conclua o assistente inicial (o projeto já possui o arquivo `firebase.json` pré-configurado na raiz para Flutter Web Single Page App).
3. Vá em **Build > Authentication > Settings > Authorized domains** e verifique se `<PROJECT_ID>.web.app` e `<PROJECT_ID>.firebaseapp.com` estão listados como domínios autorizados (eles costumam ser adicionados automaticamente ao criar o Hosting).

### 5.2 Preencher o `.env`
No Firebase Console, em **Configurações do Projeto > Geral**, adicione um app Web (`</>`), copie os dados e preencha o `.env`:
```env
# Administrador Mestre Inicial (Bootstrap)
INITIAL_ADMIN_EMAIL=nando.djx@gmail.com

# Formato base do link de convite oficial (Firebase Hosting)
INVITE_BASE_URL=https://<SEU_PROJECT_ID>.web.app/convite

# Configurações do Firebase Web
FIREBASE_API_KEY=AIzaSy...
FIREBASE_APP_ID=1:...:web:...
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_PROJECT_ID=<SEU_PROJECT_ID>
FIREBASE_AUTH_DOMAIN=<SEU_PROJECT_ID>.firebaseapp.com
FIREBASE_STORAGE_BUCKET=<SEU_PROJECT_ID>.firebasestorage.app
FIREBASE_MEASUREMENT_ID=G-...
```

### 5.3 Como Fazer o Deploy do Site no Firebase Hosting
Já deixamos configurado na raiz do projeto o arquivo `firebase.json` com roteamento SPA (Single Page Application) e cache otimizado para o Flutter Web.

Para publicar o app na web:
1. **Instale a CLI do Firebase** (se ainda não tiver):
   ```bash
   npm install -g firebase-tools
   ```
2. **Faça login na sua conta Google/Firebase**:
   ```bash
   firebase login
   ```
3. **Defina o projeto ativo**:
   ```bash
   firebase use <SEU_PROJECT_ID>
   ```
4. **Compile o Flutter para Web em modo de produção**:
   ```bash
   flutter build web --release
   ```
5. **Faça o deploy do site**:
   ```bash
   firebase deploy --only hosting
   ```

Ao concluir, o terminal exibirá a URL oficial do seu app:
`Hosting URL: https://<SEU_PROJECT_ID>.web.app`

Os links de convite gerados pelo painel administrativo funcionarão imediatamente como:
`https://<SEU_PROJECT_ID>.web.app/convite?codigo=TOKEN_XYZ`

*(Futuro: quando registrar o domínio `app.misericordiamaterna.org`, basta ir em Hosting > "Adicionar domínio personalizado", apontar o DNS e atualizar a variável `INVITE_BASE_URL` no `.env`).*

---

## 6. Regras de Segurança do Cloud Firestore (`firestore.rules`)

No Firebase Console, acesse **Build > Firestore Database > Regras** e publique:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Função auxiliar para verificar se está autenticado
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Função para verificar se é o Fundador
    function isFundador() {
      return isAuthenticated() && (
        request.auth.token.email == 'nando.djx@gmail.com' ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'fundador'
      );
    }

    // Coleção de Usuários / Membros
    match /users/{userId} {
      allow read: if isAuthenticated();
      // O próprio usuário pode atualizar sua ficha, e o Fundador tem poder total
      allow create, update: if isAuthenticated() && (request.auth.uid == userId || isFundador());
      allow delete: if isFundador();
    }

    // Coleção de Convites
    match /invites/{inviteId} {
      // Leitura permitida para quem possui o link/código validar o convite
      allow read: if true;
      // Criação e revogação apenas por perfis autorizados (Fundador e Secretarias)
      allow create, update: if isAuthenticated();
      allow delete: if isFundador();
    }
  }
}
```

---

## 7. Regras de Segurança do Firebase Storage (`storage.rules`)

No Firebase Console, acesse **Build > Storage > Regras** e publique:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}.jpg {
      // Qualquer membro autenticado pode visualizar as fotos
      allow read: if request.auth != null;
      // O usuário pode subir apenas sua própria foto, no formato JPEG e com tamanho < 1MB
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 1 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 8. Como Testar o Primeiro Login de Fundador (Bootstrap)
1. Certifique-se de que o `.env` contém:
   ```env
   INITIAL_ADMIN_EMAIL=nando.djx@gmail.com
   ```
2. Inicie a aplicação (`flutter run -d chrome` ou em seu dispositivo Android/iOS).
3. Faça login com a conta Google de `nando.djx@gmail.com` ou cadastre esse e-mail.
4. O sistema detectará o e-mail e concederá o papel de **Fundador** (`role: 'fundador'`).
5. Acesse o card **"Gerenciar Links de Convite"** para criar convites oficiais para os demais formadores, secretárias e membros!
