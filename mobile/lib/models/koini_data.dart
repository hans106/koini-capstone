enum Jar {
  tabung('Tabung', 'Untuk impianmu'),
  jajan('Jajan', 'Kebutuhan harian'),
  berbagi('Berbagi', 'Sumbangan');

  const Jar(this.label, this.description);
  final String label;
  final String description;
}

enum AllowancePeriod {
  daily('harian', 'Harian', 'per hari', 'hari ini'),
  weekly('mingguan', 'Mingguan', 'per minggu', 'minggu ini'),
  monthly('bulanan', 'Bulanan', 'per bulan', 'bulan ini');

  const AllowancePeriod(
    this.dbValue,
    this.label,
    this.perLabel,
    this.currentLabel,
  );

  final String dbValue;
  final String label;
  final String perLabel;
  final String currentLabel;

  static AllowancePeriod fromDb(String? value) =>
      AllowancePeriod.values.firstWhere(
        (item) => item.dbValue == value || item.name == value,
        orElse: () => AllowancePeriod.weekly,
      );
}

enum EntryKind {
  allowance('Uang saku'),
  income('Uang masuk'),
  spend('Jajan'),
  save('Menabung'),
  give('Berbagi'),
  transfer('Pindah toples'),
  leftoverTransfer('Sisa jajan'),
  bonus('Bonus'),
  gift('Uang hadiah'),
  giftReturn('Pengembalian titipan');

  const EntryKind(this.label);
  final String label;
}

enum Plan {
  free('Gratis', 'Rp0'),
  monthly('Bulanan', 'Rp5.000/bulan'),
  yearly('Tahunan', 'Rp50.000/tahun');

  const Plan(this.label, this.price);
  final String label;
  final String price;
}

const rupiahLimit = 999999999;

String rupiah(int value) {
  final grouped = value.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${value < 0 ? '-' : ''}Rp$grouped';
}

String dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

DateTime dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime weekStart(DateTime date) =>
    DateTime(date.year, date.month, date.day - date.weekday + 1);

DateTime periodStart(DateTime date, AllowancePeriod period) => switch (period) {
  AllowancePeriod.daily => dayStart(date),
  AllowancePeriod.weekly => weekStart(date),
  AllowancePeriod.monthly => DateTime(date.year, date.month),
};

({DateTime start, DateTime end}) previousPeriodRange(
  DateTime date,
  AllowancePeriod period,
) {
  final currentStart = periodStart(date, period);
  final prevEnd = DateTime(
    currentStart.year,
    currentStart.month,
    currentStart.day - 1,
  );
  final prevStart = periodStart(prevEnd, period);
  return (start: prevStart, end: prevEnd);
}

String isoDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class PiggyBankCheck {
  const PiggyBankCheck({
    required this.physicalAmount,
    required this.recordedAmount,
    required this.checkedAt,
  });

  final int physicalAmount;
  final int recordedAmount;
  final DateTime checkedAt;

  int get difference => physicalAmount - recordedAmount;

  Map<String, dynamic> toJson() => {
    'physicalAmount': physicalAmount,
    'recordedAmount': recordedAmount,
    'checkedAt': checkedAt.toIso8601String(),
  };

  factory PiggyBankCheck.fromJson(Map<String, dynamic> json) => PiggyBankCheck(
    physicalAmount: json['physicalAmount'] as int,
    recordedAmount: json['recordedAmount'] as int,
    checkedAt: DateTime.parse(json['checkedAt'] as String),
  );
}

class MoneyEntry {
  const MoneyEntry({
    required this.kind,
    required this.date,
    required this.amount,
    required this.note,
    this.changes = const {},
    this.dreamId,
    this.category,
  });

  final EntryKind kind;
  final DateTime date;
  final int amount;
  final String note;
  final Map<Jar, int> changes;
  final String? dreamId;
  final String? category;

  int get net => changes.values.fold(0, (sum, amount) => sum + amount);

  int get income => switch (kind) {
    EntryKind.gift => amount,
    EntryKind.giftReturn => 0,
    _ => net > 0 ? net : 0,
  };

  int get expense => net < 0 ? -net : 0;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'date': date.toIso8601String(),
    'amount': amount,
    'note': note,
    'changes': changes.map((key, value) => MapEntry(key.name, value)),
    'dreamId': dreamId,
    'category': category,
  };

  factory MoneyEntry.fromJson(Map<String, dynamic> json) => MoneyEntry(
    kind: EntryKind.values.byName(json['kind'] as String),
    date: DateTime.parse(json['date'] as String),
    amount: json['amount'] as int,
    note: json['note'] as String,
    changes: (json['changes'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(Jar.values.byName(key), value as int),
    ),
    dreamId: json['dreamId'] as String?,
    category: json['category'] as String?,
  );
}

