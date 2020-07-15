//
//  RecognitionLanguage.swift
//  SwiftyTesseract
//
//  Created by Steven Sherry on 3/22/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

/// The language of the text to be recognized
public enum RecognitionLanguage {
  case afrikaans
  case albanian
  case amharic
  case arabic
  case assamese
  case azerbaijani
  case azerbaijaniCyrillic
  case basque
  case belarusian
  case bengali
  case bosnian
  case bulgarian
  case burmese
  case catalanAndValencian
  case cebuano
  case centralKhmer
  case chineseSimplified
  case chineseTraditional
  case croatian
  case czech
  case cherokee
  case danish
  case dutchFlemish
  case dzongkha
  case english
  case englishMiddle
  case esperanto
  case estonian
  case finnish
  case frankish
  case french
  case frenchMiddle
  case galician
  case georgian
  case georgianOld
  case german
  case greekAncient
  case greekModern
  case guajarati
  case haitian
  case hebrew
  case hindi
  case hungarian
  case icelandic
  case inuktitut
  case indonesian
  case italian
  case italianOld
  case irish
  case javanese
  case japanese
  case kannada
  case kazakh
  case korean
  case kurdish
  case kyrgyz
  case lao
  case latin
  case lithuanian
  case malayalam
  case macedonian
  case malay
  case maltese
  case marathi
  case nepali
  case norwegian
  case oriya
  case pashto
  case persian
  case polish
  case portugese
  case punjabi
  case romanian
  case russian
  case sanskrit
  case serbian
  case serbianLatin
  case sinhala
  case slovak
  case slovenian
  case spanish
  case spanishOld
  case swahili
  case swedish
  case syriac
  case tamil
  case tagalog
  case tajik
  case telugu
  case thai
  case tibetan
  case tigrinya
  case turkish
  case uighur
  case ukrainian
  case urdu
  case uzbek
  case uzbekCyrillic
  case vietnamese
  case welsh
  case yiddish
  /// Takes the `String` representation of the `.trainnedata`
  /// file without the `.trainnedata` suffix.
  ///
  /// If you have a Klingon `.trainnedata` file named
  /// `klingon.trainnedata` this case would be used as `.custom("klingon")`
  case custom(String)
}

extension RecognitionLanguage: CustomStringConvertible {
  public var description: String {
    switch self {
    case .afrikaans: return "afr"
    case .albanian:  return "sqi"
    case .amharic: return "amh"
    case .arabic: return "ara"
    case .assamese: return "asm"
    case .azerbaijani: return "aze"
    case .azerbaijaniCyrillic: return "aze_cyrl"
    case .basque: return "eus"
    case .belarusian: return "bel"
    case .bengali: return "ben"
    case .bosnian: return "bos"
    case .bulgarian: return "bul"
    case .burmese: return "mya"
    case .catalanAndValencian: return "cat"
    case .cebuano: return "ceb"
    case .centralKhmer: return "khm"
    case .chineseSimplified: return "chi_sim"
    case .chineseTraditional: return "chi_tra"
    case .croatian: return "hrv"
    case .czech: return "ces"
    case .cherokee: return "chr"
    case .danish: return "dan"
    case .dutchFlemish: return "nld"
    case .dzongkha: return "dzo"
    case .english: return "eng"
    case .englishMiddle: return "enm"
    case .esperanto: return "epo"
    case .estonian: return "est"
    case .finnish: return "fin"
    case .frankish: return "frk"
    case .french: return "fra"
    case .frenchMiddle: return "frm"
    case .galician: return "glg"
    case .georgian: return "kat"
    case .georgianOld: return "kat_old"
    case .german: return "deu"
    case .greekAncient: return "grc"
    case .greekModern: return "ell"
    case .guajarati: return "guj"
    case .haitian: return "hat"
    case .hebrew: return "heb"
    case .hindi: return "hin"
    case .hungarian: return "hun"
    case .icelandic: return "isl"
    case .inuktitut: return "iku"
    case .indonesian: return "ind"
    case .italian: return "ita"
    case .italianOld: return "ita_old"
    case .irish: return "gle"
    case .javanese: return "jav"
    case .japanese: return "jpn"
    case .kannada: return "kan"
    case .kazakh: return "kaz"
    case .korean: return "kor"
    case .kurdish: return "kur"
    case .kyrgyz: return "kir"
    case .lao: return "lao"
    case .latin: return "lat"
    case .lithuanian: return "lit"
    case .malayalam: return "mal"
    case .macedonian: return "mkd"
    case .malay: return "msa"
    case .maltese: return "mlt"
    case .marathi: return "mar"
    case .nepali: return "nep"
    case .norwegian: return "nor"
    case .oriya: return "ori"
    case .pashto: return "pus"
    case .persian: return "fas"
    case .polish: return "pol"
    case .portugese: return "por"
    case .punjabi: return "pan"
    case .romanian: return "ron"
    case .russian: return "rus"
    case .sanskrit: return "san"
    case .serbian: return "srp"
    case .serbianLatin: return "srp_ltn"
    case .sinhala: return "sin"
    case .slovak: return "slk"
    case .slovenian: return "slv"
    case .spanish: return "spa"
    case .spanishOld: return "spa_old"
    case .swahili: return "swa"
    case .swedish: return "swe"
    case .syriac: return "syr"
    case .tamil: return "tam"
    case .tagalog: return "tgl"
    case .tajik: return "tgk"
    case .telugu: return "tel"
    case .thai: return "tha"
    case .tibetan: return "bod"
    case .tigrinya: return "tir"
    case .turkish: return "tur"
    case .uighur: return "uig"
    case .ukrainian: return "ukr"
    case .urdu: return "urd"
    case .uzbek: return "uzb"
    case .uzbekCyrillic: return "uzb_cyrl"
    case .vietnamese: return "vie"
    case .welsh: return "cym"
    case .yiddish: return "yid"
    case .custom(let customLanguage): return customLanguage
    }
  }
}

extension RecognitionLanguage: LanguageStringConverter {
  static func createLanguageString(from languages: [RecognitionLanguage]) -> String {
    let stringLanguages = languages.reduce("") { $0.appending("\($1.description)+") }
    return stringLanguages.droppingLast()
  }
}
