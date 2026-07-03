import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case persian = "fa"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .persian: return "فارسی"
        }
    }

    var layoutDirection: LayoutDirection {
        self == .persian ? .rightToLeft : .leftToRight
    }

    var nativeGreeting: String {
        switch self {
        case .english: return "Welcome"
        case .persian: return "خوش آمدید"
        }
    }
}

struct L10n {
    let language: AppLanguage

    var appTitle: String {
        switch language {
        case .english: return "DNS Switcher"
        case .persian: return "تغییر DNS"
        }
    }

    var appSubtitle: String {
        switch language {
        case .english: return "Manage your Mac DNS settings with one click"
        case .persian: return "تنظیمات DNS مک خود را با یک کلیک مدیریت کنید"
        }
    }

    var network: String {
        switch language {
        case .english: return "Network"
        case .persian: return "شبکه"
        }
    }

    var networkPicker: String {
        switch language {
        case .english: return "Network service"
        case .persian: return "سرویس شبکه"
        }
    }

    var currentDNS: String {
        switch language {
        case .english: return "Current DNS"
        case .persian: return "DNS فعلی"
        }
    }

    var automaticDHCP: String {
        switch language {
        case .english: return "Automatic (DHCP)"
        case .persian: return "خودکار (DHCP)"
        }
    }

    var statusAutomatic: String {
        switch language {
        case .english: return "Automatic"
        case .persian: return "خودکار"
        }
    }

    var statusCustom: String {
        switch language {
        case .english: return "Custom"
        case .persian: return "سفارشی"
        }
    }

    var statusOther: String {
        switch language {
        case .english: return "Other"
        case .persian: return "سایر"
        }
    }

    var statusActive: String {
        switch language {
        case .english: return "Active"
        case .persian: return "فعال"
        }
    }

    func statusMatched(_ preset: DNSPreset) -> String {
        switch language {
        case .english: return preset.englishName
        case .persian: return preset.persianName
        }
    }

    func statusMatchedProfile(_ profile: DNSProfile) -> String {
        profile.name
    }

    var savedProfiles: String {
        switch language {
        case .english: return "Saved Profiles"
        case .persian: return "پروفایل‌های ذخیره‌شده"
        }
    }

    var addProfile: String {
        switch language {
        case .english: return "Add Profile"
        case .persian: return "افزودن پروفایل"
        }
    }

    var editProfile: String {
        switch language {
        case .english: return "Edit Profile"
        case .persian: return "ویرایش پروفایل"
        }
    }

    var deleteProfile: String {
        switch language {
        case .english: return "Delete Profile"
        case .persian: return "حذف پروفایل"
        }
    }

    var profileName: String {
        switch language {
        case .english: return "Profile name"
        case .persian: return "نام پروفایل"
        }
    }

    var profileNamePlaceholder: String {
        switch language {
        case .english: return "Work, Home, Gaming…"
        case .persian: return "کار، خانه، بازی…"
        }
    }

    var saveProfile: String {
        switch language {
        case .english: return "Save Profile"
        case .persian: return "ذخیره پروفایل"
        }
    }

    var saveAsProfile: String {
        switch language {
        case .english: return "Save as Profile"
        case .persian: return "ذخیره به‌عنوان پروفایل"
        }
    }

    var noSavedProfiles: String {
        switch language {
        case .english: return "Save your favorite DNS setups for quick access."
        case .persian: return "تنظیمات DNS مورد علاقه خود را برای دسترسی سریع ذخیره کنید."
        }
    }

    var cancel: String {
        switch language {
        case .english: return "Cancel"
        case .persian: return "لغو"
        }
    }

    var save: String {
        switch language {
        case .english: return "Save"
        case .persian: return "ذخیره"
        }
    }

    var invalidProfileName: String {
        switch language {
        case .english: return "Enter a profile name."
        case .persian: return "نام پروفایل را وارد کنید."
        }
    }

    var dnsPreset: String {
        switch language {
        case .english: return "DNS Preset"
        case .persian: return "پیش‌فرض DNS"
        }
    }

    var customDNS: String {
        switch language {
        case .english: return "Custom DNS"
        case .persian: return "DNS سفارشی"
        }
    }

    var primaryServer: String {
        switch language {
        case .english: return "Primary"
        case .persian: return "اصلی"
        }
    }

