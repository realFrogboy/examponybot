require 'test/unit'
require_relative '../lib/dbstructure.rb'
require_relative '../lib/handlers.rb'

class TestUser < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
  end

  def test_constructor
    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    assert_equal(user.userid, 42)
    assert_equal(user.privlevel, USER_STATE[:regular])
    assert_equal(user.username, "IVAN")
  end

  def test_get_user
    User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    user = User.new(@dbl, 43, USER_STATE[:priviledged], "IVAN2")
    id = user.id
    User.new(@dbl, 44, USER_STATE[:regular], "IVAN3")

    user = User.new(@dbl, 43)
    assert_equal(user.id, id)
    assert_equal(user.userid, 43)
    assert_equal(user.privlevel, USER_STATE[:priviledged])
    assert_equal(user.username, "IVAN2")
  end

  def test_update_name
    user1 = User.new(@dbl, 42, USER_STATE[:priviledged], "IVAN")
    User.new(@dbl, 42, USER_STATE[:regular], "IVAN2")

    user = User.new(@dbl, 42)

    assert_equal(user.id, user1.id)
    assert_equal(user.userid, 42)
    assert_equal(user.privlevel, USER_STATE[:priviledged])
    assert_equal(user.username, "IVAN2")
  end

  def test_nonexistent
    user = User.new(@dbl, 42)
    assert_equal(user.userid, nil)
    assert_equal(user.privlevel, USER_STATE[:nonexistent])
    assert_equal(user.username, nil)
  end

  def test_is_priviledged
    user = User.new(@dbl, 43, USER_STATE[:priviledged], "IVAN2")
    assert_equal(user.privlevel, USER_STATE[:priviledged])
    assert_true(user.is_priviledged)

    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    assert_false(user.is_priviledged)
  end

  def test_nth_question
    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla")
    question2 = Question.new(@dbl, 2, 1, "bla1")
    question3 = Question.new(@dbl, 42, 1, "bla2")
    UserQuestion.new(@dbl, exam.id, user.id, question1.id)
    UserQuestion.new(@dbl, exam.id, user.id, question2.id)
    UserQuestion.new(@dbl, exam.id, user.id, question3.id)

    uq = user.nth_question(exam.id, 2)
    assert_equal(uq.questionid, question2.id)

    uq = user.nth_question(exam.id, 42)
    assert_equal(uq.questionid, question3.id)

    uq = user.nth_question(exam.id, 3)
    assert_nil(uq)
  end

  def test_n_reviews
    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    reviewer = User.new(@dbl, 43, USER_STATE[:regular], "IVAN2")
    exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    uq1 = UserQuestion.new(@dbl, exam.id, user.id, question1.id)
    uq2 = UserQuestion.new(@dbl, exam.id, user.id, question2.id)
    uq3 = UserQuestion.new(@dbl, exam.id, user.id, question3.id)
    ur1 = UserReview.new(@dbl, reviewer.id, uq1.id)
    ur2 = UserReview.new(@dbl, reviewer.id, uq2.id)
    ur3 = UserReview.new(@dbl, reviewer.id, uq3.id)

    n_reviews = reviewer.n_reviews
    assert_equal(n_reviews, 0)

    Review.new(@dbl, ur1.id, 10, "Nice!")
    Review.new(@dbl, ur2.id, 10, "Nice!")
    Review.new(@dbl, ur3.id, 10, "Nice!")

    n_reviews = reviewer.n_reviews
    assert_equal(n_reviews, 3)
  end

  def test_all_answers
    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    uq1 = UserQuestion.new(@dbl, exam.id, user.id, question1.id)
    uq2 = UserQuestion.new(@dbl, exam.id, user.id, question2.id)
    uq3 = UserQuestion.new(@dbl, exam.id, user.id, question3.id)

    Answer.new(@dbl, uq2.id, "Good answer2")

    answers = user.all_answers
    assert_equal(answers.length(), 1)
    assert_equal(answers[0].uqid, uq2.id)
    assert_equal(answers[0].text, "Good answer2")

    Answer.new(@dbl, uq2.id, "Good answer")
    answers = user.all_answers
    assert_equal(answers.length(), 1)
    assert_equal(answers[0].uqid, uq2.id)
    assert_equal(answers[0].text, "Good answer")

    Answer.new(@dbl, uq1.id, "Good answer1")
    Answer.new(@dbl, uq3.id, "Good answer3")
    answers = user.all_answers
    assert_equal(answers.length(), 3)
    assert_equal(answers[2].uqid, uq3.id)
    assert_equal(answers[2].text, "Good answer3")
  end

  def test_is_assigned_userreview
    user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    reviewer1 = User.new(@dbl, 43, USER_STATE[:regular], "IVAN2")
    reviewer2 = User.new(@dbl, 44, USER_STATE[:regular], "IVAN3")
    exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    uq1 = UserQuestion.new(@dbl, exam.id, user.id, question1.id)
    uq2 = UserQuestion.new(@dbl, exam.id, user.id, question2.id)
    uq3 = UserQuestion.new(@dbl, exam.id, user.id, question3.id)
    ur1 = UserReview.new(@dbl, reviewer1.id, uq1.id)
    ur2 = UserReview.new(@dbl, reviewer2.id, uq2.id)
    UserReview.new(@dbl, reviewer2.id, uq3.id)

    assert_true(reviewer1.is_assigned_userreview(ur1.id))
    assert_false(reviewer1.is_assigned_userreview(ur2.id))
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestExam < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
  end

  def test_constructor
    exam = Exam.new(@dbl, "test")
    assert_equal(exam.name, "test")
    assert_equal(exam.state, EXAM_STATE[:stopped])
  end

  def test_set_state
    exam = Exam.new(@dbl, "test")
    exam.set_state(EXAM_STATE[:reviewing])
    assert_equal(exam.state, EXAM_STATE[:reviewing])
  end

  # Several exams are not supported for now, so there is only one exam entity
  def test_several_exams
    Exam.new(@dbl, "test1")
    Exam.new(@dbl, "test2")
    exam = Exam.new(@dbl, "test3")

    assert_equal(exam.name, "test1")
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestQuestion < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
  end

  def test_constructor
    question = Question.new(@dbl, 1, 1, "bla")
    assert_equal(question.number, 1)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla")
  end

  def test_get_question
    Question.new(@dbl, 1, 1, "bla1")
    Question.new(@dbl, 2, 1, "bla2")
    Question.new(@dbl, 3, 1, "bla3")

    question = Question.new(@dbl, 2, 1)
    assert_equal(question.number, 2)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla2")
  end

  def test_update_question
    Question.new(@dbl, 1, 1, "bla")
    Question.new(@dbl, 1, 1, "bla1")

    question = Question.new(@dbl, 1, 1)
    assert_equal(question.number, 1)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla1")
  end

  def test_unexpected_number
    Question.new(@dbl, 42, 13, "bla1")
    Question.new(@dbl, 1, 1, "bla2")
    Question.new(@dbl, 42, 1, "bla3")

    question = Question.new(@dbl, 42, 13)
    assert_equal(question.number, 42)
    assert_equal(question.variant, 13)
    assert_equal(question.text, "bla1")

    question = Question.new(@dbl, 42, 1)
    assert_equal(question.number, 42)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla3")
  end

  def test_unregistered_question
    Question.new(@dbl, 1, 1, "bla")

    assert_raise(DBLayerError) { Question.new(@dbl, 1, 4) }
    assert_raise(DBLayerError) { Question.new(@dbl, 4, 1) }
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestUserQuestion < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
    @user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    @exam = Exam.new(@dbl, "exam")
    @question = Question.new(@dbl, 1, 1, "bla")
  end

  def test_constructor
    uq = UserQuestion.new(@dbl, @exam.id, @user.id, @question.id)
    assert_equal(uq.examid, @exam.id)
    assert_equal(uq.userid, @user.id)
    assert_equal(uq.questionid, @question.id)
  end

  def test_to_question
    uq = UserQuestion.new(@dbl, @exam.id, @user.id, @question.id)

    question = uq.to_question
    assert_equal(question.number, 1)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla")
  end

  def test_to_answer
    uq = UserQuestion.new(@dbl, @exam.id, @user.id, @question.id)
    Answer.new(@dbl, uq.id, "Good answer")

    answer = uq.to_answer
    assert_equal(answer.uqid, uq.id)
    assert_equal(answer.text, "Good answer")

    question1 = Question.new(@dbl, 2, 1, "bla1")
    uq = UserQuestion.new(@dbl, @exam.id, @user.id, question1.id)

    assert_nil(uq.to_answer)
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestAnswer < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
    @user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    @exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    @uq1 = UserQuestion.new(@dbl, @exam.id, @user.id, question1.id)
    @uq2 = UserQuestion.new(@dbl, @exam.id, @user.id, question2.id)
    @uq3 = UserQuestion.new(@dbl, @exam.id, @user.id, question3.id)
  end

  def test_constructor
    answer = Answer.new(@dbl, @uq1.id, "Good answer")
    assert_equal(answer.uqid, @uq1.id)
    assert_equal(answer.text, "Good answer")
  end

  def test_get_answer
    Answer.new(@dbl, @uq2.id, "Good answer2")
    Answer.new(@dbl, @uq3.id, "Good answer3")

    answer = Answer.new(@dbl, @uq2.id)
    assert_equal(answer.uqid, @uq2.id)
    assert_equal(answer.text, "Good answer2")

    answer = Answer.new(@dbl, @uq3.id)
    assert_equal(answer.uqid, @uq3.id)
    assert_equal(answer.text, "Good answer3")

    assert_raise(DBLayerError) { Answer.new(@dbl, 42) }
  end

  def test_update_answer
    Answer.new(@dbl, @uq1.id, "Good answer")
    Answer.new(@dbl, @uq1.id, "Good answer1")

    answer = Answer.new(@dbl, @uq1.id)
    assert_equal(answer.uqid, @uq1.id)
    assert_equal(answer.text, "Good answer1")
  end

  def test_to_question
    answer = Answer.new(@dbl, @uq2.id, "Good answer")

    question = answer.to_question
    assert_equal(question.number, 2)
    assert_equal(question.variant, 1)
    assert_equal(question.text, "bla2")
  end

  def test_all_reviews
    reviewer1 = User.new(@dbl, 43, USER_STATE[:regular], "IVAN2")
    ur1 = UserReview.new(@dbl, reviewer1.id, @uq1.id)

    reviewer2 = User.new(@dbl, 44, USER_STATE[:regular], "IVAN3")
    ur2 = UserReview.new(@dbl, reviewer2.id, @uq1.id)

    answer = Answer.new(@dbl, @uq1.id, "Good answer")

    reviews = answer.all_reviews
    assert_equal(reviews.length(), 0)

    Review.new(@dbl, ur1.id, 10, "Nice!")

    reviews = answer.all_reviews
    assert_equal(reviews.length(), 1)
    assert_equal(reviews[0].revid, ur1.id)

    Review.new(@dbl, ur2.id, 1, "Bad!")

    reviews = answer.all_reviews
    assert_equal(reviews.length(), 2)
    assert_equal(reviews[1].revid, ur2.id)
    assert_equal(reviews[1].text, "Bad!")
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestUserReview < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
    @user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    @reviewer = User.new(@dbl, 43, USER_STATE[:regular], "IVAN2")
    @exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    @uq1 = UserQuestion.new(@dbl, @exam.id, @user.id, question1.id)
    @uq2 = UserQuestion.new(@dbl, @exam.id, @user.id, question2.id)
    @uq3 = UserQuestion.new(@dbl, @exam.id, @user.id, question3.id)
  end

  def test_constructor
    ur = UserReview.new(@dbl, @reviewer.id, @uq1.id)
    assert_equal(ur.userid, @reviewer.id)
    assert_equal(ur.userquestionid, @uq1.id)
  end

  def test_same_user
    ur = UserReview.new(@dbl, @user.id, @uq1.id)
    assert_equal(ur.userid, @user.id)
    assert_equal(ur.userquestionid, @uq1.id)
  end

  def teardown
    system("rm unittest.db")
  end
