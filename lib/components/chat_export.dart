import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:printing/printing.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../database/model.dart';
import '../classes/global.dart';
import '../encyption/rsa.dart';
import 'package:pointycastle/asymmetric/api.dart';

Future<List<Map<String, dynamic>>> getChatHistory(String converser) async {
  Database? db;
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'p2p.db');

    db = await openDatabase(path);

    final List<Map<String, dynamic>> messages = await db.query(
        conversationsTableName,
        where: 'converser = ?',
        whereArgs: [converser],
        orderBy: "timestamp ASC",
        columns: ['_id', 'converser', 'type', 'msg', 'timestamp', 'ack']
    );

    // Decrypt messages
    return messages.map((msg) {
      try {
        if (Global.myPrivateKey != null) {
          RSAPrivateKey privateKey = Global.myPrivateKey!;
          dynamic data = jsonDecode(msg['msg']);

          if (data['type'] == 'text') {
            Uint8List encryptedBytes = base64Decode(data['data']);
            Uint8List decryptedBytes = rsaDecrypt(privateKey, encryptedBytes);
            String decryptedMessage = utf8.decode(decryptedBytes);
            return {
              ...msg,
              'decryptedMsg': decryptedMessage,
              'messageType': data['type']
            };
          } else if (data['type'] == 'file' || data['type'] == 'voice') {
            // Handle file messages
            return {
              ...msg,
              'decryptedMsg': 'File: ${data['fileName'] ?? 'Unnamed file'}',
              'messageType': data['type']
            };
          }
        }
      } catch (e) {
        debugPrint('Decryption error for message: $e');
      }
      return {
        ...msg,
        'decryptedMsg': 'Unable to decrypt message',
        'messageType': 'unknown'
      };
    }).toList();
  } catch (e) {
    debugPrint('Database error: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
    return [];
  } finally {
    await db?.close();
  }
}

Future<File> generatePdf({required String converser}) async {
  try {
    final pdf = pw.Document();
    final chatHistory = await getChatHistory(converser);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "${Global.myName}'s Chat History with $converser",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (chatHistory.isEmpty)
                pw.Text(
                  "No messages found",
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                )
              else
                ...chatHistory.map((chat) {
                  final DateTime timestamp = DateTime.parse(chat['timestamp']);
                  final String formattedTime =
                      "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
                  final String formattedDate =
                      "${timestamp.day}/${timestamp.month}/${timestamp.year}";

                  final bool isSent = chat['type'] == 'sent';

                  return pw.Column(
                    crossAxisAlignment: isSent
                        ? pw.CrossAxisAlignment.end
                        : pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(
                          "$formattedDate $formattedTime",
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 300,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: isSent ? PdfColors.blue50 : PdfColors.grey100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (chat['messageType'] == 'file' || chat['messageType'] == 'voice')
                              pw.Row(
                                children: [
                                  pw.Text(
                                    "📎 ",
                                    style: pw.TextStyle(fontSize: 12),
                                  ),
                                  pw.Text(
                                    chat['decryptedMsg'],
                                    style: pw.TextStyle(fontSize: 12),
                                  ),
                                ],
                              )
                            else
                              pw.Text(
                                chat['decryptedMsg'],
                                style: pw.TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 12),
                    ],
                  );
                }).toList(),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/chat_history_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  } catch (e) {
    debugPrint('PDF generation error: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
    rethrow;
  }
}

// Print the PDF
Future<void> printPdf({required String converser}) async {
  try {
    final file = await generatePdf(converser: converser);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => file.readAsBytes(),
    );
  } catch (e) {
    debugPrint('Print error: $e');
    rethrow;
  }
}

// Open the PDF in a viewer
Future<void> openPdf({required String converser}) async {
  try {
    final file = await generatePdf(converser: converser);
    await OpenFilex.open(file.path);
  } catch (e) {
    debugPrint('Open PDF error: $e');
    rethrow;
  }
}

// Share the PDF via apps like WhatsApp, Gmail, etc.
Future<void> sharePdf({required String converser}) async {
  try {
    final file = await generatePdf(converser: converser);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Chat History with $converser",
    );
  } catch (e) {
    debugPrint('Share error: $e');
    rethrow;
  }
}

// UI to trigger actions
class ChatExportScreen extends StatelessWidget {
  final String converser;

  const ChatExportScreen({
    Key? key,
    required this.converser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Chat - $converser"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  printPdf(converser: converser).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to print chat. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }),
              child: const Text("Print Chat History"),
            ),
            ElevatedButton(
              onPressed: () =>
                  openPdf(converser: converser).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to open PDF. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }),
              child: const Text("Open PDF"),
            ),
            ElevatedButton(
              onPressed: () =>
                  sharePdf(converser: converser).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to share PDF. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }),
              child: const Text("Share PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
