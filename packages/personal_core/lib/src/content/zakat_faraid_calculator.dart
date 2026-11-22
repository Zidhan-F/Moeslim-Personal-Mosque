/// Kalkulator Zakat (Maal, Penghasilan, Perdagangan, Fitrah), Fidyah, dan Waris Islam (Faraid termasuk Aul & Radd).
class ZakatMaalEvaluation {
  final double grossAssets;
  final double deductibleDebt;
  final double netZakatable;
  final double nisabValue;
  final bool isObligatory;
  final double zakatAmount;
  final String explanation;

  const ZakatMaalEvaluation({
    required this.grossAssets,
    required this.deductibleDebt,
    required this.netZakatable,
    required this.nisabValue,
    required this.isObligatory,
    required this.zakatAmount,
    required this.explanation,
  });
}

ZakatMaalEvaluation calculateZakatMaal({
  required double cashAndSavings,
  required double goldGrams,
  required double tradeInventory,
  required double shortTermDebt,
  required double goldPricePerGram,
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
  final explanation = obligatory
      ? 'Harta bersih telah mencapai nisab setara 85 gram emas dan wajib dizakati sebesar 2,5% setelah mencapai haul (1 tahun Hijriah).'
      : 'Harta bersih belum mencapai batas nisab 85 gram emas. Belum wajib zakat maal, namun dianjurkan bersedekah sunnah.';
  return ZakatMaalEvaluation(
    grossAssets: gross,
    deductibleDebt: debt,
    netZakatable: net,
    nisabValue: nisab,
    isObligatory: obligatory,
    zakatAmount: zakat,
    explanation: explanation,
  );
}

ZakatMaalEvaluation calculateZakatProfesiMonthly({
  required double monthlyIncome,
  required double monthlyNeedsOrDebt,
  required double goldPricePerGram,
}) {
  final safeGoldPrice = goldPricePerGram <= 0 ? 1500000.0 : goldPricePerGram;
  final annualNisab = 85.0 * safeGoldPrice;
  final monthlyNisab = annualNisab / 12.0;
  final gross = monthlyIncome < 0 ? 0.0 : monthlyIncome;
  final deduction = monthlyNeedsOrDebt < 0 ? 0.0 : monthlyNeedsOrDebt;
  final net = (gross - deduction) < 0 ? 0.0 : (gross - deduction);
  final obligatory = net >= monthlyNisab;
  final zakat = obligatory ? net * 0.025 : 0.0;
  final explanation = obligatory
      ? 'Penghasilan bersih bulanan mencapai nisab bulanan (1/12 dari 85 gram emas). Zakat penghasilan sebesar 2,5% dapat ditunaikan langsung setiap bulan.'
      : 'Penghasilan bersih bulanan belum mencapai nisab bulanan (1/12 dari 85 gram emas).';
  return ZakatMaalEvaluation(
    grossAssets: gross,
    deductibleDebt: deduction,
    netZakatable: net,
    nisabValue: monthlyNisab,
    isObligatory: obligatory,
    zakatAmount: zakat,
    explanation: explanation,
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
  final int count;
  final String portionLabel;
  final double totalShareRatio;
  final double totalAmount;
  final double perPersonAmount;
  final String legalReason;
  final bool isBlocked;

  const FaraidHeirShare({
    required this.heirName,
    required this.count,
    required this.portionLabel,
    required this.totalShareRatio,
    required this.totalAmount,
    required this.perPersonAmount,
    required this.legalReason,
    this.isBlocked = false,
  });
}

class FaraidResult {
  final double grossEstate;
  final double funeralAndDebt;
  final double maxAllowedBequest;
  final double appliedBequest;
  final double netInheritableEstate;
  final String caseType;
  final String caseExplanation;
  final List<FaraidHeirShare> shares;

  const FaraidResult({
    required this.grossEstate,
    required this.funeralAndDebt,
    required this.maxAllowedBequest,
    required this.appliedBequest,
    required this.netInheritableEstate,
    required this.caseType,
    required this.caseExplanation,
    required this.shares,
  });
}

FaraidResult computeFaraid(FaraidInput input) {
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

  // Base ratio out of 24 (LCM of 2, 3, 4, 6, 8 = 24)
  var spouseNum = 0; // out of 24
  var spouseLabel = '';
  var spouseReason = '';
  if (input.hasHusband) {
    spouseNum = hasDescendant ? 6 : 12; // 1/4 or 1/2
    spouseLabel = hasDescendant ? '1/4 (Ashabul Furudh)' : '1/2 (Ashabul Furudh)';
    spouseReason = hasDescendant
        ? 'Suami mendapat 1/4 karena pewaris memiliki anak/keturunan (QS. An-Nisa: 12).'
        : 'Suami mendapat 1/2 karena pewaris tidak memiliki anak/keturunan (QS. An-Nisa: 12).';
  } else if (wives > 0) {
    spouseNum = hasDescendant ? 3 : 6; // 1/8 or 1/4
    spouseLabel = hasDescendant ? '1/8 (Ashabul Furudh)' : '1/4 (Ashabul Furudh)';
    spouseReason = hasDescendant
        ? 'Istri mendapat 1/8 (dibagi rata bila lebih dari satu) karena pewaris memiliki keturunan (QS. An-Nisa: 12).'
        : 'Istri mendapat 1/4 karena pewaris tidak memiliki keturunan (QS. An-Nisa: 12).';
  }

  var motherNum = 0;
  var motherLabel = '';
  var motherReason = '';
  if (input.hasMother) {
    if (hasDescendant || siblingsCount >= 2) {
      motherNum = 4; // 1/6
      motherLabel = '1/6 (Ashabul Furudh)';
      motherReason = 'Ibu mendapat 1/6 karena pewaris memiliki keturunan atau >= 2 saudara (QS. An-Nisa: 11).';
    } else {
      motherNum = 8; // 1/3
      motherLabel = '1/3 (Ashabul Furudh)';
      motherReason = 'Ibu mendapat 1/3 karena pewaris tidak memiliki keturunan dan saudara kurang dari dua (QS. An-Nisa: 11).';
    }
  }

  var fatherFixedNum = 0;
  var fatherIsAshabah = false;
  var fatherLabel = '';
  var fatherReason = '';
  if (input.hasFather) {
    if (hasMaleDescendant) {
      fatherFixedNum = 4; // 1/6
      fatherLabel = '1/6 (Ashabul Furudh)';
      fatherReason = 'Ayah mendapat bagian pasti 1/6 karena ada anak laki-laki (QS. An-Nisa: 11).';
    } else if (daughters > 0) {
      fatherFixedNum = 4; // 1/6 + Ashabah
      fatherIsAshabah = true;
      fatherLabel = '1/6 + Ashabah';
      fatherReason = 'Ayah mendapat 1/6 ditambah sisa harta (Ashabah) karena hanya ada anak perempuan tanpa anak laki-laki.';
    } else {
      fatherIsAshabah = true;
      fatherLabel = 'Ashabah Binafsih';
      fatherReason = 'Ayah menjadi Ashabah (mengambil seluruh sisa setelah Ashabul Furudh) karena pewaris tidak memiliki keturunan.';
    }
  }

  var daughtersFixedNum = 0;
  var childrenAreAshabah = false;
  var daughtersLabel = '';
  var daughtersReason = '';
  if (sons > 0) {
    childrenAreAshabah = true;
  } else if (daughters == 1) {
    daughtersFixedNum = 12; // 1/2
    daughtersLabel = '1/2 (Ashabul Furudh)';
    daughtersReason = 'Anak perempuan tunggal tanpa anak laki-laki mendapat 1/2 harta (QS. An-Nisa: 11).';
  } else if (daughters >= 2) {
    daughtersFixedNum = 16; // 2/3
    daughtersLabel = '2/3 (Ashabul Furudh)';
    daughtersReason = 'Dua atau lebih anak perempuan tanpa anak laki-laki mendapat 2/3 dibagi rata (QS. An-Nisa: 11).';
  }

  final siblingsBlocked = hasMaleDescendant || input.hasFather;
  var sistersFixedNum = 0;
  var siblingsAreAshabah = false;
  var sistersLabel = '';
  var sistersReason = '';
  if (!siblingsBlocked && (brothers > 0 || sisters > 0)) {
    if (brothers > 0) {
      siblingsAreAshabah = true;
    } else if (daughters > 0) {
      // Ashabah ma'al ghair
      siblingsAreAshabah = true;
      sistersLabel = 'Ashabah Ma\'al Ghair';
      sistersReason = 'Saudara perempuan kandung menjadi Ashabah Ma\'al Ghair bersama anak perempuan.';
    } else if (sisters == 1) {
      sistersFixedNum = 12; // 1/2
      sistersLabel = '1/2 (Ashabul Furudh)';
      sistersReason = 'Saudara perempuan kandung tunggal (kalalah tanpa anak & ayah) mendapat 1/2 (QS. An-Nisa: 176).';
    } else if (sisters >= 2) {
      sistersFixedNum = 16; // 2/3
      sistersLabel = '2/3 (Ashabul Furudh)';
      sistersReason = 'Dua atau lebih saudara perempuan kandung (kalalah) mendapat 2/3 dibagi rata (QS. An-Nisa: 176).';
    }
  }

  final totalFixedNum = spouseNum + motherNum + fatherFixedNum + daughtersFixedNum + sistersFixedNum;
  final hasAnyAshabah = childrenAreAshabah || fatherIsAshabah || siblingsAreAshabah;

  var caseType = 'Normal / Seimbang';
  var caseExplanation = 'Pembagian mengikuti porsi Ashabul Furudh dan Ashabah secara proporsional.';

  final shares = <FaraidHeirShare>[];

  if (totalFixedNum == 0 && !hasAnyAshabah) {
    return FaraidResult(
      grossEstate: gross,
      funeralAndDebt: funeralDebt,
      maxAllowedBequest: maxWasiat,
      appliedBequest: wasiat,
      netInheritableEstate: net,
      caseType: 'Belum Ada Ahli Waris',
      caseExplanation: 'Pilih minimal satu ahli waris yang masih hidup untuk menghitung pembagian Faraid.',
      shares: const [],
    );
  }

  if (totalFixedNum > 24) {
    // KASUS AUL: Total bagian pasti melebihi 24/24, sehingga penyebut dinaikkan ke totalFixedNum.
    caseType = 'Kasus \'Aul ($totalFixedNum/24)';
    caseExplanation =
        'Total bagian pasti Ashabul Furudh melebihi 100% (24/$totalFixedNum), sehingga diterapkan \'Aul: setiap ahli waris mengalami penyesuaian penyebut secara proporsional.';
    final denom = totalFixedNum.toDouble();

    if (input.hasHusband) {
      final ratio = spouseNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Suami',
        count: 1,
        portionLabel: '$spouseNum/$totalFixedNum (\'Aul dari $spouseLabel)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: spouseReason,
      ));
    } else if (wives > 0) {
      final ratio = spouseNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Istri',
        count: wives,
        portionLabel: '$spouseNum/$totalFixedNum (\'Aul dari $spouseLabel)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / wives,
        legalReason: spouseReason,
      ));
    }
    if (input.hasMother) {
      final ratio = motherNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Ibu',
        count: 1,
        portionLabel: '$motherNum/$totalFixedNum (\'Aul dari $motherLabel)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: motherReason,
      ));
    }
    if (input.hasFather && fatherFixedNum > 0) {
      final ratio = fatherFixedNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Ayah',
        count: 1,
        portionLabel: '$fatherFixedNum/$totalFixedNum (\'Aul dari 1/6)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: fatherReason,
      ));
    }
    if (daughtersFixedNum > 0) {
      final ratio = daughtersFixedNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Anak Perempuan',
        count: daughters,
        portionLabel: '$daughtersFixedNum/$totalFixedNum (\'Aul dari $daughtersLabel)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / daughters,
        legalReason: daughtersReason,
      ));
    }
    if (sistersFixedNum > 0) {
      final ratio = sistersFixedNum / denom;
      shares.add(FaraidHeirShare(
        heirName: 'Saudara Perempuan Kandung',
        count: sisters,
        portionLabel: '$sistersFixedNum/$totalFixedNum (\'Aul dari $sistersLabel)',
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / sisters,
        legalReason: sistersReason,
      ));
    }
  } else if (!hasAnyAshabah && totalFixedNum < 24) {
    // KASUS RADD: Tidak ada Ashabah dan masih ada sisa harta (dikembalikan ke Ashabul Furudh non-pasangan).
    final nonSpouseFixed = motherNum + fatherFixedNum + daughtersFixedNum + sistersFixedNum;
    if (nonSpouseFixed > 0) {
      caseType = 'Kasus Radd';
      caseExplanation =
          'Terdapat sisa harta setelah bagian Ashabul Furudh dan tidak ada Ashabah. Sisa harta dikembalikan (Radd) secara proporsional kepada ahli waris nasab selain suami/istri.';
    } else {
      caseType = 'Hanya Pasangan (Sisa ke Baitul Maal / Kerabat)';
      caseExplanation =
          'Suami/istri mengambil bagian Ashabul Furudh-nya, sedangkan sisa harta diserahkan kepada kerabat Dzawil Arham atau kemaslahatan umat.';
    }

    final spouseRatio = spouseNum / 24.0;
    final remainderRatio = 1.0 - spouseRatio;

    if (input.hasHusband) {
      shares.add(FaraidHeirShare(
        heirName: 'Suami',
        count: 1,
        portionLabel: spouseLabel,
        totalShareRatio: spouseRatio,
        totalAmount: net * spouseRatio,
        perPersonAmount: net * spouseRatio,
        legalReason: spouseReason,
      ));
    } else if (wives > 0) {
      shares.add(FaraidHeirShare(
        heirName: 'Istri',
        count: wives,
        portionLabel: spouseLabel,
        totalShareRatio: spouseRatio,
        totalAmount: net * spouseRatio,
        perPersonAmount: (net * spouseRatio) / wives,
        legalReason: spouseReason,
      ));
    }

    if (nonSpouseFixed > 0) {
      if (input.hasMother) {
        final ratio = remainderRatio * (motherNum / nonSpouseFixed);
        shares.add(FaraidHeirShare(
          heirName: 'Ibu',
          count: 1,
          portionLabel: '$motherLabel + Radd',
          totalShareRatio: ratio,
          totalAmount: net * ratio,
          perPersonAmount: net * ratio,
          legalReason: '$motherReason Ditambah pengembalian sisa harta (Radd).',
        ));
      }
      if (daughtersFixedNum > 0) {
        final ratio = remainderRatio * (daughtersFixedNum / nonSpouseFixed);
        shares.add(FaraidHeirShare(
          heirName: 'Anak Perempuan',
          count: daughters,
          portionLabel: '$daughtersLabel + Radd',
          totalShareRatio: ratio,
          totalAmount: net * ratio,
          perPersonAmount: (net * ratio) / daughters,
          legalReason: '$daughtersReason Ditambah pengembalian sisa harta (Radd).',
        ));
      }
      if (sistersFixedNum > 0) {
        final ratio = remainderRatio * (sistersFixedNum / nonSpouseFixed);
        shares.add(FaraidHeirShare(
          heirName: 'Saudara Perempuan Kandung',
          count: sisters,
          portionLabel: '$sistersLabel + Radd',
          totalShareRatio: ratio,
          totalAmount: net * ratio,
          perPersonAmount: (net * ratio) / sisters,
          legalReason: '$sistersReason Ditambah pengembalian sisa harta (Radd).',
        ));
      }
    }
  } else {
    // NORMAL + ASHABAH
    if (hasAnyAshabah) {
      caseType = 'Ashabul Furudh & Ashabah';
    }
    if (input.hasHusband) {
      final ratio = spouseNum / 24.0;
      shares.add(FaraidHeirShare(
        heirName: 'Suami',
        count: 1,
        portionLabel: spouseLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: spouseReason,
      ));
    } else if (wives > 0) {
      final ratio = spouseNum / 24.0;
      shares.add(FaraidHeirShare(
        heirName: 'Istri',
        count: wives,
        portionLabel: spouseLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / wives,
        legalReason: spouseReason,
      ));
    }

    if (input.hasMother) {
      final ratio = motherNum / 24.0;
      shares.add(FaraidHeirShare(
        heirName: 'Ibu',
        count: 1,
        portionLabel: motherLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: motherReason,
      ));
    }

    final remainderRatio = ((24 - totalFixedNum).clamp(0, 24)) / 24.0;

    if (input.hasFather) {
      final fixedRatio = fatherFixedNum / 24.0;
      final ashabahRatio = (fatherIsAshabah && !childrenAreAshabah) ? remainderRatio : 0.0;
      final ratio = fixedRatio + ashabahRatio;
      shares.add(FaraidHeirShare(
        heirName: 'Ayah',
        count: 1,
        portionLabel: fatherLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: net * ratio,
        legalReason: fatherReason,
      ));
    }

    if (childrenAreAshabah) {
      final totalUnits = (sons * 2) + daughters;
      if (sons > 0) {
        final sonRatio = remainderRatio * ((sons * 2) / totalUnits);
        shares.add(FaraidHeirShare(
          heirName: 'Anak Laki-laki',
          count: sons,
          portionLabel: daughters > 0 ? 'Ashabah (2:1)' : 'Ashabah Binafsih',
          totalShareRatio: sonRatio,
          totalAmount: net * sonRatio,
          perPersonAmount: (net * sonRatio) / sons,
          legalReason: daughters > 0
              ? 'Anak laki-laki menjadi Ashabah bersama anak perempuan dengan perbandingan 2:1 (QS. An-Nisa: 11).'
              : 'Anak laki-laki mewarisi seluruh sisa harta (Ashabah Binafsih).',
        ));
      }
      if (daughters > 0) {
        final daughterRatio = remainderRatio * (daughters / totalUnits);
        shares.add(FaraidHeirShare(
          heirName: 'Anak Perempuan',
          count: daughters,
          portionLabel: 'Ashabah bil Ghair (1:2)',
          totalShareRatio: daughterRatio,
          totalAmount: net * daughterRatio,
          perPersonAmount: (net * daughterRatio) / daughters,
          legalReason: 'Anak perempuan menjadi Ashabah bil Ghair bersama anak laki-laki dengan porsi 1 bagian (QS. An-Nisa: 11).',
        ));
      }
    } else if (daughtersFixedNum > 0) {
      final ratio = daughtersFixedNum / 24.0;
      shares.add(FaraidHeirShare(
        heirName: 'Anak Perempuan',
        count: daughters,
        portionLabel: daughtersLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / daughters,
        legalReason: daughtersReason,
      ));
    }

    if (siblingsAreAshabah && !childrenAreAshabah && !fatherIsAshabah) {
      final totalUnits = (brothers * 2) + sisters;
      if (brothers > 0) {
        final broRatio = remainderRatio * ((brothers * 2) / totalUnits);
        shares.add(FaraidHeirShare(
          heirName: 'Saudara Laki-laki Kandung',
          count: brothers,
          portionLabel: sisters > 0 ? 'Ashabah (2:1)' : 'Ashabah Binafsih',
          totalShareRatio: broRatio,
          totalAmount: net * broRatio,
          perPersonAmount: (net * broRatio) / brothers,
          legalReason: 'Saudara laki-laki kandung mewarisi sisa harta secara Ashabah karena tidak ada ayah dan anak laki-laki (QS. An-Nisa: 176).',
        ));
      }
      if (sisters > 0) {
        final sisRatio = remainderRatio * (sisters / totalUnits);
        shares.add(FaraidHeirShare(
          heirName: 'Saudara Perempuan Kandung',
          count: sisters,
          portionLabel: brothers > 0 ? 'Ashabah bil Ghair (1:2)' : sistersLabel,
          totalShareRatio: sisRatio,
          totalAmount: net * sisRatio,
          perPersonAmount: (net * sisRatio) / sisters,
          legalReason: brothers > 0
              ? 'Saudara perempuan kandung menjadi Ashabah bil Ghair bersama saudara laki-laki kandung (2:1).'
              : sistersReason,
        ));
      }
    } else if (sistersFixedNum > 0) {
      final ratio = sistersFixedNum / 24.0;
      shares.add(FaraidHeirShare(
        heirName: 'Saudara Perempuan Kandung',
        count: sisters,
        portionLabel: sistersLabel,
        totalShareRatio: ratio,
        totalAmount: net * ratio,
        perPersonAmount: (net * ratio) / sisters,
        legalReason: sistersReason,
      ));
    }
  }

  // Append blocked (Mahjub) heirs for transparent fiqh education
  if (siblingsBlocked && (brothers > 0 || sisters > 0)) {
    final blocker = hasMaleDescendant ? 'Anak Laki-laki' : 'Ayah';
    if (brothers > 0) {
      shares.add(FaraidHeirShare(
        heirName: 'Saudara Laki-laki Kandung',
        count: brothers,
        portionLabel: 'Mahjub (Terhalang)',
        totalShareRatio: 0,
        totalAmount: 0,
        perPersonAmount: 0,
        legalReason: 'Terhalang (Mahjub Hirman) oleh keberadaan $blocker.',
        isBlocked: true,
      ));
    }
    if (sisters > 0) {
      shares.add(FaraidHeirShare(
        heirName: 'Saudara Perempuan Kandung',
        count: sisters,
        portionLabel: 'Mahjub (Terhalang)',
        totalShareRatio: 0,
        totalAmount: 0,
        perPersonAmount: 0,
        legalReason: 'Terhalang (Mahjub Hirman) oleh keberadaan $blocker.',
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
    caseType: caseType,
    caseExplanation: caseExplanation,
    shares: shares,
  );
}
