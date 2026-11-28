import 'dart:typed_data';

import 'package:koini/models/koini_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Isi Rapor Bulanan yang akan dicetak. Sengaja berupa data biasa agar
/// pembuatan PDF bisa diuji tanpa layar maupun plugin cetak.
class ReportPdfData {
  const ReportPdfData({
    required this.child,
    required this.periodStart,
    required this.generatedAt,
    required this.jars,
    required this.savings,
    required this.missions,
    required this.challengeCount,
    required this.challengeRewards,
    required this.bonusRewards,
    this.badges = const [],
    this.history = const [],
  });

  final String child;
  final DateTime periodStart;
  final DateTime generatedAt;
  final Map<Jar, ({int planned, int actual})> jars;
  final int savings;
  final String missions;
  final int challengeCount;
  final int challengeRewards;
  final int bonusRewards;
  final List<String> badges;
  final List<MoneyEntry> history;

  String get fileName {
    final month = periodStart.month.toString().padLeft(2, '0');
    return 'rapor-koini-${periodStart.year}-$month.pdf';
  }
}

const _ink = PdfColor.fromInt(0xFF1F2A44);
const _muted = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFD9DEE8);

String _monthName(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

/// Membuat PDF Rapor Bulanan (A4) sepenuhnya di perangkat, tanpa jaringan.
Future<Uint8List> buildReportPdf(ReportPdfData data) async {
  final doc = pw.Document(
    title: 'Rapor Bulanan Koini - ${data.child}',
    author: 'Koini',
  );
  pw.Widget title(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: _ink,
      ),
    ),
  );
  pw.Widget row(String left, String middle, String right, {bool head = false}) {
    final style = pw.TextStyle(
      fontSize: 11,
      color: head ? _muted : _ink,
      fontWeight: head ? pw.FontWeight.normal : pw.FontWeight.bold,
    );
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _line)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(left, style: style)),
          pw.SizedBox(
            width: 110,
            child: pw.Text(middle, style: style, textAlign: pw.TextAlign.right),
          ),
          pw.SizedBox(
            width: 110,
            child: pw.Text(right, style: style, textAlign: pw.TextAlign.right),
          ),
        ],
      ),
    );
  }

  pw.Widget line(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 11, color: _ink)),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (_) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Koini - Rapor Bulanan',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.Text(
              _monthName(data.periodStart),
              style: const pw.TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Text(
        'Dibuat ${dateLabel(data.generatedAt)} - Halaman '
        '${context.pageNumber}/${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: _muted),
      ),
      build: (_) => [
        line('Nama anak: ${data.child}'),
        title('Uang bulan ini'),
        row('Toples', 'Rencana', 'Tercatat', head: true),
        for (final entry in data.jars.entries)
          row(
            entry.key.label,
            rupiah(entry.value.planned),
            rupiah(entry.value.actual),
          ),
        line('Rencana mengacu pada pengaturan uang saku saat ini.'),
        title('Ringkasan'),
        line('Tabungan bulan ini: ${rupiah(data.savings)}'),
        line('Misi selesai (total): ${data.missions}'),
        line(
          'Tantangan berhasil: ${data.challengeCount} '
          '(${rupiah(data.challengeRewards)})',
        ),
        line('Bonus tabungan: ${rupiah(data.bonusRewards)}'),
        title('Pencapaian'),
        if (data.badges.isEmpty)
          line('Belum ada lencana bulan ini.')
        else
          for (final badge in data.badges) line('- $badge'),
        title('Aktivitas bulan ini'),
        if (data.history.isEmpty)
          line('Belum ada aktivitas tercatat.')
        else
          for (final entry in data.history)
            row(
              '${dateLabel(entry.date)} - ${entry.note}',
              entry.kind.label,
              rupiah(entry.net),
            ),
      ],
    ),
  );
  return doc.save();
}
