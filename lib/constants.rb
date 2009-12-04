module Constants
  DEFAULT_LANGUAGE = 'English'
  VARCHAR = 255
  SHARED_ROOT = PRODUCTION ? '' : ''

  module Locales
    ALL = {
      "English" => "en",
      "中文 (Simplified)" => "cn",
      "中文 (Traditional)" => "cn_t",
      "日本語" => "jp",
      "Español" => "es"
    }

    CODES = ['cn', 'cn_t', 'en', 'es', 'jp']
    COUNTRY_TO_LOCALE = {
      'cn' => 'cn',
      'hk' => 'cn',
      'tw' => 'cn_t',
      'jp' => 'jp',
      'es' => 'es',
      'ar' => 'es',
      'bo' => 'es',
      'cl' => 'es',
      'co' => 'es',
      'cr' => 'es',
      'cu' => 'es',
      'do' => 'es',
      'ec' => 'es',
      'gt' => 'es',
      'hn' => 'es',
      'mx' => 'es',
      'ni' => 'es',
      'pa' => 'es',
      'pe' => 'es',
      'pr' => 'es',
      'py' => 'es',
      'sv' => 'es',
      'uy' => 'es',
      've' => 'es',
    }


    DEFAULT = 'en'
  end

  module Countries
    ALL = [
     ["Afghanistan", "AF"],
     ["Albania", "AL"],
     ["Algeria", "DZ"],
     ["American Samoa", "AS"],
     ["Andorra", "AD"],
     ["Angola", "AO"],
     ["Anguilla", "AI"],
     ["Antarctica", "AQ"],
     ["Antigua and Barbuda", "AG"],
     ["Argentina", "AR"],
     ["Armenia", "AM"],
     ["Aruba", "AW"],
     ["Australia", "AU"],
     ["Austria", "AT"],
     ["Azerbaijan", "AZ"],
     ["Bahamas", "BS"],
     ["Bahrain", "BH"],
     ["Bangladesh", "BD"],
     ["Barbados", "BB"],
     ["Belarus", "BY"],
     ["Belgium", "BE"],
     ["Belize", "BZ"],
     ["Benin", "BJ"],
     ["Bermuda", "BM"],
     ["Bhutan", "BT"],
     ["Bolivia", "BO"],
     ["Bosnia and Herzegovina", "BA"],
     ["Botswana", "BW"],
     ["Bouvet Island", "BV"],
     ["Brazil", "BR"],
     ["British Indian Ocean Territory", "IO"],
     ["Brunei Darussalam", "BN"],
     ["Bulgaria", "BG"],
     ["Burkina Faso", "BF"],
     ["Burundi", "BI"],
     ["Cambodia", "KH"],
     ["Cameroon", "CM"],
     ["Canada", "CA"],
     ["Cape Verde", "CV"],
     ["Cayman Islands", "KY"],
     ["Central African Republic", "CF"],
     ["Chad", "TD"],
     ["Chile", "CL"],
     ["China", "CN"],
     ["Christmas Island", "CX"],
     ["Cocos (Keeling) Islands", "CC"],
     ["Colombia", "CO"],
     ["Comoros", "KM"],
     ["Congo", "CG"],
     ["Cook Islands", "CK"],
     ["Costa Rica", "CR"],
     ["Cote D'Ivoire (Ivory Coast)", "CI"],
     ["Croatia (Hrvatska)", "HR"],
     ["Cuba", "CU"],
     ["Cyprus", "CY"],
     ["Czech Republic", "CZ"],
     ["Czechoslovakia (former)", "CS"],
     ["Denmark", "DK"],
     ["Djibouti", "DJ"],
     ["Dominica", "DM"],
     ["Dominican Republic", "DO"],
     ["East Timor", "TP"],
     ["Ecuador", "EC"],
     ["Egypt", "EG"],
     ["El Salvador", "SV"],
     ["Equatorial Guinea", "GQ"],
     ["Eritrea", "ER"],
     ["Estonia", "EE"],
     ["Ethiopia", "ET"],
     ["Falkland Islands (Malvinas)", "FK"],
     ["Faroe Islands", "FO"],
     ["Fiji", "FJ"],
     ["Finland", "FI"],
     ["France", "FR"],
     ["France, Metropolitan", "FX"],
     ["French Guiana", "GF"],
     ["French Polynesia", "PF"],
     ["French Southern Territories", "TF"],
     ["Gabon", "GA"],
     ["Gambia", "GM"],
     ["Georgia", "GE"],
     ["Germany", "DE"],
     ["Ghana", "GH"],
     ["Gibraltar", "GI"],
     ["Great Britain (UK)", "GB"],
     ["Greece", "GR"],
     ["Greenland", "GL"],
     ["Grenada", "GD"],
     ["Guadeloupe", "GP"],
     ["Guam", "GU"],
     ["Guatemala", "GT"],
     ["Guinea", "GN"],
     ["Guinea-Bissau", "GW"],
     ["Guyana", "GY"],
     ["Haiti", "HT"],
     ["Heard and McDonald Islands", "HM"],
     ["Honduras", "HN"],
     ["Hong Kong", "HK"],
     ["Hungary", "HU"],
     ["Iceland", "IS"],
     ["India", "IN"],
     ["Indonesia", "ID"],
     ["Iran", "IR"],
     ["Iraq", "IQ"],
     ["Ireland", "IE"],
     ["Israel", "IL"],
     ["Italy", "IT"],
     ["Jamaica", "JM"],
     ["Japan", "JP"],
     ["Jordan", "JO"],
     ["Kazakhstan", "KZ"],
     ["Kenya", "KE"],
     ["Kiribati", "KI"],
     ["Korea (North)", "KP"],
     ["Korea (South)", "KR"],
     ["Kuwait", "KW"],
     ["Kyrgyzstan", "KG"],
     ["Laos", "LA"],
     ["Latvia", "LV"],
     ["Lebanon", "LB"],
     ["Lesotho", "LS"],
     ["Liberia", "LR"],
     ["Libya", "LY"],
     ["Liechtenstein", "LI"],
     ["Lithuania", "LT"],
     ["Luxembourg", "LU"],
     ["Macau", "MO"],
     ["Macedonia", "MK"],
     ["Madagascar", "MG"],
     ["Malawi", "MW"],
     ["Malaysia", "MY"],
     ["Maldives", "MV"],
     ["Mali", "ML"],
     ["Malta", "MT"],
     ["Marshall Islands", "MH"],
     ["Martinique", "MQ"],
     ["Mauritania", "MR"],
     ["Mauritius", "MU"],
     ["Mayotte", "YT"],
     ["Mexico", "MX"],
     ["Micronesia", "FM"],
     ["Moldova", "MD"],
     ["Monaco", "MC"],
     ["Mongolia", "MN"],
     ["Montserrat", "MS"],
     ["Morocco", "MA"],
     ["Mozambique", "MZ"],
     ["Myanmar", "MM"],
     ["Namibia", "NA"],
     ["Nauru", "NR"],
     ["Nepal", "NP"],
     ["Netherlands", "NL"],
     ["Netherlands Antilles", "AN"],
     ["Neutral Zone", "NT"],
     ["New Caledonia", "NC"],
     ["New Zealand (Aotearoa)", "NZ"],
     ["Nicaragua", "NI"],
     ["Niger", "NE"],
     ["Nigeria", "NG"],
     ["Niue", "NU"],
     ["Norfolk Island", "NF"],
     ["Northern Mariana Islands", "MP"],
     ["Norway", "NO"],
     ["Oman", "OM"],
     ["Pakistan", "PK"],
     ["Palau", "PW"],
     ["Panama", "PA"],
     ["Papua New Guinea", "PG"],
     ["Paraguay", "PY"],
     ["Peru", "PE"],
     ["Philippines", "PH"],
     ["Pitcairn", "PN"],
     ["Poland", "PL"],
     ["Portugal", "PT"],
     ["Puerto Rico", "PR"],
     ["Qatar", "QA"],
     ["Reunion", "RE"],
     ["Romania", "RO"],
     ["Russian Federation", "RU"],
     ["Rwanda", "RW"],
     ["S. Georgia and S. Sandwich Isls.", "GS"],
     ["Saint Kitts and Nevis", "KN"],
     ["Saint Lucia", "LC"],
     ["Saint Vincent and the Grenadines", "VC"],
     ["Samoa", "WS"],
     ["San Marino", "SM"],
     ["Sao Tome and Principe", "ST"],
     ["Saudi Arabia", "SA"],
     ["Senegal", "SN"],
     ["Seychelles", "SC"],
     ["Sierra Leone", "SL"],
     ["Singapore", "SG"],
     ["Slovak Republic", "SK"],
     ["Slovenia", "SI"],
     ["Solomon Islands", "Sb"],
     ["Somalia", "SO"],
     ["South Africa", "ZA"],
     ["Spain", "ES"],
     ["Sri Lanka", "LK"],
     ["St. Helena", "SH"],
     ["St. Pierre and Miquelon", "PM"],
     ["Sudan", "SD"],
     ["Suriname", "SR"],
     ["Svalbard and Jan Mayen Islands", "SJ"],
     ["Swaziland", "SZ"],
     ["Sweden", "SE"],
     ["Switzerland", "CH"],
     ["Syria", "SY"],
     ["Chinese Taipei", "TW"],
     ["Tajikistan", "TJ"],
     ["Tanzania", "TZ"],
     ["Thailand", "TH"],
     ["Togo", "TG"],
     ["Tokelau", "TK"],
     ["Tonga", "TO"],
     ["Trinidad and Tobago", "TT"],
     ["Tunisia", "TN"],
     ["Turkey", "TR"],
     ["Turkmenistan", "TM"],
     ["Turks and Caicos Islands", "TC"],
     ["Tuvalu", "TV"],
     ["US Minor Outlying Islands", "UM"],
     ["USSR (former)", "SU"],
     ["Uganda", "UG"],
     ["Ukraine", "UA"],
     ["United Arab Emirates", "AE"],
     ["United Kingdom", "UK"],
     ["United States", "US"],
     ["Uruguay", "UY"],
     ["Uzbekistan", "UZ"],
     ["Vanuatu", "VU"],
     ["Vatican City State (Holy See)", "VA"],
     ["Venezuela", "VE"],
     ["Viet Nam", "VN"],
     ["Virgin Islands (British)", "VG"],
     ["Virgin Islands (U.S.)", "VI"],
     ["Wallis and Futuna Islands", "WF"],
     ["Western Sahara", "EH"],
     ["Yemen", "YE"],
     ["Yugoslavia", "YU"],
     ["Zaire", "ZR"],
     ["Zambia", "ZM"],
     ["Zimbabwe", "ZW"]]
    CODES = ['CN', 'JP', 'US']

    QUESTION = [
      ["China", "CN"],
      ["Japan", "JP"],
      ["United States", "US"]
    ]

    PRIORITY = [
      ["China", "CN"],
      ["Chinese Taipei", "TW"],
      ["Hong Kong", "HK"],
      ["Japan", "JP"],
      ["Macau", "MO"],
      ["United States", "US"]
    ]
  end

  module Urls
    BASE = 'http://www.photocracy.org/'
    P3P = BASE + 'w3c/p3p.xml'
    EMAIL = 'info@photocracy.org'
  end

  module Login
    MAX_LOGIN_ATTEMPTS = 3
  end

  module Params
    LOGIN_REQUIRED = {
      :recent => "recent_login_required",
      :items => "items_login_required",
      :item => "item_login_required"
    }
    LAST_RESPONSE_PERCENT = 'last_response_percent_id'
    RANDOM_FIRST_QUESTION = 'random_first_question'
    RANDOM_NEW_QUESTION_PERCENT = 'random_new_question_percent'
    REFRESH_QUESTION_AFTER = 'refresh_question_after'
    NO_MODERATE_COMMENTS = 'no_moderate_comments'
    ITEM_FLAGS_FOR_SUSPEND = 'item_flags_for_suspend'
    COMMENT_FLAGS_FOR_SUSPEND = 'comment_flags_for_suspend'
    FLAG_QUESTION_IMAGE = 'flag_question_image'
    EXPIRE_USER_DATA_AFTER = 86400 # 1 day
    ENGLISH_VARY_PERCENT = 'english_vary_percent'

    module Spawn
      FETCH = 'spawn_fetch'
      GRAPH = 'spawn_graph'
    end

    module Default
      REFRESH_QUESTION_AFTER = 10
      ITEM_FLAGS_FOR_SUSPEND = 1
      COMMENT_FLAGS_FOR_SUSPEND = 1
    end
  end
  
  module Item
    RANK_ALGO_ID = 1
    DEFAULT_ITEM_NAME = 'NONE'
    PER_PAGE = 10
    LAST_RANK_RESPONSE = "last_rank_response"
    LAST_PERCENT_RESPONSE = "last_percent_response"
    REJECT_WITH_RATINGS_UNDER = 2
  end

  module Config
    TOP_ITEMS_FOR_USER = 3
    HASH_IP = true
    VISIT_STALE_AFTER = 10800 # 3 hours
    FLASH_DELAY = 3000
    DIR_NAME = "tmp/batch"
    DIR_PATH = "#{RAILS_ROOT}/#{DIR_NAME}"
    GOOGLE_ANALYTICS = PRODUCTION

    module Paths
      BASE = "#{RAILS_ROOT}/public/"
      PLOTS = "#{BASE}images/plots/"
    end

    module Admin
      LOCATIONS = ['All', 'CN', 'JP', 'US']
      
      module Paths
        BASE = "#{Constants::Config::Paths::BASE}admin/"
        PLOT = "#{BASE}images/"
        DATA = "#{BASE}data/"
      end
    end
  end

  module Prompts
    PRIME_FOR = 'prime_for'
    PRIME_TOP = 'prime_top'
    PROMPTS_PER_FETCH = 7
    MIN_AVAILABLE_PROMPTS = 3
    ANONYMOUS_USER_ID = 0

    module Default
      PRIME_FOR = 2 # prime user for num prompts
      PRIME_TOP = 10 # when priming prompt must be in top num
    end
  end

  module Responses
    NUM_RECENT_RESPONSES = 10
    MS_FACTOR = 10  # divided responsetimes by this factor, e.g. if 10 response times are in centiseconds
    TRACKED_RESPONSE_TIMES = 3
    MIN_RESPONSE_TIMES = 150 # min 100ths of second for 3 responses, 1.5s
    ALT = '_alt'
    WIDTH = 920

    module Delay
      ITEM = 500 # millisecs, constant set in JS too
      ITEM_APPEAR = 100 # millisecs, constant set in JS too
    end

    module UntilRank
      RESPONSES = 25
      ITEMS = 5
    end
  end

  module Display
    HIGHLIGHT = '#8BC53F'
    BORDER = '#CCC'
  end

  module Profile
    LAST_ITEMS_LIMIT = 10
  end
end

COUNTRIES = Constants::Countries::ALL