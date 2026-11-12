import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Sends raw ESC/POS bytes to a Windows printer queue (datatype RAW).
abstract final class WindowsRawPrinter {
  static Future<bool> sendRawBytes({
    required String printerName,
    required Uint8List data,
    required String jobName,
  }) async {
    if (printerName.isEmpty) {
      return false;
    }
    final name = printerName.toNativeUtf16();
    final phPrinter = calloc<Pointer>();
    final open = OpenPrinter(PCWSTR(name), phPrinter, nullptr);
    if (!open.value) {
      calloc.free(name);
      calloc.free(phPrinter);
      return false;
    }
    final handle = PRINTER_HANDLE(phPrinter.value);
    final docName = jobName.toNativeUtf16();
    final rawType = 'RAW'.toNativeUtf16();
    final docInfo = calloc<DOC_INFO_1>();
    docInfo.ref
      ..pDocName = PWSTR(docName)
      ..pOutputFile = PWSTR(nullptr.cast<Utf16>())
      ..pDatatype = PWSTR(rawType);

    final jobId = StartDocPrinter(handle, 1, docInfo);
    if (jobId == 0) {
      _cleanup(handle, phPrinter, name, docName, rawType, docInfo);
      return false;
    }
    if (!StartPagePrinter(handle)) {
      EndDocPrinter(handle);
      _cleanup(handle, phPrinter, name, docName, rawType, docInfo);
      return false;
    }

    final written = calloc<Uint32>();
    final buffer = calloc<Uint8>(data.length);
    try {
      buffer.asTypedList(data.length).setAll(0, data);
      final ok = WritePrinter(
        handle,
        buffer.cast(),
        data.length,
        written,
      );
      EndPagePrinter(handle);
      EndDocPrinter(handle);
      return ok;
    } finally {
      calloc.free(written);
      calloc.free(buffer);
      _cleanup(handle, phPrinter, name, docName, rawType, docInfo);
    }
  }

  static void _cleanup(
    PRINTER_HANDLE handle,
    Pointer<Pointer> phPrinter,
    Pointer<Utf16> name,
    Pointer<Utf16> docName,
    Pointer<Utf16> rawType,
    Pointer<DOC_INFO_1> docInfo,
  ) {
    ClosePrinter(handle);
    calloc.free(docInfo);
    calloc.free(docName);
    calloc.free(rawType);
    calloc.free(name);
    calloc.free(phPrinter);
  }
}
