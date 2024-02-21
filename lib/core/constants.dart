const Map<String, String> errorMessage = {
  "default": "Someting went wrong!",
  "db": "Something went wrong in Database",
};

enum SoundType { defaults, imported }

extension XSoundSelected on SoundType {
  get isDefault => this == SoundType.defaults;
  get isImported => this == SoundType.imported;
}

extension StringToSoundType on String {
  SoundType get toSoundType {
    if (this == SoundType.defaults.valueAsString) {
      return SoundType.defaults;
    } else {
      return SoundType.imported;
    }
  }
}

extension XSoundType on SoundType {
  String get valueAsString => toString().split('.').last;
}
