import 'base_audit_model.dart';

class SheetCuttingAuditForm extends BaseAuditForm {
  SheetCuttingAuditForm({
    dynamic id,
    required String serialNumber,
    required String auditDate,
    required String auditorName,
    required String verifiedBy,
    required String shift,
    required String po,
    required String moduleType,
    required String createdAt,
  }) : super(
         id: id,
         serialNumber: serialNumber,
         auditDate: auditDate,
         auditorName: auditorName,
         verifiedBy: verifiedBy,
         shift: shift,
         po: po,
         moduleType: moduleType,
         createdAt: createdAt,
         formType: 'sheet_cutting',
       );
  // Sheet cutting specific fields
  String? date;
  String? line;

  String? eightAMevaMake;
  String? eightAMevaFront;
  String? eightAMevaBack;
  String? eightAMpoNo;
  String? eightAMasPrPo;
  String? eightAMdimensionFront;
  String? eightAMdimensionBack;
  String? eightAMvisualCheck;
  String? eightAMdefect;
  String? eightAMremark;
  String? eightAMcheckedBy;

  String? tenAMevaMake;
  String? tenAMevaFront;
  String? tenAMevaBack;
  String? tenAMpoNo;
  String? tenAMasPrPo;
  String? tenAMdimensionFront;
  String? tenAMdimensionBack;
  String? tenAMvisualCheck;
  String? tenAMdefect;
  String? tenAMremark;
  String? tenAMcheckedBy;

  String? twelvePMevaMake;
  String? twelvePMevaFront;
  String? twelvePMevaBack;
  String? twelvePMpoNo;
  String? twelvePMasPrPo;
  String? twelvePMdimensionFront;
  String? twelvePMdimensionBack;
  String? twelvePMvisualCheck;
  String? twelvePMdefect;
  String? twelvePMremark;
  String? twelvePMcheckedBy;

  String? twoPMevaMake;
  String? twoPMevaFront;
  String? twoPMevaBack;
  String? twoPMpoNo;
  String? twoPMasPrPo;
  String? twoPMdimensionFront;
  String? twoPMdimensionBack;
  String? twoPMvisualCheck;
  String? twoPMdefect;
  String? twoPMremark;
  String? twoPMcheckedBy;

  String? fourPMevaMake;
  String? fourPMevaFront;
  String? fourPMevaBack;
  String? fourPMpoNo;
  String? fourPMasPrPo;
  String? fourPMdimensionFront;
  String? fourPMdimensionBack;
  String? fourPMvisualCheck;
  String? fourPMdefect;
  String? fourPMremark;
  String? fourPMcheckedBy;

  String? sixPMevaMake;
  String? sixPMevaFront;
  String? sixPMevaBack;
  String? sixPMpoNo;
  String? sixPMasPrPo;
  String? sixPMdimensionFront;
  String? sixPMdimensionBack;
  String? sixPMvisualCheck;
  String? sixPMdefect;
  String? sixPMremark;
  String? sixPMcheckedBy;

  String? eightPMevaMake;
  String? eightPMevaFront;
  String? eightPMevaBack;
  String? eightPMpoNo;
  String? eightPMasPrPo;
  String? eightPMdimensionFront;
  String? eightPMdimensionBack;
  String? eightPMvisualCheck;
  String? eightPMdefect;
  String? eightPMremark;
  String? eightPMcheckedBy;

  String? tenPMevaMake;
  String? tenPMevaFront;
  String? tenPMevaBack;
  String? tenPMpoNo;
  String? tenPMasPrPo;
  String? tenPMdimensionFront;
  String? tenPMdimensionBack;
  String? tenPMvisualCheck;
  String? tenPMdefect;
  String? tenPMremark;
  String? tenPMcheckedBy;

  String? twelveAMevaMake;
  String? twelveAMevaFront;
  String? twelveAMevaBack;
  String? twelveAMpoNo;
  String? twelveAMasPrPo;
  String? twelveAMdimensionFront;
  String? twelveAMdimensionBack;
  String? twelveAMvisualCheck;
  String? twelveAMdefect;
  String? twelveAMremark;
  String? twelveAMcheckedBy;

  String? twoAMevaMake;
  String? twoAMevaFront;
  String? twoAMevaBack;
  String? twoAMpoNo;
  String? twoAMasPrPo;
  String? twoAMdimensionFront;
  String? twoAMdimensionBack;
  String? twoAMvisualCheck;
  String? twoAMdefect;
  String? twoAMremark;
  String? twoAMcheckedBy;

