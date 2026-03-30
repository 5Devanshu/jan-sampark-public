// lib/features/voter/profile/models/voter_profile_models.dart

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// Full Voter Profile
// Source: GET /users/profile
// ─────────────────────────────────────────────

class VoterLocation {
  const VoterLocation({
    this.wardId,
    this.areaId,
    this.wardName,
    this.wardCode,
    this.areaName,
    this.areaCode,
  });

  final String? wardId;
  final String? areaId;
  final String? wardName;
  final String? wardCode;
  final String? areaName;
  final String? areaCode;

  factory VoterLocation.fromJson(Map<String, dynamic> j) => VoterLocation(
        wardId:   j['ward_id']   as String?,
        areaId:   j['area_id']   as String?,
        wardName: j['ward_name'] as String?,
        wardCode: j['ward_code'] as String?,
        areaName: j['area_name'] as String?,
        areaCode: j['area_code'] as String?,
      );
}

class VoterDemographics {
  const VoterDemographics({
    this.gender,
    this.genderSpecify,
    this.dateOfBirth,
    this.age,
    this.religion,
    this.education,
    this.occupation,
    this.profession,
    this.annualIncomeRange,
    this.familyAdults,
    this.familyKids,
  });

  final String? gender;
  final String? genderSpecify;
  final String? dateOfBirth;
  final int?    age;
  final String? religion;
  final String? education;
  final String? occupation;
  final String? profession;
  final String? annualIncomeRange;
  final int?    familyAdults;
  final int?    familyKids;

  factory VoterDemographics.fromJson(Map<String, dynamic> j) =>
      VoterDemographics(
        gender:            j['gender']             as String?,
        genderSpecify:     j['gender_specify']      as String?,
        dateOfBirth:       j['date_of_birth']       as String?,
        age:               j['age']                 as int?,
        religion:          j['religion']            as String?,
        education:         j['education']           as String?,
        occupation:        j['occupation']          as String?,
        profession:        j['profession']          as String?,
        annualIncomeRange: j['annual_income_range'] as String?,
        familyAdults:      j['family_adults']       as int?,
        familyKids:        j['family_kids']         as int?,
      );

  factory VoterDemographics.empty() => const VoterDemographics();

  VoterDemographics copyWith({
    String? gender,
    String? genderSpecify,
    String? dateOfBirth,
    int?    age,
    String? religion,
    String? education,
    String? occupation,
    String? profession,
    String? annualIncomeRange,
    int?    familyAdults,
    int?    familyKids,
  }) =>
      VoterDemographics(
        gender:            gender            ?? this.gender,
        genderSpecify:     genderSpecify     ?? this.genderSpecify,
        dateOfBirth:       dateOfBirth       ?? this.dateOfBirth,
        age:               age               ?? this.age,
        religion:          religion          ?? this.religion,
        education:         education         ?? this.education,
        occupation:        occupation        ?? this.occupation,
        profession:        profession        ?? this.profession,
        annualIncomeRange: annualIncomeRange ?? this.annualIncomeRange,
        familyAdults:      familyAdults      ?? this.familyAdults,
        familyKids:        familyKids        ?? this.familyKids,
      );
}

class VoterProfile {
  const VoterProfile({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.role,
    required this.language,
    required this.epicVerified,
    required this.isActive,
    required this.location,
    this.profilePhotoUrl,
    this.ocrStatus,
    this.idDocumentType,
    this.voterProfile,
    this.createdAt,
  });

  final String            id;
  final String            fullName;
  final String            mobile;
  final String            role;
  final String            language;
  final bool              epicVerified;
  final bool              isActive;
  final VoterLocation     location;
  final String?           profilePhotoUrl;
  final String?           ocrStatus;        // pending|processing|completed|failed
  final String?           idDocumentType;
  final VoterDemographics? voterProfile;
  final DateTime?         createdAt;

  String get firstName => fullName.trim().split(' ').first;

  bool get profileComplete =>
      voterProfile?.gender != null &&
      voterProfile?.dateOfBirth != null &&
      location.wardId != null;

