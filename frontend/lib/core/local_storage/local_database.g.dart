// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $EchantillonsLocauxTable extends EchantillonsLocaux
    with TableInfo<$EchantillonsLocauxTable, EchantillonsLocauxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EchantillonsLocauxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAnalyseMeta = const VerificationMeta(
    'dateAnalyse',
  );
  @override
  late final GeneratedColumn<DateTime> dateAnalyse = GeneratedColumn<DateTime>(
    'date_analyse',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _producteurMeta = const VerificationMeta(
    'producteur',
  );
  @override
  late final GeneratedColumn<String> producteur = GeneratedColumn<String>(
    'producteur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateRecolteMeta = const VerificationMeta(
    'dateRecolte',
  );
  @override
  late final GeneratedColumn<DateTime> dateRecolte = GeneratedColumn<DateTime>(
    'date_recolte',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _varieteMeta = const VerificationMeta(
    'variete',
  );
  @override
  late final GeneratedColumn<String> variete = GeneratedColumn<String>(
    'variete',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _origineMeta = const VerificationMeta(
    'origine',
  );
  @override
  late final GeneratedColumn<String> origine = GeneratedColumn<String>(
    'origine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateCreationLocaleMeta =
      const VerificationMeta('dateCreationLocale');
  @override
  late final GeneratedColumn<DateTime> dateCreationLocale =
      GeneratedColumn<DateTime>(
        'date_creation_locale',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _statutSyncMeta = const VerificationMeta(
    'statutSync',
  );
  @override
  late final GeneratedColumn<String> statutSync = GeneratedColumn<String>(
    'statut_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('enAttente'),
  );
  static const VerificationMeta _messageErreurSyncMeta = const VerificationMeta(
    'messageErreurSync',
  );
  @override
  late final GeneratedColumn<String> messageErreurSync =
      GeneratedColumn<String>(
        'message_erreur_sync',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nombreTentativesSyncMeta =
      const VerificationMeta('nombreTentativesSync');
  @override
  late final GeneratedColumn<int> nombreTentativesSync = GeneratedColumn<int>(
    'nombre_tentatives_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    numero,
    dateAnalyse,
    producteur,
    region,
    dateRecolte,
    latitude,
    longitude,
    variete,
    origine,
    notes,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'echantillons_locaux';
  @override
  VerificationContext validateIntegrity(
    Insertable<EchantillonsLocauxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('date_analyse')) {
      context.handle(
        _dateAnalyseMeta,
        dateAnalyse.isAcceptableOrUnknown(
          data['date_analyse']!,
          _dateAnalyseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateAnalyseMeta);
    }
    if (data.containsKey('producteur')) {
      context.handle(
        _producteurMeta,
        producteur.isAcceptableOrUnknown(data['producteur']!, _producteurMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('date_recolte')) {
      context.handle(
        _dateRecolteMeta,
        dateRecolte.isAcceptableOrUnknown(
          data['date_recolte']!,
          _dateRecolteMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('variete')) {
      context.handle(
        _varieteMeta,
        variete.isAcceptableOrUnknown(data['variete']!, _varieteMeta),
      );
    }
    if (data.containsKey('origine')) {
      context.handle(
        _origineMeta,
        origine.isAcceptableOrUnknown(data['origine']!, _origineMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('date_creation_locale')) {
      context.handle(
        _dateCreationLocaleMeta,
        dateCreationLocale.isAcceptableOrUnknown(
          data['date_creation_locale']!,
          _dateCreationLocaleMeta,
        ),
      );
    }
    if (data.containsKey('statut_sync')) {
      context.handle(
        _statutSyncMeta,
        statutSync.isAcceptableOrUnknown(data['statut_sync']!, _statutSyncMeta),
      );
    }
    if (data.containsKey('message_erreur_sync')) {
      context.handle(
        _messageErreurSyncMeta,
        messageErreurSync.isAcceptableOrUnknown(
          data['message_erreur_sync']!,
          _messageErreurSyncMeta,
        ),
      );
    }
    if (data.containsKey('nombre_tentatives_sync')) {
      context.handle(
        _nombreTentativesSyncMeta,
        nombreTentativesSync.isAcceptableOrUnknown(
          data['nombre_tentatives_sync']!,
          _nombreTentativesSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EchantillonsLocauxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EchantillonsLocauxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero'],
      )!,
      dateAnalyse: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_analyse'],
      )!,
      producteur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producteur'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      dateRecolte: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_recolte'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      variete: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variete'],
      )!,
      origine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origine'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      dateCreationLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation_locale'],
      )!,
      statutSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut_sync'],
      )!,
      messageErreurSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_erreur_sync'],
      ),
      nombreTentativesSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_tentatives_sync'],
      )!,
    );
  }

  @override
  $EchantillonsLocauxTable createAlias(String alias) {
    return $EchantillonsLocauxTable(attachedDatabase, alias);
  }
}

class EchantillonsLocauxData extends DataClass
    implements Insertable<EchantillonsLocauxData> {
  final String id;
  final String numero;
  final DateTime dateAnalyse;
  final String producteur;
  final String region;
  final DateTime? dateRecolte;
  final double? latitude;
  final double? longitude;
  final String variete;
  final String origine;
  final String notes;
  final DateTime dateCreationLocale;
  final String statutSync;
  final String? messageErreurSync;
  final int nombreTentativesSync;
  const EchantillonsLocauxData({
    required this.id,
    required this.numero,
    required this.dateAnalyse,
    required this.producteur,
    required this.region,
    this.dateRecolte,
    this.latitude,
    this.longitude,
    required this.variete,
    required this.origine,
    required this.notes,
    required this.dateCreationLocale,
    required this.statutSync,
    this.messageErreurSync,
    required this.nombreTentativesSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['numero'] = Variable<String>(numero);
    map['date_analyse'] = Variable<DateTime>(dateAnalyse);
    map['producteur'] = Variable<String>(producteur);
    map['region'] = Variable<String>(region);
    if (!nullToAbsent || dateRecolte != null) {
      map['date_recolte'] = Variable<DateTime>(dateRecolte);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['variete'] = Variable<String>(variete);
    map['origine'] = Variable<String>(origine);
    map['notes'] = Variable<String>(notes);
    map['date_creation_locale'] = Variable<DateTime>(dateCreationLocale);
    map['statut_sync'] = Variable<String>(statutSync);
    if (!nullToAbsent || messageErreurSync != null) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync);
    }
    map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync);
    return map;
  }

  EchantillonsLocauxCompanion toCompanion(bool nullToAbsent) {
    return EchantillonsLocauxCompanion(
      id: Value(id),
      numero: Value(numero),
      dateAnalyse: Value(dateAnalyse),
      producteur: Value(producteur),
      region: Value(region),
      dateRecolte: dateRecolte == null && nullToAbsent
          ? const Value.absent()
          : Value(dateRecolte),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      variete: Value(variete),
      origine: Value(origine),
      notes: Value(notes),
      dateCreationLocale: Value(dateCreationLocale),
      statutSync: Value(statutSync),
      messageErreurSync: messageErreurSync == null && nullToAbsent
          ? const Value.absent()
          : Value(messageErreurSync),
      nombreTentativesSync: Value(nombreTentativesSync),
    );
  }

  factory EchantillonsLocauxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EchantillonsLocauxData(
      id: serializer.fromJson<String>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      dateAnalyse: serializer.fromJson<DateTime>(json['dateAnalyse']),
      producteur: serializer.fromJson<String>(json['producteur']),
      region: serializer.fromJson<String>(json['region']),
      dateRecolte: serializer.fromJson<DateTime?>(json['dateRecolte']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      variete: serializer.fromJson<String>(json['variete']),
      origine: serializer.fromJson<String>(json['origine']),
      notes: serializer.fromJson<String>(json['notes']),
      dateCreationLocale: serializer.fromJson<DateTime>(
        json['dateCreationLocale'],
      ),
      statutSync: serializer.fromJson<String>(json['statutSync']),
      messageErreurSync: serializer.fromJson<String?>(
        json['messageErreurSync'],
      ),
      nombreTentativesSync: serializer.fromJson<int>(
        json['nombreTentativesSync'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'numero': serializer.toJson<String>(numero),
      'dateAnalyse': serializer.toJson<DateTime>(dateAnalyse),
      'producteur': serializer.toJson<String>(producteur),
      'region': serializer.toJson<String>(region),
      'dateRecolte': serializer.toJson<DateTime?>(dateRecolte),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'variete': serializer.toJson<String>(variete),
      'origine': serializer.toJson<String>(origine),
      'notes': serializer.toJson<String>(notes),
      'dateCreationLocale': serializer.toJson<DateTime>(dateCreationLocale),
      'statutSync': serializer.toJson<String>(statutSync),
      'messageErreurSync': serializer.toJson<String?>(messageErreurSync),
      'nombreTentativesSync': serializer.toJson<int>(nombreTentativesSync),
    };
  }

  EchantillonsLocauxData copyWith({
    String? id,
    String? numero,
    DateTime? dateAnalyse,
    String? producteur,
    String? region,
    Value<DateTime?> dateRecolte = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? variete,
    String? origine,
    String? notes,
    DateTime? dateCreationLocale,
    String? statutSync,
    Value<String?> messageErreurSync = const Value.absent(),
    int? nombreTentativesSync,
  }) => EchantillonsLocauxData(
    id: id ?? this.id,
    numero: numero ?? this.numero,
    dateAnalyse: dateAnalyse ?? this.dateAnalyse,
    producteur: producteur ?? this.producteur,
    region: region ?? this.region,
    dateRecolte: dateRecolte.present ? dateRecolte.value : this.dateRecolte,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    variete: variete ?? this.variete,
    origine: origine ?? this.origine,
    notes: notes ?? this.notes,
    dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
    statutSync: statutSync ?? this.statutSync,
    messageErreurSync: messageErreurSync.present
        ? messageErreurSync.value
        : this.messageErreurSync,
    nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
  );
  EchantillonsLocauxData copyWithCompanion(EchantillonsLocauxCompanion data) {
    return EchantillonsLocauxData(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      dateAnalyse: data.dateAnalyse.present
          ? data.dateAnalyse.value
          : this.dateAnalyse,
      producteur: data.producteur.present
          ? data.producteur.value
          : this.producteur,
      region: data.region.present ? data.region.value : this.region,
      dateRecolte: data.dateRecolte.present
          ? data.dateRecolte.value
          : this.dateRecolte,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      variete: data.variete.present ? data.variete.value : this.variete,
      origine: data.origine.present ? data.origine.value : this.origine,
      notes: data.notes.present ? data.notes.value : this.notes,
      dateCreationLocale: data.dateCreationLocale.present
          ? data.dateCreationLocale.value
          : this.dateCreationLocale,
      statutSync: data.statutSync.present
          ? data.statutSync.value
          : this.statutSync,
      messageErreurSync: data.messageErreurSync.present
          ? data.messageErreurSync.value
          : this.messageErreurSync,
      nombreTentativesSync: data.nombreTentativesSync.present
          ? data.nombreTentativesSync.value
          : this.nombreTentativesSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EchantillonsLocauxData(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('dateAnalyse: $dateAnalyse, ')
          ..write('producteur: $producteur, ')
          ..write('region: $region, ')
          ..write('dateRecolte: $dateRecolte, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('variete: $variete, ')
          ..write('origine: $origine, ')
          ..write('notes: $notes, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    numero,
    dateAnalyse,
    producteur,
    region,
    dateRecolte,
    latitude,
    longitude,
    variete,
    origine,
    notes,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EchantillonsLocauxData &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.dateAnalyse == this.dateAnalyse &&
          other.producteur == this.producteur &&
          other.region == this.region &&
          other.dateRecolte == this.dateRecolte &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.variete == this.variete &&
          other.origine == this.origine &&
          other.notes == this.notes &&
          other.dateCreationLocale == this.dateCreationLocale &&
          other.statutSync == this.statutSync &&
          other.messageErreurSync == this.messageErreurSync &&
          other.nombreTentativesSync == this.nombreTentativesSync);
}

class EchantillonsLocauxCompanion
    extends UpdateCompanion<EchantillonsLocauxData> {
  final Value<String> id;
  final Value<String> numero;
  final Value<DateTime> dateAnalyse;
  final Value<String> producteur;
  final Value<String> region;
  final Value<DateTime?> dateRecolte;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> variete;
  final Value<String> origine;
  final Value<String> notes;
  final Value<DateTime> dateCreationLocale;
  final Value<String> statutSync;
  final Value<String?> messageErreurSync;
  final Value<int> nombreTentativesSync;
  final Value<int> rowid;
  const EchantillonsLocauxCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.dateAnalyse = const Value.absent(),
    this.producteur = const Value.absent(),
    this.region = const Value.absent(),
    this.dateRecolte = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.variete = const Value.absent(),
    this.origine = const Value.absent(),
    this.notes = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EchantillonsLocauxCompanion.insert({
    required String id,
    required String numero,
    required DateTime dateAnalyse,
    this.producteur = const Value.absent(),
    this.region = const Value.absent(),
    this.dateRecolte = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.variete = const Value.absent(),
    this.origine = const Value.absent(),
    this.notes = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       numero = Value(numero),
       dateAnalyse = Value(dateAnalyse);
  static Insertable<EchantillonsLocauxData> custom({
    Expression<String>? id,
    Expression<String>? numero,
    Expression<DateTime>? dateAnalyse,
    Expression<String>? producteur,
    Expression<String>? region,
    Expression<DateTime>? dateRecolte,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? variete,
    Expression<String>? origine,
    Expression<String>? notes,
    Expression<DateTime>? dateCreationLocale,
    Expression<String>? statutSync,
    Expression<String>? messageErreurSync,
    Expression<int>? nombreTentativesSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (dateAnalyse != null) 'date_analyse': dateAnalyse,
      if (producteur != null) 'producteur': producteur,
      if (region != null) 'region': region,
      if (dateRecolte != null) 'date_recolte': dateRecolte,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (variete != null) 'variete': variete,
      if (origine != null) 'origine': origine,
      if (notes != null) 'notes': notes,
      if (dateCreationLocale != null)
        'date_creation_locale': dateCreationLocale,
      if (statutSync != null) 'statut_sync': statutSync,
      if (messageErreurSync != null) 'message_erreur_sync': messageErreurSync,
      if (nombreTentativesSync != null)
        'nombre_tentatives_sync': nombreTentativesSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EchantillonsLocauxCompanion copyWith({
    Value<String>? id,
    Value<String>? numero,
    Value<DateTime>? dateAnalyse,
    Value<String>? producteur,
    Value<String>? region,
    Value<DateTime?>? dateRecolte,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? variete,
    Value<String>? origine,
    Value<String>? notes,
    Value<DateTime>? dateCreationLocale,
    Value<String>? statutSync,
    Value<String?>? messageErreurSync,
    Value<int>? nombreTentativesSync,
    Value<int>? rowid,
  }) {
    return EchantillonsLocauxCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      dateAnalyse: dateAnalyse ?? this.dateAnalyse,
      producteur: producteur ?? this.producteur,
      region: region ?? this.region,
      dateRecolte: dateRecolte ?? this.dateRecolte,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      variete: variete ?? this.variete,
      origine: origine ?? this.origine,
      notes: notes ?? this.notes,
      dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
      statutSync: statutSync ?? this.statutSync,
      messageErreurSync: messageErreurSync ?? this.messageErreurSync,
      nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (dateAnalyse.present) {
      map['date_analyse'] = Variable<DateTime>(dateAnalyse.value);
    }
    if (producteur.present) {
      map['producteur'] = Variable<String>(producteur.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (dateRecolte.present) {
      map['date_recolte'] = Variable<DateTime>(dateRecolte.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (variete.present) {
      map['variete'] = Variable<String>(variete.value);
    }
    if (origine.present) {
      map['origine'] = Variable<String>(origine.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dateCreationLocale.present) {
      map['date_creation_locale'] = Variable<DateTime>(
        dateCreationLocale.value,
      );
    }
    if (statutSync.present) {
      map['statut_sync'] = Variable<String>(statutSync.value);
    }
    if (messageErreurSync.present) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync.value);
    }
    if (nombreTentativesSync.present) {
      map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EchantillonsLocauxCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('dateAnalyse: $dateAnalyse, ')
          ..write('producteur: $producteur, ')
          ..write('region: $region, ')
          ..write('dateRecolte: $dateRecolte, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('variete: $variete, ')
          ..write('origine: $origine, ')
          ..write('notes: $notes, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpectresLocauxTable extends SpectresLocaux
    with TableInfo<$SpectresLocauxTable, SpectresLocauxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpectresLocauxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _echantillonIdMeta = const VerificationMeta(
    'echantillonId',
  );
  @override
  late final GeneratedColumn<String> echantillonId = GeneratedColumn<String>(
    'echantillon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES echantillons_locaux (id)',
    ),
  );
  static const VerificationMeta _valeursXJsonMeta = const VerificationMeta(
    'valeursXJson',
  );
  @override
  late final GeneratedColumn<String> valeursXJson = GeneratedColumn<String>(
    'valeurs_x_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeursYJsonMeta = const VerificationMeta(
    'valeursYJson',
  );
  @override
  late final GeneratedColumn<String> valeursYJson = GeneratedColumn<String>(
    'valeurs_y_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreSeriesMeta = const VerificationMeta(
    'nombreSeries',
  );
  @override
  late final GeneratedColumn<int> nombreSeries = GeneratedColumn<int>(
    'nombre_series',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAcquisitionMeta = const VerificationMeta(
    'dateAcquisition',
  );
  @override
  late final GeneratedColumn<DateTime> dateAcquisition =
      GeneratedColumn<DateTime>(
        'date_acquisition',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tailleDonneesMeta = const VerificationMeta(
    'tailleDonnees',
  );
  @override
  late final GeneratedColumn<int> tailleDonnees = GeneratedColumn<int>(
    'taille_donnees',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationLocaleMeta =
      const VerificationMeta('dateCreationLocale');
  @override
  late final GeneratedColumn<DateTime> dateCreationLocale =
      GeneratedColumn<DateTime>(
        'date_creation_locale',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _statutSyncMeta = const VerificationMeta(
    'statutSync',
  );
  @override
  late final GeneratedColumn<String> statutSync = GeneratedColumn<String>(
    'statut_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('enAttente'),
  );
  static const VerificationMeta _messageErreurSyncMeta = const VerificationMeta(
    'messageErreurSync',
  );
  @override
  late final GeneratedColumn<String> messageErreurSync =
      GeneratedColumn<String>(
        'message_erreur_sync',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nombreTentativesSyncMeta =
      const VerificationMeta('nombreTentativesSync');
  @override
  late final GeneratedColumn<int> nombreTentativesSync = GeneratedColumn<int>(
    'nombre_tentatives_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    echantillonId,
    valeursXJson,
    valeursYJson,
    nombreSeries,
    dateAcquisition,
    checksum,
    tailleDonnees,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spectres_locaux';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpectresLocauxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('echantillon_id')) {
      context.handle(
        _echantillonIdMeta,
        echantillonId.isAcceptableOrUnknown(
          data['echantillon_id']!,
          _echantillonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_echantillonIdMeta);
    }
    if (data.containsKey('valeurs_x_json')) {
      context.handle(
        _valeursXJsonMeta,
        valeursXJson.isAcceptableOrUnknown(
          data['valeurs_x_json']!,
          _valeursXJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valeursXJsonMeta);
    }
    if (data.containsKey('valeurs_y_json')) {
      context.handle(
        _valeursYJsonMeta,
        valeursYJson.isAcceptableOrUnknown(
          data['valeurs_y_json']!,
          _valeursYJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valeursYJsonMeta);
    }
    if (data.containsKey('nombre_series')) {
      context.handle(
        _nombreSeriesMeta,
        nombreSeries.isAcceptableOrUnknown(
          data['nombre_series']!,
          _nombreSeriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreSeriesMeta);
    }
    if (data.containsKey('date_acquisition')) {
      context.handle(
        _dateAcquisitionMeta,
        dateAcquisition.isAcceptableOrUnknown(
          data['date_acquisition']!,
          _dateAcquisitionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateAcquisitionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('taille_donnees')) {
      context.handle(
        _tailleDonneesMeta,
        tailleDonnees.isAcceptableOrUnknown(
          data['taille_donnees']!,
          _tailleDonneesMeta,
        ),
      );
    }
    if (data.containsKey('date_creation_locale')) {
      context.handle(
        _dateCreationLocaleMeta,
        dateCreationLocale.isAcceptableOrUnknown(
          data['date_creation_locale']!,
          _dateCreationLocaleMeta,
        ),
      );
    }
    if (data.containsKey('statut_sync')) {
      context.handle(
        _statutSyncMeta,
        statutSync.isAcceptableOrUnknown(data['statut_sync']!, _statutSyncMeta),
      );
    }
    if (data.containsKey('message_erreur_sync')) {
      context.handle(
        _messageErreurSyncMeta,
        messageErreurSync.isAcceptableOrUnknown(
          data['message_erreur_sync']!,
          _messageErreurSyncMeta,
        ),
      );
    }
    if (data.containsKey('nombre_tentatives_sync')) {
      context.handle(
        _nombreTentativesSyncMeta,
        nombreTentativesSync.isAcceptableOrUnknown(
          data['nombre_tentatives_sync']!,
          _nombreTentativesSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpectresLocauxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpectresLocauxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      echantillonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}echantillon_id'],
      )!,
      valeursXJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeurs_x_json'],
      )!,
      valeursYJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeurs_y_json'],
      )!,
      nombreSeries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_series'],
      )!,
      dateAcquisition: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_acquisition'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      tailleDonnees: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taille_donnees'],
      ),
      dateCreationLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation_locale'],
      )!,
      statutSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut_sync'],
      )!,
      messageErreurSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_erreur_sync'],
      ),
      nombreTentativesSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_tentatives_sync'],
      )!,
    );
  }

  @override
  $SpectresLocauxTable createAlias(String alias) {
    return $SpectresLocauxTable(attachedDatabase, alias);
  }
}

class SpectresLocauxData extends DataClass
    implements Insertable<SpectresLocauxData> {
  final String id;
  final String echantillonId;
  final String valeursXJson;
  final String valeursYJson;
  final int nombreSeries;
  final DateTime dateAcquisition;
  final String checksum;
  final int? tailleDonnees;
  final DateTime dateCreationLocale;
  final String statutSync;
  final String? messageErreurSync;
  final int nombreTentativesSync;
  const SpectresLocauxData({
    required this.id,
    required this.echantillonId,
    required this.valeursXJson,
    required this.valeursYJson,
    required this.nombreSeries,
    required this.dateAcquisition,
    required this.checksum,
    this.tailleDonnees,
    required this.dateCreationLocale,
    required this.statutSync,
    this.messageErreurSync,
    required this.nombreTentativesSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['echantillon_id'] = Variable<String>(echantillonId);
    map['valeurs_x_json'] = Variable<String>(valeursXJson);
    map['valeurs_y_json'] = Variable<String>(valeursYJson);
    map['nombre_series'] = Variable<int>(nombreSeries);
    map['date_acquisition'] = Variable<DateTime>(dateAcquisition);
    map['checksum'] = Variable<String>(checksum);
    if (!nullToAbsent || tailleDonnees != null) {
      map['taille_donnees'] = Variable<int>(tailleDonnees);
    }
    map['date_creation_locale'] = Variable<DateTime>(dateCreationLocale);
    map['statut_sync'] = Variable<String>(statutSync);
    if (!nullToAbsent || messageErreurSync != null) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync);
    }
    map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync);
    return map;
  }

  SpectresLocauxCompanion toCompanion(bool nullToAbsent) {
    return SpectresLocauxCompanion(
      id: Value(id),
      echantillonId: Value(echantillonId),
      valeursXJson: Value(valeursXJson),
      valeursYJson: Value(valeursYJson),
      nombreSeries: Value(nombreSeries),
      dateAcquisition: Value(dateAcquisition),
      checksum: Value(checksum),
      tailleDonnees: tailleDonnees == null && nullToAbsent
          ? const Value.absent()
          : Value(tailleDonnees),
      dateCreationLocale: Value(dateCreationLocale),
      statutSync: Value(statutSync),
      messageErreurSync: messageErreurSync == null && nullToAbsent
          ? const Value.absent()
          : Value(messageErreurSync),
      nombreTentativesSync: Value(nombreTentativesSync),
    );
  }

  factory SpectresLocauxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpectresLocauxData(
      id: serializer.fromJson<String>(json['id']),
      echantillonId: serializer.fromJson<String>(json['echantillonId']),
      valeursXJson: serializer.fromJson<String>(json['valeursXJson']),
      valeursYJson: serializer.fromJson<String>(json['valeursYJson']),
      nombreSeries: serializer.fromJson<int>(json['nombreSeries']),
      dateAcquisition: serializer.fromJson<DateTime>(json['dateAcquisition']),
      checksum: serializer.fromJson<String>(json['checksum']),
      tailleDonnees: serializer.fromJson<int?>(json['tailleDonnees']),
      dateCreationLocale: serializer.fromJson<DateTime>(
        json['dateCreationLocale'],
      ),
      statutSync: serializer.fromJson<String>(json['statutSync']),
      messageErreurSync: serializer.fromJson<String?>(
        json['messageErreurSync'],
      ),
      nombreTentativesSync: serializer.fromJson<int>(
        json['nombreTentativesSync'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'echantillonId': serializer.toJson<String>(echantillonId),
      'valeursXJson': serializer.toJson<String>(valeursXJson),
      'valeursYJson': serializer.toJson<String>(valeursYJson),
      'nombreSeries': serializer.toJson<int>(nombreSeries),
      'dateAcquisition': serializer.toJson<DateTime>(dateAcquisition),
      'checksum': serializer.toJson<String>(checksum),
      'tailleDonnees': serializer.toJson<int?>(tailleDonnees),
      'dateCreationLocale': serializer.toJson<DateTime>(dateCreationLocale),
      'statutSync': serializer.toJson<String>(statutSync),
      'messageErreurSync': serializer.toJson<String?>(messageErreurSync),
      'nombreTentativesSync': serializer.toJson<int>(nombreTentativesSync),
    };
  }

  SpectresLocauxData copyWith({
    String? id,
    String? echantillonId,
    String? valeursXJson,
    String? valeursYJson,
    int? nombreSeries,
    DateTime? dateAcquisition,
    String? checksum,
    Value<int?> tailleDonnees = const Value.absent(),
    DateTime? dateCreationLocale,
    String? statutSync,
    Value<String?> messageErreurSync = const Value.absent(),
    int? nombreTentativesSync,
  }) => SpectresLocauxData(
    id: id ?? this.id,
    echantillonId: echantillonId ?? this.echantillonId,
    valeursXJson: valeursXJson ?? this.valeursXJson,
    valeursYJson: valeursYJson ?? this.valeursYJson,
    nombreSeries: nombreSeries ?? this.nombreSeries,
    dateAcquisition: dateAcquisition ?? this.dateAcquisition,
    checksum: checksum ?? this.checksum,
    tailleDonnees: tailleDonnees.present
        ? tailleDonnees.value
        : this.tailleDonnees,
    dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
    statutSync: statutSync ?? this.statutSync,
    messageErreurSync: messageErreurSync.present
        ? messageErreurSync.value
        : this.messageErreurSync,
    nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
  );
  SpectresLocauxData copyWithCompanion(SpectresLocauxCompanion data) {
    return SpectresLocauxData(
      id: data.id.present ? data.id.value : this.id,
      echantillonId: data.echantillonId.present
          ? data.echantillonId.value
          : this.echantillonId,
      valeursXJson: data.valeursXJson.present
          ? data.valeursXJson.value
          : this.valeursXJson,
      valeursYJson: data.valeursYJson.present
          ? data.valeursYJson.value
          : this.valeursYJson,
      nombreSeries: data.nombreSeries.present
          ? data.nombreSeries.value
          : this.nombreSeries,
      dateAcquisition: data.dateAcquisition.present
          ? data.dateAcquisition.value
          : this.dateAcquisition,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      tailleDonnees: data.tailleDonnees.present
          ? data.tailleDonnees.value
          : this.tailleDonnees,
      dateCreationLocale: data.dateCreationLocale.present
          ? data.dateCreationLocale.value
          : this.dateCreationLocale,
      statutSync: data.statutSync.present
          ? data.statutSync.value
          : this.statutSync,
      messageErreurSync: data.messageErreurSync.present
          ? data.messageErreurSync.value
          : this.messageErreurSync,
      nombreTentativesSync: data.nombreTentativesSync.present
          ? data.nombreTentativesSync.value
          : this.nombreTentativesSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpectresLocauxData(')
          ..write('id: $id, ')
          ..write('echantillonId: $echantillonId, ')
          ..write('valeursXJson: $valeursXJson, ')
          ..write('valeursYJson: $valeursYJson, ')
          ..write('nombreSeries: $nombreSeries, ')
          ..write('dateAcquisition: $dateAcquisition, ')
          ..write('checksum: $checksum, ')
          ..write('tailleDonnees: $tailleDonnees, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    echantillonId,
    valeursXJson,
    valeursYJson,
    nombreSeries,
    dateAcquisition,
    checksum,
    tailleDonnees,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpectresLocauxData &&
          other.id == this.id &&
          other.echantillonId == this.echantillonId &&
          other.valeursXJson == this.valeursXJson &&
          other.valeursYJson == this.valeursYJson &&
          other.nombreSeries == this.nombreSeries &&
          other.dateAcquisition == this.dateAcquisition &&
          other.checksum == this.checksum &&
          other.tailleDonnees == this.tailleDonnees &&
          other.dateCreationLocale == this.dateCreationLocale &&
          other.statutSync == this.statutSync &&
          other.messageErreurSync == this.messageErreurSync &&
          other.nombreTentativesSync == this.nombreTentativesSync);
}

class SpectresLocauxCompanion extends UpdateCompanion<SpectresLocauxData> {
  final Value<String> id;
  final Value<String> echantillonId;
  final Value<String> valeursXJson;
  final Value<String> valeursYJson;
  final Value<int> nombreSeries;
  final Value<DateTime> dateAcquisition;
  final Value<String> checksum;
  final Value<int?> tailleDonnees;
  final Value<DateTime> dateCreationLocale;
  final Value<String> statutSync;
  final Value<String?> messageErreurSync;
  final Value<int> nombreTentativesSync;
  final Value<int> rowid;
  const SpectresLocauxCompanion({
    this.id = const Value.absent(),
    this.echantillonId = const Value.absent(),
    this.valeursXJson = const Value.absent(),
    this.valeursYJson = const Value.absent(),
    this.nombreSeries = const Value.absent(),
    this.dateAcquisition = const Value.absent(),
    this.checksum = const Value.absent(),
    this.tailleDonnees = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpectresLocauxCompanion.insert({
    required String id,
    required String echantillonId,
    required String valeursXJson,
    required String valeursYJson,
    required int nombreSeries,
    required DateTime dateAcquisition,
    this.checksum = const Value.absent(),
    this.tailleDonnees = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       echantillonId = Value(echantillonId),
       valeursXJson = Value(valeursXJson),
       valeursYJson = Value(valeursYJson),
       nombreSeries = Value(nombreSeries),
       dateAcquisition = Value(dateAcquisition);
  static Insertable<SpectresLocauxData> custom({
    Expression<String>? id,
    Expression<String>? echantillonId,
    Expression<String>? valeursXJson,
    Expression<String>? valeursYJson,
    Expression<int>? nombreSeries,
    Expression<DateTime>? dateAcquisition,
    Expression<String>? checksum,
    Expression<int>? tailleDonnees,
    Expression<DateTime>? dateCreationLocale,
    Expression<String>? statutSync,
    Expression<String>? messageErreurSync,
    Expression<int>? nombreTentativesSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (echantillonId != null) 'echantillon_id': echantillonId,
      if (valeursXJson != null) 'valeurs_x_json': valeursXJson,
      if (valeursYJson != null) 'valeurs_y_json': valeursYJson,
      if (nombreSeries != null) 'nombre_series': nombreSeries,
      if (dateAcquisition != null) 'date_acquisition': dateAcquisition,
      if (checksum != null) 'checksum': checksum,
      if (tailleDonnees != null) 'taille_donnees': tailleDonnees,
      if (dateCreationLocale != null)
        'date_creation_locale': dateCreationLocale,
      if (statutSync != null) 'statut_sync': statutSync,
      if (messageErreurSync != null) 'message_erreur_sync': messageErreurSync,
      if (nombreTentativesSync != null)
        'nombre_tentatives_sync': nombreTentativesSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpectresLocauxCompanion copyWith({
    Value<String>? id,
    Value<String>? echantillonId,
    Value<String>? valeursXJson,
    Value<String>? valeursYJson,
    Value<int>? nombreSeries,
    Value<DateTime>? dateAcquisition,
    Value<String>? checksum,
    Value<int?>? tailleDonnees,
    Value<DateTime>? dateCreationLocale,
    Value<String>? statutSync,
    Value<String?>? messageErreurSync,
    Value<int>? nombreTentativesSync,
    Value<int>? rowid,
  }) {
    return SpectresLocauxCompanion(
      id: id ?? this.id,
      echantillonId: echantillonId ?? this.echantillonId,
      valeursXJson: valeursXJson ?? this.valeursXJson,
      valeursYJson: valeursYJson ?? this.valeursYJson,
      nombreSeries: nombreSeries ?? this.nombreSeries,
      dateAcquisition: dateAcquisition ?? this.dateAcquisition,
      checksum: checksum ?? this.checksum,
      tailleDonnees: tailleDonnees ?? this.tailleDonnees,
      dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
      statutSync: statutSync ?? this.statutSync,
      messageErreurSync: messageErreurSync ?? this.messageErreurSync,
      nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (echantillonId.present) {
      map['echantillon_id'] = Variable<String>(echantillonId.value);
    }
    if (valeursXJson.present) {
      map['valeurs_x_json'] = Variable<String>(valeursXJson.value);
    }
    if (valeursYJson.present) {
      map['valeurs_y_json'] = Variable<String>(valeursYJson.value);
    }
    if (nombreSeries.present) {
      map['nombre_series'] = Variable<int>(nombreSeries.value);
    }
    if (dateAcquisition.present) {
      map['date_acquisition'] = Variable<DateTime>(dateAcquisition.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (tailleDonnees.present) {
      map['taille_donnees'] = Variable<int>(tailleDonnees.value);
    }
    if (dateCreationLocale.present) {
      map['date_creation_locale'] = Variable<DateTime>(
        dateCreationLocale.value,
      );
    }
    if (statutSync.present) {
      map['statut_sync'] = Variable<String>(statutSync.value);
    }
    if (messageErreurSync.present) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync.value);
    }
    if (nombreTentativesSync.present) {
      map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpectresLocauxCompanion(')
          ..write('id: $id, ')
          ..write('echantillonId: $echantillonId, ')
          ..write('valeursXJson: $valeursXJson, ')
          ..write('valeursYJson: $valeursYJson, ')
          ..write('nombreSeries: $nombreSeries, ')
          ..write('dateAcquisition: $dateAcquisition, ')
          ..write('checksum: $checksum, ')
          ..write('tailleDonnees: $tailleDonnees, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResultatsLocauxTable extends ResultatsLocaux
    with TableInfo<$ResultatsLocauxTable, ResultatsLocauxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResultatsLocauxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _echantillonIdMeta = const VerificationMeta(
    'echantillonId',
  );
  @override
  late final GeneratedColumn<String> echantillonId = GeneratedColumn<String>(
    'echantillon_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES echantillons_locaux (id)',
    ),
  );
  static const VerificationMeta _modeleUtiliseIdMeta = const VerificationMeta(
    'modeleUtiliseId',
  );
  @override
  late final GeneratedColumn<int> modeleUtiliseId = GeneratedColumn<int>(
    'modele_utilise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aciditeMeta = const VerificationMeta(
    'acidite',
  );
  @override
  late final GeneratedColumn<double> acidite = GeneratedColumn<double>(
    'acidite',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indicePeroxydeMeta = const VerificationMeta(
    'indicePeroxyde',
  );
  @override
  late final GeneratedColumn<double> indicePeroxyde = GeneratedColumn<double>(
    'indice_peroxyde',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCalculMeta = const VerificationMeta(
    'dateCalcul',
  );
  @override
  late final GeneratedColumn<DateTime> dateCalcul = GeneratedColumn<DateTime>(
    'date_calcul',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dureeAnalyseSecondesMeta =
      const VerificationMeta('dureeAnalyseSecondes');
  @override
  late final GeneratedColumn<int> dureeAnalyseSecondes = GeneratedColumn<int>(
    'duree_analyse_secondes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conformeMeta = const VerificationMeta(
    'conforme',
  );
  @override
  late final GeneratedColumn<bool> conforme = GeneratedColumn<bool>(
    'conforme',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("conforme" IN (0, 1))',
    ),
  );
  static const VerificationMeta _commentaireMeta = const VerificationMeta(
    'commentaire',
  );
  @override
  late final GeneratedColumn<String> commentaire = GeneratedColumn<String>(
    'commentaire',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateCreationLocaleMeta =
      const VerificationMeta('dateCreationLocale');
  @override
  late final GeneratedColumn<DateTime> dateCreationLocale =
      GeneratedColumn<DateTime>(
        'date_creation_locale',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _statutSyncMeta = const VerificationMeta(
    'statutSync',
  );
  @override
  late final GeneratedColumn<String> statutSync = GeneratedColumn<String>(
    'statut_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('enAttente'),
  );
  static const VerificationMeta _messageErreurSyncMeta = const VerificationMeta(
    'messageErreurSync',
  );
  @override
  late final GeneratedColumn<String> messageErreurSync =
      GeneratedColumn<String>(
        'message_erreur_sync',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nombreTentativesSyncMeta =
      const VerificationMeta('nombreTentativesSync');
  @override
  late final GeneratedColumn<int> nombreTentativesSync = GeneratedColumn<int>(
    'nombre_tentatives_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    echantillonId,
    modeleUtiliseId,
    acidite,
    indicePeroxyde,
    dateCalcul,
    dureeAnalyseSecondes,
    conforme,
    commentaire,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resultats_locaux';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResultatsLocauxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('echantillon_id')) {
      context.handle(
        _echantillonIdMeta,
        echantillonId.isAcceptableOrUnknown(
          data['echantillon_id']!,
          _echantillonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_echantillonIdMeta);
    }
    if (data.containsKey('modele_utilise_id')) {
      context.handle(
        _modeleUtiliseIdMeta,
        modeleUtiliseId.isAcceptableOrUnknown(
          data['modele_utilise_id']!,
          _modeleUtiliseIdMeta,
        ),
      );
    }
    if (data.containsKey('acidite')) {
      context.handle(
        _aciditeMeta,
        acidite.isAcceptableOrUnknown(data['acidite']!, _aciditeMeta),
      );
    }
    if (data.containsKey('indice_peroxyde')) {
      context.handle(
        _indicePeroxydeMeta,
        indicePeroxyde.isAcceptableOrUnknown(
          data['indice_peroxyde']!,
          _indicePeroxydeMeta,
        ),
      );
    }
    if (data.containsKey('date_calcul')) {
      context.handle(
        _dateCalculMeta,
        dateCalcul.isAcceptableOrUnknown(data['date_calcul']!, _dateCalculMeta),
      );
    }
    if (data.containsKey('duree_analyse_secondes')) {
      context.handle(
        _dureeAnalyseSecondesMeta,
        dureeAnalyseSecondes.isAcceptableOrUnknown(
          data['duree_analyse_secondes']!,
          _dureeAnalyseSecondesMeta,
        ),
      );
    }
    if (data.containsKey('conforme')) {
      context.handle(
        _conformeMeta,
        conforme.isAcceptableOrUnknown(data['conforme']!, _conformeMeta),
      );
    }
    if (data.containsKey('commentaire')) {
      context.handle(
        _commentaireMeta,
        commentaire.isAcceptableOrUnknown(
          data['commentaire']!,
          _commentaireMeta,
        ),
      );
    }
    if (data.containsKey('date_creation_locale')) {
      context.handle(
        _dateCreationLocaleMeta,
        dateCreationLocale.isAcceptableOrUnknown(
          data['date_creation_locale']!,
          _dateCreationLocaleMeta,
        ),
      );
    }
    if (data.containsKey('statut_sync')) {
      context.handle(
        _statutSyncMeta,
        statutSync.isAcceptableOrUnknown(data['statut_sync']!, _statutSyncMeta),
      );
    }
    if (data.containsKey('message_erreur_sync')) {
      context.handle(
        _messageErreurSyncMeta,
        messageErreurSync.isAcceptableOrUnknown(
          data['message_erreur_sync']!,
          _messageErreurSyncMeta,
        ),
      );
    }
    if (data.containsKey('nombre_tentatives_sync')) {
      context.handle(
        _nombreTentativesSyncMeta,
        nombreTentativesSync.isAcceptableOrUnknown(
          data['nombre_tentatives_sync']!,
          _nombreTentativesSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResultatsLocauxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResultatsLocauxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      echantillonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}echantillon_id'],
      )!,
      modeleUtiliseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modele_utilise_id'],
      ),
      acidite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acidite'],
      ),
      indicePeroxyde: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}indice_peroxyde'],
      ),
      dateCalcul: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_calcul'],
      ),
      dureeAnalyseSecondes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duree_analyse_secondes'],
      ),
      conforme: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}conforme'],
      ),
      commentaire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentaire'],
      )!,
      dateCreationLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_creation_locale'],
      )!,
      statutSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut_sync'],
      )!,
      messageErreurSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_erreur_sync'],
      ),
      nombreTentativesSync: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nombre_tentatives_sync'],
      )!,
    );
  }

  @override
  $ResultatsLocauxTable createAlias(String alias) {
    return $ResultatsLocauxTable(attachedDatabase, alias);
  }
}

class ResultatsLocauxData extends DataClass
    implements Insertable<ResultatsLocauxData> {
  final String id;
  final String echantillonId;
  final int? modeleUtiliseId;
  final double? acidite;
  final double? indicePeroxyde;
  final DateTime? dateCalcul;
  final int? dureeAnalyseSecondes;
  final bool? conforme;
  final String commentaire;
  final DateTime dateCreationLocale;
  final String statutSync;
  final String? messageErreurSync;
  final int nombreTentativesSync;
  const ResultatsLocauxData({
    required this.id,
    required this.echantillonId,
    this.modeleUtiliseId,
    this.acidite,
    this.indicePeroxyde,
    this.dateCalcul,
    this.dureeAnalyseSecondes,
    this.conforme,
    required this.commentaire,
    required this.dateCreationLocale,
    required this.statutSync,
    this.messageErreurSync,
    required this.nombreTentativesSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['echantillon_id'] = Variable<String>(echantillonId);
    if (!nullToAbsent || modeleUtiliseId != null) {
      map['modele_utilise_id'] = Variable<int>(modeleUtiliseId);
    }
    if (!nullToAbsent || acidite != null) {
      map['acidite'] = Variable<double>(acidite);
    }
    if (!nullToAbsent || indicePeroxyde != null) {
      map['indice_peroxyde'] = Variable<double>(indicePeroxyde);
    }
    if (!nullToAbsent || dateCalcul != null) {
      map['date_calcul'] = Variable<DateTime>(dateCalcul);
    }
    if (!nullToAbsent || dureeAnalyseSecondes != null) {
      map['duree_analyse_secondes'] = Variable<int>(dureeAnalyseSecondes);
    }
    if (!nullToAbsent || conforme != null) {
      map['conforme'] = Variable<bool>(conforme);
    }
    map['commentaire'] = Variable<String>(commentaire);
    map['date_creation_locale'] = Variable<DateTime>(dateCreationLocale);
    map['statut_sync'] = Variable<String>(statutSync);
    if (!nullToAbsent || messageErreurSync != null) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync);
    }
    map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync);
    return map;
  }

  ResultatsLocauxCompanion toCompanion(bool nullToAbsent) {
    return ResultatsLocauxCompanion(
      id: Value(id),
      echantillonId: Value(echantillonId),
      modeleUtiliseId: modeleUtiliseId == null && nullToAbsent
          ? const Value.absent()
          : Value(modeleUtiliseId),
      acidite: acidite == null && nullToAbsent
          ? const Value.absent()
          : Value(acidite),
      indicePeroxyde: indicePeroxyde == null && nullToAbsent
          ? const Value.absent()
          : Value(indicePeroxyde),
      dateCalcul: dateCalcul == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCalcul),
      dureeAnalyseSecondes: dureeAnalyseSecondes == null && nullToAbsent
          ? const Value.absent()
          : Value(dureeAnalyseSecondes),
      conforme: conforme == null && nullToAbsent
          ? const Value.absent()
          : Value(conforme),
      commentaire: Value(commentaire),
      dateCreationLocale: Value(dateCreationLocale),
      statutSync: Value(statutSync),
      messageErreurSync: messageErreurSync == null && nullToAbsent
          ? const Value.absent()
          : Value(messageErreurSync),
      nombreTentativesSync: Value(nombreTentativesSync),
    );
  }

  factory ResultatsLocauxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResultatsLocauxData(
      id: serializer.fromJson<String>(json['id']),
      echantillonId: serializer.fromJson<String>(json['echantillonId']),
      modeleUtiliseId: serializer.fromJson<int?>(json['modeleUtiliseId']),
      acidite: serializer.fromJson<double?>(json['acidite']),
      indicePeroxyde: serializer.fromJson<double?>(json['indicePeroxyde']),
      dateCalcul: serializer.fromJson<DateTime?>(json['dateCalcul']),
      dureeAnalyseSecondes: serializer.fromJson<int?>(
        json['dureeAnalyseSecondes'],
      ),
      conforme: serializer.fromJson<bool?>(json['conforme']),
      commentaire: serializer.fromJson<String>(json['commentaire']),
      dateCreationLocale: serializer.fromJson<DateTime>(
        json['dateCreationLocale'],
      ),
      statutSync: serializer.fromJson<String>(json['statutSync']),
      messageErreurSync: serializer.fromJson<String?>(
        json['messageErreurSync'],
      ),
      nombreTentativesSync: serializer.fromJson<int>(
        json['nombreTentativesSync'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'echantillonId': serializer.toJson<String>(echantillonId),
      'modeleUtiliseId': serializer.toJson<int?>(modeleUtiliseId),
      'acidite': serializer.toJson<double?>(acidite),
      'indicePeroxyde': serializer.toJson<double?>(indicePeroxyde),
      'dateCalcul': serializer.toJson<DateTime?>(dateCalcul),
      'dureeAnalyseSecondes': serializer.toJson<int?>(dureeAnalyseSecondes),
      'conforme': serializer.toJson<bool?>(conforme),
      'commentaire': serializer.toJson<String>(commentaire),
      'dateCreationLocale': serializer.toJson<DateTime>(dateCreationLocale),
      'statutSync': serializer.toJson<String>(statutSync),
      'messageErreurSync': serializer.toJson<String?>(messageErreurSync),
      'nombreTentativesSync': serializer.toJson<int>(nombreTentativesSync),
    };
  }

  ResultatsLocauxData copyWith({
    String? id,
    String? echantillonId,
    Value<int?> modeleUtiliseId = const Value.absent(),
    Value<double?> acidite = const Value.absent(),
    Value<double?> indicePeroxyde = const Value.absent(),
    Value<DateTime?> dateCalcul = const Value.absent(),
    Value<int?> dureeAnalyseSecondes = const Value.absent(),
    Value<bool?> conforme = const Value.absent(),
    String? commentaire,
    DateTime? dateCreationLocale,
    String? statutSync,
    Value<String?> messageErreurSync = const Value.absent(),
    int? nombreTentativesSync,
  }) => ResultatsLocauxData(
    id: id ?? this.id,
    echantillonId: echantillonId ?? this.echantillonId,
    modeleUtiliseId: modeleUtiliseId.present
        ? modeleUtiliseId.value
        : this.modeleUtiliseId,
    acidite: acidite.present ? acidite.value : this.acidite,
    indicePeroxyde: indicePeroxyde.present
        ? indicePeroxyde.value
        : this.indicePeroxyde,
    dateCalcul: dateCalcul.present ? dateCalcul.value : this.dateCalcul,
    dureeAnalyseSecondes: dureeAnalyseSecondes.present
        ? dureeAnalyseSecondes.value
        : this.dureeAnalyseSecondes,
    conforme: conforme.present ? conforme.value : this.conforme,
    commentaire: commentaire ?? this.commentaire,
    dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
    statutSync: statutSync ?? this.statutSync,
    messageErreurSync: messageErreurSync.present
        ? messageErreurSync.value
        : this.messageErreurSync,
    nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
  );
  ResultatsLocauxData copyWithCompanion(ResultatsLocauxCompanion data) {
    return ResultatsLocauxData(
      id: data.id.present ? data.id.value : this.id,
      echantillonId: data.echantillonId.present
          ? data.echantillonId.value
          : this.echantillonId,
      modeleUtiliseId: data.modeleUtiliseId.present
          ? data.modeleUtiliseId.value
          : this.modeleUtiliseId,
      acidite: data.acidite.present ? data.acidite.value : this.acidite,
      indicePeroxyde: data.indicePeroxyde.present
          ? data.indicePeroxyde.value
          : this.indicePeroxyde,
      dateCalcul: data.dateCalcul.present
          ? data.dateCalcul.value
          : this.dateCalcul,
      dureeAnalyseSecondes: data.dureeAnalyseSecondes.present
          ? data.dureeAnalyseSecondes.value
          : this.dureeAnalyseSecondes,
      conforme: data.conforme.present ? data.conforme.value : this.conforme,
      commentaire: data.commentaire.present
          ? data.commentaire.value
          : this.commentaire,
      dateCreationLocale: data.dateCreationLocale.present
          ? data.dateCreationLocale.value
          : this.dateCreationLocale,
      statutSync: data.statutSync.present
          ? data.statutSync.value
          : this.statutSync,
      messageErreurSync: data.messageErreurSync.present
          ? data.messageErreurSync.value
          : this.messageErreurSync,
      nombreTentativesSync: data.nombreTentativesSync.present
          ? data.nombreTentativesSync.value
          : this.nombreTentativesSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResultatsLocauxData(')
          ..write('id: $id, ')
          ..write('echantillonId: $echantillonId, ')
          ..write('modeleUtiliseId: $modeleUtiliseId, ')
          ..write('acidite: $acidite, ')
          ..write('indicePeroxyde: $indicePeroxyde, ')
          ..write('dateCalcul: $dateCalcul, ')
          ..write('dureeAnalyseSecondes: $dureeAnalyseSecondes, ')
          ..write('conforme: $conforme, ')
          ..write('commentaire: $commentaire, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    echantillonId,
    modeleUtiliseId,
    acidite,
    indicePeroxyde,
    dateCalcul,
    dureeAnalyseSecondes,
    conforme,
    commentaire,
    dateCreationLocale,
    statutSync,
    messageErreurSync,
    nombreTentativesSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResultatsLocauxData &&
          other.id == this.id &&
          other.echantillonId == this.echantillonId &&
          other.modeleUtiliseId == this.modeleUtiliseId &&
          other.acidite == this.acidite &&
          other.indicePeroxyde == this.indicePeroxyde &&
          other.dateCalcul == this.dateCalcul &&
          other.dureeAnalyseSecondes == this.dureeAnalyseSecondes &&
          other.conforme == this.conforme &&
          other.commentaire == this.commentaire &&
          other.dateCreationLocale == this.dateCreationLocale &&
          other.statutSync == this.statutSync &&
          other.messageErreurSync == this.messageErreurSync &&
          other.nombreTentativesSync == this.nombreTentativesSync);
}

class ResultatsLocauxCompanion extends UpdateCompanion<ResultatsLocauxData> {
  final Value<String> id;
  final Value<String> echantillonId;
  final Value<int?> modeleUtiliseId;
  final Value<double?> acidite;
  final Value<double?> indicePeroxyde;
  final Value<DateTime?> dateCalcul;
  final Value<int?> dureeAnalyseSecondes;
  final Value<bool?> conforme;
  final Value<String> commentaire;
  final Value<DateTime> dateCreationLocale;
  final Value<String> statutSync;
  final Value<String?> messageErreurSync;
  final Value<int> nombreTentativesSync;
  final Value<int> rowid;
  const ResultatsLocauxCompanion({
    this.id = const Value.absent(),
    this.echantillonId = const Value.absent(),
    this.modeleUtiliseId = const Value.absent(),
    this.acidite = const Value.absent(),
    this.indicePeroxyde = const Value.absent(),
    this.dateCalcul = const Value.absent(),
    this.dureeAnalyseSecondes = const Value.absent(),
    this.conforme = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResultatsLocauxCompanion.insert({
    required String id,
    required String echantillonId,
    this.modeleUtiliseId = const Value.absent(),
    this.acidite = const Value.absent(),
    this.indicePeroxyde = const Value.absent(),
    this.dateCalcul = const Value.absent(),
    this.dureeAnalyseSecondes = const Value.absent(),
    this.conforme = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.dateCreationLocale = const Value.absent(),
    this.statutSync = const Value.absent(),
    this.messageErreurSync = const Value.absent(),
    this.nombreTentativesSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       echantillonId = Value(echantillonId);
  static Insertable<ResultatsLocauxData> custom({
    Expression<String>? id,
    Expression<String>? echantillonId,
    Expression<int>? modeleUtiliseId,
    Expression<double>? acidite,
    Expression<double>? indicePeroxyde,
    Expression<DateTime>? dateCalcul,
    Expression<int>? dureeAnalyseSecondes,
    Expression<bool>? conforme,
    Expression<String>? commentaire,
    Expression<DateTime>? dateCreationLocale,
    Expression<String>? statutSync,
    Expression<String>? messageErreurSync,
    Expression<int>? nombreTentativesSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (echantillonId != null) 'echantillon_id': echantillonId,
      if (modeleUtiliseId != null) 'modele_utilise_id': modeleUtiliseId,
      if (acidite != null) 'acidite': acidite,
      if (indicePeroxyde != null) 'indice_peroxyde': indicePeroxyde,
      if (dateCalcul != null) 'date_calcul': dateCalcul,
      if (dureeAnalyseSecondes != null)
        'duree_analyse_secondes': dureeAnalyseSecondes,
      if (conforme != null) 'conforme': conforme,
      if (commentaire != null) 'commentaire': commentaire,
      if (dateCreationLocale != null)
        'date_creation_locale': dateCreationLocale,
      if (statutSync != null) 'statut_sync': statutSync,
      if (messageErreurSync != null) 'message_erreur_sync': messageErreurSync,
      if (nombreTentativesSync != null)
        'nombre_tentatives_sync': nombreTentativesSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResultatsLocauxCompanion copyWith({
    Value<String>? id,
    Value<String>? echantillonId,
    Value<int?>? modeleUtiliseId,
    Value<double?>? acidite,
    Value<double?>? indicePeroxyde,
    Value<DateTime?>? dateCalcul,
    Value<int?>? dureeAnalyseSecondes,
    Value<bool?>? conforme,
    Value<String>? commentaire,
    Value<DateTime>? dateCreationLocale,
    Value<String>? statutSync,
    Value<String?>? messageErreurSync,
    Value<int>? nombreTentativesSync,
    Value<int>? rowid,
  }) {
    return ResultatsLocauxCompanion(
      id: id ?? this.id,
      echantillonId: echantillonId ?? this.echantillonId,
      modeleUtiliseId: modeleUtiliseId ?? this.modeleUtiliseId,
      acidite: acidite ?? this.acidite,
      indicePeroxyde: indicePeroxyde ?? this.indicePeroxyde,
      dateCalcul: dateCalcul ?? this.dateCalcul,
      dureeAnalyseSecondes: dureeAnalyseSecondes ?? this.dureeAnalyseSecondes,
      conforme: conforme ?? this.conforme,
      commentaire: commentaire ?? this.commentaire,
      dateCreationLocale: dateCreationLocale ?? this.dateCreationLocale,
      statutSync: statutSync ?? this.statutSync,
      messageErreurSync: messageErreurSync ?? this.messageErreurSync,
      nombreTentativesSync: nombreTentativesSync ?? this.nombreTentativesSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (echantillonId.present) {
      map['echantillon_id'] = Variable<String>(echantillonId.value);
    }
    if (modeleUtiliseId.present) {
      map['modele_utilise_id'] = Variable<int>(modeleUtiliseId.value);
    }
    if (acidite.present) {
      map['acidite'] = Variable<double>(acidite.value);
    }
    if (indicePeroxyde.present) {
      map['indice_peroxyde'] = Variable<double>(indicePeroxyde.value);
    }
    if (dateCalcul.present) {
      map['date_calcul'] = Variable<DateTime>(dateCalcul.value);
    }
    if (dureeAnalyseSecondes.present) {
      map['duree_analyse_secondes'] = Variable<int>(dureeAnalyseSecondes.value);
    }
    if (conforme.present) {
      map['conforme'] = Variable<bool>(conforme.value);
    }
    if (commentaire.present) {
      map['commentaire'] = Variable<String>(commentaire.value);
    }
    if (dateCreationLocale.present) {
      map['date_creation_locale'] = Variable<DateTime>(
        dateCreationLocale.value,
      );
    }
    if (statutSync.present) {
      map['statut_sync'] = Variable<String>(statutSync.value);
    }
    if (messageErreurSync.present) {
      map['message_erreur_sync'] = Variable<String>(messageErreurSync.value);
    }
    if (nombreTentativesSync.present) {
      map['nombre_tentatives_sync'] = Variable<int>(nombreTentativesSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultatsLocauxCompanion(')
          ..write('id: $id, ')
          ..write('echantillonId: $echantillonId, ')
          ..write('modeleUtiliseId: $modeleUtiliseId, ')
          ..write('acidite: $acidite, ')
          ..write('indicePeroxyde: $indicePeroxyde, ')
          ..write('dateCalcul: $dateCalcul, ')
          ..write('dureeAnalyseSecondes: $dureeAnalyseSecondes, ')
          ..write('conforme: $conforme, ')
          ..write('commentaire: $commentaire, ')
          ..write('dateCreationLocale: $dateCreationLocale, ')
          ..write('statutSync: $statutSync, ')
          ..write('messageErreurSync: $messageErreurSync, ')
          ..write('nombreTentativesSync: $nombreTentativesSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $EchantillonsLocauxTable echantillonsLocaux =
      $EchantillonsLocauxTable(this);
  late final $SpectresLocauxTable spectresLocaux = $SpectresLocauxTable(this);
  late final $ResultatsLocauxTable resultatsLocaux = $ResultatsLocauxTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    echantillonsLocaux,
    spectresLocaux,
    resultatsLocaux,
  ];
}

typedef $$EchantillonsLocauxTableCreateCompanionBuilder =
    EchantillonsLocauxCompanion Function({
      required String id,
      required String numero,
      required DateTime dateAnalyse,
      Value<String> producteur,
      Value<String> region,
      Value<DateTime?> dateRecolte,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> variete,
      Value<String> origine,
      Value<String> notes,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });
typedef $$EchantillonsLocauxTableUpdateCompanionBuilder =
    EchantillonsLocauxCompanion Function({
      Value<String> id,
      Value<String> numero,
      Value<DateTime> dateAnalyse,
      Value<String> producteur,
      Value<String> region,
      Value<DateTime?> dateRecolte,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> variete,
      Value<String> origine,
      Value<String> notes,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });

final class $$EchantillonsLocauxTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $EchantillonsLocauxTable,
          EchantillonsLocauxData
        > {
  $$EchantillonsLocauxTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SpectresLocauxTable, List<SpectresLocauxData>>
  _spectresLocauxRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.spectresLocaux,
    aliasName: 'echantillons_locaux__id__spectres_locaux__echantillon_id',
  );

  $$SpectresLocauxTableProcessedTableManager get spectresLocauxRefs {
    final manager = $$SpectresLocauxTableTableManager(
      $_db,
      $_db.spectresLocaux,
    ).filter((f) => f.echantillonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_spectresLocauxRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResultatsLocauxTable, List<ResultatsLocauxData>>
  _resultatsLocauxRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resultatsLocaux,
        aliasName: 'echantillons_locaux__id__resultats_locaux__echantillon_id',
      );

  $$ResultatsLocauxTableProcessedTableManager get resultatsLocauxRefs {
    final manager = $$ResultatsLocauxTableTableManager(
      $_db,
      $_db.resultatsLocaux,
    ).filter((f) => f.echantillonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resultatsLocauxRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EchantillonsLocauxTableFilterComposer
    extends Composer<_$LocalDatabase, $EchantillonsLocauxTable> {
  $$EchantillonsLocauxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAnalyse => $composableBuilder(
    column: $table.dateAnalyse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateRecolte => $composableBuilder(
    column: $table.dateRecolte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variete => $composableBuilder(
    column: $table.variete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origine => $composableBuilder(
    column: $table.origine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> spectresLocauxRefs(
    Expression<bool> Function($$SpectresLocauxTableFilterComposer f) f,
  ) {
    final $$SpectresLocauxTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spectresLocaux,
      getReferencedColumn: (t) => t.echantillonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpectresLocauxTableFilterComposer(
            $db: $db,
            $table: $db.spectresLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resultatsLocauxRefs(
    Expression<bool> Function($$ResultatsLocauxTableFilterComposer f) f,
  ) {
    final $$ResultatsLocauxTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resultatsLocaux,
      getReferencedColumn: (t) => t.echantillonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultatsLocauxTableFilterComposer(
            $db: $db,
            $table: $db.resultatsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EchantillonsLocauxTableOrderingComposer
    extends Composer<_$LocalDatabase, $EchantillonsLocauxTable> {
  $$EchantillonsLocauxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAnalyse => $composableBuilder(
    column: $table.dateAnalyse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateRecolte => $composableBuilder(
    column: $table.dateRecolte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variete => $composableBuilder(
    column: $table.variete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origine => $composableBuilder(
    column: $table.origine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EchantillonsLocauxTableAnnotationComposer
    extends Composer<_$LocalDatabase, $EchantillonsLocauxTable> {
  $$EchantillonsLocauxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAnalyse => $composableBuilder(
    column: $table.dateAnalyse,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producteur => $composableBuilder(
    column: $table.producteur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<DateTime> get dateRecolte => $composableBuilder(
    column: $table.dateRecolte,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get variete =>
      $composableBuilder(column: $table.variete, builder: (column) => column);

  GeneratedColumn<String> get origine =>
      $composableBuilder(column: $table.origine, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => column,
  );

  Expression<T> spectresLocauxRefs<T extends Object>(
    Expression<T> Function($$SpectresLocauxTableAnnotationComposer a) f,
  ) {
    final $$SpectresLocauxTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spectresLocaux,
      getReferencedColumn: (t) => t.echantillonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpectresLocauxTableAnnotationComposer(
            $db: $db,
            $table: $db.spectresLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resultatsLocauxRefs<T extends Object>(
    Expression<T> Function($$ResultatsLocauxTableAnnotationComposer a) f,
  ) {
    final $$ResultatsLocauxTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resultatsLocaux,
      getReferencedColumn: (t) => t.echantillonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultatsLocauxTableAnnotationComposer(
            $db: $db,
            $table: $db.resultatsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EchantillonsLocauxTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $EchantillonsLocauxTable,
          EchantillonsLocauxData,
          $$EchantillonsLocauxTableFilterComposer,
          $$EchantillonsLocauxTableOrderingComposer,
          $$EchantillonsLocauxTableAnnotationComposer,
          $$EchantillonsLocauxTableCreateCompanionBuilder,
          $$EchantillonsLocauxTableUpdateCompanionBuilder,
          (EchantillonsLocauxData, $$EchantillonsLocauxTableReferences),
          EchantillonsLocauxData,
          PrefetchHooks Function({
            bool spectresLocauxRefs,
            bool resultatsLocauxRefs,
          })
        > {
  $$EchantillonsLocauxTableTableManager(
    _$LocalDatabase db,
    $EchantillonsLocauxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EchantillonsLocauxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EchantillonsLocauxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EchantillonsLocauxTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> numero = const Value.absent(),
                Value<DateTime> dateAnalyse = const Value.absent(),
                Value<String> producteur = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<DateTime?> dateRecolte = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> variete = const Value.absent(),
                Value<String> origine = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EchantillonsLocauxCompanion(
                id: id,
                numero: numero,
                dateAnalyse: dateAnalyse,
                producteur: producteur,
                region: region,
                dateRecolte: dateRecolte,
                latitude: latitude,
                longitude: longitude,
                variete: variete,
                origine: origine,
                notes: notes,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String numero,
                required DateTime dateAnalyse,
                Value<String> producteur = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<DateTime?> dateRecolte = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> variete = const Value.absent(),
                Value<String> origine = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EchantillonsLocauxCompanion.insert(
                id: id,
                numero: numero,
                dateAnalyse: dateAnalyse,
                producteur: producteur,
                region: region,
                dateRecolte: dateRecolte,
                latitude: latitude,
                longitude: longitude,
                variete: variete,
                origine: origine,
                notes: notes,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EchantillonsLocauxTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({spectresLocauxRefs = false, resultatsLocauxRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (spectresLocauxRefs) db.spectresLocaux,
                    if (resultatsLocauxRefs) db.resultatsLocaux,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (spectresLocauxRefs)
                        await $_getPrefetchedData<
                          EchantillonsLocauxData,
                          $EchantillonsLocauxTable,
                          SpectresLocauxData
                        >(
                          currentTable: table,
                          referencedTable: $$EchantillonsLocauxTableReferences
                              ._spectresLocauxRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EchantillonsLocauxTableReferences(
                                db,
                                table,
                                p0,
                              ).spectresLocauxRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.echantillonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resultatsLocauxRefs)
                        await $_getPrefetchedData<
                          EchantillonsLocauxData,
                          $EchantillonsLocauxTable,
                          ResultatsLocauxData
                        >(
                          currentTable: table,
                          referencedTable: $$EchantillonsLocauxTableReferences
                              ._resultatsLocauxRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EchantillonsLocauxTableReferences(
                                db,
                                table,
                                p0,
                              ).resultatsLocauxRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.echantillonId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EchantillonsLocauxTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $EchantillonsLocauxTable,
      EchantillonsLocauxData,
      $$EchantillonsLocauxTableFilterComposer,
      $$EchantillonsLocauxTableOrderingComposer,
      $$EchantillonsLocauxTableAnnotationComposer,
      $$EchantillonsLocauxTableCreateCompanionBuilder,
      $$EchantillonsLocauxTableUpdateCompanionBuilder,
      (EchantillonsLocauxData, $$EchantillonsLocauxTableReferences),
      EchantillonsLocauxData,
      PrefetchHooks Function({
        bool spectresLocauxRefs,
        bool resultatsLocauxRefs,
      })
    >;
typedef $$SpectresLocauxTableCreateCompanionBuilder =
    SpectresLocauxCompanion Function({
      required String id,
      required String echantillonId,
      required String valeursXJson,
      required String valeursYJson,
      required int nombreSeries,
      required DateTime dateAcquisition,
      Value<String> checksum,
      Value<int?> tailleDonnees,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });
typedef $$SpectresLocauxTableUpdateCompanionBuilder =
    SpectresLocauxCompanion Function({
      Value<String> id,
      Value<String> echantillonId,
      Value<String> valeursXJson,
      Value<String> valeursYJson,
      Value<int> nombreSeries,
      Value<DateTime> dateAcquisition,
      Value<String> checksum,
      Value<int?> tailleDonnees,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });

final class $$SpectresLocauxTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $SpectresLocauxTable,
          SpectresLocauxData
        > {
  $$SpectresLocauxTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EchantillonsLocauxTable _echantillonIdTable(_$LocalDatabase db) => db
      .echantillonsLocaux
      .createAlias('spectres_locaux__echantillon_id__echantillons_locaux__id');

  $$EchantillonsLocauxTableProcessedTableManager get echantillonId {
    final $_column = $_itemColumn<String>('echantillon_id')!;

    final manager = $$EchantillonsLocauxTableTableManager(
      $_db,
      $_db.echantillonsLocaux,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_echantillonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpectresLocauxTableFilterComposer
    extends Composer<_$LocalDatabase, $SpectresLocauxTable> {
  $$SpectresLocauxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valeursXJson => $composableBuilder(
    column: $table.valeursXJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valeursYJson => $composableBuilder(
    column: $table.valeursYJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreSeries => $composableBuilder(
    column: $table.nombreSeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAcquisition => $composableBuilder(
    column: $table.dateAcquisition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tailleDonnees => $composableBuilder(
    column: $table.tailleDonnees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnFilters(column),
  );

  $$EchantillonsLocauxTableFilterComposer get echantillonId {
    final $$EchantillonsLocauxTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.echantillonId,
      referencedTable: $db.echantillonsLocaux,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EchantillonsLocauxTableFilterComposer(
            $db: $db,
            $table: $db.echantillonsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpectresLocauxTableOrderingComposer
    extends Composer<_$LocalDatabase, $SpectresLocauxTable> {
  $$SpectresLocauxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valeursXJson => $composableBuilder(
    column: $table.valeursXJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valeursYJson => $composableBuilder(
    column: $table.valeursYJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreSeries => $composableBuilder(
    column: $table.nombreSeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAcquisition => $composableBuilder(
    column: $table.dateAcquisition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tailleDonnees => $composableBuilder(
    column: $table.tailleDonnees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnOrderings(column),
  );

  $$EchantillonsLocauxTableOrderingComposer get echantillonId {
    final $$EchantillonsLocauxTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.echantillonId,
      referencedTable: $db.echantillonsLocaux,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EchantillonsLocauxTableOrderingComposer(
            $db: $db,
            $table: $db.echantillonsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpectresLocauxTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SpectresLocauxTable> {
  $$SpectresLocauxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get valeursXJson => $composableBuilder(
    column: $table.valeursXJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valeursYJson => $composableBuilder(
    column: $table.valeursYJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreSeries => $composableBuilder(
    column: $table.nombreSeries,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAcquisition => $composableBuilder(
    column: $table.dateAcquisition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<int> get tailleDonnees => $composableBuilder(
    column: $table.tailleDonnees,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => column,
  );

  $$EchantillonsLocauxTableAnnotationComposer get echantillonId {
    final $$EchantillonsLocauxTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.echantillonId,
          referencedTable: $db.echantillonsLocaux,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EchantillonsLocauxTableAnnotationComposer(
                $db: $db,
                $table: $db.echantillonsLocaux,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SpectresLocauxTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SpectresLocauxTable,
          SpectresLocauxData,
          $$SpectresLocauxTableFilterComposer,
          $$SpectresLocauxTableOrderingComposer,
          $$SpectresLocauxTableAnnotationComposer,
          $$SpectresLocauxTableCreateCompanionBuilder,
          $$SpectresLocauxTableUpdateCompanionBuilder,
          (SpectresLocauxData, $$SpectresLocauxTableReferences),
          SpectresLocauxData,
          PrefetchHooks Function({bool echantillonId})
        > {
  $$SpectresLocauxTableTableManager(
    _$LocalDatabase db,
    $SpectresLocauxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpectresLocauxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpectresLocauxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpectresLocauxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> echantillonId = const Value.absent(),
                Value<String> valeursXJson = const Value.absent(),
                Value<String> valeursYJson = const Value.absent(),
                Value<int> nombreSeries = const Value.absent(),
                Value<DateTime> dateAcquisition = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<int?> tailleDonnees = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpectresLocauxCompanion(
                id: id,
                echantillonId: echantillonId,
                valeursXJson: valeursXJson,
                valeursYJson: valeursYJson,
                nombreSeries: nombreSeries,
                dateAcquisition: dateAcquisition,
                checksum: checksum,
                tailleDonnees: tailleDonnees,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String echantillonId,
                required String valeursXJson,
                required String valeursYJson,
                required int nombreSeries,
                required DateTime dateAcquisition,
                Value<String> checksum = const Value.absent(),
                Value<int?> tailleDonnees = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpectresLocauxCompanion.insert(
                id: id,
                echantillonId: echantillonId,
                valeursXJson: valeursXJson,
                valeursYJson: valeursYJson,
                nombreSeries: nombreSeries,
                dateAcquisition: dateAcquisition,
                checksum: checksum,
                tailleDonnees: tailleDonnees,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SpectresLocauxTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({echantillonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (echantillonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.echantillonId,
                                referencedTable: $$SpectresLocauxTableReferences
                                    ._echantillonIdTable(db),
                                referencedColumn:
                                    $$SpectresLocauxTableReferences
                                        ._echantillonIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpectresLocauxTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SpectresLocauxTable,
      SpectresLocauxData,
      $$SpectresLocauxTableFilterComposer,
      $$SpectresLocauxTableOrderingComposer,
      $$SpectresLocauxTableAnnotationComposer,
      $$SpectresLocauxTableCreateCompanionBuilder,
      $$SpectresLocauxTableUpdateCompanionBuilder,
      (SpectresLocauxData, $$SpectresLocauxTableReferences),
      SpectresLocauxData,
      PrefetchHooks Function({bool echantillonId})
    >;
typedef $$ResultatsLocauxTableCreateCompanionBuilder =
    ResultatsLocauxCompanion Function({
      required String id,
      required String echantillonId,
      Value<int?> modeleUtiliseId,
      Value<double?> acidite,
      Value<double?> indicePeroxyde,
      Value<DateTime?> dateCalcul,
      Value<int?> dureeAnalyseSecondes,
      Value<bool?> conforme,
      Value<String> commentaire,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });
typedef $$ResultatsLocauxTableUpdateCompanionBuilder =
    ResultatsLocauxCompanion Function({
      Value<String> id,
      Value<String> echantillonId,
      Value<int?> modeleUtiliseId,
      Value<double?> acidite,
      Value<double?> indicePeroxyde,
      Value<DateTime?> dateCalcul,
      Value<int?> dureeAnalyseSecondes,
      Value<bool?> conforme,
      Value<String> commentaire,
      Value<DateTime> dateCreationLocale,
      Value<String> statutSync,
      Value<String?> messageErreurSync,
      Value<int> nombreTentativesSync,
      Value<int> rowid,
    });

final class $$ResultatsLocauxTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $ResultatsLocauxTable,
          ResultatsLocauxData
        > {
  $$ResultatsLocauxTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EchantillonsLocauxTable _echantillonIdTable(_$LocalDatabase db) => db
      .echantillonsLocaux
      .createAlias('resultats_locaux__echantillon_id__echantillons_locaux__id');

  $$EchantillonsLocauxTableProcessedTableManager get echantillonId {
    final $_column = $_itemColumn<String>('echantillon_id')!;

    final manager = $$EchantillonsLocauxTableTableManager(
      $_db,
      $_db.echantillonsLocaux,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_echantillonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResultatsLocauxTableFilterComposer
    extends Composer<_$LocalDatabase, $ResultatsLocauxTable> {
  $$ResultatsLocauxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modeleUtiliseId => $composableBuilder(
    column: $table.modeleUtiliseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get acidite => $composableBuilder(
    column: $table.acidite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get indicePeroxyde => $composableBuilder(
    column: $table.indicePeroxyde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCalcul => $composableBuilder(
    column: $table.dateCalcul,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dureeAnalyseSecondes => $composableBuilder(
    column: $table.dureeAnalyseSecondes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get conforme => $composableBuilder(
    column: $table.conforme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentaire => $composableBuilder(
    column: $table.commentaire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnFilters(column),
  );

  $$EchantillonsLocauxTableFilterComposer get echantillonId {
    final $$EchantillonsLocauxTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.echantillonId,
      referencedTable: $db.echantillonsLocaux,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EchantillonsLocauxTableFilterComposer(
            $db: $db,
            $table: $db.echantillonsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultatsLocauxTableOrderingComposer
    extends Composer<_$LocalDatabase, $ResultatsLocauxTable> {
  $$ResultatsLocauxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modeleUtiliseId => $composableBuilder(
    column: $table.modeleUtiliseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get acidite => $composableBuilder(
    column: $table.acidite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get indicePeroxyde => $composableBuilder(
    column: $table.indicePeroxyde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCalcul => $composableBuilder(
    column: $table.dateCalcul,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dureeAnalyseSecondes => $composableBuilder(
    column: $table.dureeAnalyseSecondes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get conforme => $composableBuilder(
    column: $table.conforme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentaire => $composableBuilder(
    column: $table.commentaire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => ColumnOrderings(column),
  );

  $$EchantillonsLocauxTableOrderingComposer get echantillonId {
    final $$EchantillonsLocauxTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.echantillonId,
      referencedTable: $db.echantillonsLocaux,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EchantillonsLocauxTableOrderingComposer(
            $db: $db,
            $table: $db.echantillonsLocaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultatsLocauxTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ResultatsLocauxTable> {
  $$ResultatsLocauxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modeleUtiliseId => $composableBuilder(
    column: $table.modeleUtiliseId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get acidite =>
      $composableBuilder(column: $table.acidite, builder: (column) => column);

  GeneratedColumn<double> get indicePeroxyde => $composableBuilder(
    column: $table.indicePeroxyde,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCalcul => $composableBuilder(
    column: $table.dateCalcul,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dureeAnalyseSecondes => $composableBuilder(
    column: $table.dureeAnalyseSecondes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get conforme =>
      $composableBuilder(column: $table.conforme, builder: (column) => column);

  GeneratedColumn<String> get commentaire => $composableBuilder(
    column: $table.commentaire,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreationLocale => $composableBuilder(
    column: $table.dateCreationLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statutSync => $composableBuilder(
    column: $table.statutSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageErreurSync => $composableBuilder(
    column: $table.messageErreurSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreTentativesSync => $composableBuilder(
    column: $table.nombreTentativesSync,
    builder: (column) => column,
  );

  $$EchantillonsLocauxTableAnnotationComposer get echantillonId {
    final $$EchantillonsLocauxTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.echantillonId,
          referencedTable: $db.echantillonsLocaux,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EchantillonsLocauxTableAnnotationComposer(
                $db: $db,
                $table: $db.echantillonsLocaux,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ResultatsLocauxTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ResultatsLocauxTable,
          ResultatsLocauxData,
          $$ResultatsLocauxTableFilterComposer,
          $$ResultatsLocauxTableOrderingComposer,
          $$ResultatsLocauxTableAnnotationComposer,
          $$ResultatsLocauxTableCreateCompanionBuilder,
          $$ResultatsLocauxTableUpdateCompanionBuilder,
          (ResultatsLocauxData, $$ResultatsLocauxTableReferences),
          ResultatsLocauxData,
          PrefetchHooks Function({bool echantillonId})
        > {
  $$ResultatsLocauxTableTableManager(
    _$LocalDatabase db,
    $ResultatsLocauxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResultatsLocauxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResultatsLocauxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResultatsLocauxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> echantillonId = const Value.absent(),
                Value<int?> modeleUtiliseId = const Value.absent(),
                Value<double?> acidite = const Value.absent(),
                Value<double?> indicePeroxyde = const Value.absent(),
                Value<DateTime?> dateCalcul = const Value.absent(),
                Value<int?> dureeAnalyseSecondes = const Value.absent(),
                Value<bool?> conforme = const Value.absent(),
                Value<String> commentaire = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultatsLocauxCompanion(
                id: id,
                echantillonId: echantillonId,
                modeleUtiliseId: modeleUtiliseId,
                acidite: acidite,
                indicePeroxyde: indicePeroxyde,
                dateCalcul: dateCalcul,
                dureeAnalyseSecondes: dureeAnalyseSecondes,
                conforme: conforme,
                commentaire: commentaire,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String echantillonId,
                Value<int?> modeleUtiliseId = const Value.absent(),
                Value<double?> acidite = const Value.absent(),
                Value<double?> indicePeroxyde = const Value.absent(),
                Value<DateTime?> dateCalcul = const Value.absent(),
                Value<int?> dureeAnalyseSecondes = const Value.absent(),
                Value<bool?> conforme = const Value.absent(),
                Value<String> commentaire = const Value.absent(),
                Value<DateTime> dateCreationLocale = const Value.absent(),
                Value<String> statutSync = const Value.absent(),
                Value<String?> messageErreurSync = const Value.absent(),
                Value<int> nombreTentativesSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultatsLocauxCompanion.insert(
                id: id,
                echantillonId: echantillonId,
                modeleUtiliseId: modeleUtiliseId,
                acidite: acidite,
                indicePeroxyde: indicePeroxyde,
                dateCalcul: dateCalcul,
                dureeAnalyseSecondes: dureeAnalyseSecondes,
                conforme: conforme,
                commentaire: commentaire,
                dateCreationLocale: dateCreationLocale,
                statutSync: statutSync,
                messageErreurSync: messageErreurSync,
                nombreTentativesSync: nombreTentativesSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResultatsLocauxTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({echantillonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (echantillonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.echantillonId,
                                referencedTable:
                                    $$ResultatsLocauxTableReferences
                                        ._echantillonIdTable(db),
                                referencedColumn:
                                    $$ResultatsLocauxTableReferences
                                        ._echantillonIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResultatsLocauxTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ResultatsLocauxTable,
      ResultatsLocauxData,
      $$ResultatsLocauxTableFilterComposer,
      $$ResultatsLocauxTableOrderingComposer,
      $$ResultatsLocauxTableAnnotationComposer,
      $$ResultatsLocauxTableCreateCompanionBuilder,
      $$ResultatsLocauxTableUpdateCompanionBuilder,
      (ResultatsLocauxData, $$ResultatsLocauxTableReferences),
      ResultatsLocauxData,
      PrefetchHooks Function({bool echantillonId})
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$EchantillonsLocauxTableTableManager get echantillonsLocaux =>
      $$EchantillonsLocauxTableTableManager(_db, _db.echantillonsLocaux);
  $$SpectresLocauxTableTableManager get spectresLocaux =>
      $$SpectresLocauxTableTableManager(_db, _db.spectresLocaux);
  $$ResultatsLocauxTableTableManager get resultatsLocaux =>
      $$ResultatsLocauxTableTableManager(_db, _db.resultatsLocaux);
}
