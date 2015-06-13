require 'minitest/autorun'
require './typeform_connector'

class Import_Test < Minitest::Test

  PARCOURS_JSON = JSON.parse(File.read 'parcours.json')
  INSCRIPTION_JSON = JSON.parse(File.read 'inscription.json')

  def test_extract_users_data
    user_data = extract_answers(INSCRIPTION_JSON)

    assert_equal(2, user_data.length)
    assert_equal('Loulou', user_data[0]['textfield_2760418'])
  end

  def test_build_users_from_json
    users = build_users_from_json(INSCRIPTION_JSON)

    assert_equal(2, users.length)
    assert_equal('loulou@lola.com', users[0][:email])
    assert_equal('Loulou', users[0][:first_name])
    assert_equal('Consultant Formateur', users[0][:job_title])
    assert_equal('entreprenariat, création', users[0][:keyword_list])
    assert_equal(2, users[0][:questions_attributes].length)
    assert_equal('Mon métier', users[0][:questions_attributes][0][:answer])
    assert_equal('propose à toute', users[0][:questions_attributes][1][:answer])
  end

  def test_build_users_from_jsons
    users = build_users_from_jsons([INSCRIPTION_JSON, INSCRIPTION_JSON])

    assert_equal(4, users.length)
  end


  def test_select_only_responses_with_id
    responses = select_only_responses_with_id(PARCOURS_JSON)

    assert_equal(1, responses.length)
    assert_equal('303', responses[0]['id'])
  end

  def test_build_ids_and_questions_from_json
    ids_questions = build_ids_and_questions_from_json(PARCOURS_JSON)

    assert_equal(1, ids_questions.length)
    assert_equal("23", ids_questions[0][:id])

    assert_equal('what_job_did_you_want_to_do', ids_questions[0][:questions][:questions_attributes][0][:identifier])
    assert_equal('n', ids_questions[0][:questions][:questions_attributes][0][:position])
    assert_equal('Je ne savais vraiment pas.', ids_questions[0][:questions][:questions_attributes][0][:answer])

    assert_equal('Et comment êtes-vous devenu(e) Conseillère emploi et formation ?', ids_questions[0][:questions][:questions_attributes][1][:title])
  end

  def test_build_ids_and_questions_from_jsons
    ids_questions = build_ids_and_questions_from_jsons([PARCOURS_JSON,PARCOURS_JSON])

    assert_equal(2, ids_questions.length)
    assert_equal("23", ids_questions[0][:id])
  end
end