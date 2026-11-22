import 'package:shared_prayer/shared_prayer.dart';

import 'l10n_core.dart';

/// Kalkulator Zakat (Maal, Penghasilan, Perdagangan, Fitrah), Fidyah, dan Waris Islam (Faraid termasuk Aul & Radd).
class ZakatMaalEvaluation {
  final double grossAssets;
  final double deductibleDebt;
  final double netZakatable;
  final double nisabValue;
  final bool isObligatory;
  final double zakatAmount;
  final String explanation;
  final String? explanationEn;

  const ZakatMaalEvaluation({
    required this.grossAssets,
    required this.deductibleDebt,
    required this.netZakatable,
    required this.nisabValue,
    required this.isObligatory,
    required this.zakatAmount,
    required this.explanation,
    this.explanationEn,
  });

  String explanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (explanationEn?.isNotEmpty ?? false) ? explanationEn! : explanation;
}

ZakatMaalEvaluation calculateZakatMaal({
  required double cashAndSavings,
  required double goldGrams,
  required double tradeInventory,
  required double shortTermDebt,
  required double goldPricePerGram,
  AppLanguage lang = AppLanguage.id,
}) {
  final safeGoldPrice = goldPricePerGram <= 0 ? 1500000.0 : goldPricePerGram;
  final nisab = 85.0 * safeGoldPrice;
  final gross = (cashAndSavings < 0 ? 0.0 : cashAndSavings) +
      ((goldGrams < 0 ? 0.0 : goldGrams) * safeGoldPrice) +
      (tradeInventory < 0 ? 0.0 : tradeInventory);
  final debt = shortTermDebt < 0 ? 0.0 : shortTermDebt;
  final net = (gross - debt) < 0 ? 0.0 : (gross - debt);
  final obligatory = net >= nisab;
  final zakat = obligatory ? net * 0.025 : 0.0;
  final explanationId = obligatory
      ? 'Harta bersih telah mencapai nisab setara 85 gram emas dan wajib dizakati sebesar 2,5% setelah mencapai haul (1 tahun Hijriah).'
      : 'Harta bersih belum mencapai batas nisab 85 gram emas. Belum wajib zakat maal, namun dianjurkan bersedekah sunnah.';
  final explanationEn = obligatory
      ? 'Net zakatable wealth has reached the Nisab threshold of 85 grams of gold; 2.5% Zakat is due once held for one lunar year (Hawl).'
      : 'Net wealth is below the 85-gram gold Nisab threshold. Zakat al-Mal is not obligatory, though voluntary charity (sadaqah) is encouraged.';
  return ZakatMaalEvaluation(
    grossAssets: gross,
    deductibleDebt: debt,
    netZakatable: net,
    nisabValue: nisab,
    isObligatory: obligatory,
    zakatAmount: zakat,
    explanation: tr(lang, explanationId, explanationEn),
    explanationEn: explanationEn,
  );
}

ZakatMaalEvaluation calculateZakatProfesiMonthly({
  required double monthlyIncome,
  required double monthlyNeedsOrDebt,
  required double goldPricePerGram,
  AppLanguage lang = AppLanguage.id,
}) {
  final safeGoldPrice = goldPricePerGram <= 0 ? 1500000.0 : goldPricePerGram;
  final annualNisab = 85.0 * safeGoldPrice;
  final monthlyNisab = annualNisab / 12.0;
  final gross = monthlyIncome < 0 ? 0.0 : monthlyIncome;
  final deduction = monthlyNeedsOrDebt < 0 ? 0.0 : monthlyNeedsOrDebt;
  final net = (gross - deduction) < 0 ? 0.0 : (gross - deduction);
  final obligatory = net >= monthlyNisab;
  final zakat = obligatory ? net * 0.025 : 0.0;
  final explanationId = obligatory
      ? 'Penghasilan bersih bulanan mencapai nisab bulanan (1/12 dari 85 gram emas). Zakat penghasilan sebesar 2,5% dapat ditunaikan langsung setiap bulan.'
      : 'Penghasilan bersih bulanan belum mencapai nisab bulanan (1/12 dari 85 gram emas).';
  final explanationEn = obligatory
      ? 'Net monthly income reaches the monthly Nisab threshold (1/12 of 85 grams of gold). Income Zakat of 2.5% may be paid each month.'
      : 'Net monthly income is below the monthly Nisab threshold (1/12 of 85 grams of gold).';
  return ZakatMaalEvaluation(
    grossAssets: gross,
    deductibleDebt: deduction,
    netZakatable: net,
    nisabValue: monthlyNisab,
    isObligatory: obligatory,
    zakatAmount: zakat,
    explanation: tr(lang, explanationId, explanationEn),
    explanationEn: explanationEn,
  );
}

