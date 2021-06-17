class QuizzesController < ApplicationController
    
    def next
        @current_answer = Answer.find(params[:user_answer])
        @current_answer.user = true
        @current_answer.save
        @finished_question = QuestionBank.find_by(id: @current_answer.question_bank_id)
        @finished_question.done = true
        @finished_question.save
        questions = QuestionBank.all()
        questions.each do |q|
            if !q.done
                redirect_to question_path(q.id, params[:quiz_id])
                return
            end
        end

        redirect_to pages_results_path
    end

    def create
     if QuestionBank.count > 0
        QuestionBank.delete_all
     end
     if Answer.count > 0
        Answer.delete_all
     end
     if Quiz.count > 0
        Quiz.delete_all
     end
     @current_quiz = Quiz.new(user_id: session[:user_id])
     num_questions = params[:question_amount].to_i
     @current_quiz.save
     already_added = []
     new_question = 0
     (1..num_questions).each do 
        question = @data[new_question]
        new_question = rand(15)
        if !already_added.include?(new_question)
            already_added << new_question
            adding_question = QuestionBank.create({quiz_id: @current_quiz.id,
            json_id: question["id"], question: question["question"], category:
            question["category"], difficulty: question["difficulty"], done: false,
            multiple_correct_answers: question["multiple_correct_answers"] ==
            "true" ? true : false})
            question["answers"].each do |k,v|
                Answer.create(question_bank_id: adding_question.id, answer: v, user: false, correct: question["correct_answers"]["#{k}_correct"])
            end
        else
            redo
        end
    end

     redirect_to question_path(QuestionBank.find_by(quiz_id: @current_quiz.id).id)
    end

    def reload
        answers= Answer.all()
        answers.each do |a|
            if a.user
                a.user = false
                a.save
            end
        end
        questions = QuestionBank.all()
        questions.each do |q|
            if q.done
                q.done = false
                q.save
            end
        end
        current_quiz = Quiz.find_by(user_id: session[:user_id])
        redirect_to question_path(QuestionBank.find_by(quiz_id: current_quiz.id).id)
    end


end