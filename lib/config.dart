enum TextSizes { big, normal, small }

enum DrawSizes { bold, normal, thin }

enum EraseSizes { big, normal, small }

class Config {
  static TextSizes textSize = TextSizes.normal;
  static DrawSizes drawSize = DrawSizes.normal;
  static EraseSizes eraseSize = EraseSizes.normal;

  static double getFontSize() {
    double _size;

    switch (textSize) {
      case TextSizes.small:
        _size = 10;
        break;
      case TextSizes.normal:
        _size = 20;
        break;
      case TextSizes.big:
        _size = 30;
        break;
    }

    return _size;
  }

  static double getDrawSize() {
    double _size;

    switch (drawSize) {
      case DrawSizes.thin:
        _size = 0.5;
        break;
      case DrawSizes.normal:
        _size = 1.5;
        break;
      case DrawSizes.bold:
        _size = 2.5;
        break;
    }

    return _size;
  }

  static double getEraserSize() {
    double _size;

    switch (eraseSize) {
      case EraseSizes.small:
        _size = 4;
        break;
      case EraseSizes.normal:
        _size = 10;
        break;
      case EraseSizes.big:
        _size = 20;
        break;
    }

    return _size;
  }
}