  String? fourAMevaMake;
  String? fourAMevaFront;
  String? fourAMevaBack;
  String? fourAMpoNo;
  String? fourAMasPrPo;
  String? fourAMdimensionFront;
  String? fourAMdimensionBack;
  String? fourAMvisualCheck;
  String? fourAMdefect;
  String? fourAMremark;
  String? fourAMcheckedBy;

  String? sixAMevaMake;
  String? sixAMevaFront;
  String? sixAMevaBack;
  String? sixAMpoNo;
  String? sixAMasPrPo;
  String? sixAMdimensionFront;
  String? sixAMdimensionBack;
  String? sixAMvisualCheck;
  String? sixAMdefect;
  String? sixAMremark;
  String? sixAMcheckedBy;

  String? remarks;
  String? note;
  String? qcInnspectorName;
  String? preparedBy;
  String? verifyBy;
  String? approvedBy;

  @override
  Map<String, dynamic> toMap() {
    // Get common fields from parent class
    final Map<String, dynamic> data = getCommonFields();

    // Add sheet cutting specific fields
    data.addAll({
      'date': date,
      'line': line,
      'eightAMevaMake': eightAMevaMake,
      'eightAMevaFront': eightAMevaFront,
      'eightAMevaBack': eightAMevaBack,
      'eightAMpoNo': eightAMpoNo,
      'eightAMasPrPo': eightAMasPrPo,
      'eightAMdimensionFront': eightAMdimensionFront,
      'eightAMdimensionBack': eightAMdimensionBack,
      'eightAMvisualCheck': eightAMvisualCheck,
      'eightAMdefect': eightAMdefect,
      'eightAMremark': eightAMremark,
      'eightAMcheckedBy': eightAMcheckedBy,
      'tenAMevaMake': tenAMevaMake,
      'tenAMevaFront': tenAMevaFront,
      'tenAMevaBack': tenAMevaBack,
      'tenAMpoNo': tenAMpoNo,
      'tenAMasPrPo': tenAMasPrPo,
      'tenAMdimensionFront': tenAMdimensionFront,
      'tenAMdimensionBack': tenAMdimensionBack,
      'tenAMvisualCheck': tenAMvisualCheck,
      'tenAMdefect': tenAMdefect,
      'tenAMremark': tenAMremark,
      'tenAMcheckedBy': tenAMcheckedBy,
      'twelvePMevaMake': twelvePMevaMake,
      'twelvePMevaFront': twelvePMevaFront,
      'twelvePMevaBack': twelvePMevaBack,
      'twelvePMpoNo': twelvePMpoNo,
      'twelvePMasPrPo': twelvePMasPrPo,
      'twelvePMdimensionFront': twelvePMdimensionFront,
      'twelvePMdimensionBack': twelvePMdimensionBack,
      'twelvePMvisualCheck': twelvePMvisualCheck,
      'twelvePMdefect': twelvePMdefect,
      'twelvePMremark': twelvePMremark,
      'twelvePMcheckedBy': twelvePMcheckedBy,
      'twoPMevaMake': twoPMevaMake,
      'twoPMevaFront': twoPMevaFront,
      'twoPMevaBack': twoPMevaBack,
      'twoPMpoNo': twoPMpoNo,
      'twoPMasPrPo': twoPMasPrPo,
      'twoPMdimensionFront': twoPMdimensionFront,
      'twoPMdimensionBack': twoPMdimensionBack,
      'twoPMvisualCheck': twoPMvisualCheck,
      'twoPMdefect': twoPMdefect,
      'twoPMremark': twoPMremark,
      'twoPMcheckedBy': twoPMcheckedBy,
      'fourPMevaMake': fourPMevaMake,
      'fourPMevaFront': fourPMevaFront,
      'fourPMevaBack': fourPMevaBack,
      'fourPMpoNo': fourPMpoNo,
      'fourPMasPrPo': fourPMasPrPo,
      'fourPMdimensionFront': fourPMdimensionFront,
      'fourPMdimensionBack': fourPMdimensionBack,
      'fourPMvisualCheck': fourPMvisualCheck,
      'fourPMdefect': fourPMdefect,
      'fourPMremark': fourPMremark,
      'fourPMcheckedBy': fourPMcheckedBy,
      'sixPMevaMake': sixPMevaMake,
      'sixPMevaFront': sixPMevaFront,
      'sixPMevaBack': sixPMevaBack,
      'sixPMpoNo': sixPMpoNo,
      'sixPMasPrPo': sixPMasPrPo,
      'sixPMdimensionFront': sixPMdimensionFront,
      'sixPMdimensionBack': sixPMdimensionBack,
      'sixPMvisualCheck': sixPMvisualCheck,
      'sixPMdefect': sixPMdefect,
      'sixPMremark': sixPMremark,
      'sixPMcheckedBy': sixPMcheckedBy,
      'eightPMevaMake': eightPMevaMake,
      'eightPMevaFront': eightPMevaFront,
      'eightPMevaBack': eightPMevaBack,
      'eightPMpoNo': eightPMpoNo,
      'eightPMasPrPo': eightPMasPrPo,
      'eightPMdimensionFront': eightPMdimensionFront,
      'eightPMdimensionBack': eightPMdimensionBack,
      'eightPMvisualCheck': eightPMvisualCheck,
      'eightPMdefect': eightPMdefect,
      'eightPMremark': eightPMremark,
      'eightPMcheckedBy': eightPMcheckedBy,
      'tenPMevaMake': tenPMevaMake,
      'tenPMevaFront': tenPMevaFront,
      'tenPMevaBack': tenPMevaBack,
      'tenPMpoNo': tenPMpoNo,
      'tenPMasPrPo': tenPMasPrPo,
      'tenPMdimensionFront': tenPMdimensionFront,
      'tenPMdimensionBack': tenPMdimensionBack,
      'tenPMvisualCheck': tenPMvisualCheck,
      'tenPMdefect': tenPMdefect,
      'tenPMremark': tenPMremark,
      'tenPMcheckedBy': tenPMcheckedBy,
      'twelveAMevaMake': twelveAMevaMake,
      'twelveAMevaFront': twelveAMevaFront,
      'twelveAMevaBack': twelveAMevaBack,
      'twelveAMpoNo': twelveAMpoNo,
      'twelveAMasPrPo': twelveAMasPrPo,
      'twelveAMdimensionFront': twelveAMdimensionFront,
      'twelveAMdimensionBack': twelveAMdimensionBack,
      'twelveAMvisualCheck': twelveAMvisualCheck,
      'twelveAMdefect': twelveAMdefect,
      'twelveAMremark': twelveAMremark,
      'twelveAMcheckedBy': twelveAMcheckedBy,
      'twoAMevaMake': twoAMevaMake,
      'twoAMevaFront': twoAMevaFront,
      'twoAMevaBack': twoAMevaBack,
      'twoAMpoNo': twoAMpoNo,
      'twoAMasPrPo': twoAMasPrPo,
      'twoAMdimensionFront': twoAMdimensionFront,
      'twoAMdimensionBack': twoAMdimensionBack,
      'twoAMvisualCheck': twoAMvisualCheck,
      'twoAMdefect': twoAMdefect,
      'twoAMremark': twoAMremark,
      'twoAMcheckedBy': twoAMcheckedBy,
      'fourAMevaMake': fourAMevaMake,
      'fourAMevaFront': fourAMevaFront,
      'fourAMevaBack': fourAMevaBack,
      'fourAMpoNo': fourAMpoNo,
      'fourAMasPrPo': fourAMasPrPo,
      'fourAMdimensionFront': fourAMdimensionFront,
      'fourAMdimensionBack': fourAMdimensionBack,
      'fourAMvisualCheck': fourAMvisualCheck,
      'fourAMdefect': fourAMdefect,
      'fourAMremark': fourAMremark,
      'fourAMcheckedBy': fourAMcheckedBy,
      'sixAMevaMake': sixAMevaMake,
      'sixAMevaFront': sixAMevaFront,
      'sixAMevaBack': sixAMevaBack,
      'sixAMpoNo': sixAMpoNo,
      'sixAMasPrPo': sixAMasPrPo,
      'sixAMdimensionFront': sixAMdimensionFront,
      'sixAMdimensionBack': sixAMdimensionBack,
      'sixAMvisualCheck': sixAMvisualCheck,
      'sixAMdefect': sixAMdefect,
      'sixAMremark': sixAMremark,
      'sixAMcheckedBy': sixAMcheckedBy,
      'note': note,
      'remarks': remarks,
      'qcInnspectorName': qcInnspectorName,
      'preparedBy': preparedBy,
      'verifyBy': verifyBy,
      'approvedBy': approvedBy,
    });

    return data;
  }

