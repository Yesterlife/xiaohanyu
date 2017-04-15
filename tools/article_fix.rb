# coding: utf-8
require 'yaml'

def fix_english_word(content)
  alpha_re = /(\p{Han})([[:ascii:]]+?)(\p{Han})/
  word_fix = YAML::load(File.open('tags_fix.yaml').read)
  new_word_fix = {}
  word_fix.each_pair do |key, value|
    new_word_fix[key.downcase] = value
  end

  content.gsub(alpha_re) do
    if new_word_fix.has_key?($2.downcase)
      fix_word = new_word_fix[$2.downcase]
    else
      fix_word = $2
    end
    $1 + ' ' + fix_word +  ' ' + $3
  end
end

def fix_english_word_with_punct(content)
  alpha_re = /(\p{Han})([[:ascii:]]+?)(\p{Punct})/
  word_fix = YAML::load(File.open('tags_fix.yaml').read)
  new_word_fix = {}
  word_fix.each_pair do |key, value|
    new_word_fix[key.downcase] = value
  end

  content.gsub(alpha_re) do
    if new_word_fix.has_key?($2.downcase)
      fix_word = new_word_fix[$2.downcase]
    else
      fix_word = $2
    end
    $1 + ' ' + fix_word +  $3
  end
end

def fix_bullet_point(content)
  content.gsub(/^-\s+/, '- ')
end

def fix_org_properties(content)
  content.gsub(/.*PROPERTIES.*\n\s+:CUSTOM_ID:.*\n.*END.*\n\n/, '')
end

def fix_org_section_title(content)
  content.gsub(/(^\*{1,4})\s*.*\[.*\]\[(.*)\]\]/, '\1 \2')
end

def fix_source_code(content)
  content.gsub('BEGIN_EXAMPLE', 'BEGIN_SRC').
    gsub('END_EXAMPLE', 'END_SRC').
    gsub(' ', ' ')
end

def main(file)
  content = ''
  File.open(file) do |f|
    content = f.read
  end

  content =
    fix_english_word_with_punct(
      fix_english_word(
        fix_bullet_point(
          fix_org_properties(
            fix_org_section_title(
              fix_source_code(content)
            )
          )
        )
      )
    )

  File.open(file, 'w') do |f|
    f.write(content)
  end
end

if __FILE__ == $0
  main(ARGV[0])
end
