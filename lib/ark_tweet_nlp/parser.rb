require 'set'

module ArkTweetNlp
  module Parser
    TAGSET = {
      :N => 'common noun',
      :O => 'pronoun, non possessive',
      :^ => 'proper noun',
      :S => 'nominal + possessive',
      :Z => 'proper noun + possessive',
      :V => 'verb including copula, auxiliaries',
      :L => 'nominal + verbal (e.g. i’m), verbal + nominal (let’s)',
      :M => 'proper noun + verbal',
      :A => 'adjective',
      :R => 'adverb',
      :! => 'interjection',
      :D => 'determiner',
      :P => 'pre- or postposition, or subordinating conjunction',
      :& => 'coordinating conjunction',
      :T => 'verb particle',
      :X => 'existential there, predeterminers',
      :Y => 'X + verbal',
      :'#' => 'hashtag (indicates topic/category for tweet)',
      :'@' => 'at-mention (indicates a user as a recipient of a tweet)',
      :~ => 'discourse marker, indications of continuation across multiple tweets',
      :U => 'URL or email address',
      :E => 'emoticon',
      :'$' => 'numeral',
      :',' => 'punctuation',
      :G => 'other abbreviations, foreign words, possessive endings, symbols, garbage'
    }
    TAGGER_PATH = File.join(Dir.pwd , '/bin/ark-tweet-nlp-0.3.2/runTagger.sh')

    def Parser.ola
      "ola"
    end

    def Parser.find_tags text
      result = Parser.run_tagger(text)
      result.split("\n").map{ |line| Parser.convert_line( line ) }
    end

    def Parser.get_words_tagged_as tagged_result, *tags
      Parser.merge_array( tagged_result.map{ |e| Parser.safe_invert( e ).select{ |key| tags.include? key } })
    end

    private
    def Parser.merge hash1, hash2
      hash2.each{ |key, value| hash1[key] ||= Set.new; hash1[key] << value }
    end

    # merges all hashs inside array
    def Parser.merge_array arr
      arr.each.inject({}){ |res,hash| Parser.merge(res,hash) }
    end

    def Parser.run_tagger text
      `echo '#{text}' | #{TAGGER_PATH}`
    end

    def Parser.convert_line line
      text = line.split("\t")[0].split
      tags = line.split("\t")[1].split
      text.each.with_index.inject({}){ |result,(value,index)| result[value] = tags[index].to_sym; result }
    end

    def Parser.safe_invert hash
       hash.each.inject({}){|sum,val| sum[val.last] ||= Set.new; sum[val.last] << val.first; sum}
    end

  end
end
