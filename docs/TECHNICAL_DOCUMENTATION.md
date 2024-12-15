# Journal Demo - Teknik Dokümantasyon

## İçindekiler
1. [Proje Genel Bakış](#1-proje-genel-bakış)
2. [Teknik Altyapı](#2-teknik-altyapı)
3. [Proje Yapısı](#3-proje-yapısı)
4. [Temel Bileşenler](#4-temel-bileşenler)
5. [Veri Akışı](#5-veri-akışı)
6. [Özellikler ve İşlevler](#6-özellikler-ve-işlevler)
7. [Performans Optimizasyonları](#7-performans-optimizasyonları)
8. [Geliştirici Rehberi](#8-geliştirici-rehberi)

## 1. Proje Genel Bakış

Journal Demo, interaktif dünya haritası üzerinde ülkeleri seçip özelleştirmeye olanak sağlayan bir Flutter uygulamasıdır. Kullanıcılar harita üzerinde ülkeleri seçebilir, renk atayabilir ve detaylı ülke bilgilerine erişebilir.

### 1.1 Temel Özellikler
- İnteraktif dünya haritası
- Ülke seçimi ve renklendirme
- Detaylı ülke görünümleri
- Harita yakınlaştırma ve kaydırma
- Not defteri entegrasyonu

## 2. Teknik Altyapı

### 2.1 Kullanılan Teknolojiler
- Flutter SDK ^3.5.4
- Dart programlama dili
- SVG harita işleme
- XML parsing
- Custom widget'lar

### 2.2 Temel Bağımlılıklar
yaml
dependencies:
flutter_svg: ^2.0.16
flutter_svg_provider: ^1.0.7
xml: ^6.5.0
path_drawing: ^1.0.1
flutter_colorpicker: ^1.0.3
flutter_dotenv: ^5.2.1
notebook_paper: ^0.0.4
```

## 3. Proje Yapısı

### 3.1 Klasör Organizasyonu

```
lib/
├── models/
│   ├── map_item.dart
│   └── country.dart
├── services/
│   └── map_service.dart
├── widgets/
│   ├── map/
│   │   ├── map_item_widget.dart
│   │   └── map_clipper.dart
│   └── common/
│       └── color_picker_dialog.dart
├── screens/
│   ├── splash/
│   ├── world_map/
│   └── country_map/
├── constants/
│   ├── colors.dart
│   └── country_configs.dart
└── utils/
```

### 3.2 Temel Bileşenler ve Sorumlulukları

#### Models
- **MapItem**: Harita öğeleri için temel sınıf
- **Country**: Ülke verilerini tutan model sınıfı

#### Services
- **MapService**: SVG harita yükleme ve işleme servisi

#### Widgets
- **MapItemWidget**: Harita öğelerinin görsel temsili
- **MapClipper**: SVG path'lerini kırpma işlemi
- **ColorPickerDialog**: Renk seçim dialogu

## 4. Temel Bileşenler

### 4.1 Harita İşleme Sistemi
```dart
class MapService {
  static Future<List<Country>> loadWorldMap() async {
    const path = 'assets/svgFiles/worldHigh.svg';
    return _loadMapItems(path, (element) => Country.fromSvgElement(element));
  }
}
```

SVG haritalar assets/svgFiles/ klasöründe tutulur ve MapService tarafından yüklenir. XML parsing işlemi ile path verileri çıkarılır ve Country nesnelerine dönüştürülür.

### 4.2 Veri Modelleri
```dart
class MapItem {
  final String id;
  final String path;
  final String title;
}

class Country extends MapItem {
  factory Country.fromSvgElement(dynamic element) {
    // SVG elementinden Country nesnesi oluşturma
  }
}
```

### 4.3 Ekran Yapısı
- **SplashScreen**: Giriş ekranı
- **WorldMapScreen**: Ana harita ekranı
- **GenericMapScreen**: Ülke detay haritaları

## 5. Veri Akışı

### 5.1 Harita Yükleme Süreci
1. SVG dosyası okunur
2. XML parsing yapılır
3. Path verileri çıkarılır
4. Country nesneleri oluşturulur
5. UI güncellenir

### 5.2 Kullanıcı Etkileşimi
1. Kullanıcı ülkeye tıklar
2. Ülke seçili duruma geçer
3. Renk seçimi yapılabilir
4. Seçim bilgisi state'te saklanır

## 6. Özellikler ve İşlevler

### 6.1 Harita Etkileşimleri
- Yakınlaştırma/Uzaklaştırma
- Kaydırma
- Ülke seçimi
- Renk atama

### 6.2 Renk Yönetimi
```dart
final Map<String, Color> countryColors = {};
Color selectedColor = AppColors.defaultSelectedColor;
```

Her ülke için ayrı renk saklanabilir ve değiştirilebilir.

### 6.3 Navigasyon
- Splash Screen → World Map
- World Map → Country Details
- World Map → Notebook

## 7. Performans Optimizasyonları

### 7.1 SVG İşleme
- SVG path'leri önbellekte tutulur
- Gereksiz render işlemleri engellenir

### 7.2 Widget Optimizasyonları
- const constructor kullanımı
- setState optimizasyonu
- Gereksiz build işlemlerinin önlenmesi

## 8. Geliştirici Rehberi

### 8.1 Yeni Özellik Ekleme
1. İlgili model sınıfını güncelle
2. Gerekli widget'ları oluştur
3. Service katmanını güncelle
4. UI entegrasyonunu yap

### 8.2 Yeni Ülke Haritası Ekleme
1. SVG dosyasını assets/svgFiles/ klasörüne ekle
2. country_configs.dart dosyasında yapılandırma ekle
3. Gerekli route'ları oluştur

### 8.3 Best Practices
- Modüler kod yazımı
- Single Responsibility prensibi
- DRY (Don't Repeat Yourself) prensibi
- Anlamlı isimlendirme
- Kod dokümantasyonu