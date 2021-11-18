part of crop_your_image;

class PartImagePainter extends StatefulWidget {
  //final String imageUrl;
  final Rect rect;
  final Uint8List image;
  final Key? key;

  PartImagePainter({required this.rect, required this.image, this.key}) : super(key: key);

  @override
  _PartImagePainterState createState() => _PartImagePainterState();
}

class _PartImagePainterState extends State<PartImagePainter> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getImage(widget.image),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If the Future is complete, display the preview.
            return paintImage(snapshot.data);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<ui.Image> getImage(Uint8List path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new MemoryImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  paintImage(image) {
    return CustomPaint(
      painter: ImagePainter(image, widget.rect),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: widget.rect.height,
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  ui.Image resImage;

  Rect rectCrop;

  ImagePainter(this.resImage, this.rectCrop);

  @override
  void paint(Canvas canvas, Size size) {
    if (resImage == null) {
      return;
    }
    final Rect rect = Offset.zero & size;
    final Size imageSize = Size(resImage.width.toDouble(), resImage.height.toDouble());
    FittedSizes sizes = applyBoxFit(BoxFit.fitWidth, imageSize, size);

    Rect inputSubRect = rectCrop;
    final Rect outputSubRect = Alignment.center.inscribe(sizes.destination, rect);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;
    canvas.drawRect(rect, paint);

    canvas.drawImageRect(resImage, inputSubRect, outputSubRect, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
