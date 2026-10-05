export 'pdf_platform_stub.dart'
    if (dart.library.js_interop) 'pdf_platform_web.dart'
    if (dart.library.html) 'pdf_platform_web.dart';
