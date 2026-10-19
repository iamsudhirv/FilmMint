# Film industries the app tracks. "bollywood" covers Indian cinema in all languages
# (Hindi, Tamil, Telugu, Malayalam, Punjabi, ...); Film#language records which.
module Industry
  LABELS = {
    "hollywood" => "Hollywood",
    "bollywood" => "Bollywood (all Indian languages)",
    "french" => "French cinema",
    "japanese" => "Japanese cinema",
    "pakistani" => "Pakistani cinema",
    "bhojpuri" => "Bhojpuri cinema",
    "portuguese" => "Portuguese cinema"
  }.freeze

  KEYS = LABELS.keys.freeze
end
