## Installing a font without admin right.

For this you can use any File Icon Theme or Product Icon Theme

Go to the extension and edit it's JSON. Add the following
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
