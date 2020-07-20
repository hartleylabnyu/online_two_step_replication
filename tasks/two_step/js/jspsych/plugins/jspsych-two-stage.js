/**
 *
 * plugin for displaying a stimulus and then a second image given a keyboard response
 *
 **/


jsPsych.plugins["two-stage"] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('two-stage', 'stimuli', 'image');

  plugin.info = {
    name: 'two-stage',
    description: '',
    parameters: {
      stimuli: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Stimuli',
        default: undefined,
        array: true,
        description: 'The images to be displayed.'
      },
      choices: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        array: false,
        pretty_name: 'Choices',
        default: 32,
        description: "Key press we're looking for."
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed below the stimulus.'
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
        description: 'How long to show trial before it ends.'
      },
    }
  }

  plugin.trial = function(display_element, trial) {

    var new_html = '<img src="'+trial.stimuli[0]+'" id="two-stage"></img>';

    // add prompt
    if (trial.prompt !== null){
      new_html += trial.prompt;
    }

    // draw
    display_element.innerHTML = new_html;

    var second_html = '<img src="'+trial.stimuli[1]+'" id="two-stage"></img>';

    // add prompt
    if (trial.prompt !== null){
      second_html += trial.prompt;
    }


    // store response
    var response = {
      rt: null,
      key: null 
    };

    var choice_pressed=0;

    // function to end trial when it is time
    var end_trial = function() {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // kill keyboard listeners
      if (typeof keyboardListener !== 'undefined') {
        jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
      }

      // gather the data to store for the trial
      var trial_data = {
        "rt": response.rt,
        "stimulus": trial.stimulus,
        "key_press": response.key,
        "duration": trial.trial_duration,
        "choice_pressed" : choice_pressed
      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // function to handle responses by the subject
    var after_response = function(info) {
      // only record the first response
      if (response.key == null) {
        response = info;
        if (info.key == trial.choices) {
          choice_pressed = 1;


         // after a valid response, the stimulus will have the CSS class 'responded'
        // which can be used to provide visual feedback that a response was recorded
        display_element.querySelector('#two-stage').className += ' responded';

          // clear the display
          display_element.innerHTML = '';
            // draw
          display_element.innerHTML = second_html;
          jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
        }
      } else if (info.key == trial.choices) {
            response = info;
            // after a valid response, the stimulus will have the CSS class 'responded'
            // which can be used to provide visual feedback that a response was recorded
            display_element.querySelector('#two-stage').className += ' responded';

          // clear the display
          display_element.innerHTML = '';
            // draw
          display_element.innerHTML = second_html;
          jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
      }
    };

    // start the response listener
      var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
        callback_function: after_response,
        valid_responses: jsPsych.ALL_KEYS,
        rt_method: 'date',
        persist: true,
        allow_held_key: false
      });


    // hide stimulus if stimulus_duration is set
    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        display_element.querySelector('#two-stage').style.visibility = 'hidden';
      }, trial.stimulus_duration);
    }

    // end trial if trial_duration is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }

  };

  return plugin;
})();
