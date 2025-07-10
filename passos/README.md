# Contador de Passos (Wear OS + Health Connect)

## Descrição

Aplicativo Android desenvolvido em Flutter (padrão MVVM) que exibe a quantidade de passos dados nas últimas 24 horas, **exclusivamente** contabilizados por um smartwatch com Wear OS, utilizando a API Health Connect.  
**Não é necessário instalar nenhum app no relógio.**  
O app **não coleta dados do telefone** — apenas os passos sincronizados do relógio via Health Connect.

---

## Funcionamento do App

- Ao abrir o app, ele verifica se o Health Connect está disponível e solicita as permissões necessárias.
- Após conceder as permissões, o app busca os dados de passos das últimas 24 horas, **filtrando apenas os dados provenientes do smartwatch**.
- O total de passos, a fonte dos dados e a data/hora da última atualização são exibidos na tela principal.
- O usuário pode atualizar os dados manualmente ou solicitar permissões caso ainda não tenha concedido.

---

## Permissões Utilizadas

- **Leitura de dados de passos (Health Connect):**  
  O app solicita permissão para ler os dados de passos sincronizados via Health Connect.  
  Nenhum dado do telefone é utilizado, apenas dados cuja fonte seja identificada como smartwatch.

---

## Como os dados são acessados via Health Connect

- O app utiliza o pacote [`health`](https://pub.dev/packages/health) para Flutter.
- Os dados são obtidos usando a função `getHealthDataFromTypes` para o tipo `HealthDataType.STEPS`.
- Após obter os dados, o app filtra para considerar apenas aqueles cuja fonte (`sourceName`) contenha termos como `"watch"`, `"wear"`, `"galaxy watch"`, `"pixel watch"` ou `"fitbit"`.
- Se não houver dados do relógio, o app exibe zero passos ou uma mensagem de ausência de dados.

---

## Simulação de Passos no Relógio (Wear OS)

Durante o desenvolvimento, para simular atividade física no relógio, utilize os seguintes comandos ADB (execute no terminal do seu computador, com o relógio conectado via ADB):

```sh
adb devices
adb -s [NOME_DO_EMULADOR_OU_ID] shell am broadcast -a "whs.USE_SYNTHETIC_PROVIDERS" com.google.android.wearable.healthservices
adb -s [NOME_DO_EMULADOR_OU_ID] shell am broadcast -a "whs.synthetic.user.START_WALKING" com.google.android.wearable.healthservices
# Aguarde alguns segundos/minutos para simular passos
adb -s [NOME_DO_EMULADOR_OU_ID] shell am broadcast -a "whs.synthetic.user.STOP_EXERCISE" com.google.android.wearable.healthservices
```

- Substitua `[NOME_DO_EMULADOR_OU_ID]` pelo identificador do seu relógio (veja na lista do comando `adb devices`).
- Após a simulação, aguarde a sincronização dos dados do relógio com o Health Connect no smartphone e atualize os dados no app.

---

## Como rodar o app

1. **Pré-requisitos:**
   - Flutter SDK instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
   - Android Studio ou VS Code com plugin Flutter
   - Um smartphone Android com Health Connect instalado
   - Um smartwatch Wear OS pareado e sincronizado com o smartphone

2. **Instalação das dependências:**
   ```sh
   cd passos
   flutter pub get
   ```

3. **Execução:**
   ```sh
   flutter run
   ```
   - Escolha o dispositivo Android (smartphone) para rodar o app.

4. **Permissões:**
   - Ao abrir o app, conceda as permissões solicitadas para leitura dos dados de passos via Health Connect.

---

## Estrutura do Projeto (MVVM)

- `lib/models/paso_data.dart` — Modelo de dados dos passos
- `lib/services/healt_service.dart` — Serviço de acesso ao Health Connect
- `lib/viewmodels/pasos_viewmodel.dart` — Lógica de apresentação e estado
- `lib/views/home_view.dart` — Interface principal do usuário

---

## Dúvidas Frequentes

- **O app mostra passos do telefone?**  
  Não. O app filtra para mostrar apenas passos do smartwatch.

- **Preciso instalar algo no relógio?**  
  Não. Basta o relógio estar pareado e sincronizado com o Health Connect no smartphone.

- **Como simular passos?**  
  Siga as instruções da seção "Simulação de Passos no Relógio".

---
