import 'dart:io' as Io;
import 'package:image/image.dart';

//import 'dart:ui';
//import 'dart:typed_data';

import 'package:dart1/dart1_util.dart' as dart1_util;

void main(List<String> arguments) {
  print('Hello world (image reducer): ${dart1_util.calculate()}!');

  Io.Directory dir = Io.Directory ("img");
  Io.Directory output = Io.Directory ("resized");

  if (output.existsSync() == false) output.createSync(recursive: true);


  // async
  // dir.list(recursive: false).forEach((f) {
  //   print(f);
  // });

  int GRID_MAX_CELLS_WIDTH = 6;
  int MAXX = 6000;
  int MAXY = 6000;// TODO: Make this dynamic, based on the # of images to resize/grid. Auto-grow height then crop to fit.

  int cellWidth = (MAXX / GRID_MAX_CELLS_WIDTH).floor();
  int cellHeight = cellWidth;

  int cellx = 0;
  int celly = 0;

  Image gridImg = Image(width: MAXX, height: MAXY);

  // sync
  List<Io.FileSystemEntity> entries = dir.listSync(recursive: false).toList();

  for(Io.FileSystemEntity e in entries)
  {
    String imgPath = e.path;

    if (e.statSync().type == Io.FileSystemEntityType.file && (!e.path.endsWith(".resized.jpg")) && (e.path.endsWith(".jpg") || e.path.endsWith(".jpeg") || e.path.endsWith(".png")))
    {
      Image? image = decodeImage(new Io.File(imgPath).readAsBytesSync());

      if (image != null) {
        print ("Image " + e.uri.pathSegments.last + " loaded, resizing...");
        // Test 1) "LowResThumbnails": Create low-res images that are close in quality to the originals
        //    For each image, then stream back to disk in a smaller size / reduced quality

        // Resize by half, keeping the same aspect ratio
        Image thumbnail = copyResize(image, width: (image.width / 2).floor(), interpolation: Interpolation.cubic);

        // Save the thumbnail as a PNG.
        //new Io.File(imgPath + ".png")
        //    .writeAsBytesSync(encodePng(thumbnail));

        // Save the thumbnail as a JPG.
        new Io.File(output.path + "/" + e.uri.pathSegments.last)
            .writeAsBytesSync(encodeJpg(thumbnail, quality: 80));

        // Test 2) "PhotoGrid": Create a single large image with all the given pictures as cells in a table layout of all the images
        //    For each image, draw onto a larger image in a grid.
        // Direct compositing doesn't yield good enough resizing quality... going to resize on-the-fly for better quality
        // compositeImage(gridImg, thumbnail, dstX: cellx * cellWidth, dstY: celly * cellHeight, dstW: cellWidth, dstH: cellHeight, );
        compositeImage(gridImg, copyResize(image, width: cellWidth, interpolation: Interpolation.cubic), dstX: cellx * cellWidth, dstY: celly * cellHeight/*, dstW: cellWidth, dstH: cellHeight*/);


        cellx++;
        if (cellx > GRID_MAX_CELLS_WIDTH - 1)
        {
          cellx = 0;
          celly += 1;
        }
      }
      else
      {
        print ("Unable to read image: " + imgPath);
      }
    }
    else
    {
      print ("Non-image: " + imgPath);
    }
  }

  Image testImg = Image(width: MAXX, height: MAXY);
  fill(testImg, color: ColorRgba8(255, 0, 0, 0));
  drawLine(testImg, x1: 0, y1: 0, x2: testImg.width, y2: testImg.height, color: ColorRgb8(0, 255, 0));
  drawLine(testImg, x1: testImg.width, y1: 0, x2: 0, y2: testImg.height, color: ColorRgb8(0, 0, 255));
  new Io.File(output.path + "/" + "_test.png").writeAsBytesSync(encodePng(testImg, level: 9));// Level = compression level, 0 (most) - 9 (none)

  //compositeImage(testImg, decodeImage(new Io.File("img/dIbcnTB.jpeg").readAsBytesSync())!, dstH: 100, dstW: 100, dstX: 100, dstY: 100);

  //new Io.File(output.path + "\\" + "_grid2.png").writeAsBytesSync(encodePng(testImg, level: 9));// Level = compression level, 0 (most) - 9 (none)

  new Io.File(output.path + "/" + "_grid.png").writeAsBytesSync(encodePng(gridImg, level: 9));// Level = compression level, 0 (most) - 9 (none)



  // email client for SMTP & POP3: https://pub.dev/packages/enough_mail/example

  // Test 1) "LowResThumbnails": Create low-res images that are close in quality to the originals
  //    For each image, then stream back to disk in a smaller size / reduced quality

  // Test 2) "PhotoGrid": Create a single large image with all the given pictures as cells in a table layout of all the images
  //    For each image, draw onto a larger image in a grid.


}
