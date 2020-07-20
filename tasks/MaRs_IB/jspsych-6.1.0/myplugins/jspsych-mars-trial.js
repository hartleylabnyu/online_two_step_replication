/**
 * jspsych-mars-trial
 * Josh de Leeuw
 *
 * plugin for displaying a stimulus and getting a keyboard response
 *
 * documentation: docs.jspsych.org
 *
 **/

jsPsych.plugins["mars-trial"] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'mars-trial',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Stimulus',
        default: undefined,
        description: 'The HTML string to be displayed'
      },
      choices: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Choices',
        default: undefined,
        array: true,
        description: 'The labels for the buttons.'
      },
      button_html: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Button HTML',
        default: '<button class="jspsych-btn">%choice%</button>',
        array: true,
        description: 'The html of the button. Can create own style.'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed under the button.'
      },
      stimulus_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus duration',
        default: null,
        description: 'How long to hide the stimulus.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show the trial.'
      },
      countdown_start: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Countdown duration',
        default: null,
        description: 'How long to show the countdown timer.'
      },
      margin_vertical: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Margin vertical',
        default: '0px',
        description: 'The vertical margin of the button.'
      },
      margin_horizontal: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Margin horizontal',
        default: '8px',
        description: 'The horizontal margin of the button.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: true,
        description: 'If true, then trial will end when user responds.'
      },
      shuffle_buttons: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Shuffle buttons',
        default: false,
        description: 'If true, then order of buttons will be shuffled.'
      },
      display_feedback: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Display feedback',
        default: false,
        description: 'If true, then feedback will be displayed after a button press.'
      },
      feedback_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Feedback duration',
        default: 2000,
        description: 'Length of time for which feedback is displayed.'
      },
      pos_img: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Positive feedback image',
        default: null,
        description: 'Image to display after correct response.'
      },
      neg_img: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Negative feedback image',
        default: null,
        description: 'Image to display after incorrect response.'
      },
    }
  }

  plugin.trial = function(display_element, trial) {

    // display stimulus
    var html = '<div id="jspsych-mars-trial-stimulus">'+trial.stimulus+'</div>';

    //display buttons
    var buttons = [];
    if (Array.isArray(trial.button_html)) {
      if (trial.button_html.length == trial.choices.length) {
        buttons = trial.button_html;
      } else {
        console.error('Error in mars-trial plugin. The length of the button_html array does not equal the length of the choices array');
      }
    } else {
      for (var i = 0; i < trial.choices.length; i++) {
        buttons.push(trial.button_html);
      }
    }
    html += '<div id="jspsych-mars-trial-btngroup">';

    var k_array = [0, 1, 2, 3]
    k_array = jsPsych.randomization.shuffle(k_array)

    for (var i = 0; i < trial.choices.length; i++) {
      if (trial.shuffle_buttons){
      k = k_array[i]}
      else {k = i}
      var str = buttons[k].replace(/%choice%/g, trial.choices[k]);
      html += '<div class="jspsych-mars-trial-button" style="display: inline-block; margin:'+trial.margin_vertical+' '+trial.margin_horizontal+'" id="jspsych-mars-trial-button-' + i +'" data-choice="'+i+'">'+str+'</div>';
    }
    html += '</div>';

    //show prompt if there is one
    if (trial.prompt !== null) {
      html += trial.prompt;
    }
    display_element.innerHTML = html;

    //display timer
    if(trial.countdown_start !== null){ // if there is a timer
    jsPsych.pluginAPI.setTimeout(function(){
        html += "<div id='timer'> <img src='img/timer5.png' height='100' width='100'></img> </div>"
        display_element.innerHTML = html;
         // add event listeners to buttons
      for (var i = 0; i < trial.choices.length; i++) {
      display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
        var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
        after_response(choice);});
    }

      }, trial.countdown_start);


      jsPsych.pluginAPI.setTimeout(function(){
        html += "<div id='timer'> <img src='img/timer4.png' height='100' width='100'></img> </div>"
        display_element.innerHTML = html;
          // add event listeners to buttons
      for (var i = 0; i < trial.choices.length; i++) {
        display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
          var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
          after_response(choice);
        });
      }
      }, trial.countdown_start + 1000);

      jsPsych.pluginAPI.setTimeout(function(){
        html += "<div id='timer'> <img src='img/timer3.png' height='100' width='100'></img> </div>"
        display_element.innerHTML = html;
          // add event listeners to buttons
      for (var i = 0; i < trial.choices.length; i++) {
        display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
          var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
          after_response(choice);
        });
      }
      }, trial.countdown_start + 2000);

      jsPsych.pluginAPI.setTimeout(function(){
        html += "<div id='timer'> <img src='img/timer2.png' height='100' width='100'></img> </div>"
        display_element.innerHTML = html;
          // add event listeners to buttons
      for (var i = 0; i < trial.choices.length; i++) {
        display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
          var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
          after_response(choice);
        });
      }
      }, trial.countdown_start + 3000);

      jsPsych.pluginAPI.setTimeout(function(){
        html += "<div id='timer'> <img src='img/timer1.png' height='100' width='100'></img> </div>"
        display_element.innerHTML = html;
          // add event listeners to buttons
      for (var i = 0; i < trial.choices.length; i++) {
        display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
          var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
          after_response(choice);
        });
      }
      }, trial.countdown_start + 4000);

    }


    // start time
    var start_time = performance.now();

    // add event listeners to buttons
    for (var i = 0; i < trial.choices.length; i++) {
      display_element.querySelector('#jspsych-mars-trial-button-' + i).addEventListener('click', function(e){
        var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
        after_response(choice);
      });
    }


    // store response
    var response = {
      rt: null,
      button: null,
      unshuffled_button: null
    };

    // function to handle responses by the subject
    function after_response(choice) {

      //clear timer
      jsPsych.pluginAPI.clearAllTimeouts();

      // measure rt
      var end_time = performance.now();
      var rt = end_time - start_time;
      response.button = choice;
      response.rt = rt;
      response.unshuffled_button = k_array[choice]


      // after a valid response, the stimulus will have the CSS class 'responded'
      // which can be used to provide visual feedback that a response was recorded
      display_element.querySelector('#jspsych-mars-trial-stimulus').className += ' responded';

      // disable all the buttons after a response
      var btns = document.querySelectorAll('.jspsych-mars-trial-button button');
      for(var i=0; i<btns.length; i++){
        //btns[i].removeEventListener('click');
        btns[i].setAttribute('disabled', 'disabled');
      }

      //display feedback
      var display_feedback = trial.display_feedback
      if(display_feedback){
        if(response.unshuffled_button == 0){
          html += "<div id='timer'> <img src='img/blanktimer.png' height='100' width='100'></img> </div>"
          html += trial.pos_img;
        }
        else if(response.unshuffled_button !== 0){
          html += "<div id='timer'> <img src='img/blanktimer.png' height='100' width='100'></img> </div>"
          html += trial.neg_img;
        }
        display_element.innerHTML = html;
      }

      if (trial.response_ends_trial) {
      jsPsych.pluginAPI.setTimeout(function(){
        end_trial();},
        trial.feedback_duration)
      }
    };

    // function to end trial when it is time
    function end_trial() {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // gather the data to store for the trial
      var trial_data = {
        "rt": response.rt,
        "stimulus": trial.stimulus,
        "button_pressed": response.button,
        "unshuffled_button": response.unshuffled_button
      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // hide image if timing is set
    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        display_element.querySelector('#jspsych-mars-trial-stimulus').style.visibility = 'hidden';
      }, trial.stimulus_duration);
    }

    // end trial if time limit is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }

  };

  return plugin;
})();
