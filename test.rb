require 'minitest/autorun'
require './typeform_connector'

class Import_Test < Minitest::Test

  PARCOURS_JSON = JSON.parse(File.read 'parcours.json')
  INSCRIPTION_JSON = JSON.parse(File.read 'inscription.json')
  NEW_INSCRIPTION_JSON = JSON.parse(File.read 'new_inscription.json')
  ACTUALLY_JSON = JSON.parse(File.read 'actually.json')

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

  def test_build_users_from_new_inscription_json
    users = build_users_from_json(NEW_INSCRIPTION_JSON)

    assert_equal(10, users.length)
    assert_equal('julie.pairault@hotmail.com', users[0][:email])
    assert_equal('Julie', users[0][:first_name])
    assert_equal('Directrice congrès et evenements en hotellerie de luxe', users[0][:job_title])
    assert_equal('Organisation, minutie, contact, synergie, creativite ', users[0][:keyword_list])
    assert_equal(2, users[0][:questions_attributes].length)
    assert_equal('Je vends et organise des evenements', users[0][:questions_attributes][0][:answer])
    assert_equal('J\'aime le contact avec le client', users[0][:questions_attributes][1][:answer])
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

  def test_build_actually_questions_from_json
    ids_questions = build_actually_ids_questions_from_json(ACTUALLY_JSON)

    assert_equal(2, ids_questions.length)
    assert_equal("48", ids_questions[0][:id])

    assert_equal('how_many_people_in_company', ids_questions[0][:questions][:questions_attributes][0][:identifier])
    assert_equal('1 seule personne, moi ;-)', ids_questions[0][:questions][:questions_attributes][0][:answer])

    assert_equal('solo_vs_team', ids_questions[0][:questions][:questions_attributes][1][:identifier])
    assert_equal('3', ids_questions[0][:questions][:questions_attributes][1][:answer])

    assert_equal('who_do_you_work_with', ids_questions[0][:questions][:questions_attributes][2][:identifier])
    assert_equal('Clients, partenaires', ids_questions[0][:questions][:questions_attributes][2][:answer])

    assert_equal('manual_or_intellectual', ids_questions[0][:questions][:questions_attributes][3][:identifier])
    assert_equal('2', ids_questions[0][:questions][:questions_attributes][3][:answer])

    assert_equal('foreign_language_mandatory', ids_questions[0][:questions][:questions_attributes][4][:identifier])
    assert_equal('5', ids_questions[0][:questions][:questions_attributes][4][:answer])

    assert_equal('always_on_the_road', ids_questions[0][:questions][:questions_attributes][5][:identifier])
    assert_equal('3', ids_questions[0][:questions][:questions_attributes][5][:answer])

    assert_equal('inside_or_outside_work', ids_questions[0][:questions][:questions_attributes][6][:identifier])
    assert_equal('2', ids_questions[0][:questions][:questions_attributes][6][:answer])

    assert_equal('self_time_management', ids_questions[0][:questions][:questions_attributes][7][:identifier])
    assert_equal('4', ids_questions[0][:questions][:questions_attributes][7][:answer])

    assert_equal('qualification_required', ids_questions[0][:questions][:questions_attributes][8][:identifier])
    assert_equal('0', ids_questions[0][:questions][:questions_attributes][8][:answer])

    assert_equal('typical_workday', ids_questions[0][:questions][:questions_attributes][9][:identifier])
    assert_equal('Très difficile', ids_questions[0][:questions][:questions_attributes][9][:answer])

    assert_equal('how_fun_was_this_form', ids_questions[0][:questions][:questions_attributes][10][:identifier])
    assert_equal('3', ids_questions[0][:questions][:questions_attributes][10][:answer])

    assert_equal('actually_something_to_add', ids_questions[0][:questions][:questions_attributes][11][:identifier])
    assert_equal('Questions plus personnelles bienvenues :)', ids_questions[0][:questions][:questions_attributes][11][:answer])
  end


end