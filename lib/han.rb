# coding: utf-8
class HanFilter < Nanoc::Filter
  identifier :han

  def run(content, params = {})
    han_re = /(\p{Han}|，|。|？|！|：|；|（|）)\s(\p{Han}|，|。|？|！|：|；|（|）)/
    content.gsub(han_re) { $1 + $2 }
  end
end