class Dream {
  const Dream({
    required this.id,
    required this.name,
    required this.image,
    required this.target,
    required this.weekly,
    this.deadline,
  });

  final String id;
  final String name;
  final int image;
  final int target;
  final int weekly;
  final DateTime? deadline;

  Dream withPlan(int amount, {DateTime? deadline}) => Dream(
    id: id,
    name: name,
    image: image,
    target: target,
    weekly: amount,
    deadline: deadline ?? this.deadline,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'target': target,
    'weekly': weekly,
    'deadline': deadline?.toIso8601String(),
  };

  factory Dream.fromJson(Map<String, dynamic> json) => Dream(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as int,
    target: json['target'] as int,
    weekly: json['weekly'] as int,
    deadline: DateTime.tryParse(json['deadline'] as String? ?? ''),
  );
}

class KoiniData {
  int? anakId;
  String name = '';
  String email = '';
  String pin = '';
  int age = 9;
  int allowance = 100000;
  AllowancePeriod allowancePeriod = AllowancePeriod.weekly;
  int dailyLimit = 10000;
  Map<Jar, int> split = {
    Jar.tabung: 40000,
    Jar.jajan: 50000,
    Jar.berbagi: 10000,
  };
  Plan plan = Plan.free;
  bool reminders = false;
  bool emailAlerts = false;
  bool stories = false;
  bool tutorialDone = false;
  String? lastSweptPeriodEnd;
  int rating = 0;
  int heldGiftMoney = 0;
  final entries = <MoneyEntry>[];
  final dreams = <Dream>[];
  final piggyChecks = <PiggyBankCheck>[];
  final missionScores = <String, int>{};
  final studyDays = <String>{};

  bool get hasProfile => name.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'anakId': anakId,
    'name': name,
    'email': email,
    'pin': pin,
    'age': age,
    'allowance': allowance,
    'allowancePeriod': allowancePeriod.dbValue,
    'dailyLimit': dailyLimit,
    'split': split.map((jar, value) => MapEntry(jar.name, value)),
    'plan': plan.name,
    'reminders': reminders,
    'emailAlerts': emailAlerts,
    'stories': stories,
    'tutorialDone': tutorialDone,
    'lastSweptPeriodEnd': lastSweptPeriodEnd,
    'rating': rating,
    'heldGiftMoney': heldGiftMoney,
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'dreams': dreams.map((dream) => dream.toJson()).toList(),
    'piggyChecks': piggyChecks.map((check) => check.toJson()).toList(),
    'missionScores': missionScores,
    'studyDays': studyDays.toList(),
  };

  KoiniData();

  KoiniData.fromJson(Map<String, dynamic> json) {
    anakId = json['anakId'] as int?;
    name = json['name'] as String;
    email = json['email'] as String;
    pin = json['pin'] as String;
    age = json['age'] as int;
    allowance = json['allowance'] as int;
    allowancePeriod = AllowancePeriod.fromDb(
      json['allowancePeriod'] as String?,
    );
    dailyLimit = json['dailyLimit'] as int;
    split = (json['split'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(Jar.values.byName(key), value as int),
    );
    plan = Plan.values.byName(json['plan'] as String);
    reminders = json['reminders'] as bool;
    emailAlerts = json['emailAlerts'] as bool;
    stories = json['stories'] as bool;
    tutorialDone = json['tutorialDone'] as bool? ?? false;
    lastSweptPeriodEnd = json['lastSweptPeriodEnd'] as String?;
    rating = json['rating'] as int;
    heldGiftMoney = json['heldGiftMoney'] as int? ?? 0;
    entries.addAll(
      (json['entries'] as List).cast<Map<String, dynamic>>().map(
        MoneyEntry.fromJson,
      ),
    );
    dreams.addAll(
      (json['dreams'] as List).cast<Map<String, dynamic>>().map(Dream.fromJson),
    );
    if (json['piggyChecks'] case final List rawChecks) {
      piggyChecks.addAll(
        rawChecks.cast<Map<String, dynamic>>().map(PiggyBankCheck.fromJson),
      );
    }
    missionScores.addAll((json['missionScores'] as Map).cast<String, int>());
    studyDays.addAll((json['studyDays'] as List).cast<String>());
  }
}
