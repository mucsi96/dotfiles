## Installing a font without admin right.

For this you can use any File Icon Theme or Product Icon Theme

Go to the extension JSON definition file (under `%USERPROFILE%\.vscode\extensions`) and add the following
```
  "fonts": [
    {
      "id": "Dank Mono",
      "src": [
        {
          "path": "./DankMono-Regular.otf",
          "format": "opentype"
        }
      ],
      "weight": "normal",
      "style": "normal"
    },
    {
      "id": "Dank Mono",
      "src": [
        {
          "path": "./DankMono-Italic.otf",
          "format": "opentype"
        }
      ],
      "weight": "normal",
      "style": "italic"
    }
  ],
```

Place the fonts next to this file.

Enable the font in settings using
```
  "editor.fontFamily": "Dank Mono",
  "editor.fontLigatures": true,
  "editor.renderWhitespace": "none"
```