class FitrahFidyahEvaluation {
  final int soulCount;
  final double riceKgTotal;
  final double fitrahMoneyTotal;
  final int fidyahDays;
  final double fidyahMoneyTotal;

  const FitrahFidyahEvaluation({
    required this.soulCount,
    required this.riceKgTotal,
    required this.fitrahMoneyTotal,
    required this.fidyahDays,
    required this.fidyahMoneyTotal,
  });
}

FitrahFidyahEvaluation calculateFitrahAndFidyah({
  required int soulCount,
  required double ricePricePerKg,
  required int fidyahDays,
  required double fidyahMealCostPerDay,
}) {
  final souls = soulCount.clamp(0, 500);
  final priceKg = ricePricePerKg < 0 ? 0.0 : ricePricePerKg;
  final days = fidyahDays.clamp(0, 3650);
  final mealCost = fidyahMealCostPerDay < 0 ? 0.0 : fidyahMealCostPerDay;
  final kg = souls * 2.5;
  return FitrahFidyahEvaluation(
    soulCount: souls,
    riceKgTotal: kg,
    fitrahMoneyTotal: kg * priceKg,
    fidyahDays: days,
    fidyahMoneyTotal: days * mealCost,
  );
}

// ================= FARAID (WARIS ISLAM) =================

class FaraidInput {
  final double grossEstate;
  final double funeralCost;
  final double debt;
  final double bequestRequested;
  final bool hasHusband;
  final int wivesCount;
  final int sonsCount;
  final int daughtersCount;
  final bool hasFather;
  final bool hasMother;
  final int fullBrothersCount;
  final int fullSistersCount;

  const FaraidInput({
    required this.grossEstate,
    this.funeralCost = 0,
    this.debt = 0,
    this.bequestRequested = 0,
    this.hasHusband = false,
    this.wivesCount = 0,
    this.sonsCount = 0,
    this.daughtersCount = 0,
    this.hasFather = false,
    this.hasMother = false,
    this.fullBrothersCount = 0,
    this.fullSistersCount = 0,
  });
}

class FaraidHeirShare {
  final String heirName;
  final String? heirNameEn;
  final int count;
  final String portionLabel;
  final String? portionLabelEn;
  final double totalShareRatio;
  final double totalAmount;
  final double perPersonAmount;
  final String legalReason;
  final String? legalReasonEn;
  final bool isBlocked;

  const FaraidHeirShare({
    required this.heirName,
    this.heirNameEn,
    required this.count,
    required this.portionLabel,
    this.portionLabelEn,
    required this.totalShareRatio,
    required this.totalAmount,
    required this.perPersonAmount,
    required this.legalReason,
    this.legalReasonEn,
    this.isBlocked = false,
  });

  String heirNameFor(AppLanguage lang) =>
      lang == AppLanguage.en && (heirNameEn?.isNotEmpty ?? false) ? heirNameEn! : heirName;
  String portionLabelFor(AppLanguage lang) =>
      lang == AppLanguage.en && (portionLabelEn?.isNotEmpty ?? false) ? portionLabelEn! : portionLabel;
  String legalReasonFor(AppLanguage lang) =>
      lang == AppLanguage.en && (legalReasonEn?.isNotEmpty ?? false) ? legalReasonEn! : legalReason;
}

class FaraidResult {
  final double grossEstate;
  final double funeralAndDebt;
  final double maxAllowedBequest;
  final double appliedBequest;
  final double netInheritableEstate;
  final String caseType;
  final String? caseTypeEn;
  final String caseExplanation;
  final String? caseExplanationEn;
  final List<FaraidHeirShare> shares;

  const FaraidResult({
    required this.grossEstate,
    required this.funeralAndDebt,
    required this.maxAllowedBequest,
    required this.appliedBequest,
    required this.netInheritableEstate,
    required this.caseType,
    this.caseTypeEn,
    required this.caseExplanation,
    this.caseExplanationEn,
    required this.shares,
  });

  String caseTypeFor(AppLanguage lang) =>
      lang == AppLanguage.en && (caseTypeEn?.isNotEmpty ?? false) ? caseTypeEn! : caseType;
  String caseExplanationFor(AppLanguage lang) =>
      lang == AppLanguage.en && (caseExplanationEn?.isNotEmpty ?? false)
          ? caseExplanationEn!
          : caseExplanation;
}