  // Factory constructor to create a SheetCuttingAuditForm from a map
  factory SheetCuttingAuditForm.fromjson(Map<String, dynamic> json) {
    final form = SheetCuttingAuditForm(
      id: parseMongoId(json['_id']),
      serialNumber: json['serialNumber'] ?? '',
      auditDate: parseAuditDate(json['auditDate']),
      auditorName: json['auditorName'] ?? '',
      verifiedBy: json['verifiedBy'] ?? '',
      shift: json['shift'] ?? '',
      po: json['po'] ?? '',
      moduleType: json['moduleType'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
    form.eightAMevaMake = json['eightAMevaMake'];
    form.eightAMevaFront = json['eightAMevaFront'];
    form.eightAMevaBack = json['eightAMevaBack'];
    form.eightAMpoNo = json['eightAMpoNo'];
    form.eightAMasPrPo = json['eightAMasPrPo'];
    form.eightAMdimensionFront = json['eightAMdimensionFront'];
    form.eightAMdimensionBack = json['eightAMdimensionBack'];
    form.eightAMvisualCheck = json['eightAMvisualCheck'];
    form.eightAMdefect = json['eightAMdefect'];
    form.eightAMremark = json['eightAMremark'];
    form.eightAMcheckedBy = json['eightAMcheckedBy'];
    form.tenAMevaMake = json['tenAMevaMake'];
    form.tenAMevaFront = json['tenAMevaFront'];
    form.tenAMevaBack = json['tenAMevaBack'];
    form.tenAMpoNo = json['tenAMpoNo'];
    form.tenAMasPrPo = json['tenAMasPrPo'];
    form.tenAMdimensionFront = json['tenAMdimensionFront'];
    form.tenAMdimensionBack = json['tenAMdimensionBack'];
    form.tenAMvisualCheck = json['tenAMvisualCheck'];
    form.tenAMdefect = json['tenAMdefect'];
    form.tenAMremark = json['tenAMremark'];
    form.tenAMcheckedBy = json['tenAMcheckedBy'];
    form.twelvePMevaMake = json['twelvePMevaMake'];
    form.twelvePMevaFront = json['twelvePMevaFront'];
    form.twelvePMevaBack = json['twelvePMevaBack'];
    form.twelvePMpoNo = json['twelvePMpoNo'];
    form.twelvePMasPrPo = json['twelvePMasPrPo'];
    form.twelvePMdimensionFront = json['twelvePMdimensionFront'];
    form.twelvePMdimensionBack = json['twelvePMdimensionBack'];
    form.twelvePMvisualCheck = json['twelvePMvisualCheck'];
    form.twelvePMdefect = json['twelvePMdefect'];
    form.twelvePMremark = json['twelvePMremark'];
    form.twelvePMcheckedBy = json['twelvePMcheckedBy'];
    form.twoPMevaMake = json['twoPMevaMake'];
    form.twoPMevaFront = json['twoPMevaFront'];
    form.twoPMevaBack = json['twoPMevaBack'];
    form.twoPMpoNo = json['twoPMpoNo'];
    form.twoPMasPrPo = json['twoPMasPrPo'];
    form.twoPMdimensionFront = json['twoPMdimensionFront'];
    form.twoPMdimensionBack = json['twoPMdimensionBack'];
    form.twoPMvisualCheck = json['twoPMvisualCheck'];
    form.twoPMdefect = json['twoPMdefect'];
    form.twoPMremark = json['twoPMremark'];
    form.twoPMcheckedBy = json['twoPMcheckedBy'];
    form.fourPMevaMake = json['fourPMevaMake'];
    form.fourPMevaFront = json['fourPMevaFront'];
    form.fourPMevaBack = json['fourPMevaBack'];
    form.fourPMpoNo = json['fourPMpoNo'];
    form.fourPMasPrPo = json['fourPMasPrPo'];
    form.fourPMdimensionFront = json['fourPMdimensionFront'];
    form.fourPMdimensionBack = json['fourPMdimensionBack'];
    form.fourPMvisualCheck = json['fourPMvisualCheck'];
    form.fourPMdefect = json['fourPMdefect'];
    form.fourPMremark = json['fourPMremark'];
    form.fourPMcheckedBy = json['fourPMcheckedBy'];
    form.sixPMevaMake = json['sixPMevaMake'];
    form.sixPMevaFront = json['sixPMevaFront'];
    form.sixPMevaBack = json['sixPMevaBack'];
    form.sixPMpoNo = json['sixPMpoNo'];
    form.sixPMasPrPo = json['sixPMasPrPo'];
    form.sixPMdimensionFront = json['sixPMdimensionFront'];
    form.sixPMdimensionBack = json['sixPMdimensionBack'];
    form.sixPMvisualCheck = json['sixPMvisualCheck'];
    form.sixPMdefect = json['sixPMdefect'];
    form.sixPMremark = json['sixPMremark'];
    form.sixPMcheckedBy = json['sixPMcheckedBy'];
    form.eightPMevaMake = json['eightPMevaMake'];
    form.eightPMevaFront = json['eightPMevaFront'];
    form.eightPMevaBack = json['eightPMevaBack'];
    form.eightPMpoNo = json['eightPMpoNo'];
    form.eightPMasPrPo = json['eightPMasPrPo'];
    form.eightPMdimensionFront = json['eightPMdimensionFront'];
    form.eightPMdimensionBack = json['eightPMdimensionBack'];
    form.eightPMvisualCheck = json['eightPMvisualCheck'];
    form.eightPMdefect = json['eightPMdefect'];
    form.eightPMremark = json['eightPMremark'];
    form.eightPMcheckedBy = json['eightPMcheckedBy'];
    form.tenPMevaMake = json['tenPMevaMake'];
    form.tenPMevaFront = json['tenPMevaFront'];
    form.tenPMevaBack = json['tenPMevaBack'];
    form.tenPMpoNo = json['tenPMpoNo'];
    form.tenPMasPrPo = json['tenPMasPrPo'];
    form.tenPMdimensionFront = json['tenPMdimensionFront'];
    form.tenPMdimensionBack = json['tenPMdimensionBack'];
    form.tenPMvisualCheck = json['tenPMvisualCheck'];
    form.tenPMdefect = json['tenPMdefect'];
    form.tenPMremark = json['tenPMremark'];
    form.tenPMcheckedBy = json['tenPMcheckedBy'];
    form.twelveAMevaMake = json['twelveAMevaMake'];
    form.twelveAMevaFront = json['twelveAMevaFront'];
    form.twelveAMevaBack = json['twelveAMevaBack'];
    form.twelveAMpoNo = json['twelveAMpoNo'];
    form.twelveAMasPrPo = json['twelveAMasPrPo'];
    form.twelveAMdimensionFront = json['twelveAMdimensionFront'];
    form.twelveAMdimensionBack = json['twelveAMdimensionBack'];
    form.twelveAMvisualCheck = json['twelveAMvisualCheck'];
    form.twelveAMdefect = json['twelveAMdefect'];
    form.twelveAMremark = json['twelveAMremark'];
    form.twelveAMcheckedBy = json['twelveAMcheckedBy'];
    form.twoAMevaMake = json['twoAMevaMake'];
    form.twoAMevaFront = json['twoAMevaFront'];
    form.twoAMevaBack = json['twoAMevaBack'];
    form.twoAMpoNo = json['twoAMpoNo'];
    form.twoAMasPrPo = json['twoAMasPrPo'];
    form.twoAMdimensionFront = json['twoAMdimensionFront'];
    form.twoAMdimensionBack = json['twoAMdimensionBack'];
    form.twoAMvisualCheck = json['twoAMvisualCheck'];
    form.twoAMdefect = json['twoAMdefect'];
    form.twoAMremark = json['twoAMremark'];
    form.twoAMcheckedBy = json['twoAMcheckedBy'];
    form.fourAMevaMake = json['fourAMevaMake'];
    form.fourAMevaFront = json['fourAMevaFront'];
    form.fourAMevaBack = json['fourAMevaBack'];
    form.fourAMpoNo = json['fourAMpoNo'];
    form.fourAMasPrPo = json['fourAMasPrPo'];
    form.fourAMdimensionFront = json['fourAMdimensionFront'];
    form.fourAMdimensionBack = json['fourAMdimensionBack'];
    form.fourAMvisualCheck = json['fourAMvisualCheck'];
    form.fourAMdefect = json['fourAMdefect'];
    form.fourAMremark = json['fourAMremark'];
    form.fourAMcheckedBy = json['fourAMcheckedBy'];
    form.sixAMevaMake = json['sixAMevaMake'];
    form.sixAMevaFront = json['sixAMevaFront'];
    form.sixAMevaBack = json['sixAMevaBack'];
    form.sixAMpoNo = json['sixAMpoNo'];
    form.sixAMasPrPo = json['sixAMasPrPo'];
    form.sixAMdimensionFront = json['sixAMdimensionFront'];
    form.sixAMdimensionBack = json['sixAMdimensionBack'];
    form.sixAMvisualCheck = json['sixAMvisualCheck'];
    form.sixAMdefect = json['sixAMdefect'];
    form.sixAMremark = json['sixAMremark'];
    form.sixAMcheckedBy = json['sixAMcheckedBy'];
    form.note = json['note'];
    form.remarks = json['remarks'];
    form.qcInnspectorName = json['qcInnspectorName'];
    form.preparedBy = json['preparedBy'];
    form.verifyBy = json['verifyBy'];
    form.approvedBy = json['approvedBy'];
    form.date = json['date'];
    form.line = json['line'];

    return form;
  }
}