end

class TestReview < Test::Unit::TestCase
  def setup
    @dbl = DBLayer.new('unittest.db')
    @user = User.new(@dbl, 42, USER_STATE[:regular], "IVAN")
    @reviewer = User.new(@dbl, 43, USER_STATE[:regular], "IVAN2")
    @exam = Exam.new(@dbl, "exam")
    question1 = Question.new(@dbl, 1, 1, "bla1")
    question2 = Question.new(@dbl, 2, 1, "bla2")
    question3 = Question.new(@dbl, 3, 1, "bla3")
    @uq1 = UserQuestion.new(@dbl, @exam.id, @user.id, question1.id)
    @uq2 = UserQuestion.new(@dbl, @exam.id, @user.id, question2.id)
    @uq3 = UserQuestion.new(@dbl, @exam.id, @user.id, question3.id)
    @ur1 = UserReview.new(@dbl, @reviewer.id, @uq1.id)
    @ur2 = UserReview.new(@dbl, @reviewer.id, @uq2.id)
    @ur3 = UserReview.new(@dbl, @reviewer.id, @uq3.id)
  end

  def test_constructor
    review = Review.new(@dbl, @ur1.id, 10, "Nice!")
    assert_equal(review.revid, @ur1.id)
    assert_equal(review.grade, 10)
    assert_equal(review.text, "Nice!")
  end

  def test_get_review
    Review.new(@dbl, @ur1.id, 10, "Nice!")

    review = Review.new(@dbl, @ur1.id)
    assert_equal(review.revid, @ur1.id)
    assert_equal(review.grade, 10)
    assert_equal(review.text, "Nice!")

    assert_raise(DBLayerError) { Review.new(@dbl, 42) }
  end

  def test_update_review
    Review.new(@dbl, @ur1.id, 10, "Nice!")

    review = Review.new(@dbl, @ur1.id)
    assert_equal(review.revid, @ur1.id)
    assert_equal(review.grade, 10)
    assert_equal(review.text, "Nice!")

    Review.new(@dbl, @ur1.id, 1, "Bad!")

    review = Review.new(@dbl, @ur1.id)
    assert_equal(review.revid, @ur1.id)
    assert_equal(review.grade, 1)
    assert_equal(review.text, "Bad!")
  end

  def teardown
    system("rm unittest.db")
  end
end
