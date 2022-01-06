class TinyImageInfo {
  Input? input;
  Output? output;

  TinyImageInfo({this.input, this.output});

  TinyImageInfo.fromJson(Map<String, dynamic> json) {
    input = json['input'] != null ? new Input.fromJson(json['input']) : null;
    output =
        json['output'] != null ? new Output.fromJson(json['output']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.input != null) {
      data['input'] = this.input!.toJson();
    }
    if (this.output != null) {
      data['output'] = this.output!.toJson();
    }
    return data;
  }
}

class Input {
  int? size;
  String? type;

  Input({this.size, this.type});

  Input.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['size'] = this.size;
    data['type'] = this.type;
    return data;
  }
}

class Output {
  int? size;
  String? type;
  int? width;
  int? height;
  double? ratio;
  String? url;

  Output({this.size, this.type, this.width, this.height, this.ratio, this.url});

  Output.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    type = json['type'];
    width = json['width'];
    height = json['height'];
    ratio = json['ratio'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['size'] = this.size;
    data['type'] = this.type;
    data['width'] = this.width;
    data['height'] = this.height;
    data['ratio'] = this.ratio;
    data['url'] = this.url;
    return data;
  }
}

