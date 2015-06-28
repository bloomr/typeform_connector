require 'json'
require 'httparty'

URL = ENV['url']
KEY = ENV['key']
TYPEFORM_KEY = ENV['typeform_key']
INSCRIPTION_API_URL = "https://api.typeform.com/v0/form/ZDAyNU?key=#{TYPEFORM_KEY}&completed=true&limit=10&offset="
PARCOURS_API_URL    = "https://api.typeform.com/v0/form/gXeaxa?key=#{TYPEFORM_KEY}&completed=true&limit=10&offset="
ACTUALLY_API_URL    = "https://api.typeform.com/v0/form/EZBixl?key=#{TYPEFORM_KEY}&completed=true&limit=10&offset="

def is_new_creation_form?(answer)
  !answer["textfield_7635908"].nil?
end

def build_user_from_answer(answer)
  user = {
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

  if is_new_creation_form?(answer)
    user[:first_name]   = answer["textfield_2759788"]
    user[:keyword_list] = answer["textfield_7635908"]
  end

  user
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

def build_actually_questions_from_answer(answer)
  {
      questions_attributes: [
          {
              identifier: "how_many_people_in_company",
              title: "Combien y a-t-il de personnes dans la structure dans laquelle vous travaillez ?",
              answer: answer["list_3211156_choice"]
          }, {
              identifier: "solo_vs_team",
              title: "Au quotidien, vous travaillez plutôt seul(e) ou plutôt en équipe ?",
              answer: answer["opinionscale_6974948"]
          }, {
              identifier: "who_do_you_work_with",
              title: "Lors d'une journée typique, avec qui êtes-vous en relation ?",
              answer: answer["textarea_7015191"]
          }, {
              identifier: "manual_or_intellectual",
              title: "Votre métier est plutôt manuel ou plutôt cérébral ?",
              answer: answer["opinionscale_6974950"]
          }, {
              identifier: "foreign_language_mandatory",
              title: "Est-ce que la connaissance d'une langue étrangère est impérative pour exercer votre métier ?",
              answer: answer["opinionscale_6975003"]
          }, {
              identifier: "always_on_the_road",
              title: "Est-ce que vous vous déplacez souvent ?",
              answer: answer["opinionscale_6975078"]
          }, {
              identifier: "inside_or_outside_work",
              title: "Et vous travaillez plutôt à l'extérieur ou pas ?",
              answer: answer["opinionscale_7015042"]
          }, {
              identifier: "self_time_management",
              title: "Est-ce que vous gérez vous-même votre temps ?",
              answer: answer["opinionscale_6975119"]
          }, {
              identifier: "qualification_required",
              title: "Votre métier peut-il s'exercer sans qualification ?",
              answer: answer["yesno_3211154"]
          }, {
              identifier: "typical_workday",
              title: "Pour finir, pouvez-vous décrire le déroulement de votre journée type ?",
              answer: answer["textarea_7015225"]
          }, {
              identifier: "how_fun_was_this_form",
              title: "Diriez-vous que ce questionnaire a été une expérience plaisante ?",
              answer: answer["opinionscale_3211160"]
          }, {
              identifier: "actually_something_to_add",
              title: "Une chose à ajouter ?",
              answer: answer["textarea_3211152"]
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
  build_ids_and_questions_from_jsons(retrieve_all_jsons_from_typeform(PARCOURS_API_URL))
end

def post_questions_from_typeform(ids_questions)
  ids_questions.map { |q| puts post_user_questions(q[:questions], URL + "/" + q[:id], KEY) }
end

def build_actually_ids_questions_from_json(json)
  json['responses'].map { |response| { id: response['hidden']['id'], questions: build_actually_questions_from_answer(response['answers'])}}
end

def build_actually_ids_questions_from_jsons(jsons)
  jsons.map { |json| build_actually_ids_questions_from_json(json) }.flatten
end

def build_actually_questions_from_typeform
  build_actually_ids_questions_from_jsons(retrieve_all_jsons_from_typeform(ACTUALLY_API_URL))
end

if __FILE__ == $0
  post_users_from_typeform
  post_questions_from_typeform(build_questions_from_typeform())
  post_questions_from_typeform(build_actually_questions_from_typeform())
end