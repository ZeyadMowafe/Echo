import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingTitleOne.
  ///
  /// In en, this message translates to:
  /// **'Scan & Decode'**
  String get onboardingTitleOne;

  /// No description provided for @onboardingDescOne.
  ///
  /// In en, this message translates to:
  /// **'Point your camera to unlock artifact\nstories and instantly translate ancient\nHieroglyphs.'**
  String get onboardingDescOne;

  /// No description provided for @onboardingTitleTwo.
  ///
  /// In en, this message translates to:
  /// **'Speak to History'**
  String get onboardingTitleTwo;

  /// No description provided for @onboardingDescTwo.
  ///
  /// In en, this message translates to:
  /// **'Have real conversations with artifacts.\nAsk questions and hear their hidden\nsecrets.'**
  String get onboardingDescTwo;

  /// No description provided for @onboardingTitleThree.
  ///
  /// In en, this message translates to:
  /// **'Explore the Myths'**
  String get onboardingTitleThree;

  /// No description provided for @onboardingDescThree.
  ///
  /// In en, this message translates to:
  /// **'Dive deep into the eras and mythology\nof Ancient Egypt. Your journey begins\nnow.'**
  String get onboardingDescThree;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get drawerDiscover;

  /// No description provided for @drawerScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get drawerScan;

  /// No description provided for @drawerChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get drawerChat;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @homeSliderDescOne.
  ///
  /// In en, this message translates to:
  /// **'Powered by the\n*GEM\nCollection*.'**
  String get homeSliderDescOne;

  /// No description provided for @homeSliderDescTwo.
  ///
  /// In en, this message translates to:
  /// **'Our AI model is\ncurrently\ndedicated to the\n*Grand Egyptian\nMuseum *artifacts.'**
  String get homeSliderDescTwo;

  /// No description provided for @homeScanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Artifacts & Decode\nHieroglyphs'**
  String get homeScanButton;

  /// No description provided for @homeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Egyptian\nhistory & Eras'**
  String get homeHistoryTitle;

  /// No description provided for @homeMythologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mythology &\nGods'**
  String get homeMythologyTitle;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Egyptian history & Eras'**
  String get discoverHistoryTitle;

  /// No description provided for @discoverMythologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mythology & Gods'**
  String get discoverMythologyTitle;

  /// No description provided for @discoverHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Explore Dynasties'**
  String get discoverHistoryButton;

  /// No description provided for @discoverMythologyButton.
  ///
  /// In en, this message translates to:
  /// **'Enter The Pantheon'**
  String get discoverMythologyButton;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showless.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showless;

  /// No description provided for @era1Title.
  ///
  /// In en, this message translates to:
  /// **'Pre-Dynastic and Early Dynastic Period'**
  String get era1Title;

  /// No description provided for @era1Desc.
  ///
  /// In en, this message translates to:
  /// **'Predynastic & Early Dynastic Period (c. 3200 – 2686 BC)\nThe story of civilization began when the inhabitants of the Nile Valley gathered in two main centers: the Delta region (Kingdom of the North) and the city of \"Hierakonpolis\" in Upper Egypt (Kingdom of the South). From the South emerged Narmer (Menes), the last king of the Predynastic period, who invaded the North to unify the country for the first time around 3150 BC. Narmer recorded this great victory on the \"Narmer Palette,\" where he appears wearing the crown of the South on one side and the crown of the North on the other, establishing the First Dynasty. To ensure central control and manage the emerging bureaucracy, he founded the capital \"Memphis.\" He was succeeded by King \"Hor-Aha,\" and the Second Dynasty continued to consolidate the pillars of the state.'**
  String get era1Desc;

  /// No description provided for @era2Title.
  ///
  /// In en, this message translates to:
  /// **'Old Kingdom'**
  String get era2Title;

  /// No description provided for @era2Desc.
  ///
  /// In en, this message translates to:
  /// **'The Age of Pyramid Builders (2686 – 2181 BC)\nThe Third Dynasty witnessed an architectural leap, where King Djoser and his architect Imhotep built the first giant stone structure in history (the Step Pyramid of Saqqara). With the advent of the Fourth Dynasty, Sneferu established true pyramids in Meidum and Dahshur. Then came his son Khufu to build the Great Pyramid at Giza, which remained the tallest building in the world for millennia, constructed by Egyptian workers—who worked in exchange for tax exemptions and food, not as slaves. In the Fifth Dynasty, Userkaf focused on building sun temples in Abusir. However, by the end of the Sixth Dynasty, royal prestige began to dwindle, and the trend of independence grew among provincial governors.'**
  String get era2Desc;

  /// No description provided for @era3Title.
  ///
  /// In en, this message translates to:
  /// **'First Intermediate Period'**
  String get era3Title;

  /// No description provided for @era3Desc.
  ///
  /// In en, this message translates to:
  /// **'First Intermediate Period (2181 – 2055 BC)\nAfter the collapse of the Old Kingdom, Egypt entered a dark tunnel where central authority completely receded. Chaos and political instability prevailed, to the point where the era was described by phrases indicating the abundance of kings and their short reigns (Dynasties 9 to 11), leading to widespread social anxiety.'**
  String get era3Desc;

  /// No description provided for @era4Title.
  ///
  /// In en, this message translates to:
  /// **'Middle Kingdom'**
  String get era4Title;

  /// No description provided for @era4Desc.
  ///
  /// In en, this message translates to:
  /// **'The Age of Prosperity (2055 – 1650 BC)\nUnity returned to Egyptian lands with the dawn of the Eleventh Dynasty at the hands of the princes of Thebes. King Mentuhotep II managed to reunify the country and built his mortuary temple at Deir el-Bahari. The Twelfth Dynasty witnessed stability and prosperity, where kings like Amenemhat I and Senusret II undertook irrigation projects and built relatively smaller pyramids (compared to the Old Kingdom) in Lisht, Lahun, and Hawara in Faiyum'**
  String get era4Desc;

  /// No description provided for @era5Title.
  ///
  /// In en, this message translates to:
  /// **'Second Intermediate Period'**
  String get era5Title;

  /// No description provided for @era5Desc.
  ///
  /// In en, this message translates to:
  /// **'The Hyksos Invasion (1650 – 1550 BC)\nRoyal authority retreated again, allowing the \"Hyksos\" (nomadic pastoral tribes) to exploit this weakness and dominate northern Egypt and the Delta using war chariots. The Hyksos established their capital in \"Avaris,\" while native Egyptian rule was confined to the South, during a period Egyptians did not tend to document much due to the bitterness of defeat.'**
  String get era5Desc;

  /// No description provided for @era6Title.
  ///
  /// In en, this message translates to:
  /// **'New Kingdom'**
  String get era6Title;

  /// No description provided for @era6Desc.
  ///
  /// In en, this message translates to:
  /// **'The Age of Empire (1550 – 1069 BC)\nThis glorious era began with King Ahmose expelling the Hyksos and founding the Eighteenth Dynasty.Egypt expanded militarily; Thutmose I invaded Nubia, and Thutmose III (the Napoleon of ancient times) led campaigns reaching the Euphrates River in Syria.Queen Hatshepsut rose to prominence, building the Deir el-Bahari temple; her reign was marked by construction and prosperity.A religious and artistic revolution occurred when Amenhotep IV (Akhenaten) replaced the old gods with the worship of \"Aten\" and moved the capital to \"Tell el-Amarna.\" However, his son Tutankhamun returned the capital to Thebes and restored the old religion.In the Nineteenth Dynasty, Seti I and later his son Ramesses II faced the Hittite forces. The conflict ended with the Battle of Kadesh and the first peace treaty in history. Ramesses built massive monuments (Abu Simbel).The empire\'s glory ended with Ramesses III (Twentieth Dynasty), who repelled the \"Sea Peoples,\" followed by a decline under the Ramesside kings.'**
  String get era6Desc;

  /// No description provided for @era7Title.
  ///
  /// In en, this message translates to:
  /// **'Third Intermediate Period'**
  String get era7Title;

  /// No description provided for @era7Desc.
  ///
  /// In en, this message translates to:
  /// **'Third Intermediate Period (1069 – 664 BC)\nEgypt became politically divided; a new dynasty ruled from \"Tanis\" in the Delta, while the High Priests of Amun controlled Thebes in the South. The country fragmented into small states, paving the way for the rulers of Kush (Nubians) to control Upper Egypt, invade Memphis, and establish the Twenty-Fifth Dynasty.'**
  String get era7Desc;

  /// No description provided for @era8Title.
  ///
  /// In en, this message translates to:
  /// **'Late Period'**
  String get era8Title;

  /// No description provided for @era8Desc.
  ///
  /// In en, this message translates to:
  /// **'Late Period (664 – 332 BC)\nDespite constant wars, this period saw flashes of a cultural renaissance (Twenty-Sixth Dynasty). Egypt faced Assyrian invasion, then the Thirtieth Dynasty returned as the last native Egyptian dynasty led by Nectanebo I and Nectanebo II, who built temples at Philae. Native rule ended permanently after Nectanebo II was defeated by the Persians at the Battle of Pelusium (343 BC), making Egypt a Persian province for the second time.'**
  String get era8Desc;

  /// No description provided for @era9Title.
  ///
  /// In en, this message translates to:
  /// **'Greek and Roman Periods'**
  String get era9Title;

  /// No description provided for @era9Desc.
  ///
  /// In en, this message translates to:
  /// **'Greek and Roman Periods (332 BC – 30 BC)\nIn 332 BC, Alexander the Great entered Egypt, ending Persian rule. After his death, Ptolemy I founded the Ptolemaic Kingdom. Ptolemaic rule continued until the era of Cleopatra VII, who engaged in a throne struggle that ended with the arrival of Julius Caesar, and later Octavian (Augustus). Octavian defeated her and captured Alexandria in 30 BC, officially turning Egypt into a Roman province, marking the gradual fading of the ancient Egyptian language and culture.'**
  String get era9Desc;

  /// No description provided for @god1Title.
  ///
  /// In en, this message translates to:
  /// **'The Chronicles of the Nile:\nFrom Chaos to Order'**
  String get god1Title;

  /// No description provided for @god1Desc.
  ///
  /// In en, this message translates to:
  /// **'I. The Dawn of Light\nIn the beginning, before time began, there was only Nun, a chaotic, infinite ocean of dark water. From the depths of this abyss, a great pyramidal mound rose, and upon its peak sat a lotus flower. As the petals blossomed, they revealed a blinding brilliance that banished the darkness. This was Ra, the Sun God and the source of all life.\n\nLonely in his magnificence, Ra begat the first generation of gods: Shu (Air) and Tefnut (Rain). But the universe was vast and watery, and his children became lost in the dark currents. Distressed, Ra sent his eye, in the form of the goddess Hathor, to find them. When they returned, Ra wept tears of pure joy. As these divine tears hit the earth, they transformed into the first human beings.\n\nRa, the first Pharaoh, ruled over a golden age. He gifted humanity the River Nile, the heartbeat of existence. However, as eons passed, Ra grew old. Humanity, seeing his fading strength, rebelled. In anger, Ra unleashed the lioness Sekhmet to punish them, nearly wiping out mankind in a flood of blood before Ra showed mercy. Weary of the mortal world, Ra ascended to the heavens. Each day he sailed the sky in his solar barque, and each night he descended into the Underworld to battle the chaos serpent, Apep, ensuring the sun would rise again.\n\nII. The Golden Age of Osiris\nWith Ra in the heavens, the rule of the earth passed to his grandchildren: Osiris and Isis, and Set and Nephthys.\n\nOsiris sat upon the throne of Egypt, a benevolent and wise king. He brought civilization to humanity, teaching them to weave, bake bread, establish laws, and farm the land. Under his rule, peace flourished. However, in the shadows lurked his brother, Set.\n\nWhile Osiris ruled the fertile valley, Set was lord of the arid, burning deserts. Jealousy rotted Set’s heart—not only of his brother\'s power but of the secret affair Osiris had with Set’s wife, Nephthys, which produced Anubis, the jackal-headed god.\n\nIII. The Treacherous Feast\nConsumed by envy, Set plotted a dark revenge. He threw a lavish feast in Osiris\'s honor. In the center of the hall, he displayed a magnificent coffin, crafted from cedar and gold. \"This chest,\" Set announced with a wicked smile, \"belongs to whomever fits inside it perfectly.\"\n\nOne by one, the guests tried, but it was a trap designed only for the King. When Osiris lay down within it, Set and his conspirators slammed the lid shut, sealed it with molten lead, and cast it into the Nile. The benevolent King drowned, and the age of innocence ended.\n\nIsis, consumed by grief, searched the world for her husband. She found him, but the malicious Set stole the body and hacked it into 14 pieces, scattering them across Egypt. With the help of Anubis, Isis recovered the pieces (save for one) and performed the first rites of mummification. Osiris was resurrected, but he could no longer dwell in the land of the living. He descended to become the Lord of the Dead, leaving the throne of Egypt empty.\n\nIV. The War of Uncle and Nephew\nSet seized the throne, plunging Egypt into a reign of terror and darkness. But Isis had borne a son from her resurrected husband: Horus, the Falcon God.\n\nHidden away in the marshes until he came of age, Horus eventually stepped forward to reclaim his birthright. He challenged his uncle, initiating a war that would last 80 years. The conflict was brutal. In their battles, they transformed into hippopotamuses to see who could stay submerged longest; they fought in the skies and the sands. At one point, Set tore out Horus’s eye (which was restored by Hathor), and Horus humiliated Set by tricking him into consuming his divine seed hidden in lettuce.\n\nThe tribunal of the Gods, presided over by Ra, grew tired of the chaos. Though Ra initially favored Set for his strength in protecting the solar barge from the serpent Apep, the justice of Horus’s claim could not be denied.\n\nV. The Balance: The Black Land and The Red Land\nFinally, the gods issued their verdict. Horus was crowned the rightful King, avenging his father.\nHowever, the Egyptian worldview was built on Ma\'at—balance. Total destruction of one side was not the way of the cosmos. The world was divided between the two powerful gods:\n\nHorus was given dominion over Kemet, the \"Black Land.\" This was the fertile soil along the Nile banks where crops grew, civilization thrived, and the people lived. He represented order, growth, and the heart of Egypt.\n\nSet was not destroyed but was given dominion over the Deserts, the \"Red Land.\" While harsh, his strength was necessary. He became the fierce protector of Egypt\'s borders, guarding the kingdom against foreign invaders and continuing to ride on Ra’s boat to slay the chaos serpent Apep every night.\n\nVI. The Coronation\nFrom that day forward, the Pharaohs of Egypt were seen as the living embodiment of Horus. Yet, they acknowledged the necessity of Set\'s strength.\n\nIn a final act of cosmic harmony, it was established that both Horus and Set would symbolically crown every new Pharaoh. In the coronation rituals depicted on temple walls, the Falcon and the Beast stand on either side of the new King, placing the crown upon his head together. This symbolized that a true ruler must master both the fertile peace of the Black Land and the fierce, chaotic power of the Red Land to keep Egypt sovereign and strong.'**
  String get god1Desc;

  /// No description provided for @god2Title.
  ///
  /// In en, this message translates to:
  /// **'Atum'**
  String get god2Title;

  /// No description provided for @god2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Creator'**
  String get god2Subtitle;

  /// No description provided for @god2Desc.
  ///
  /// In en, this message translates to:
  /// **'In the beginning of time, there was only Nun, the primeval waters of chaos. From a great flood within these waters, the sun god Atum rose and willed himself into creation. He created the first divine pair: Shu (air) and Tefnut (moisture). They, in turn, gave birth to Geb (earth) and Nut (sky), who produced the four siblings: Osiris, Isis, Seth, and Nephthys, completing the divine group known as the Ennead.'**
  String get god2Desc;

  /// No description provided for @god3Title.
  ///
  /// In en, this message translates to:
  /// **'Osiris'**
  String get god3Title;

  /// No description provided for @god3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'King of the Dead'**
  String get god3Subtitle;

  /// No description provided for @god3Desc.
  ///
  /// In en, this message translates to:
  /// **'Osiris was a beloved king who ruled Egypt with his sister-wife Isis during an unprecedented time of peace and prosperity. However, his jealous brother Seth murdered him, dismembered his body, and scattered the pieces across the land. After Isis recovered his body, Osiris was resurrected but was too weak to remain in the world of the living. He traveled to the Duat (the Underworld) to become the Lord of the Dead. There, he presides over the final judgment, evaluating whether souls are worthy to enter the afterlife.'**
  String get god3Desc;

  /// No description provided for @god4Title.
  ///
  /// In en, this message translates to:
  /// **'Isis'**
  String get god4Title;

  /// No description provided for @god4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Great Mother and Magician'**
  String get god4Subtitle;

  /// No description provided for @god4Desc.
  ///
  /// In en, this message translates to:
  /// **'Considered Egypt’s most important goddess, Isis was the wife of Osiris and mother of Horus. After her husband\'s murder, she searched for his scattered pieces and, with the help of Anubis and Thoth, reconstructed him to create the first mummy. She fled to hide her son Horus from Seth, raising him in secret. Isis was renowned for her powerful magic, which she used to heal the people and protect the kingdom. Her magic was so potent that she once created a snake to bite Ra, forcing him to reveal his secret name to be healed, which greatly enhanced her power.'**
  String get god4Desc;

  /// No description provided for @god5Title.
  ///
  /// In en, this message translates to:
  /// **'Seth'**
  String get god5Title;

  /// No description provided for @god5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'God of Chaos and the Desert'**
  String get god5Subtitle;

  /// No description provided for @god5Desc.
  ///
  /// In en, this message translates to:
  /// **'Known as \"The Red One,\" Seth personified anger, violence, and the arid desert (\"Red Land\") that threatened life. He murdered his brother Osiris to usurp the throne, leading to a violent conflict with his nephew Horus. Despite being the antagonist and representing civil unrest and foreign invasion, Seth played a crucial role in the cosmic order. Every night, he traveled on Ra’s solar barge through the underworld, being the only god capable of repelling the serpent Apophis with his spear to protect the sun.'**
  String get god5Desc;

  /// No description provided for @god6Title.
  ///
  /// In en, this message translates to:
  /// **'Horus'**
  String get god6Title;

  /// No description provided for @god6Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Falcon King'**
  String get god6Subtitle;

  /// No description provided for @god6Desc.
  ///
  /// In en, this message translates to:
  /// **'The son of Isis and Osiris, Horus is the god of kingship. He was raised in hiding until he was old enough to challenge his uncle Seth. After a violent contest and a divine legal trial presided over by Geb, Horus was declared the rightful king of Egypt. Pharaohs were believed to be the living embodiment of Horus. He was imagined as a cosmic falcon: his right eye was the sun, his left eye was the moon, and the downsweep of his wings produced the winds.'**
  String get god6Desc;

  /// No description provided for @god7Title.
  ///
  /// In en, this message translates to:
  /// **'Ra'**
  String get god7Title;

  /// No description provided for @god7Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Sun God'**
  String get god7Subtitle;

  /// No description provided for @god7Desc.
  ///
  /// In en, this message translates to:
  /// **'Ra was the foremost of the gods, his body thought to be the sun itself. He created man from his tears. He ruled as the first King on earth until he grew old and ascended to the heavens on the back of the sky goddess Nut. Ra undergoes a daily cycle:\nKhepri: The scarab beetle, rolling the sun up at dawn.\nRa: The midday sun sailing across the sky.\nAtum: The setting sun. At night, he travels through the underworld, battling the serpent Apophis to be reborn again at dawn.'**
  String get god7Desc;

  /// No description provided for @god8Title.
  ///
  /// In en, this message translates to:
  /// **'Amun'**
  String get god8Title;

  /// No description provided for @god8Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Hidden One'**
  String get god8Subtitle;

  /// No description provided for @god8Desc.
  ///
  /// In en, this message translates to:
  /// **'Amun was the invisible force behind all things. Unlike other gods linked to specific elements, Amun was a universal god. Throughout history, he absorbed other gods, most notably merging with Ra to become Amun-Ra. In this form, he became the King of the Gods and the chief deity of Egypt.'**
  String get god8Desc;

  /// No description provided for @god9Title.
  ///
  /// In en, this message translates to:
  /// **'Anubis'**
  String get god9Title;

  /// No description provided for @god9Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian of the Tombs'**
  String get god9Subtitle;

  /// No description provided for @god9Desc.
  ///
  /// In en, this message translates to:
  /// **'The jackal-headed god of embalming. He helped Isis wrap Osiris, creating the first mummy. Anubis watched over tombs, punished grave robbers, and supervised the embalming rituals. In the afterlife, he plays a key role in the Hall of Ma\'at. He operates the scales, weighing the heart of the deceased against the \"Feather of Truth.\" If the heart was pure, the soul passed to Osiris; if it was heavy with sin, it was devoured by the monster Ammit.'**
  String get god9Desc;

  /// No description provided for @god10Title.
  ///
  /// In en, this message translates to:
  /// **'Thoth'**
  String get god10Title;

  /// No description provided for @god10Subtitle.
  ///
  /// In en, this message translates to:
  /// **'God of Wisdom and Writing'**
  String get god10Subtitle;

  /// No description provided for @god10Desc.
  ///
  /// In en, this message translates to:
  /// **'A moon god of writing, knowledge, and balance. Some myths say he was born from the forehead of Seth. Thoth healed Horus’s eye after it was injured in battle. He invented the art of writing and served as the scribe of the gods, recording divine words and the reigns of Pharaohs. In the Hall of Judgment, he stands by the scales to record the verdict of the weighing of the heart.'**
  String get god10Desc;

  /// No description provided for @god11Title.
  ///
  /// In en, this message translates to:
  /// **'Ptah'**
  String get god11Title;

  /// No description provided for @god11Subtitle.
  ///
  /// In en, this message translates to:
  /// **'The Craftsman Creator'**
  String get god11Subtitle;

  /// No description provided for @god11Desc.
  ///
  /// In en, this message translates to:
  /// **'The patron god of Memphis and craftsmen. The theology of Memphis held that Ptah was the creator of the world, bringing the universe into existence through thought and speech (dreaming it in his heart and speaking it with his tongue). He was seen as a sculptor who formed the earth on a potter\'s wheel.'**
  String get god11Desc;

  /// No description provided for @god12Title.
  ///
  /// In en, this message translates to:
  /// **'Sekhmet'**
  String get god12Title;

  /// No description provided for @god12Desc.
  ///
  /// In en, this message translates to:
  /// **'The lioness of war and fire. Ra sent her to punish rebellious humans, and her wrath was so great she nearly wiped out humanity.'**
  String get god12Desc;

  /// No description provided for @god13Title.
  ///
  /// In en, this message translates to:
  /// **'Bastet'**
  String get god13Title;

  /// No description provided for @god13Desc.
  ///
  /// In en, this message translates to:
  /// **'Originally a lioness, she later became the cat goddess. She protected pregnant women and the Pharaoh, while still helping Ra fight Apophis.'**
  String get god13Desc;

  /// No description provided for @god14Title.
  ///
  /// In en, this message translates to:
  /// **'Hathor'**
  String get god14Title;

  /// No description provided for @god14Desc.
  ///
  /// In en, this message translates to:
  /// **'The cow goddess of love, motherhood, and music. She welcomed the dead into the afterlife.'**
  String get god14Desc;

  /// No description provided for @god15Title.
  ///
  /// In en, this message translates to:
  /// **'Neith'**
  String get god15Title;

  /// No description provided for @god15Desc.
  ///
  /// In en, this message translates to:
  /// **'A warrior and mother goddess (mother of the crocodile god Sobek). She was a master archer and creator figure.'**
  String get god15Desc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get settingsAppPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLightMood.
  ///
  /// In en, this message translates to:
  /// **'Light Mood'**
  String get settingsLightMood;

  /// No description provided for @settingsCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get settingsCameraPermission;

  /// No description provided for @settingsSupportAbout.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get settingsSupportAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Echo'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where ancient whispers find a modern voice'**
  String get aboutSubtitle;

  /// No description provided for @aboutPhilosophyTitle.
  ///
  /// In en, this message translates to:
  /// **'The Philosophy of Echo'**
  String get aboutPhilosophyTitle;

  /// No description provided for @aboutPhilosophyBody.
  ///
  /// In en, this message translates to:
  /// **'History is more than just dates and dusty stones; it is the heartbeat of a civilization that refused to be forgotten. For thousands of years, the stories of our ancestors have existed as \"whispers\" carved into temple walls and whispered through the halls of our museums.\n\nEcho was born from a simple yet profound mission: to give those whispers a modern voice.\n\nWe believe that to truly understand an artifact, one must look beyond its physical form and delve into the spirit of its creators: their sacred mythology, their rhythmic language, and the timeless beliefs that shaped the world.'**
  String get aboutPhilosophyBody;

  /// No description provided for @aboutMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'More Than Just an App'**
  String get aboutMoreTitle;

  /// No description provided for @aboutMoreBody.
  ///
  /// In en, this message translates to:
  /// **'Our journey was not just about writing code; it was about rediscovering the Egyptian soul. We have meticulously gathered the threads of our heritage to offer you a deeper connection to the past:\n\n• The Wisdom of Mythology: Exploring the stories of the gods and the philosophy of the afterlife.\n• The Power of Language: Bridging the gap between ancient inscriptions and modern understanding.\n• The Depth of History: Uncovering the human stories behind every statue and monument.'**
  String get aboutMoreBody;

  /// No description provided for @aboutBridgeTitle.
  ///
  /// In en, this message translates to:
  /// **'The Bridge to Tomorrow'**
  String get aboutBridgeTitle;

  /// No description provided for @aboutBridgeBody.
  ///
  /// In en, this message translates to:
  /// **'While our hearts are rooted in the ancient world, our tools are forged in the modern era. We use technology as a bridge not to replace history, but to illuminate it. By combining advanced AI and interactive design, we allow the past to speak once again, ensuring that the legacy of Egypt continues to resonate with future generations.'**
  String get aboutBridgeBody;

  /// No description provided for @aboutTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get aboutTeamTitle;

  /// No description provided for @aboutTeamBody.
  ///
  /// In en, this message translates to:
  /// **'We are a team of senior students from the Faculty of Computers and Information, Tanta University, dedicated to preserving our heritage through innovation.'**
  String get aboutTeamBody;

  /// No description provided for @profileFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get profileFavorite;

  /// No description provided for @profileScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get profileScan;

  /// No description provided for @profileAuthMessage.
  ///
  /// In en, this message translates to:
  /// **'Log in or sign up to have a Profile'**
  String get profileAuthMessage;

  /// No description provided for @profileNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get profileNoFavorites;

  /// No description provided for @profileNoScans.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get profileNoScans;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileName;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSave;

  /// No description provided for @editProfileChangeCover.
  ///
  /// In en, this message translates to:
  /// **'Change Cover'**
  String get editProfileChangeCover;

  /// No description provided for @editProfileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get editProfileChangeAvatar;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authSubtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get authSubtitleDefault;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerNameHint;

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhoneHint;

  /// No description provided for @registerLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get registerLanguageHint;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogle;

  /// No description provided for @authApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authApple;

  /// No description provided for @authMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Continue with Microsoft'**
  String get authMicrosoft;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get authPhone;

  /// No description provided for @authGuestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t want all the benefits of an account?'**
  String get authGuestPrompt;

  /// No description provided for @authContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get authContinueGuest;

  /// No description provided for @authStayLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Stay logged out'**
  String get authStayLoggedOut;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordTooShort;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @socialComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Social login is coming soon!'**
  String get socialComingSoon;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Artifacts & Decode Hieroglyphs'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of any ancient Egyptian artifact to identify it and translate its hieroglyphs.'**
  String get scanSubtitle;

  /// No description provided for @scanTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get scanTakePhoto;

  /// No description provided for @scanPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get scanPickGallery;

  /// No description provided for @scanAnalyzeArtifact.
  ///
  /// In en, this message translates to:
  /// **'Analyze Artifact'**
  String get scanAnalyzeArtifact;

  /// No description provided for @scanDifferentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Different Photo'**
  String get scanDifferentPhoto;

  /// No description provided for @scanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your artifact...'**
  String get scanAnalyzing;

  /// No description provided for @scanAnalyzingWait.
  ///
  /// In en, this message translates to:
  /// **'This may take up to a minute'**
  String get scanAnalyzingWait;

  /// No description provided for @scanSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Save to Favorites'**
  String get scanSaveFavorites;

  /// No description provided for @scanRemoveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get scanRemoveFavorites;

  /// No description provided for @scanNewScan.
  ///
  /// In en, this message translates to:
  /// **'New Scan'**
  String get scanNewScan;

  /// No description provided for @scanChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get scanChat;

  /// No description provided for @scanHieroglyphs.
  ///
  /// In en, this message translates to:
  /// **'Hieroglyphs'**
  String get scanHieroglyphs;

  /// No description provided for @scanAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites!'**
  String get scanAddedToFavorites;

  /// No description provided for @scanRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get scanRemovedFromFavorites;

  /// No description provided for @scanFavorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get scanFavorited;

  /// No description provided for @scanSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get scanSave;

  /// No description provided for @scanNoHieroglyphs.
  ///
  /// In en, this message translates to:
  /// **'No hieroglyphs detected in this artifact.'**
  String get scanNoHieroglyphs;

  /// No description provided for @scanNoArtifactFound.
  ///
  /// In en, this message translates to:
  /// **'No artifact could be recognized in this image.'**
  String get scanNoArtifactFound;

  /// No description provided for @scanHieroglyphsTranslation.
  ///
  /// In en, this message translates to:
  /// **'Hieroglyphs Translation'**
  String get scanHieroglyphsTranslation;

  /// No description provided for @scanDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get scanDetails;

  /// No description provided for @scanRevealTranslation.
  ///
  /// In en, this message translates to:
  /// **'Reveal Translation'**
  String get scanRevealTranslation;

  /// No description provided for @scanHideTranslation.
  ///
  /// In en, this message translates to:
  /// **'Hide Translation'**
  String get scanHideTranslation;

  /// No description provided for @scanLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get scanLanguage;

  /// No description provided for @scanNoArtifactRecognized.
  ///
  /// In en, this message translates to:
  /// **'No artifact recognized in this image.'**
  String get scanNoArtifactRecognized;

  /// No description provided for @scanRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get scanRescan;

  /// No description provided for @scanTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get scanTryAgain;

  /// No description provided for @scanStatLines.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 line} other{{count} lines}}'**
  String scanStatLines(int count);

  /// No description provided for @scanStatGlyphs.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 glyph} other{{count} glyphs}}'**
  String scanStatGlyphs(int count);

  /// No description provided for @scanStatCartouches.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 cartouche} other{{count} cartouches}}'**
  String scanStatCartouches(int count);

  /// No description provided for @scanStep1.
  ///
  /// In en, this message translates to:
  /// **'Initializing Neural Scan...'**
  String get scanStep1;

  /// No description provided for @scanStep2.
  ///
  /// In en, this message translates to:
  /// **'Isolating Glyphic Regions...'**
  String get scanStep2;

  /// No description provided for @scanStep3.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Contrast Gradients...'**
  String get scanStep3;

  /// No description provided for @scanStep4.
  ///
  /// In en, this message translates to:
  /// **'Decrypting Hieroglyphic Forms...'**
  String get scanStep4;

  /// No description provided for @scanStep5.
  ///
  /// In en, this message translates to:
  /// **'Translating Ancient Meanings...'**
  String get scanStep5;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @detailsAboutThisArtifact.
  ///
  /// In en, this message translates to:
  /// **'About This Artifact'**
  String get detailsAboutThisArtifact;

  /// No description provided for @detailsRevealTranslation.
  ///
  /// In en, this message translates to:
  /// **'Reveal Translation'**
  String get detailsRevealTranslation;

  /// No description provided for @detailsHideTranslation.
  ///
  /// In en, this message translates to:
  /// **'Hide Translation'**
  String get detailsHideTranslation;

  /// No description provided for @detailsTranslationReveals.
  ///
  /// In en, this message translates to:
  /// **'Discover what the translation reveals…'**
  String get detailsTranslationReveals;

  /// No description provided for @detailsUnknownArtifact.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artifact'**
  String get detailsUnknownArtifact;

  /// No description provided for @detailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailsDescription;

  /// No description provided for @detailsChatWithMe.
  ///
  /// In en, this message translates to:
  /// **'chat with me'**
  String get detailsChatWithMe;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternet;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get errorServerError;

  /// No description provided for @errorStorageError.
  ///
  /// In en, this message translates to:
  /// **'Storage error occurred'**
  String get errorStorageError;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnexpected;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get errorTimeout;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again'**
  String get errorSessionExpired;

  /// No description provided for @errorResourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get errorResourceNotFound;

  /// No description provided for @errorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get errorRequestFailed;

  /// No description provided for @errorRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled'**
  String get errorRequestCancelled;

  /// No description provided for @errorSecurityError.
  ///
  /// In en, this message translates to:
  /// **'Security error occurred'**
  String get errorSecurityError;

  /// No description provided for @chatHintMessage.
  ///
  /// In en, this message translates to:
  /// **'message...'**
  String get chatHintMessage;

  /// No description provided for @chatWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask me about Ancient Egypt...'**
  String get chatWelcomeMessage;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chatSearchHint;

  /// No description provided for @chatNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get chatNewChat;

  /// No description provided for @chatDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get chatDeleteConfirm;

  /// No description provided for @chatDeleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will delete all messages in this session.'**
  String get chatDeleteConfirmDesc;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for'**
  String get noRouteDefined;

  /// No description provided for @updatingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Updating language...'**
  String get updatingLanguage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileUnknownArtifact.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artifact'**
  String get profileUnknownArtifact;

  /// No description provided for @profileUnknownEra.
  ///
  /// In en, this message translates to:
  /// **'Unknown Era'**
  String get profileUnknownEra;

  /// No description provided for @profileStartScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get profileStartScanning;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoJustNow;

  /// Time ago in minutes
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1m ago} other{{count}m ago}}'**
  String timeAgoMinute(int count);

  /// Time ago in hours
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1h ago} other{{count}h ago}}'**
  String timeAgoHour(int count);

  /// Time ago in days
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1d ago} other{{count}d ago}}'**
  String timeAgoDay(int count);

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @scanCouldNotIdentify.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t identify the image'**
  String get scanCouldNotIdentify;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