FaraidResult computeFaraid(
  FaraidInput input, {
  AppLanguage lang = AppLanguage.id,
}) {
  final gross = input.grossEstate < 0 ? 0.0 : input.grossEstate;
  final funeralDebt = (input.funeralCost < 0 ? 0.0 : input.funeralCost) + (input.debt < 0 ? 0.0 : input.debt);
  final afterDebt = (gross - funeralDebt) < 0 ? 0.0 : (gross - funeralDebt);
  final maxWasiat = afterDebt / 3.0;
  final reqWasiat = input.bequestRequested < 0 ? 0.0 : input.bequestRequested;
  final wasiat = reqWasiat > maxWasiat ? maxWasiat : reqWasiat;
  final net = afterDebt - wasiat;

  final sons = input.sonsCount.clamp(0, 50);
  final daughters = input.daughtersCount.clamp(0, 50);
  final wives = input.hasHusband ? 0 : input.wivesCount.clamp(0, 4);
  final brothers = input.fullBrothersCount.clamp(0, 50);
  final sisters = input.fullSistersCount.clamp(0, 50);
  final hasDescendant = sons > 0 || daughters > 0;
  final hasMaleDescendant = sons > 0;
  final siblingsCount = brothers + sisters;

  FaraidHeirShare makeShare({
    required String nameId,
    required String nameEn,
    required int count,
    required String portionId,
    required String portionEn,
    required double ratio,
    required double total,
    required double perPerson,
    required String reasonId,
    required String reasonEn,
    bool isBlocked = false,
  }) =>
      FaraidHeirShare(
        heirName: tr(lang, nameId, nameEn),
        heirNameEn: nameEn,
        count: count,
        portionLabel: tr(lang, portionId, portionEn),
        portionLabelEn: portionEn,
        totalShareRatio: ratio,
        totalAmount: total,
        perPersonAmount: perPerson,
        legalReason: tr(lang, reasonId, reasonEn),
        legalReasonEn: reasonEn,
        isBlocked: isBlocked,
      );

  // Base ratio out of 24 (LCM of 2, 3, 4, 6, 8 = 24)
  var spouseNum = 0; // out of 24
  var spouseLabelId = '';
  var spouseLabelEn = '';
  var spouseReasonId = '';
  var spouseReasonEn = '';
  if (input.hasHusband) {
    spouseNum = hasDescendant ? 6 : 12; // 1/4 or 1/2
    spouseLabelId = hasDescendant ? '1/4 (Ashabul Furudh)' : '1/2 (Ashabul Furudh)';
    spouseLabelEn = hasDescendant ? '1/4 (Fixed Share)' : '1/2 (Fixed Share)';
    spouseReasonId = hasDescendant
        ? 'Suami mendapat 1/4 karena pewaris memiliki anak/keturunan (QS. An-Nisa: 12).'
        : 'Suami mendapat 1/2 karena pewaris tidak memiliki anak/keturunan (QS. An-Nisa: 12).';
    spouseReasonEn = hasDescendant
        ? 'Husband receives 1/4 because the deceased left surviving children (Quran 4:12).'
        : 'Husband receives 1/2 because the deceased left no surviving children (Quran 4:12).';
  } else if (wives > 0) {
    spouseNum = hasDescendant ? 3 : 6; // 1/8 or 1/4
    spouseLabelId = hasDescendant ? '1/8 (Ashabul Furudh)' : '1/4 (Ashabul Furudh)';
    spouseLabelEn = hasDescendant ? '1/8 (Fixed Share)' : '1/4 (Fixed Share)';
    spouseReasonId = hasDescendant
        ? 'Istri mendapat 1/8 (dibagi rata bila lebih dari satu) karena pewaris memiliki keturunan (QS. An-Nisa: 12).'
        : 'Istri mendapat 1/4 karena pewaris tidak memiliki keturunan (QS. An-Nisa: 12).';
    spouseReasonEn = hasDescendant
        ? 'Wife receives 1/8 (shared equally if more than one) because the deceased left children (Quran 4:12).'
        : 'Wife receives 1/4 because the deceased left no children (Quran 4:12).';
  }

  var motherNum = 0;
  var motherLabelId = '';
  var motherLabelEn = '';
  var motherReasonId = '';
  var motherReasonEn = '';
  if (input.hasMother) {
    if (hasDescendant || siblingsCount >= 2) {
      motherNum = 4; // 1/6
      motherLabelId = '1/6 (Ashabul Furudh)';
      motherLabelEn = '1/6 (Fixed Share)';
      motherReasonId = 'Ibu mendapat 1/6 karena pewaris memiliki keturunan atau >= 2 saudara (QS. An-Nisa: 11).';
      motherReasonEn = 'Mother receives 1/6 because the deceased left children or 2 or more siblings (Quran 4:11).';
    } else {
      motherNum = 8; // 1/3
      motherLabelId = '1/3 (Ashabul Furudh)';
      motherLabelEn = '1/3 (Fixed Share)';
      motherReasonId = 'Ibu mendapat 1/3 karena pewaris tidak memiliki keturunan dan saudara kurang dari dua (QS. An-Nisa: 11).';
      motherReasonEn = 'Mother receives 1/3 because the deceased left no children and fewer than two siblings (Quran 4:11).';
    }
  }

  var fatherFixedNum = 0;
  var fatherIsAshabah = false;
  var fatherLabelId = '';
  var fatherLabelEn = '';
  var fatherReasonId = '';
  var fatherReasonEn = '';
  if (input.hasFather) {
    if (hasMaleDescendant) {
      fatherFixedNum = 4; // 1/6
      fatherLabelId = '1/6 (Ashabul Furudh)';
      fatherLabelEn = '1/6 (Fixed Share)';
      fatherReasonId = 'Ayah mendapat bagian pasti 1/6 karena ada anak laki-laki (QS. An-Nisa: 11).';
      fatherReasonEn = 'Father receives a fixed 1/6 share because there is a surviving son (Quran 4:11).';
    } else if (daughters > 0) {
      fatherFixedNum = 4; // 1/6 + Ashabah
      fatherIsAshabah = true;
      fatherLabelId = '1/6 + Ashabah';
      fatherLabelEn = '1/6 + Residue (\'Asabah)';
      fatherReasonId = 'Ayah mendapat 1/6 ditambah sisa harta (Ashabah) karena hanya ada anak perempuan tanpa anak laki-laki.';
      fatherReasonEn = 'Father receives 1/6 plus any remaining estate (\'Asabah) because there are only daughters and no son.';
    } else {
      fatherIsAshabah = true;
      fatherLabelId = 'Ashabah Binafsih';
      fatherLabelEn = 'Residuary Heir (\'Asabah)';
      fatherReasonId = 'Ayah menjadi Ashabah (mengambil seluruh sisa setelah Ashabul Furudh) karena pewaris tidak memiliki keturunan.';
      fatherReasonEn = 'Father inherits the entire residue after fixed shares because the deceased left no children.';
    }
  }

  var daughtersFixedNum = 0;
  var childrenAreAshabah = false;
  var daughtersLabelId = '';
  var daughtersLabelEn = '';
  var daughtersReasonId = '';
  var daughtersReasonEn = '';
  if (sons > 0) {
    childrenAreAshabah = true;
  } else if (daughters == 1) {
    daughtersFixedNum = 12; // 1/2
    daughtersLabelId = '1/2 (Ashabul Furudh)';
    daughtersLabelEn = '1/2 (Fixed Share)';
    daughtersReasonId = 'Anak perempuan tunggal tanpa anak laki-laki mendapat 1/2 harta (QS. An-Nisa: 11).';
    daughtersReasonEn = 'An only daughter with no surviving son receives 1/2 of the estate (Quran 4:11).';
  } else if (daughters >= 2) {
    daughtersFixedNum = 16; // 2/3
    daughtersLabelId = '2/3 (Ashabul Furudh)';
    daughtersLabelEn = '2/3 (Fixed Share)';
    daughtersReasonId = 'Dua atau lebih anak perempuan tanpa anak laki-laki mendapat 2/3 dibagi rata (QS. An-Nisa: 11).';
    daughtersReasonEn = 'Two or more daughters with no surviving son share 2/3 equally (Quran 4:11).';
  }

  final siblingsBlocked = hasMaleDescendant || input.hasFather;
  var sistersFixedNum = 0;
  var siblingsAreAshabah = false;
  var sistersLabelId = '';
  var sistersLabelEn = '';
  var sistersReasonId = '';
  var sistersReasonEn = '';
  if (!siblingsBlocked && (brothers > 0 || sisters > 0)) {
    if (brothers > 0) {
      siblingsAreAshabah = true;
    } else if (daughters > 0) {
      // Ashabah ma'al ghair
      siblingsAreAshabah = true;
      sistersLabelId = 'Ashabah Ma\'al Ghair';
      sistersLabelEn = 'Residuary with Daughter (\'Asabah Ma\'al Ghayr)';
      sistersReasonId = 'Saudara perempuan kandung menjadi Ashabah Ma\'al Ghair bersama anak perempuan.';
      sistersReasonEn = 'Full sisters inherit the residue alongside surviving daughters.';
    } else if (sisters == 1) {
      sistersFixedNum = 12; // 1/2
      sistersLabelId = '1/2 (Ashabul Furudh)';
      sistersLabelEn = '1/2 (Fixed Share)';
      sistersReasonId = 'Saudara perempuan kandung tunggal (kalalah tanpa anak & ayah) mendapat 1/2 (QS. An-Nisa: 176).';
      sistersReasonEn = 'A sole full sister in a kalalah case (no children or father) receives 1/2 (Quran 4:176).';
    } else if (sisters >= 2) {
      sistersFixedNum = 16; // 2/3
      sistersLabelId = '2/3 (Ashabul Furudh)';
      sistersLabelEn = '2/3 (Fixed Share)';
      sistersReasonId = 'Dua atau lebih saudara perempuan kandung (kalalah) mendapat 2/3 dibagi rata (QS. An-Nisa: 176).';
      sistersReasonEn = 'Two or more full sisters in a kalalah case share 2/3 equally (Quran 4:176).';
    }
  }

  final totalFixedNum = spouseNum + motherNum + fatherFixedNum + daughtersFixedNum + sistersFixedNum;
  final hasAnyAshabah = childrenAreAshabah || fatherIsAshabah || siblingsAreAshabah;

  var caseTypeId = 'Normal / Seimbang';
  var caseTypeEn = 'Standard / Balanced';
  var caseExplanationId = 'Pembagian mengikuti porsi Ashabul Furudh dan Ashabah secara proporsional.';
  var caseExplanationEn = 'Distribution follows fixed Quranic shares (Ashab al-Furud) and residuary heirs (\'Asabah).';

  final shares = <FaraidHeirShare>[];

  if (totalFixedNum == 0 && !hasAnyAshabah) {
    const noHeirTypeId = 'Belum Ada Ahli Waris';
    const noHeirTypeEn = 'No Heirs Selected';
    const noHeirExpId = 'Pilih minimal satu ahli waris yang masih hidup untuk menghitung pembagian Faraid.';
    const noHeirExpEn = 'Select at least one surviving heir to calculate Islamic inheritance shares.';
    return FaraidResult(
      grossEstate: gross,
      funeralAndDebt: funeralDebt,
      maxAllowedBequest: maxWasiat,
      appliedBequest: wasiat,
      netInheritableEstate: net,
      caseType: tr(lang, noHeirTypeId, noHeirTypeEn),
      caseTypeEn: noHeirTypeEn,
      caseExplanation: tr(lang, noHeirExpId, noHeirExpEn),
      caseExplanationEn: noHeirExpEn,
      shares: const [],
    );
  }

  if (totalFixedNum > 24) {
    // KASUS AUL: Total bagian pasti melebihi 24/24, sehingga penyebut dinaikkan ke totalFixedNum.
    caseTypeId = 'Kasus \'Aul ($totalFixedNum/24)';
    caseTypeEn = '\'Awl Case ($totalFixedNum/24)';
    caseExplanationId =
        'Total bagian pasti Ashabul Furudh melebihi 100% (24/$totalFixedNum), sehingga diterapkan \'Aul: setiap ahli waris mengalami penyesuaian penyebut secara proporsional.';
    caseExplanationEn =
        'Total fixed shares exceed 100% ($totalFixedNum/24), so \'Awl applies: each heir\'s share is scaled down proportionally by raising the denominator to $totalFixedNum.';
    final denom = totalFixedNum.toDouble();

    if (input.hasHusband) {
      final ratio = spouseNum / denom;
      shares.add(makeShare(
        nameId: 'Suami',
        nameEn: 'Husband',
        count: 1,
        portionId: '$spouseNum/$totalFixedNum (\'Aul dari $spouseLabelId)',
        portionEn: '$spouseNum/$totalFixedNum (\'Awl from $spouseLabelEn)',
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    } else if (wives > 0) {
      final ratio = spouseNum / denom;
      shares.add(makeShare(
        nameId: 'Istri',
        nameEn: 'Wife',
        count: wives,
        portionId: '$spouseNum/$totalFixedNum (\'Aul dari $spouseLabelId)',
        portionEn: '$spouseNum/$totalFixedNum (\'Awl from $spouseLabelEn)',
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / wives,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    }
    if (input.hasMother) {
      final ratio = motherNum / denom;
      shares.add(makeShare(
        nameId: 'Ibu',
        nameEn: 'Mother',
        count: 1,
        portionId: '$motherNum/$totalFixedNum (\'Aul dari $motherLabelId)',
        portionEn: '$motherNum/$totalFixedNum (\'Awl from $motherLabelEn)',
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: motherReasonId,
        reasonEn: motherReasonEn,
      ));
    }
    if (input.hasFather && fatherFixedNum > 0) {
      final ratio = fatherFixedNum / denom;
      shares.add(makeShare(
        nameId: 'Ayah',
        nameEn: 'Father',
        count: 1,
        portionId: '$fatherFixedNum/$totalFixedNum (\'Aul dari 1/6)',
        portionEn: '$fatherFixedNum/$totalFixedNum (\'Awl from 1/6)',
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: fatherReasonId,
        reasonEn: fatherReasonEn,
      ));
    }
    if (daughtersFixedNum > 0) {
      final ratio = daughtersFixedNum / denom;
      shares.add(makeShare(
        nameId: 'Anak Perempuan',
        nameEn: 'Daughter',
        count: daughters,
        portionId: '$daughtersFixedNum/$totalFixedNum (\'Aul dari $daughtersLabelId)',
        portionEn: '$daughtersFixedNum/$totalFixedNum (\'Awl from $daughtersLabelEn)',
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / daughters,
        reasonId: daughtersReasonId,
        reasonEn: daughtersReasonEn,
      ));
    }
    if (sistersFixedNum > 0) {
      final ratio = sistersFixedNum / denom;
      shares.add(makeShare(
        nameId: 'Saudara Perempuan Kandung',
        nameEn: 'Full Sister',
        count: sisters,
        portionId: '$sistersFixedNum/$totalFixedNum (\'Aul dari $sistersLabelId)',
        portionEn: '$sistersFixedNum/$totalFixedNum (\'Awl from $sistersLabelEn)',
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / sisters,
        reasonId: sistersReasonId,
        reasonEn: sistersReasonEn,
      ));
    }
  } else if (!hasAnyAshabah && totalFixedNum < 24) {
    // KASUS RADD: Tidak ada Ashabah dan masih ada sisa harta (dikembalikan ke Ashabul Furudh non-pasangan).
    final nonSpouseFixed = motherNum + fatherFixedNum + daughtersFixedNum + sistersFixedNum;
    if (nonSpouseFixed > 0) {
      caseTypeId = 'Kasus Radd';
      caseTypeEn = 'Radd Case (Surplus Return)';
      caseExplanationId =
          'Terdapat sisa harta setelah bagian Ashabul Furudh dan tidak ada Ashabah. Sisa harta dikembalikan (Radd) secara proporsional kepada ahli waris nasab selain suami/istri.';
      caseExplanationEn =
          'Surplus estate remains after fixed shares with no residuary heir (\'Asabah). The remainder is returned proportionally (Radd) to bloodline fixed-share heirs excluding spouses.';
    } else {
      caseTypeId = 'Hanya Pasangan (Sisa ke Baitul Maal / Kerabat)';
      caseTypeEn = 'Spouse Only (Remainder to Public Treasury / Distant Kin)';
      caseExplanationId =
          'Suami/istri mengambil bagian Ashabul Furudh-nya, sedangkan sisa harta diserahkan kepada kerabat Dzawil Arham atau kemaslahatan umat.';
      caseExplanationEn =
          'The spouse takes their fixed Quranic share, while the remaining estate goes to distant relatives (Dhawil Arham) or public welfare (Bayt al-Mal).';
    }

    final spouseRatio = spouseNum / 24.0;
    final remainderRatio = 1.0 - spouseRatio;

    if (input.hasHusband) {
      shares.add(makeShare(
        nameId: 'Suami',
        nameEn: 'Husband',
        count: 1,
        portionId: spouseLabelId,
        portionEn: spouseLabelEn,
        ratio: spouseRatio,
        total: net * spouseRatio,
        perPerson: net * spouseRatio,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    } else if (wives > 0) {
      shares.add(makeShare(
        nameId: 'Istri',
        nameEn: 'Wife',
        count: wives,
        portionId: spouseLabelId,
        portionEn: spouseLabelEn,
        ratio: spouseRatio,
        total: net * spouseRatio,
        perPerson: (net * spouseRatio) / wives,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    }

    if (nonSpouseFixed > 0) {
      if (input.hasMother) {
        final ratio = remainderRatio * (motherNum / nonSpouseFixed);
        shares.add(makeShare(
          nameId: 'Ibu',
          nameEn: 'Mother',
          count: 1,
          portionId: '$motherLabelId + Radd',
          portionEn: '$motherLabelEn + Radd',
          ratio: ratio,
          total: net * ratio,
          perPerson: net * ratio,
          reasonId: '$motherReasonId Ditambah pengembalian sisa harta (Radd).',
          reasonEn: '$motherReasonEn Plus proportional surplus return (Radd).',
        ));
      }
      if (daughtersFixedNum > 0) {
        final ratio = remainderRatio * (daughtersFixedNum / nonSpouseFixed);
        shares.add(makeShare(
          nameId: 'Anak Perempuan',
          nameEn: 'Daughter',
          count: daughters,
          portionId: '$daughtersLabelId + Radd',
          portionEn: '$daughtersLabelEn + Radd',
          ratio: ratio,
          total: net * ratio,
          perPerson: (net * ratio) / daughters,
          reasonId: '$daughtersReasonId Ditambah pengembalian sisa harta (Radd).',
          reasonEn: '$daughtersReasonEn Plus proportional surplus return (Radd).',
        ));
      }
      if (sistersFixedNum > 0) {
        final ratio = remainderRatio * (sistersFixedNum / nonSpouseFixed);
        shares.add(makeShare(
          nameId: 'Saudara Perempuan Kandung',
          nameEn: 'Full Sister',
          count: sisters,
          portionId: '$sistersLabelId + Radd',
          portionEn: '$sistersLabelEn + Radd',
          ratio: ratio,
          total: net * ratio,
          perPerson: (net * ratio) / sisters,
          reasonId: '$sistersReasonId Ditambah pengembalian sisa harta (Radd).',
          reasonEn: '$sistersReasonEn Plus proportional surplus return (Radd).',
        ));
      }
    }
  } else {
    // NORMAL + ASHABAH
    if (hasAnyAshabah) {
      caseTypeId = 'Ashabul Furudh & Ashabah';
      caseTypeEn = 'Fixed Shares & Residuary Heirs';
    }
    if (input.hasHusband) {
      final ratio = spouseNum / 24.0;
      shares.add(makeShare(
        nameId: 'Suami',
        nameEn: 'Husband',
        count: 1,
        portionId: spouseLabelId,
        portionEn: spouseLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    } else if (wives > 0) {
      final ratio = spouseNum / 24.0;
      shares.add(makeShare(
        nameId: 'Istri',
        nameEn: 'Wife',
        count: wives,
        portionId: spouseLabelId,
        portionEn: spouseLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / wives,
        reasonId: spouseReasonId,
        reasonEn: spouseReasonEn,
      ));
    }

    if (input.hasMother) {
      final ratio = motherNum / 24.0;
      shares.add(makeShare(
        nameId: 'Ibu',
        nameEn: 'Mother',
        count: 1,
        portionId: motherLabelId,
        portionEn: motherLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: motherReasonId,
        reasonEn: motherReasonEn,
      ));
    }

    final remainderRatio = ((24 - totalFixedNum).clamp(0, 24)) / 24.0;

    if (input.hasFather) {
      final fixedRatio = fatherFixedNum / 24.0;
      final ashabahRatio = (fatherIsAshabah && !childrenAreAshabah) ? remainderRatio : 0.0;
      final ratio = fixedRatio + ashabahRatio;
      shares.add(makeShare(
        nameId: 'Ayah',
        nameEn: 'Father',
        count: 1,
        portionId: fatherLabelId,
        portionEn: fatherLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: net * ratio,
        reasonId: fatherReasonId,
        reasonEn: fatherReasonEn,
      ));
    }

    if (childrenAreAshabah) {
      final totalUnits = (sons * 2) + daughters;
      if (sons > 0) {
        final sonRatio = remainderRatio * ((sons * 2) / totalUnits);
        shares.add(makeShare(
          nameId: 'Anak Laki-laki',
          nameEn: 'Son',
          count: sons,
          portionId: daughters > 0 ? 'Ashabah (2:1)' : 'Ashabah Binafsih',
          portionEn: daughters > 0 ? 'Residuary (2:1)' : 'Sole Residuary (\'Asabah)',
          ratio: sonRatio,
          total: net * sonRatio,
          perPerson: (net * sonRatio) / sons,
          reasonId: daughters > 0
              ? 'Anak laki-laki menjadi Ashabah bersama anak perempuan dengan perbandingan 2:1 (QS. An-Nisa: 11).'
              : 'Anak laki-laki mewarisi seluruh sisa harta (Ashabah Binafsih).',
          reasonEn: daughters > 0
              ? 'Sons inherit the residue alongside daughters at a 2:1 ratio (Quran 4:11).'
              : 'Sons inherit the entire remaining estate as primary residuary heirs.',
        ));
      }
      if (daughters > 0) {
        final daughterRatio = remainderRatio * (daughters / totalUnits);
        shares.add(makeShare(
          nameId: 'Anak Perempuan',
          nameEn: 'Daughter',
          count: daughters,
          portionId: 'Ashabah bil Ghair (1:2)',
          portionEn: 'Residuary with Son (1:2)',
          ratio: daughterRatio,
          total: net * daughterRatio,
          perPerson: (net * daughterRatio) / daughters,
          reasonId: 'Anak perempuan menjadi Ashabah bil Ghair bersama anak laki-laki dengan porsi 1 bagian (QS. An-Nisa: 11).',
          reasonEn: 'Daughters inherit residually alongside sons at a 1:2 share ratio (Quran 4:11).',
        ));
      }
    } else if (daughtersFixedNum > 0) {
      final ratio = daughtersFixedNum / 24.0;
      shares.add(makeShare(
        nameId: 'Anak Perempuan',
        nameEn: 'Daughter',
        count: daughters,
        portionId: daughtersLabelId,
        portionEn: daughtersLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / daughters,
        reasonId: daughtersReasonId,
        reasonEn: daughtersReasonEn,
      ));
    }

    if (siblingsAreAshabah && !childrenAreAshabah && !fatherIsAshabah) {
      final totalUnits = (brothers * 2) + sisters;
      if (brothers > 0) {
        final broRatio = remainderRatio * ((brothers * 2) / totalUnits);
        shares.add(makeShare(
          nameId: 'Saudara Laki-laki Kandung',
          nameEn: 'Full Brother',
          count: brothers,
          portionId: sisters > 0 ? 'Ashabah (2:1)' : 'Ashabah Binafsih',
          portionEn: sisters > 0 ? 'Residuary (2:1)' : 'Residuary Heir (\'Asabah)',
          ratio: broRatio,
          total: net * broRatio,
          perPerson: (net * broRatio) / brothers,
          reasonId: 'Saudara laki-laki kandung mewarisi sisa harta secara Ashabah karena tidak ada ayah dan anak laki-laki (QS. An-Nisa: 176).',
          reasonEn: 'Full brothers inherit the residue because there is no surviving father or son (Quran 4:176).',
        ));
      }
      if (sisters > 0) {
        final sisRatio = remainderRatio * (sisters / totalUnits);
        shares.add(makeShare(
          nameId: 'Saudara Perempuan Kandung',
          nameEn: 'Full Sister',
          count: sisters,
          portionId: brothers > 0 ? 'Ashabah bil Ghair (1:2)' : sistersLabelId,
          portionEn: brothers > 0 ? 'Residuary with Brother (1:2)' : sistersLabelEn,
          ratio: sisRatio,
          total: net * sisRatio,
          perPerson: (net * sisRatio) / sisters,
          reasonId: brothers > 0
              ? 'Saudara perempuan kandung menjadi Ashabah bil Ghair bersama saudara laki-laki kandung (2:1).'
              : sistersReasonId,
          reasonEn: brothers > 0
              ? 'Full sisters inherit residually alongside full brothers at a 1:2 share ratio.'
              : sistersReasonEn,
        ));
      }
    } else if (sistersFixedNum > 0) {
      final ratio = sistersFixedNum / 24.0;
      shares.add(makeShare(
        nameId: 'Saudara Perempuan Kandung',
        nameEn: 'Full Sister',
        count: sisters,
        portionId: sistersLabelId,
        portionEn: sistersLabelEn,
        ratio: ratio,
        total: net * ratio,
        perPerson: (net * ratio) / sisters,
        reasonId: sistersReasonId,
        reasonEn: sistersReasonEn,
      ));
    }
  }

  // Append blocked (Mahjub) heirs for transparent fiqh education
  if (siblingsBlocked && (brothers > 0 || sisters > 0)) {
    final blockerId = hasMaleDescendant ? 'Anak Laki-laki' : 'Ayah';
    final blockerEn = hasMaleDescendant ? 'a surviving Son' : 'the Father';
    if (brothers > 0) {
      shares.add(makeShare(
        nameId: 'Saudara Laki-laki Kandung',
        nameEn: 'Full Brother',
        count: brothers,
        portionId: 'Mahjub (Terhalang)',
        portionEn: 'Blocked (Mahjub)',
        ratio: 0,
        total: 0,
        perPerson: 0,
        reasonId: 'Terhalang (Mahjub Hirman) oleh keberadaan $blockerId.',
        reasonEn: 'Excluded (Mahjub) by the presence of $blockerEn.',
        isBlocked: true,
      ));
    }
    if (sisters > 0) {
      shares.add(makeShare(
        nameId: 'Saudara Perempuan Kandung',
        nameEn: 'Full Sister',
        count: sisters,
        portionId: 'Mahjub (Terhalang)',
        portionEn: 'Blocked (Mahjub)',
        ratio: 0,
        total: 0,
        perPerson: 0,
        reasonId: 'Terhalang (Mahjub Hirman) oleh keberadaan $blockerId.',
        reasonEn: 'Excluded (Mahjub) by the presence of $blockerEn.',
        isBlocked: true,
      ));
    }
  }

  return FaraidResult(
    grossEstate: gross,
    funeralAndDebt: funeralDebt,
    maxAllowedBequest: maxWasiat,
    appliedBequest: wasiat,
    netInheritableEstate: net,
    caseType: tr(lang, caseTypeId, caseTypeEn),
    caseTypeEn: caseTypeEn,
    caseExplanation: tr(lang, caseExplanationId, caseExplanationEn),
    caseExplanationEn: caseExplanationEn,
    shares: shares,
  );
}