  factory VoterProfile.fromJson(Map<String, dynamic> j) {
    final locRaw     = j['location']     as Map<String, dynamic>? ?? {};
    final vpRaw      = j['voter_profile'] as Map<String, dynamic>?;
    return VoterProfile(
      id:              j['id']               as String? ?? '',
      fullName:        j['full_name']        as String? ?? '',
      mobile:          j['mobile']           as String? ?? '',
      role:            j['role']             as String? ?? 'voter',
      language:        j['language']         as String? ?? 'english',
      epicVerified:    j['epic_verified']    as bool?   ?? false,
      isActive:        j['is_active']        as bool?   ?? true,
      location:        VoterLocation.fromJson(locRaw),
      profilePhotoUrl: j['profile_photo_url'] as String?,
      ocrStatus:       j['ocr_status']       as String?,
      idDocumentType:  j['id_document_type'] as String?,
      voterProfile:    vpRaw != null
          ? VoterDemographics.fromJson(vpRaw)
          : null,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
    );
  }

  VoterProfile copyWith({
    String?           fullName,
    String?           language,
    String?           profilePhotoUrl,
    VoterLocation?    location,
    VoterDemographics? voterProfile,
    bool?             epicVerified,
    String?           ocrStatus,
  }) =>
      VoterProfile(
        id:              id,
        fullName:        fullName        ?? this.fullName,
        mobile:          mobile,
        role:            role,
        language:        language        ?? this.language,
        epicVerified:    epicVerified    ?? this.epicVerified,
        isActive:        isActive,
        location:        location        ?? this.location,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        ocrStatus:       ocrStatus       ?? this.ocrStatus,
        idDocumentType:  idDocumentType,
        voterProfile:    voterProfile    ?? this.voterProfile,
        createdAt:       createdAt,
      );
}

// ─────────────────────────────────────────────
// OCR Job Status
// Source: GET /ocr/status
// ─────────────────────────────────────────────

class OcrExtractedData {
  const OcrExtractedData({
    this.name,
    this.idNumber,
    this.dateOfBirth,
    this.address,
  });

  final String? name;
  final String? idNumber;
  final String? dateOfBirth;
  final String? address;

  factory OcrExtractedData.fromJson(Map<String, dynamic> j) =>
      OcrExtractedData(
        name:        j['name']          as String?,
        idNumber:    j['id_number']     as String?,
        dateOfBirth: j['date_of_birth'] as String?,
        address:     j['address']       as String?,
      );
}

class OcrJobStatus {
  const OcrJobStatus({
    required this.jobId,
    required this.documentType,
    required this.status,
    this.extractedData,
    this.errorMessage,
    this.createdAt,
    this.completedAt,
  });

  final String          jobId;
  final String          documentType;
  final String          status;   // queued|processing|completed|failed
  final OcrExtractedData? extractedData;
  final String?         errorMessage;
  final DateTime?       createdAt;
  final DateTime?       completedAt;

  bool get isCompleted  => status == 'completed';
  bool get isFailed     => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'queued';

