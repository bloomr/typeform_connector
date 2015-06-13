require 'json'
require 'httparty'

URL = ENV['url']
KEY = ENV['key']
TYPEFORM_KEY = ENV['typeform_key']
INSCRIPTION_API_URL = "https://api.typeform.com/v0/form/ZDAyNU?key=#{TYPEFORM_KEY}&completed=true&limit=10&offset="
PARCOURS_API_URL    = "https://api.typeform.com/v0/form/gXeaxa?key=#{TYPEFORM_KEY}&completed=true&limit=10&offset="

def build_user_from_answer(answer)
  {
    email:      answer["email_2760387"],
    first_name: answer["textfield_2760418"],
    job_title:  answer["textfield_2761813"],
    keyword_list: answer["textfield_2759788"],
    questions_attributes: [{
      identifier: "specifically",
      position: "specifically",
      title: "Que faites vous exactement ?",
      answer: answer["textarea_2759680"]
    },{
      identifier: "love_job",
      position: "love_job",
      title: "Au fond, qu'est ce qui fait que vous aimez votre métier ?",
      answer: answer["textarea_2759737"]
    }]
  }
end

def build_question_from_answer_and_hidden(answer, hidden)
  {
      questions_attributes: [
          {
              identifier: "what_job_did_you_want_to_do",
              position: "n",
              title: "Quand vous étiez au collège ou au lycée, qu'est-ce que vous vouliez faire plus tard ?",
              answer: answer["textarea_3235955"]
          }, {
              identifier: "how_did_you_become",
              position: "o",
              title: "Et comment êtes-vous devenu(e) #{hidden['metier']} ?",
              answer: answer["textarea_3023382"]
          }, {
              identifier: "talk_to_your_15_self",
              position: "p",
              title: "Aujourd'hui, que diriez-vous à la personne que vous étiez quand vous aviez 15 ans ?",
              answer: answer["textarea_3023840"]
          }
      ]
  }
end

def extract_answers(json)
  json['responses'].map { |r| r['answers'] }
end

def build_users_from_json(json)
  extract_answers(json).map { |answer| build_user_from_answer(answer) }
end

def build_users_from_jsons(jsons)
  jsons.map { |json| build_users_from_json(json) }.flatten
end

def retrieve_json_from_typeform(url, offset)
  JSON.parse(HTTParty.get(url + offset.to_s).body)
end

def more_result?(json)
  json['stats']['responses']['showing'] > 0
end

def retrieve_all_jsons_from_typeform(url)
  jsons = []
  continue = true
  offset=0

  while continue do
    json = retrieve_json_from_typeform(url, offset)
    if more_result? json
      puts "current offset: #{offset}"
      jsons.push json
      offset += 10
    else
      continue = false
    end
  end

  jsons
end

def post_user user, url, key
  HTTParty.post(url,
      :body => { :user => user, :key => key }.to_json,
      :headers => {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
      }
  )
end

def post_user_questions user, url, key
  HTTParty.patch(url,
      :body => { :user => user, :key => key }.to_json,
      :headers => {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
      }
  )
end

def build_users_from_typeform
  build_users_from_jsons(retrieve_all_jsons_from_typeform(INSCRIPTION_API_URL))
end

def post_users_from_typeform
  build_users_from_typeform().map { |u| puts post_user(u, URL, KEY) }
end

def has_id?(response)
  !response['hidden']['id'].empty?
end

def select_only_responses_with_id(json)
  json["responses"].select { |response| has_id?(response) }
end

def build_ids_and_questions_from_json(json)
  select_only_responses_with_id(json).map { |response| { id: response['hidden']['id'], questions: build_question_from_answer_and_hidden(response['answers'], response['hidden'])}}
end

def build_ids_and_questions_from_jsons(jsons)
  jsons.map { |json| build_ids_and_questions_from_json(json) }.flatten
end

def build_questions_from_typeform
  qs = build_ids_and_questions_from_jsons(retrieve_all_jsons_from_typeform(PARCOURS_API_URL))
  puts qs.length
  qs
end

def post_questions_from_typeform
  build_questions_from_typeform().map { |q| puts post_user_questions(q[:questions], URL + "/" + q[:id], KEY) }
end

if __FILE__ == $0
  post_users_from_typeform
  post_questions_from_typeform
end