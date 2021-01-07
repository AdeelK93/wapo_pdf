# Washington Post PDF converter

***Requires Washington Post subscription***

The objective of this program is to download The Washington Post Print Edition from https://thewashingtonpost.pressreader.com/ and convert it into a PDF. It then uploads the PDF to reMarkble cloud. I have mine running on `cron` running each morning off of my Raspberry Pi.

## Usage

Run `./pressReader.sh`, and it'll make sure your cookies are in order.

This program uses R for filtering out some pages I'm not interested (ads, obituaries, and sports) and deducing page "scales" (required for API), python for reMarkable API, and bash to hold it all together.
