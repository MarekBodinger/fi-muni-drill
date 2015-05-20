class Classes.QuestionList
  constructor: (options)->
    @list_container = options.list_container
    @list_template = options.list_template
    @containers_container = options.containers_container
    @containers_template = options.containers_template
    $.getJSON options.filename, (data)=>
      setlist = data
      @render(setlist)

  render: (setlist)=>
    html = @list_template {
      list: setlist
    }
    @list_container.html(html)
    html = @containers_template {
      list: setlist
    }
    @containers_container.html(html)
    for set in setlist
      new Classes.Questions
        dataset: set.dataset
        container: $("#questions-" + set.id)
        template: _.template($('.question').first().html())
    $('.source-link').click ->
      window.location.href = "https://github.com/fprochazka/fi-muni-drill"


class Classes.Questions
  constructor: (options)->
    @container = options.container
    @template = options.template
    @name = options.name

    @done_questions = []
    $.getJSON options.dataset, (data)=>
      @questions = data
      @renderQuestion(@popRandomQuestion())

  renderQuestion: (question)=>
    @done_questions << @current_question if @current_question
    @current_question = question
    html = @template {
      question: question
      question_index: @done_questions.length
      total_questions: @done_questions.length + @questions.length
      dataset: @name
    }
    @container.html(html)
    @container.find('#submit-button').click @submit
    @container.find('#next-button').click @nextQuestion

  popRandomQuestion: =>
    if @questions.length == 0
      @questions = @done_questions
      @done_questions = []
    random_index = _.random(0,@questions.length-1)
    ret = @questions[random_index]
    @questions[random_index] = undefined
    @questions = _.compact(@questions)
    @done_questions.push ret
    ret

  submit: =>
    _.each @container.find('input[name=answer]'), (answer)=>
      li = @container.find(answer).parent().parent()
      li.removeClass "bad"
      li.removeClass "good"
      li.removeClass "missing"
      if answer.checked and $(answer).attr('value') == "false"
        li.addClass "bad"
      if !answer.checked and $(answer).attr('value') == "true"
        li.addClass "missing"
      if answer.checked and $(answer).attr('value') == "true"
        li.addClass "good"

  nextQuestion: =>
    @renderQuestion(@popRandomQuestion())