  factory OcrJobStatus.fromJson(Map<String, dynamic> j) {
    final edRaw = j['extracted_data'] as Map<String, dynamic>?;
    return OcrJobStatus(
      jobId:         j['job_id']       as String? ?? '',
      documentType:  j['document_type'] as String? ?? '',
      status:        j['status']        as String? ?? '',
      extractedData: edRaw != null ? OcrExtractedData.fromJson(edRaw) : null,
      errorMessage:  j['error_message'] as String?,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
      completedAt: j['completed_at'] != null
          ? DateTime.tryParse(j['completed_at'] as String)
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// Verification Status
// Source: GET /voter/verification-status
// ─────────────────────────────────────────────

class EpicVerificationStatus {
  const EpicVerificationStatus({
    required this.voterId,
    required this.epicVerified,
    this.verifiedAt,
    this.epicNumberMasked,
    this.assemblyName,
    this.pollingStation,
  });

  final String   voterId;
  final bool     epicVerified;
  final DateTime? verifiedAt;
  final String?  epicNumberMasked;
  final String?  assemblyName;
  final String?  pollingStation;

  factory EpicVerificationStatus.fromJson(Map<String, dynamic> j) =>
      EpicVerificationStatus(
        voterId:          j['voter_id']           as String? ?? '',
        epicVerified:     j['epic_verified']       as bool?   ?? false,
        verifiedAt: j['verified_at'] != null
            ? DateTime.tryParse(j['verified_at'] as String)
            : null,
        epicNumberMasked: j['epic_number_masked'] as String?,
        assemblyName:     j['assembly_name']      as String?,
        pollingStation:   j['polling_station']    as String?,
      );
}

// ─────────────────────────────────────────────
// ECI Search Models
// ─────────────────────────────────────────────

class CaptchaData {
  const CaptchaData({
    required this.sessionId,
    required this.captchaImageBase64,
  });

  final String sessionId;
  final String captchaImageBase64;

  factory CaptchaData.fromJson(Map<String, dynamic> j) => CaptchaData(
        sessionId:           j['session_id']    as String? ?? '',
        captchaImageBase64:  j['captcha_image'] as String? ?? '',
      );
}

class EciVoterResult {
  const EciVoterResult({
    this.epicNumber,
    this.firstName,
    this.lastName,
    this.fullName,
    this.age,
    this.gender,
    this.relativeName,
    this.relationType,
    this.assemblyName,
    this.district,
    this.stateName,
    this.stateCode,
    this.pollingStation,
    this.stationAddress,
    this.partNumber,
    this.rawJson,
  });

  final String?            epicNumber;
  final String?            firstName;
  final String?            lastName;
  final String?            fullName;
  final int?               age;
  final String?            gender;
  final String?            relativeName;
  final String?            relationType;
  final String?            assemblyName;
  final String?            district;
  final String?            stateName;
  final String?            stateCode;
  final String?            pollingStation;
  final String?            stationAddress;
  final String?            partNumber;
  final Map<String, dynamic>? rawJson;

  String get displayName =>
      fullName ?? [firstName, lastName].whereType<String>().join(' ');

  factory EciVoterResult.fromJson(Map<String, dynamic> j) => EciVoterResult(
        epicNumber:     j['epic_number']     as String?,
        firstName:      j['first_name']      as String?,
        lastName:       j['last_name']       as String?,
        fullName:       j['full_name']       as String?,
        age:            j['age']             as int?,
        gender:         j['gender']          as String?,
        relativeName:   j['relative_name']   as String?,
        relationType:   j['relation_type']   as String?,
        assemblyName:   j['assembly_name']   as String?,
        district:       j['district']        as String?,
        stateName:      j['state_name']      as String?,
        stateCode:      j['state_code']      as String?,
        pollingStation: j['polling_station'] as String?,
        stationAddress: j['station_address'] as String?,
        partNumber:     j['part_number']     as String?,
        rawJson:        j,
      );
}

// ─────────────────────────────────────────────
// Profile Update Request
// ─────────────────────────────────────────────

@immutable
class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    this.fullName,
    this.language,
    this.gender,
    this.genderSpecify,
    this.dateOfBirth,
    this.religion,
    this.education,
    this.occupation,
    this.profession,
    this.annualIncomeRange,
    this.familyAdults,
    this.familyKids,
    this.wardId,
    this.areaId,
  });

  final String? fullName;
  final String? language;
  final String? gender;
  final String? genderSpecify;
  final String? dateOfBirth;
  final String? religion;
  final String? education;
  final String? occupation;
  final String? profession;
  final String? annualIncomeRange;
  final int?    familyAdults;
  final int?    familyKids;
  final String? wardId;
  final String? areaId;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (fullName != null)          m['full_name']            = fullName;
    if (language != null)          m['language']             = language;
    if (gender != null)            m['gender']               = gender;
    if (genderSpecify != null)     m['gender_specify']       = genderSpecify;
    if (dateOfBirth != null)       m['date_of_birth']        = dateOfBirth;
    if (religion != null)          m['religion']             = religion;
    if (education != null)         m['education']            = education;
    if (occupation != null)        m['occupation']           = occupation;
    if (profession != null)        m['profession']           = profession;
    if (annualIncomeRange != null) m['annual_income_range']  = annualIncomeRange;
    if (familyAdults != null)      m['family_adults']        = familyAdults;
    if (familyKids != null)        m['family_kids']          = familyKids;
    if (wardId != null)            m['ward_id']              = wardId;
    if (areaId != null)            m['area_id']              = areaId;
    return m;
  }
}