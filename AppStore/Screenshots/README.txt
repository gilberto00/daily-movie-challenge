App Store Connect — screenshots (iPhone 6.5")
============================================

Pasta: AppStore/Screenshots/

01-home-daily-challenge.png … 06-notification-settings.png
  • Cópias de trabalho com os nomes certos (ordem sugerida para a loja).
  • Se estiverem a ~470×1024 px, foram reduzidas (ex.: ao passar pelo chat).
    A App Store Connect NÃO aceita esse tamanho.

for-app-store-connect-1284x2778/
  • PNGs a 1284×2778 px — dimensão VÁLIDA para o slot "iPhone 6.5\" Display".
  • Estes foram gerados a partir das cópias acima: servem para o Connect aceitar
    o upload, mas estão AMPLIADOS a partir de imagens pequenas → podem ficar
    TUVIDOS. Para material de loja nítido, use SEMPRE o fluxo abaixo.

Fluxo recomendado (máxima qualidade)
--------------------------------------
1. Simulator → File → Save Screen Shot (⌘S). Os ficheiros ficam no Desktop
   com resolução NATIVA do dispositivo (ex. centenas de KB ou mais por imagem).
2. No Terminal, a partir da raiz do projeto:

   ./scripts/prepare-appstore-iphone65-screenshots.sh ~/Desktop/Simulator*.png

3. Confirme com:

   sips -g pixelWidth -g pixelHeight <ficheiro.png>

   Deve mostrar pixelWidth: 1284 e pixelHeight: 2778.

4. Carregue no App Store Connect os PNGs gerados (ou os do Desktop se já
   forem exatamente 1242×2688 ou 1284×2778).

Verificar dimensões
--------------------
  sips -g pixelWidth -g pixelHeight caminho/para/imagem.png

Ficheiros "PNG" que o Connect rejeita (! vermelho)
---------------------------------------------------
  Confirme que são PNG de verdade (não JPEG com extensão .png):

    file caminho/para/imagem.png

  Deve dizer: "PNG image data". Se disser "JPEG image data", o Connect pode
  falhar ao processar. O script prepare-appstore-iphone65-screenshots.sh
  usa "sips -s format png" para forçar PNG real.

Privacy Policy URL (App Store Connect)
---------------------------------------
  Página publicada em:

    https://gilberto00.github.io/daily-movie-challenge/privacy.html

  (após git push do ficheiro docs/privacy.html)