    var secondaryServer: String {
        switch language {
        case .english: return "Secondary"
        case .persian: return "ثانویه"
        }
    }

    var optional: String {
        switch language {
        case .english: return "optional"
        case .persian: return "اختیاری"
        }
    }

    var applyDNS: String {
        switch language {
        case .english: return "Apply DNS"
        case .persian: return "اعمال DNS"
        }
    }

    var resetAutomatic: String {
        switch language {
        case .english: return "Reset to Automatic"
        case .persian: return "بازگشت به خودکار"
        }
    }

    var openApp: String {
        switch language {
        case .english: return "Open DNS Switcher…"
        case .persian: return "باز کردن DNS Switcher…"
        }
    }

    var quitApp: String {
        switch language {
        case .english: return "Quit DNS Switcher"
        case .persian: return "خروج از DNS Switcher"
        }
    }

    var languageLabel: String {
        switch language {
        case .english: return "Language"
        case .persian: return "زبان"
        }
    }

    func dnsApplied(_ servers: [String]) -> String {
        switch language {
        case .english:
            return "DNS updated to \(servers.joined(separator: ", "))."
        case .persian:
            return "DNS به \(servers.joined(separator: "، ")) تغییر کرد."
        }
    }

    var dnsReset: String {
        switch language {
        case .english: return "DNS reset to automatic (DHCP)."
        case .persian: return "DNS به حالت خودکار (DHCP) بازگردانده شد."
        }
    }

    var invalidPrimary: String {
        switch language {
        case .english: return "Enter a valid primary DNS address."
        case .persian: return "آدرس DNS اصلی معتبر وارد کنید."
        }
    }

    var invalidSecondary: String {
        switch language {
        case .english: return "Secondary DNS address is not valid."
        case .persian: return "آدرس DNS ثانویه معتبر نیست."
        }
    }

    func presetDescription(_ preset: DNSPreset) -> String {
        switch language {
        case .english: return preset.englishDescription
        case .persian: return preset.persianDescription
        }
    }

    // MARK: - Onboarding

    var onboardingWelcome: String {
        switch language {
        case .english: return "Welcome to DNS Switcher"
        case .persian: return "به DNS Switcher خوش آمدید"
        }
    }

    var onboardingSubtitle: String {
        switch language {
        case .english: return "Switch DNS on your Mac in seconds. Pick a language to get started."
        case .persian: return "DNS مک خود را در چند ثانیه تغییر دهید. برای شروع زبان را انتخاب کنید."
        }
    }

    var chooseLanguage: String {
        switch language {
        case .english: return "Choose your language"
        case .persian: return "زبان خود را انتخاب کنید"
        }
    }

    var getStarted: String {
        switch language {
        case .english: return "Get Started"
        case .persian: return "شروع کنید"
        }
    }

    var onboardingFeature1Title: String {
        switch language {
        case .english: return "One-click switching"
        case .persian: return "تغییر با یک کلیک"
        }
    }

    var onboardingFeature1Desc: String {
        switch language {
        case .english: return "Apply trusted DNS presets instantly"
        case .persian: return "پیش‌فرض‌های DNS را فوراً اعمال کنید"
        }
    }

    var onboardingFeature2Title: String {
        switch language {
        case .english: return "Custom servers"
        case .persian: return "سرورهای سفارشی"
        }
    }

    var onboardingFeature2Desc: String {
        switch language {
        case .english: return "Use your own primary and secondary DNS"
        case .persian: return "DNS اصلی و ثانویه خود را وارد کنید"
        }
    }

    var onboardingFeature3Title: String {
        switch language {
        case .english: return "Bilingual interface"
        case .persian: return "رابط دو زبانه"
        }
    }

    var onboardingFeature3Desc: String {
        switch language {
        case .english: return "Full support for English and Persian"
        case .persian: return "پشتیبانی کامل از انگلیسی و فارسی"
        }
    }

    var onboardingFeature4Title: String {
        switch language {
        case .english: return "Saved profiles"
        case .persian: return "پروفایل‌های ذخیره‌شده"
        }
    }

    var onboardingFeature4Desc: String {
        switch language {
        case .english: return "Save and reuse your favorite DNS setups"
        case .persian: return "تنظیمات DNS مورد علاقه خود را ذخیره و دوباره استفاده کنید"
        }
    }
}
